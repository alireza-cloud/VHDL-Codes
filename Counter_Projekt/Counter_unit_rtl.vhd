library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

architecture rtl of cntr is
				
	signal		s_count_base						:	std_logic_vector(3 downto 0):= x"9";
	signal		s_cnt_mode							:	std_logic;       

	begin
	
		p_decode_input : process(clk_i, reset_i)	
		
		begin
			if reset_i = '1' then
				s_cnt_mode <= '0';
			else
				if (clk_i'event and clk_i = '1') then
					
					if cntrup_i = '0' and cntrdown_i = '1' then
						s_cnt_mode <= '1';
					elsif cntrup_i ='1' and cntrdown_i = '0' then
						s_cnt_mode <= '0';
					end if;		
				end if;
			end if;	
		end process;

		p_counter : process(clk_i, reset_i, s_cnt_mode)
		
		variable cy_o			:	std_logic;							
		variable v_count_0		:	std_logic_vector(3 downto 0);	
		variable v_count_1		:	std_logic_vector(3 downto 0);	
		variable v_count_2		:	std_logic_vector(3 downto 0);	
		variable v_count_3		:	std_logic_vector(3 downto 0);	

		begin
			if reset_i = '1' then											
			
					cy_o := '0';
					v_count_0 := x"0";
					v_count_1 := x"0";
					v_count_2 := x"0";
					v_count_3 := x"0";	
				
			elsif (clk_i'event and clk_i = '1' and cntrhold_i = '0') then
			
					--*****************************Counting up*************************************------------------------
					--*****************************Counting up************************************------------------------
					--*****************************Counting up*************************************------------------------
					--*****************************Counting up*************************************------------------------
						if s_cnt_mode = '0' then

							--COUNTER 0
							if  v_count_0 >= s_count_base then			
								v_count_0 := x"0";
								cy_o := '1';				
							else 												
								v_count_0 := v_count_0 + 1;	
								cy_o := '0';	

							end if;	
							--COUNTER 1
							if cy_o = '1' then
								if  v_count_1 >= s_count_base then					
									v_count_1 := x"0";						
									cy_o := '1';				
								else													 								
									v_count_1 := v_count_1 + 1;	
									cy_o := '0';				
								end if;	
							end if;
							--COUNTER 2
							if cy_o = '1' then 
								if  v_count_2 >= s_count_base then					
									v_count_2 := x"0";						
									cy_o := '1';				
								else														 								
									v_count_2 := v_count_2 + 1;	
									cy_o := '0';					
								end if;
							end if;
							--COUNTER 3
							if cy_o = '1' then
								if  v_count_3 >= s_count_base then					
									v_count_3 := x"0";						
									cy_o := '1';				
								else														 								
									v_count_3 := v_count_3 + 1;	
									cy_o := '0';	
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
								cy_o := '1';				
							else															 								
								v_count_0 := v_count_0 - 1;	
								cy_o := '0';	
							end if;
							--COUNTER 1 
							if cy_o = '1' then					
								if v_count_1 = 0 then			
									v_count_1 := s_count_base;
									cy_o := '1';				
								else												 								
									v_count_1 := v_count_1 - 1;	
									cy_o := '0';
								end if;	
							end if;
							--COUNTER 2
							if cy_o = '1' then					 
								if  v_count_2 = 0 then			
									v_count_2 := s_count_base;
									cy_o := '1';				
								else														 								
									v_count_2 := v_count_2 - 1;	
									cy_o := '0';	
								end if;
							end if;
							--COUNTER 3 
							if cy_o = '1' then
								if  v_count_3 = 0 then			
									v_count_3 := s_count_base;
									cy_o := '1';				
								else														 								
									v_count_3 := v_count_3 - 1;	
									cy_o := '0';
								end if;	
							end if;
						--end if;
					
					end if;		
			end if;
			
			cntr_0_o <= v_count_0;
			cntr_1_o <= v_count_1;
			cntr_2_o <= v_count_2;
			cntr_3_o <= v_count_3;
		end process;
end rtl;
