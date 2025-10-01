module FSM_tb();

    // -------------------------
    // Señales de prueba
    // -------------------------
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

    // -------------------------
    // Generador de reloj
    // -------------------------
    initial clk = 0;
    always #5 clk = ~clk; // Ciclo de reloj de 10 unidades de tiempo

    // -------------------------
    // Secuencia de prueba
    // -------------------------
    initial begin
        // Inicialización
        rst = 1;
        m = 0;
        cartas_seleccionadas = 2'b00;
        @(posedge clk); 
        rst = 0;
        @(posedge clk);

        // -------------------------
        // Estados iniciales 00000 -> 00101
        // -------------------------
        m = 1; @(posedge clk); m = 0; @(posedge clk); // 00000 -> 00001
        m = 1; @(posedge clk); m = 0; @(posedge clk); // 00001 -> 00010
        m = 1; @(posedge clk); m = 0; @(posedge clk); // 00010 -> 00011
        m = 1; @(posedge clk); m = 0; @(posedge clk); // 00011 -> 00100
        m = 1; @(posedge clk); m = 0; @(posedge clk); // 00100 -> 00101

        // -------------------------
        // Turno jugador 1
        // -------------------------
        // Forzar tiempo agotado para mostrar carta (00101 -> 01000)
        @(posedge clk);
        uut.contador_tiempo = 16;   // fuerza la transición
        cartas_seleccionadas = 2'b00;
        @(posedge clk);
        uut.contador_tiempo = 0;    // reinicia

        // Selección de cartas
        cartas_seleccionadas = 2'b01; @(posedge clk); // 01000 -> 00110
        cartas_seleccionadas = 2'b10; @(posedge clk); // 00110 -> 00111

        // Evaluar pareja
        uut.jugador_1_tiene_pareja = 1;
        @(posedge clk); 
        cartas_seleccionadas = 2'b00;
        @(posedge clk); 
        uut.jugador_1_tiene_pareja = 0;
        @(posedge clk);

        // -------------------------
        // Turno jugador 2
        // -------------------------
        // Forzar tiempo agotado para mostrar carta (01001 -> 01100)
        @(posedge clk);
        uut.contador_tiempo = 16;   // fuerza la transición
        cartas_seleccionadas = 2'b00;
        @(posedge clk);
        uut.contador_tiempo = 0;    // reinicia

        // Selección de cartas
        cartas_seleccionadas = 2'b01; @(posedge clk); // 01100 -> 01010
        cartas_seleccionadas = 2'b10; @(posedge clk); // 01010 -> 01011

        // Evaluar pareja
        uut.jugador_2_tiene_pareja = 1;
        @(posedge clk); 
        cartas_seleccionadas = 2'b00;
        @(posedge clk); 
        uut.jugador_2_tiene_pareja = 0;
        @(posedge clk);

        // -------------------------
        // Estados de resultado
        // -------------------------
        uut.j1_num_parejas = 4;
        uut.j2_num_parejas = 4;
        @(posedge clk);

        // Puntaje jugador 1 gana
        uut.puntaje_j1 = 5;
        uut.puntaje_j2 = 3;
        @(posedge clk);

        // Puntaje jugador 2 gana
        uut.puntaje_j1 = 3;
        uut.puntaje_j2 = 5;
        @(posedge clk);

        // Empate
        uut.puntaje_j1 = 4;
        uut.puntaje_j2 = 4;
        @(posedge clk);

        // -------------------------
        // Terminar simulación
        // -------------------------
        @(posedge clk);
        $stop;
    end

endmodule
