----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.09.2023 12:50:04
-- Design Name: 
-- Module Name: Delta_Decompression_Int - Behavioral
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

entity Huffman_Decompression is
    generic (
        DATA_COMPRESSED_SIZE : positive := 32;
        DATA_DECOMPRESSED_SIZE : positive := 8;
        SIZE_BRAM : positive := 1024;
        SLIDING_WINDOW_SIZE : positive := 24 -- Max depth of tree
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        output_decompressed : out std_logic_vector(DATA_DECOMPRESSED_SIZE-1 downto 0);
        bram_comp_empty : out std_logic;
        bram_decomp_full : out std_logic
    );
end Huffman_Decompression;

architecture Behavioral of Huffman_Decompression is

    signal tmp_decompression_ready : std_logic;
    signal tmp_compressed_data : std_logic_vector(DATA_COMPRESSED_SIZE-1 downto 0);
    signal tmp_compressed_data_valid : std_logic;
    signal tmp_dec_bram_ready : std_logic;
    signal tmp_decompressed_output : std_logic_vector(DATA_DECOMPRESSED_SIZE-1 downto 0);
    signal tmp_decompressed_output_valid : std_logic;

    component BRAM_Compressed_Top is
        generic (
            DATA_COMPRESSED_SIZE : positive := DATA_COMPRESSED_SIZE;
            SIZE_BRAM : positive := SIZE_BRAM
        );
        port (
            clk : in std_logic;
            reset : in std_logic;
            decompression_is_ready : in std_logic;
            bram_comp_empty : out std_logic;
            output_valid : out std_logic;
            output_data : out std_logic_vector(DATA_COMPRESSED_SIZE-1 downto 0)
        );
    end component BRAM_Compressed_Top;
    
    component HuffmanDecoder is
        generic (
            DATA_INPUT_SIZE : positive := DATA_COMPRESSED_SIZE; --max number coding bits used
            DATA_OUTPUT_SIZE : positive := DATA_DECOMPRESSED_SIZE;
            SLIDING_WINDOW_SIZE : positive := SLIDING_WINDOW_SIZE --max depth of tree
        );
        port (
            clk : in std_logic;
            reset : in std_logic;
            input_valid : in std_logic;
            next_one_ready : in std_logic;
            input_data : in std_logic_vector(DATA_INPUT_SIZE-1 downto 0);
            output_data : out std_logic_vector(DATA_OUTPUT_SIZE-1 downto 0);
            output_valid : out std_logic;
            ready : out std_logic
        );
    end component HuffmanDecoder;
    
    component BRAM_Decompressed_Top is
        generic (
            DATA_DECOMPRESSED_SIZE : positive := DATA_DECOMPRESSED_SIZE;
            SIZE_BRAM : positive := SIZE_BRAM
        );
        port (
            clk : in std_logic;
            reset : in std_logic;
            input_valid : in std_logic;
            input_decompressed : in std_logic_vector(DATA_DECOMPRESSED_SIZE-1 downto 0);
            bram_decomp_full : out std_logic;
            bram_is_ready : out std_logic;
            output_decompressed : out std_logic_vector(DATA_DECOMPRESSED_SIZE-1 downto 0)
        );
    end component BRAM_Decompressed_Top;

begin

    -- Instantiate BRAM_Compressed_Top
    BRAM_Comp_Top : BRAM_Compressed_Top
        generic map(
            DATA_COMPRESSED_SIZE => DATA_COMPRESSED_SIZE,
            SIZE_BRAM => SIZE_BRAM
        )
        port map(
            clk => clk,
            reset => reset,
            decompression_is_ready =>tmp_decompression_ready,
            bram_comp_empty => bram_comp_empty,
            output_valid => tmp_compressed_data_valid,
            output_data => tmp_compressed_data
        );
        
    -- Instantiate HuffmanDecoder
    HuffmanDec_Text : HuffmanDecoder
        generic map(
            DATA_INPUT_SIZE => DATA_COMPRESSED_SIZE,
            DATA_OUTPUT_SIZE => DATA_DECOMPRESSED_SIZE,
            SLIDING_WINDOW_SIZE => SLIDING_WINDOW_SIZE
        )
        port map(
            clk => clk,
            reset => reset,
            input_valid => tmp_compressed_data_valid,
            input_data => tmp_compressed_data,
            next_one_ready => tmp_dec_bram_ready,
            output_data => tmp_decompressed_output,
            output_valid => tmp_decompressed_output_valid,
            ready => tmp_decompression_ready
        );       

        
    -- Instantiate BRAM_Decompressed_Top
    BRAM_Decomp_Top : BRAM_Decompressed_Top
        generic map(
            DATA_DECOMPRESSED_SIZE => DATA_DECOMPRESSED_SIZE,
            SIZE_BRAM => SIZE_BRAM
        )
        port map(
            clk => clk,
            reset => reset,
            input_valid => tmp_decompressed_output_valid,
            input_decompressed => tmp_decompressed_output,
            bram_decomp_full => bram_decomp_full,
            bram_is_ready => tmp_dec_bram_ready,
            output_decompressed => output_decompressed
        );

end Behavioral;
