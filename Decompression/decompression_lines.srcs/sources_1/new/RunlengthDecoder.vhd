----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.07.2023 11:51:41
-- Design Name: 
-- Module Name: RunlengthDecoder - Behavioral
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

entity RunlengthDecoder is
    generic (
        DATA_INPUT_SIZE : positive := 32;
        DATA_OUTPUT_SIZE : positive := 32
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
end RunlengthDecoder;

architecture Behavioral of RunlengthDecoder is
    signal readLength : boolean := true;
    signal count : integer := 0;
    signal current_value : std_logic_vector(DATA_OUTPUT_SIZE-1 downto 0) := (others => '0');
    signal is_decoding : boolean := false;

begin   
    process (reset, clk)
    begin
        if reset = '1' then
            count <= 0;
            current_value <= (others => '0');
            is_decoding <= false;
            output_data <= (others => '0');
            output_valid <= '0';
            ready <= '1';
        elsif rising_edge(clk) then
            if next_one_ready = '1' then
                if input_valid = '1' then
                    if not is_decoding then
                        if readLength = true then
                            count <= to_integer(unsigned(input_data));
                            readLength <= false;
                        else
                            current_value <= input_data;
                            is_decoding <= true;
                            ready <= '0';
                        end if;
                     end if;
                elsif input_valid = '0' and not is_decoding then
                    ready <= '1';
                end if;
                
                if is_decoding then
                    output_data <= current_value;
                    output_valid <= '1';
                    count <= count - 1;
    
                    if count = 0 then
                        is_decoding <= false;
                        readLength <= true;
                        output_valid <= '0';
                        ready <= '1';
                    end if;
                end if;
            else
                ready <= '0';
            end if;
        end if;
        
    end process;

end Behavioral;
