

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

architecture rtl of cntr is

--	constant 	c_count_prescale_speed_0		:	std_logic_vector(27 downto 0) := x"5F5E100";  	--scale down for actual hardware 1Hz
--	constant 	c_count_prescale_speed_1		:	std_logic_vector(27 downto 0) := x"00F4240";  	--scale down for actual hardware 100Hz
--	constant 	c_count_prescale_speed_2		:	std_logic_vector(27 downto 0) := x"00186A0";  	--scale down for actual hardware 1kHz

	-- constant 	c_count_prescale_speed_0		:	std_logic_vector(27 downto 0) := x"0000008";  	--scale down for simulation (sytstemtest)
	-- constant 	c_count_prescale_speed_1		:	std_logic_vector(27 downto 0) := x"0000002";  	--scale down for simulation (sytstemtest)
	-- constant 	c_count_prescale_speed_2		:	std_logic_vector(27 downto 0) := x"0000001";  	--scale down for simulation (sytstemtest)
	
	constant	c_count_base_8					:	std_logic_vector(3 downto 0) := x"7";				--max value for base 8
	constant	c_count_base_10					:	std_logic_vector(3 downto 0) := x"9";				--max value for base 10
	constant	c_count_base_16					:	std_logic_vector(3 downto 0) := x"F";				--max value for base 16
	
	signal		s_sync_reset						:	std_logic;
	signal		s_count_base						:	std_logic_vector(3 downto 0);
	signal		s_count_prescale					:	std_logic_vector(27 downto 0);
	signal		s_cnt_mode							:	std_logic;
	signal		s_count_pulse_source				:	std_logic;        

	begin
	
		--proccess to decode input signals and setting the appropriate input signals for counter direction, base and speed
		p_decode_input : process(clk_i, reset_i)	
		
		variable v_old_base : std_logic_vector(3 downto 0);
		variable v_resetting : std_logic;
		
		begin
			if reset_i = '1' then
				s_cnt_mode <= '0';
			else
				if (clk_i'event and clk_i = '1') then
					--counter direction
					if cntrup_i = '0' and cntrdown_i = '1' then
						s_cnt_mode <= '1';
					elsif cntrup_i ='1' then
						s_cnt_mode <= '0';
					end if;
					s_count_base <= c_count_base_10 ;
				

				
				end if;
			end if;	
		end process;

		p_counter : process(clk_i, reset_i)
		
		--variable v_cnt_armed		:	std_logic;							--flag for edge detection
		variable v_cnt_overrun	:	std_logic;							--overrun indicator of subcounter
		variable v_count_0		:	std_logic_vector(3 downto 0);	--subcounter 0 value
		variable v_count_1		:	std_logic_vector(3 downto 0);	--subcounter 1 value
		variable v_count_2		:	std_logic_vector(3 downto 0);	--subcounter 2 value
		variable v_count_3		:	std_logic_vector(3 downto 0);	--subcounter 3 value

		begin
			if reset_i = '1' then											--asynchronous reset
				--if reverse count ? yes: set to max val, no -> to 0 
				if s_cnt_mode = '1' then									
					v_cnt_overrun := '0';									
					--v_cnt_armed := '1';
					v_count_0 := s_count_base;
					v_count_1 := s_count_base;
					v_count_2 := s_count_base;
					v_count_3 := s_count_base;
				else
					v_cnt_overrun := '0';
					--v_cnt_armed := '1';
					v_count_0 := x"0";
					v_count_1 := x"0";
					v_count_2 := x"0";
					v_count_3 := x"0";	
				end if;
			elsif clk_i'event and clk_i = '1'  then					--rising clock edge 
				--synchroinous counter reset performed ?
				
			
					-- counter is not set to hold and a rising edge of the pulse source is detected
					if cntrhold_i = '0' then
						--v_cnt_armed := '0';	 and s_count_pulse_source = '1' and v_cnt_armed = '1'								--disarm counter for edge detection
						--downward counting ?
						if s_cnt_mode = '0' then							--no count upwards
							--COUNTER 0 (is triggered 
							--sub counter 0 overrun ?
							if  v_count_0 >= s_count_base then			--yes set subcounter to its reset value and set the overrun indicator
								v_count_0 := x"0";
								v_cnt_overrun := '1';				
							else 													--no increment counter and set overrun indicator to 0
								v_count_0 := v_count_0 + 1;	
								v_cnt_overrun := '0';	

							end if;	
							--COUNTER 1 (is triggered by the overrun of the previous counter)
							--sub counter 1 overrun ?
							if v_cnt_overrun = '1' then
								if  v_count_1 >= s_count_base then		--yes set subcounter to its reset value and set the overrun indicator			
									v_count_1 := x"0";						
									v_cnt_overrun := '1';				
								else												--no increment counter and set overrun indicator to 0		 								
									v_count_1 := v_count_1 + 1;	
									v_cnt_overrun := '0';					--no increment counter
								end if;	
							end if;
							--COUNTER 2 (is triggered by the overrun of the previous counter)
							--sub counter 2 overrun ?
							if v_cnt_overrun = '1' then 
								if  v_count_2 >= s_count_base then		--yes set subcounter to its reset value and set the overrun indicator			
									v_count_2 := x"0";						
									v_cnt_overrun := '1';				
								else												--no increment counter and set overrun indicator to 0		 								
									v_count_2 := v_count_2 + 1;	
									v_cnt_overrun := '0';					
								end if;
							end if;
							--COUNTER 3 (is triggered by the overrun of the previous counter)
							--sub counter 3 overrun ?
							if v_cnt_overrun = '1' then
								if  v_count_3 >= s_count_base then		--yes set subcounter to its reset value and set the overrun indicator			
									v_count_3 := x"0";						
									v_cnt_overrun := '1';				
								else												--no increment counter and set overrun indicator to 0		 								
									v_count_3 := v_count_3 + 1;	
									v_cnt_overrun := '0';	
									end if;	
							end if;
--*****************************Counting down**************************************------------------------
--*****************************Counting down**************************************------------------------
--*****************************Counting down**************************************------------------------
--*****************************Counting down**************************************------------------------
						else	
							if  v_count_0 = 0 then							--yes set subcounter to its reset value and set the overrun indicator			
								v_count_0 := s_count_base;
								v_cnt_overrun := '1';				
							else													--no increment counter and set overrun indicator to 0		 								
								v_count_0 := v_count_0 - 1;	
								v_cnt_overrun := '0';	
							end if;
							--COUNTER 1 (is triggered by the overrun of the previous counter)
							--sub counter 1 overrun ?
							if v_cnt_overrun = '1' then					--yes set subcounter to its reset value and set the overrun indicator
								if v_count_1 = 0 then			
									v_count_1 := s_count_base;
									v_cnt_overrun := '1';				
								else												--no increment counter and set overrun indicator to 0		 								
									v_count_1 := v_count_1 - 1;	
									v_cnt_overrun := '0';
								end if;	
							end if;
							--COUNTER 2 (is triggered by the overrun of the previous counter)
							--sub counter 2 overrun ?
							if v_cnt_overrun = '1' then					--yes set subcounter to its reset value and set the overrun indicator 
								if  v_count_2 = 0 then			
									v_count_2 := s_count_base;
									v_cnt_overrun := '1';				
								else												--no increment counter and set overrun indicator to 0		 								
									v_count_2 := v_count_2 - 1;	
									v_cnt_overrun := '0';	
								end if;
							end if;
							--COUNTER 3 (is triggered by the overrun of the previous counter)
							--sub counter 3 overrun ?
							if v_cnt_overrun = '1' then					--yes set subcounter to its reset value and set the overrun indicator
								if  v_count_3 = 0 then			
									v_count_3 := s_count_base;
									v_cnt_overrun := '1';				
								else												--no increment counter and set overrun indicator to 0		 								
									v_count_3 := v_count_3 - 1;	
									v_cnt_overrun := '0';
								end if;	
							end if;
						end if;
					
					end if;		
					
			end if;
			
			cntr_0_o <= v_count_0;
			cntr_1_o <= v_count_1;
			cntr_2_o <= v_count_2;
			cntr_3_o <= v_count_3;
		end process;
end rtl;
