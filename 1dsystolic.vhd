LIBRARY ieee;
USE ieee.numeric_std.ALL;
USE IEEE.MATH_REAL.ALL;
USE IEEE.STD_LOGIC_1164.ALL;
PACKAGE type_pkg IS
    TYPE real_matrix IS ARRAY (INTEGER RANGE <>, INTEGER RANGE <>) OF real;
    TYPE real_vector IS ARRAY (INTEGER RANGE <>) OF real;
END PACKAGE type_pkg;
USE work.type_pkg.ALL;

LIBRARY ieee;
USE ieee.numeric_std.ALL;
USE IEEE.MATH_REAL.ALL;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY SystolicArray IS
    GENERIC (
        npe : INTEGER := 4; -- PE's
        wc : INTEGER := 4   --  input array size
    );
    PORT (
        X : IN real_vector(0 TO wc - 1) := (OTHERS => 1.0);
        W : IN real_matrix(0 TO wc - 1, 0 TO npe - 1) := (OTHERS => (OTHERS => 1.0));
        rst : IN STD_LOGIC := '0';
        clk : IN STD_LOGIC;
        start : IN STD_LOGIC := '0';
        Z : OUT real_vector(0 TO npe - 1);
        done : OUT STD_LOGIC := '0';
        pchange : IN STD_LOGIC := '0'
    );
END ENTITY SystolicArray;

ARCHITECTURE behavioral OF SystolicArray IS
    SIGNAL results : real_vector (0 TO npe - 1) := (OTHERS => 0.0);
    SIGNAL x_input, weights_inout, reg_input : real_vector(0 TO npe - 1) := (OTHERS => 0.0);
    SIGNAL cycle_tmp : INTEGER := 0;
    SIGNAL done_tmp : STD_LOGIC := '0';
    COMPONENT PE
        PORT (
            x : IN real;
            y : IN real;
            reg : IN real;
            rst : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            result : OUT real
        );
    END COMPONENT;
BEGIN
    PROCESS (clk)
        VARIABLE delay_tmp : INTEGER := 0;
        VARIABLE index, conut : INTEGER := 0;
        VARIABLE x_input_tmp, weights_inout_tmp, reg_input_tmp : real_vector(0 TO npe - 1) := (OTHERS => 0.0);
    BEGIN
        IF pchange = '1' THEN
            cycle_tmp <= 0;
            done_tmp <= '0';
            reg_input <= (OTHERS => 0.0);
            -- results<=(OTHERS => 0.0);
        ELSE
            IF (done_tmp = '0') AND start = '1' AND conut = 0 THEN
                IF (cycle_tmp <= npe + wc - 2) THEN
                    FOR i IN 0 TO npe - 1 LOOP
                        IF cycle_tmp - i < 0 THEN
                            x_input_tmp(i) := 0.0;
                            weights_inout_tmp(i) := 0.0;
                            reg_input_tmp(i) := 0.0;
                        ELSIF cycle_tmp - i > npe - 1 THEN
                            reg_input_tmp(i) := results(i);
                            x_input_tmp(i) := 0.0;
                            weights_inout_tmp(i) := 0.0;

                        ELSE
                            reg_input_tmp(i) := results(i);
                            index := cycle_tmp - i;
                            x_input_tmp(i) := X(index);
                            weights_inout_tmp(i) := W(index, i);
                        END IF;
                    END LOOP;
                    reg_input <= reg_input_tmp;
                    x_input <= x_input_tmp;
                    weights_inout <= weights_inout_tmp;
                    conut := 1;
                    cycle_tmp <= cycle_tmp + 1;
                ELSE
                    done_tmp <= '1';
                END IF;
            ELSIF conut = 1 THEN
                conut := 0;
            END IF;

        END IF;

    END PROCESS;
    PEI : FOR i IN 0 TO npe - 1 GENERATE
        PE_i : PE PORT MAP(
            x => x_input(i), y => weights_inout(i), reg => reg_input(i), rst => pchange,
            clk => clk, result => results(i));
    END GENERATE PEI;
    done <= done_tmp;
    Z <= results;
END behavioral;