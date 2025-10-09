module verificar_pareja (
    input  logic clk,                          // Reloj del sistema
    input  logic rst,                          // Reset sincrónico/asincrónico
    input  logic start,                        // Señal para iniciar la verificación
    input  logic [4:0] arr_cards_in [0:15],   // Array de cartas de entrada (5 bits cada una)
    output logic [4:0] arr_cards_out [0:15],  // Array de cartas de salida (resultado)
    output logic done,                         // Pulso de fin de verificación
    output logic hubo_pareja                   // Pulso si se encontró pareja
);

    // Definición de estados
    typedef enum logic [1:0] {IDLE=2'b00, CHECK=2'b01} state_t;
    state_t state;

    // Variables internas
    integer i;                 // Iterador para loops
    logic [3:0] pos1, pos2;    // Posiciones de las cartas abiertas
    logic [1:0] cont;          // Contador de cartas abiertas
    logic [2:0] sym1, sym2;    // Símbolos de las cartas abiertas

    // Lógica principal
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset: inicializar salidas y variables de control
            done <= 0;
            hubo_pareja <= 0;
            state <= IDLE;
            pos1 <= 0;
            pos2 <= 0;
            cont <= 0;
            for (i=0;i<16;i=i+1)
                arr_cards_out[i] <= 5'b00011; // todas cerradas
        end else begin
            // Limpiar pulsos
            done <= 0;
            hubo_pareja <= 0;

            case(state)
                // Estado IDLE: espera señal de inicio
                IDLE: begin
                    if (start) begin
                        // Inicializar array de salida con las cartas de entrada
                        for (i=0;i<16;i=i+1)
                            arr_cards_out[i] <= arr_cards_in[i];

                        // Reset de variables de control
                        pos1 <= 0;
                        pos2 <= 0;
                        cont <= 0;

                        // Pasar al estado CHECK
                        state <= CHECK;
                    end
                end

                // Estado CHECK: contar cartas abiertas y verificar pareja
                CHECK: begin
                    cont = 0;
                    pos1 = 0;
                    pos2 = 0;

                    // Buscar cartas abiertas (estado '01')
                    for (i=0;i<16;i=i+1) begin
                        if (arr_cards_out[i][1:0] == 2'b01) begin
                            if (cont == 0) pos1 = i;
                            else if (cont == 1) pos2 = i;
                            cont = cont + 1;
                        end
                    end

                    // Inicializar arr_cards_out con entrada (asegura coherencia)
                    for (i=0;i<16;i=i+1)
                        arr_cards_out[i] <= arr_cards_in[i];

                    // Casos válidos
                    if (cont == 0) begin
                        // Ninguna carta abierta: fin
                        done <= 1;
                    end else if (cont == 2) begin
                        // Dos cartas abiertas: comparar símbolos
                        sym1 = arr_cards_in[pos1][4:2];
                        sym2 = arr_cards_in[pos2][4:2];
                        if (sym1 == sym2) begin
                            // Pareja encontrada: marcar como cerrada definitiva '10'
                            arr_cards_out[pos1][1:0] <= 2'b10;
                            arr_cards_out[pos2][1:0] <= 2'b10;
                            hubo_pareja <= 1;
                        end else begin
                            // Símbolos distintos: cerrar cartas
                            arr_cards_out[pos1][1:0] <= 2'b00;
                            arr_cards_out[pos2][1:0] <= 2'b00;
                        end
                        done <= 1;
                    end else begin
                        // Caso inválido (>2 abiertas): cerrar todas
                        for (i=0;i<16;i=i+1)
                            if (arr_cards_out[i][1:0] == 2'b01)
                                arr_cards_out[i][1:0] <= 2'b00;
                        done <= 1;
                    end

                    // Volver a IDLE
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule

