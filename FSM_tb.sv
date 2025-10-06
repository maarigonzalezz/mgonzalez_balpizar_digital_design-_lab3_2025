`timescale 1ns/1ps

module FSM_tb;

    // Señales
    logic m, rst, clk;
    logic [1:0] cartas_seleccionadas;
    logic tiempo_terminado, inicio, se_eligio_carta;
    logic cartas_mostradas, cartas_ocultas, cartas_revueltas;
    logic jugador_tiene_pareja;
    logic [1:0] ganador;

    // Instancia de la FSM
    FSM uut (
        .m(m),
        .rst(rst),
        .clk(clk),
        .cartas_seleccionadas(cartas_seleccionadas),
        .tiempo_terminado(tiempo_terminado),
        .inicio(inicio),
        .se_eligio_carta(se_eligio_carta),
        .cartas_mostradas(cartas_mostradas),
        .cartas_ocultas(cartas_ocultas),
        .cartas_revueltas(cartas_revueltas),
        .ganador(ganador)
    );

    // Señal interna para simular parejas
    initial begin
        // Inicialización
        clk = 0;
        rst = 1; inicio = 0; se_eligio_carta = 0; tiempo_terminado = 0;
        cartas_mostradas = 0; cartas_ocultas = 0; cartas_revueltas = 0;
        cartas_seleccionadas = 0; m = 0; jugador_tiene_pareja = 0;
        #10;
        rst = 0;
    end

    // Clock
    always #5 clk = ~clk;

    // Secuencia de estímulos
    initial begin
        // 0000 -> 0001
        inicio = 1; #10; inicio = 0; #10;

        // 0001 -> 0010
        cartas_mostradas = 1; #10; cartas_mostradas = 0; #10;

        // 0010 -> 0011
        cartas_ocultas = 1; #10; cartas_ocultas = 0; #10;

        // 0011 -> 0100
        cartas_revueltas = 1; #10; cartas_revueltas = 0; #10;

        // 0100 -> 0101
        #10;

        // 0101 -> 0110 (selecciona carta)
        se_eligio_carta = 1; #10; se_eligio_carta = 0; #10;

        // 0110 -> 0111 (selecciona segunda carta)
        se_eligio_carta = 1; #10; se_eligio_carta = 0; #10;

        // 0111 -> 0101 o puntaje
        jugador_tiene_pareja = 1;  // simula que encontró pareja
        // Incrementamos manualmente los puntajes para llegar a 8
        uut.puntaje_j1 = 4;
        uut.puntaje_j2 = 4;
        #10;
        jugador_tiene_pareja = 0; // siguiente turno

        // 0101 -> 1000 por tiempo terminado
        tiempo_terminado = 1; #10; tiempo_terminado = 0; #10;

        // 1000 -> 0110 (según cartas_seleccionadas_reg)
        cartas_seleccionadas = 2'b00; #10;

        // 0110 -> 0111 nuevamente
        se_eligio_carta = 1; #10; se_eligio_carta = 0; #10;

        // 0111 -> 1001 (fin de juego con puntajes sumando 8)
        jugador_tiene_pareja = 1; 
        #10;
        jugador_tiene_pareja = 0;

        // 1001 -> 1010
        #10;

        // 1010 -> 0000 (reinicio final)
        #10;

        $finish;
    end

endmodule