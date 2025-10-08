module top_mostrar_carta_random (
    input  logic        clk,             // Reloj
    input  logic        rst,             // Reset
    input  logic        start,           // Inicia la actualización de cartas
    input  logic [4:0]  arr_cards_in [0:15], // Array de entrada
    output logic [4:0]  arr_cards_out [0:15], // Array de salida
    output logic        done             // Señal de finalización
);

    // ------------------------------------------------------------------------
    // Semilla pseudoaleatoria generada por bit_shifter
    // ------------------------------------------------------------------------
    logic [7:0] seed;

    bit_shifter bs (
        .clk(clk),
        .rst(rst),
        .data(seed)
    );

    // ------------------------------------------------------------------------
    // Instancia de mostrar_carta_random
    // ------------------------------------------------------------------------
    mostrar_carta_random mcr (
        .clk(clk),
        .rst(rst),
        .start(start),
        .seed(seed),
        .arr_cards_in(arr_cards_in),
        .arr_cards_out(arr_cards_out),
        .done(done)
    );

endmodule
