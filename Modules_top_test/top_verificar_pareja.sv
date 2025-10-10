
module top_verificar_pareja (
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic [4:0] arr_cards_in [0:15],
    output logic [4:0] arr_cards_out [0:15],
    output logic done,
    output logic hubo_pareja
);

	//Consideracion, es recomandable aplicar un rst antes de usarlo

    // Instancia del módulo principal
    verificar_pareja uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .arr_cards_in(arr_cards_in),
        .arr_cards_out(arr_cards_out),
        .done(done),
        .hubo_pareja(hubo_pareja)
    );

endmodule
