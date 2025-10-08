module mostrar_carta_random (
    input  logic        clk,
    input  logic        rst,
    input  logic        start,
    input  logic [7:0]  seed,
    input  logic [4:0]  arr_cards_in [0:15],
    output logic [4:0]  arr_cards_out [0:15],
    output logic        done
);

    typedef enum logic [1:0] {
        IDLE,
        PROCESS,
        FINISH
    } state_t;

    state_t state, next_state;

    logic [4:0] arr_tmp [0:15];
    logic [3:0] count_01;
    logic [3:0] num_to_change;
    logic [3:0] found_00;
    logic [3:0] idx;

    // ------------------------------------------------------
    // FSM secuencial
    // ------------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 0;
            for(int i=0;i<16;i++) arr_cards_out[i] <= arr_cards_in[i];
        end else begin
            state <= next_state;
            case(state)
                IDLE: begin
                    done <= 0;
                    if(start) begin
                        for(int i=0;i<16;i++) arr_tmp[i] <= arr_cards_in[i];
                    end
                end

                PROCESS: begin
                    // contar cartas con estado 01
                    count_01 = 0;
                    for(int i=0; i<16; i++)
                        if(arr_tmp[i][1:0] == 2'b01) count_01++;

                    // determinar cuántas cartas 00 cambiar
                    if(count_01 == 0) num_to_change = 2;
                    else if(count_01 == 1) num_to_change = 1;
                    else num_to_change = 0;

                    found_00 = 0;

                    // -------------------------------
                    // Recorrido hacia adelante desde seed
                    // -------------------------------
                    for(int i=0; i<16 && found_00 < num_to_change; i++) begin
                        idx = (seed[3:0] + i) % 16;
                        if(arr_tmp[idx][1:0] == 2'b00) begin
                            arr_tmp[idx][1:0] = 2'b01;
                            found_00++;
                        end
                    end

                    // -------------------------------
                    // Recorrido hacia atrás desde seed
                    // -------------------------------
                    for(int i=1; i<16 && found_00 < num_to_change; i++) begin
                        idx = (seed[3:0] + 16 - i) % 16; // moverse hacia atrás circularmente
                        if(arr_tmp[idx][1:0] == 2'b00) begin
                            arr_tmp[idx][1:0] = 2'b01;
                            found_00++;
                        end
                    end
                end

                FINISH: begin
                    for(int i=0;i<16;i++) arr_cards_out[i] <= arr_tmp[i];
                    done <= 1;
                end
            endcase
        end
    end

    // ------------------------------------------------------
    // Lógica de transición de estados
    // ------------------------------------------------------
    always_comb begin
        next_state = state;
        case(state)
            IDLE:    if(start) next_state = PROCESS;
            PROCESS: next_state = FINISH;
            FINISH:  if(!start) next_state = IDLE;
        endcase
    end
endmodule
