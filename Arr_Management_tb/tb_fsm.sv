// tb_fsm.sv
`timescale 1ns/1ps

module tb_fsm;

  // Señales de prueba
  logic clk, rst;
  logic [1:0] cartas_seleccionadas;
  logic tiempo_terminado, inicio, se_eligio_carta;
  logic cartas_mostradas, cartas_ocultas, cartas_revueltas;
  logic cartas_verificadas, carta_randomizada, hubo_pareja;
  logic [1:0] ganador, turno_de;
  logic [3:0] state, puntajeJ1, puntajeJ2;
  logic reset_timer;

  // Instancia del DUT
  FSM dut (
    .rst(rst),
    .clk(clk),
    .cartas_seleccionadas(cartas_seleccionadas),
    .tiempo_terminado(tiempo_terminado),
    .inicio(inicio),
    .se_eligio_carta(se_eligio_carta),
    .cartas_mostradas(cartas_mostradas),
    .cartas_ocultas(cartas_ocultas),
    .cartas_revueltas(cartas_revueltas),
    .cartas_verificadas(cartas_verificadas),
    .carta_randomizada(carta_randomizada),
    .hubo_pareja(hubo_pareja),
    .ganador(ganador),
    .state(state),
    .turno_de(turno_de),
    .puntajeJ1(puntajeJ1),
    .puntajeJ2(puntajeJ2),
    .reset_timer(reset_timer)
  );

  // Generador de reloj
  always #5 clk = ~clk; // 100 MHz

  // ----------------------------------------------------------
  // Inicialización y estímulos
  // ----------------------------------------------------------
  initial begin
    $display("\n===== INICIO DE SIMULACIÓN FSM =====");

    // Inicialización
    clk = 0;
    rst = 1;
    inicio = 0;
    se_eligio_carta = 0;
    tiempo_terminado = 0;
    cartas_mostradas = 0;
    cartas_ocultas = 0;
    cartas_revueltas = 0;
    cartas_verificadas = 0;
    carta_randomizada = 0;
    hubo_pareja = 0;
    cartas_seleccionadas = 2'b00;
    #20 rst = 0;

    // Paso 1: Presionar inicio
    $display("\n-> Fase: INICIO DEL JUEGO");
    inicio = 1; #20; inicio = 0;
    #50 cartas_mostradas = 1; #10 cartas_mostradas = 0;

    // Paso 2: Mostrar y ocultar cartas
    $display("\n-> Fase: MOSTRAR Y OCULTAR CARTAS");
    #50 cartas_ocultas = 1; #10 cartas_ocultas = 0;
    #50 cartas_revueltas = 1; #10 cartas_revueltas = 0;

    // Paso 3: Primer turno del jugador 1
    $display("\n-> TURNO JUGADOR 1: Selecciona dos cartas (SIN pareja)");
    #100 se_eligio_carta = 1; #10 se_eligio_carta = 0; // primera carta
	 $display("\n-> UNA CARTA");
    #50 se_eligio_carta = 1; #10 se_eligio_carta = 0; // segunda carta
	 $display("\n-> DOS CARTAS");
    #20 cartas_verificadas = 1; hubo_pareja = 0; #10 cartas_verificadas = 0;

    // Paso 4: Segundo turno (Jugador 2 ahora)
    $display("\n-> TURNO JUGADOR 2: Encuentra una pareja");
    #100 se_eligio_carta = 1; #10 se_eligio_carta = 0;
	 $display("\n-> UNA CARTA");
    #50 se_eligio_carta = 1; #10 se_eligio_carta = 0;
	 $display("\n-> DOS CARTAS");
    #20 cartas_verificadas = 1; hubo_pareja = 1; #10 cartas_verificadas = 0;

    // Paso 5: Jugador 2 vuelve a jugar (otra pareja)
    $display("\n-> TURNO JUGADOR 2: NO ENCUENTRA PAREJA");
    #100 se_eligio_carta = 1; #10 se_eligio_carta = 0;
	 $display("\n-> UNA CARTA");
    #50 se_eligio_carta = 1; #10 se_eligio_carta = 0;
	 $display("\n-> DOS CARTAS");
    #20 cartas_verificadas = 1; hubo_pareja = 0; #10 cartas_verificadas = 0;

    // Paso 6: Simular fin de partida (8 puntos totales)
    $display("\n-> DEBERIA DE SEGUIR EN 0101 Y CAMBIAMOS PUNTAJES");
    dut.puntaje_j1 = 2;
	 dut.puntaje_j2 = 4;
    #50;
	 
	 $display("\n-> TURNO JUGADOR 1: Encuentra una pareja");
    #100 se_eligio_carta = 1; #10 se_eligio_carta = 0;
	 $display("\n-> UNA CARTA");
    #50 se_eligio_carta = 1; #10 se_eligio_carta = 0;
	 $display("\n-> DOS CARTAS");
    #20 cartas_verificadas = 1; hubo_pareja = 1; #10 cartas_verificadas = 0;
	 $display("\n-> DEBERIA DE SEGUIR 0101 con jugador 1");
	 
	 $display("\n-> TURNO JUGADOR 1: Encuentra una pareja");
	 #100 tiempo_terminado = 1; #10 tiempo_terminado = 0;
	 $display("\n-> TURNO JUGADOR 1: DEBERIA DE MOSTRAR DOS CARTAS RANDOM");
	 #50 carta_randomizada = 1; #10 carta_randomizada = 0;
    $display("\n-> DOS CARTAS");
    #20 cartas_verificadas = 1; hubo_pareja = 1; #10 cartas_verificadas = 0;
	 $display("\n-> DEBERIA DE SEGUIR CON EL FINAL DE LA PARTIDA con jugador 1");


    // Paso 7: Estado de conclusión
    $display("\n-> Llegando a CONCLUSION");
    #100 inicio = 1; #10 inicio = 0; 
	 

    $display("\n===== FIN DE SIMULACIÓN =====");
    $stop;
  end

  // ----------------------------------------------------------
  // Monitoreo continuo
  // ----------------------------------------------------------
  always @(posedge clk) begin
    $display("t=%0t | state=%b | turno=%0d | resetT=%b | J1=%0d | J2=%0d | pareja=%b | ganador=%b",
      $time, state, turno_de, reset_timer, puntajeJ1, puntajeJ2, hubo_pareja, ganador);
  end

endmodule