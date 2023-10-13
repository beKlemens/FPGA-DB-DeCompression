----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.08.2023 13:12:40
-- Design Name: 
-- Module Name: Decompression_Single_Method - Behavioral
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

entity BRAM_Decompressed_Top is
    generic (
        DATA_DECOMPRESSED_SIZE : positive := 32;
        SIZE_BRAM : positive := 1024
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
end BRAM_Decompressed_Top;

architecture Behavioral of BRAM_Decompressed_Top is
    
    signal tmp_decompressed_ena : std_logic;
    signal tmp_decompressed_enb : std_logic;
    signal tmp_decompressed_wea : std_logic;
    signal tmp_decompressed_addra : std_logic_vector(9 downto 0);
    signal tmp_decompressed_addrb : std_logic_vector(9 downto 0);
    signal tmp_decompressed_dia : std_logic_vector(DATA_DECOMPRESSED_SIZE-1 downto 0);
    signal tmp_decompressed_dob : std_logic_vector(DATA_DECOMPRESSED_SIZE-1 downto 0);

    -- Component declaration for BRAM_Decompressed
    component BRAM_Decompressed is
        generic(
            DATA_DECOMPRESSED_SIZE : positive := DATA_DECOMPRESSED_SIZE;
            SIZE_BRAM : positive := SIZE_BRAM
        );
        port(
            clk : in std_logic;
            ena : in std_logic;
            enb : in std_logic;
            wea : in std_logic;
            addra : in std_logic_vector(9 downto 0);
            addrb : in std_logic_vector(9 downto 0);
            dia : in std_logic_vector(DATA_DECOMPRESSED_SIZE-1 downto 0);
            dob : out std_logic_vector(DATA_DECOMPRESSED_SIZE-1 downto 0)
        );
    end component BRAM_Decompressed;
    
    component BRAM_Decomp_Interface is
        generic (
            DATA_DECOMPRESSED_SIZE : positive := DATA_DECOMPRESSED_SIZE;
            SIZE_BRAM : positive := SIZE_BRAM
        );
        port(
            clk : in std_logic;
            reset : in std_logic;
            
            -- Decompressor Signals
            output_data : in std_logic_vector(DATA_DECOMPRESSED_SIZE-1 downto 0);
            output_valid : in std_logic;
            
            is_full : out std_logic;
            bram_is_ready : out std_logic;
            
            -- BRAM - Signals
            ena : out std_logic;
            enb : out std_logic;
            wea : out std_logic;
            addra : out std_logic_vector(9 downto 0);
            addrb : out std_logic_vector(9 downto 0);
            dia : out std_logic_vector(DATA_DECOMPRESSED_SIZE-1 downto 0)
        );
    end component BRAM_Decomp_Interface;

begin
        
    -- Instantiate BRAM_Decompressed
    BRAM_Decomp : BRAM_Decompressed
        generic map (
            DATA_DECOMPRESSED_SIZE => DATA_DECOMPRESSED_SIZE
        )
        port map(
            clk => clk,
            ena => tmp_decompressed_ena,
            wea => tmp_decompressed_wea,
            enb => tmp_decompressed_enb,
            addra => tmp_decompressed_addra,
            addrb => tmp_decompressed_addrb,
            dia => tmp_decompressed_dia,
            dob => output_decompressed
        );
        
    BRAM_Decomp_Inter : BRAM_Decomp_Interface
        generic map (
            DATA_DECOMPRESSED_SIZE => DATA_DECOMPRESSED_SIZE,
            SIZE_BRAM => SIZE_BRAM
        )
        port map(
            clk => clk,
            reset => reset,
            
            -- Decompressor Signals
            output_data => input_decompressed,
            output_valid => input_valid,
            
            is_full => bram_decomp_full,
            bram_is_ready => bram_is_ready,
            
            -- BRAM - Signals
            ena => tmp_decompressed_ena,
            enb => tmp_decompressed_enb,
            wea => tmp_decompressed_wea,
            addra => tmp_decompressed_addra,
            addrb => tmp_decompressed_addrb,
            dia => tmp_decompressed_dia
        );     

end Behavioral;
