//Generador de una figura en la pantalla, aplicacion de colores por pixel

module videoGen(input logic [9:0] x, y,
					input logic [3:0] state,
					output logic [7:0] r, g, b);

logic pixel, cA1, cA2, cB1, cB2;
logic cC1, cC2, cD1, cD2, cE1, cE2;
logic cF1, cF2, cG1, cG2, cH1, cH2;
logic simA1, simA2, simB1, simB2;
logic simC1, simC2, simD1, simD2;
logic simE1, simE2, simF1, simF2;
logic simG1, simG2, simH1, simH2;
logic [10:0] topS = 10'd360;
logic [10:0] botS = 10'd411;
logic [10:0] leftS = 10'd76;
logic [10:0] rightS = 10'd126;

// las cartas en la pantalla se veran como una matriz 4x4, por lo cual usaremos variables
// Filas
logic [9:0] topF1 = 10'd70;     logic [9:0] bottomF1 = 10'd140;

logic [9:0] topF2 = 10'd160;    logic [9:0] bottomF2 = 10'd230;

logic [9:0] topF3 = 10'd250;    logic [9:0] bottomF3 = 10'd320;

logic [9:0] topF4 = 10'd340;    logic [9:0] bottomF4 = 10'd410;

// Columnas 
logic [9:0] leftC1 = 10'd160;   logic [9:0] rightC1 = 10'd210;

logic [9:0] leftC2 = 10'd250;   logic [9:0] rightC2 = 10'd300;

logic [9:0] leftC3 = 10'd340;   logic [9:0] rightC3 = 10'd390;

logic [9:0] leftC4 = 10'd430;   logic [9:0] rightC4 = 10'd480;


// Cartas: coordenadas
    carta cartaA1(
        .x(x), .y(y), 
        .left(leftC1), .right(rightC1), 
        .top(topF1), .bot(bottomF1), 
        .symbol_sel(3'd0), .incard(cA1), 
		  .insymbol(simA1)
    );
	 
	 carta cartaA2(
        .x(x), .y(y), 
        .left(leftC2), .right(rightC2), 
        .top(topF1), .bot(bottomF1), 
        .symbol_sel(3'd0), .incard(cA2),
		  .insymbol(simA2)
    );
	 
	 carta cartaB1(
        .x(x), .y(y), 
        .left(leftC3), .right(rightC3), 
        .top(topF1), .bot(bottomF1), 
        .symbol_sel(3'd1), .incard(cB1), 
		  .insymbol(simB1)
    );
	 
	 carta cartaB2(
        .x(x), .y(y), 
        .left(leftC4), .right(rightC4), 
        .top(topF1), .bot(bottomF1), 
        .symbol_sel(3'd1), .incard(cB2),
		  .insymbol(simB2)
    );
	 
	 carta cartaC1(
        .x(x), .y(y), 
        .left(leftC1), .right(rightC1), 
        .top(topF2), .bot(bottomF2), 
        .symbol_sel(3'd2), .incard(cC1), 
		  .insymbol(simC1)
    );
	 
	 carta cartaC2(
        .x(x), .y(y), 
        .left(leftC2), .right(rightC2), 
        .top(topF2), .bot(bottomF2), 
        .symbol_sel(3'd2), .incard(cC2),
		  .insymbol(simC2)
    );
	 
	 carta cartaD1(
        .x(x), .y(y), 
        .left(leftC3), .right(rightC3), 
        .top(topF2), .bot(bottomF2), 
        .symbol_sel(3'd3), .incard(cD1), 
		  .insymbol(simD1)
    );
	 
	 carta cartaD2(
        .x(x), .y(y), 
        .left(leftC4), .right(rightC4), 
        .top(topF2), .bot(bottomF2), 
        .symbol_sel(3'd3), .incard(cD2),
		  .insymbol(simD2)
    );
	 
	 carta cartaE1(
        .x(x), .y(y), 
        .left(leftC1), .right(rightC1), 
        .top(topF3), .bot(bottomF3), 
        .symbol_sel(3'd4), .incard(cE1), 
		  .insymbol(simE1)
    );
	 
	 carta cartaE2(
        .x(x), .y(y), 
        .left(leftC2), .right(rightC2), 
        .top(topF3), .bot(bottomF3), 
        .symbol_sel(3'd4), .incard(cE2),
		  .insymbol(simE2)
    );
	 
	 carta cartaF1(
        .x(x), .y(y), 
        .left(leftC3), .right(rightC3), 
        .top(topF3), .bot(bottomF3), 
        .symbol_sel(3'd5), .incard(cF1), 
		  .insymbol(simF1)
    );
	 
	 carta cartaF2(
        .x(x), .y(y), 
        .left(leftC4), .right(rightC4), 
        .top(topF3), .bot(bottomF3), 
        .symbol_sel(3'd5), .incard(cF2),
		  .insymbol(simF2)
    );
	 
	 carta cartaG1(
        .x(x), .y(y), 
        .left(leftC1), .right(rightC1), 
        .top(topF4), .bot(bottomF4), 
        .symbol_sel(3'd6), .incard(cG1), 
		  .insymbol(simG1)
    );
	 
	 carta cartaG2(
        .x(x), .y(y), 
        .left(leftC2), .right(rightC2), 
        .top(topF4), .bot(bottomF4), 
        .symbol_sel(3'd6), .incard(cG2),
		  .insymbol(simG2)
    );
	 
	 carta cartaH1(
        .x(x), .y(y), 
        .left(leftC3), .right(rightC3), 
        .top(topF4), .bot(bottomF4), 
        .symbol_sel(3'd7), .incard(cH1), 
		  .insymbol(simH1)
    );
	 
	 carta cartaH2(
        .x(x), .y(y), 
        .left(leftC4), .right(rightC4), 
        .top(topF4), .bot(bottomF4), 
        .symbol_sel(3'd7), .incard(cH2),
		  .insymbol(simH2)
    );
	 
	 
	 

	// Detecta si el pixel está en alguna carta
	wire in_any_card = cA1 | cA2 | cB1 | cB2 | 
							 cC1 | cC2 | cD1 | cD2 | 
							 cE1 | cE2 | cF1 | cF2 | 
							 cG1 | cG2 | cH1 | cH2;

	// Detecta si el pixel está en algún símbolo
	wire in_any_symbol = simA1 | simA2 | simB1 | simB2 | simC1 | simC2 | 
								simD1 | simD2 | simE1 | simE2 | simF1 | simF2 | 
								simG1 | simG2 | simH1 | simH2;


	always_comb begin
		 // Fondo negro
		 r = 8'h87;
		 g = 8'h00;
		 b = 8'h63;

		 if (in_any_card) begin
			  // todas las cartas del mismo color (blancas)
			  r = 8'hFF; g = 8'hFF; b = 8'hFF;

			  if (in_any_symbol) begin
					// todos los símbolos del mismo color (rojo)
					r = 8'hFF; g = 8'h0F; b = 8'hE6;
			  end
		 end
	end
	
endmodule
