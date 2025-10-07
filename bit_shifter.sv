module bit_shifter (
    input  logic clk,        // Reloj principal para el registro de desplazamiento
    input  logic rst,        // Reset asíncrono para inicializar el registro
    output logic [7:0] data  // Salida pseudoaleatoria de 8 bits
);

    // Registro interno de 8 bits que hace el desplazamiento
    logic [7:0] shift_reg;

    // ------------------------------------------------------
    // Lógica secuencial: registro de desplazamiento con LFSR tipo Galois
    // ------------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg <= 8'hA5; // Valor inicial al reset (puede ser cualquier constante)
        end else begin
            // Desplazamiento a la izquierda con realimentación XOR para generar pseudoaleatoriedad
            // shift_reg[7] se calcula como XOR de bits 7,5,4,3
            shift_reg <= {shift_reg[6:0], shift_reg[7] ^ shift_reg[5] ^ shift_reg[4] ^ shift_reg[3]};
        end
    end

    // ------------------------------------------------------
    // Asignar salida
    // ------------------------------------------------------
    assign data = shift_reg;  // La salida refleja el valor actual del registro

endmodule