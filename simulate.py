from typing import Generator, Iterable, List
from matplotlib import pyplot as plt
from math import ceil, log2, sin, pi

import random


def sin_wave(x: int) -> float:
    t = 100
    return 10 * sin(x * 2 * pi / t)


def step(x: int) -> float:
    return 0 if x < 50 else 250


def noise(xs: Iterable[float], sigma: float) -> Generator[float, None, None]:
    for x in xs:
        yield x + random.gauss(0, sigma)


def peak_noise(xs: Iterable[float], sigma: float) -> Generator[float, None, None]:
    for x in xs:
        yield x + (random.gauss(0, sigma) if random.randint(0, 99) < 5 else 0)


def median(xs: Iterable[float], window_size: int) -> Generator[float, None, None]:
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


def low_freq(xs: Iterable[float], tau: int) -> Generator[float, None, None]:
    extra_bits = ceil(log2(tau))
    acc = 0
    for x in xs:
        acc = x * 2**extra_bits + acc - acc // tau
        yield acc / 2**extra_bits / tau

sigma = 1

random.seed(0)
xs = list(range(300))
ys = list(peak_noise(noise(map(step, xs), sigma), 100 * sigma))

window_size = 3
tau = 10

median_ys = list(median(ys, window_size))
low_ys = list(low_freq(ys, tau))
median_then_low = list(low_freq(median(ys, window_size), tau))
low_then_median = list(median(low_freq(ys, tau), window_size))

plt.plot(xs, ys, 'k', label='signal')
#plt.plot(xs, median_ys, 'r', label='median')
#plt.plot(xs, low_ys, 'g', label='low_freq')
plt.plot(xs, median_then_low, 'r', label='median_then_low')
#plt.plot(xs, low_then_median, 'r', label='low_then_median')
plt.legend()
plt.show()
