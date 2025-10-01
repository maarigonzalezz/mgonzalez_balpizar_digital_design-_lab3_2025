//Generador de una figura en la pantalla, aplicacion de colores por pixel

module videoGen(input logic [9:0] x, y, 
					output logic [7:0] r, g, b);

logic pixel, cA1, cA2, cB1, cB2;
logic cC1, cC2, cD1, cD2, cE1, cE2;
logic cF1, cF2, cG1, cG2, cH1, cH2;
logic [10:0] topS = 10'd360;
logic [10:0] botS = 10'd411;
logic [10:0] leftS = 10'd76;
logic [10:0] rightS = 10'd126;

// las cartas en la pantalla se veran como una matriz 4x4, por lo cual usaremos variables
// para alturas anchos y posiciones
logic [9:0] topF1 = 10'd70;
logic [9:0] bottomF1 = 10'd140;

logic [9:0] topF2 = 10'd160;
logic [9:0] bottomF2 = 10'd230;

logic [9:0] topF3 = 10'd250;
logic [9:0] bottomF3 = 10'd320;

logic [9:0] topF4 = 10'd340;
logic [9:0] bottomF4 = 10'd410;

logic [9:0] leftC1 = 10'd160;
logic [9:0] rightC1 = 10'd210;

logic [9:0] leftC2 = 10'd250;
logic [9:0] rightC2 = 10'd300;

logic [9:0] leftC3 = 10'd340;
logic [9:0] rightC3 = 10'd390;

logic [9:0] leftC4 = 10'd430;
logic [9:0] rightC4 = 10'd480;


// Cartas: coordenadas
    carta cartaA1(
        .x(x), .y(y), 
        .left(leftC1), .right(rightC1), 
        .top(topF1), .bot(bottomF1), 
        .incard(cA1)
    );
	 
	 carta cartaA2(
        .x(x), .y(y), 
        .left(leftC2), .right(rightC2), 
        .top(topF1), .bot(bottomF1), 
        .incard(cA2)
    );
	 


// Unión de ambos
assign cartas_total = cA1 | cA2;

always_comb begin
    // Fondo negro
    r = 8'h00;
    g = 8'h00;
    b = 8'h00;

    // Si está en cualquiera de los dos rectángulos
    if (cartas_total) begin
        r = 8'hFF;   // Rojo
        g = 8'h00;
        b = 8'hFF;
    end
end
	
endmodule
