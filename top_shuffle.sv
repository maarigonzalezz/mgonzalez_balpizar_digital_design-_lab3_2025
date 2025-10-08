module top_shuffle (
    input  logic        clk,             // Reloj
    input  logic        rst,             // Reset
    input  logic        start,           // Inicia el shuffle
    output logic        done,            // Indica que terminó el shuffle
    output logic [4:0]  arr_cards [0:15] // Arreglo de cartas barajadas
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
    // Instancia del Shuffle secuencial
    // ------------------------------------------------------------------------
    Shuffle sh (
        .clk(clk),
        .rst(rst),
        .start(start),
        .seed(seed),
        .arr_cards(arr_cards), // salida directa en arreglo
        .done(done)
    );

endmodule