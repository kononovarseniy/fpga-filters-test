package math is

	function log2 (x : positive) return natural;

end package math;


package body math is

	function log2 (x : positive) return natural is
      variable i : integer;
   begin
      i := 0;
      while (2**i < x) and i < 31 loop
         i := i + 1;
      end loop;
      return i;
   end function;

end package body math;
