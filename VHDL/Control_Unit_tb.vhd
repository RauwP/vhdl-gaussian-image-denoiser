library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.helper_package.all;

entity control_unit_tb is
	
end control_unit_tb;
architecture control_unit_tb_ARCH of control_unit_tb is

component control_unit
	port(
		clk				:	in	std_logic;
		rst				:	in	std_logic;
		start_pulse_p	:	in	std_logic;
		end_pulse_p		:	out	std_logic
	);
end component;

signal	clk					:	std_logic:='0';
signal	rst					:	std_logic:='1';
signal	start_pulse_p		:	std_logic:='0';
signal	end_pulse_p			:	std_logic;

begin
	u_control_unit	:	control_unit
	port map(
			clk				=>	clk,
			rst				=>	rst,
			start_pulse_p	=>	start_pulse_p,
			end_pulse_p		=>	end_pulse_p
	);

	
	process
	begin
		clk<= not clk;
		wait for 10 ns;
	end process;
	rst<='0' after 100 ns;
	start_pulse_p<='1' after 150 ns, '0' after 180 ns;
	
end architecture control_unit_tb_ARCH;
