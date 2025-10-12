module save_cards(
    input  logic clk, rst,
    input  logic load,
    input  logic [4:0] arr_in [0:15],
    output logic [4:0] arr_out [0:15]
);

	logic [4:0] arr_temp [0:15];
	
	
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            for (int i = 0; i < 16; i++) arr_out[i] <= '0;
        else if (load)
            arr_out <= arr_in;
    end
	 
endmodule 