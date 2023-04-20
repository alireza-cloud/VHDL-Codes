-------------------------------------------------------------------------------
-- 											    							 --
--                                                                           --
-- Author : Ali Reza NOORI                                                   --
-- Date   : 08 01 2021                                                       --
-- File   : Ambient_Light_Sensor.vhd                                    	 --
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity ambient_light_sensor is
    generic(
        ClockDivider 		:   integer := 13);  -- 3.846 MHz = 100MHz / 2*13 
    port(
        sys_clock         	:   in      std_logic;   					-- 100 MHz system clock
        reset_asyn     		:   in      std_logic;  					--Asynchronous Reset with active low function
		enable		:   in      std_logic;						-- the enable switch = 1 allows the transaction, enable = 0 holds the last value
        miso        		:   in      std_logic;   					--Master in Slave out pin
        sclk        		:   buffer  std_logic;     					--Serial Clock for the ALS PMOD Sensor
        cs        		:   buffer  std_logic;     					--Chip select pin of the ALS PMOD
        leds    		:   out     std_logic_vector(7 downto 0));  -- output leds 
		
end ambient_light_sensor;

architecture behavior of ambient_light_sensor is
    signal spi_rx_data			: std_logic_vector(15 downto 0);   					 -- data received by the SPI_Master
	signal s_pwm_cnt		: std_logic_vector(7 downto 0) := (others => '0');		 -- Signal to generate PWM
	signal s_pwm_cnt_toggle		: std_logic := '0';									 -- Signal to toggle the Counter for the Serial Clock 
	signal enable_leds		: std_logic;											 -- Enable Output LEDs 


    -- Component Declaration
    component spi_master is
        generic(
            data_width : integer := 16);
        port(
            sys_clock   		: in     std_logic;                             
            reset_asyn 			: in     std_logic;                             
            enable  			: in     std_logic;                             
            clockPolarity    		: in     std_logic;                             
            clockPhase    		: in     std_logic;                             
            ClockDivider 		: in     integer;                               
            miso    			: in     std_logic;                             
            sclk    			: buffer std_logic;                             
            cs    			: buffer std_logic;   
            rx_data 			: out    std_logic_vector(data_width-1 downto 0)); 
    end component spi_master;

begin

  --instantiate the component
  spi_master_0:  spi_master
     generic map(data_width => 16)
     port map(sys_clock => sys_clock,
			  reset_asyn => reset_asyn, 
			  enable => enable, 
			  clockPolarity => '1',
			  clockPhase => '1', 
			  ClockDivider => ClockDivider, 
			  miso => miso, 
			  sclk => sclk, 
			  cs => cs,
			  rx_data => spi_rx_data);
		   
		   
	onehz:  process(sys_clock,reset_asyn) --1 hz
			 begin
				if(reset_asyn = '1')then
					s_pwm_cnt <= (others => '0'); 
			
				elsif(sys_clock'event and sys_clock = '1')then
					s_pwm_cnt <= s_pwm_cnt + '1';				
				end if;
			end process onehz;

	enable_leds <= '1' when (s_pwm_cnt >= (spi_rx_data(12 downto 5))) else '0'; -- generating pwm
	
	leds(0) <= not enable_leds;   --assign ambient light data bits to output
	leds(1) <= not enable_leds;
	leds(2) <= not enable_leds;
	leds(3) <= not enable_leds;
	leds(4) <= not enable_leds;
	leds(5) <= not enable_leds;
	leds(6) <= not enable_leds;
	leds(7) <= not enable_leds;
	
end behavior;
