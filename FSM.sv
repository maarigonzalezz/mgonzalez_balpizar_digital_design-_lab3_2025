module FSM(
    input logic m, rst, clk,                 // Entradas principales
    input logic [1:0] cartas_seleccionadas,  // Cartas seleccionadas
    output logic [7:0] estado                // Salida del estado
);

    // Registros internos de la FSM
    logic [4:0] state, next_state;          // Estado actual y siguiente estado
    logic t0;                               // Señal de sincronización del clkCounter
    logic [7:0] mCounter;                   // Contador del estado inicial
    logic [3:0] contador_tiempo;           // Contador de 0 a 15
    logic pulse_segundo;                    // Pulso de 1 segundo
    logic [2:0] j1_num_parejas;            // Parejas jugador 1
    logic [2:0] j2_num_parejas;            // Parejas jugador 2
    logic [2:0] puntaje_j1;                // Puntaje jugador 1
    logic [2:0] puntaje_j2;                // Puntaje jugador 2
    logic jugador_1_tiene_pareja;          // Indica si jugador 1 tiene pareja
    logic jugador_2_tiene_pareja;          // Indica si jugador 2 tiene pareja
    logic [1:0] cartas_seleccionadas_reg;  // Registro interno de cartas seleccionadas

    // Instancia de contador de segundos
    clk_counter_seg #(
        .CLOCK_FREQ_HZ(50_000_000)         // Ajusta a la frecuencia del reloj
    ) contador_segundos (
        .clk(clk),
        .rst(rst),
        .pulse_1s(pulse_segundo)
    );

    // Instancia del clkCounter para señal t0
    clkCounter counter(clk, rst, t0);

    // -------------------------
    // Logica secuencial (estado actual)
    // -------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset: inicializa todos los registros
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
            // Incrementar contador de tiempo cada segundo
            if (pulse_segundo && contador_tiempo < 15)
                contador_tiempo <= contador_tiempo + 1;

            // Acciones según el siguiente estado
            case(next_state)
                5'b00101: begin
                    jugador_1_tiene_pareja <= 0;
                    j1_num_parejas <= j1_num_parejas + 1;
                    puntaje_j1 <= puntaje_j1 + 1;
                end
                5'b00110, 5'b00111: begin
                    cartas_seleccionadas_reg <= cartas_seleccionadas_reg + 1;
                end
                5'b01001: begin
                    jugador_2_tiene_pareja <= 0;
                    j2_num_parejas <= j2_num_parejas + 1;
                    puntaje_j2 <= puntaje_j2 + 1;
                end
                5'b01010, 5'b01011: begin
                    cartas_seleccionadas_reg <= cartas_seleccionadas_reg + 1;
                end
            endcase

            // Salida del estado (ejemplo de visualización)
            estado <= t0 ? 8'hFF : mCounter;

            // Actualizar estado actual
            state <= next_state;

            // Incrementar contador del estado inicial
            if (next_state == 5'b00001)
                mCounter <= mCounter + 1;
        end
    end

    // -------------------------
    // Logica combinacional (siguiente estado)
    // -------------------------
    always_comb begin
        // Por defecto, siguiente estado igual al actual
        next_state = state;

        case(state)
            // Estado inicial
            5'b00000: next_state = (m) ? 5'b00001 : 5'b00000;

            // Mostrar cartas
            5'b00001: next_state = (m) ? 5'b00010 : 5'b00000;

            // Ocultar cartas
            5'b00010: next_state = (m) ? 5'b00011 : 5'b00000;

            // Revolver cartas
            5'b00011: next_state = (m) ? 5'b00100 : 5'b00000;

            // Iniciar juego
            5'b00100: next_state = (m) ? 5'b00101 : 5'b00000;

            // Turno jugador 1
            5'b00101: begin
                if (contador_tiempo < 16)
                    next_state = 5'b00101;
                else if (cartas_seleccionadas == 2'b01)
                    next_state = 5'b00110;
                else
                    next_state = 5'b01000;
            end

            // Jugador 1 tiene una carta
            5'b00110: begin
                if (contador_tiempo < 16)
                    next_state = 5'b00110;
                else if (cartas_seleccionadas == 2'b10)
                    next_state = 5'b00111;
                else
                    next_state = 5'b01000;
            end

            // Jugador 1 tiene 2 cartas
            5'b00111: next_state = (jugador_1_tiene_pareja) ? 5'b00101 : 5'b01001;

            // Mostrar carta aleatoria jugador 1
            5'b01000: begin
                if (cartas_seleccionadas == 2'b00)
                    next_state = 5'b00110;
                else if (cartas_seleccionadas == 2'b01)
                    next_state = 5'b00111;
            end

            // Turno jugador 2
            5'b01001: begin
                if (contador_tiempo < 16)
                    next_state = 5'b01001;
                else if (cartas_seleccionadas == 2'b01)
                    next_state = 5'b01010;
                else
                    next_state = 5'b01100;
            end

            // Jugador 2 tiene una carta
            5'b01010: begin
                if (contador_tiempo < 16)
                    next_state = 5'b01010;
                else if (cartas_seleccionadas == 2'b10)
                    next_state = 5'b01011;
                else
                    next_state = 5'b01100;
            end

            // Jugador 2 tiene dos cartas
            5'b01011: next_state = (jugador_2_tiene_pareja) ? 5'b01001 : 5'b00101;

            // Mostrar carta aleatoria jugador 2
            5'b01100: begin
                if (cartas_seleccionadas == 2'b00)
                    next_state = 5'b01010;
                else if (cartas_seleccionadas == 2'b01)
                    next_state = 5'b01011;
            end

            // No hay más parejas
            5'b01101: begin
                if (puntaje_j1 > puntaje_j2)
                    next_state = 5'b01110;
                else if (puntaje_j1 < puntaje_j2)
                    next_state = 5'b01111;
                else
                    next_state = 5'b10000;
            end

            // Resultado final
            5'b01110, 5'b01111, 5'b10000: next_state = 5'b10001;

            // Estado standby
            5'b10001: next_state = 5'b00000;

            // Default de seguridad
            default: next_state = 5'b00000;
        endcase
    end

endmodule

