module card_controller(
    input  logic clk,
    input  logic rst,
    input  logic [3:0] state,
    input  logic [4:0] arr_in [0:15],
    output logic [4:0] arr_out [0:15],
    output logic doneSh,
    output logic doneMcr,
    output logic load
);

    // -----------------------------------------------------------------
    // Señales internas
    // -----------------------------------------------------------------
    logic [7:0] seed;
    logic [4:0] arr_Sh [0:15];
    logic done_Shuffle;
    logic startS;
    logic shuffle_active;

    logic startVP;
    logic doneVP;
    logic huboPareja;
    logic [4:0] arr_VP [0:15];

    // -----------------------------------------------------------------
    // Instancias de módulos
    // -----------------------------------------------------------------
    bit_shifter bs (
        .clk(clk),
        .rst(rst),
        .data(seed)
    );

    Shuffle sh(
        .clk(clk),
        .rst(rst),
        .start(startS),
        .seed(seed),
        .arr_cards(arr_Sh),
        .done(done_Shuffle)
    );

    verificar_pareja vp(
        .clk(clk),
        .rst(rst),
        .start(startVP),
        .arr_cards_in(arr_out),  // entrada del shuffle o passthrough
        .arr_cards_out(arr_VP),
        .done(doneVP),
        .hubo_pareja(huboPareja)
    );

    // -----------------------------------------------------------------
    // FSM top-level
    // -----------------------------------------------------------------
    typedef enum logic [2:0] {
        IDLE         = 3'b000,
        SHUFFLE      = 3'b001,
        VERIFY       = 3'b010,
        PASS_THROUGH = 3'b011,
        FINISHED     = 3'b100
    } top_state_t;

    top_state_t tstate;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            tstate <= IDLE;
            startS <= 0;
            startVP <= 0;
            shuffle_active <= 0;
            doneSh <= 0;
            doneMcr <= 0;
            load <= 0;
            // Inicializar arr_out
            for (int i=0; i<16; i++) arr_out[i] <= arr_in[i];
        end else begin
            // Reset pulsos cada ciclo
            startS <= 0;
            startVP <= 0;
            doneSh <= 0;
            doneMcr <= 0;
            load <= 0;

            case(tstate)
                IDLE: begin
                    if (state == 4'b0011) tstate <= SHUFFLE;
                    else tstate <= PASS_THROUGH;
                end

                SHUFFLE: begin
                    startS <= 1;
                    shuffle_active <= 1;

                    if (done_Shuffle) begin
                        for (int i = 0; i < 16; i++) arr_out[i] <= arr_Sh[i];
                        doneSh <= 1;
                        load <= 1;
                        shuffle_active <= 0;
                        tstate <= VERIFY;
                    end
                end

                VERIFY: begin
                    startVP <= 1;
                    if (doneVP) begin
                        for (int i = 0; i < 16; i++) arr_out[i] <= arr_VP[i];
                        doneMcr <= 1;
                        tstate <= FINISHED;
                    end
                end

                PASS_THROUGH: begin
                    for (int i = 0; i < 16; i++) arr_out[i] <= arr_in[i];
                    tstate <= FINISHED;
                end

                FINISHED: begin
                    if (state != 4'b0011) tstate <= IDLE;
                end
            endcase
        end
    end

endmodule
