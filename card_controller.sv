module card_controller(
		input  logic clk,
		input  logic rst,
		input  logic [3:0] state,
		input logic startSh, startMcr,
		output logic [4:0] arr_out [0:15], // 16 elementos, cada uno de 5 bits
		output logic doneSh, doneMcr);

	
	logic [7:0] seed; // semilla pseudoaleatoria
	logic [4:0] arr_Sh [0:15];
	logic [4:0] arr_Sel [0:15];
	logic [4:0] arr_Mcr [0:15];
	logic [4:0] arr_V [0:15];
	
	
	//bit shifter que funciona para el shuffle y para mostrar carta random
	bit_shifter bs (.clk(clk), .rst(rst), .data(seed));
	
	// Instancia al modulo que mezcla las cartas
	Shuffle sh (.clk(clk), .rst(rst), .start(startSh), .seed(seed), .arr_cards(arr_Sh), .done(doneSh));
	
	// Instancia que hace mostrar una carta random en base a cuantas cartas han sido seleccionadas 
	mostrar_carta_random mcr (.clk(clk), .rst(rst), .start(startMcr), .seed(seed), .arr_cards_in(arr_Sel),
										.arr_cards_out(arr_Mcr), .done(doneMcr));


			
		
endmodule 
		