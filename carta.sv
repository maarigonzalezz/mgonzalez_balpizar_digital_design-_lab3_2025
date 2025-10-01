module carta(
    input logic [9:0] x, y, 
    input logic [9:0] left, right, top, bot, // cuadrado
	 input  logic [2:0] symbol_sel,            // selector de símbolo
    output logic incard,
	 output logic insymbol
);

logic inrect;
logic plus, minus, cros, circle, hash, square, trin, invtri;
logic [9:0] centerx, centery;
	
	assign centerx = left + 10'd25;
	assign centery = top  + 10'd35; 

    // Rectángulo de la carta
    rectgen rect_inst (
        .x(x), .y(y),
        .left(left), .right(right),
        .top(top), .bot(bot),
        .inrect(inrect)
    );
	 
	 // Instancias de todos los símbolos
	 plus_symbol plus_inst (
		 .x(x), .y(y),
		 .cx(centerx), .cy(centery), // centro de la carta
		 .size(30),          // largo del símbolo
		 .t(4),              // grosor de las líneas
		 .inplus(plus)
	);
	
	minus_symbol minus_inst (
		 .x(x), .y(y),
		 .cx(centerx), .cy(centery), // centro de la carta
		 .size(30),          // largo del símbolo
		 .t(4),              // grosor de las líneas
		 .inminus(minus)
	);
	
	cros_symbol cros_inst (
		 .x(x), .y(y),
		 .cx(centerx), .cy(centery), // centro de la carta
		 .size(30),          // largo del símbolo
		 .t(4),              // grosor de las líneas
		 .incros(cros)
	);
	 
	 // Decoder 2→8 con un mux
    always_comb begin
        case (symbol_sel)
            3'd0: insymbol = plus;
            3'd1: insymbol = minus;
            3'd2: insymbol = cros;
            //3'd3: insymbol = circle;
            //3'd4: insymbol = hash;
            //3'd5: insymbol = square;
            //3'd6: insymbol = trin;
            //3'd7: insymbol = invtri;
            default: insymbol = 1'b0;
        endcase
    end
	 
	 assign incard = inrect;
    
endmodule