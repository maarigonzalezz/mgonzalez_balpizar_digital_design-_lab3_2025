module carta(
    input logic [9:0] x, y, 
    input logic [9:0] left, right, top, bot, // cuadrado
	 input logic [4:0] formato,
    output logic incard,
	 output logic insymbol,
	 output logic inborder
);


logic inrect;
logic plus, minus, cros, circle, hash, square, trin, invtri, selSym, border;
logic [9:0] centerx, centery;
logic [2:0] symbol_sel;
logic [1:0] estado_carta;
	
	assign centerx = left + 10'd25;
	assign centery = top  + 10'd35; 
	assign symbol_sel = formato[4:2];
	assign estado_carta = formato[1:0];

    // Rectángulo de la carta
    rectgen rect_inst (
        .x(x), .y(y),
        .left(left), .right(right),
        .top(top), .bot(bot),
        .inrect(inrect)
    );
	 
	 // Borde externo
	rectborder #(.BORDER_WIDTH(2)) border_inst (
		 .x(x), .y(y),
		 .left(left - 2),  
		 .right(right + 2),
		 .top(top - 2),
		 .bot(bot + 2),
		 .inborder(border)
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
	
	square_symbol square_inst (
		 .x(x), .y(y),
		 .cx(centerx), .cy(centery), // centro de la carta
		 .insquare(square)
	);
	
	hash_symbol hash_inst (
		 .x(x), .y(y),
		 .cx(centerx), .cy(centery), // centro de la carta
		 .size(30),          // largo del símbolo
		 .t(4),              // grosor de las líneas
		 .inhash(hash)
	);
	
	circle_symbol circle_inst (
		 .x(x), .y(y),
		 .cx(centerx), .cy(centery), // centro de la carta
		 .radius(12),          // largo del símbolo
		 .t(4),              // grosor de las líneas
		 .incircle(circle)
	);
	
	triangle_symbol tri_inst (
		 .x(x), .y(y),
		 .cx(centerx), .cy(centery), // centro de la carta
		 .size(30),          // largo del símbolo
		 .t(5),              // grosor de las líneas
		 .intrin(trin)
	);
	
	invtriangle_symbol invtri_inst (
		 .x(x), .y(y),
		 .cx(centerx), .cy(centery), // centro de la carta
		 .size(30),          // largo del símbolo
		 .t(5),              // grosor de las líneas
		 .ininvtri(invtri)
	);
	
	 
	 // Decoder 2→8 con un mux
    always_comb begin
        case (symbol_sel)
            3'd0: selSym = plus;
            3'd1: selSym = minus;
            3'd2: selSym = cros;
            3'd3: selSym = square;
            3'd4: selSym = hash;
            3'd5: selSym = circle;
            3'd6: selSym = trin;
            3'd7: selSym = invtri;
            default: selSym = 1'b0;
        endcase
    end
	 
	 always_comb begin
		  inborder = 1'b0;
        case (estado_carta)
            2'b00: begin
                // no mostrar nada
                insymbol = 1'b0;
            end

            2'b01: begin
                insymbol = selSym;
					 inborder = 1'b1;
            end

            2'b10: begin
                // mostrar el símbolo seleccionado
                insymbol = selSym;
            end

            default: begin
                insymbol = 1'b0;
            end
        endcase
    end
	 
	 assign incard = inrect;
    
endmodule