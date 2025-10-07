module top_shuffle (
    input  logic        clk,             // Reloj
    input  logic        rst,             // Reset
    input  logic        start,           // Inicia el shuffle
    output logic [79:0] out_cards_flat,  // Cartas barajadas
    output logic        done             // Indica que terminó el shuffle
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
        .out_cards_flat(out_cards_flat),
        .done(done)
    );
	 
endmodule
