module plus_symbol (
    input  logic [9:0] x, y,        // coordenadas actuales del pixel
    input  logic [9:0] cx, cy,      // centro del símbolo
    input  logic [9:0] size,        // largo total del símbolo (p. ej. 30)
    input  logic [9:0] t,           // grosor de la línea (p. ej. 1..5)
    output logic inplus             // 1 si el pixel está en el "+"
);

    // usamos más bits y signed para los cálculos de límites
    logic [9:0] half_size, half_t;
    logic signed [12:0] xmin_h, xmax_h, ymin_h, ymax_h; // horizontal bar bounds
    logic signed [12:0] xmin_v, xmax_v, ymin_v, ymax_v; // vertical bar bounds

    // división por 2: shift (trunca hacia abajo)
    assign half_size = size >> 1;
    assign half_t    = t    >> 1;

    // límites de la barra horizontal (ancho = size, alto = t)
    assign xmin_h = $signed({1'b0, cx}) - $signed({3'b0, half_size});
    assign xmax_h = $signed({1'b0, cx}) + $signed({3'b0, half_size});
    assign ymin_h = $signed({1'b0, cy}) - $signed({3'b0, half_t});
    assign ymax_h = $signed({1'b0, cy}) + $signed({3'b0, half_t});

    // límites de la barra vertical (ancho = t, alto = size)
    assign xmin_v = $signed({1'b0, cx}) - $signed({3'b0, half_t});
    assign xmax_v = $signed({1'b0, cx}) + $signed({3'b0, half_t});
    assign ymin_v = $signed({1'b0, cy}) - $signed({3'b0, half_size});
    assign ymax_v = $signed({1'b0, cy}) + $signed({3'b0, half_size});

    // condición: incluir ambos extremos (<=) para permitir grosor 1
    wire in_hbar = ( $signed({1'b0,x}) >= xmin_h ) && ( $signed({1'b0,x}) <= xmax_h ) &&
                   ( $signed({1'b0,y}) >= ymin_h ) && ( $signed({1'b0,y}) <= ymax_h );

    wire in_vbar = ( $signed({1'b0,x}) >= xmin_v ) && ( $signed({1'b0,x}) <= xmax_v ) &&
                   ( $signed({1'b0,y}) >= ymin_v ) && ( $signed({1'b0,y}) <= ymax_v );

    assign inplus = in_hbar | in_vbar;

endmodule

