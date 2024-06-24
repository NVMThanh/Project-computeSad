LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY controller IS
    PORT (
        COMPARE : IN STD_LOGIC;
        CLK, RST : IN STD_LOGIC;
        START : IN STD_LOGIC;
        Done : OUT STD_LOGIC;
        -- Internal signals for controlling the data path
        EN_count : OUT STD_LOGIC;
        CLR_count : OUT STD_LOGIC;
        Wen3, Wen2, Wen1 : OUT STD_LOGIC;
        Ren1, Ren2, Ren3 : OUT STD_LOGIC
    );
END ENTITY controller;

ARCHITECTURE fsm OF controller IS
    TYPE state_type IS (RESET, SETUP, START_STATE, CALCULATE, COMPARE_STATE, ADD, SUB, LOOPS, FINISH);
    SIGNAL state, next_state : state_type;
    SIGNAL count : INTEGER RANGE 0 TO 15 := 0;
    SIGNAL Done_internal : STD_LOGIC := '0';

BEGIN
    -- State transition process
    PROCESS (CLK, RST)
    BEGIN
        IF RST = '1' THEN
            state <= RESET;
        ELSIF CLK'event AND CLK = '1' THEN
            state <= next_state;
        END IF;
    END PROCESS;

    -- Next state logic process
    PROCESS (state, START, count)
    BEGIN
        CASE state IS
            WHEN RESET =>
                next_state <= SETUP;
            WHEN SETUP =>
                IF START = '1' THEN
                    next_state <= START_STATE;
                ELSE
                    next_state <= SETUP;
                END IF;
            WHEN START_STATE =>
                next_state <= CALCULATE;
            WHEN CALCULATE =>
                next_state <= COMPARE_STATE;
            WHEN COMPARE_STATE =>
                IF COMPARE = '1' THEN
                    next_state <= ADD;
                ELSE
                    next_state <= SUB;
                END IF;
            WHEN ADD =>
                next_state <= LOOPS;
            WHEN SUB =>
                next_state <= LOOPS;
            WHEN LOOPS =>
                IF count = 7 THEN
                    next_state <= FINISH;
                ELSE
                    next_state <= CALCULATE;
                END IF;
            WHEN FINISH =>
                next_state <= RESET;
            WHEN OTHERS =>
                next_state <= RESET;
        END CASE;
    END PROCESS;

    -- Output logic process
    PROCESS (state)
    BEGIN
        -- Default signal values
        Done_internal <= '0';
        EN_count <= '1';
        CLR_count <= '0';
        Wen3 <= '0';
        Wen2 <= '0';
        Wen1 <= '0';
        Ren1 <= '1';
        Ren2 <= '1';
        Ren3 <= '0';

        CASE state IS
            WHEN RESET =>
                Done_internal <= '0';
            WHEN SETUP =>
                Done_internal <= '0';
                Wen1 <= '1';
                Wen2 <= '1';
                Wen3 <= '0';
                Ren3 <= '0';
            WHEN START_STATE =>
                Wen1 <= '1';
                Wen2 <= '1';
                Wen3 <= '1';
                Ren3 <= '1';
                Ren1 <= '1';
                Ren2 <= '1';
                Done_internal <= '0';
            WHEN CALCULATE =>
                Ren1 <= '1';
                Ren2 <= '1';
                Done_internal <= '0';
            WHEN COMPARE_STATE =>
                Ren1 <= '1';
                Ren2 <= '1';
                Done_internal <= '0';
            WHEN ADD =>
                Ren1 <= '1';
                Ren2 <= '1';
                Ren3 <= '1';
                Wen3 <= '1';
                Done_internal <= '0';
            WHEN SUB =>
                EN_count <= '1';
                Ren1 <= '1';
                Ren2 <= '1';
                Ren3 <= '1';
                Wen3 <= '1';
                Done_internal <= '0';
            WHEN LOOPS =>
                Done_internal <= '0';
            WHEN FINISH =>
                Done_internal <= '1';
            WHEN OTHERS =>
                Done_internal <= '0';
        END CASE;
    END PROCESS;

    -- Count process
    PROCESS (CLK, RST)
    BEGIN
        IF RST = '1' THEN
            count <= 0;
        ELSIF CLK'event AND CLK = '1' THEN
            IF state = CALCULATE THEN
                IF count = 8 THEN
                    count <= 0;
                ELSE
                    count <= count + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    Done <= Done_internal;

END ARCHITECTURE fsm;

