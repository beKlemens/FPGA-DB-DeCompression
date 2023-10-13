----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.09.2023 12:17:47
-- Design Name: 
-- Module Name: Bitpacking_Delta_Top - Behavioral
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

entity Bitpacking_Runlength_Delta_Int_Top is
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
end Bitpacking_Runlength_Delta_Int_Top;

architecture Behavioral of Bitpacking_Runlength_Delta_Int_Top is

    signal tmp_delta_ready : std_logic;
    signal tmp_runlength_ready : std_logic;
    signal tmp_bitpack_output_valid : std_logic;
    signal tmp_bitpack_output_data : std_logic_vector(DATA_DECOMPRESSED_SIZE-1 downto 0);
    signal tmp_runlength_output_valid : std_logic;
    signal tmp_runlength_output_data : std_logic_vector(DATA_DECOMPRESSED_SIZE-1 downto 0);

    component BitpackingDecoder is
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
    end component BitpackingDecoder;
    
    component RunlengthDecoder is
        generic (
            DATA_INPUT_SIZE : positive := 32;
            DATA_OUTPUT_SIZE : positive := 32
        );
        port (
            clk : in std_logic;
            reset : in std_logic;
            next_one_ready : in std_logic;
            input_valid : in std_logic;
            input_data : in std_logic_vector(DATA_COMPRESSED_SIZE-1 downto 0);
            output_data : out std_logic_vector(DATA_DECOMPRESSED_SIZE-1 downto 0);
            output_valid : out std_logic;
            ready : out std_logic
        );
    end component RunlengthDecoder;
    
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

    -- Instantiate BitpackingDecoder
    BitpackingDec : BitpackingDecoder
        generic map (
            DATA_INPUT_SIZE => DATA_COMPRESSED_SIZE, --max number coding bits used
            DATA_OUTPUT_SIZE => DATA_DECOMPRESSED_SIZE
        )
        port map(
            clk => clk,
            reset => reset,
            next_one_ready => tmp_runlength_ready,
            input_valid => input_valid,
            input_data => input_compressed,
            sliding_window_size => sliding_window_size, -- muss aus dem config header gesetzt werden
            output_data => tmp_bitpack_output_data,
            output_valid => tmp_bitpack_output_valid,
            ready => ready
        );
        
    RunlengthDec : RunlengthDecoder
        generic map(
            DATA_INPUT_SIZE => DATA_COMPRESSED_SIZE,
            DATA_OUTPUT_SIZE => DATA_DECOMPRESSED_SIZE
        )
        port map(
            clk => clk,
            reset => reset,
            next_one_ready => tmp_delta_ready,
            input_valid => tmp_bitpack_output_valid,
            input_data => tmp_bitpack_output_data,
            output_data => tmp_runlength_output_data,
            output_valid => tmp_runlength_output_valid,
            ready => tmp_runlength_ready
        );
        
    -- Instantiate BitpackingDecoder
    DeltaDec : DeltaDecoder
        generic map (
            DATA_INPUT_SIZE => DATA_DECOMPRESSED_SIZE, --max number coding bits used
            DATA_OUTPUT_SIZE => DATA_DECOMPRESSED_SIZE
        )
        port map(
            clk => clk,
            reset => reset,
            next_one_ready => dec_bram_is_ready,
            input_valid => tmp_runlength_output_valid,
            input_data => tmp_runlength_output_data,
            output_data => output_decompressed,
            output_valid => output_valid,
            ready => tmp_delta_ready
        );

end Behavioral;
