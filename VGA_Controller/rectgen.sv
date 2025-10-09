// Modulo para la creacion del rectangulo con circulo adentro

module rectgen(
    input logic [9:0] x, y, 
    input logic [9:0] left, right, top, bot, // cuadrado
    output logic inrect
);

    // Lógica del rectángulo
    assign inrect = (x >= left & x < right & y >= top & y < bot);
endmodule
