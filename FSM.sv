// ================================================
// FSM para el juego de cartas (Memory Game)
// ================================================

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
    logic t0;                                 // Señal de sincronización del clkCounter
    logic [7:0] mCounter;                     // Contador del estado inicial
    logic [3:0] contador_tiempo;             // Contador de tiempo 0-15
    logic pulse_segundo;                      // Pulso de 1 segundo
    logic [2:0] j1_num_parejas;              // Número de parejas jugador 1
    logic [2:0] j2_num_parejas;              // Número de parejas jugador 2
    logic [2:0] puntaje_j1;                  // Puntaje jugador 1
    logic [2:0] puntaje_j2;                  // Puntaje jugador 2
    logic jugador_1_tiene_pareja;            // Indica si jugador 1 encontró pareja
    logic jugador_2_tiene_pareja;            // Indica si jugador 2 encontró pareja
    logic [1:0] cartas_seleccionadas_reg;    // Registro interno de cartas seleccionadas

    // -------------------------
    // Instancias de módulos auxiliares
    // -------------------------
    clk_counter_seg #(
        .CLOCK_FREQ_HZ(50_000_000)
    ) contador_segundos (
        .clk(clk),
        .rst(rst),
        .pulse_1s(pulse_segundo)
    );

    clkCounter counter(
        .clk(clk),
        .rst(rst),
        .t0(t0)
    );

    // -------------------------
    // Lógica secuencial: registros y estado actual
    // -------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Inicialización
            state <= 5'b00000;
            mCounter <= 8'h00;
            j1_num_parejas <= 0;
            j2_num_parejas <= 0;
            puntaje_j1 <= 0;
            puntaje_j2 <= 0;
            jugador_1_tiene_pareja <= 0;
            jugador_2_tiene_pareja <= 0;
            contador_tiempo <= 0;
            cartas_seleccionadas_reg <= 0;
        end
        else begin
            // Contador de tiempo
            if (pulse_segundo && contador_tiempo < 16) begin
                contador_tiempo <= contador_tiempo + 1;
            end

            // Actualización de registros según estado
            case(state)
                // Jugador 1
                5'b00111: begin
                    if (jugador_1_tiene_pareja) begin
                        j1_num_parejas <= j1_num_parejas + 1;
                        puntaje_j1 <= puntaje_j1 + 1;
                        jugador_1_tiene_pareja <= 0;
                    end
                end
                5'b01000: begin
                    cartas_seleccionadas_reg <= cartas_seleccionadas_reg + 1;
                end

                // Jugador 2
                5'b01011: begin
                    if (jugador_2_tiene_pareja) begin
                        j2_num_parejas <= j2_num_parejas + 1;
                        puntaje_j2 <= puntaje_j2 + 1;
                        jugador_2_tiene_pareja <= 0;
                    end
                end
                5'b01100: begin
                    cartas_seleccionadas_reg <= cartas_seleccionadas_reg + 1;
                end
            endcase

            // Salida para visualización
            if (t0) estado <= 8'hFF;
            else estado <= mCounter;

            // Actualización del estado
            state <= next_state;

            // Contador del estado inicial
            if (state == 5'b00001) begin
                mCounter <= mCounter + 1;
            end
        end
    end

    // -------------------------
    // Lógica combinacional: siguiente estado
    // -------------------------
    always_comb begin
        next_state = state; // Por defecto

        case(state)
            // Estados iniciales
            5'b00000: if (m) next_state = 5'b00001;
            5'b00001: if (m) next_state = 5'b00010;
            5'b00010: if (m) next_state = 5'b00011;
            5'b00011: if (m) next_state = 5'b00100;
            5'b00100: if (m) next_state = 5'b00101;

            // Jugador 1
            5'b00101: begin
                if (contador_tiempo < 16)
                    next_state = 5'b00101;
                else if (cartas_seleccionadas == 2'b01)
                    next_state = 5'b00110;
                else
                    next_state = 5'b01000;
            end

            5'b00110: begin
                if (contador_tiempo < 16)
                    next_state = 5'b00110;
                else if (cartas_seleccionadas == 2'b10)
                    next_state = 5'b00111;
                else
                    next_state = 5'b01000;
            end

            5'b00111: begin
                if (jugador_1_tiene_pareja) begin
                    if ((j1_num_parejas + j2_num_parejas) == 8)
                        next_state = 5'b01101;
                    else
                        next_state = 5'b00101;
                end
                else
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

            // Jugador 2
            5'b01001: begin
                if (contador_tiempo < 16)
                    next_state = 5'b01001;
                else if (cartas_seleccionadas == 2'b01)
                    next_state = 5'b01010;
                else
                    next_state = 5'b01100;
            end

            5'b01010: begin
                if (contador_tiempo < 16)
                    next_state = 5'b01010;
                else if (cartas_seleccionadas == 2'b10)
                    next_state = 5'b01011;
                else
                    next_state = 5'b01100;
            end

            5'b01011: begin
                if (jugador_2_tiene_pareja) begin
                    if ((j1_num_parejas + j2_num_parejas) == 8)
                        next_state = 5'b01101;
                    else
                        next_state = 5'b01001;
                end
                else
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

            // Fin del juego
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

