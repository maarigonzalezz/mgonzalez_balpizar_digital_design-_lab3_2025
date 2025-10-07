module start(input logic [9:0] x, y, 
					output logic [7:0] r, g, b);
					
	// Letras: I, N, I, C, I, O
    logic letter_I1, letter_N, letter_I2, letter_C, letter_I3, letter_O;

    // Coordenadas y tamaños de las letras
    logic [10:0] letter_width, letter_height;
    logic [10:0] I1_left, I1_right, N_left, N_right, I2_left, I2_right, 
                 C_left, C_right, I3_left, I3_right, O_left, O_right;
    logic [10:0] letter_top, letter_bottom;

    // --------------------------
    // Configuración inicial
    // --------------------------
    initial begin
        letter_width  = 10'd40;   // ancho de cada letra
        letter_height = 10'd80;   // alto de cada letra

        // posición inicial de la palabra
        I1_left = 10'd150;

        // separación entre letras = 10 píxeles
        N_left  = I1_left + letter_width + 10;
        I2_left = N_left  + letter_width + 10;
        C_left  = I2_left + letter_width + 10;
        I3_left = C_left  + letter_width + 10;
        O_left  = I3_left + letter_width + 10;

        // parte superior e inferior
        letter_top    = 10'd150;
        letter_bottom = letter_top + letter_height;
    end

    // Cálculo de bordes derechos
    always_comb begin
        I1_right = I1_left + letter_width;
        N_right  = N_left  + letter_width;
        I2_right = I2_left + letter_width;
        C_right  = C_left  + letter_width;
        I3_right = I3_left + letter_width;
        O_right  = O_left  + letter_width;
    end

    // --------------------------
    // Definición de cada letra
    // --------------------------
    always_comb begin
        // Letra I
        letter_I1 = ((x >= I1_left && x <= I1_right) && (y >= letter_top && y <= letter_bottom)) &&
                    ( (x == I1_left + letter_width/2) || (y == letter_top) || (y == letter_bottom) );

        // Letra N
        letter_N = ((x >= N_left && x <= N_right) && (y >= letter_top && y <= letter_bottom)) &&
                   ( (x == N_left) || (x == N_right) || (y - letter_top == (x - N_left)*letter_height/letter_width) );

        // Segunda I
        letter_I2 = ((x >= I2_left && x <= I2_right) && (y >= letter_top && y <= letter_bottom)) &&
                    ( (x == I2_left + letter_width/2) || (y == letter_top) || (y == letter_bottom) );

        // Letra C
        letter_C = ((x >= C_left && x <= C_right) && (y >= letter_top && y <= letter_bottom)) &&
                   ( (y == letter_top) || (y == letter_bottom) || (x == C_left) );

        // Tercera I
        letter_I3 = ((x >= I3_left && x <= I3_right) && (y >= letter_top && y <= letter_bottom)) &&
                    ( (x == I3_left + letter_width/2) || (y == letter_top) || (y == letter_bottom) );

        // Letra O
        letter_O = ((x >= O_left && x <= O_right) && (y >= letter_top && y <= letter_bottom)) &&
                   ( (y == letter_top) || (y == letter_bottom) || (x == O_left) || (x == O_right) );
    end

    // --------------------------
    // Asignación de color (verde brillante)
    // --------------------------
    assign r = (letter_I1 || letter_N || letter_I2 || letter_C || letter_I3 || letter_O) ? 8'hFF : 8'h87;
    assign g = (letter_I1 || letter_N || letter_I2 || letter_C || letter_I3 || letter_O) ? 8'hFF : 8'h0A;
    assign b = (letter_I1 || letter_N || letter_I2 || letter_C || letter_I3 || letter_O) ? 8'hFF : 8'h63;
endmodule
