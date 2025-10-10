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
    logic done_Shuffle;
    logic startS;
    logic shuffle_active;
    
    // Instancias
    bit_shifter bs (.clk(clk), .rst(rst), .data(seed));
    Shuffle sh(.clk(clk), .rst(rst), .start(startS), .seed(seed), .arr_cards(arr_Sh), .done(done_Shuffle));
	 
	 // Control del shuffle basado en el estado de la FSM
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            startS <= 0;
            doneSh <= 0;
            shuffle_active <= 0;
            // Inicializar arrays
            for (int i = 0; i < 16; i++) begin
                arr_out[i] <= arr_in[i];
            end
        end else begin
            // Reset señal doneSh cada ciclo
            doneSh <= 0;
            
            // Detectar cuando entramos al estado de revolver (4'b0011)
            if (state == 4'b0011 && !shuffle_active) begin
                // Iniciar shuffle
                startS <= 1;
                shuffle_active <= 1;
            end else begin
                startS <= 0;
            end
            
            // Cuando el shuffle termina
            if (done_Shuffle && shuffle_active) begin
                // Copiar resultado del shuffle a la salida
                for (int i = 0; i < 16; i++) begin
                    arr_out[i] <= arr_Sh[i];
                end
                doneSh <= 1;
					 load <= 1;
                shuffle_active <= 0;
            end
            
            // Si no estamos en shuffle, pasar through del input
            if (!shuffle_active && state != 4'b0011) begin
                for (int i = 0; i < 16; i++) begin
                    arr_out[i] <= arr_in[i];
                end
            end
        end
    end

endmodule 