----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.08.2023 15:00:05
-- Design Name: 
-- Module Name: HuffmanCode - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity HuffmanCode is
    port (
        input_code : in std_logic_vector(23 downto 0);
        output_symbol : out std_logic_vector(7 downto 0);
        output_level : out std_logic_vector(4 downto 0) --gives positions to shift the sliding window
    );
end HuffmanCode;

architecture Behavioral of HuffmanCode is
begin
    process(input_code)
    begin
        case input_code(23 downto 20) is --Level 4
            when "1111" =>
                output_symbol <= "00100000"; --space
                output_level <= "00100";
            when "0110" =>
                output_symbol <= "01100101"; --e
                output_level <= "00100";
            when "0010" =>
                output_symbol <= "01111100"; --|
                output_level <= "00100";
            when "0001" =>
                output_symbol <= "01100001"; --a
                output_level <= "00100";
            when others =>
                case input_code(23 downto 19) is --Level 5
                    when "11010" =>
                        output_symbol <= "01110100"; --t
                        output_level <= "00101";
                    when "10111" =>
                        output_symbol <= "01110010"; --r
                        output_level <= "00101";
                    when "10110" =>
                        output_symbol <= "01101001"; --i
                        output_level <= "00101";
                    when "10101" =>
                        output_symbol <= "01101110"; --n
                        output_level <= "00101";
                    when "10100" =>
                        output_symbol <= "01101100"; --l
                        output_level <= "00101";
                    when "10011" =>
                        output_symbol <= "01101111"; --o
                        output_level <= "00101";
                    when "10010" =>
                        output_symbol <= "01110011"; --s
                        output_level <= "00101";
                    when "01110" =>
                        output_symbol <= "00110000"; --0
                        output_level <= "00101";
                    when "00111" =>
                        output_symbol <= "01110101"; --u
                        output_level <= "00101";
                    when others =>
                        case input_code(23 downto 18) is --Level 6
                            when "110111" =>
                                output_symbol <= "01100011"; --c
                                output_level <= "00110";
                            when "110011" =>
                                output_symbol <= "01101000"; --h
                                output_level <= "00110";
                            when "110000" =>
                                output_symbol <= "01110000"; --p
                                output_level <= "00110";
                            when "100011" =>
                                output_symbol <= "01100100"; --d
                                output_level <= "00110";
                            when "010101" =>
                                output_symbol <= "01111001"; --y
                                output_level <= "00110";
                            when "010000" =>
                                output_symbol <= "01101101"; --m
                                output_level <= "00110";                                 
                            when others =>
                                case input_code(23 downto 17) is --Level 7
                                    when "1110000" =>
                                        output_symbol <= "01110111"; --w
                                        output_level <= "00111";
                                    when "1110001" =>
                                        output_symbol <= "01100110"; --f
                                        output_level <= "00111";                                    
                                    when others => --todo: finish tree with all remain values
                                        case input_code(23 downto 0) is
                                            when others =>
                                                output_symbol <= "00000000"; -- Default value if no match is found
                                                output_level <= "00000";
                                        end case;
                                end case;
                        end case;
                end case;  
        end case;        
    end process;
    
end Behavioral;
