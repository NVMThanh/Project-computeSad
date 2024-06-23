LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Counter IS
    PORT (
        RST : IN STD_LOGIC;
        CLK : IN STD_LOGIC;
        EN  : IN STD_LOGIC;
        CLR : IN STD_LOGIC;  -- Changed Load to CLR for clarity
        COUNT: OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
    );
END Counter;

ARCHITECTURE behavior OF Counter IS
    SIGNAL count_reg : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
    SIGNAL clr_internal : STD_LOGIC := '0';
BEGIN
    PROCESS (CLK, RST)
    BEGIN
        IF RST = '1' THEN
            count_reg <= (OTHERS => '0');
	    clr_internal <= '0';
        ELSIF CLK'event AND CLK = '1' THEN
            IF EN = '1' THEN
                IF clr_internal = '1' THEN
                    count_reg <= (OTHERS => '0');
                    clr_internal <= '0';
                ELSE
                    count_reg <= std_logic_vector(unsigned(count_reg) + 1);
                END IF;
            END IF;
        END IF;
    END PROCESS;
    PROCESS (CLR)
    BEGIN
        IF CLR = '1' THEN
            clr_internal <= '1';
        END IF;
    END PROCESS;

    COUNT <= count_reg;
END behavior;
