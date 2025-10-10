module BinTo7Seg (
    input  logic [3:0] bin,
    output logic [6:0] bin_to_7seg
);
    always_comb begin
        case (bin)
            4'd0: bin_to_7seg = 7'b1000000; // 0
            4'd1: bin_to_7seg = 7'b1111001; // 1
            4'd2: bin_to_7seg = 7'b0100100; // 2
            4'd3: bin_to_7seg = 7'b0110000; // 3
            4'd4: bin_to_7seg = 7'b0011001; // 4
            4'd5: bin_to_7seg = 7'b0010010; // 5
            4'd6: bin_to_7seg = 7'b0000010; // 6
            4'd7: bin_to_7seg = 7'b1111000; // 7
            4'd8: bin_to_7seg = 7'b0000000; // 8
            4'd9: bin_to_7seg = 7'b0010000; // 9
            default: bin_to_7seg = 7'b1111111; // Error
        endcase
    end
endmodule

