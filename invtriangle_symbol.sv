module invtriangle_symbol (
    input  logic [9:0] x, y,        // coordenadas actuales del pixel
    input  logic [9:0] cx, cy,      // centro del símbolo
    input  logic [9:0] size,        // ancho total del triángulo (base)
    input  logic [9:0] t,           // grosor deseado del borde (píxeles)
    output logic ininvtri           // 1 si el pixel está en el borde del triángulo invertido
);

    // medias
    logic [9:0] half_size;
    logic [9:0] half_t;

    assign half_size = size >> 1; // truncado
    assign half_t    = t    >> 1;

    // Vértices externos (triángulo apuntando hacia abajo)
    // A = top-left, B = top-right, C = bottom (apex)
    logic signed [13:0] Ax, Ay, Bx, By, Cx_v, Cy_v;
    assign Ax   = $signed({1'b0, cx}) - $signed({1'b0, half_size}); // cx - half_size
    assign Bx   = $signed({1'b0, cx}) + $signed({1'b0, half_size}); // cx + half_size
    assign Ay   = $signed({1'b0, cy}) - $signed({1'b0, half_size}); // top y
    assign By   = Ay;
    assign Cx_v = $signed({1'b0, cx});                               // apex x = cx
    assign Cy_v = $signed({1'b0, cy}) + $signed({1'b0, half_size}); // apex y below

    // Punto P (x,y) como signed
    logic signed [13:0] Px, Py;
    assign Px = $signed({1'b0, x});
    assign Py = $signed({1'b0, y});

    // Función sign (cross product) para las 3 aristas (sin divides)
    logic signed [31:0] s1_ext, s2_ext, s3_ext;
    assign s1_ext = (Px - Bx) * (Ay - By) - (Py - By) * (Ax - Bx); // edge AB (top edge)
    assign s2_ext = (Px - Cx_v) * (By - Cy_v) - (Py - Cy_v) * (Bx - Cx_v); // edge BC (right)
    assign s3_ext = (Px - Ax) * (Cy_v - Ay) - (Py - Ay) * (Cx_v - Ax); // edge CA (left)

    // Vértices internos (triángulo reducido) para crear el borde
    logic signed [13:0] Aix, Aiy, Bix, Biy, Cix, Ciy;
    assign Aix = Ax + $signed({1'b0, half_t});
    assign Aiy = Ay + $signed({1'b0, half_t});
    assign Bix = Bx - $signed({1'b0, half_t});
    assign Biy = By + $signed({1'b0, half_t});
    assign Cix = Cx_v;
    assign Ciy = Cy_v - $signed({1'b0, half_t});

    // signos internos
    logic signed [31:0] s1_in, s2_in, s3_in;
    assign s1_in = (Px - Bix) * (Aiy - Biy) - (Py - Biy) * (Aix - Bix);
    assign s2_in = (Px - Cix) * (Biy - Ciy) - (Py - Ciy) * (Bix - Cix);
    assign s3_in = (Px - Aix) * (Ciy - Aiy) - (Py - Aiy) * (Cix - Aix);

    // calculo combinacional en always_comb (evita inicializaciones no permitidas)
    logic inside_ext, inside_in;
    always_comb begin
        inside_ext = ( (s1_ext >= 0 && s2_ext >= 0 && s3_ext >= 0) ||
                       (s1_ext <= 0 && s2_ext <= 0 && s3_ext <= 0) );

        inside_in  = ( (s1_in >= 0 && s2_in >= 0 && s3_in >= 0) ||
                       (s1_in <= 0 && s2_in <= 0 && s3_in <= 0) );

        // borde = dentro del triángulo externo pero no dentro del triángulo interno
        ininvtri = inside_ext && !inside_in;
    end

endmodule
