// -------------------------
// Módulo Top Level
// -------------------------
module top_7seg_counter (
    input  logic clk,       // Reloj principal (ej: 50 MHz en FPGA real)
    input  logic rst,       // Reset asíncrono
    output logic [6:0] seg, // Segmentos del display (a-g)
    output logic [3:0] an   // Ánodos del display (solo 1 display activo)
);

    // -------------------------
    // Señales internas
    // -------------------------
    logic pulse_1s;          // Pulso de 1 segundo
    logic [3:0] counter_hex; // Contador 0-F

    // -------------------------
    // Instancia del contador de 1 segundo
    // -------------------------
    clk_counter_seg #(
        .CLOCK_FREQ_HZ(50_000_000) // Valor real para FPGA
    ) u_clk_counter (
        .clk(clk),
        .rst(rst),
        .pulse_1s(pulse_1s)
    );

    // -------------------------
    // Contador hexadecimal (0-F)
    // -------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_hex <= 0;
        end else if (pulse_1s) begin
            if (counter_hex == 4'hF)
                counter_hex <= 0;
            else
                counter_hex <= counter_hex + 1;
        end
    end

    // -------------------------
    // Decoder Hex -> 7 segmentos
    // -------------------------
    always_comb begin
        case (counter_hex)
            4'h0: seg = 7'b1000000; // 0
            4'h1: seg = 7'b1111001; // 1
            4'h2: seg = 7'b0100100; // 2
            4'h3: seg = 7'b0110000; // 3
            4'h4: seg = 7'b0011001; // 4
            4'h5: seg = 7'b0010010; // 5
            4'h6: seg = 7'b0000010; // 6
            4'h7: seg = 7'b1111000; // 7
            4'h8: seg = 7'b0000000; // 8
            4'h9: seg = 7'b0010000; // 9
            4'hA: seg = 7'b0001000; // A
            4'hB: seg = 7'b0000011; // b
            4'hC: seg = 7'b1000110; // C
            4'hD: seg = 7'b0100001; // d
            4'hE: seg = 7'b0000110; // E
            4'hF: seg = 7'b0001110; // F
            default: seg = 7'b1111111; // Apagado
        endcase
    end

    // -------------------------
    // Activar solo un display
    // -------------------------
    assign an = 4'b1110; // Solo se usa un dígito (AN0 activo en bajo)

endmodule