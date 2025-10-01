module FSM(
    input  logic        m,                     // Pulso de acción
    input  logic        rst,                   // Señal de reset
    input  logic        clk,                   // Reloj principal
    input  logic [1:0]  cartas_seleccionadas,  // Cartas seleccionadas por el jugador
    output logic [7:0]  estado                 // Salida de estado para visualización
);

    // -------------------------
    // Registros internos
    // -------------------------
    logic [4:0] state, next_state;            // Estado actual y siguiente
    logic [7:0] mCounter;                     // Contador del estado inicial
    logic [4:0] contador_tiempo;             // Solo registro hueco
    logic [2:0] j1_num_parejas;
    logic [2:0] j2_num_parejas;
    logic [2:0] puntaje_j1;
    logic [2:0] puntaje_j2;
    logic jugador_1_tiene_pareja;
    logic jugador_2_tiene_pareja;
    logic [1:0] cartas_seleccionadas_reg;
    logic mostrar_carta;

    // -------------------------
    // Secuencial: registros y estado
    // -------------------------
    always_ff @(posedge clk or posedge rst) begin
	
        if (rst) begin
            state <= 5'b00000;
            mCounter <= 0;
            j1_num_parejas <= 0;
            j2_num_parejas <= 0;
            puntaje_j1 <= 0;
            puntaje_j2 <= 0;
            jugador_1_tiene_pareja <= 0;
            jugador_2_tiene_pareja <= 0;
            contador_tiempo <= 0;
            cartas_seleccionadas_reg <= 0;
            mostrar_carta <= 0;
        end
		  else begin
		  		// Incrementar contador de tiempo hasta el máximo
				if (contador_tiempo < 31) begin
            contador_tiempo <= contador_tiempo + 1;
					end
		  
            // Actualización de registros según estado
            case(state)
                5'b00111: if (jugador_1_tiene_pareja) begin
                    j1_num_parejas <= j1_num_parejas + 1;
                    puntaje_j1 <= puntaje_j1 + 1;
                    jugador_1_tiene_pareja <= 0;
                    cartas_seleccionadas_reg <= 0;
                end
                5'b01000: cartas_seleccionadas_reg <= cartas_seleccionadas_reg + 1;

                5'b01011: if (jugador_2_tiene_pareja) begin
                    j2_num_parejas <= j2_num_parejas + 1;
                    puntaje_j2 <= puntaje_j2 + 1;
                    jugador_2_tiene_pareja <= 0;
                    cartas_seleccionadas_reg <= 0;
                end
                5'b01100: cartas_seleccionadas_reg <= cartas_seleccionadas_reg + 1;
            endcase

            // Salida para visualización
            estado <= mCounter;

            // Actualización del estado
            if (!mostrar_carta)
                state <= next_state;

            // Contador del estado inicial
            if (state == 5'b00001)
                mCounter <= mCounter + 1;
        end
    end

    // -------------------------
    // Combinacional: siguiente estado
    // -------------------------
    always_comb begin
        next_state = state;

        case(state)
            5'b00000: if (m) next_state = 5'b00001;
            5'b00001: if (m) next_state = 5'b00010;
            5'b00010: if (m) next_state = 5'b00011;
            5'b00011: if (m) next_state = 5'b00100;
            5'b00100: if (m) next_state = 5'b00101;

            5'b00101: begin
                if (contador_tiempo >= 16 && cartas_seleccionadas == 2'b00)
                    next_state = 5'b01000;
                else if (cartas_seleccionadas == 2'b01)
                    next_state = 5'b00110;
                else
                    next_state = 5'b00101;
            end

            5'b00110: begin
                if (contador_tiempo >= 16 && cartas_seleccionadas == 2'b00)
                    next_state = 5'b01000;
                else if (cartas_seleccionadas == 2'b10)
                    next_state = 5'b00111;
                else
                    next_state = 5'b00110;
            end

            5'b00111: begin
                if (jugador_1_tiene_pareja) begin
                    if ((j1_num_parejas + j2_num_parejas) == 8)
                        next_state = 5'b01101;
                    else
                        next_state = 5'b00101;
                end else
                    next_state = 5'b01001;
            end

            5'b01000: begin
                if (cartas_seleccionadas == 2'b00)
                    next_state = 5'b00110;
                else if (cartas_seleccionadas == 2'b01)
                    next_state = 5'b00111;
                else
                    next_state = 5'b01000;
            end

            5'b01001: begin
                if (contador_tiempo >= 16 && cartas_seleccionadas == 2'b00)
                    next_state = 5'b01100;
                else if (cartas_seleccionadas == 2'b01)
                    next_state = 5'b01010;
                else
                    next_state = 5'b01001;
            end

            5'b01010: begin
                if (contador_tiempo >= 16 && cartas_seleccionadas == 2'b00)
                    next_state = 5'b01100;
                else if (cartas_seleccionadas == 2'b10)
                    next_state = 5'b01011;
                else
                    next_state = 5'b01010;
            end

            5'b01011: begin
                if (jugador_2_tiene_pareja) begin
                    if ((j1_num_parejas + j2_num_parejas) == 8)
                        next_state = 5'b01101;
                    else
                        next_state = 5'b01001;
                end else
                    next_state = 5'b00101;
            end

            5'b01100: begin
                if (cartas_seleccionadas == 2'b00)
                    next_state = 5'b01010;
                else if (cartas_seleccionadas == 2'b01)
                    next_state = 5'b01011;
                else
                    next_state = 5'b01100;
            end

            5'b01101: begin
                if (puntaje_j1 > puntaje_j2)
                    next_state = 5'b01110;
                else if (puntaje_j1 < puntaje_j2)
                    next_state = 5'b01111;
                else
                    next_state = 5'b10000;
            end

            5'b01110, 5'b01111, 5'b10000: next_state = 5'b10001;
            5'b10001: next_state = 5'b00000;

            default: next_state = 5'b00000;
        endcase
    end

endmodule
