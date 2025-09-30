// Módulo: contador de segundos
// Genera un pulso de 1 ciclo de reloj cada segundo real
module clk_counter_seg #(
    parameter CLOCK_FREQ_HZ = 50_000_000  // Frecuencia del reloj principal (por defecto 50 MHz)
)(
    input  logic clk,       // Reloj principal
    input  logic rst,       // Reset síncrono/asincrónico
    output logic pulse_1s   // Pulso de 1 segundo
);

    // Número de ciclos necesarios para generar 1 segundo
    localparam CYCLES_PER_SECOND = CLOCK_FREQ_HZ;

    // Contador interno de ciclos de reloj
    logic [$clog2(CYCLES_PER_SECOND)-1:0] cycle_counter;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cycle_counter <= 0;
            pulse_1s <= 0;
        end else begin
            if (cycle_counter == CYCLES_PER_SECOND-1) begin
                cycle_counter <= 0;
                pulse_1s <= 1;       // Pulso de 1 segundo
            end else begin
                cycle_counter <= cycle_counter + 1;
                pulse_1s <= 0;
            end
        end
    end

endmodule