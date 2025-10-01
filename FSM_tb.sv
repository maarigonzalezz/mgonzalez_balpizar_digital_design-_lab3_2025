module tb_FSM();

    logic clk;
    logic rst;
    logic m;
    logic [1:0] cartas_seleccionadas;
    logic [7:0] estado;

    // Instancia de la FSM
    FSM uut (
        .clk(clk),
        .rst(rst),
        .m(m),
        .cartas_seleccionadas(cartas_seleccionadas),
        .estado(estado)
    );

    // Generador de reloj
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz ciclo de prueba rápido

    initial begin
        // Inicialización
        rst = 1;
        m = 0;
        cartas_seleccionadas = 2'b00;
        #10 rst = 0;

        // --------------------------
        // Estados iniciales 00000 -> 00101
        // --------------------------
        m = 1; #10; m = 0; // 00000 -> 00001
        m = 1; #10; m = 0; // 00001 -> 00010
        m = 1; #10; m = 0; // 00010 -> 00011
        m = 1; #10; m = 0; // 00011 -> 00100
        m = 1; #10; m = 0; // 00100 -> 00101

        // --------------------------
        // Turno jugador 1
        // --------------------------
        cartas_seleccionadas = 2'b00; #10; // No selecciona -> debe ir a 01000
        #1 uut.contador_tiempo = 16;        // Forzar tiempo agotado
        #10 cartas_seleccionadas = 2'b01;  // Selecciona 1 carta -> 00110
        #10 cartas_seleccionadas = 2'b10;  // Selecciona 2da carta -> 00111
        #1 uut.jugador_1_tiene_pareja = 1; // Simula que encontró pareja
        #10 cartas_seleccionadas = 2'b00;  // Siguiente turno jugador 1 o paso a jugador 2
        #1 uut.jugador_1_tiene_pareja = 0; // Reset indicador

        // --------------------------
        // Turno jugador 2
        // --------------------------
        cartas_seleccionadas = 2'b00; #10; // No selecciona -> debe ir a 01100
        #1 uut.contador_tiempo = 16;        // Forzar tiempo agotado
        #10 cartas_seleccionadas = 2'b01;  // Selecciona 1 carta -> 01010
        #10 cartas_seleccionadas = 2'b10;  // Selecciona 2da carta -> 01011
        #1 uut.jugador_2_tiene_pareja = 1; // Simula que encontró pareja
        #10 cartas_seleccionadas = 2'b00;  // Siguiente turno jugador 1
        #1 uut.jugador_2_tiene_pareja = 0; // Reset indicador

        // --------------------------
        // Estados de resultado
        // --------------------------
        #10;
        #1 uut.j1_num_parejas = 4;  // Total de parejas jugador 1
        #1 uut.j2_num_parejas = 4;  // Total de parejas jugador 2
        #1 uut.puntaje_j1 = 5;       // Puntaje jugador 1
        #1 uut.puntaje_j2 = 3;       // Puntaje jugador 2
        #10; // Se activa 01101 -> debe ir a 01110 (gana J1)

        #1 uut.puntaje_j1 = 3;       // Puntaje jugador 1
        #1 uut.puntaje_j2 = 5;       // Puntaje jugador 2
        #10; // Se activa 01101 -> debe ir a 01111 (gana J2)

        #1 uut.puntaje_j1 = 4;       // Empate
        #1 uut.puntaje_j2 = 4;       
        #10; // Se activa 01101 -> debe ir a 10000 (empate)

        // --------------------------
        // Terminar simulación
        // --------------------------
        #50 $stop;
    end

endmodule