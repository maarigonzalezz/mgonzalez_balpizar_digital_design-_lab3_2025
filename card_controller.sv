module card_controller(
    input  logic clk,
    input  logic rst,
	 input  logic Izq, Der, Sel,
    input  logic [3:0] state,           // Estado externo
    input  logic [4:0] arr_in [0:15],
    output logic [4:0] arr_out [0:15],
    output logic doneSh, // listo shuffle
	 output logic doneSp, //se selecciono carta
    output logic doneMcr, // listo mostrar carta random
	 output logic doneVep, // listo verificar parejaa
	 output logic [1:0]  cartas_seleccionadas,
    output logic load, // señal para guardar el output en el registro
	 output logic hubo_pareja
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
    logic [4:0] arr_VP [0:15];
	 
	 logic startMR;
    logic doneMR;
    logic [4:0] arr_MR [0:15];

	 logic startSP;
    logic doneSP1;
	 logic doneSP2;
    logic [4:0] arr_SP1 [0:15];
	 logic [4:0] arr_SP2 [0:15];
	 logic rstSp;
	 assign rstSp = ~rst;


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
        .arr_cards_in(arr_in),    // entrada del shuffle o passthrough
        .arr_cards_out(arr_VP),
        .done(doneVP),
        .hubo_pareja(hubo_Pareja)
    );

	 mostrar_carta_random mr(
        .clk(clk),
        .rst(rst),
        .start(startMR),
        .seed(seed),
        .arr_cards_in(arr_in),
        .arr_cards_out(arr_MR),
        .done(doneMR)
    );

	 seleccionar_parejas sp1(
		  .clk(clk),
        .rst(rstSp),
        .start(startSP),
		  .Izq(Izq),
		  .Der(Der),
		  .Sel(Sel),
		  .arr_in(arr_in),
        .arr_out(arr_SP1),
		  .load(doneSP1)
	 );

	 seleccionar_parejas sp2(
		  .clk(clk),
        .rst(rstSp),
        .start(startSP),
		  .Izq(Izq),
		  .Der(Der),
		  .Sel(Sel),
		  .arr_in(arr_in),
        .arr_out(arr_SP2),
		  .load(doneSP2)
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
				startSP <= 0;
            shuffle_active <= 0;
            doneSh <= 0;
            doneMcr <= 0;
				doneVp <= 0;
            load <= 0;
				cartas_seleccionadas <= 0;
				startMR <= 0;
				doneSp <= 0;
				doneSP1 <= 0;
				doneSP2 <= 0;
				doneVP <= 0;
				doneMR <= 0;
            for (int i=0; i<16; i++) arr_out[i] <= arr_in[i];
        end else begin
            // Reset de pulsos cada ciclo
            startS <= 0;
            startVP <= 0;
				startSP <= 0;
            doneSh <= 0;
            doneMcr <= 0;
				doneVep <= 0;
            load <= 0;
				doneSp <= 0;

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
					 //Estado de turno y espera recibir una carta sel
                TURNO_JUGADOR: begin
                    startSP <= 1;
						  cartas_seleccionadas <= 2'b00;
                    if (doneSP1) begin
                        for (int i=0; i<16; i++) arr_out[i] <= arr_SP1[i];
								load <= 1;
                        doneSp <= 1;
                    end
                end

					 UNA_CARTA: begin
						  doneSp <= 0;
                    startSP <= 1;
						  cartas_seleccionadas <= 2'b01;
                    if (doneSP2) begin
                        for (int i=0; i<16; i++) arr_out[i] <= arr_SP2[i];
								load <= 1;
                        doneSp <= 1;
                    end
                end


					//Estado para verificar parejas
                DOS_CARTAS: begin
                    startVP <= 1;
                    if (doneVP) begin
                        for (int i=0; i<16; i++) arr_out[i] <= arr_VP[i];
								load <= 1;
                        doneVep <= 1;
                    end
                end

					 // -----------------------------------------------------------------
                // Estado MOSTRAR_RANDOM
                // -----------------------------------------------------------------
                MOSTRAR_RANDOM: begin
                    startMR <= 1;
                    if (doneMR) begin
                        for (int i = 0; i < 16; i++) arr_out[i] <= arr_MR[i];
								doneMcr <= 1;
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