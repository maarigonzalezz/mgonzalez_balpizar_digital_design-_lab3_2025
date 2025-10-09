module modify_arr(
    input  logic [1:0] estado,
    output logic [4:0] arrI [0:15]
);

    int num;

    always_comb begin
        num = 3'd0;

        for (int i = 0; i <= 15; i += 2) begin
            arrI[i][4:2]   = num[2:0];
            arrI[i][1:0]   = estado;
            arrI[i+1][4:2] = num[2:0];
            arrI[i+1][1:0] = estado;
            num += 1;
        end
    end

endmodule
