-------------------------------------------------------------------------------
-- Design: VHDL Counter Project : top-level design   			             --
--                                                                           --
-- Author : It's me                                                --
-- Date   : 08 01 2021                                                       --
-- File   : cntr_top_struc.vhd                                               --
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity cntr_top is
     
  port (		--inputs
			clk_i   : in std_logic;
			reset_i : in  std_logic;
						
			sw_i	  : in std_logic_vector(15 downto 0);	 --16 switches (from FPGA board)
			pb_i     : in std_logic_vector(3 downto 0);	 --4 buttons (from FPGA board)
					
			--outputs	
      		ss_o     : out std_logic_vector(7 downto 0);	 -- to 7-segment displays of the FPGA board 
			ss_sel_o : out std_logic_vector(3 downto 0) 	 -- Selection of a 7-segment digit
			
        );
end cntr_top;



architecture struc of cntr_top is
	
	component cntr
	port ( --inputs
			
			clk_i   : in std_logic;						--System clock(100MHZ)
			reset_i : in  std_logic;					--Asynchronous high active reset
			
			cntrup_i   : in std_logic;					--Counts up if signal is '1'
			cntrdown_i : in  std_logic;					--Conts down if signal is '1'
			
			cntrreset_i   : in std_logic;				--Sets counter to 0x0 if signal is '1'
			cntrhold_i : in  std_logic;					--Holds count value if signal is '1'
						
			--outputs
			
			
			cntr_0_o  : out std_logic_vector(3 downto 0);		--später (n:0)
			cntr_1_o  : out std_logic_vector(3 downto 0);
			cntr_2_o  : out std_logic_vector(3 downto 0);
			cntr_3_o  : out std_logic_vector(3 downto 0)
	
	);
	end component;
	
	component io_ctrl
	port (	    
	        --inputs
			clk_i   : in std_logic;
			reset_i : in  std_logic;
			
			cntr0_i  : in std_logic_vector(3 downto 0);
			cntr1_i  : in std_logic_vector(3 downto 0);
			cntr2_i  : in std_logic_vector(3 downto 0);
			cntr3_i  : in std_logic_vector(3 downto 0);
			
			sw_i	  : in std_logic_vector(15 downto 0);	 --16 switches (from FPGA board)
			pb_i     : in std_logic_vector(3 downto 0);	 --4 buttons (from FPGA board)
			
			
			--outputs
			
      		ss_o     : out std_logic_vector(7 downto 0);	 -- to 7-segment displays of the FPGA board 
			ss_sel_o : out std_logic_vector(3 downto 0); 	 -- Selection of a 7-segment digit
			swclean_o : out std_logic_vector(15 downto 0); -- 16 switches to (internal logic)
			pbclean_o  : out std_logic_vector(3 downto 0) -- 4 buttons (to internal logic)

	);
	end component;
	
-------------------------------------	
		signal s_cntr0 : std_logic_vector(3 downto 0);
		signal s_cntr1 : std_logic_vector(3 downto 0);
		signal s_cntr2 : std_logic_vector(3 downto 0);
		signal s_cntr3 : std_logic_vector(3 downto 0);
		
		signal s_pbsync : std_logic_vector(3 downto 0);
		signal s_swsync : std_logic_vector(15 downto 0);
		signal s_count_updown : std_logic;
		
	
------------------------------------

begin -- struc
	
	--s_count_updown <= Not s_swsync(1);	


	i_cntr : cntr
	port map
	( 		clk_i  	=> clk_i,				
			reset_i => reset_i,				
			
			cntrup_i  	=>  s_swsync(2),			
			cntrdown_i 	=>	s_swsync(1),		
			
			cntrreset_i => s_pbsync(0),				
			cntrhold_i 	=>	s_swsync(0),			
						
			--outputs
			
			
			cntr_0_o  => s_cntr0,
			cntr_1_o  => s_cntr1,
			cntr_2_o  => s_cntr2,
			cntr_3_o  => s_cntr3

	);
	
	i_io_ctrl : io_ctrl
	port map
	(
			clk_i    => clk_i,
			reset_i  => reset_i,
			
			cntr0_i  => s_cntr0,
			cntr1_i  => s_cntr1,
			cntr2_i  => s_cntr2,
			cntr3_i  => s_cntr3,
			
			sw_i	  => sw_i,
			pb_i   	  => pb_i,
					
			--outputs
			
			ss_o   		=> ss_o,
			ss_sel_o 	=> ss_sel_o,
			swclean_o 	=> s_swsync,
			pbclean_o 	=> s_pbsync
	
	);

	


end architecture struc;









