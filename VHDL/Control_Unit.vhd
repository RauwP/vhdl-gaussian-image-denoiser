library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.helper_package.all;

-- This is the top-level control unit for the image processing system.
-- It instantiates three parallel processing channels (R, G, B), each reading from a ROM, 
-- processing the data, and writing the results to a RAM.
-- The end_pulse_p signal is asserted when all three channels complete processing.


entity control_unit is
	Port(
			clk				:	in		std_logic;
			rst				:	in 	std_logic;
			start_pulse_p	:	in		std_logic;
			end_pulse_p		:	out	std_logic
);
				attribute altera_chip_pin_lc: string;
				attribute altera_chip_pin_lc of clk  : signal is "Y2";
				attribute altera_chip_pin_lc of rst  : signal is "AB28";
				attribute altera_chip_pin_lc of start_pulse_p: signal is "AC28";
				attribute altera_chip_pin_lc of end_pulse_p : signal is "E21";
end control_unit;
architecture control_unit_ARCH of control_unit is
--Components
component color_control_unit
	generic(
		inst_name	:	STRING;
		mif_path		:	STRING;
		test_mode	:	std_logic
	);
   port(
		clk				:	in		std_logic;
		rst				:	in 	std_logic;
		start_pulse_p	:	in		std_logic;
		end_pulse_p		:	out	std_logic	
	);
end component;
--signals
	 signal end_pulse_p_R, end_pulse_p_G, end_pulse_p_B : std_logic:='0';

	 
begin
-- end_pulse_p is the logical AND of end_pulse_p_R, end_pulse_p_G, and end_pulse_p_B.
-- This ensures that the top-level signal only goes high when all three channels have finished.

	end_pulse_p<=((end_pulse_p_R and end_pulse_p_G) and end_pulse_p_B);

	u_color_control_unit_r	:	color_control_unit
		generic map(
			inst_name=>"RRAM",
			mif_path=>"../ROM_init/lena_noise_r.mif",
			test_mode=>'0'
		)
		port map(
			clk=>clk,
			rst=>rst,
			start_pulse_p=>start_pulse_p,
			end_pulse_p=>end_pulse_p_R
		);

		u_color_control_unit_g	:	color_control_unit
		generic map(
			inst_name=>"GRAM",
			mif_path=>"../ROM_init/lena_noise_g.mif",
			test_mode=>'0'
		)
		port map(
			clk=>clk,
			rst=>rst,
			start_pulse_p=>start_pulse_p,
			end_pulse_p=>end_pulse_p_G
		);
		
		u_color_control_unit_b	:	color_control_unit
		generic map(
			inst_name=>"BRAM",
			mif_path=>"../ROM_init/lena_noise_b.mif",
			test_mode=>'0'
		)
		port map(
			clk=>clk,
			rst=>rst,
			start_pulse_p=>start_pulse_p,
			end_pulse_p=>end_pulse_p_B
		);
end architecture control_unit_ARCH;
