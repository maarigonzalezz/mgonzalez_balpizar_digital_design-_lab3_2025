module rectborder #(
    parameter int BORDER_WIDTH = 1  // Grosor del borde (en píxeles)
)(
    input  logic [9:0] x, y,        // Coordenadas actuales del píxel VGA
    input  logic [9:0] left, right, // Límites horizontales del rectángulo
    input  logic [9:0] top, bot,    // Límites verticales del rectángulo
    output logic inborder           // 1 si el píxel está en el borde
);
    always_comb begin
        inborder = 1'b0;

        // Borde superior (encima del rectángulo)
        if ((y >= top - BORDER_WIDTH) && (y < top) &&
            (x >= left - BORDER_WIDTH) && (x <= right + BORDER_WIDTH))
            inborder = 1'b1;

        // Borde inferior (debajo del rectángulo)
        else if ((y > bot) && (y <= bot + BORDER_WIDTH) &&
                 (x >= left - BORDER_WIDTH) && (x <= right + BORDER_WIDTH))
            inborder = 1'b1;

        // Borde izquierdo (a la izquierda del rectángulo)
        else if ((x >= left - BORDER_WIDTH) && (x < left) &&
                 (y >= top - BORDER_WIDTH) && (y <= bot + BORDER_WIDTH))
            inborder = 1'b1;

        // Borde derecho (a la derecha del rectángulo)
        else if ((x > right) && (x <= right + BORDER_WIDTH) &&
                 (y >= top - BORDER_WIDTH) && (y <= bot + BORDER_WIDTH))
            inborder = 1'b1;
    end
endmodule
