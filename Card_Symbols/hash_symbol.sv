module hash_symbol (
    input  logic [9:0] x, y,        // coordenadas actuales del pixel
    input  logic [9:0] cx, cy,      // centro del símbolo
    input  logic [9:0] size,        // largo total del símbolo
    input  logic [9:0] t,           // grosor de la línea
    output logic inhash             // 1 si el pixel está en el "#"
);

    // variables auxiliares
    logic [9:0] half_size, half_t, quarter_size;
    logic signed [13:0] xmin_h1, xmax_h1, ymin_h1, ymax_h1; // hor bar 1
    logic signed [13:0] xmin_h2, xmax_h2, ymin_h2, ymax_h2; // hor bar 2
    logic signed [13:0] xmin_v1, xmax_v1, ymin_v1, ymax_v1; // vert bar 1
    logic signed [13:0] xmin_v2, xmax_v2, ymin_v2, ymax_v2; // vert bar 2

    // cálculos simples (shift para dividir por 2 y por 4)
    assign half_size   = size >> 1;
    assign half_t      = t    >> 1;
    assign quarter_size = size >> 2; // aproximación para separar las barras

    // horizontales: dos barras separadas verticalmente alrededor del centro
    // primera barra (arriba)
    assign xmin_h1 = $signed({1'b0, cx}) - $signed({3'b0, half_size});
    assign xmax_h1 = $signed({1'b0, cx}) + $signed({3'b0, half_size});
    assign ymin_h1 = $signed({1'b0, cy}) - $signed({3'b0, quarter_size}) - $signed({3'b0, half_t});
    assign ymax_h1 = $signed({1'b0, cy}) - $signed({3'b0, quarter_size}) + $signed({3'b0, half_t});

    // segunda barra (abajo)
    assign xmin_h2 = xmin_h1;
    assign xmax_h2 = xmax_h1;
    assign ymin_h2 = $signed({1'b0, cy}) + $signed({3'b0, quarter_size}) - $signed({3'b0, half_t});
    assign ymax_h2 = $signed({1'b0, cy}) + $signed({3'b0, quarter_size}) + $signed({3'b0, half_t});

    // verticales: dos barras separadas horizontalmente alrededor del centro
    // primera barra (izq)
    assign xmin_v1 = $signed({1'b0, cx}) - $signed({3'b0, quarter_size}) - $signed({3'b0, half_t});
    assign xmax_v1 = $signed({1'b0, cx}) - $signed({3'b0, quarter_size}) + $signed({3'b0, half_t});
    assign ymin_v1 = $signed({1'b0, cy}) - $signed({3'b0, half_size});
    assign ymax_v1 = $signed({1'b0, cy}) + $signed({3'b0, half_size});

    // segunda barra (der)
    assign xmin_v2 = $signed({1'b0, cx}) + $signed({3'b0, quarter_size}) - $signed({3'b0, half_t});
    assign xmax_v2 = $signed({1'b0, cx}) + $signed({3'b0, quarter_size}) + $signed({3'b0, half_t});
    assign ymin_v2 = ymin_v1;
    assign ymax_v2 = ymax_v1;

    // condiciones inclusivas (<=) para que t = 1 funcione
    wire in_h1 = ( $signed({1'b0,x}) >= xmin_h1 ) && ( $signed({1'b0,x}) <= xmax_h1 ) &&
                 ( $signed({1'b0,y}) >= ymin_h1 ) && ( $signed({1'b0,y}) <= ymax_h1 );

    wire in_h2 = ( $signed({1'b0,x}) >= xmin_h2 ) && ( $signed({1'b0,x}) <= xmax_h2 ) &&
                 ( $signed({1'b0,y}) >= ymin_h2 ) && ( $signed({1'b0,y}) <= ymax_h2 );

    wire in_v1 = ( $signed({1'b0,x}) >= xmin_v1 ) && ( $signed({1'b0,x}) <= xmax_v1 ) &&
                 ( $signed({1'b0,y}) >= ymin_v1 ) && ( $signed({1'b0,y}) <= ymax_v1 );

    wire in_v2 = ( $signed({1'b0,x}) >= xmin_v2 ) && ( $signed({1'b0,x}) <= xmax_v2 ) &&
                 ( $signed({1'b0,y}) >= ymin_v2 ) && ( $signed({1'b0,y}) <= ymax_v2 );

    assign inhash = in_h1 | in_h2 | in_v1 | in_v2;

endmodule
