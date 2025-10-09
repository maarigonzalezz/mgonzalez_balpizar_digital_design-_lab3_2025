module Top_Level_Memory(input logic m, rst, clk,
								input logic I, cartas_Mo, cartas_Oc,
								input logic Izq, Der, Sel,  // Inputs donde el usuario selecciona una carta
								output logic [1:0]  ganador,
								output logic [6:0] seg, // Segmentos del display (a-g) --> contador
								output logic vgaclk, // 25.175 MHz VGA clock --> VGA
								output logic hsync, vsync, // VGA
								output logic sync_b, blank_b, // VGA
								output logic [7:0] r, g, b);

	// Variables para VGA
	logic [9:0] x, y; 
	logic [7:0] r_videoGen, g_videoGen, b_videoGen; // salidas de colores del juego
	logic [7:0] r_videoGenI, g_videoGenI, b_videoGenI; // colores de mostrar cartas
	logic [7:0] r_OVER, g_OVER, b_OVER; // Colores GAME_OVER
	logic [7:0] r_PantallaInicial, g_PantallaInicial, b_PantallaInicial; // Colores pantalla inicial
	logic [7:0] r_w, g_w, b_w; // Pantalla default
	
	// Variables para manejo de logica de juego
	logic [3:0] state;
	logic [4:0] arrI [0:15]; // 16 elementos, cada uno de 5 bits
	logic [4:0] arr_cartas [0:15]; // Array donde se encuentra la logica del juego
	logic [4:0] arr_temp [0:15];
	logic tiempoT, carta_El, cartas_Re;
	logic [1:0]  cartas_sel;    // Cartas seleccionadas
	logic [1:0] estCartas; // para los primeros 3 estados de la MEF
	
	logic start_shuffle, start_mcr, load;
	
	
	// ======================================================= VGA =============================================================
	// Modulo para obtener 25MHz
	pll vgapll(.inclk0(clk), .c0(vgaclk));

	// Generador de señales para el monitor
	vgaController vgaCont(vgaclk, hsync, vsync, sync_b, blank_b, x, y);
	
	// Modulo que pinta la pantalla de inicio 
	start pantalla_inicio(.x(x), .y(y), .r(r_PantallaInicial), .g(g_PantallaInicial), .b(b_PantallaInicial));
	
	// Modulo que pinta las cartas mostradas en pantalla
	videoGen videoGenI(.x(x), .y(y), .state(state), .arr_cartas(arrI), .r(r_videoGenI), .g(g_videoGenI), .b(b_videoGenI));
	
	// Modulo que pinta las cartas mostradas en pantalla
	videoGen videoGen(.x(x), .y(y), .state(state), .arr_cartas(arr_cartas), .r(r_videoGen), .g(g_videoGen), .b(b_videoGen));
	
	// Modulo que muestra la pantalla de terminar juego
	finish pantalla_final(.x(x), .y(y), .ganador(ganador), .r(r_OVER), .g(g_OVER), .b(b_OVER));
	
	
	// ===================================================== MEF ===============================================================
	// Instancia de la maquina de estados
	FSM FSMM(.m(m), .rst(rst), .clk(clk), .cartas_seleccionadas(cartas_sel),
					.tiempo_terminado(tiempoT), .inicio(I), .se_eligio_carta(carta_El),
					.cartas_mostradas(cartas_Mo), .cartas_ocultas(cartas_Oc),
					.cartas_revueltas(cartas_Re), .ganador(ganador), .state(state));
	
	//contador de 15 seg
	top_7seg_counter cont15s(.clk(clk), .rst(rst), .seg(seg));
	
	// ====================================== MODULO DESTINADO A LA MODIFICACION DEL ARRAY DE CARTAS =========================
	
	// crea el array inicial y lo modifica segun el estado
	modify_arr crear_arr(.estado(estCartas), .arrI(arrI));
	
	// modulo que tambien maneja resultados de la FSM
	card_controller cambia_arr(.clk(clk), .rst(rst), .state(state), .startSh(start_shuffle), .startMcr(start_mcr),
										.arr_in(arr_cartas), .arr_out(arr_temp), .doneSh(cartas_Re), .load(load));
										
	// modulo que guarda el array en un registro
	save_cards guardar_arr(.clk(clk), .rst(rst), .load(load), .arr_in(arr_temp), .arr_out(arr_cartas));
	
	
	
	// ===================================== Visualización de distintas pantallas =====================================
	// Pantalla default
    assign r_w = 8'h87;
    assign g_w = 8'h0A;
    assign b_w = 8'h63;
	 
	 always_comb begin
			estCartas = 2'b11;
			case (state)
				4'b0000: begin // Pantalla START
                r = r_PantallaInicial;
                g = g_PantallaInicial;
                b = b_PantallaInicial;
				end
				4'b0001: begin // Pantalla de mostrar cartas ordenadas
					 estCartas = 2'b10;
                r = r_videoGenI;
                g = g_videoGenI;
                b = b_videoGenI;
				end
				4'b0010: begin // Pantalla de ocultar cartas
					 estCartas = 2'b00;
                r = r_videoGenI;
                g = g_videoGenI;
                b = b_videoGenI;
				end
				4'b0011: begin // Pantalla de revolver cartas
                r = r_OVER;
                g = g_OVER;
                b = b_OVER;
				end
				4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001: begin // Pantalla de juego
                r = r_videoGen;
                g = g_videoGen;
                b = b_videoGen;
				end
				4'b1010: begin // Pantalla final
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
								