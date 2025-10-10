module card_controller(
    input  logic clk,
    input  logic rst,
    input  logic [3:0] state,           // Estado externo
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
	 
	 logic startMR;
    logic doneMR;
    logic [4:0] arr_MR [0:15];

    // -----------------------------------------------------------------
    // Instancias de módulos
    // -----------------------------------------------------------------
    bit_shifter bs (
        .clk(clk),
        .rst(rst),
        .data(seed)
    );

    Shuffle sh (
        .clk(clk),
        .rst(rst),
        .start(startS),
        .seed(seed),
        .arr_cards(arr_Sh),
        .done(done_Shuffle)
    );

    verificar_pareja vp (
        .clk(clk),
        .rst(rst),
        .start(startVP),
        .arr_cards_in(arr_out),    // entrada del shuffle o passthrough
        .arr_cards_out(arr_VP),
        .done(doneVP),
        .hubo_pareja(huboPareja)
    );

	 mostrar_carta_random mr(
        .clk(clk),
        .rst(rst),
        .start(startMR),
        .seed(seed),
        .arr_cards_in(arr_out),
        .arr_cards_out(arr_MR),
        .done(doneMR)
    );
	 
	 
    // -----------------------------------------------------------------
    // FSM basada en estado externo
    // -----------------------------------------------------------------
    typedef enum logic [3:0] {
        INICIO          = 4'b0000,
        MUESTRO_CORTAS  = 4'b0001,
        OCULTA_CORTAS   = 4'b0010,
        REVUELVE_CORTAS = 4'b0011,
        INICIO_JUEGO    = 4'b0100,
        TURNO_JUGADOR   = 4'b0101,
        UNA_CARTA       = 4'b0110,
        DOS_CARTAS      = 4'b0111,
        MOSTRAR_RANDOM  = 4'b1000,
        NO_MAS_PAREJAS  = 4'b1001,
        CONCLUSION      = 4'b1010
    } state_t;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            startS <= 0;
            startVP <= 0;
            shuffle_active <= 0;
            doneSh <= 0;
            doneMcr <= 0;
            load <= 0;
            for (int i=0; i<16; i++) arr_out[i] <= arr_in[i];
        end else begin
            // Reset de pulsos cada ciclo
            startS <= 0;
            startVP <= 0;
            doneSh <= 0;
            doneMcr <= 0;
            load <= 0;

            case(state)
					//Estado para Shuffle
                REVUELVE_CORTAS: begin
                    if (!shuffle_active) begin
                        startS <= 1;
                        shuffle_active <= 1;
                    end

                    if (done_Shuffle && shuffle_active) begin
                        for (int i=0; i<16; i++) arr_out[i] <= arr_Sh[i];
                        doneSh <= 1;
                        load <= 1;
                        shuffle_active <= 0;
                    end
                end
					 
					 
					//Estado para verificar parejas
                DOS_CARTAS: begin
                    startVP <= 1;
                    if (doneVP) begin
                        for (int i=0; i<16; i++) arr_out[i] <= arr_VP[i];
								load <= 1;
                        doneMcr <= 1;
                    end
                end
					 
					 // -----------------------------------------------------------------
                // Estado MOSTRAR_RANDOM
                // -----------------------------------------------------------------
                MOSTRAR_RANDOM: begin
                    startMR <= 1;
                    if (doneMR) begin
                        for (i = 0; i < 16; i++) arr_out[i] <= arr_MR[i];
                        load <= 1;
                    end
                end

                default: begin
                    // Pass-through para otros estados
                    for (int i=0; i<16; i++) arr_out[i] <= arr_in[i];
                end
            endcase
        end
    end

endmodule