-------------------------------------------------------------------------------
-- Design: VHDL Counter Project : I/0 control design   			             --
--                                                                           --
-- Author : Ali Reza NOORI                                                   --
-- Date   : 08 01 2021                                                       --
-- File   : io_cntrl_rtl.vhd                                                 --
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

--************************************Entity I/0 Control***************************************************--
--************************************Entity I/0 Control***************************************************--
--************************************Entity I/0 Control***************************************************--

entity io_ctrl is
     
  port (		--inputs
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
end io_ctrl;

--************************************RTL I/0 Control***************************************************--
--************************************RTL I/0 Control***************************************************--
--************************************RTL I/0 Control***************************************************--

architecture rtl of io_ctrl is
	
--************************************Decoder Component declaration*************************************--

	component decoder
	port(		
		--inputs
		cntr_i : in std_logic_vector(3 downto 0); -- 4 Bit Eingang vom Counter
		clk_i   : in std_logic;	
		reset_i : in std_logic;
			
		--outputs
      	cntr_o : out std_logic_vector(7 downto 0)  -- 8 Bit decodiertes Ausgangsignal für 7-Segment
			
        );
	end component;
	
--************************************Constants and Signals declaration***********************************--

	constant Khz_1_MAX_CNTV : std_logic_vector(16 downto 0):= "11000011010100000"; --1khz--> 100000 (deciaml)Takte
															  
	signal s_en_1Khz : std_logic :='0';
	signal s_cnt_1Khz : std_logic_vector(16 downto 0) := (others =>'0');
	


--  Signale für input buffering	
	signal s_sw_i : std_logic_vector(15 downto 0);
	signal s_pb_i : std_logic_vector(3 downto 0);
	
	signal s_sw_delay1, s_sw_delay2, s_sw_delay3 : std_logic_vector(15 downto 0);
	signal s_pb_delay1, s_pb_delay2, s_pb_delay3 : std_logic_vector(3 downto 0);


--  Ausgangssignale von den 4 instanzierten decodern	
	signal cntr_einer_o : std_logic_vector(7 downto 0);
	signal cntr_zehner_o : std_logic_vector(7 downto 0);
	signal cntr_hundert_o : std_logic_vector(7 downto 0);
	signal cntr_tausend_o : std_logic_vector(7 downto 0);
	
	signal multiplex_count : std_logic_vector (1 downto 0) := (others => '0');
	signal s_ss_sel_o : std_logic_vector(3 downto 0) := (others =>'0');
	signal s_7seg : std_logic_vector(7 downto 0) := (others => '0');
	

--************************************Architecture begin***************************************************--

begin 


--************************************Prescaler Process for Mutliplexing***********************************--

-- Es wird in jeder ms ein Impuls von einem Takt ausgegeben
 p_prescaler: process (clk_i, reset_i) -- verlangsamen
 	begin -- process p_prescaler
 	if reset_i = '1' then
 
		s_en_1Khz <= '0';
		s_cnt_1Khz <= (others => '0');

 	elsif (clk_i'event and clk_i = '1') then -- rising clock edge
		-- jetzt hinauf zähle
		-- 1Khz --> 1ms --> 100 000 Takte für 1 Khz
	
		if (s_cnt_1Khz = Khz_1_MAX_CNTV ) then
			s_en_1Khz <= '1';
			s_cnt_1Khz <= (others => '0');
		else
			s_en_1Khz <= '0';
			s_cnt_1Khz <= s_cnt_1Khz + '1';

 		end if;
	end if;
 end process p_prescaler;



--************************************Input Buffering Process ***********************************************--

-- Jedes Eingangssignal von sw_i ( 16 Schalter) und pb_ (4 buttons ) wird auf ein Eingangssignal gepuffert
 p_input_buffering : process (sw_i, pb_i, reset_i, clk_i)
 
	begin
	if (reset_i ='1') then
		s_sw_i <= (others => '0');
		s_pb_i <=  (others => '0');
	
	elsif(clk_i'event and clk_i ='1') then
		s_sw_i <= sw_i;
		s_pb_i <= pb_i;
	end if;
	
end process p_input_buffering;



--************************************Switches/ Buttons debouncing Process ***********************************************--


-- Eingänge der Schalter und Buttons entprellen
-- gepufferte Eingangssignale werden über 3 Flipflop-Stufen mit 1khz Takt geschickt.
-- und am Schluß verundet.

 p_input_debounce : process (sw_i, pb_i, reset_i, s_en_1Khz)
 --sw_i	  	: in std_logic_vector(15 downto 0);	 --16 switches (from FPGA board)
 --pb_i     : in std_logic_vector(3 downto 0);	 --4 buttons (from FPGA board)
 
	begin
	if (reset_i ='1') then
		s_sw_delay1 <= (others => '0');
		s_sw_delay2 <= (others => '0');
		s_sw_delay3 <= (others => '0');
		
		s_pb_delay1 <= (others => '0');
		s_pb_delay2 <= (others => '0');
		s_pb_delay3 <= (others => '0');
	
	
	elsif(s_en_1Khz'event and s_en_1Khz ='1') then
		s_sw_delay1 <= s_sw_i;
		s_sw_delay2 <= s_sw_delay1;
		s_sw_delay3 <= s_sw_delay2;
		
		s_pb_delay1 <= pb_i;
		s_pb_delay2 <= s_pb_delay1;
		s_pb_delay3 <= s_pb_delay2;
		
		
	end if;
	
	
end process p_input_debounce;

	swclean_o <= s_sw_delay1 and s_sw_delay2 and s_sw_delay3;
	pbclean_o <= s_pb_delay1 and s_pb_delay2 and s_pb_delay3;
	

--************************************Decoder Instantiation***************************************************--
	decoder_einer : decoder
	port map( 
		
		cntr_i => cntr0_i,
		clk_i  => clk_i,
		reset_i => reset_i,
      	cntr_o =>  cntr_einer_o
		
	);
	
	decoder_zehner : decoder
	port map( 
		
		cntr_i => cntr1_i,
		clk_i  => clk_i,
		reset_i => reset_i,
      	cntr_o =>  cntr_zehner_o
		
	);
	
	decoder_hundert: decoder
	port map( 
		
		cntr_i => cntr2_i,
		clk_i  => clk_i,
		reset_i => reset_i,
      	cntr_o =>  cntr_hundert_o
		
	);
	
	decoder_tausend: decoder
	port map( 
		
		cntr_i => cntr3_i,
		clk_i  => clk_i,
		reset_i => reset_i,
      	cntr_o =>  cntr_tausend_o
		
	);

--Multiplexer
--schaltet jede Milisekunde auf das nächste Digit( einer,zehner,hundert,tausendér Stelle) und gibt vom dazugehörigen counter den Wertz aus
p_multiplex : process(s_en_1Khz, reset_i, multiplex_count, cntr_einer_o, cntr_zehner_o, cntr_hundert_o,cntr_tausend_o)
begin
	if( reset_i ='1') then
		multiplex_count<= "00";
		
		
	elsif (s_en_1Khz'event and s_en_1Khz = '1')then
		if(multiplex_count="11") then
			multiplex_count <= "00";
		else
			multiplex_count <= multiplex_count + '1';
		end if;
	end if;
	
	case multiplex_count is       		              	   		
						when "00"  => 
							s_7seg <= cntr_einer_o;	
							s_ss_sel_o <= "1110";		--erstes 7-Segment ausgewählt (einer)
						when "01"  => 
							s_7seg<= cntr_zehner_o;
							s_ss_sel_o <= "1101";		--zweites 7-Segment ausgewählt (zehner)
						
						when "10"  => 
							s_7seg <= cntr_hundert_o;
							s_ss_sel_o <= "1011";		--drittes 7-Segment ausgewählt (hundert)
						when "11"  => 
							s_7seg <= cntr_tausend_o;
							s_ss_sel_o <= "0111";		--viertes 7-Segment ausgewählt (tausend)
						when others => 
							s_7seg <="11111111";
							s_ss_sel_o <= "1111";							
	end case;
	
end process p_multiplex;
	
ss_o <= s_7seg;
ss_sel_o <=s_ss_sel_o;



end architecture rtl;









