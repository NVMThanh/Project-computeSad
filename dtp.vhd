LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE WORK.sadlib.all;  -- Assuming 'sadlib' library contains necessary components

ENTITY datapath IS
    PORT (
        -- Reset and clock signals
        RST : IN STD_LOGIC;
        CLK : IN STD_LOGIC;
        
        -- Memory control signals
        Wen1, Wen2, Wen3 : IN STD_LOGIC;
        Ren1, Ren2, Ren3 : IN STD_LOGIC;
        Address1, Address2, Address3 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        Din1, Din2 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        -- Memory data output signals
        Dout1, Dout2, Dout3 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        -- Counter control signals
        EN_count, CLR_count_in : IN STD_LOGIC;
        
        -- Counter data output signal
        COUNT : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
        
        -- Output signal to be driven by internal logic
        Din3 : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        -- Additional output for comparison result
        COMPARE : OUT STD_LOGIC
    );
END ENTITY datapath;

ARCHITECTURE structural OF datapath IS
    -- Internal signals for connecting components
    SIGNAL Dout_reg1, Dout_reg2, Dout_reg3 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL count_reg : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL CLR_count : STD_LOGIC;
    SIGNAL START_sig : STD_LOGIC := '0';
    
    -- Internal address signals
    SIGNAL addr1, addr2, addr3 : STD_LOGIC_VECTOR(3 DOWNTO 0);  -- Adjusted to match Address width

    -- New signal for Dout1 - Dout2
    SIGNAL Dout_diff : STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    -- Additional signal for absolute difference calculation
    SIGNAL abs_Dout_diff : STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
    
    -- Clear counter when START signal is inactive
    CLR_count <= '0' WHEN START_sig = '0' ELSE '1';

    -- Assign internal address signals (truncate if needed)
    addr1 <= Address1(3 DOWNTO 0);  -- Ensure correct slicing based on Address width
    addr2 <= Address2(3 DOWNTO 0);
    addr3 <= Address3(3 DOWNTO 0);

    -- Difference and absolute difference calculations
    Dout_diff <= std_logic_vector(signed(Dout_reg1) - signed(Dout_reg2));
    abs_Dout_diff <= std_logic_vector(unsigned(Dout_reg3) + unsigned(Dout_diff)) WHEN signed(Dout_diff) > 0 ELSE std_logic_vector(unsigned(Dout_reg3) - unsigned(Dout_diff));
    COMPARE <= '1' WHEN abs_Dout_diff > "00000000" ELSE '0';  -- Use 'others' for initialization to zero
    
    -- Connect Din3 to Memory 3
    Din3 <= abs_Dout_diff;  -- Directly connect Din3 to this architecture's signal
    
    -- Instantiate Memory 1
    mem1: MEMORY GENERIC MAP (
        INPUT_WIDTH => 8,
        OUTPUT_WIDTH => 8,
        ADDRESS_WIDTH => 4
    )
    PORT MAP (
        RST => RST,
        CLK => CLK,
        Wen => Wen1,
        Ren => Ren1,
        Address => addr1,
        Din => Din1,
        Dout => Dout_reg1
    );

    -- Instantiate Memory 2
    mem2: MEMORY GENERIC MAP (
        INPUT_WIDTH => 8,
        OUTPUT_WIDTH => 8,
        ADDRESS_WIDTH => 4
    )
    PORT MAP (
        RST => RST,
        CLK => CLK,
        Wen => Wen2,
        Ren => Ren2,
        Address => addr2,
        Din => Din2,
        Dout => Dout_reg2
    );

    -- Instantiate Memory 3
    mem3: MEMORY GENERIC MAP (
        INPUT_WIDTH => 8,
        OUTPUT_WIDTH => 8,
        ADDRESS_WIDTH => 4
    )
    PORT MAP (
        RST => RST,
        CLK => CLK,
        Wen => Wen3,
        Ren => Ren3,
        Address => addr3,
        Din => Din3,  -- Connect Din3 directly to this architecture's signal
        Dout => Dout_reg3
    );

    -- Instantiate Counter
    counter_inst: Counter
    PORT MAP (
        RST => RST,
        CLK => CLK,
        EN  => EN_count,
        CLR => CLR_count,
        COUNT => count_reg
    );

    -- Connect output ports of Memory instances to top-level ports
    Dout1 <= Dout_reg1;
    Dout2 <= Dout_reg2;
    Dout3 <= Dout_reg3;

    -- Connect Counter output to top-level port
    COUNT <= count_reg;
    
END structural;

