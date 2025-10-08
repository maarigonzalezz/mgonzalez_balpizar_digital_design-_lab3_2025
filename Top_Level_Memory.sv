module Top_Level_Memory(input logic m, rst, clk,
								input logic I, cartas_Mo,
								output logic [1:0]  ganador,
								output logic [6:0] seg, // Segmentos del display (a-g) --> contador
								output logic vgaclk, // 25.175 MHz VGA clock --> VGA
								output logic hsync, vsync, // VGA
								output logic sync_b, blank_b, // VGA
								output logic [7:0] r, g, b);

	logic [9:0] x, y; 
	logic [3:0] state;
	logic [7:0] r_videoGen, g_videoGen, b_videoGen; // colores de mostrar cartas
	logic [7:0] r_OVER, g_OVER, b_OVER; // Colores GAME_OVER
	logic [7:0] r_PantallaInicial, g_PantallaInicial, b_PantallaInicial; // Colores pantalla inicial
	logic [7:0] r_w, g_w, b_w; // Pantalla default
	logic [4:0] arr_cartas [0:15]; // 16 elementos, cada uno de 5 bits
	logic [4:0] arr_cartas1 [0:15]; // 16 elementos, cada uno de 5 bits
	logic tiempoT, carta_El, cartas_Oc, cartas_Re;
	logic [1:0]  cartas_sel;    // Cartas seleccionadas
	logic [1:0] estCartas;
	
	
	// Modulo para obtener 25MHz
	pll vgapll(.inclk0(clk), .c0(vgaclk));

	// Generador de señales para el monitor
	vgaController vgaCont(vgaclk, hsync, vsync, sync_b, blank_b, x, y);
	
	// Modulo que pinta la pantalla de inicio 
	start pantalla_inicio(.x(x), .y(y), .r(r_PantallaInicial), .g(g_PantallaInicial), .b(b_PantallaInicial));
	
	// Modulo que pinta las cartas mostradas en pantalla
	videoGen videoGen(.x(x), .y(y), .state(state), .arr_cartas(arr_cartas), .r(r_videoGen), .g(g_videoGen), .b(b_videoGen));
	
	// Modulo que muestra la pantalla de terminar juego
	finish pantalla_final(.x(x), .y(y), .ganador(ganador), .r(r_OVER), .g(g_OVER), .b(b_OVER));
	
	// Instancia de la maquina de estados
	FSM FSMM(.m(m), .rst(rst), .clk(clk), .cartas_seleccionadas(cartas_sel),
					.tiempo_terminado(tiempoT), .inicio(I), .se_eligio_carta(carta_El),
					.cartas_mostradas(cartas_Mo), .cartas_ocultas(cartas_Oc),
					.cartas_revueltas(cartas_Re), .ganador(ganador), .state(state));
	
	//contador de 15 seg
	top_7seg_counter cont15s(.clk(clk), .rst(rst), .seg(seg));
	
	modify_arr crear_arr(.estado(estCartas), .arrI(arr_cartas1));
	
	
	// Visualización de distintas pantallas
	// Pantalla default
    assign r_w = 8'h87;
    assign g_w = 8'h0A;
    assign b_w = 8'h63;
	 
	 always_comb begin
			estCartas = 00;
			arr_cartas = arr_cartas1;
			case (state)
				4'b0000: begin // Pantalla START
                r = r_PantallaInicial;
                g = g_PantallaInicial;
                b = b_PantallaInicial;
				end
				4'b0001: begin // Pantalla que muestra las cartas
					 estCartas = 2'b10; // para que al siguiente estado se muestren todas las cartas
                r = r_videoGen;
                g = g_videoGen;
                b = b_videoGen;
				end
				4'b0010: begin // Pantalla que oculta las cartas
					 estCartas = 2'b00; // para que se muestren cartas en blanco
                r = r_videoGen;
                g = g_videoGen;
                b = b_videoGen;
				end
				4'b0011: begin // Pantalla que revuelve las f cartas
				// arr_cartas = a no se
					 estCartas = 2'b11; //para asignar por fuera el cambio del array
                r = r_OVER;
                g = g_OVER;
                b = b_OVER;
				end
				
				default: begin
					 r = r_w;
					 g = g_w;
					 b = b_w;
				end
			endcase
		end
	 
	 
								
								
endmodule 								
								