library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.helper_package.all;

-- The processing_unit reads pixel data from a memory (via data_in), processes it using a 
-- pixel manipulation function (filter), and then writes the processed data out.
-- It operates line-by-line, using internal state machines and buffer arrays to handle 
-- a 3x3 neighborhood operation.


entity processing_unit is
	generic(
		test_mode		:	std_logic
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
end processing_unit;
architecture processing_unit_ARCH of processing_unit is
	type fsm_state_type is (IDLE_SM, READ_LEFT_FIRST_ROW_SM, IDLE1_FIRST_ROW_SM, IDLE2_FIRST_ROW_SM,READ_RIGHT_FIRST_ROW_SM,LOOP_START_SM,LOOP_WAIT_READ_LEFT1,LOOP_WAIT_READ_LEFT2,LOOP_READ_LEFT,LOOP_WAIT_READ_RIGHT1,LOOP_WAIT_READ_RIGHT2,LOOP_READ_RIGHT,LOOP_WRITE_LEFT,LOOP_WRITE_ADD_ADVANCE1,LOOP_WRITE_RIGHT,LOOP_WRITE_ADD_ADVANCE2,END_SM);
	signal processing_sm				:	fsm_state_type :=IDLE_SM;
	signal left_top_row					:	int_array(127 downto 0);
	signal left_middle_row				:	int_array(127 downto 0);
	signal left_buttom_row				:	int_array(127 downto 0);
	signal right_top_row				:	int_array(127 downto 0);
	signal right_middle_row				:	int_array(127 downto 0);
	signal right_buttom_row				:	int_array(127 downto 0);
	signal write_start_p_buff			:	std_logic;
	signal write_add_buff				:	std_logic_vector(8 downto 0);
	signal read_add_buff				:	std_logic_vector(8 downto 0);
	signal last_row_flag				:	std_logic:='0';
	
	constant zero_int					:	integer	:= 0;
begin
	
	read_add<=read_add_buff;
	
	write_add<=write_add_buff;
	
	write_start_p<=write_start_p_buff;
	
	process(clk, rst)
		variable medianleft 		:	integer range 0 to 255:=0;
		variable medianmiddle 	:	integer range 0 to 255:=0;
		variable medianright		:	integer range 0 to 255:=0;
	begin
		if(rst = '1') then
			end_pulse_p<='0';
			data_out<=(others=>zero_int);
			left_top_row<=(others=>zero_int);
			left_middle_row<=(others=>zero_int);
			left_buttom_row<=(others=>zero_int);
			right_top_row<=(others=>zero_int);
			right_middle_row<=(others=>zero_int);
			right_buttom_row<=(others=>zero_int);
			write_add_buff<=(others=>'0');
			read_add_buff<=(others=>'0');
			processing_sm<=IDLE_SM;
			write_start_p_buff<='0';
			last_row_flag<='0';
		else
			if(rising_edge(clk)) then
				case processing_sm is
					
					when	IDLE_SM =>
							if(start_pulse_p = '1') then
								processing_sm<=READ_LEFT_FIRST_ROW_SM;
							end if;
						
					when	READ_LEFT_FIRST_ROW_SM =>
							left_top_row(127 downto 0)<=data_in(127 downto 0);
							left_middle_row(127 downto 0)<=data_in(127 downto 0);
							read_add_buff<= read_add_buff + 1;
							processing_sm<=IDLE1_FIRST_ROW_SM;
							--|	1 cycle delay
							--V
					when	IDLE1_FIRST_ROW_SM =>
							processing_sm<=IDLE2_FIRST_ROW_SM;
							--|	1 cycle delay		
							--V
					when	IDLE2_FIRST_ROW_SM =>
							processing_sm<=READ_RIGHT_FIRST_ROW_SM;
							--| 1 cycle delay
							--V overall 3 cycle delay between writing to the read address reg to the data to staiblize
					when	READ_RIGHT_FIRST_ROW_SM =>
							right_top_row(127 downto 0)<=data_in(127 downto 0);
							right_middle_row(127 downto 0)<=data_in(127 downto 0);
							--jump to the middle of the loop
							read_add_buff<= read_add_buff + 1;
							processing_sm<=LOOP_WAIT_READ_LEFT1;

					when	LOOP_START_SM =>
							left_top_row<=left_middle_row;
							right_top_row<=right_middle_row;
							left_middle_row<=left_buttom_row;
							right_middle_row<=right_buttom_row;
							
							if(write_add_buff /= 510) then
								read_add_buff<= read_add_buff + 1;
								processing_sm<=LOOP_WAIT_READ_LEFT1;
							else
								last_row_flag<='1';
								processing_sm<=LOOP_WRITE_LEFT;
							end if;
							--|	1 cycle delay
							--V
					when	LOOP_WAIT_READ_LEFT1 =>
							processing_sm<=LOOP_WAIT_READ_LEFT2;
							--|	1 cycle delay
					when	LOOP_WAIT_READ_LEFT2 =>
							processing_sm<=LOOP_READ_LEFT;
							--|	1 cycle delay
							--V overall 3 cycle delay between writing to the read address reg to the data to staiblize					
					when	LOOP_READ_LEFT =>
							left_buttom_row(127 downto 0)<= data_in(127 downto 0);
							read_add_buff<= read_add_buff + 1;
							processing_sm<=LOOP_WAIT_READ_RIGHT1;
							--|	1 cycle delay
							--V
					when	LOOP_WAIT_READ_RIGHT1 =>
							processing_sm<=LOOP_WAIT_READ_RIGHT2;
							--|	1 cycle delay
							--V
					when	LOOP_WAIT_READ_RIGHT2 =>
							processing_sm<=LOOP_READ_RIGHT;
							--|	1 cycle delay
							--V	overall 3 cycle delay between writing to the read address reg to the data to staiblize
					when	LOOP_READ_RIGHT =>
							right_buttom_row(127 downto 0)<=data_in(127 downto 0);
							processing_sm<=LOOP_WRITE_LEFT;
							
					when	LOOP_WRITE_LEFT =>
							for i in 127 downto 0 loop
								if(i=127)then
									medianleft :=median(left_top_row(127),left_middle_row(127),left_buttom_row(127));
									medianmiddle :=medianleft;
									medianright :=median(left_top_row(126),left_middle_row(126),left_buttom_row(126));
								elsif(i /= 0) then
									medianleft:=medianmiddle;
									medianmiddle:=medianright;
									medianright:=median(left_top_row(i-1),left_middle_row(i-1),left_buttom_row(i-1));
								else
									medianleft := medianmiddle;
									medianmiddle := medianright;
									medianright := median(right_top_row(127),right_middle_row(127),right_buttom_row(127));
								end if;
								if(test_mode = '0') then
									data_out(i)<=median(medianleft,medianmiddle,medianright);
								else
									data_out(i)<=left_middle_row(i);
								end if;
							end loop;
							write_start_p_buff<='1';
							processing_sm<=LOOP_WRITE_ADD_ADVANCE1;
							
					when	LOOP_WRITE_ADD_ADVANCE1=>
							write_start_p_buff<='0';
							write_add_buff<= write_add_buff + 1;
							processing_sm<=LOOP_WRITE_RIGHT;
							
					when	LOOP_WRITE_RIGHT=>
							for i in 127 downto 0 loop
								if(i=127)then
									medianleft :=median(left_top_row(0),left_middle_row(0),left_buttom_row(0));
									medianmiddle :=median(right_top_row(127),right_middle_row(127),right_buttom_row(127));
									medianright :=median(right_top_row(126),right_middle_row(126),right_buttom_row(126));
								elsif(i /= 0) then
									medianleft:=medianmiddle;
									medianmiddle:=medianright;
									medianright:=median(right_top_row(i-1),right_middle_row(i-1),right_buttom_row(i-1));																							
								else
									medianleft:=medianmiddle;
									medianmiddle:=medianright;
									medianright:=medianright;																											
								end if;
								if(test_mode = '0') then
									data_out(i)<=median(medianleft,medianmiddle,medianright);
								else
									data_out(i)<=right_middle_row(i);
								end if;
							end loop;
							write_start_p_buff<='1';
							processing_sm<=LOOP_WRITE_ADD_ADVANCE2;
					
					when	LOOP_WRITE_ADD_ADVANCE2=>
							write_start_p_buff<='0';
							write_add_buff<= write_add_buff + 1;
							if(last_row_flag /= '1') then
								processing_sm<=LOOP_START_SM;
							else
								processing_sm<=END_SM;
							end if;
					
					when	END_SM=>
							end_pulse_p<='1';
							processing_sm<=IDLE_SM;
							
					when	OTHERS =>
							processing_sm<=processing_sm;
				end case;
			end if;
		end if;
	end process;
end architecture processing_unit_ARCH;
