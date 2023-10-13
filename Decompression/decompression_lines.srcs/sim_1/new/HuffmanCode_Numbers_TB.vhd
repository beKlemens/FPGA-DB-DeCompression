----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.08.2023 15:30:22
-- Design Name: 
-- Module Name: HuffmanCode_TB - Behavioral
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

entity HuffmanCode_Numbers_TB is
end HuffmanCode_Numbers_TB;

architecture Behavioral of HuffmanCode_Numbers_TB is
    constant DATA_INPUT_SIZE : positive := 4; --spaeter sliding window 
    constant DATA_OUTPUT_SIZE : positive := 4;

    signal clk_tb             : std_logic := '0';
    signal input_code_tb : std_logic_vector(DATA_INPUT_SIZE-1 downto 0);
    signal output_symbol_tb : std_logic_vector(DATA_OUTPUT_SIZE-1 downto 0);
    signal output_level_tb : std_logic_vector(4 downto 0);

    component HuffmanCode_Numbers is
        port (
            input_code : in std_logic_vector(DATA_INPUT_SIZE-1 downto 0);
            output_symbol : out std_logic_vector(DATA_OUTPUT_SIZE-1 downto 0);
            output_level : out std_logic_vector(4 downto 0)
        );
    end component HuffmanCode_Numbers;

begin

    dut : HuffmanCode_Numbers
    port map (
      input_code => input_code_tb,
      output_symbol => output_symbol_tb,
      output_level => output_level_tb
    );

    clk_process : process
    begin
        clk_tb <= '0';
        wait for 5 ns;
        clk_tb <= '1';
        wait for 5 ns;
    end process;
    
    stimulus_process : process
    begin
        input_code_tb <= "1001";
        wait for 10ns;
        assert output_symbol_tb = "0100"
            report "Test failed: Expected outputValue = '4'"
            severity error;
            
        wait for 20ns;
         
        input_code_tb <= "0100";
        wait for 10ns;
        assert output_symbol_tb = "0110"
            report "Test failed: Expected outputValue = '6'"
            severity error;
            
        wait for 10ns;
         
        input_code_tb <= "1111";
        wait for 10ns;
        assert output_symbol_tb = "1110"
            report "Test failed: Expected outputValue = '-'"
            severity error;
            
        wait;
    end process;
    
end Behavioral;
