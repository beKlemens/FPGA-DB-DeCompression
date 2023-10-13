----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.07.2023 15:48:16
-- Design Name: 
-- Module Name: BitpackingDecoder_TB - Behavioral
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

entity BitpackingDecoder_TB is
end BitpackingDecoder_TB;

architecture Behavioral of BitpackingDecoder_TB is

    constant DATA_INPUT_SIZE : positive := 32;
    constant DATA_OUTPUT_SIZE : positive := 32;

    signal clk_tb             : std_logic := '0';
    signal next_one_ready     : std_logic := '0';
    signal reset_tb           : std_logic := '0';
    signal input_valid_tb     : std_logic := '0';
    signal input_data_tb      : std_logic_vector(DATA_INPUT_SIZE - 1 downto 0);
    signal sliding_window_size_tb      : std_logic_vector(5 downto 0);
    signal output_data_tb     : std_logic_vector(DATA_OUTPUT_SIZE - 1 downto 0);
    signal output_valid_tb    : std_logic := '0';
    signal ready_tb : std_logic;
   
    component BitpackingDecoder is
    generic (
        DATA_INPUT_SIZE : positive := 32; --max number coding bits used
        DATA_OUTPUT_SIZE : positive := 32
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        next_one_ready : in std_logic;
        input_valid : in std_logic;
        input_data : in std_logic_vector(DATA_INPUT_SIZE-1 downto 0);
        sliding_window_size : in std_logic_vector(5 downto 0);
        output_data : out std_logic_vector(DATA_OUTPUT_SIZE-1 downto 0);
        output_valid : out std_logic;
        ready : out std_logic
    );
    end component BitpackingDecoder;

begin

    -- Instantiate the BitpackingDecoder entity
    dut : BitpackingDecoder
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
            sliding_window_size => sliding_window_size_tb,
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
        
        variable input_complete : boolean := false;
        variable counter : integer := 3;
        variable input_build_up : std_logic_vector(DATA_INPUT_SIZE-1 downto 0);
    begin
        next_one_ready <= '1';
        reset_tb <= '1';
        wait for 10 ns;
        reset_tb <= '0';      
    
        file_open(file_pointer, "C:\Users\kleme\OneDrive\Dokumente\Studium\MTI3\Studienarbeit\Simple_Compression\database_stackoverflow\compressed\test_column.bin", READ_MODE);  
        while not endfile(file_pointer) loop
            
            if not input_complete then --build 32 bit input
                read(file_pointer, read_input);
               
                input_build_up(counter * 8 + 7 downto counter * 8) := std_logic_vector(to_unsigned(character'pos(read_input),8));
                counter := counter - 1;
                
                if counter < 0 then
                    counter := 3;
                    input_complete := true;
                end if;  
                wait for 10ns;
            else --use the 32 bit input and test behaviour
                next_one_ready <= '0';
                wait for 10ns;
                input_data_tb <= input_build_up;
                input_valid_tb <= '1';
                sliding_window_size_tb <= "000101"; -- set sliding window size
                wait for 20ns;
                input_valid_tb <= '0';
                wait for 10ns;
                next_one_ready <= '1';
                wait for 20ns;
                next_one_ready <= '0';
                wait for 20ns;
                next_one_ready <= '1';
                
                wait until ready_tb = '1'; 
                input_complete := false;
                input_build_up := (others => '0');
                wait for 10ns;
            end if;
            
        end loop;
        file_close(file_pointer);
        -- rest of the file
        wait for 10ns;
        input_data_tb <= input_build_up;
        input_valid_tb <= '1';
        sliding_window_size_tb <= "000101"; -- set sliding window size
        wait for 10ns;
        input_valid_tb <= '0';
        
        wait;
    end process;
end Behavioral;
