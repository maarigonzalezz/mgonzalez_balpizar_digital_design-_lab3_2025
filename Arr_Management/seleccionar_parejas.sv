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

    // Edge detectors
    logic izq_q, der_q, sel_q;
    wire  izq_p = Izq & ~izq_q;
    wire  der_p = Der & ~der_q;
    wire  sel_p = Sel & ~sel_q;

    // Seguimiento de flancos
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            izq_q <= 1'b0;
            der_q <= 1'b0;
            sel_q <= 1'b0;
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
        logic [4:0] temp[0:15];
        for (i = 0; i < 16; i++)
            temp[i] = temp_arr[i];

        // No hace cambios hasta que se seleccione una carta
        if (sel_p && !carta_seleccionada && temp[index][1:0] != 2'b01)
            temp[index][1:0] = 2'b01;

        for (i = 0; i < 16; i++)
            pool_comb[i] = temp[i];
    end

    // ======================================================
    // BLOQUE SECUENCIAL: control tipo mostrar_carta_random
    // ======================================================
    always_ff @(posedge clk or negedge rst) begin
        integer i;
        if (!rst) begin
            running            <= 0;
            done               <= 0;
            carta_seleccionada <= 0;
            index              <= 0;
            for (i = 0; i < 16; i++) begin
                temp_arr[i] <= 0;
                arr_out[i]  <= 0;
            end
        end else begin
            done <= 0;

            // Iniciar ronda
            if (start && !running) begin
                running            <= 1;
                carta_seleccionada <= 0;
                index              <= 0;
                for (i = 0; i < 16; i++)
                    temp_arr[i] <= arr_in[i];
            end

            if (running) begin
                // Movimiento
                if (izq_p) begin
                    if (index == 0)
                        index <= 15;
                    else
                        index <= index - 1;
                end else if (der_p) begin
                    if (index == 15)
                        index <= 0;
                    else
                        index <= index + 1;
                end

                // Selección
                if (sel_p && !carta_seleccionada && temp_arr[index][1:0] != 2'b01) begin
                    for (i = 0; i < 16; i++)
                        arr_out[i] <= pool_comb[i]; // Actualiza salida solo aquí
                    carta_seleccionada <= 1;
                    done               <= 1;
                    running            <= 0;       // Termina la ronda
                end
            end
        end
    end

    // Salida
    assign cartas_seleccionadas = {1'b0, carta_seleccionada};

endmodule
