module cartaA(
    input logic [9:0] x, y, 
    input logic [9:0] left, right, top, bot, // cuadrado
    output logic incard
);

logic inrect, incircle;

    // Rectángulo de la carta
    rectgen rect_inst (
        .x(x), .y(y),
        .left(left), .right(right),
        .top(top), .bot(bot),
        .inrect(inrect)
    );
	 
	 assign incard = inrect;
    
endmodule
