-- File: helper_package.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

package helper_package is
-- Declarations (types, constants, functions, etc.)
	type int_array is array (natural range <>) of integer range 0 to 255;	
	subtype stdlv1024 is std_logic_vector(1023 downto 0);
--functions
Function intarr128toSTDLV(input_arr	:	int_array(127 downto 0)) return stdlv1024;

Function STDLVtointarr128(input_arr	:	stdlv1024) return int_array;

Function median(a : integer range 0 to 255; b : integer range 0 to 255; c : integer range 0 to 255) return integer;

end helper_package;

package body helper_package is

function intarr128toSTDLV(input_arr : int_array(127 downto 0)) return stdlv1024 is
        variable result : stdlv1024 := (others => '0');
        variable temp   : unsigned(7 downto 0);
    begin
        for i in 127 downto 0 loop
            temp := to_unsigned(input_arr(i), 8);
            -- Place temp into the correct segment of the result
            result((i+1)*8-1 downto i*8) := std_logic_vector(temp);
        end loop;
        return result;
    end function intarr128toSTDLV;


function STDLVtointarr128(input_arr : stdlv1024) return int_array is
		variable result : int_array(127 downto 0) := (others => 0);
		variable temp   : unsigned(7 downto 0);
   begin
		for i in 127 downto 0 loop
			temp := unsigned(input_arr((i+1)*8-1 downto i*8));
			result(i) := to_integer(temp);
      end loop;
      return result;
    end function STDLVtointarr128;
	 
Function median(a : integer range 0 to 255; b : integer range 0 to 255; c : integer range 0 to 255) return integer is
	begin
		if((a>=b and b>=c) or (a<=b and b<=c)) then
			return b;
		elsif((b>=a and a>=c) or (b<=a and a<=c)) then
			return a;
		else
			return c;
		end if;
	end function median;

end helper_package;
