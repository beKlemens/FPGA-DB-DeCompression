----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.10.2023 20:48:59
-- Design Name: 
-- Module Name: Bitpack_RunlengthBoolDec_TB - Behavioral
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

entity Bitpack_RunlengthBoolDec_TB is
--  Port ( );
end Bitpack_RunlengthBoolDec_TB;

architecture Behavioral of Bitpack_RunlengthBoolDec_TB is
    constant DATA_INPUT_SIZE : positive := 32;
    constant DATA_OUTPUT_SIZE : positive := 32;
    constant DATA_READ_SIZE : positive := 8;
  
    signal reset : std_logic := '0';
    signal clk : std_logic := '0';
    signal dec_bram_is_ready : std_logic := '0';
    signal input_valid : std_logic := '0';
    signal input_data : std_logic_vector(DATA_INPUT_SIZE-1 downto 0);
    signal output_data : std_logic_vector(DATA_OUTPUT_SIZE-1 downto 0);
    signal sliding_window_size : std_logic_vector(5 downto 0);
    signal output_valid : std_logic;
    signal ready : std_logic;

    component Bitpack_RunlengthBool_Top is
    generic (
        DATA_COMPRESSED_SIZE : positive := 32;
        DATA_DECOMPRESSED_SIZE : positive := 32
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        input_valid : in std_logic;
        input_compressed : in std_logic_vector(DATA_COMPRESSED_SIZE-1 downto 0);
        dec_bram_is_ready : in std_logic;        
        sliding_window_size : in std_logic_vector(5 downto 0);
        output_decompressed : out std_logic_vector(DATA_DECOMPRESSED_SIZE-1 downto 0);
        output_valid : out std_logic;
        ready : out std_logic
    );
    end component Bitpack_RunlengthBool_Top;
begin

    dut: Bitpack_RunlengthBool_Top
    generic map(
        DATA_COMPRESSED_SIZE => DATA_INPUT_SIZE,
        DATA_DECOMPRESSED_SIZE => DATA_OUTPUT_SIZE
    )
    port map(
        clk => clk,
        reset => reset,
        input_valid => input_valid,
        input_compressed => input_data,
        dec_bram_is_ready => dec_bram_is_ready,       
        sliding_window_size => sliding_window_size,
        output_decompressed => output_data,
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
    
    stimulus : process
        type character_file is file of character;
        file file_pointer : character_file;
        variable read_input : character;
        
        variable input_complete : boolean := false;
        variable counter : integer := 3;
        variable input_build_up : std_logic_vector(DATA_INPUT_SIZE-1 downto 0);
    begin
        reset <= '1';
        sliding_window_size <= "000010"; -- set sliding window size
        dec_bram_is_ready <= '1'; -- bram is empty and ready to receive data
        wait for 10 ns;
        reset <= '0';
        -- config finished
        
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
            else --use the 32 bit input and test behaviour
                input_data <= input_build_up;
                input_valid <= '1';
                
                wait until ready = '1';
                input_valid <= '0';
                input_complete := false;
                input_build_up := (others => '0');
            end if;
            
        end loop;
        file_close(file_pointer);
        -- rest of the file
        wait for 10ns;
        input_data <= input_build_up;
        input_valid <= '1';
        wait for 10ns;
        input_valid <= '0';
        
        wait;
  end process;

end Behavioral;
