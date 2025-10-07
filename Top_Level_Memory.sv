module Top_Level_Memory(input logic m, rst, clk,
								input  logic [1:0]  cartas_sel,      // Cartas seleccionadas
								input  logic tiempoT, I, carta_El, cartas_Mo,           
								input  logic cartas_Oc, cartas_Re,
								output logic [1:0]  ganador,
								output logic [6:0] seg, // Segmentos del display (a-g) --> contador
								output logic vgaclk, // 25.175 MHz VGA clock --> VGA
								output logic hsync, vsync, // VGA
								output logic sync_b, blank_b, // VGA
								output logic [7:0] r, g, b);

	logic [9:0] x, y; 
	
	// Modulo para obtener 25MHz
	pll vgapll(.inclk0(clk), .c0(vgaclk));

	// Generador de señales para el monitor
	vgaController vgaCont(vgaclk, hsync, vsync, sync_b, blank_b, x, y);
	
	// Modulo que pinta las cartas mostradas en pantalla
	videoGen videoGen(x, y, r, g, b);
	
	//contador de 15 seg
	top_7seg_counter cont15s(.clk(clk), .rst(rst), .seg(seg));
	
	// Instancia de la maquina de estados
	FSM FSMM(.m(m), .rst(rst), .clk(clk), .cartas_seleccionadas(cartas_sel),
					.tiempo_terminado(tiempoT), .inicio(I), .se_eligio_carta(carta_El),
					.cartas_mostradas(cartas_Mo), .cartas_ocultas(cartas_Oc),
					.cartas_revueltas(cartas_Re), .ganador(ganador));
								
								
endmodule 								
								