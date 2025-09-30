// Modulo para la creacion del rectangulo de test

module rectgen(
    input logic [9:0] x, y, left, right, top, bot,
    output logic inrect
);
    assign inrect = (x >= left & x < right & y >= top & y < bot);
endmodule
