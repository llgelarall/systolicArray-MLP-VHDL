LIBRARY ieee;
USE ieee.numeric_std.ALL;
USE IEEE.MATH_REAL.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY PE IS
    PORT (
        x : IN real := 0.0;
        y : IN real := 0.0;
        reg : IN real := 0.0;
        rst : IN STD_LOGIC := '0';
        clk : IN STD_LOGIC;
        result : OUT real := 0.0
    );
END ENTITY PE;

ARCHITECTURE behavioral OF PE IS
BEGIN
    PROCESS (clk)
    BEGIN
        IF rst = '1' THEN
            result <= 0.0;
        ELSIF rst = '0' THEN
            result <= (x * y) + reg;
        END IF;
    END PROCESS;
END ARCHITECTURE behavioral;