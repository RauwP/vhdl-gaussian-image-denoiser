library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.helper_package.all;

entity color_control_unit is
	generic(
		inst_name	:	string;
		mif_path		:	string;
		test_mode	:	std_logic
		);
	port(
		clk				:	in		std_logic;
		rst				:	in 	std_logic;
		start_pulse_p	:	in		std_logic;
		end_pulse_p		:	out	std_logic
		);
end color_control_unit;
architecture color_control_unit_ARCH of color_control_unit is
--Components
	 
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
END component;
	
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
END component;

component processing_unit
	generic(
		test_mode	:	std_logic
	);
	Port(
			clk				:	in		std_logic;
			rst				:	in 	std_logic;
			start_pulse_p	:	in		std_logic;
			end_pulse_p		:	out	std_logic;
			
			data_in			:	in		int_array(127 downto 0);
			data_out			:	out	int_array(127 downto 0);
			
			write_start_p	:	out	std_logic;
			
			write_add		:	out	std_logic_vector(8 downto 0);
			read_add			:	out	std_logic_vector(8 downto 0)
);
end component;
--Signals
signal read_add, write_add	:	std_logic_vector(8 downto 0);
signal data_from_rom_stdlv, data_to_ram_stdlv	:	std_logic_vector(1023 downto 0);
signal data_from_rom_int, data_to_ram_int	:	int_array(127 downto 0);
signal wren	:	std_logic;

begin
	
	data_to_ram_stdlv<=intarr128toSTDLV(data_to_ram_int);
	data_from_rom_int<=STDLVtointarr128(data_from_rom_stdlv);

	
	u_rom:	ROM
		generic map(
			mif_path=>mif_path
		)
		port map(
			aclr		=>rst,
			address	=>read_add ,
			clock		=>clk,
			q		=>data_from_rom_stdlv
	);

	u_processing_unit	:	processing_unit
		generic map(
			test_mode=>test_mode
		)
		port map(
			clk=> clk,
			rst=>rst,
			start_pulse_p=>start_pulse_p,
			end_pulse_p=>end_pulse_p,
			
			data_in=>data_from_rom_int,
			data_out=>data_to_ram_int,
			
			write_start_p=>wren,
			
			write_add=>write_add,
			read_add=>read_add 
	);
	
	u_ram: RAM
		generic map(
			inst_name=>inst_name
		)
      port map(
         aclr		=>rst,
			address => write_add,      
         clock   => clk,
         data    => data_to_ram_stdlv,
         wren    => wren,
         q       => OPEN
      );


end architecture color_control_unit_ARCH;
