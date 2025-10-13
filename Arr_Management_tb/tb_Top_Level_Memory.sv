`timescale 1ns/1ps

module tb_Top_Level_Memory;

  // ================================
  // Señales principales del Top
  // ================================
  logic clk, rst;
  logic I, CM, CO, CR;
  logic Izq, Der, Sel;

  // Salidas relevantes (sin VGA)
  logic [1:0] turno_de;
  logic [6:0] seg, segPJ1, segPJ2;
  logic [3:0] s;
  logic cargar;

  // Ignoradas (solo dummy)
  logic [7:0] r, g, b;
  logic vgaclk, hsync, vsync, sync_b, blank_b;

  // ================================
  // DUT
  // ================================
  Top_Level_Memory DUT (
      .clk(clk),
      .rst(rst),
      .I(I),
      .CM(CM),
      .CO(CO),
      .CR(CR),
      .Izq(Izq),
      .Der(Der),
      .Sel(Sel),
      .turno_de(turno_de),
      .seg(seg),
      .segPJ1(segPJ1),
      .segPJ2(segPJ2),
      .vgaclk(vgaclk),
      .hsync(hsync),
      .vsync(vsync),
      .sync_b(sync_b),
      .blank_b(blank_b),
      .s(s),
      .r(r),
      .g(g),
      .b(b),
      .cargar(cargar)
  );

  // ================================
  // Reloj
  // ================================
  always #5 clk = ~clk; // 100 MHz

  // ================================
  // Tareas auxiliares
  // ================================
  task print_arr(string tag, logic [4:0] arr[0:15]);
    $display("\n--- %s ---", tag);
    for (int i = 0; i < 16; i++) $write("%b ", arr[i]);
    $display("\n");
  endtask

  // ================================
  // Simulación
  // ================================
  initial begin
    // Reset inicial
    clk = 0; rst = 1;
    I = 0; CM = 0; CO = 0; CR = 0;
    Izq = 0; Der = 0; Sel = 0;

    $display("\n==== INICIO SIMULACIÓN Top_Level_Memory ====");
    #20 rst = 0;

    // ===================================================
    // 1️⃣ Estado INICIO → MUESTRO_CORTAS
    // ===================================================
    $display("\n[INICIO] Activando inicio del juego...");
    I = 1; #20; I = 0;
    CM = 1; #20; CM = 0; // Simula que las cartas se mostraron
    CO = 1; #20; CO = 0; // Simula ocultarlas
    CR = 1; #20; CR = 0; // Simula revolver
    #100;

    $display("FSM llegó a estado: %b (esperado: INICIO_JUEGO o TURNO_JUGADOR)", DUT.state);

    // ===================================================
    // 2️⃣ TURNO_JUGADOR → primera carta seleccionada
    // ===================================================
    $display("\n[TURNO_JUGADOR] Jugador 1 selecciona primera carta...");
    Der = 1; #20; Der = 0; #20;
    Der = 1; #20; Der = 0; #20;
    Sel = 1; #20; Sel = 0; #20;
    #100;

    $display("-> Señal se_eligio_carta: %b", DUT.se_eligio_carta);
    $display("-> Señal load: %b", DUT.load);
    print_arr("Array de cartas tras primera selección (arr_cartas)", DUT.arr_cartas);

    // ===================================================
    // 3️⃣ UNA_CARTA → segunda carta seleccionada
    // ===================================================
    $display("\n[UNA_CARTA] Jugador 1 selecciona segunda carta...");
    Izq = 1; #20; Izq = 0; #20;
    Sel = 1; #20; Sel = 0; #20;
    #200;

    $display("-> Señal se_eligio_carta: %b", DUT.se_eligio_carta);
    $display("-> Señal load: %b", DUT.load);
    print_arr("Array tras segunda selección (arr_cartas)", DUT.arr_cartas);

	 
	     // ===================================================
    // 2️⃣ TURNO_JUGADOR → primera carta seleccionada
    // ===================================================
    $display("\n[TURNO_JUGADOR] Jugador 1 selecciona primera carta...");
    Der = 1; #20; Der = 0; #20;
	 Der = 1; #20; Der = 0; #20;
	 Der = 1; #20; Der = 0; #20;
	 Der = 1; #20; Der = 0; #20;
    Sel = 1; #20; Sel = 0; #20;
    #100;

    $display("-> Señal se_eligio_carta: %b", DUT.se_eligio_carta);
    $display("-> Señal load: %b", DUT.load);
    print_arr("Array de cartas tras primera selección (arr_cartas)", DUT.arr_cartas);


	 // ===================================================
    // 3️⃣ UNA_CARTA → segunda carta seleccionada
    // ===================================================
    $display("\n[UNA_CARTA] Jugador 1 selecciona segunda carta...");
    Der = 1; #20; Der = 0; #20;
	 Der = 1; #20; Der = 0; #20;
    Sel = 1; #20; Sel = 0; #20;
    #200;

    $display("-> Señal se_eligio_carta: %b", DUT.se_eligio_carta);
    $display("-> Señal load: %b", DUT.load);
    print_arr("Array tras segunda selección (arr_cartas)", DUT.arr_cartas);
	 
	 
    // ===================================================
    // 4️⃣ DOS_CARTAS → verificar pareja
    // ===================================================
    $display("\n[DOS_CARTAS] Verificando pareja...");
    #200;
    print_arr("Array tras verificar pareja", DUT.arr_cartas);
    $display("hubo_pareja = %b", DUT.hubo_pareja);

    // ===================================================
    // 5️⃣ Cambios de turno y puntaje
    // ===================================================
    $display("\n[POST VERIFICACIÓN] Turno y puntaje");
    $display("Turno de jugador: %b", DUT.turno_de);
    $display("Puntaje J1: %0d | Puntaje J2: %0d", DUT.puntajeJ1, DUT.puntajeJ2);

    // ===================================================
    // 6️⃣ Mostrar estados siguientes
    // ===================================================
    $display("\n[ESTADOS SIGUIENTES]");
    #200;
    $display("FSM -> state=%b | cartas_revueltas=%b | se_eligio_carta=%b | load=%b",
             DUT.state, DUT.cartas_revueltas, DUT.se_eligio_carta, DUT.load);

    $display("\n==== FIN SIMULACIÓN ====");
    $stop;
  end

	// ================================
	// Monitoreo en tiempo real
	// ================================
	always @(posedge clk) begin
		 $display("t=%0t | state=%b | turno=%b | load=%b | pareja=%b | J1=%0d | J2=%0d| se_eligio_carta: %b",
					 $time, DUT.state, DUT.turno_de, DUT.load, DUT.hubo_pareja, DUT.puntajeJ1, DUT.puntajeJ2, DUT.se_eligio_carta);

		 // Imprime el arreglo de cartas
		 $write("t=%0t | arr_cartas=", $time);
		 for (int i = 0; i < 16; i = i + 1)
			  $write("%05b ", DUT.arr_cartas[i]);
		 $display("");
	end
	  
  initial begin
    #1000; // Esperar a que empiece la simulación principal

    $display("\n===== MONITOREO DE TEMPORIZADOR 7 SEGMENTOS =====");

    // Espera al primer reseteo del contador
    @(posedge DUT.reset_timer);
    $display("t=%0t | 🌀 FSM resetea el contador del turno", $time);

    // Observa cómo cambian los segmentos durante el turno
    repeat (40) begin
      #50;
      $display("t=%0t | seg=%b | tiempo_terminado=%b", $time, DUT.seg, DUT.tiempo_terminado);
    end

    // Espera a que el tiempo se termine (si ocurre)
    wait (DUT.tiempo_terminado === 1);
    $display("t=%0t | ⏰ ¡Tiempo terminado! FSM debería pasar a MOSTRAR_RANDOM o cambiar turno.", $time);

    #200;
    $display("===== FIN DEL MONITOREO DEL TEMPORIZADOR =====");
  end
  

endmodule