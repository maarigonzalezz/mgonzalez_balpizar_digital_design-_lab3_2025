module posedge_detector (
    input  logic clk,       // Reloj del sistema
    input  logic rst,       // Reset síncrono/asincrónico
    input  logic sig_in,    // Señal a detectar
    output logic pulse_out  // Pulso garantizado de un ciclo
);

    // Registro para almacenar el valor anterior de la señal
    logic sig_ff;

    // Registro del valor previo
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            sig_ff <= 0;
        else
            sig_ff <= sig_in;
    end

    // Pulso de un ciclo cuando la señal sube de 0 → 1
    assign pulse_out = sig_in & ~sig_ff;

endmodule
