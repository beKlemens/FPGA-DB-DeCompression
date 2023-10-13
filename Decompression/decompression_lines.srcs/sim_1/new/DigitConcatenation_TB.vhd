----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.10.2023 11:48:35
-- Design Name: 
-- Module Name: DigitConcatenation_TB - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DigitConcatenation_TB is
--  Port ( );
end DigitConcatenation_TB;

architecture Behavioral of DigitConcatenation_TB is
  constant DATA_INPUT_SIZE : positive := 4;
  constant DATA_OUTPUT_SIZE : positive := 32;
  
  signal reset : std_logic := '0';
  signal clk : std_logic := '0';
  signal next_one_ready : std_logic := '0';
  signal input_valid : std_logic := '0';
  signal input_data : std_logic_vector(DATA_INPUT_SIZE-1 downto 0);
  signal output_data : std_logic_vector(DATA_OUTPUT_SIZE-1 downto 0);
  signal output_valid : std_logic;
  signal ready : std_logic;
  
    component DigitConcatenation is
        generic (
            DIGIT_INPUT_SIZE : positive := 4; -- Size of each input value in bits
            DATA_OUTPUT_SIZE : positive := 32     -- Width of the output signal in bits
        );
        port (
            reset : in std_logic;
            clk : in std_logic;
            next_one_ready : in std_logic;
            input_valid : in std_logic;
            input_data : in std_logic_vector(DIGIT_INPUT_SIZE-1 downto 0);
            output_data : out std_logic_vector(DATA_OUTPUT_SIZE-1 downto 0);
            output_valid : out std_logic;
            ready : out std_logic
        );
    end component DigitConcatenation;
  
begin

    -- Instantiate the DeltaDecoder entity
    dut : DigitConcatenation
        generic map (
          DIGIT_INPUT_SIZE => DATA_INPUT_SIZE,
          DATA_OUTPUT_SIZE => DATA_OUTPUT_SIZE
        )
        port map (
          reset => reset,
          clk => clk,
          next_one_ready => next_one_ready,
          input_valid => input_valid,
          input_data => input_data,
          output_data => output_data,
          output_valid => output_valid,
          ready => ready
        );

    clk_process : process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;
    
    stimulus_process : process
    begin
        reset <= '1';
        next_one_ready <= '1';
        wait for 10ns;
        reset <= '0';
        wait for 20ns;
    
    
        input_data <= "0001"; --1
        input_valid <= '1';
        wait for 10ns;
         
        input_data <= "0010"; --2
        input_valid <= '1';
        wait for 10ns;
         
        input_data <= "0011"; --3
        input_valid <= '1';
        wait for 10ns;
        
        input_data <= "1111"; --| end of number -> start of new number
        input_valid <= '1';
        wait for 10ns;
        
        input_data <= "0101"; --5
        input_valid <= '1';
        wait for 10ns;
        
        input_data <= "0101"; --5
        input_valid <= '1';
        wait for 10ns;
        
        input_data <= "0100"; --4
        input_valid <= '1';
        wait for 10ns;
        
        input_data <= "1111"; --| end of number -> start of new number
        input_valid <= '1';
        wait for 10ns;
        
        input_data <= "1110"; -- - negative number
        input_valid <= '1';
        wait for 10ns;
        
        input_data <= "0100"; --4
        input_valid <= '1';
        wait for 10ns;
        
        input_data <= "1001"; --9
        input_valid <= '1';
        wait for 10ns;
        
        input_data <= "1111"; --| end of number -> start of new number
        input_valid <= '1';
        wait for 10ns;
        
        
--        assert output_data = "01110011"
--            report "Test failed: Expected outputValue = 's'"
--            severity error;
            
        wait;
    end process;

end Behavioral;
