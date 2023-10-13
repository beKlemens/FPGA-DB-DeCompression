----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.08.2023 15:20:22
-- Design Name: 
-- Module Name: HuffmanDecoder - Behavioral
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity HuffmanDecoder is
    generic (
        DATA_INPUT_SIZE : positive := 32; --max number coding bits used
        DATA_OUTPUT_SIZE : positive := 8;
        SLIDING_WINDOW_SIZE : positive := 4
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        input_valid : in std_logic;
        next_one_ready : in std_logic;
        input_data : in std_logic_vector(DATA_INPUT_SIZE-1 downto 0);
        output_data : out std_logic_vector(DATA_OUTPUT_SIZE-1 downto 0);
        output_valid : out std_logic;
        ready : out std_logic
    );
end HuffmanDecoder;

architecture Behavioral of HuffmanDecoder is
    signal compressed_data : std_logic_vector(DATA_INPUT_SIZE-1 downto 0);
    signal input_code : std_logic_vector(SLIDING_WINDOW_SIZE-1 downto 0);
    signal output_level : std_logic_vector(4 downto 0) := (others => '0');
    signal is_decoding : boolean := false;
    
    -- Component declaration for HuffmanStaticCode
    component HuffmanCode is
        port (
            input_code : in std_logic_vector(SLIDING_WINDOW_SIZE-1 downto 0);
            output_symbol : out std_logic_vector(7 downto 0);
            output_level : out std_logic_vector(4 downto 0)
        );
    end component HuffmanCode;
    
begin

    HuffmanStaticCode : HuffmanCode
        port map (
          input_code => input_code,
          output_symbol => output_data,
          output_level => output_level
        );

    process (reset, clk)
        variable position :  integer;
        variable shiftPosition : boolean := false;
        variable setBuffer : boolean := false;
        variable restBitBuffer : std_logic_vector(SLIDING_WINDOW_SIZE-1 downto 0);
    begin
        if reset = '1' then
            output_valid <= '0';
            position := DATA_INPUT_SIZE-1;
            restBitBuffer := (others => '0');
            shiftPosition := false;
            setBuffer := false;
            is_decoding <= false;
            ready <= '1';
        elsif rising_edge(clk) then
            if input_valid = '1' then
                compressed_data <= input_data; --save new input
                is_decoding <= true;
                ready <= '0';
            end if;
                        
            if is_decoding = true and next_one_ready='1' then
                if shiftPosition = true then
                     position := position - to_integer(unsigned(output_level));
                end if;

                if position >= SLIDING_WINDOW_SIZE-1 then --normal sliding in input vector               
                    input_code <= std_logic_vector(resize(unsigned(compressed_data(position downto position - (SLIDING_WINDOW_SIZE-1))), input_code'length));
                    output_valid <= '1';
                    shiftPosition := true; --activate buffer to store rest bits
                    setBuffer := true;
                else --reached end of input vector -> write to buffer and switch to new input
                    if setBuffer = true then
                        restBitBuffer(position downto 0) := compressed_data(position downto 0); -- set rest bits in buffer
                        setBuffer := false;
                        shiftPosition := false;
                        is_decoding <= false;
                        output_valid <= '0';
                        ready <= '1'; --read new value
                    else --handle buffer
                        if position >= 0 then -- buffer is not empty
                            input_code <= std_logic_vector(resize(unsigned(restBitBuffer(position downto 0) & compressed_data(DATA_INPUT_SIZE -1 downto DATA_INPUT_SIZE - (SLIDING_WINDOW_SIZE-1 - position))), input_code'length));
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
