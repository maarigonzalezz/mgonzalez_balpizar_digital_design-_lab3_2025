module minus_symbol (
    input  logic [9:0] x, y,        // coordenadas actuales del pixel
    input  logic [9:0] cx, cy,      // centro del símbolo
    input  logic [9:0] size,        // largo total del símbolo (p. ej. 30)
    input  logic [9:0] t,           // grosor de la línea (p. ej. 1..5)
    output logic inminus             // 1 si el pixel está en el "-"
);

    // usamos más bits y signed para los cálculos de límites
    logic [9:0] half_size, half_t;
    logic signed [12:0] xmin_h, xmax_h, ymin_h, ymax_h; // horizontal bar bounds

    // división por 2: shift (trunca hacia abajo)
    assign half_size = size >> 1;
    assign half_t    = t    >> 1;

    // límites de la barra horizontal (ancho = size, alto = t)
    assign xmin_h = $signed({1'b0, cx}) - $signed({3'b0, half_size});
    assign xmax_h = $signed({1'b0, cx}) + $signed({3'b0, half_size});
    assign ymin_h = $signed({1'b0, cy}) - $signed({3'b0, half_t});
    assign ymax_h = $signed({1'b0, cy}) + $signed({3'b0, half_t});


    // condición: incluir ambos extremos (<=) para permitir grosor 1
    wire in_hbar = ( $signed({1'b0,x}) >= xmin_h ) && ( $signed({1'b0,x}) <= xmax_h ) &&
                   ( $signed({1'b0,y}) >= ymin_h ) && ( $signed({1'b0,y}) <= ymax_h );


    assign inminus = in_hbar;

endmodule