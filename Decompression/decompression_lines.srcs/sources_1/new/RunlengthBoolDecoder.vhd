----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.08.2023 10:47:30
-- Design Name: 
-- Module Name: RunlengthBoolDecoder - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RunlengthBoolDecoder is
    generic (
        DATA_INPUT_SIZE : positive := 32; -- Size of each input value in bits
        DATA_OUTPUT_SIZE : positive := 1 -- Size of each input value in bits
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
end RunlengthBoolDecoder;

architecture Behavioral of RunlengthBoolDecoder is
    signal is_first_value : boolean := true;
    signal count : integer := 0;
    signal is_decoding : boolean := false;
    signal init_value : std_logic := '1';
    signal is_valid : std_logic := '0';
begin

    process (reset, clk)
    begin
        if reset = '1' then
            count <= 0;
            is_decoding <= false;
            output_data <= ( others => '0'); 
            output_valid <= '0';
            is_first_value <= true;
            ready <= '1';
        elsif rising_edge(clk) then    
            if next_one_ready = '1' then
                if input_valid = '1' then --input changes when ready = true
                    if is_first_value = true then
                        if to_integer(unsigned(input_data)) = 1 then
                            init_value <= '1';
                        else
                            init_value <= '0';
                        end if;
                        is_first_value <= false;
                    elsif not is_decoding then
                        count <= to_integer(unsigned(input_data));
                        ready <= '0';
                        is_decoding <= true;
                    end if;
                    
                    if is_decoding = true and not is_first_value then
                        if count > 0 then
                            output_data <= (DATA_OUTPUT_SIZE-1 downto 1 => '0') & init_value; 
                            output_valid <= '1';
                            count <= count - 1;  
                            ready <= '0';
                        else
                            output_valid <= '0';
                            is_decoding <= false;
                            init_value <= not init_value;
                            ready <= '1';
                        end if;
                    end if;
                else
                    ready <= '1';
                end if;
            else
                ready <= '0';
            end if;
            
        end if;
    end process;
end Behavioral;
