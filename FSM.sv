module FSM(
    input  logic        m,                     // Pulso de acción
    input  logic        rst,                   // Señal de reset
    input  logic        clk,                   // Reloj principal
    input  logic [1:0]  cartas_seleccionadas,  // Cartas seleccionadas por el jugador
    output logic [7:0]  estado                 // Salida de estado para visualización
);

// -------------------------
// Registros internos de la FSM
// -------------------------
logic [4:0] state, next_state;      // Estado actual y siguiente estado
logic [7:0] mCounter;               // Contador para los pasos iniciales del juego
logic [4:0] contador_tiempo;       // Contador de tiempo para mostrar cartas automáticamente
logic [2:0] j1_num_parejas;        // Número de parejas encontradas por el jugador 1
logic [2:0] j2_num_parejas;        // Número de parejas encontradas por el jugador 2
logic [2:0] puntaje_j1;            // Puntaje actual del jugador 1
logic [2:0] puntaje_j2;            // Puntaje actual del jugador 2
logic jugador_1_tiene_pareja;      // Señal interna: jugador 1 encontró pareja
logic jugador_2_tiene_pareja;      // Señal interna: jugador 2 encontró pareja
logic mostrar_carta;               // Flag que bloquea temporalmente el cambio de estado
logic [1:0] cartas_seleccionadas_reg;

// -------------------------
// Secuencial: actualización de registros y estado
// -------------------------
always_ff @(posedge clk or posedge rst) begin

    if (rst) begin
        // Reset: inicializa todos los registros y variables a cero
        state <= 5'b00000;           // Estado inicial: pantalla de bienvenida
        mCounter <= 0;               // Contador de pasos iniciales
        j1_num_parejas <= 0;         // Número de parejas jugador 1
        j2_num_parejas <= 0;         // Número de parejas jugador 2
        puntaje_j1 <= 0;             // Puntaje jugador 1
        puntaje_j2 <= 0;             // Puntaje jugador 2
        jugador_1_tiene_pareja <= 0; // Señal de pareja encontrada jugador 1
        jugador_2_tiene_pareja <= 0; // Señal de pareja encontrada jugador 2
        contador_tiempo <= 0;        // Contador de tiempo para mostrar cartas
        cartas_seleccionadas_reg <= 0; // Registro auxiliar (puede eliminarse si no se usa)
        mostrar_carta <= 0;          // Flag para mostrar carta
    end else begin

        // -------------------------
        // Incremento del contador de tiempo
        // -------------------------
        // Contador que se usa para avanzar estados automáticamente después de un tiempo
        if (contador_tiempo < 31) begin
            contador_tiempo <= contador_tiempo + 1;
        end

        // -------------------------
        // Actualización de registros según estado
        // -------------------------
        case(state)
            // Estado 00111: Evaluar si jugador 1 tiene pareja
            5'b00111: if (jugador_1_tiene_pareja) begin
                j1_num_parejas <= j1_num_parejas + 1; // Sumar una pareja
                puntaje_j1 <= puntaje_j1 + 1;         // Aumentar puntaje
                jugador_1_tiene_pareja <= 0;          // Limpiar flag de pareja
                cartas_seleccionadas_reg <= 0;        // Limpiar registro auxiliar
            end

            // Estado 01000: Mostrar carta jugador 1 por tiempo agotado
            5'b01000: cartas_seleccionadas_reg <= cartas_seleccionadas_reg + 1;

            // Estado 01011: Evaluar si jugador 2 tiene pareja
            5'b01011: if (jugador_2_tiene_pareja) begin
                j2_num_parejas <= j2_num_parejas + 1; // Sumar una pareja
                puntaje_j2 <= puntaje_j2 + 1;         // Aumentar puntaje
                jugador_2_tiene_pareja <= 0;          // Limpiar flag de pareja
                cartas_seleccionadas_reg <= 0;        // Limpiar registro auxiliar
            end

            // Estado 01100: Mostrar carta jugador 2 por tiempo agotado
            5'b01100: cartas_seleccionadas_reg <= cartas_seleccionadas_reg + 1;
        endcase

        // -------------------------
        // Salida para visualización
        // -------------------------
        estado <= mCounter; // Muestra el valor del contador inicial

        // -------------------------
        // Actualización del estado
        // -------------------------
        // Solo se actualiza si no se está mostrando carta
        if (!mostrar_carta)
            state <= next_state;

        // -------------------------
        // Contador del estado inicial
        // -------------------------
        // Se usa para avanzar automáticamente los primeros pasos del juego
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
        // Estado 00000: Inicio del juego / pantalla de bienvenida
        5'b00000: if (m) next_state = 5'b00001;

        // Estado 00001: Primer paso inicial (contador de inicialización)
        5'b00001: if (m) next_state = 5'b00010;

        // Estado 00010: Segundo paso inicial
        5'b00010: if (m) next_state = 5'b00011;

        // Estado 00011: Tercer paso inicial
        5'b00011: if (m) next_state = 5'b00100;

        // Estado 00100: Cuarto paso inicial
        5'b00100: if (m) next_state = 5'b00101;

        // Estado 00101: Espera turno jugador 1 / tiempo para mostrar carta
        5'b00101: begin
            if (contador_tiempo >= 16 && cartas_seleccionadas == 2'b00)
                next_state = 5'b01000; // Mostrar carta por tiempo agotado
            else if (cartas_seleccionadas == 2'b01)
                next_state = 5'b00110; // Selección de primera carta
            else
                next_state = 5'b00101; // Mantener estado
        end

        // Estado 00110: Segunda selección jugador 1
        5'b00110: begin
            if (contador_tiempo >= 16 && cartas_seleccionadas == 2'b00)
                next_state = 5'b01000; // Mostrar carta por tiempo agotado
            else if (cartas_seleccionadas == 2'b10)
                next_state = 5'b00111; // Selección de segunda carta
            else
                next_state = 5'b00110; // Mantener estado
        end

        // Estado 00111: Evaluar si jugador 1 tiene pareja
        5'b00111: begin
            if (jugador_1_tiene_pareja) begin
                if ((j1_num_parejas + j2_num_parejas) == 8)
                    next_state = 5'b01101; // Todos los pares encontrados -> mostrar resultados
                else
                    next_state = 5'b00101; // Volver a turno jugador 1
            end else
                next_state = 5'b01001; // Turno jugador 2
        end

        // Estado 01000: Mostrar carta jugador 1 por tiempo agotado
        5'b01000: begin
            if (cartas_seleccionadas == 2'b00)
                next_state = 5'b00110; // Segunda selección jugador 1
            else if (cartas_seleccionadas == 2'b01)
                next_state = 5'b00111; // Evaluar pareja
            else
                next_state = 5'b01000; // Mantener estado
        end

        // Estado 01001: Espera turno jugador 2 / tiempo para mostrar carta
        5'b01001: begin
            if (contador_tiempo >= 16 && cartas_seleccionadas == 2'b00)
                next_state = 5'b01100; // Mostrar carta por tiempo agotado
            else if (cartas_seleccionadas == 2'b01)
                next_state = 5'b01010; // Primera selección jugador 2
            else
                next_state = 5'b01001; // Mantener estado
        end

        // Estado 01010: Segunda selección jugador 2
        5'b01010: begin
            if (contador_tiempo >= 16 && cartas_seleccionadas == 2'b00)
                next_state = 5'b01100; // Mostrar carta por tiempo agotado
            else if (cartas_seleccionadas == 2'b10)
                next_state = 5'b01011; // Evaluar pareja
            else
                next_state = 5'b01010; // Mantener estado
        end

        // Estado 01011: Evaluar si jugador 2 tiene pareja
        5'b01011: begin
            if (jugador_2_tiene_pareja) begin
                if ((j1_num_parejas + j2_num_parejas) == 8)
                    next_state = 5'b01101; // Todos los pares encontrados -> mostrar resultados
                else
                    next_state = 5'b01001; // Volver a turno jugador 2
            end else
                next_state = 5'b00101; // Turno jugador 1
        end

        // Estado 01100: Mostrar carta jugador 2 por tiempo agotado
        5'b01100: begin
            if (cartas_seleccionadas == 2'b00)
                next_state = 5'b01010; // Segunda selección jugador 2
            else if (cartas_seleccionadas == 2'b01)
                next_state = 5'b01011; // Evaluar pareja
            else
                next_state = 5'b01100; // Mantener estado
        end

        // Estado 01101: Comparar puntajes y determinar ganador
        5'b01101: begin
            if (puntaje_j1 > puntaje_j2)
                next_state = 5'b01110; // Jugador 1 gana
            else if (puntaje_j1 < puntaje_j2)
                next_state = 5'b01111; // Jugador 2 gana
            else
                next_state = 5'b10000; // Empate
        end

        // Estados finales: mostrar resultado antes de reset
        5'b01110, 5'b01111, 5'b10000: next_state = 5'b10001; // Mostrar resultado final

        // Estado 10001: Reinicio del juego
        5'b10001: next_state = 5'b00000;

        // Default: en caso de error, volver a inicio
        default: next_state = 5'b00000;
    endcase
end

endmodule
