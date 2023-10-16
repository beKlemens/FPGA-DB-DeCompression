----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.08.2023 19:24:11
-- Design Name: 
-- Module Name: BRAM_Comp_Interface - Behavioral
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

entity BRAM_Comp_Interface is
    generic (
        DATA_COMPRESSED_SIZE : positive := 32;
        SIZE_BRAM : positive := 1024
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
end BRAM_Comp_Interface;

architecture Behavioral of BRAM_Comp_Interface is

begin

    process (reset, clk)
        variable address : integer := 0;
        variable read_finished : boolean := false;
    begin
        if reset = '1' then
            address := 0;
            read_finished := false;
        elsif rising_edge(clk) then
            if not read_finished then
                if ready = '1' then
                    if address < SIZE_BRAM then
                        -- read new data from Bram and transmit is to decompressor
                        ena <= '0';
                        enb <= '1';
                        wea <= '0';
                        addra <= (others => '0');
                        addrb <= conv_std_logic_vector(address, addrb'length);
                        dia <= (others => '0');
                        is_empty <= '0';
                        address := address +1;
                        read_finished := true;
                    else
                        is_empty <= '1';
                    end if;
                end if;
                input_valid <= '0';
            else
                input_data <= dob;
                input_valid <= '1';
                read_finished := false;
            end if;

        end if;
    end process;

end Behavioral;
