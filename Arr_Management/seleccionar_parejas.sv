module seleccionar_parejas (
    input  logic        clk,
    input  logic        rst,          // activo en bajo
    input  logic        start,        // inicia una ronda
    input  logic        Izq,          // activo en alto
    input  logic        Der,          // activo en alto
    input  logic        Sel,          // activo en alto
    input  logic [4:0]  arr_in [0:15],
    output logic [4:0]  arr_out [0:15],
    output logic [1:0]  cartas_seleccionadas,
    output logic        done
);

    // Variables internas
    logic        running;
    logic [3:0]  index;
    logic [4:0]  temp_arr [0:15];
    logic [4:0]  pool_comb [0:15];
    logic        carta_seleccionada;
    logic        doing; // bloquea pulsos de Sel hasta nueva ronda

    // Edge detectors
    logic izq_q, der_q, sel_q;
    wire  izq_p = Izq & ~izq_q;
    wire  der_p = Der & ~der_q;
    wire  sel_p = Sel & ~sel_q;

    // Seguimiento de flancos
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            izq_q <= 0; der_q <= 0; sel_q <= 0;
        end else begin
            izq_q <= Izq;
            der_q <= Der;
            sel_q <= Sel;
        end
    end

    // ======================================================
    // BLOQUE COMBINACIONAL: genera pool_comb (resultado)
    // ======================================================
    always_comb begin
        integer i;
        for (i = 0; i < 16; i = i + 1)
            pool_comb[i] = temp_arr[i]; // copia actual del array
        if (running && sel_p && !carta_seleccionada && temp_arr[index][1:0] != 2'b01 && temp_arr[index][1:0] != 2'b10)
            pool_comb[index][1:0] = 2'b01; // marca carta seleccionada
    end

    // ======================================================
    // BLOQUE SECUENCIAL: control de ronda y selección
    // ======================================================
    always_ff @(posedge clk or negedge rst) begin
        integer i;
        if (!rst) begin
            running            <= 0;
            done               <= 0;
            carta_seleccionada <= 0;
            index              <= 0;
            doing              <= 0;
            for (i = 0; i < 16; i = i + 1) begin
                temp_arr[i] <= 0;
                arr_out[i]  <= 0;
            end
        end else begin
            done <= 0;

            // Iniciar ronda
            if (start) begin
                running            <= 1;
                carta_seleccionada <= 0;
                doing              <= 0;
                index              <= 0;
                for (i = 0; i < 16; i = i + 1) begin
                    temp_arr[i] <= arr_in[i];
                    arr_out[i]  <= arr_in[i];
                end
            end

            if (running) begin
                // Movimiento del índice
                if (izq_p) index <= (index == 0) ? 15 : index - 1;
                else if (der_p) index <= (index == 15) ? 0 : index + 1;

                // Selección de carta
                if (sel_p && !doing && !carta_seleccionada && temp_arr[index][1:0] != 2'b01 && temp_arr[index][1:0] != 2'b10) begin
                    temp_arr[index][1:0] <= 2'b01; // marca temp_arr
                    arr_out[index][1:0]  <= 2'b01; // actualiza salida
                    carta_seleccionada   <= 1;
                    done                 <= 1;
                    running              <= 0;       // termina la ronda
                    doing                <= 1;       // bloquea hasta nueva ronda
                end
            end
        end
    end

    // Salida
    assign cartas_seleccionadas = {1'b0, carta_seleccionada};

endmodule
