----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.10.2023 12:17:13
-- Design Name: 
-- Module Name: IntegerFloat_TB - Behavioral
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

entity IntegerFloat_TB is
--  Port ( );
end IntegerFloat_TB;

architecture Behavioral of IntegerFloat_TB is
    constant DATA_INPUT_SIZE : positive := 8;
    constant DATA_OUTPUT_SIZE : positive := 8;

    signal clk : std_logic := '0';
    signal input_valid : std_logic := '0';
    signal twos_complement_input_tb     : std_logic_vector(DATA_INPUT_SIZE-1 downto 0); -- -1 in 16-bit two's complement form
    signal decimal_places_tb            : integer := 1;
    signal integer_part_tb              : std_logic_vector(DATA_INPUT_SIZE - 1 downto 0);
    signal fraction_part_tb             : std_logic_vector(DATA_INPUT_SIZE - 1 downto 0);
    signal output_valid                 : std_logic;

    component IntegerToFloat is
        generic (
            DATA_INPUT_SIZE : positive := 32;   -- Size of the integer part (including the sign bit)
            DATA_OUTPUT_SIZE : positive := 32
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
    end component IntegerToFloat;

begin

    dut: IntegerToFloat
        generic map (
            DATA_INPUT_SIZE => DATA_INPUT_SIZE,
            DATA_OUTPUT_SIZE => DATA_OUTPUT_SIZE
        )
        port map (
            twos_complement_input => twos_complement_input_tb,
            clk => clk,
            input_valid => input_valid,
            decimal_places => decimal_places_tb,
            integer_part => integer_part_tb,
            fraction_part => fraction_part_tb,
            output_valid => output_valid
        );
        
   clk_process : process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;


   stimulus : process
        type character_file is file of character;
        file file_pointer : character_file;
        variable read_input : character;
    begin
        input_valid <= '1';
        twos_complement_input_tb <= "01111011"; -- 123 -- results in 12.3
        decimal_places_tb <= 2;
        wait for 10ns;
        
        twos_complement_input_tb <= "00100000"; -- 32 --results in 3.2
        decimal_places_tb <= 1;
        wait for 10ns;
        
        twos_complement_input_tb <= "11100000"; -- -32 --results in -3.2
        decimal_places_tb <= 1;

        wait;
    end process;

end Behavioral;
