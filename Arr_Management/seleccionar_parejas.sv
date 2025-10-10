module seleccionar_parejas (
    input  logic        clk,
    input  logic        rst,
    input  logic        start,       // Señal para habilitar el funcionamiento
    input  logic        Izq,         // Botón para moverse a la izquierda
    input  logic        Der,         // Botón para moverse a la derecha
    input  logic        Sel,         // Botón para seleccionar carta
    input  logic [4:0]  arr_in [0:15],
    output logic [4:0]  arr_out [0:15],
    output logic [1:0]  cartas_seleccionadas,
    output logic        load
);

    logic [3:0] index;               // Posición actual (0 a 15)
    logic [4:0] temp_arr [0:15];     // Arreglo temporal
    logic        carta_seleccionada; // Bandera de si ya se seleccionó una carta

    // ============================================
    // Movimiento Izquierda / Derecha circular
    // ============================================
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            index <= 4'd0;
        end else if (start) begin
            if (!Izq) begin
                if (index == 4'd0)
                    index <= 4'd15;
                else
                    index <= index - 4'd1;
            end else if (!Der) begin
                if (index == 4'd15)
                    index <= 4'd0;
                else
                    index <= index + 4'd1;
            end
        end
    end

    // ============================================
    // Selección de una sola carta
    // ============================================
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            carta_seleccionada <= 1'b0;
            temp_arr           <= arr_in;
            load               <= 1'b0;
        end else if (start) begin
            if (!Sel) begin
                // Solo si no hay carta seleccionada y la actual no está marcada
                if (!carta_seleccionada && temp_arr[index][1:0] != 2'b01) begin
                    temp_arr[index][1:0] <= 2'b01; // Marcar carta seleccionada
                    carta_seleccionada    <= 1'b1; // Bandera activa
                    load                  <= 1'b1; // Indicar cambio
                end else begin
                    load <= 1'b0; // Ya hay carta seleccionada o repetida
                end
            end else begin
                load <= 1'b0; // Botón Sel no presionado
            end
        end else begin
            load <= 1'b0; // Si start = 0, módulo inactivo
        end
    end

    // ============================================
    // Salidas
    // ============================================
    assign arr_out = temp_arr;
    assign cartas_seleccionadas = {1'b0, carta_seleccionada}; // 0 o 1 carta seleccionada

endmodule
