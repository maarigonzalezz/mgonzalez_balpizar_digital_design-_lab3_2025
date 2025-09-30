module FSM(
    input logic m, rst, clk,              // entradas existentes
    input logic [2:0] puntaje_j1,         // puntaje jugador 1
    input logic [2:0] puntaje_j2,         // puntaje jugador 2
    output logic [7:0] estado             // salida existente
);

    logic [4:0] state, next_state;    // Registros para el estado actual y el siguiente estado de la MEF
    logic t0;                         // Señal de sincronización del clkCounter
    logic [7:0] mCounter;             // Contador para el estado 0
	 

    // Instancia del modulo clkCounter para generar la señal t0
    clkCounter counter(clk, rst, t0);

    // Logica del estado actual
    always_ff @ (posedge clk or posedge rst) begin
        if (rst) begin
            // Si hay reset, el estado vuelve al inicial y se reinicia el contador
            state = 5'b00000;
            mCounter = 'h0;
        end
        else begin
            // Logica de salida: si t0 esta en low se muestra el valor de mCounter;
            // si t0 esta en high, se establece estado 1.
            case(t0)
                0 : estado = mCounter;
                1 : estado = 'hFF;
                default: estado = 0;
            endcase
            
            // Transicion para el siguiente estado
            state = next_state;
            
            if (next_state == 5'b00001) begin
					mCounter = mCounter + 1;
				end	
        end
    end

	// Transicion entre estados
	always_comb begin
		 case(state)
        // Estado 00000 → avanza a 00001 si m=1, si no regresa a 00000
        5'b00000: if (m) next_state = 5'b00001; else next_state = 5'b00000;

        // Estado 00001 → avanza a 00010 si m=1, si no regresa a 00000
        5'b00001: if (m) next_state = 5'b00010; else next_state = 5'b00000;

        // Estado 00010 → avanza a 00011 si m=1, si no regresa a 00000
        5'b00010: if (m) next_state = 5'b00011; else next_state = 5'b00000;

        // Estado 00011 → avanza a 00100 si m=1, si no regresa a 00000
        5'b00011: if (m) next_state = 5'b00100; else next_state = 5'b00000;

        // Estado 00100 → avanza a 00101 si m=1, si no regresa a 00000
        5'b00100: if (m) next_state = 5'b00101; else next_state = 5'b00000;

        // Estado 00101 → avanza a 00110 si m=1, si no regresa a 00000
        5'b00101: if (m) next_state = 5'b00110; else next_state = 5'b00000;

        // Estado 00110 → avanza a 00111 si m=1, si no regresa a 00000
        5'b00110: if (m) next_state = 5'b00111; else next_state = 5'b00000;

        // Estado 00111 → avanza a 01000 si m=1, si no regresa a 00000
        5'b00111: if (m) next_state = 5'b01000; else next_state = 5'b00000;

        // Estado 01000 → avanza a 01001 si m=1, si no regresa a 00000
        5'b01000: if (m) next_state = 5'b01001; else next_state = 5'b00000;

        // Estado 01001 → avanza a 01010 si m=1, si no regresa a 00000
        5'b01001: if (m) next_state = 5'b01010; else next_state = 5'b00000;

        // Estado 01010 → avanza a 01011 si m=1, si no regresa a 00000
        5'b01010: if (m) next_state = 5'b01011; else next_state = 5'b00000;

        // Estado 01011 → avanza a 01100 si m=1, si no regresa a 00000
        5'b01011: if (m) next_state = 5'b01100; else next_state = 5'b00000;

		  
        // Estado 01100 → avanza a 01101 si m=1, si no regresa a 00000
        5'b01100: if (m) next_state = 5'b01101; else next_state = 5'b00000;
		  
		  

        // Estado 01101 → avanza a 01110 si m=1, si no regresa a 00000
        5'b01101: if (puntaje_j1 > puntaje_j2) begin
							next_state = 5'b01110;
						end
						else if (puntaje_j1 < puntaje_j2) begin
							 next_state = 5'b01111;
						end
						else begin
							 next_state = 5'b10000;
						end
													
        // Estado 01110 → avanza a 01111 si m=1, si no regresa a 00000
        5'b01110: if (m) next_state = 5'b01111; else next_state = 5'b00000;

        // Estado 01111 → avanza a 10000 si m=1, si no regresa a 00000
        5'b01111: if (m) next_state = 5'b10000; else next_state = 5'b00000;

        // Estado 10000 → último estado, regresa a 00000
        5'b10000:  next_state = 5'b00000;

        // Default: seguridad
        default: next_state = 5'b00000;
        endcase
    end
endmodule
