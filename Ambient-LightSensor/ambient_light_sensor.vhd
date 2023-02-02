-------------------------------------------------------------------------------
-- --
-- --
-- Author : It' me --
-- Date : 08 01 2021 --
-- File : Ambient_Light_Sensor.vhd --
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY ambient_light_sensor IS
	GENERIC (
	ClockDivider : INTEGER := 13); -- 3.846 MHz = 100MHz / 2*13
	PORT (
		sys_clock : IN std_logic; -- 100 MHz system clock
		reset_asyn : IN std_logic; --Asynchronous Reset with active low function
		enable : IN std_logic; -- the enable switch = 1 allows the transaction, enable = 0 holds the last value
		miso : IN std_logic; --Master in Slave out pin
		sclk : BUFFER std_logic; --Serial Clock for the ALS PMOD Sensor
		cs : BUFFER std_logic; --Chip select pin of the ALS PMOD
	leds : OUT std_logic_vector(7 DOWNTO 0)); -- output leds
 
END ambient_light_sensor;

ARCHITECTURE behavior OF ambient_light_sensor IS
	SIGNAL spi_rx_data : std_logic_vector(15 DOWNTO 0); -- data received by the SPI_Master
	SIGNAL s_pwm_cnt : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0'); -- Signal to generate PWM
	SIGNAL s_pwm_cnt_toggle : std_logic := '0'; -- Signal to toggle the Counter for the Serial Clock
	SIGNAL enable_leds : std_logic; -- Enable Output LEDs
	-- Component Declaration
	COMPONENT spi_master IS
		GENERIC (
			data_width : INTEGER := 16
		);
		PORT (
			sys_clock : IN std_logic; 
			reset_asyn : IN std_logic; 
			enable : IN std_logic; 
			clockPolarity : IN std_logic; 
			clockPhase : IN std_logic; 
			ClockDivider : IN INTEGER; 
			miso : IN std_logic; 
			sclk : BUFFER std_logic; 
			cs : BUFFER std_logic; 
			rx_data : OUT std_logic_vector(data_width - 1 DOWNTO 0)
		);
	END COMPONENT spi_master;

BEGIN
	--instantiate the component
	spi_master_0 : spi_master
		GENERIC MAP(data_width => 16)
	PORT MAP(
		sys_clock => sys_clock, 
		reset_asyn => reset_asyn, 
		enable => enable, 
		clockPolarity => '1', 
		clockPhase => '1', 
		ClockDivider => ClockDivider, 
		miso => miso, 
		sclk => sclk, 
		cs => cs, 
		rx_data => spi_rx_data
	);
 
 
		onehz : PROCESS (sys_clock, reset_asyn) --1 hz
		BEGIN
			IF (reset_asyn = '1') THEN
				s_pwm_cnt <= (OTHERS => '0');
 
			ELSIF (sys_clock'EVENT AND sys_clock = '1') THEN
				s_pwm_cnt <= s_pwm_cnt + '1'; 
			END IF;
		END PROCESS onehz;

		enable_leds <= '1' WHEN (s_pwm_cnt >= (spi_rx_data(12 DOWNTO 5))) ELSE '0'; -- generating pwm
 
		leds(0) <= NOT enable_leds; --assign ambient light data bits to output
		leds(1) <= NOT enable_leds;
		leds(2) <= NOT enable_leds;
		leds(3) <= NOT enable_leds;
		leds(4) <= NOT enable_leds;
		leds(5) <= NOT enable_leds;
		leds(6) <= NOT enable_leds;
		leds(7) <= NOT enable_leds;
 
		END behavior;
