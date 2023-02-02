-------------------------------------------------------------------------------
-- SPI Master implementation on Basys 3 Board    							 --
--                                                                           --
-- Author : Ali Reza NOORI                                                   --
-- Date   : 08 01 2021                                                       --
-- File   : SPI_Master.vhd                                    		      	 --
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity spi_master is
  generic(
        data_width : integer := 16); 
  port(
    sys_clock   		: in     std_logic;  
    reset_asyn 			: in     std_logic;  
    enable 				: in     std_logic;  
    clockPolarity    	: in     std_logic;  
    clockPhase    		: in     std_logic;  
    ClockDivider 		: in     integer;    
    miso    			: in     std_logic;  
    sclk   				: buffer std_logic; 
    cs   				: buffer std_logic;  
    rx_data 			: out    std_logic_vector(data_width-1 downto 0)); --data received
end spi_master;

architecture logic of spi_master is
  type FSM is(set, operate);                            		--state FSM data type
  signal state       : FSM;                              		--current state
  signal clk_ratio   : integer;                              	--current ClockDivider
  signal count       : integer;                              	--counter 
  signal clk_toggles : integer range 0 to data_width*2 + 1;     
  signal assert_data : std_logic;                           	
  signal rx_buffer   : std_logic_vector(data_width-1 downto 0); --receive data buffer
  signal last_bit_rx : integer range 0 to data_width*2;         --last rx data bit adress
begin
  process(sys_clock, reset_asyn)
  begin

    if(reset_asyn = '1') then       	 			--Asynchronous Reset 
      cs <= '1';			      					--Pull Chip select to high
      rx_data <= (others => '0');					--set all data to "0"
      state <= set;           						--move to the next state

    elsif(sys_clock'event and sys_clock = '1') then
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
      case state is               
        when set =>
          cs <= '1'; 			   

          
          if(enable = '1') then       
            if(ClockDivider = 0) then     										--check for valid spi speed
              clk_ratio <= 1;        											--set the speed to max if the clock divider = 0
              count <= 1;           			 								
            else
              clk_ratio <= ClockDivider;  										--set to input selection if valid
              count <= ClockDivider;      										--initiate system-to-spi clock counter
            end if;
            sclk <= clockPolarity;            									--set spi clock polarity
            assert_data <= not clockPhase; 										--set spi clock phase
            clk_toggles <= 0;        											--initiate clock toggle counter
            last_bit_rx <= data_width*2 + conv_integer(clockPhase) - 1; 		--set last rx data bit
            state <= operate;        											--proceed to operate state
          else
            state <= set;          												--remain in set state
          end if;
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
        when operate =>
		if(enable = '1') then 
          cs <= '0'; 															--set slave select output
          
          if(count = clk_ratio) then        
            count <= 1;                     									--reset system-to-spi clock counter
             assert_data <= not assert_data; 									
            if(clk_toggles = data_width*2 + 1) then
              clk_toggles <= 0;               									
            else
              clk_toggles <= clk_toggles + 1; 									
            end if;
            
            --spi clock toggle 
            if(clk_toggles <= data_width*2 and cs = '0') then 
              sclk <= not sclk; --toggle spi clock
            end if;
            
            --receive spi clock toggle
            if(cs = '0' and assert_data = '0' and clk_toggles < last_bit_rx + 1) then 
              rx_buffer <= rx_buffer(data_width-2 downto 0) & miso; 			--shift in received bit
            end if;
			
            --end of the data transaction
            if(clk_toggles = data_width*2 + 1) then   
              cs <= '1'; 
              rx_data <= rx_buffer;    	--Pass the received the data
              state <= set;          	--go to set state
            else                      
              state <= operate;        --stay in the operate state
            end if;
          
          else        
            count <= count + 1; --increment counter
            state <= operate;   --stay in the operate state
          end if;
		end if;
      end case;
    end if;
  end process; 
end logic;
