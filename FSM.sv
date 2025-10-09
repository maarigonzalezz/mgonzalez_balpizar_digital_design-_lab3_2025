module FSM(
    input  logic        rst, clk,
    input  logic [1:0]  cartas_seleccionadas,
    input  logic        tiempo_terminado,
    input  logic        inicio,
    input  logic        se_eligio_carta,
    input  logic        cartas_mostradas,
    input  logic        cartas_ocultas,
    input  logic        cartas_revueltas,
    output logic [1:0]  ganador,
    output logic [3:0]  state
);

    // Definición de estados
    typedef enum logic [3:0] {
        INICIO          = 4'b0000,
        MUESTRO_CORTAS  = 4'b0001,
        OCULTA_CORTAS   = 4'b0010,
        REVUELVE_CORTAS = 4'b0011,
        INICIO_JUEGO    = 4'b0100,
        TURNO_JUGADOR   = 4'b0101,
        UNA_CARTA       = 4'b0110,
        DOS_CARTAS      = 4'b0111,
        MOSTRAR_RANDOM  = 4'b1000,
        NO_MAS_PAREJAS  = 4'b1001,
        CONCLUSION      = 4'b1010
    } state_t;

    state_t current_state, next_state;

    // Registros internos
    logic [3:0] puntaje_j1;
    logic [3:0] puntaje_j2;
    logic jugador_en_turno; // 0 = jug1, 1 = jug2
    logic [4:0] primera_carta;
    logic [4:0] segunda_carta;
    logic pareja_encontrada;

    // UN SOLO BLOQUE ALWAYS_FF PARA TODA LA LÓGICA SECUENCIAL
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= INICIO;
            puntaje_j1 <= 0;
            puntaje_j2 <= 0;
            jugador_en_turno <= 0;
            primera_carta <= 0;
            segunda_carta <= 0;
            pareja_encontrada <= 0;
            ganador <= 2'b00;
        end else begin
            current_state <= next_state;

            // Lógica de actualización de registros BASADA EN EL ESTADO ACTUAL
            case (current_state)
                INICIO: begin
                    // Resetear puntajes al inicio
                    puntaje_j1 <= 0;
                    puntaje_j2 <= 0;
                    jugador_en_turno <= 0;
                    ganador <= 2'b00;
                end
                
                TURNO_JUGADOR: begin
                    // Resetear variables de cartas al inicio del turno
                    primera_carta <= 0;
                    segunda_carta <= 0;
                    pareja_encontrada <= 0;
                end
                
                UNA_CARTA: begin
                    // Capturar primera carta cuando se selecciona
                    if (se_eligio_carta) begin
                        primera_carta <= {3'b0, cartas_seleccionadas};
                    end
                end
                
                DOS_CARTAS: begin
                    // Capturar segunda carta y verificar pareja
                    if (se_eligio_carta) begin
                        segunda_carta <= {3'b0, cartas_seleccionadas};
                        
                        // Verificar si es pareja
                        if (primera_carta == segunda_carta) begin
                            pareja_encontrada <= 1;
                            // Sumar puntaje al jugador en turno
                            if (jugador_en_turno == 0)
                                puntaje_j1 <= puntaje_j1 + 1;
                            else
                                puntaje_j2 <= puntaje_j2 + 1;
                        end else begin
                            // Cambiar turno si no hay pareja
                            jugador_en_turno <= ~jugador_en_turno;
                        end
                    end
                end
                
                CONCLUSION: begin
                    // Determinar ganador
                    if (puntaje_j1 > puntaje_j2)
                        ganador <= 2'b01;
                    else if (puntaje_j1 < puntaje_j2)
                        ganador <= 2'b10;
                    else
                        ganador <= 2'b11;
                end
                
                default: ; // No hacer nada en otros estados
            endcase
        end
    end

    // Lógica de transición de estados (COMBINACIONAL)
    always_comb begin
        next_state = current_state;
        
        case (current_state)
            INICIO: begin
                if (inicio)
                    next_state = MUESTRO_CORTAS;
                else
                    next_state = INICIO;
            end
            
            MUESTRO_CORTAS: begin
                if (cartas_mostradas)
                    next_state = OCULTA_CORTAS;
                else
                    next_state = MUESTRO_CORTAS;
            end
            
            OCULTA_CORTAS: begin
                if (cartas_ocultas)
                    next_state = REVUELVE_CORTAS;
                else
                    next_state = OCULTA_CORTAS;
            end
            
            REVUELVE_CORTAS: begin
                if (cartas_revueltas)
                    next_state = INICIO_JUEGO;
                else
                    next_state = REVUELVE_CORTAS;
            end
            
            INICIO_JUEGO: begin
                next_state = TURNO_JUGADOR;
            end
            
            TURNO_JUGADOR: begin
                if (se_eligio_carta)
                    next_state = UNA_CARTA;
                else if (tiempo_terminado)
                    next_state = MOSTRAR_RANDOM;
                else
                    next_state = TURNO_JUGADOR;
            end
            
            UNA_CARTA: begin
                if (se_eligio_carta)
                    next_state = DOS_CARTAS;
                else if (tiempo_terminado)
                    next_state = MOSTRAR_RANDOM;
                else
                    next_state = UNA_CARTA;
            end
            
            DOS_CARTAS: begin
                if (pareja_encontrada && (puntaje_j1 + puntaje_j2 >= 8))
                    next_state = NO_MAS_PAREJAS;
                else
                    next_state = TURNO_JUGADOR;
            end
            
            MOSTRAR_RANDOM: begin
                next_state = TURNO_JUGADOR;
            end
            
            NO_MAS_PAREJAS: begin
                next_state = CONCLUSION;
            end
            
            CONCLUSION: begin
                // Esperamos a que se presione 'inicio' para volver al INICIO
                if (inicio)
                    next_state = INICIO;
                else
                    next_state = CONCLUSION;
            end
            
            default: next_state = INICIO;
        endcase
    end

    // Salida de estado
    assign state = current_state;

endmodule