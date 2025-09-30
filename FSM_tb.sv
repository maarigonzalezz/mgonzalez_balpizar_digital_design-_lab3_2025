`timescale 1ns/1ps

module tb_FSM;

    // Señales de prueba
    logic clk;
    logic rst;
    logic m;
    logic [1:0] cartas_seleccionadas;
    logic [7:0] estado;

    // Señales internas para controlar parejas y puntajes
    logic jugador_1_tiene_pareja;
    logic jugador_2_tiene_pareja;

    // Instancia de la FSM
    FSM dut (
        .clk(clk),
        .rst(rst),
        .m(m),
        .cartas_seleccionadas(cartas_seleccionadas),
        .estado(estado)
    );

    // -------------------------
    // Generación de reloj: 10ns de período
    // -------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // -------------------------
    // Secuencia de prueba
    // -------------------------
    initial begin
        // Inicializar todas las señales
        rst = 1;
        m = 0;
        cartas_seleccionadas = 2'b00;
        jugador_1_tiene_pareja = 0;
        jugador_2_tiene_pareja = 0;

        // Reset inicial
        #20;
        rst = 0;

        // -------------------------
        // Avanzar estados iniciales 00000 -> 00100
        // -------------------------
        repeat (5) begin
            m = 1;
            #10;
            m = 0;
            #10;
        end

        // -------------------------
        // Turno jugador 1: 0, 1 y 2 cartas seleccionadas
        // -------------------------
        cartas_seleccionadas = 2'b00;
        #10;

        cartas_seleccionadas = 2'b01;
        #10;

        cartas_seleccionadas = 2'b10;
        #10;

        // Simular jugador 1 tiene pareja
        jugador_1_tiene_pareja = 1;
        #10;
        jugador_1_tiene_pareja = 0;
        #10;

        // -------------------------
        // Turno jugador 2: 0, 1 y 2 cartas seleccionadas
        // -------------------------
        cartas_seleccionadas = 2'b00;
        #10;

        cartas_seleccionadas = 2'b01;
        #10;

        cartas_seleccionadas = 2'b10;
        #10;

        // Simular jugador 2 tiene pareja
        jugador_2_tiene_pareja = 1;
        #10;
        jugador_2_tiene_pareja = 0;
        #10;

        // -------------------------
        // Escenarios de fin de juego
        // -------------------------
        // Jugador 1 gana
        dut.puntaje_j1 = 3'b101;  // 5 puntos
        dut.puntaje_j2 = 3'b010;  // 2 puntos
        dut.state = 5'b01101;
        #10;

        // Jugador 2 gana
        dut.puntaje_j1 = 3'b001;
        dut.puntaje_j2 = 3'b011;
        dut.state = 5'b01101;
        #10;

        // Empate
        dut.puntaje_j1 = 3'b100;
        dut.puntaje_j2 = 3'b100;
        dut.state = 5'b01101;
        #10;

        $finish;
    end

    // -------------------------
    // Monitoreo de señales
    // -------------------------
    initial begin
        $monitor("Tiempo=%0t | Estado=%b | cartas=%b | jugador1=%b | jugador2=%b | m=%b", 
                 $time, estado, cartas_seleccionadas, jugador_1_tiene_pareja, jugador_2_tiene_pareja, m);
    end

endmodule