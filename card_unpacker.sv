module card_unpacker (
    input  logic [79:0] out_cards_flat,     // 16 cartas * 5 bits
    output logic [4:0]  arr_cards [0:15]    // Arreglo 16x5
);
    integer i;

    always_comb begin
        for (i = 0; i < 16; i++) begin
            // Tomar de los bits más altos hacia los más bajos
            arr_cards[i] = out_cards_flat[79 - i*5 -: 5];
        end
    end
endmodule