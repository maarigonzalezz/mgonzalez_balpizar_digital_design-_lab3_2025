// MEF TESTBENCH actualizado para puntaje_j1 y puntaje_j2
module FSM_tb();
    logic m;
    logic rst;
    logic clk;
    logic [7:0] estado;
    logic [2:0] puntaje_j1, puntaje_j2; // puntajes de 0 a 4

    // Instancia de la MEF
    MEF_T2 fsm(
        .m(m),
        .puntaje_j1(puntaje_j1),
        .puntaje_j2(puntaje_j2),
        .rst(rst),
        .clk(clk),
        .estado(estado)
    );

    // Generador de reloj, invierte el valor de clk cada 10 unidades de tiempo
    always begin
        #10 clk = ~clk;
    end

    // Monitor para ver cambios
    initial begin
        $monitor("t=%0t | clk=%b rst=%b m=%b j1=%d j2=%d estado=%b", 
                  $time, clk, rst, m, puntaje_j1, puntaje_j2, estado);
    end

    // TEST
    initial begin
        // Valores iniciales
        clk = 0;
        m = 0;
        rst = 1;
        puntaje_j1 = 0;
        puntaje_j2 = 0;
        #40
        rst = 0;  // Quitar reset
        #40

        // Avanzar estados con diferentes combinaciones
        m = 1; puntaje_j1 = 2; puntaje_j2 = 1; #40
        m = 1; puntaje_j1 = 4; puntaje_j2 = 3; #40

        // Probar los 3 caminos en el estado 01101
        m = 1; puntaje_j1 = 4; puntaje_j2 = 2; #40  // j1 > j2 → debería ir a 01110
        m = 1; puntaje_j1 = 1; puntaje_j2 = 3; #40  // j1 < j2 → debería ir a 01111
        m = 1; puntaje_j1 = 2; puntaje_j2 = 2; #40  // empate → debería ir a 10000

        // Reset final
        rst = 1; #40
        rst = 0; #40

        // Tiempo adicional para observar cambios
        #100;
        $finish;
    end
endmodule
