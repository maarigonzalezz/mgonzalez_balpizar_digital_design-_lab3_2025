//CLK
module clkCounter(input logic clk, rst,
                  output logic t0);

    logic [7:0] cycles;  // Contador de ciclos

    // Contar ciclos de reloj y generar t0
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset del contador de ciclos y la señal t0
            cycles = 0;
            t0 = 0;
        end
        else begin
            cycles = cycles + 1;
            
            // Cuando se alcanzan 200 ciclos, resetear el contador y activar t0
            if (cycles == 200) begin
                cycles = 0;
                t0 = 1;
            end
        end
    end
endmodule
