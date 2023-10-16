----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.10.2023 20:12:33
-- Design Name: 
-- Module Name: RunlengthBool_Decompression - Behavioral
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

entity RunlengthBool_Decompression is
    generic (
        DATA_COMPRESSED_SIZE : positive := 32;
        DATA_DECOMPRESSED_SIZE : positive := 32;
        SIZE_BRAM : positive := 1024
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        sliding_window_size : in std_logic_vector(5 downto 0);
        output_decompressed : out std_logic_vector(DATA_DECOMPRESSED_SIZE-1 downto 0);
        bram_comp_empty : out std_logic;
        bram_decomp_full : out std_logic
    );
end RunlengthBool_Decompression;

architecture Behavioral of RunlengthBool_Decompression is

    signal tmp_decompression_ready : std_logic;
    signal tmp_compressed_data : std_logic_vector(DATA_COMPRESSED_SIZE-1 downto 0);
    signal tmp_compressed_data_valid : std_logic;
    signal tmp_dec_bram_is_ready : std_logic;
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
    
    component Bitpack_RunlengthBool_Top is
        generic (
            DATA_COMPRESSED_SIZE : positive := DATA_COMPRESSED_SIZE;
            DATA_DECOMPRESSED_SIZE : positive := DATA_DECOMPRESSED_SIZE
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
        
    -- Instantiate BRAM_Compressed_Top
    Bitpacking_RunlengthBool_Top : Bitpack_RunlengthBool_Top
        generic map(
            DATA_COMPRESSED_SIZE => DATA_COMPRESSED_SIZE,
            DATA_DECOMPRESSED_SIZE => DATA_DECOMPRESSED_SIZE
        )
        port map(
            clk => clk,
            reset => reset,
            input_valid => tmp_compressed_data_valid,
            input_compressed => tmp_compressed_data,
            dec_bram_is_ready => tmp_dec_bram_is_ready,       
            sliding_window_size => sliding_window_size,
            output_decompressed => tmp_decompressed_output,
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
            bram_is_ready => tmp_dec_bram_is_ready,
            output_decompressed => output_decompressed
        );


end Behavioral;
