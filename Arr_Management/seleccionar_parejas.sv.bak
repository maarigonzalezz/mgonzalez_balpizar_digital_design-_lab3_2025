module seleccionar_parejas (
    input  logic        clk,
    input  logic        rst,
    input  logic        start,       // Nueva señal para habilitar funcionamiento
    input  logic        Izq,
    input  logic        Der,
    input  logic        Sel,
    input  logic [4:0]  arr_in [0:15],
    input  logic [3:0]  state,
    output logic [4:0]  arr_out [0:15],
    output logic [1:0]  cartas_seleccionadas,
    output logic        load
);

    logic [3:0] index;               // Posición actual (0 a 15)
    logic [4:0] temp_arr [0:15];     // Arreglo temporal
    logic [1:0] temp_cartas_sel;     // Contador de cartas seleccionadas

    // Movimiento Izq / Der
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
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

    // Selección de cartas
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            temp_cartas_sel <= 2'd0;
            temp_arr <= arr_in;
            load <= 1'b0;
        end else if (start) begin
            if (!Sel) begin
                // Solo si aún no hay 2 cartas seleccionadas
                if (temp_cartas_sel < 2 && temp_arr[index][1:0] != 2'b01) begin
                    temp_arr[index][1:0] <= 2'b01;   // Marcar carta
                    temp_cartas_sel <= temp_cartas_sel + 1;
                    load <= 1'b1;                    // Indicar cambio
                end else begin
                    load <= 1'b0;
                end
            end else begin
                load <= 1'b0;
            end
        end
    end

    // Salidas
    assign arr_out = temp_arr;
    assign cartas_seleccionadas = temp_cartas_sel;

endmodule