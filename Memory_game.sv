`timescale 1ns/1ps

module tb_card_controller;

  // Señales de prueba
  logic clk;
  logic rst;
  logic Izq, Der, Sel;
  logic [3:0] state;
  logic [4:0] arr_in [0:15];
  logic [4:0] arr_out [0:15];
  logic doneSh, doneSp, doneMcr, doneVp;
  logic [1:0] cartas_seleccionadas;
  logic load, hubo_pareja;

  // Instancia del DUT (Device Under Test)
  card_controller uut (
    .clk(clk),
    .rst(rst),
    .Izq(Izq),
    .Der(Der),
    .Sel(Sel),
    .state(state),
    .arr_in(arr_in),
    .arr_out(arr_out),
    .doneSh(doneSh),
    .doneSp(doneSp),
    .doneMcr(doneMcr),
    .doneVp(doneVp),
    .cartas_seleccionadas(cartas_seleccionadas),
    .load(load),
    .hubo_pareja(hubo_pareja)
  );

  // Generador de reloj
  always #5 clk = ~clk; // 10ns periodo (100 MHz)

  // Inicialización
  initial begin
    clk = 0;
    rst = 1;
    Izq = 0;
    Der = 0;
    Sel = 0;
    state = 4'b0000;

    // Inicializar cartas con valores simples
    for (int i = 0; i < 16; i++) begin
      arr_in[i] = i;
    end

    // Mostrar encabezado
    $display("===== INICIO DE SIMULACIÓN card_controller =====");
    $display("Tiempo | Estado | Señales: doneSh doneSp doneMcr doneVp load cartas_sel");

    // Liberar reset
    #20 rst = 0;

    // --- Estado: REVUELVE_CORTAS ---
    state = 4'b0011;
    $display("\n[REVUELVE_CORTAS] Mezclando cartas...");
    #100;

    // --- Estado: TURNO_JUGADOR ---
    state = 4'b0101;
    Izq = 1; Sel = 0;
    $display("\n[TURNO_JUGADOR] Jugador selecciona primera carta...");
    #100;

    // --- Estado: UNA_CARTA ---
    state = 4'b0110;
    Izq = 0; Der = 1; Sel = 1;
    $display("\n[UNA_CARTA] Jugador selecciona segunda carta...");
    #100;

    // --- Estado: DOS_CARTAS ---
    state = 4'b0111;
    $display("\n[DOS_CARTAS] Verificando pareja...");
    #100;

    // --- Estado: MOSTRAR_RANDOM ---
    state = 4'b1000;
    $display("\n[MOSTRAR_RANDOM] Mostrando carta aleatoria...");
    #100;

    // --- Estado: CONCLUSION ---
    state = 4'b1010;
    $display("\n[CONCLUSION] Fin de la simulación.");
    #50;

    $display("===== FIN DE SIMULACIÓN =====");
    $stop;
  end

  // Monitoreo de señales en consola
  always @(posedge clk) begin
    $display("t=%0t | state=%b | doneSh=%b doneSp=%b doneMcr=%b doneVp=%b load=%b cartas_sel=%b",
      $time, state, doneSh, doneSp, doneMcr, doneVp, load, cartas_seleccionadas);
  end

endmodule
