----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.08.2023 11:44:07
-- Design Name: 
-- Module Name: RunlengthBoolDecoder_TB - Behavioral
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
use ieee.std_logic_textio.all;
use std.textio.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RunlengthBoolDecoder_TB is
end RunlengthBoolDecoder_TB;

architecture Behavioral of RunlengthBoolDecoder_TB is

    constant DATA_INPUT_SIZE : positive := 2;
    constant DATA_OUTPUT_SIZE : positive := 1;
    
    constant DATA_READ_SIZE : positive := 8;

    signal clk_tb             : std_logic := '0';
    signal reset_tb           : std_logic := '0';
    signal next_one_ready     : std_logic;
    signal input_valid_tb     : std_logic := '0';
    signal input_data_tb      : std_logic_vector(DATA_INPUT_SIZE - 1 downto 0);
    signal output_data_tb     : std_logic_vector(DATA_OUTPUT_SIZE - 1 downto 0);
    signal output_valid_tb    : std_logic := '0';
    signal ready_tb           : std_logic;
    
    signal binary_input: std_logic_vector(DATA_READ_SIZE-1 downto 0);
    signal is_first_value : boolean := true;

    component RunlengthBoolDecoder is
        generic (
            DATA_INPUT_SIZE : positive := 32; -- Size of each input value in bits
            DATA_OUTPUT_SIZE : positive := 1 
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
    end component RunlengthBoolDecoder;

begin

    -- Instantiate the BitpackingDecoder entity
    dut : RunlengthBoolDecoder
        generic map (
            DATA_INPUT_SIZE => DATA_INPUT_SIZE,
            DATA_OUTPUT_SIZE => DATA_OUTPUT_SIZE
        )
        port map (
            clk => clk_tb,
            reset => reset_tb,
            next_one_ready => next_one_ready,
            input_valid => input_valid_tb,
            input_data => input_data_tb,
            output_data => output_data_tb,
            output_valid => output_valid_tb,
            ready => ready_tb
        );
        
    clk_process : process
    begin
        clk_tb <= '0';
        wait for 5 ns;
        clk_tb <= '1';
        wait for 5 ns;
    end process;
    
    -- Stimulus process
    stimulus_process : process
        type character_file is file of character;
        file file_pointer : character_file;
        variable read_input : character;
    begin
        reset_tb <= '1';
        next_one_ready <= '1';
        wait for 10 ns;
        reset_tb <= '0';      
    
        file_open(file_pointer, "C:\Users\kleme\OneDrive\Dokumente\Studium\MTI3\Studienarbeit\Simple_Compression\database_stackoverflow\compressed\test_column.bin", READ_MODE);  
        while not endfile(file_pointer) loop
            read(file_pointer, read_input);
            binary_input <= std_logic_vector(to_unsigned(character'pos(read_input),8));
            
            wait for 10ns;
            input_data_tb <=  binary_input(7 downto 6);   -- Input data
            input_valid_tb <= '1';       -- Assert input_valid    
            wait for 10ns;
            
            input_data_tb <=  binary_input(5 downto 4);   -- Input data
            input_valid_tb <= '1';       -- Assert input_valid           
            wait until ready_tb = '1';

            input_data_tb <=  binary_input(3 downto 2);   -- Input data
            input_valid_tb <= '1';       -- Assert input_valid           
            wait until ready_tb = '1';

            input_data_tb <=  binary_input(1 downto 0);   -- Input data
            input_valid_tb <= '1';       -- Assert input_valid           
            wait until ready_tb = '1';
            
        end loop;
        file_close(file_pointer);
        wait;
    end process;

end Behavioral;
