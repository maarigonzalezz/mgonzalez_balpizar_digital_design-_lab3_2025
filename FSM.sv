module FSM(
    input  logic        rst, clk,
    input  logic [1:0]  cartas_seleccionadas,
    input  logic        tiempo_terminado,
    input  logic        inicio,
    input  logic        se_eligio_carta,
    input  logic        cartas_mostradas,
    input  logic        cartas_ocultas,
    input  logic        cartas_revueltas,
	 input  logic        cartas_verificadas,
	 input  logic        carta_randomizada,
	 input  logic        hubo_pareja,
    output logic [1:0]  ganador,
    output logic [3:0]  state,
	 output logic [1:0]  turno_de,
	 output logic [3:0] puntajeJ1,
    output logic [3:0] puntajeJ2,
	 output logic       reset_timer
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
	 logic esperando_pareja;
	 
	 assign turno_de = jugador_en_turno + 1'b1;
	 assign puntajeJ1 = puntaje_j1;
	 assign puntajeJ2 = puntaje_j2;
	 
	 logic reset_done;
	 

    // UN SOLO BLOQUE ALWAYS_FF PARA TODA LA LÓGICA SECUENCIAL
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= INICIO;
            puntaje_j1 <= 0;
            puntaje_j2 <= 0;
            jugador_en_turno <= 0;
            ganador <= 2'b00;
				reset_timer <= 1'b1;
				reset_done <= 1'b0;  // Asegurarse de que no se ha completado el reset
				esperando_pareja <= 0;
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
                    if (!reset_done) begin
                        reset_timer <= 1'b1;  // Reseteamos el temporizador al cambiar de turno
                        reset_done <= 1'b1;
                    end else begin
                        reset_timer <= 1'b0;  // Permitimos que el temporizador cuente
                    end
                end

                
                
                DOS_CARTAS: begin
                    if (!esperando_pareja)
                        esperando_pareja <= 1;
                    else if (esperando_pareja && cartas_verificadas) begin
                        esperando_pareja <= 0;

                        if (hubo_pareja) begin
                            if (jugador_en_turno == 0)
                                puntaje_j1 <= puntaje_j1 + 1;
                            else
                                puntaje_j2 <= puntaje_j2 + 1;
                        end else begin
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
                
                default: begin
                    reset_timer <= 1'b0;
                    reset_done <= 1'b0;
                end

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
					 if (cartas_verificadas)
                    next_state = NO_MAS_PAREJAS;
					 else
						  next_state = DOS_CARTAS; // espera resultado
				end
            
            MOSTRAR_RANDOM: begin
					if (carta_randomizada)
                    next_state = DOS_CARTAS;	  
            end
				
            
            NO_MAS_PAREJAS: begin
                    if (puntaje_j1 + puntaje_j2 >= 8)
                        next_state = CONCLUSION;
                    else
                        next_state = TURNO_JUGADOR;
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