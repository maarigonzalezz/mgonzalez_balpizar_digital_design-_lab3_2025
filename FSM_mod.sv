module FSM_mod(
    input logic m, rst, clk,                 // Entradas principales
	 input logic ha_seleccionado
    input logic [1;0] cartas_seleccionada,  			// Cartas seleccionadas
	 input logic turno_terminado
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
	 logic jugador_en_turno;
	 logic [15:0] cartas;


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
				jugador_en_turno <= 0;
        end
        else begin
            // Acciones según el siguiente estado
            case(state)
                
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
            4'b0000: next_state = (m) ? 5'b00001 : 5'b00000;

            // Mostrar cartas
            4'b0001: next_state = (m) ? 5'b00010 : 5'b00000;

            // Ocultar cartas
            4'b0010: next_state = (m) ? 5'b00011 : 5'b00000;

            // Revolver cartas
            4'b0011: next_state = (m) ? 5'b00100 : 5'b00000;

            // Iniciar juego
            4'b0100: next_state = (m) ? 5'b00101 : 5'b00000;

            // Estado standby
            4'b0001: next_state = 5'b00000;

            // Default de seguridad
            default: next_state = 5'b00000;
        endcase
    end

endmodule