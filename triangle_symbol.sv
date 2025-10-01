module triangle_symbol (
    input  logic [9:0] x, y,        // coordenadas actuales del pixel
    input  logic [9:0] cx, cy,      // centro del símbolo
    input  logic [9:0] size,        // ancho total del triángulo (base)
    input  logic [9:0] t,           // grosor deseado del borde (píxeles)
    output logic intrin             // 1 si el pixel está en el borde del triángulo
);

    // mitades
    logic [9:0] half_size;
    logic [9:0] half_t;

    assign half_size = size >> 1; // truncado hacia abajo
    assign half_t    = t    >> 1;

    // Vértices externos (triángulo apuntando hacia arriba)
    // A = bottom-left, B = bottom-right, C = top
    logic signed [13:0] Ax, Ay, Bx, By, Cx_v, Cy_v;
    // base at cy + half_size/2, top at cy - half_size/2 (aprox)
    assign Ax   = $signed({1'b0, cx}) - $signed({1'b0, half_size}); // cx - half_size
    assign Bx   = $signed({1'b0, cx}) + $signed({1'b0, half_size}); // cx + half_size
    assign Ay   = $signed({1'b0, cy}) + $signed({1'b0, half_size}); // base y
    assign By   = Ay;
    assign Cx_v = $signed({1'b0, cx});                               // apex x = cx
    assign Cy_v = $signed({1'b0, cy}) - $signed({1'b0, half_size}); // apex y

    // Punto P (x,y) como signed
    logic signed [13:0] Px, Py;
    assign Px = $signed({1'b0, x});
    assign Py = $signed({1'b0, y});

    // Función sign (barycentric tests) usando cross product (no divide)
    // sign(P, A, B) = (Px - Bx)*(Ay - By) - (Py - By)*(Ax - Bx)
    logic signed [31:0] s1_ext, s2_ext, s3_ext;
    assign s1_ext = (Px - Bx) * (Ay - By) - (Py - By) * (Ax - Bx); // relative to edge AB
    assign s2_ext = (Px - Cx_v) * (By - Cy_v) - (Py - Cy_v) * (Bx - Cx_v); // edge BC
    assign s3_ext = (Px - Ax) * (Cy_v - Ay) - (Py - Ay) * (Cx_v - Ax); // edge CA

    // Vértices internos (aproximación simple moviendo vértices hacia el centro)
    // movemos base hacia arriba y los extremos hacia el centro x en half_t,
    // movemos la cumbre hacia abajo en half_t
    logic signed [13:0] Aix, Aiy, Bix, Biy, Cix, Ciy;
    assign Aix = Ax + $signed({1'b0, half_t});
    assign Aiy = Ay - $signed({1'b0, half_t});
    assign Bix = Bx - $signed({1'b0, half_t});
    assign Biy = By - $signed({1'b0, half_t});
    assign Cix = Cx_v;
    assign Ciy = Cy_v + $signed({1'b0, half_t});

    // signos internos
    logic signed [31:0] s1_in, s2_in, s3_in;
    assign s1_in = (Px - Bix) * (Aiy - Biy) - (Py - Biy) * (Aix - Bix);
    assign s2_in = (Px - Cix) * (Biy - Ciy) - (Py - Ciy) * (Bix - Cix);
    assign s3_in = (Px - Aix) * (Ciy - Aiy) - (Py - Aiy) * (Cix - Aix);

    // señales de salida calculadas en always_comb (evita inicializaciones no constantes)
    logic inside_ext, inside_in;

    always_comb begin
        // punto dentro triángulo externo si los 3 signos son todos >=0 o todos <=0
        inside_ext = ( (s1_ext >= 0 && s2_ext >= 0 && s3_ext >= 0) ||
                       (s1_ext <= 0 && s2_ext <= 0 && s3_ext <= 0) );

        inside_in  = ( (s1_in >= 0 && s2_in >= 0 && s3_in >= 0) ||
                       (s1_in <= 0 && s2_in <= 0 && s3_in <= 0) );

        // borde: dentro del triángulo externo pero no dentro del interno
        intrin = inside_ext && !inside_in;
    end

endmodule
