module mostrar_carta_random (
    input  logic       clk,
    input  logic       rst,
    input  logic       start,
    input  logic [7:0] seed,
    input  logic [4:0] arr_cards_in [0:15],
    output logic [4:0] arr_cards_out [0:15],
    output logic       done
);

    // ------------------------------------------------------
    // Variables internas
    // ------------------------------------------------------
    logic [4:0] pool_comb[0:15]; 
    logic running;
    logic [7:0] rand_val;
	 logic [1:0] max_to_change;

    // ------------------------------------------------------
    // Lógica combinacional: decide qué cartas 00 → 10
    // ------------------------------------------------------
    always_comb begin
        logic [4:0] temp[0:15];
        integer count_01, changed, idx;
        integer i, iter; // locales al bloque

        // Copiar entrada
        for (i = 0; i < 16; i++)
            temp[i] = arr_cards_in[i];

        // Contar cartas con estado 01
        count_01 = 0;
        for (i = 0; i < 16; i++)
            if (temp[i][1:0] == 2'b01)
                count_01 = count_01 + 1;

        // Inicializar pseudoaleatorio
        changed = 0;
        rand_val = seed;

			// Determinar cuántas cartas 00 debemos cambiar según el número de 01 presentes

			if (count_01 == 0)
				 max_to_change = 2;  // Si no hay cartas 01, cambiar 2 cartas 00
			else if (count_01 == 1)
				 max_to_change = 1;  // Si hay 1 carta 01, cambiar solo 1 carta 00
			else
				 max_to_change = 0;  // Si hay 2 o más cartas 01, no cambiar ninguna

			// Selección pseudoaleatoria de cartas 00 a convertir en 01
			changed = 0;
			for (iter = 0; iter < 16 && changed < max_to_change; iter++) begin
				 idx = rand_val % 16;  // índice pseudoaleatorio usando LFSR

				 if (temp[idx][1:0] == 2'b00) begin
					  temp[idx][1:0] = 2'b01;  // cambiar estado de la carta
					  changed = changed + 1;
				 end

				 // Generar siguiente valor pseudoaleatorio usando LFSR
				 rand_val = {rand_val[6:0], rand_val[7] ^ rand_val[5] ^ rand_val[4] ^ rand_val[3]};
			end

        // Asignar combinacional a pool
        for (i = 0; i < 16; i++)
            pool_comb[i] = temp[i];
    end

    // ------------------------------------------------------
    // Registro de salida y done
    // ------------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        integer i; // local al bloque
        if (rst) begin
            running <= 0;
            done    <= 0;
            for (i = 0; i < 16; i++)
                arr_cards_out[i] <= 0;
        end else begin
            if (start && !running) begin
                running <= 1;
                done    <= 0;
            end

            if (running) begin
                // Registrar salida combinacional
                for (i = 0; i < 16; i++)
                    arr_cards_out[i] <= pool_comb[i];

                done    <= 1;
                running <= 0;
            end
        end
    end

endmodule