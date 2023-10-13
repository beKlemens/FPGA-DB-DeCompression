----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.08.2023 11:54:05
-- Design Name: 
-- Module Name: IntegerToFloat - Behavioral
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
use ieee.numeric_std.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IntegerToFloat is
    generic (
        DATA_INPUT_SIZE : positive := 32;
        DATA_OUTPUT_SIZE: positive := 32
    );
    port (
        twos_complement_input : in std_logic_vector(DATA_INPUT_SIZE - 1 downto 0);
        clk : in std_logic;
        input_valid : in std_logic;
        decimal_places : in integer;
        integer_part : out std_logic_vector(DATA_OUTPUT_SIZE - 1 downto 0);
        fraction_part : out std_logic_vector(DATA_OUTPUT_SIZE - 1 downto 0);
        output_valid : out std_logic
    );
end IntegerToFloat;

architecture Behavioral of IntegerToFloat is

    signal dividingThrough : integer;

begin
    
    process (decimal_places) is --lookup table for dividing integer -> since exponential calculation is not possible
    begin
        case decimal_places is
        when 1 => dividingThrough <= 10;
        when 2 => dividingThrough <= 100;
        when 3 => dividingThrough <= 1000;
        when 4 => dividingThrough <= 10000;
        when 5 => dividingThrough <= 100000;
        when 6 => dividingThrough <= 1000000;
        when 7 => dividingThrough <= 10000000;
        when 8 => dividingThrough <= 100000000;
        when 9 => dividingThrough <= 1000000000;
        when others => --bound of range of integers -> no compression would make sence, since it would cost more bits than uncompressed
            dividingThrough <= 10;
        end case;
    end process;

    process (clk)
    begin
        if rising_edge(clk) then
            if input_valid = '1' then
                integer_part <= std_logic_vector(to_signed((to_integer(signed(twos_complement_input)) / dividingThrough), DATA_OUTPUT_SIZE));
                fraction_part <= std_logic_vector(to_signed((abs(to_integer(signed(twos_complement_input))) mod dividingThrough), DATA_OUTPUT_SIZE));
                output_valid <= '1';
            else
                output_valid <= '0';
            end if;
        end if;
    end process;
end Behavioral;
