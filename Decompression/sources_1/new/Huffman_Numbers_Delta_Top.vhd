----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.10.2023 16:19:21
-- Design Name: 
-- Module Name: Huffman_Numbers_Delta_Top - Behavioral
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

entity Huffman_Numbers_Delta_Top is
    generic (
        DATA_COMPRESSED_SIZE : positive := 32;
        DATA_HUFFMAN_OUTPUT_SIZE : positive := 4;
        DATA_DECOMPRESSED_SIZE : positive := 32;
        SLIDING_WINDOW_SIZE : positive := 4
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        input_valid : in std_logic;
        input_compressed : in std_logic_vector(DATA_COMPRESSED_SIZE-1 downto 0);
        dec_bram_is_ready : in std_logic;
        output_decompressed : out std_logic_vector(DATA_DECOMPRESSED_SIZE-1 downto 0);
        output_valid : out std_logic;
        ready : out std_logic
    );
end Huffman_Numbers_Delta_Top;

architecture Behavioral of Huffman_Numbers_Delta_Top is

    signal tmp_digit_conc_ready : std_logic;
    signal tmp_huffman_output_valid : std_logic;
    signal tmp_huffman_output_data : std_logic_vector(DATA_HUFFMAN_OUTPUT_SIZE-1 downto 0);
    signal tmp_delta_ready : std_logic;
    signal tmp_digit_conc_output_valid : std_logic;
    signal tmp_digit_conc_output_data : std_logic_vector(DATA_DECOMPRESSED_SIZE-1 downto 0);

    component HuffmanDecoder_Numbers is
        generic (
            DATA_INPUT_SIZE : positive := 32; --max number coding bits used
            DATA_OUTPUT_SIZE : positive := 4;
            SLIDING_WINDOW_SIZE : positive := 4
        );
        port (
            clk : in std_logic;
            reset : in std_logic;
            next_one_ready : in std_logic;
            input_valid : in std_logic;
            input_data : in std_logic_vector(DATA_INPUT_SIZE-1 downto 0);
            output_data : out std_logic_vector(DATA_OUTPUT_SIZE-1 downto 0);
            output_valid : out std_logic;
            ready : out std_logic
        );
    end component HuffmanDecoder_Numbers;
    
    component DigitConcatenation is
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
    end component DigitConcatenation;
    
    component DeltaDecoder is
        generic (
            DATA_INPUT_SIZE : positive := DATA_DECOMPRESSED_SIZE; -- Size of each input value in bits
            DATA_OUTPUT_SIZE : positive := DATA_DECOMPRESSED_SIZE     -- Width of the output signal in bits
        );
        port (
            reset : in std_logic;
            clk : in std_logic;
            next_one_ready : in std_logic;
            input_valid : in std_logic;
            input_data : in std_logic_vector(DATA_DECOMPRESSED_SIZE-1 downto 0);
            output_data : out std_logic_vector(DATA_DECOMPRESSED_SIZE-1 downto 0);
            output_valid : out std_logic;
            ready : out std_logic
        );
    end component DeltaDecoder;

begin

    HuffmanDec_Numbers: HuffmanDecoder_Numbers
        generic map(
            DATA_INPUT_SIZE => DATA_COMPRESSED_SIZE,
            DATA_OUTPUT_SIZE => DATA_HUFFMAN_OUTPUT_SIZE,
            SLIDING_WINDOW_SIZE => SLIDING_WINDOW_SIZE
        )
        port map (
          clk => clk,
          reset => reset,
          next_one_ready => tmp_digit_conc_ready,
          input_valid => input_valid,
          input_data => input_compressed,
          output_data => tmp_huffman_output_data,
          output_valid => tmp_huffman_output_valid,
          ready => ready
        );
        
    Digit_Concat: DigitConcatenation
        generic map (
          DIGIT_INPUT_SIZE => DATA_HUFFMAN_OUTPUT_SIZE,
          DATA_OUTPUT_SIZE => DATA_DECOMPRESSED_SIZE
        )
        port map (
          reset => reset,
          clk => clk,
          next_one_ready => tmp_delta_ready,
          input_valid => tmp_huffman_output_valid,
          input_data => tmp_huffman_output_data,
          output_data => tmp_digit_conc_output_data,
          output_valid => tmp_digit_conc_output_valid,
          ready => tmp_digit_conc_ready
        );
        
    -- Instantiate DeltaDecoder
    DeltaDec : DeltaDecoder
        generic map (
            DATA_INPUT_SIZE => DATA_DECOMPRESSED_SIZE, --max number coding bits used
            DATA_OUTPUT_SIZE => DATA_DECOMPRESSED_SIZE
        )
        port map(
            clk => clk,
            reset => reset,
            next_one_ready => dec_bram_is_ready,
            input_valid => tmp_digit_conc_output_valid,
            input_data => tmp_digit_conc_output_data,
            output_data => output_decompressed,
            output_valid => output_valid,
            ready => tmp_delta_ready
        );

end Behavioral;
