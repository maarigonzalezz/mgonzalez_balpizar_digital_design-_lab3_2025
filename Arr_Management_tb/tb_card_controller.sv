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
  int num = 3'd0;

  // Instancia del DUT
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
  always #5 clk = ~clk; // 10 ns (100 MHz)

  // Tarea para imprimir un arreglo
  task print_arr(string tag, logic [4:0] arr[0:15]);
    $display("\n--- %s ---", tag);
    for (int i = 0; i < 16; i++) $write("%b ", arr[i]);
    $display("\n");
  endtask

  // Tarea para copiar arr_out → arr_in
  task update_input_from_output;
    for (int i = 0; i < 16; i++)
      arr_in[i] = arr_out[i];
    $display("[TB] arr_in actualizado desde arr_out\n");
  endtask

  // Inicialización
  initial begin
    clk = 0;
    rst = 1;
    Izq = 0;
    Der = 0;
    Sel = 0;
    state = 4'b0000;

    // Inicializar arr_in con pares de valores (como cartas)
    for (int i = 0; i <= 15; i += 2) begin
      arr_in[i][4:2]   = num[2:0];
      arr_in[i][1:0]   = 2'b00;
      arr_in[i+1][4:2] = num[2:0];
      arr_in[i+1][1:0] = 2'b00;
      num += 1;
    end

    $display("Contenido inicial de arr_in:");
    for (int i = 0; i < 16; i++) $write("%b ", arr_in[i]);
    $display("\n");

    $display("===== INICIO SIMULACIÓN card_controller =====");

    // Liberar reset
    #20 rst = 0;

    // ==================================================
    // Estado REVUELVE_CORTAS
    // ==================================================
    state = 4'b0011;
    $display("\n[REVUELVE_CORTAS] Mezclando cartas...");
    #100;
    print_arr("arr_out tras REVUELVE_CORTAS", arr_out);
    update_input_from_output();

    // ==================================================
    // Estado TURNO_JUGADOR
    // ==================================================
    state = 4'b0101;
    $display("\n[TURNO_JUGADOR] Jugador selecciona primera carta...");
    // Pulsos en los botones (activos en alto)
    Der = 1; #10; Der = 0; #20;
    Der = 1; #10; Der = 0; #20;
    Sel = 1; #10; Sel = 0; #20;
    #100;
    print_arr("arr_out tras TURNO_JUGADOR", arr_out);
    update_input_from_output();

    // ==================================================
    // Estado UNA_CARTA
    // ==================================================
    state = 4'b0110;
    $display("\n[UNA_CARTA] Jugador selecciona segunda carta...");
    Izq = 1; #10; Izq = 0; #20;
    Sel = 1; #10; Sel = 0; #20;
    #100;
    print_arr("arr_out tras UNA_CARTA", arr_out);
    update_input_from_output();
	 

    // ==================================================
    // Estado DOS_CARTAS
    // ==================================================
    state = 4'b0111;
    $display("\n[DOS_CARTAS] Verificando pareja...");
    #100;
    print_arr("arr_out tras DOS_CARTAS", arr_out);
    update_input_from_output();

    // ==================================================
    // Estado MOSTRAR_RANDOM
    // ==================================================
    state = 4'b1000;
    $display("\n[MOSTRAR_RANDOM] Mostrando carta aleatoria...");
    #100;
    print_arr("arr_out tras MOSTRAR_RANDOM", arr_out);
    update_input_from_output();

    // ==================================================
    // Estado CONCLUSION
    // ==================================================
    state = 4'b1010;
    $display("\n[CONCLUSION] Fin de la simulación.");
    #50;

    $display("===== FIN DE SIMULACIÓN =====");
    $stop;
  end

  // Monitoreo
  always @(posedge clk) begin
    $display("t=%0t | state=%b | doneSh=%b doneSp=%b doneMcr=%b doneVp=%b load=%b cartas_sel=%b",
      $time, state, doneSh, doneSp, doneMcr, doneVp, load, cartas_seleccionadas);
  end

endmodule


