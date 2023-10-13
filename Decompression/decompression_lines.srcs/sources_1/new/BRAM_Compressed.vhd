----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.08.2023 17:15:06
-- Design Name: 
-- Module Name: BRAM_Compressed - Behavioral
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
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BRAM_Compressed is
    generic(
        DATA_COMPRESSED_SIZE : positive := 32;
        SIZE_BRAM : positive := 1024
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
end BRAM_Compressed;

architecture Behavioral of BRAM_Compressed is
    type ram_type is array (SIZE_BRAM-1 downto 0) of std_logic_vector(DATA_COMPRESSED_SIZE-1 downto 0);
    shared variable RAM : ram_type;
    
    --type ram_type is array (1023 downto 0) of std_logic_vector(31 downto 0);
    --signal RAM : ram_type;
    
    --signal address : std_logic_vector(9 downto 0) := (others => '0'); 
begin

    process(clk)
    begin
        if clk'event and clk = '1' then
            if ena = '1' then
                if wea = '1' then
                    RAM(conv_integer(addra)) := dia;
                end if;
            end if;
        end if;
    end process;
    
    process(clk)
    begin
        if clk'event and clk = '1' then
            if enb = '1' then
                dob <= RAM(conv_integer(addrb));
            end if;
        end if;
    end process;

end Behavioral;
