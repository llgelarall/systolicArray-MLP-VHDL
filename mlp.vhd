USE work.type_pkg.ALL;
LIBRARY IEEE;
USE ieee.numeric_std.ALL;
USE IEEE.MATH_REAL.ALL;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY neural_network IS
    GENERIC (
        n : NATURAL := 8
    );
    PORT (
        rst : IN STD_LOGIC := '0';
        clk : IN STD_LOGIC
    );
END neural_network;

ARCHITECTURE Behavioral OF neural_network IS
    SIGNAL initDone : INTEGER := 0;
    SIGNAL W1_main : real_matrix(0 TO 3, 0 TO 3) := ((-0.1385, -1.3722, 0.8025, 0.7169),
    (-1.5812, -0.6739, -1.0537, -0.4472),
    (0.6813, -0.8171, 2.4749, 1.9919),
    (1.5548, 0.9509, 0.1667, 0.3937));
    SIGNAL W2_main : real_matrix(0 TO 3, 0 TO 3) := ((-0.3875, -0.3182, -0.2720, -0.4756),
    (2.4344, -2.0315, -1.6956, 1.3998),
    (1.0618, -0.2194, 2.4020, -1.2807),
    (0.0937, -0.4450, -0.3804, -0.1862));
    SIGNAL W3_main : real_matrix(0 TO 2, 0 TO 3) := ((-0.4503, -0.1903, -1.9133, 0.3772),
    (-0.1165, 3.3349, -0.2748, 0.2483),
    (-0.1752, -1.9774, 2.4156, 0.1991));
    SIGNAL b1_main : real_vector(0 TO 3) := (2.1684, 0.7884, -0.6250, -0.5770);
    SIGNAL b2_main : real_vector(0 TO 3) := (-0.0456, 0.4548, -0.6798, -0.1712);
    SIGNAL b3_main : real_vector(0 TO 2) := (4.9059, -1.7162, -3.0999);
    SIGNAL X_test_reshape : real_matrix(0 TO 14, 0 TO 3);
    SIGNAL X_test : real_matrix(0 TO 14, 0 TO 3) :=
    ((-1.5065, 0.7888, -1.3402, -1.1838),
    (-1.5065, 0.0982, -1.2834, -1.3154),
    (-0.1737, -1.2830, 0.7059, 1.0539),
    (-1.2642, -0.1320, -1.3402, -1.4471),
    (-1.2642, 0.7888, -1.0560, -1.3154),
    (1.6438, -0.1320, 1.1606, 0.5274),
    (-1.0218, -0.1320, -1.2266, -1.3154),
    (1.0380, -1.2830, 1.1606, 0.7907),
    (0.6745, -0.5924, 1.0469, 1.1856),
    (-1.2642, -0.1320, -1.3402, -1.1838),
    (-0.6583, 1.4794, -1.2834, -1.3154),
    (-1.7489, 0.3284, -1.3971, -1.3154),
    (-1.0218, 0.3284, -1.4539, -1.3154),
    (-0.5372, 1.9398, -1.1697, -1.0522),
    (0.1898, 0.7888, 0.4217, 0.5274));
    SIGNAL X_Row : real_vector(0 TO 3) := (OTHERS => 0.0);
    SIGNAL Y_test : real_vector(0 TO 14) := (0.0, 0.0, 2.0, 0.0, 0.0, 2.0, 0.0, 2.0, 2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0);
    SIGNAL Final : real_vector(0 TO 14);
    SIGNAL mcorrect, p : INTEGER := 0;
    SIGNAL doneL1, doneL2, doneL3, SL2, SL3, doneL1R, doneL2R, doneL3R, finalDone, pchange : STD_LOGIC := '0';
    SIGNAL W1 : real_matrix(0 TO 3, 0 TO 3) := W1_main;
    SIGNAL W2 : real_matrix(0 TO 3, 0 TO 3) := W2_main;
    SIGNAL W3 : real_matrix(0 TO 3, 0 TO 2);
    SIGNAL b1, b2 : real_vector(0 TO 3) := b1_main;
    SIGNAL b3 : real_vector(0 TO 2) := b3_main;
    SIGNAL Z1F, h1F, Z2F, h2F : real_vector(0 TO 3) := (OTHERS => 0.0);
    SIGNAL Z3F : real_vector(0 TO 2) := (OTHERS => 0.0);
    SIGNAL h3F : real_vector(0 TO 2) := (OTHERS => 0.0);
    COMPONENT SystolicArray IS
        GENERIC (
            npe : INTEGER;
            wc : INTEGER
        );
        PORT (
            X : IN real_vector(0 TO wc - 1);
            W : IN real_matrix(0 TO wc - 1, 0 TO npe - 1);
            rst : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            start : IN STD_LOGIC;
            Z : OUT real_vector(0 TO npe - 1);
            done : OUT STD_LOGIC;
            pchange : IN STD_LOGIC
        );
    END COMPONENT;

    -- relu function implementation
    FUNCTION relu(x : real) RETURN real IS
    BEGIN
        IF x <= 0.0 THEN
            RETURN 0.0;
        ELSE
            RETURN x;
        END IF;
    END relu;
BEGIN
    --Forward Propagation
    PROCESS (rst, clk)
        VARIABLE test_out : real_vector(0 TO 14);
        VARIABLE correct, conut : INTEGER := 0;
        VARIABLE Z1FF, Z2FF : real_vector(0 TO 3) := (OTHERS => 0.0);
        VARIABLE Z3FF : real_vector(0 TO 2) := (OTHERS => 0.0);
        VARIABLE h3F_tmp : real_vector(0 TO 2) := (OTHERS => 0.0);
        VARIABLE h1F_tmp, h2F_tmp : real_vector(0 TO 3) := (OTHERS => 0.0);
        VARIABLE Z3F_tmp : real_vector(0 TO 2) := (OTHERS => 0.0);
    BEGIN
        IF pchange = '1' THEN
            doneL1R <= '0';
            doneL2R <= '0';
            doneL3R <= '0';
            SL2 <= '0';
            SL3 <= '0';
            pchange <= '0';
            IF h3F_tmp(0) >= h3F_tmp(1) AND h3F_tmp(0) >= h3F_tmp(2) THEN
                test_out(p) := 0.0;
            END IF;
            IF h3F_tmp(1) >= h3F_tmp(0) AND h3F_tmp(1) >= h3F_tmp(2) THEN
                test_out(p) := 1.0;
            END IF;
            IF h3F_tmp(2) >= h3F_tmp(0) AND h3F_tmp(2) >= h3F_tmp(1) THEN
                test_out(p) := 2.0;
            END IF;
            IF Y_test(p) = test_out(p) THEN
                correct := correct + 1;
            END IF;
            Final(p) <= test_out(p);
            p <= p + 1;
        ELSE
            IF initDone = 0 THEN
                initDone <= 1;
                FOR i IN 0 TO 3 LOOP
                    FOR j IN 0 TO 3 LOOP
                        W1(i, j) <= W1_main(j, i);
                        W2(i, j) <= W2_main(j, i);
                    END LOOP;
                END LOOP;
                FOR i IN 0 TO 3 LOOP
                    FOR j IN 0 TO 2 LOOP
                        W3(i, j) <= W3_main(j, i);
                    END LOOP;
                END LOOP;
            ELSE
                IF p < 15 AND conut = 0 THEN
                    conut := 1;
                    X_Row <= (X_test(p, 0), X_test(p, 1), X_test(p, 2), X_test(p, 3));
                    --Forward-firstlayer
                    IF doneL1 = '1' THEN
                        FOR i IN 0 TO 3 LOOP
                            -- Z1F(i) := W1(0, i) * X_test(p, 0) + W1(1, i) * X_Test(p, 1) + W1(2, i) * X_test(p, 2) + W1(3, i) * X_test(p, 3) + b1(i);
                            Z1FF(i) := Z1F(i) + b1(i);
                            IF Z1FF(i) < 0.0 THEN
                                h1F_tmp(i) := 0.0;
                            ELSE
                                h1F_tmp(i) := Z1FF(i);
                            END IF;
                            h1F(i) <= h1F_tmp(i);
                        END LOOP;
                        doneL1R <= '1';
                        SL2 <= '1';
                    END IF;

                    --Forward-secondlayer
                    IF doneL2 = '1' AND doneL1R = '1' THEN
                        FOR i IN 0 TO 3 LOOP
                            -- Z2F(i) := W2(0, i) * h1F(0) + W2(1, i) * h1F(1) + W2(2, i) * h1F(2) + W1(3, i) * h1F(3) + b2(i);
                            Z2FF(i) := Z2F(i) + b2(i);
                            IF Z2FF(i) < 0.0 THEN
                                h2F_tmp(i) := 0.0;
                            ELSE
                                h2F_tmp(i) := Z2FF(i);
                            END IF;
                            h2F(i) <= h2F_tmp(i);
                            -- h2F(i) <= relu(Z2FF(i));
                        END LOOP;
                        doneL2R <= '1';
                        SL3 <= '1';
                    END IF;
                    --Forward-thirdlayer
                    IF doneL3 = '1' AND doneL2R = '1' THEN
                        FOR i IN 0 TO 2 LOOP
                            -- Z3F(i) := W3(0, i) * h2F(0) + W3(1, i) * h2F(1) + W3(2, i) * h2F(2) + W3(3, i) * h2F(3) + b3(i);
                            Z3FF(i) := Z3F(i) + b3(i);
                            IF Z3FF(i) < 0.0 THEN
                                h3F_tmp(i) := 0.0;
                            ELSE
                                h3F_tmp(i) := Z3FF(i);
                            END IF;
                            -- h3F_tmp(i) := relu(Z3FF(i));
                            h3F(i) <= h3F_tmp(i);
                        END LOOP;
                        doneL3R <= '1';

                        pchange <= '1';
                    END IF;
                ELSIF conut = 1 AND p < 15 THEN
                    conut := 0;
                ELSE
                    finalDone <= '1';
                    Final <= test_out;
                END IF;
            END IF;
        END IF;
        mcorrect <= correct;
    END PROCESS;
    layer1 : SystolicArray GENERIC MAP(
        npe => 4,
        wc => 4
    )
    PORT MAP(
        X => X_Row,
        W => W1,
        rst => rst,
        clk => clk,
        start => '1',
        Z => Z1F,
        done => doneL1,
        pchange => pchange
    );
    layer2 : SystolicArray GENERIC MAP(
        npe => 4,
        wc => 4
    )
    PORT MAP(
        X => h1F,
        W => W2,
        rst => rst,
        clk => clk,
        start => SL2,
        Z => Z2F,
        done => doneL2,
        pchange => pchange
    );
    layer3 : SystolicArray GENERIC MAP(
        npe => 3,
        wc => 4)
    PORT MAP(
        X => h2F,
        W => W3,
        rst => rst,
        clk => clk,
        start => SL3,
        Z => Z3F,
        done => doneL3,
        pchange => pchange);
END Behavioral;