library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.helper_package.all;

entity processing_unit_tb is
	
end processing_unit_tb;
architecture processing_unit_tb_ARCH of processing_unit_tb is

component processing_unit
	generic(
		test_mode	:	std_logic
	);
	Port(
			clk					:	in		std_logic;
			rst					:	in 		std_logic;
			start_pulse_p		:	in		std_logic;
			end_pulse_p			:	out		std_logic;
			
			data_in				:	in		int_array(127 downto 0);
			data_out			:	out		int_array(127 downto 0);
			
			write_start_p		:	out		std_logic;
			
			write_add			:	out		std_logic_vector(8 downto 0);
			read_add			:	out		std_logic_vector(8 downto 0)
);
end component;

component RAM
	generic(
		inst_name	:	string
		);
    port(
        aclr		: in	std_logic;
		address	: in  std_logic_vector(8 downto 0);
        clock  	: in  std_logic;
        data   	: in  std_logic_vector(1023 downto 0);
        wren   	: in  std_logic;
        q      	: out std_logic_vector(1023 downto 0)
        );
end component;
	
component ROM
	generic(
		mif_path	:	string
		);
	port(
		aclr		: in  std_logic;
		address		: in  std_logic_vector(8 DOWNTO 0);
		clock		: in  std_logic;
		q		: out  std_logic_vector(1023 DOWNTO 0)
		);
end component;

signal	clk					:	std_logic:='0';
signal	rst					:	std_logic:='1';
signal	start_pulse_p		:	std_logic:='0';
signal	end_pulse_p			:	std_logic;
signal	wren				:	std_logic;
signal	data_from_ROM_std	:	std_logic_vector(1023 downto 0);
signal	data_from_ROM_int	:	int_array(127 downto 0);
signal	data_to_RAM_std		:	std_logic_vector(1023 downto 0);
signal	data_to_RAM_int		:	int_array(127 downto 0);
signal	write_address		:	std_logic_vector(8 downto 0);
signal	read_address		:	std_logic_vector(8 downto 0);

begin
	u_rom	:	ROM
		generic map(
			mif_path=>"./lena_noise_b.mif"
		)
		port map(
			aclr		=>rst,
			address		=>read_address ,
			clock		=>clk,
			q			=>data_from_ROM_std
		);
	
	u_processing_unit	:	processing_unit
		generic map(
			test_mode=>'0'
		)
		port map(
			clk					=>	clk,
			rst					=>	rst,
			start_pulse_p		=>	start_pulse_p,
			end_pulse_p			=>	end_pulse_p,
			
			data_in				=>	data_from_ROM_int,
			data_out			=>	data_to_RAM_int,
			
			write_start_p		=>	wren,
			
			write_add			=>	write_address,
			read_add			=>	read_address
		);

	u_ram	:	RAM
		generic map(
			inst_name=>"RAM0"
		)
		port map(
			aclr		=>	rst,
			address		=>	write_address,
			clock  		=>	clk,
			data   		=>	data_to_RAM_std,
			wren   		=>	wren,
			q      		=>	OPEN
		);
	
	data_from_ROM_int<=STDLVtointarr128(data_from_ROM_std);
	data_to_RAM_std<=intarr128toSTDLV(data_to_RAM_int);

	
	process
	begin
		clk<= not clk;
		wait for 10 ns;
	end process;
	rst<='0' after 100 ns;
	start_pulse_p<='1' after 150 ns, '0' after 180 ns;
	
end architecture processing_unit_tb_ARCH;
