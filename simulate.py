from functools import reduce
from typing import Generator, Iterable, List, Tuple
from matplotlib import pyplot as plt
from math import ceil, log2, sin, pi

import random
from pathlib import Path
import textwrap
import re


def sin_wave(x: int) -> float:
    t = 100
    return 10 * sin(x * 2 * pi / t)


def step(x: int) -> float:
    return 0 if x < 50 else 250


def noise(xs: Iterable[float], sigma: float) -> Generator[float, None, None]:
    for x in xs:
        yield max(0, x + random.gauss(0, sigma))


def peak_noise(xs: Iterable[float], sigma: float) -> Generator[float, None, None]:
    for x in xs:
        yield max(0, x + (random.gauss(0, sigma) if random.randint(0, 99) < 5 else 0))


def median(xs: Iterable[int], window_size: int) -> Generator[int, None, None]:
    window_size = 3
    window = None
    for x in xs:
        if window is None:
            window = [x] * window_size

        window.append(x)
        window.pop(0)

        sw = sorted(window)
        if window_size % 2 == 1:
            yield sw[window_size // 2]
        else:
            yield (sw[window_size // 2 - 1] + sw[window_size // 2 + 1]) / 2


def low_freq(xs: Iterable[int], tau: int) -> Generator[int, None, None]:
    extra_bits = ceil(log2(tau))
    acc = 0
    for x in xs:
        acc = x * 2**extra_bits + acc - acc // tau
        yield acc // 2**extra_bits // tau


def iter_bits(values: Iterable[int], bit: int) -> Generator[int, None, None]:
    for v in values:
        yield (v >> bit) & 1


transition_list_pattern = re.compile(r"""
    TRANSITION_LIST\("signal_o\[(?P<bit>\d+)\]"\) \s*
    \{ \s*
        NODE \s*
	    \{ \s*
		    REPEAT\s*=\s*1; \s*
            (?P<transitions>[^}]*)
        \} \s*
    \}
    """, re.VERBOSE | re.MULTILINE)

transition_pattern = re.compile(r"""
    LEVEL \s+ (?P<value>[01]) \s* FOR \s* (?P<duration>\d+)
    """, re.VERBOSE)


def parse_transitions(transitions: str, time_offset: int, period: int) -> Generator[int, None, None]:
    for i, m in enumerate(re.finditer(transition_pattern, transitions)):
        value = int(m['value'])
        duration = int(m['duration'])
        if i == 0:
            duration -= time_offset
        for _ in range(duration // period):
            yield value


def read_output_waveform(file: Path, bits: int) -> Generator[int, None, None]:
    bit_sequences = {
        int(m['bit']): parse_transitions(m['transitions'], 100, 10)
        for m in re.finditer(transition_list_pattern, file.read_text())
    }
    for value_bits in zip(*(bit_sequences[i] for i in reversed(range(bits)))):
        yield reduce(lambda a, b: a * 2 + b, value_bits, 0)


def write_input_waveform(template_file: Path, file: Path, values: List[int], bits: int) -> None:
    signals = ""
    transitions = ""
    for i in range(bits):
        signals += textwrap.dedent(f"""\
            SIGNAL("signal_i[{i}]")
            {{
                VALUE_TYPE = NINE_LEVEL_BIT;
                SIGNAL_TYPE = SINGLE_BIT;
                WIDTH = 1;
                LSB_INDEX = -1;
                DIRECTION = INPUT;
                PARENT = "signal_i";
            }}
            """)
        tr_list = "\n".join(
            f"        LEVEL {bit} FOR 10.0;" for bit in iter_bits(values, i))
        transitions += textwrap.dedent(f"""
            TRANSITION_LIST("signal_i[{i}]")
            {{
                NODE
                {{
                    REPEAT = 1;
                    LEVEL 0 FOR 100.0;
                    {tr_list}
                }}
            }}
            """)

    template = template_file.read_text()
    file.write_text(
        template
        .replace('\* signals placeholder *\\', signals)
        .replace('\* transitions placeholder *\\', transitions))


sigma = 1

random.seed(0)
xs = list(range(300))
ys = map(step, xs)
ys = peak_noise(noise(ys, sigma), 100 * sigma)
ys = list(map(lambda x: int(round(x)), ys))

window_size = 3
tau = 10
data_bits = 10

median_ys = list(median(ys, window_size))
low_ys = list(low_freq(ys, tau))
median_then_low = list(low_freq(median(ys, window_size), tau))
low_then_median = list(median(low_freq(ys, tau), window_size))

write_input_waveform(Path('Waveform_template.vwf'),
                     Path('Waveform.vwf'), ys, data_bits)
sim_ys = list(read_output_waveform(
    Path('simulation/qsim/Filters.sim.vwf'), data_bits))[0:len(xs)]

plt.plot(xs, ys, 'k', label='signal')
#plt.plot(xs, median_ys, 'r', label='median')
#plt.plot(xs, low_ys, 'g', label='low_freq')
plt.plot(xs, median_then_low, 'r', label='median_then_low')
#plt.plot(xs, low_then_median, 'r', label='low_then_median')

plt.plot(xs, sim_ys, 'g', label='simulation')

plt.legend()
plt.show()
