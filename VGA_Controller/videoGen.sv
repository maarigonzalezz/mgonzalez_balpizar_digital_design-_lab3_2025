//Generador de una figura en la pantalla, aplicacion de colores por pixel

module videoGen(input logic [9:0] x, y,
					input logic [4:0] arr_cartas [0:15],
					output logic [7:0] r, g, b);

logic pixel, cA1, cA2, cB1, cB2;
logic cC1, cC2, cD1, cD2, cE1, cE2;
logic cF1, cF2, cG1, cG2, cH1, cH2;
logic simA1, simA2, simB1, simB2;
logic simC1, simC2, simD1, simD2;
logic simE1, simE2, simF1, simF2;
logic simG1, simG2, simH1, simH2;
logic brA1, brA2, brB1, brB2;
logic brC1, brC2, brD1, brD2;
logic brE1, brE2, brF1, brF2;
logic brG1, brG2, brH1, brH2;
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
        .formato(arr_cartas[0]), .incard(cA1), 
		  .insymbol(simA1), .inborder(brA1)
    );
	 
	 carta cartaA2(
        .x(x), .y(y), 
        .left(leftC2), .right(rightC2), 
        .top(topF1), .bot(bottomF1), 
        .formato(arr_cartas[1]), .incard(cA2),
		  .insymbol(simA2), .inborder(brA2)
    );
	 
	 carta cartaB1(
        .x(x), .y(y), 
        .left(leftC3), .right(rightC3), 
        .top(topF1), .bot(bottomF1), 
        .formato(arr_cartas[2]), .incard(cB1), 
		  .insymbol(simB1), .inborder(brB1)
    );
	 
	 carta cartaB2(
        .x(x), .y(y), 
        .left(leftC4), .right(rightC4), 
        .top(topF1), .bot(bottomF1), 
        .formato(arr_cartas[3]), .incard(cB2),
		  .insymbol(simB2), .inborder(brB2)
    );
	 
	 carta cartaC1(
        .x(x), .y(y), 
        .left(leftC1), .right(rightC1), 
        .top(topF2), .bot(bottomF2), 
        .formato(arr_cartas[4]), .incard(cC1), 
		  .insymbol(simC1), .inborder(brC1)
    );
	 
	 carta cartaC2(
        .x(x), .y(y), 
        .left(leftC2), .right(rightC2), 
        .top(topF2), .bot(bottomF2), 
        .formato(arr_cartas[5]), .incard(cC2),
		  .insymbol(simC2), .inborder(brC2)
    );
	 
	 carta cartaD1(
        .x(x), .y(y), 
        .left(leftC3), .right(rightC3), 
        .top(topF2), .bot(bottomF2), 
        .formato(arr_cartas[6]), .incard(cD1), 
		  .insymbol(simD1), .inborder(brD1)
    );
	 
	 carta cartaD2(
        .x(x), .y(y), 
        .left(leftC4), .right(rightC4), 
        .top(topF2), .bot(bottomF2), 
        .formato(arr_cartas[7]), .incard(cD2),
		  .insymbol(simD2), .inborder(brD2)
    );
	 
	 carta cartaE1(
        .x(x), .y(y), 
        .left(leftC1), .right(rightC1), 
        .top(topF3), .bot(bottomF3), 
        .formato(arr_cartas[8]), .incard(cE1), 
		  .insymbol(simE1), .inborder(brE1)
    );
	 
	 carta cartaE2(
        .x(x), .y(y), 
        .left(leftC2), .right(rightC2), 
        .top(topF3), .bot(bottomF3), 
        .formato(arr_cartas[9]), .incard(cE2),
		  .insymbol(simE2), .inborder(brE2)
    );
	 
	 carta cartaF1(
        .x(x), .y(y), 
        .left(leftC3), .right(rightC3), 
        .top(topF3), .bot(bottomF3), 
        .formato(arr_cartas[10]), .incard(cF1), 
		  .insymbol(simF1), .inborder(brF1)
    );
	 
	 carta cartaF2(
        .x(x), .y(y), 
        .left(leftC4), .right(rightC4), 
        .top(topF3), .bot(bottomF3), 
        .formato(arr_cartas[11]), .incard(cF2),
		  .insymbol(simF2), .inborder(brF2)
    );
	 
	 carta cartaG1(
        .x(x), .y(y), 
        .left(leftC1), .right(rightC1), 
        .top(topF4), .bot(bottomF4), 
        .formato(arr_cartas[12]), .incard(cG1), 
		  .insymbol(simG1), .inborder(brG1)
    );
	 
	 carta cartaG2(
        .x(x), .y(y), 
        .left(leftC2), .right(rightC2), 
        .top(topF4), .bot(bottomF4), 
        .formato(arr_cartas[13]), .incard(cG2),
		  .insymbol(simG2), .inborder(brG2)
    );
	 
	 carta cartaH1(
        .x(x), .y(y), 
        .left(leftC3), .right(rightC3), 
        .top(topF4), .bot(bottomF4), 
        .formato(arr_cartas[14]), .incard(cH1), 
		  .insymbol(simH1), .inborder(brH1)
    );
	 
	 carta cartaH2(
        .x(x), .y(y), 
        .left(leftC4), .right(rightC4), 
        .top(topF4), .bot(bottomF4), 
        .formato(arr_cartas[15]), .incard(cH2),
		  .insymbol(simH2), .inborder(brH2)
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
	
	// Detecta si el pixel está en algun borde
	wire in_any_border = brA1 | brA2 | brB1 | brB2 | brC1 | brC2 | 
								brD1 | brD2 | brE1 | brE2 | brF1 | brF2 | 
								brG1 | brG2 | brH1 | brH2;

	always_comb begin
    // fondo
    r = 8'h87; g = 8'h00; b = 8'h63;

    // 2) carta rellena
    if (in_any_card) begin
        r = 8'hFF; g = 8'hFF; b = 8'hFF;
		  
		  // 1) Borde (puede estar fuera del área de la carta)
			 if (in_any_border) begin
				  r = 8'hF5; g = 8'h5B; b = 8'hE6;
				  if (in_any_symbol) begin
					  r = 8'hFF; g = 8'h0F; b = 8'hE6;
				 end
			 end
			 // 3) Símbolo (dentro de la carta, tiene prioridad sobre el borde)
			 else if (in_any_symbol) begin
				  r = 8'hFF; g = 8'h0F; b = 8'hE6;
			 end
    end
end
	
endmodule
