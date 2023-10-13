----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.07.2023 12:00:47
-- Design Name: 
-- Module Name: BitpackingDecoder - Behavioral
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

entity UnsignedBitpackingDecoder is
    generic (
        DATA_INPUT_SIZE : positive := 32; --max number coding bits used
        DATA_OUTPUT_SIZE : positive := 32
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        next_one_ready : in std_logic;
        input_valid : in std_logic;
        input_data : in std_logic_vector(DATA_INPUT_SIZE-1 downto 0);
        sliding_window_size : in std_logic_vector(5 downto 0);
        output_data : out std_logic_vector(DATA_OUTPUT_SIZE-1 downto 0);
        output_valid : out std_logic;
        ready : out std_logic
    );
end UnsignedBitpackingDecoder;

architecture Behavioral of UnsignedBitpackingDecoder is
    signal is_decoding : boolean := false;
begin

    process (reset, clk)
        variable position :  integer;
        variable shiftPosition : boolean := false;
        variable setBuffer : boolean := false;
        variable restBitBuffer : std_logic_vector(DATA_INPUT_SIZE-1 downto 0);
        variable current_Input : std_logic_vector(DATA_INPUT_SIZE-1 downto 0);
        variable tmp_twos_complement : std_logic_vector(DATA_INPUT_SIZE-1 downto 0);
    begin
         if reset = '1' then
            output_valid <= '0';
            position := DATA_INPUT_SIZE-1;
            restBitBuffer := (others => '0');
            shiftPosition := false;
            setBuffer := false;
            ready <= '1';
        elsif rising_edge(clk) then
            if input_valid = '1' then
                current_Input := input_data; --save new input
                is_decoding <= true;
                ready <= '0';
            end if;
                        
            if is_decoding = true and next_one_ready = '1' then -- und der folgende ready ist
                if shiftPosition = true then
                     position := position - to_integer(unsigned(sliding_window_size)); --SLIDING_WINDOW_SIZE;
                end if;

                if position >= to_integer(unsigned(sliding_window_size))-1 then --normal sliding in input vector
                    output_data <= std_logic_vector(resize(unsigned(current_Input(position downto position - (to_integer(unsigned(sliding_window_size))-1))), output_data'length));
                    output_valid <= '1';
                    shiftPosition := true; --activate buffer to store rest bits
                    setBuffer := true;
                else --reached end of input vector -> write to buffer and switch to new input
                    if setBuffer = true then
                        restBitBuffer(position downto 0) := current_Input(position downto 0); -- set rest bits in buffer
                        setBuffer := false;
                        shiftPosition := false;
                        is_decoding <= false;
                        output_valid <= '0';
                        ready <= '1';
                    else --handle buffer
                        if position >= 0 then -- buffer is not empty
                            output_data <= std_logic_vector(resize(unsigned(restBitBuffer & current_Input(DATA_INPUT_SIZE -1 downto DATA_INPUT_SIZE - (to_integer(unsigned(sliding_window_size))-1 - position))), output_data'length));
                            shiftPosition := true;
                            output_valid <= '1';
                            ready <= '0';
                        else -- buffer empty and go on with normal input data
                            position := DATA_INPUT_SIZE - abs(position);
                            output_valid <= '0';
                            shiftPosition := false;
                            ready <= '0';
                        end if;
                    end if;
                end if;   
             end if;
        end if;
    end process;
end Behavioral;
