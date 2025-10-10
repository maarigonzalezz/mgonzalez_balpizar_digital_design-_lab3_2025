module card_controller(
    input  logic clk,
    input  logic rst,
    input  logic [3:0] state,
    input logic [4:0] arr_in [0:15],
    output logic [4:0] arr_out [0:15],
    output logic doneSh, doneMcr, load
);
    
    logic [7:0] seed;
    logic [4:0] arr_Sh [0:15];
    logic [4:0] arr_Sel [0:15];
    logic [4:0] arr_Mcr [0:15];
    logic done_Shuffle;
    logic startS;
    
    bit_shifter bs (.clk(clk), .rst(rst), .data(seed));
    Shuffle sh(.clk(clk), .rst(rst), .start(startS), .seed(seed), .arr_cards(arr_Sh), .done(done_Shuffle));
    mostrar_carta_random mcr (.clk(clk), .rst(rst), .start(startMcr), .seed(seed), .arr_cards_in(arr_Sel),
                             .arr_cards_out(arr_Mcr), .done(doneMcr));

endmodule 