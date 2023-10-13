----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.10.2023 09:37:16
-- Design Name: 
-- Module Name: HuffmanCode_Numbers - Behavioral
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

entity HuffmanCode_Numbers is
    port (
        input_code : in std_logic_vector(3 downto 0);
        output_symbol : out std_logic_vector(3 downto 0);
        output_level : out std_logic_vector(4 downto 0) --gives positions to shift the sliding window
    );
end HuffmanCode_Numbers;

architecture Behavioral of HuffmanCode_Numbers is

begin
    process(input_code)
    begin
        case input_code(3 downto 1) is --Level 3
            when "110" =>
                output_symbol <= "0001"; --1
                output_level <= "00011";
            when "100" =>
                output_symbol <= "0100"; --4
                output_level <= "00011";
            when "011" =>
                output_symbol <= "0101"; --5
                output_level <= "00011";
            when "001" =>
                output_symbol <= "0010"; --2
                output_level <= "00011";
            when others =>
                case input_code(3 downto 0) is --Level 4
                    when "1111" =>
                        output_symbol <= "1110"; -- -
                        output_level <= "00100";
                    when "1110" =>
                        output_symbol <= "0111"; --7
                        output_level <= "00100";
                    when "1011" =>
                        output_symbol <= "0011"; --3
                        output_level <= "00100";
                    when "1010" =>
                        output_symbol <= "1111"; --|
                        output_level <= "00100";
                    when "0101" =>
                        output_symbol <= "0000"; --0
                        output_level <= "00100";
                    when "0100" =>
                        output_symbol <= "0110"; --6
                        output_level <= "00100";
                    when "0001" =>
                        output_symbol <= "1000"; --8
                        output_level <= "00100";
                    when "0000" =>
                        output_symbol <= "1001"; --9
                        output_level <= "00100";
                    when others =>
                        output_symbol <= "0000"; -- Default value if no match is found
                        output_level <= "00000";
                end case;
        end case;        
    end process;
end Behavioral;
