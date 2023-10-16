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

entity BRAM_Compressed_Top is
    generic (
        DATA_COMPRESSED_SIZE : positive := 32;
        SIZE_BRAM : positive := 1024
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        decompression_is_ready : in std_logic;
        bram_comp_empty : out std_logic;
        output_valid : out std_logic;
        output_data : out std_logic_vector(DATA_COMPRESSED_SIZE-1 downto 0)
    );
end BRAM_Compressed_Top;

architecture Behavioral of BRAM_Compressed_Top is
    
    signal tmp_compressed_ena : std_logic;
    signal tmp_compressed_enb : std_logic;
    signal tmp_compressed_wea : std_logic;
    signal tmp_compressed_addra : std_logic_vector(9 downto 0);
    signal tmp_compressed_addrb : std_logic_vector(9 downto 0);
    signal tmp_compressed_dia : std_logic_vector(DATA_COMPRESSED_SIZE-1 downto 0);
    signal tmp_compressed_dob : std_logic_vector(DATA_COMPRESSED_SIZE-1 downto 0);

    -- Component declaration for BRAM_Compressed
    component BRAM_Compressed is
        generic(
            DATA_COMPRESSED_SIZE : positive := DATA_COMPRESSED_SIZE;
            SIZE_BRAM : positive := SIZE_BRAM
        );
        port(
            clk : in std_logic;
            ena : in std_logic;
            enb : in std_logic;
            wea : in std_logic;
            addra : in std_logic_vector(9 downto 0);
            addrb : in std_logic_vector(9 downto 0);
            dia : in std_logic_vector(DATA_COMPRESSED_SIZE-1 downto 0);
            dob : out std_logic_vector(DATA_COMPRESSED_SIZE-1 downto 0)
        );
    end component BRAM_Compressed;
    
    component BRAM_Comp_Interface is
        generic (
            DATA_COMPRESSED_SIZE : positive := DATA_COMPRESSED_SIZE;
            SIZE_BRAM : positive := SIZE_BRAM
        );
        port(
            clk : in std_logic;
            reset : in std_logic;
            
            -- Decompressor Signals
            input_valid : out std_logic;
            input_data : out std_logic_vector(DATA_COMPRESSED_SIZE-1 downto 0);
            ready : in std_logic;
            
            is_empty : out std_logic;
            
            -- BRAM - Signals
            ena : out std_logic;
            enb : out std_logic;
            wea : out std_logic;
            addra : out std_logic_vector(9 downto 0);
            addrb : out std_logic_vector(9 downto 0);
            dia : out std_logic_vector(DATA_COMPRESSED_SIZE-1 downto 0);
            dob : in std_logic_vector(DATA_COMPRESSED_SIZE-1 downto 0)
        );
    end component BRAM_Comp_Interface;

begin
    
    -- Instantiate BRAM_Compressed
    BRAM_Comp : BRAM_Compressed
        generic map (
            DATA_COMPRESSED_SIZE => DATA_COMPRESSED_SIZE,
            SIZE_BRAM => SIZE_BRAM
        )
        port map(
            clk => clk,
            ena => tmp_compressed_ena,
            enb => tmp_compressed_enb,
            wea => tmp_compressed_wea,
            addra => tmp_compressed_addra,
            addrb => tmp_compressed_addrb,
            dia => tmp_compressed_dia,
            dob => tmp_compressed_dob
        );
        
    BRAM_Comp_Inter : BRAM_Comp_Interface
        generic map (
            DATA_COMPRESSED_SIZE => DATA_COMPRESSED_SIZE,
            SIZE_BRAM => SIZE_BRAM
        )
        port map(
            clk => clk,
            reset => reset,
            
            -- Decompressor Signals
            input_valid => output_valid,
            input_data => output_data,
            ready => decompression_is_ready,
            
            is_empty => bram_comp_empty,
            
            -- BRAM - Signals
            ena => tmp_compressed_ena,
            enb => tmp_compressed_enb,
            wea => tmp_compressed_wea,
            addra => tmp_compressed_addra,
            addrb => tmp_compressed_addrb,
            dia => tmp_compressed_dia,
            dob => tmp_compressed_dob
        );

end Behavioral;
