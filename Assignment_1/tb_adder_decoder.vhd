-------------------------------------------------------------------------------
-- Design: Assignment_1 : adder_decoder design testbench			         --
--                                                                           --
-- Author : It's me                                				 --
-- Date   : 27 11 2020                                                       --
-- File   : tb_adder_decoder.vhd                                             --
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_adder_decoder is end tb_adder_decoder;

architecture sim of tb_adder_decoder is

  component adder_decoder
    
    port (	data0_i :  in std_logic_vector(7 downto 0);
			data1_i :  in std_logic_vector(7 downto 0);
			lvl0_o 	: out std_logic ;
			lvl1_o 	: out std_logic ;
			lvl2_o 	: out std_logic ;
			lvl3_o 	: out std_logic ;
			lvl4_o 	: out std_logic ;
			lvl5_o 	: out std_logic ;
			lvl6_o 	: out std_logic ;
			lvl7_o 	: out std_logic );
  end component;


		-- signals for input usage
			signal data0_i :   std_logic_vector(7 downto 0);
			signal data1_i :   std_logic_vector(7 downto 0);
  
		-- signals for output usage
			signal lvl0_o :  std_logic;
			signal lvl1_o :  std_logic;
			signal lvl2_o :  std_logic;
			signal lvl3_o :  std_logic;
			signal lvl4_o :  std_logic;
			signal lvl5_o :  std_logic;
			signal lvl6_o :  std_logic;
			signal lvl7_o :  std_logic;
 
  
begin

  -- Instantiate the adder_decoder design for testing
  i_decoder_fsm : adder_decoder
    
    port map
    (	data0_i => data0_i,
		data1_i => data1_i,
		lvl0_o 	=> lvl0_o,
		lvl1_o 	=> lvl1_o,
		lvl2_o 	=> lvl2_o,
		lvl3_o 	=> lvl3_o,
		lvl4_o 	=> lvl4_o,
		lvl5_o 	=> lvl5_o,	
		lvl6_o 	=> lvl6_o,
		lvl7_o 	=> lvl7_o)
    ;



  p_test : process
  begin
    -- idle
    data0_i  <= x"00";	-- decimal 0
    data1_i  <= x"00";	-- decimal 0
    wait for 500 ns;
	-- overflow
    data0_i  <= x"FF";	-- decimal 255
    data1_i  <= x"FF";	-- decimal 255
    wait for 500 ns;
    -- case 1
    data0_i  <= x"00";	-- decimal 0
    data1_i  <= x"05";	-- decimal 5
    wait for 500 ns;
	-- case 2
    data0_i  <= x"11";	-- decimal 17
    data1_i  <= x"03";	-- decimal 0
    wait for 500 ns;
    -- case 3
    data0_i  <= x"1C";	-- decimal 28
    data1_i  <= x"04";	-- decimal 4
    wait for 500 ns;
	-- case 4
    data0_i  <= x"44";	-- decimal 68
    data1_i  <= x"05";	-- decimal 5
    wait for 500 ns;
    -- case 5
    data0_i  <= x"66";	-- decimal 102
    data1_i  <= x"07";	-- decimal 7
    wait for 500 ns;
	-- case 6
    data0_i  <= x"80";	-- decimal 128
    data1_i  <= x"06";	-- decimal 6
    wait for 500 ns;
    -- case 7
    data0_i  <= x"93";	-- decimal 147
    data1_i  <= x"07";	-- decimal 7
    wait for 500 ns;


    
 
    wait;
  end process p_test;

end sim;

