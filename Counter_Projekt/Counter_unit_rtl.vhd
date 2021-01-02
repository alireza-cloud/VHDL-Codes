library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

architecture rtl of cntr is
				
	signal		s_count_base						:	std_logic_vector(3 downto 0):= x"9";
	signal		s_count_prescale					:	std_logic_vector(27 downto 0);
	signal		s_cnt_mode							:	std_logic;
	signal		s_count_pulse_source				:	std_logic;        

	begin
	
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
				end if;
			end if;	
		end process;

		p_counter : process(clk_i, reset_i)
		
		variable v_cnt_overrun	:	std_logic;							
		variable v_count_0		:	std_logic_vector(3 downto 0);	
		variable v_count_1		:	std_logic_vector(3 downto 0);	
		variable v_count_2		:	std_logic_vector(3 downto 0);	
		variable v_count_3		:	std_logic_vector(3 downto 0);	

		begin
			if reset_i = '1' then											
				
				if s_cnt_mode = '1' then									
					v_cnt_overrun := '0';
					v_count_0 := s_count_base;
					v_count_1 := s_count_base;
					v_count_2 := s_count_base;
					v_count_3 := s_count_base;
				else
					v_cnt_overrun := '0';
					v_count_0 := x"0";
					v_count_1 := x"0";
					v_count_2 := x"0";
					v_count_3 := x"0";	
				end if;
			elsif clk_i'event and clk_i = '1'  then		
					if cntrhold_i = '0' then
						if s_cnt_mode = '0' then

							--COUNTER 0
							if  v_count_0 >= s_count_base then			
								v_count_0 := x"0";
								v_cnt_overrun := '1';				
							else 												
								v_count_0 := v_count_0 + 1;	
								v_cnt_overrun := '0';	

							end if;	
							--COUNTER 1
							if v_cnt_overrun = '1' then
								if  v_count_1 >= s_count_base then					
									v_count_1 := x"0";						
									v_cnt_overrun := '1';				
								else													 								
									v_count_1 := v_count_1 + 1;	
									v_cnt_overrun := '0';				
								end if;	
							end if;
							--COUNTER 2
							if v_cnt_overrun = '1' then 
								if  v_count_2 >= s_count_base then					
									v_count_2 := x"0";						
									v_cnt_overrun := '1';				
								else														 								
									v_count_2 := v_count_2 + 1;	
									v_cnt_overrun := '0';					
								end if;
							end if;
							--COUNTER 3
							if v_cnt_overrun = '1' then
								if  v_count_3 >= s_count_base then					
									v_count_3 := x"0";						
									v_cnt_overrun := '1';				
								else														 								
									v_count_3 := v_count_3 + 1;	
									v_cnt_overrun := '0';	
									end if;	
							end if;
--*****************************Counting down**************************************------------------------
--*****************************Counting down**************************************------------------------
--*****************************Counting down**************************************------------------------
--*****************************Counting down**************************************------------------------
						else	
							--COUNTER 0
							if  v_count_0 = 0 then									
								v_count_0 := s_count_base;
								v_cnt_overrun := '1';				
							else															 								
								v_count_0 := v_count_0 - 1;	
								v_cnt_overrun := '0';	
							end if;
							--COUNTER 1 
							if v_cnt_overrun = '1' then					
								if v_count_1 = 0 then			
									v_count_1 := s_count_base;
									v_cnt_overrun := '1';				
								else												 								
									v_count_1 := v_count_1 - 1;	
									v_cnt_overrun := '0';
								end if;	
							end if;
							--COUNTER 2
							if v_cnt_overrun = '1' then					 
								if  v_count_2 = 0 then			
									v_count_2 := s_count_base;
									v_cnt_overrun := '1';				
								else														 								
									v_count_2 := v_count_2 - 1;	
									v_cnt_overrun := '0';	
								end if;
							end if;
							--COUNTER 3 
							if v_cnt_overrun = '1' then
								if  v_count_3 = 0 then			
									v_count_3 := s_count_base;
									v_cnt_overrun := '1';				
								else														 								
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
