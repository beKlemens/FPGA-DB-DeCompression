----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.07.2023 21:25:58
-- Design Name: 
-- Module Name: DeltaDecoder - Behavioral
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DeltaDecoder is
    generic (
        DATA_INPUT_SIZE : positive := 32; -- Size of each input value in bits
        DATA_OUTPUT_SIZE : positive := 32     -- Width of the output signal in bits
    );
    port (
        reset : in std_logic;
        clk : in std_logic;
        next_one_ready : in std_logic;
        input_valid : in std_logic;
        input_data : in std_logic_vector(DATA_INPUT_SIZE-1 downto 0);
        output_data : out std_logic_vector(DATA_OUTPUT_SIZE-1 downto 0);
        output_valid : out std_logic;
        ready : out std_logic
    );
end DeltaDecoder;

architecture Behavioral of DeltaDecoder is
    signal previous : signed(DATA_OUTPUT_SIZE-1 downto 0);
begin

    process (reset, clk)
    begin
        if reset = '1' then
            previous <= (others => '0');
            output_valid <= '0';
            ready <= '1';
        elsif rising_edge(clk) then
            if next_one_ready = '1' then
                if input_valid = '1' then
                    previous <= previous + signed(input_data);
                    output_valid <= '1';
                    ready <= '1';
                 else
                    output_valid <= '0';
                    ready <= '1';
                 end if;
            else
                ready <= '0';
            end if;
        end if;
    end process;

    output_data <= std_logic_vector(previous);

end Behavioral;
