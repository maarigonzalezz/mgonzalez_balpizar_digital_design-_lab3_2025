module circle_symbol (
    input  logic [9:0] x, y,        // coordenadas actuales del pixel
    input  logic [9:0] cx, cy,      // centro del símbolo
    input  logic [9:0] radius,        // largo total del símbolo (diámetro). si 0 -> usa radio=12
    input  logic [9:0] t,           // grosor de la línea (en píxeles)
    output logic incircle           // 1 si el pixel está en el círculo (borde)
);


    // medio grosor para calcular el anillo (usar shift -> truncado)
    logic [9:0] half_t;
    assign half_t = (t >> 1);

    // límites de radio (r - half_t) .. (r + half_t)
    logic [10:0] r_lo; // un bit extra para evitar underflow al restar
    logic [10:0] r_hi;
    assign r_lo = (radius > half_t) ? (radius - half_t) : 11'd0;
    assign r_hi = radius + half_t;

    // diferencias (signed) para evitar wrap cuando cx > x o viceversa
    logic signed [20:0] dx;
    logic signed [20:0] dy;
    assign dx = $signed({1'b0,x}) - $signed({1'b0,cx});
    assign dy = $signed({1'b0,y}) - $signed({1'b0,cy});

    // dist^2 = dx^2 + dy^2  (usar suficiente ancho)
    logic [41:0] dist2;
    logic [41:0] rlo2, rhi2;
    assign dist2 = $unsigned(dx * dx) + $unsigned(dy * dy);

    // cuadrados de los radios (anchos suficientes)
    assign rlo2 = $unsigned(r_lo) * $unsigned(r_lo);
    assign rhi2 = $unsigned(r_hi) * $unsigned(r_hi);

    // condición inclusiva: si la distancia al cuadrado está entre rlo2 y rhi2
    assign incircle = (dist2 >= rlo2) && (dist2 <= rhi2);

endmodule
