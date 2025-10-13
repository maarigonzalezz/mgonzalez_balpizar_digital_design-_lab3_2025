module Top_Level_Memory(
    input logic rst, clk,
    input logic I, CM, CO, CR,
    input logic Izq, Der, Sel,
	 output logic [1:0] turno_de,
    output logic [6:0] seg,
	 output logic [6:0] segPJ1,
	 output logic [6:0] segPJ2,
    output logic vgaclk,
    output logic hsync, vsync,
    output logic sync_b, blank_b,
	 output logic [3:0] s, 
    output logic [7:0] r, g, b,
	 output logic cargar
);

	// Variables para VGA
	logic [9:0] x, y; 
	logic [7:0] r_videoGen, g_videoGen, b_videoGen; // salidas de colores del juego
	logic [7:0] r_videoGenI, g_videoGenI, b_videoGenI; // colores de mostrar cartas
	logic [7:0] r_OVER, g_OVER, b_OVER; // Colores GAME_OVER
	logic [7:0] r_PantallaInicial, g_PantallaInicial, b_PantallaInicial; // Colores pantalla inicial
	logic [7:0] r_w, g_w, b_w; // Pantalla default
	logic [1:0] estCartas;
	
	// Variables para la MEF
	logic [1:0]  cartas_sw;
	logic inicio, tiempo_terminado, se_eligio_carta, load;
	logic cartas_mostradas, cartas_ocultas, cartas_revueltas, carta_randomizada, cartas_verificadas;
	logic [3:0]  state;
	logic [3:0] puntajeJ1;
   logic [3:0] puntajeJ2;
	logic [1:0] ganador;
	logic reset_timer;
	
	// arrays
	logic [4:0] arrI [0:15]; // 16 elementos, cada uno de 5 bits
	logic [4:0] arr_cartas [0:15]; // Array donde se encuentra la logica del juego
	logic [4:0] arr_temp [0:15];
	
	
	// ======================================================= VGA =============================================================
	// Modulo para obtener 25MHz
	pll vgapll(.inclk0(clk), .c0(vgaclk));

	// Generador de señales para el monitor
	vgaController vgaCont(vgaclk, hsync, vsync, sync_b, blank_b, x, y);
	
	// Modulo que pinta la pantalla de inicio 
	start pantalla_inicio(.x(x), .y(y), .r(r_PantallaInicial), .g(g_PantallaInicial), .b(b_PantallaInicial));
	
	// Modulo que pinta las cartas mostradas en pantalla
	videoGen videoGenI(.x(x), .y(y), .arr_cartas(arrI), .r(r_videoGenI), .g(g_videoGenI), .b(b_videoGenI));
	
	// Modulo que pinta las cartas mostradas en pantalla ------> quede instanciando esto
	videoGen videoGen(.x(x), .y(y), .arr_cartas(arr_cartas), .r(r_videoGen), .g(g_videoGen), .b(b_videoGen));
	
	// Modulo que muestra la pantalla de terminar juego
	finish pantalla_final(.x(x), .y(y), .ganador(ganador), .r(r_OVER), .g(g_OVER), .b(b_OVER));
	
	// ============================================ MANEJO DE ARRAY DE CARTAS =====================================
	// crea el array inicial y lo modifica segun el estado
	modify_arr crear_arr(.estado(estCartas), .arrI(arrI));
	
	// modulo que tiene el control del manejo de cartas
	card_controller cartasM(.clk(clk), .rst(rst), .Izq(Izq), .Der(Der), .Sel(Sel), 
									.state(state), .arr_in(arr_cartas), .arr_out(arr_temp), .doneSh(cartas_revueltas), 
									.doneSp(se_eligio_carta), .doneMcr(carta_randomizada), .cartas_seleccionadas(cartas_sw),
									.doneVp(cartas_verificadas), .load(load), .hubo_pareja(hubo_pareja));
									
	save_cards cartasG(.clk(clk), .rst(rst), .load(load), .arr_in(arr_temp), .arr_out(arr_cartas));
	
	// ===================================================== MEF ==================================================
	assign inicio = I;
	assign cartas_mostradas = CM;
	assign cartas_ocultas = CO; 
	//assign cartas_revueltas = CR;

	assign s = state;
	assign cargar = load;
	
	FSM memory_fsm (
        .rst(rst),
        .clk(clk),
        .cartas_seleccionadas(cartas_sw),
        .tiempo_terminado(tiempo_terminado),
        .inicio(inicio),
        .se_eligio_carta(se_eligio_carta),
        .cartas_mostradas(cartas_mostradas),
        .cartas_ocultas(cartas_ocultas),
        .cartas_revueltas(cartas_revueltas),
		  .carta_randomizada(carta_randomizada),
		  .hubo_pareja(hubo_pareja),
		  .cartas_verificadas(cartas_verificadas),
        .ganador(ganador),
        .state(state),
		  .turno_de(turno_de),
		  .puntajeJ1(puntajeJ1),
		  .puntajeJ2(puntajeJ2),
		  .reset_timer(reset_timer)
    );
	 
	 
	logic done_sync;

	posedge_detector pd_done(
			 .clk(clk),
			 .rst(rst),
			 .sig_in(done),
			 .pulse_out(done_sync)
	);

	 
	
	//============================================ 7 SEGMENTOS ==============================================

	top_7seg_counter counter_7seg_1(.clk(clk), .rst(reset_timer), .seg(seg), .tiempo_terminado(tiempo_terminado));
	
	// Decodificadores de 7 segmentos
    BinTo7Seg display_unidades (
			.bin(puntajeJ1), 
			.bin_to_7seg(segPJ1));
			
    BinTo7Seg display_decenas  (
			.bin(puntajeJ2),  
			.bin_to_7seg(segPJ2));


	// ============================================ LÓGICA DE PANTALLAS ===========================================
    // Pantalla default (morado)
    assign r_w = 8'h87;
    assign g_w = 8'h0A;
    assign b_w = 8'h63;
    
    // Selección de pantalla según estado
    always_comb begin
        estCartas = 2'b11;       
        case (state)
            4'b0000: begin // Pantalla START
                r = r_PantallaInicial;
                g = g_PantallaInicial;
                b = b_PantallaInicial;
            end
            
            4'b0001: begin // Pantalla de mostrar cartas ordenadas
                estCartas = 2'b10;  // Cartas visibles
                r = r_videoGenI;
                g = g_videoGenI;
                b = b_videoGenI;
            end
            
            4'b0010: begin // Pantalla de ocultar cartas
                estCartas = 2'b00;  // Cartas ocultas
                r = r_videoGenI;
                g = g_videoGenI;
                b = b_videoGenI;
            end
            
            4'b0011: begin // Pantalla de revolver cartas
                estCartas = 2'b01;  // Cartas seleccionadas 
                r = r_videoGenI;
                g = g_videoGenI;
                b = b_videoGenI;
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