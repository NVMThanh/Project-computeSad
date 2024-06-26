library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sadlib.all;

entity sad_tb is
end entity sad_tb;

architecture behavior of sad_tb is
    constant input_w : integer := 8;
    constant output_w : integer := 8;
    constant addr_w : integer := 4;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal start : std_logic := '0';
    signal done : std_logic := '0';
    signal wen1, wen2, wen3 : std_logic := '0';
    signal din1, din2 ,dout3: std_logic_vector(input_w - 1 downto 0) := (others => '0');
    signal COUNT: STD_LOGIC_VECTOR(4 DOWNTO 0);

    constant CLK_PERIOD : time := 100 ns;
begin
    -- Instantiate the SAD unit
    SAD_unit : entity work.sad
        port map(
            CLK => clk,
            RST => rst,
            START => start,
            Wen1 => wen1,
            Wen2 => wen2,
            Wen3 => wen3,
            Din1 => din1,
            Din2 => din2,
	    Dout3 => dout3,
            done => done
        );

    -- Clock generation process
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2 ;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Simulation process
    simulation : process
    begin
        -- Initialize reset
        rst <= '1';
        wait for 2 * CLK_PERIOD;
        rst <= '0';
        wait for CLK_PERIOD;

        -- Load data into memory
        wen1 <= '1'; 
	wen2 <= '1'; 
	wen3 <= '0';
        din1 <= std_logic_vector(to_unsigned(10, input_w));
        din2 <= std_logic_vector(to_unsigned(2, input_w));
        wait for CLK_PERIOD;

        din1 <= std_logic_vector(to_unsigned(9, input_w));
        din2 <= std_logic_vector(to_signed(7, input_w));
        wait for CLK_PERIOD;

        din1 <= std_logic_vector(to_unsigned(5, input_w));
        din2 <= std_logic_vector(to_unsigned(2, input_w));
        wait for CLK_PERIOD;

        din1 <= std_logic_vector(to_signed(8, input_w));
        din2 <= std_logic_vector(to_unsigned(2, input_w));
        wait for CLK_PERIOD;

        din1 <= std_logic_vector(to_signed(14, input_w));
        din2 <= std_logic_vector(to_signed(1, input_w));
        wait for CLK_PERIOD;

        din1 <= std_logic_vector(to_unsigned(1, input_w));
        din2 <= std_logic_vector(to_unsigned(10, input_w));
        wait for CLK_PERIOD;
	start <= '1';
	wen1 <= '0'; 
	wen2 <= '0'; 
	wen3 <= '1';
	wait for CLK_PERIOD;
   
        -- Wait for the done signal
        wait until done = '1';

        -- Simulation complete
        wait;
    end process;
end architecture behavior;

