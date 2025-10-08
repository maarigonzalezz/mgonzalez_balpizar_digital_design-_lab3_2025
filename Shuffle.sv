module Shuffle (
    input  logic        clk,
    input  logic        rst,
    input  logic        start,
    input  logic [7:0]  seed,
    output logic [4:0]  arr_cards [0:15],
    output logic        done
);

    // ------------------------------------------------------
    // Variables internas
    // ------------------------------------------------------
    logic [2:0] pool_comb[0:15]; 
    logic running;
    logic [7:0] rand_val;

    // ------------------------------------------------------
    // Shuffle combinacional (solo genera pool)
    // ------------------------------------------------------
    always_comb begin
        logic [2:0] tmp;
        integer i, j;
        logic [2:0] symbols_pool[0:15];

        // Inicializar pool
        for (i = 0; i < 8; i++) begin
            symbols_pool[2*i]   = i[2:0];
            symbols_pool[2*i+1] = i[2:0];
        end

        rand_val = seed;

        for (i = 15; i > 0; i = i - 1) begin
            rand_val = {rand_val[6:0], rand_val[7] ^ rand_val[5] ^ rand_val[4] ^ rand_val[3]};
            j = rand_val % (i+1);

            // Swap
            tmp = symbols_pool[i];
            symbols_pool[i] = symbols_pool[j];
            symbols_pool[j] = tmp;
        end

        // Asignación combinacional a pool_comb
        for (i = 0; i < 16; i++)
            pool_comb[i] = symbols_pool[i];
    end

    // ------------------------------------------------------
    // Registro de salida y done
    // ------------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        integer k; // usar local
        if (rst) begin
            running <= 0;
            done    <= 0;
            for (k = 0; k < 16; k++)
                arr_cards[k] <= 0;
        end else begin
            if (start && !running) begin
                running <= 1;
                done    <= 0;
            end

            if (running) begin
                // Copiar combinacional a salida registrada
                for (k = 0; k < 16; k++)
                    arr_cards[k] <= {pool_comb[k], 2'b00};

                done    <= 1;
                running <= 0;
            end
        end
    end

endmodule

