-------------------------------------------------------------------------------
-- Design: Assignment_2 : Testbench für architecture Module elevator 	     --
--                                                                           --
-- Author : Ali Reza Noori                                    				 --
-- Date   : 11 12 2020                                                       --
-- File   : TB_Elevator.vhd                                            		 --
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_elevator is end tb_elevator;

architecture sim of tb_elevator is
  
-- *************************** component declaration ***********************************************************--  
  component elevator
    
		port (		--inputs
			gf_cab_i : in std_logic;
			f1_cab_i : in  std_logic;
			
			gf_call_i : in std_logic;
			f1_call_i : in  std_logic;
			
			gf_end_i : in std_logic;
			f1_end_i : in  std_logic;
			
			clk_i : in std_logic :='0';
			reset_i : in  std_logic := '0';
			
			--outputs
      		engine_o : out std_logic_vector(1 downto 0)); 		
        
    end component;
	
-- *************************** Signals declaration ***********************************************************-- 
	signal gf_cab_i : std_logic;
	signal f1_cab_i : std_logic;

	signal gf_call_i : std_logic;
	signal f1_call_i : std_logic;

	signal gf_end_i : std_logic;
	signal f1_end_i : std_logic;

	signal clk_i : std_logic;
	signal reset_i : std_logic;

	signal engine_o : std_logic_vector(1 downto 0);


	begin
	
	-- *************************** Instantiate the elevator design for DUT ***********************************************-- 
	i_elevator : elevator
    
		port map
		(
			gf_cab_i => gf_cab_i ,
			f1_cab_i => f1_cab_i ,

			gf_call_i => gf_call_i,
			f1_call_i  => f1_call_i,

			gf_end_i => gf_end_i,
			f1_end_i => f1_end_i,

			clk_i => clk_i,
			reset_i => reset_i,

			engine_o => engine_o 
		);	
		
    
	-- *************************** processing the clock for 10 MHZ ***********************************************************-- 

	p_clock_ten_MH: process
	begin
 	
	clk_i <='0';
 	wait for 50 ns;
 	clk_i <='1';
 	wait for 50 ns;

	end process p_clock_ten_MH;

    -- *************************** Start of the Testbench process ***********************************************************-- 
	
	p_testbench : process
	begin
    -- *************************** if the reset = 1 then idle GF ***********************************************************-- 
   reset_i  <= '1';
  
   gf_cab_i <='0';
   f1_cab_i <= '0';

   gf_call_i <= '0';
   f1_call_i <= '0';

   gf_end_i <= '1';
   f1_end_i <= '0';

    wait for 250 ns;
	-- *********************** 	release the reset button, reset = 0 ********************************************************--
   reset_i  <= '0';
 
   gf_cab_i <='0';
   f1_cab_i <= '0';

   gf_call_i <= '0';
   f1_call_i <= '0';

   gf_end_i <= '1';
   f1_end_i <= '0';

   wait for 250 ns;
-- ****************************** press the f1_cab_i = 1 in the cabine *****************************************************--
   reset_i  <= '0';
 
   gf_cab_i <='0';
   f1_cab_i <= '1';

   gf_call_i <= '0';
   f1_call_i <= '0';

   gf_end_i <= '1'; -- the elevator is still on the GF 
   f1_end_i <= '0';

   wait for 250 ns;
   -- ****************************** release the f1_cab_i = 0 in the cabine ************************************************--
   reset_i  <= '0';
 
   gf_cab_i <='0';
   f1_cab_i <= '0';

   gf_call_i <= '0';
   f1_call_i <= '0';

   gf_end_i <= '1'; -- the elevator is still on the GF 
   f1_end_i <= '0';
   
   wait for 250 ns;
   -- ****************************** elevator moving upwards ***************************************************************--
   reset_i  <= '0';
 
   gf_cab_i <='0';
   f1_cab_i <= '0';

   gf_call_i <= '0';
   f1_call_i <= '0';

   gf_end_i <= '0';
   f1_end_i <= '0';
   wait for 250 ns;
  
  -- ****************************** elevator reaches the F1, f1_end_i = 1 **************************************************--
   reset_i  <= '0';
 
   gf_cab_i <='0';
   f1_cab_i <= '0';

   gf_call_i <= '0';
   f1_call_i <= '0';

   gf_end_i <= '0';
   f1_end_i <= '1';
   wait for 250 ns;
   -- ****************************** press the button gf_cab_i = 1 in the cabine *******************************************--
   reset_i  <= '0';
 
   gf_cab_i <='1';
   f1_cab_i <= '0';

   gf_call_i <= '0';
   f1_call_i <= '0';

   gf_end_i <= '0';
   f1_end_i <= '1'; -- the elevator is still on the F1 
   
    wait for 250 ns;
   -- ****************************** release the button gf_cab_i = 0 in the cabine *****************************************--
   reset_i  <= '0';
 
   gf_cab_i <='0';
   f1_cab_i <= '0';

   gf_call_i <= '0';
   f1_call_i <= '0';

   gf_end_i <= '0';
   f1_end_i <= '1'; -- the elevator is still on the F1 
   wait for 250 ns;
      -- ****************************** elevator moving downwards **********************************************************--
   reset_i  <= '0';
 
   gf_cab_i <='0';
   f1_cab_i <= '0';

   gf_call_i <= '0';
   f1_call_i <= '0';

   gf_end_i <= '0';
   f1_end_i <= '0';
   
   wait for 250 ns;
      -- ****************************** elevator reaches the ground floor gf_end_i = 1 *************************************--
   reset_i  <= '0';
 
   gf_cab_i <='0';
   f1_cab_i <= '0';

   gf_call_i <= '0';
   f1_call_i <= '0';

   gf_end_i <= '1';
   f1_end_i <= '0';
 
   wait for 250 ns;
   

    wait;
  end process p_testbench;

end architecture sim;

