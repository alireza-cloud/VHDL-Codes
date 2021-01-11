-------------------------------------------------------------------------------
-- Design: Assignment_2 : elevator design Module	       					 --
--                                                                           --
-- Author : Ali Reza Noori                                    				 --
-- Date   : 11 12 2020                                                       --
-- File   : Elevator_rtl.vhd                                            	 --
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--****************************************************************************************----------------
------------------------------Entity----------------------------------------------------------------------
--****************************************************************************************----------------
entity elevator is
     
  port (		--inputs
			gf_cab_i : in std_logic;
			f1_cab_i : in  std_logic;
			
			gf_call_i : in std_logic;
			f1_call_i : in  std_logic;
			
			gf_end_i : in std_logic;
			f1_end_i : in  std_logic;
			
			clk_i : in std_logic;
			reset_i : in  std_logic;
			
			--outputs
      		engine_o : out std_logic_vector(1 downto 0) 
			
			
        );
end elevator;
--****************************************************************************************----------------
--------------------------Module architecture-------------------------------------------------------------
--****************************************************************************************----------------
architecture rtl of elevator is

type t_state is (GF,F1,DOWN,UP);
signal s_present_state : t_state;
signal s_next_state : t_state;

begin
--****************************************************************************************----------------
--------------------------sequential Process-------------------------------------------------------------
--****************************************************************************************----------------
p_fsm_seq : process (clk_i, reset_i)
begin
	if (reset_i = '1') then
		s_present_state <= GF;
	elsif ( clk_i' event and clk_i='1') then 
		s_present_state <= s_next_state;
	end if;
		
end process p_fsm_seq;

--****************************************************************************************----------------
--------------------------combinational Process-------------------------------------------------------------
--****************************************************************************************-----------------
p_fsm_comb: process ( s_present_state, f1_call_i, f1_cab_i, f1_end_i, gf_call_i, gf_cab_i, gf_end_i )
begin
	case s_present_state is
		when GF =>
			 if( f1_call_i ='1' or f1_cab_i ='1' ) then 
				 engine_o <= "01";
				 s_next_state <= UP;
			 else 
				 s_next_state <= GF;
				 engine_o <= "00";
			 end if;
		when UP =>
			 if ( f1_end_i = '1')  then 
				  engine_o <= "00";
				  s_next_state <= F1;
		     else 
				 s_next_state <= UP;
				 engine_o <= "01";
			 end if;
			 
		when F1 =>
			 if ( gf_call_i = '1' or gf_cab_i ='1')  then
				  engine_o <= "10";
				  s_next_state <= DOWN;
			 else 
				 s_next_state <= F1;
				 engine_o <= "00";
			 end if;
		
		when DOWN =>
			 if ( gf_end_i = '1')  then
				  engine_o <= "00";
				  s_next_state <= GF;
			 else 
				 s_next_state <= DOWN;
				 engine_o <= "10";
			 end if;
		
		when others => 
			s_next_state <= GF;
			-- engine_o <= "11";
	end case;
end process p_fsm_comb;		


end rtl;
