-------------------------------------------------------------------------------
-- Design: Assignment_1 : adder_decoder design entity and architecture                     --
--                                                                           --
-- Author : Ali Reza Noori *done in a group of three*                        --
-- Date   : 27 11 2020                                                       --
-- File   : adder_decoder_rtl.vhd                                                     --
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity adder_decoder is
     
  port (		--inputs
			data0_i : in  std_logic_vector(7 downto 0);
			data1_i : in  std_logic_vector(7 downto 0);
			
			--outputs
      		lvl0_o : out std_logic :='0';
			lvl1_o : out std_logic :='0';
			lvl2_o : out std_logic :='0';
			lvl3_o : out std_logic :='0';
			lvl4_o : out std_logic :='0';
			lvl5_o : out std_logic :='0';
			lvl6_o : out std_logic :='0';
			lvl7_o : out std_logic :='0'
			
        );
end adder_decoder;

architecture rtl of adder_decoder is

signal s_sum : std_logic_vector(8 downto 0);
signal s_temp_level : std_logic_vector(7 downto 0);


begin
-----------------------------process to do addtion. process is copied from VHDL Class Example 4 adder.vhd-----------------------------
		p_add : process(data0_i, data1_i)
				variable v_a : unsigned(8 downto 0);
    			variable v_tempsum : unsigned(8 downto 0);

				begin
    			v_a(8) := '0';
    			v_a(7 downto 0) := unsigned(data0_i);
				v_tempsum := v_a + unsigned(data1_i);
    			s_sum <= std_logic_vector(v_tempsum(8 downto 0));
    			
				end process p_add;

-----------------------------process to do decoding----------------------------------------------------------------------------	
	p_decode : process(s_sum)
	begin
				
	if ((s_sum(8)='1')) then		-- comparing an overflow
		s_temp_level  <= "10000000";

	--elsif ( (s_sum = "000000000")) then
		--s_temp_level <= "00000000";

	elsif ( (s_sum >= "000000000") and (s_sum <= "000010000")) then		-- as defined in the questions, if s_sum is between x00-x10 then lvl0_o -> 1 and so on
		s_temp_level <= "00000001";
	
	elsif ( (s_sum >= "000010001") and (s_sum <= "000011011")) then
		s_temp_level <= "00000010";

	elsif ( (s_sum >= "000011100") and (s_sum <= "001000011")) then
		s_temp_level <= "00000100";
	
	elsif ( (s_sum >= "001000100") and (s_sum <= "001100101")) then
		s_temp_level <= "00001000";

	elsif ( (s_sum >= "001100110") and (s_sum <= "001111111")) then
		s_temp_level <= "00010000";

	elsif ( (s_sum >= "010000000") and (s_sum <= "010010010")) then
		s_temp_level <= "00100000";

	elsif ( (s_sum >= "010010011") and (s_sum <= "011111111")) then
		s_temp_level <= "01000000";
	end if;

	end process p_decode;
-----------------------------process to assign outputs the value of signals--------------------------------------------------------
	p_output :process(s_temp_level,data0_i, data1_i)
	begin

	lvl0_o <= s_temp_level(0);
	lvl1_o <= s_temp_level(1);
	lvl2_o <= s_temp_level(2);
	lvl3_o <= s_temp_level(3);
	lvl4_o <= s_temp_level(4);
	lvl5_o <= s_temp_level(5);
	lvl6_o <= s_temp_level(6);
	lvl7_o <= s_temp_level(7);

	end process p_output;


end rtl;
-- comment
-- 2nd comment
