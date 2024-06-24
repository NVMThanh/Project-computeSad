LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY sad IS
    PORT (
        CLK, RST, START: IN STD_LOGIC;
        Wen1, Wen2, Wen3: OUT STD_LOGIC;
        Din1, Din2 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        done : OUT STD_LOGIC;
	Dout3 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	COUNT : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
    );
END ENTITY sad;

ARCHITECTURE rtl OF sad IS
    -- Internal signals to connect datapart and controller
    SIGNAL Ren1, Ren2, Ren3 : STD_LOGIC;
    SIGNAL Address1, Address2, Address3 : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL Dout1, Dout2: STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL EN_count, CLR_count_in : STD_LOGIC;
    SIGNAL Din3 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL COMPARE : STD_LOGIC;
    SIGNAL Done_internal : STD_LOGIC;
    
    -- Internal write enable signals for internal control
    SIGNAL internal_Wen1, internal_Wen2, internal_Wen3 : STD_LOGIC;

BEGIN
    -- Instantiate datapart
    data_unit : ENTITY work.datapath
    PORT MAP(
        -- Reset and clock signals
        RST => RST,
        CLK => CLK,
        
        -- Memory control signals
        Wen1 => internal_Wen1,
        Wen2 => internal_Wen2,
        Wen3 => internal_Wen3,
        Ren1 => Ren1,
        Ren2 => Ren2,
        Ren3 => Ren3,
        Address1 => Address1,
        Address2 => Address2,
        Address3 => Address3,
        Din1 => Din1,
        Din2 => Din2,
        
        -- Memory data output signals
        Dout1 => Dout1,
        Dout2 => Dout2,
        Dout3 => Dout3,
        
        -- Counter control signals
        EN_count => EN_count,
        CLR_count_in => CLR_count_in,
        
        -- Counter data output signal
        COUNT => COUNT,
        
        -- Output signal to be driven by internal logic
        Din3 => Din3,
        
        -- Additional output for comparison result
        COMPARE => COMPARE
    );

    -- Instantiate controller
    control_unit : ENTITY work.controller
    PORT MAP(
        COMPARE => COMPARE,
        CLK => CLK,
        RST => RST,
        START => START,
        Done => Done_internal,
        -- Internal signals for controlling the data path
        EN_count => EN_count,
        CLR_count => CLR_count_in,
        Wen3 => internal_Wen3,
        Wen2 => internal_Wen2,
        Wen1 => internal_Wen1,
        Ren1 => Ren1,
        Ren2 => Ren2,
        Ren3 => Ren3
    );
    
    -- Connect done signal
    done <= Done_internal;
    
    -- Connect internal write enable signals to top-level ports
    Wen1 <= internal_Wen1;
    Wen2 <= internal_Wen2;
    Wen3 <= internal_Wen3;

END ARCHITECTURE rtl;

