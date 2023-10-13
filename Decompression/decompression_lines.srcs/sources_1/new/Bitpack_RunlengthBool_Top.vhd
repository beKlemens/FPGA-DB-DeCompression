----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.10.2023 19:23:33
-- Design Name: 
-- Module Name: Bitpack_RunlengthBool_Top - Behavioral
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

entity Bitpack_RunlengthBool_Top is
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
end Bitpack_RunlengthBool_Top;

architecture Behavioral of Bitpack_RunlengthBool_Top is

    signal tmp_next_one_ready : std_logic;
    signal tmp_bitpack_output_valid : std_logic;
    signal tmp_bitpack_output_data : std_logic_vector(DATA_DECOMPRESSED_SIZE-1 downto 0);

    component UnsignedBitpackingDecoder is
        generic (
            DATA_INPUT_SIZE : positive := DATA_COMPRESSED_SIZE; --max number coding bits used
            DATA_OUTPUT_SIZE : positive := DATA_DECOMPRESSED_SIZE
        );
        port (
            clk : in std_logic;
            reset : in std_logic;
            next_one_ready : in std_logic;
            input_valid : in std_logic;
            input_data : in std_logic_vector(DATA_COMPRESSED_SIZE-1 downto 0);
            sliding_window_size : in std_logic_vector(5 downto 0);
            output_data : out std_logic_vector(DATA_DECOMPRESSED_SIZE-1 downto 0);
            output_valid : out std_logic;
            ready : out std_logic
        );
    end component UnsignedBitpackingDecoder;
    
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

    -- Instantiate BitpackingDecoder
    UnsginedBitpackingDec : UnsignedBitpackingDecoder
        generic map (
            DATA_INPUT_SIZE => DATA_COMPRESSED_SIZE, --max number coding bits used
            DATA_OUTPUT_SIZE => DATA_DECOMPRESSED_SIZE
        )
        port map(
            clk => clk,
            reset => reset,
            next_one_ready => tmp_next_one_ready,
            input_valid => input_valid,
            input_data => input_compressed,
            sliding_window_size => sliding_window_size, -- muss aus dem config header gesetzt werden
            output_data => tmp_bitpack_output_data,
            output_valid => tmp_bitpack_output_valid,
            ready => ready
        );
        
     RunlengthBoolDec : RunlengthBoolDecoder
        generic map (
            DATA_INPUT_SIZE => DATA_COMPRESSED_SIZE,
            DATA_OUTPUT_SIZE => DATA_DECOMPRESSED_SIZE
        )
        port map (
            clk => clk,
            reset => reset,
            next_one_ready => dec_bram_is_ready,
            input_valid => tmp_bitpack_output_valid,
            input_data => tmp_bitpack_output_data,
            output_data => output_decompressed,
            output_valid => output_valid,
            ready => tmp_next_one_ready
        );

end Behavioral;
