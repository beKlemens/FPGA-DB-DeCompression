----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.10.2023 11:08:12
-- Design Name: 
-- Module Name: DigitConcatenation - Behavioral
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

entity DigitConcatenation is
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
end DigitConcatenation;

architecture Behavioral of DigitConcatenation is
    signal value : integer;
    signal is_negative : std_logic;
begin

    process (reset, clk)
    begin
        if reset = '1' then
            output_valid <= '0';
            ready <= '1';
            value <= 0;
            is_negative <= '0';
        elsif rising_edge(clk) then
            if input_valid = '1' then
                if input_data = "1111" then -- is end of number -> start new one
                    if next_one_ready = '1' then -- wait till next one is ready
                        if is_negative = '1' then -- set sign
                            output_data <= std_logic_vector(unsigned(not std_logic_vector(to_unsigned(value, output_data'length))) + 1);
                        else
                            output_data <= std_logic_vector(to_unsigned(value, output_data'length));
                        end if;
                        
                        output_valid <= '1';
                        is_negative <= '0'; --reset negativ sign
                        value <= 0; --reset value for new number
                        ready <= '1';
                    else
                        ready <= '0';
                    end if;
                elsif input_data = "1110" then --set negative sign
                    is_negative <= '1';
                    output_valid <= '0';
                else --build number
                    value <= value * 10 + to_integer(unsigned(input_data));
                    output_valid <= '0';
                end if;
            else
                output_valid <= '0';
                ready <= '1';
            end if;
        end if;
    end process;

end Behavioral;
