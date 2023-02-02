-------------------------------------------------------------------------------
-- SPI Master implementation on Basys 3 Board --
-- --
-- Author : It's me --
-- Date : 08 01 2021 --
-- File : SPI_Master.vhd --
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY spi_master IS
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
	rx_data : OUT std_logic_vector(data_width - 1 DOWNTO 0)); --data received
END spi_master;

ARCHITECTURE logic OF spi_master IS
	TYPE FSM IS(set, operate); --state FSM data type
	SIGNAL state : FSM; --current state
	SIGNAL clk_ratio : INTEGER; --current ClockDivider
	SIGNAL count : INTEGER; --counter
	SIGNAL clk_toggles : INTEGER RANGE 0 TO data_width * 2 + 1; 
	SIGNAL assert_data : std_logic; 
	SIGNAL rx_buffer : std_logic_vector(data_width - 1 DOWNTO 0); --receive data buffer
	SIGNAL last_bit_rx : INTEGER RANGE 0 TO data_width * 2; --last rx data bit adress
BEGIN
	PROCESS (sys_clock, reset_asyn)
	BEGIN
		IF (reset_asyn = '1') THEN --Asynchronous Reset
			cs <= '1'; --Pull Chip select to high
			rx_data <= (OTHERS => '0'); --set all data to "0"
			state <= set; --move to the next state

		ELSIF (sys_clock'EVENT AND sys_clock = '1') THEN
			--------------------------------------------------------------------------------------------------------------------------------
			--------------------------------------------------------------------------------------------------------------------------------
			CASE state IS 
				WHEN set => 
					cs <= '1'; 

 
					IF (enable = '1') THEN 
						IF (ClockDivider = 0) THEN --check for valid spi speed
							clk_ratio <= 1; --set the speed to max if the clock divider = 0
							count <= 1; 
						ELSE
							clk_ratio <= ClockDivider; --set to input selection if valid
							count <= ClockDivider; --initiate system-to-spi clock counter
						END IF;
						sclk <= clockPolarity; --set spi clock polarity
						assert_data <= NOT clockPhase; --set spi clock phase
						clk_toggles <= 0; --initiate clock toggle counter
						last_bit_rx <= data_width * 2 + conv_integer(clockPhase) - 1; --set last rx data bit
						state <= operate; --proceed to operate state
					ELSE
						state <= set; --remain in set state
					END IF;
					--------------------------------------------------------------------------------------------------------------------------------
					--------------------------------------------------------------------------------------------------------------------------------
				WHEN operate => 
					IF (enable = '1') THEN
						cs <= '0'; --set slave select output
 
						IF (count = clk_ratio) THEN 
							count <= 1; --reset system-to-spi clock counter
							assert_data <= NOT assert_data; 
							IF (clk_toggles = data_width * 2 + 1) THEN
								clk_toggles <= 0; 
							ELSE
								clk_toggles <= clk_toggles + 1; 
							END IF;
 
							--spi clock toggle
							IF (clk_toggles <= data_width * 2 AND cs = '0') THEN
								sclk <= NOT sclk; --toggle spi clock
							END IF;
 
							--receive spi clock toggle
							IF (cs = '0' AND assert_data = '0' AND clk_toggles < last_bit_rx + 1) THEN
								rx_buffer <= rx_buffer(data_width - 2 DOWNTO 0) & miso; --shift in received bit
							END IF;
 
							--end of the data transaction
							IF (clk_toggles = data_width * 2 + 1) THEN 
								cs <= '1';
								rx_data <= rx_buffer; --Pass the received the data
								state <= set; --go to set state
							ELSE 
								state <= operate; --stay in the operate state
							END IF;
 
						ELSE 
							count <= count + 1; --increment counter
							state <= operate; --stay in the operate state
						END IF;
					END IF;
			END CASE;
		END IF;
	END PROCESS;
END logic;
