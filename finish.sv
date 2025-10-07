module finish (
    input  logic [9:0] x, y,        // coordenadas del pixel
    input  logic [1:0] ganador,     // 00 ninguno, 01 J1, 10 J2, 11 empate
    output logic [7:0] r, g, b      // color del pixel
);
    // Letras para "GANADOR"
    logic letter_G, letter_A1, letter_N, letter_A2, letter_D, letter_O, letter_R;

    // Letras para J1 / J2 / E
    logic letter_J, letter_1, letter_2, letter_E;

    // Posiciones y tamaños
    logic [10:0] letter_width, letter_height;
    logic [10:0] top_word_left;
    logic [10:0] bottom_word_left;
    logic [10:0] top_y, bottom_y, bottom_letter_top;

    initial begin
        letter_width  = 10'd40;
        letter_height = 10'd80;

        // posición de la palabra GANADOR
        top_word_left = 10'd120;
        top_y = 10'd100;

        // posición de la palabra inferior (J1, J2, E)
        bottom_word_left = 10'd260;
        bottom_y = 10'd250;
    end

    // límites verticales
    logic [10:0] top_bottom_y;
    assign top_bottom_y = top_y + letter_height;
    assign bottom_letter_top = bottom_y;
    logic [10:0] bottom_letter_bottom;
	 assign bottom_letter_bottom = bottom_y + letter_height;

    // --------------------------------------------
    // "GANADOR"
    // --------------------------------------------
    always_comb begin
        // Letra G
        letter_G = ((x >= top_word_left && x <= top_word_left + letter_width) &&
                    (y >= top_y && y <= top_bottom_y)) &&
                   ( (y == top_y) || (y == top_bottom_y) || (x == top_word_left) ||
                     ((y >= top_y + letter_height/2) && (x == top_word_left + letter_width)) ||
                     (y == top_y + letter_height/2 && x >= top_word_left + letter_width/2) );

        // Letra A1
        letter_A1 = ((x >= top_word_left + 50 && x <= top_word_left + 90) &&
                     (y >= top_y && y <= top_bottom_y)) &&
                    ( (y == top_y) ||
                      (x == top_word_left + 50) ||
                      (x == top_word_left + 90) ||
                      (y == top_y + letter_height/2 && x >= top_word_left + 55 && x <= top_word_left + 85) );

        // Letra N
        letter_N = ((x >= top_word_left + 100 && x <= top_word_left + 140) &&
                    (y >= top_y && y <= top_bottom_y)) &&
                   ( (x == top_word_left + 100) ||
                     (x == top_word_left + 140) ||
                     (y - top_y == (x - (top_word_left + 100))*letter_height/letter_width) );

        // Letra A2
        letter_A2 = ((x >= top_word_left + 150 && x <= top_word_left + 190) &&
                     (y >= top_y && y <= top_bottom_y)) &&
                    ( (y == top_y) ||
                      (x == top_word_left + 150) ||
                      (x == top_word_left + 190) ||
                      (y == top_y + letter_height/2 && x >= top_word_left + 155 && x <= top_word_left + 185) );

        // Letra D
        letter_D = ((x >= top_word_left + 200 && x <= top_word_left + 240) &&
                    (y >= top_y && y <= top_bottom_y)) &&
                   ( (x == top_word_left + 200) ||
                     (y == top_y) ||
                     (y == top_bottom_y) ||
                     (x == top_word_left + 240 && y >= top_y && y <= top_bottom_y) );

        // Letra O
        letter_O = ((x >= top_word_left + 250 && x <= top_word_left + 290) &&
                    (y >= top_y && y <= top_bottom_y)) &&
                   ( (x == top_word_left + 250) ||
                     (x == top_word_left + 290) ||
                     (y == top_y) ||
                     (y == top_bottom_y) );

        // Letra R
        letter_R = ((x >= top_word_left + 300 && x <= top_word_left + 340) &&
                    (y >= top_y && y <= top_bottom_y)) &&
                   ( (x == top_word_left + 300) ||
                     (y == top_y) ||
                     (y == top_y + letter_height/2) ||
                     (x == top_word_left + 340 && y <= top_y + letter_height/2) ||
                     (y - (top_y + letter_height/2) == (x - (top_word_left + 300))*letter_height/letter_width) );
    end

    // --------------------------------------------
    // Segundo texto según “ganador”
    // --------------------------------------------
    always_comb begin
        letter_J = 0;
        letter_1 = 0;
        letter_2 = 0;
        letter_E = 0;

        case (ganador)
            2'b01: begin // Jugador 1
                // Letra J
                letter_J = ((x >= bottom_word_left && x <= bottom_word_left + 40) &&
                            (y >= bottom_letter_top && y <= bottom_letter_bottom)) &&
                           ( (y == bottom_letter_top) ||
                             (x == bottom_word_left + 20 && y < bottom_letter_bottom) ||
                             (y == bottom_letter_bottom && x <= bottom_word_left + 20) );

                // Número 1
                letter_1 = ((x >= bottom_word_left + 60 && x <= bottom_word_left + 100) &&
                            (y >= bottom_letter_top && y <= bottom_letter_bottom)) &&
                           ( (x == bottom_word_left + 80) || (y == bottom_letter_top) );
            end

            2'b10: begin // Jugador 2
                // Letra J
                letter_J = ((x >= bottom_word_left && x <= bottom_word_left + 40) &&
                            (y >= bottom_letter_top && y <= bottom_letter_bottom)) &&
                           ( (y == bottom_letter_top) ||
                             (x == bottom_word_left + 20 && y < bottom_letter_bottom) ||
                             (y == bottom_letter_bottom && x <= bottom_word_left + 20) );

                // Número 2
                letter_2 = ((x >= bottom_word_left + 60 && x <= bottom_word_left + 100) &&
                            (y >= bottom_letter_top && y <= bottom_letter_bottom)) &&
                           ( (y == bottom_letter_top) || (y == bottom_letter_bottom) ||
                             (x == bottom_word_left + 100 && y <= bottom_letter_top + 40) ||
                             (x == bottom_word_left + 60 && y >= bottom_letter_top + 40) ||
                             (y == bottom_letter_top + 40 && x >= bottom_word_left + 60 && x <= bottom_word_left + 100) );
            end

            2'b11: begin // Empate -> E
                letter_E = ((x >= bottom_word_left + 40 && x <= bottom_word_left + 80) &&
                            (y >= bottom_letter_top && y <= bottom_letter_bottom)) &&
                           ( (x == bottom_word_left + 40) ||
                             (y == bottom_letter_top) ||
                             (y == bottom_letter_bottom) ||
                             (y == bottom_letter_top + letter_height/2) );
            end

            default: begin
                letter_J = 0;
                letter_1 = 0;
                letter_2 = 0;
                letter_E = 0;
            end
        endcase
    end

    // --------------------------------------------
    // Asignar color: Verde para "GANADOR", Rojo para el resultado
    // --------------------------------------------
    assign r = (letter_J || letter_1 || letter_2 || letter_E) ? 8'hFF :
               (letter_G || letter_A1 || letter_N || letter_A2 || letter_D || letter_O || letter_R) ? 8'h00 : 8'h00;

    assign g = (letter_G || letter_A1 || letter_N || letter_A2 || letter_D || letter_O || letter_R) ? 8'hFF : 8'h00;

    assign b = (letter_J || letter_1 || letter_2 || letter_E) ? 8'h00 :
               (letter_G || letter_A1 || letter_N || letter_A2 || letter_D || letter_O || letter_R) ? 8'h00 : 8'h00;

endmodule
					