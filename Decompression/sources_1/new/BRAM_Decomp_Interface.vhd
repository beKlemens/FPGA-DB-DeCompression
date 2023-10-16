----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.08.2023 20:00:51
-- Design Name: 
-- Module Name: BRAM_Decomp_Interface - Behavioral
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
use ieee.Std_Logic_Arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BRAM_Decomp_Interface is
    generic (
        DATA_DECOMPRESSED_SIZE : positive := 32;
        SIZE_BRAM : positive := 1024
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
end BRAM_Decomp_Interface;

architecture Behavioral of BRAM_Decomp_Interface is

begin

    process (reset, clk)
        variable address : integer := 0;
    begin
        if reset = '1' then
            address := 0;
            ena <= '0';
            enb <= '0';
            wea <= '0';
            bram_is_ready <= '1';
        elsif rising_edge(clk) then
            if address < SIZE_BRAM then
                if output_valid = '1' then
                    --write to decompressed BRAM
                    ena <= '1';
                    enb <= '0';
                    wea <= '1';
                    addra <= conv_std_logic_vector(address, addra'length);
                    addrb <= (others => '0');
                    dia <= output_data;
                    address := address +1;       
                    bram_is_ready <= '1';
                end if;
                is_full <= '0';
            else
                is_full <= '1';
                bram_is_ready <= '0';
            end if;
        end if;
    end process;


end Behavioral;
