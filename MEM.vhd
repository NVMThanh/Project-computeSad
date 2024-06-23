LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY MEMORY IS
    GENERIC ( 
        INPUT_WIDTH : integer := 8;
        OUTPUT_WIDTH : integer := 8;
        ADDRESS_WIDTH : integer := 4
    );
    PORT(
        RST      : IN STD_LOGIC;
        CLK      : IN STD_LOGIC;
        Wen      : IN STD_LOGIC;
        Ren      : IN STD_LOGIC;
        Address  : IN STD_LOGIC_VECTOR(ADDRESS_WIDTH-1 DOWNTO 0);
        Din      : IN STD_LOGIC_VECTOR(INPUT_WIDTH-1 DOWNTO 0);
        Dout     : OUT STD_LOGIC_VECTOR(OUTPUT_WIDTH-1 DOWNTO 0)
    );
END MEMORY;

ARCHITECTURE behavior OF MEMORY IS
    -- Define the memory array
    TYPE mem_array IS ARRAY (0 TO 2**ADDRESS_WIDTH-1) OF STD_LOGIC_VECTOR(INPUT_WIDTH-1 DOWNTO 0);
    SIGNAL memory : mem_array := (OTHERS => (OTHERS => '0'));

    -- Signal to hold read data
    SIGNAL Dout_reg : STD_LOGIC_VECTOR(OUTPUT_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
BEGIN
    -- Process for synchronous read and write operations
    PROCESS (CLK)
    BEGIN
        IF CLK'event AND CLK = '1' THEN
            IF RST = '1' THEN
                Dout_reg <= (OTHERS => '0');
            ELSE
                -- Write operation
                IF Wen = '1' THEN
                    memory(to_integer(unsigned(Address))) <= Din;
                END IF;
                -- Read operation
                IF Ren = '1' THEN
                    Dout_reg <= memory(to_integer(unsigned(Address)));
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Output read data
    Dout <= Dout_reg;

END behavior;
