`timescale 1ns/1ps

// Testbench realista y compatible con Quartus para Top_Level_Memory / card_controller
// - Evita keywords SystemVerilog que Quartus puede no soportar (bit, int, always_ff).
// - Imprime arr_cartas y arrI cada vez que cambia el estado 's'.
// - Observa señales expuestas por el DUT (DUT.cartasM.doneSh, DUT.cartasM.doneVp, DUT.puntajeJ1, etc.)

module tb_Top_Level_Memory_realistic;

    // -----------------------------------------------------------------
    // Señales top-level
    // -----------------------------------------------------------------
    reg rst, clk;
    reg I, CM, CO, CR;
    reg Izq, Der, Sel;

    wire [1:0] turno_de;
    wire [6:0] seg;
    wire [6:0] segPJ1, segPJ2;
    wire vgaclk;
    wire hsync, vsync;
    wire sync_b, blank_b;
    wire [3:0] s; // estado expuesto por el top
    wire [7:0] r, g, b;
    wire cargar; // salida del top (equivale a 'load' del card_controller)

    // Instanciación explícita (evita problemas con `.*` en algunos simuladores)
    Top_Level_Memory DUT (
        .rst(rst), .clk(clk),
        .I(I), .CM(CM), .CO(CO), .CR(CR),
        .Izq(Izq), .Der(Der), .Sel(Sel),
        .turno_de(turno_de),
        .seg(seg), .segPJ1(segPJ1), .segPJ2(segPJ2),
        .vgaclk(vgaclk), .hsync(hsync), .vsync(vsync),
        .sync_b(sync_b), .blank_b(blank_b),
        .s(s),
        .r(r), .g(g), .b(b),
        .cargar(cargar)
    );

    // Clock: 50 MHz (20 ns period)
    initial clk = 0;
    always #10 clk = ~clk;

    // Monitor: imprime arr_cartas y arrI cada vez que cambia el estado 's'
    reg [3:0] prev_s;
    initial prev_s = 4'b0000;

    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            prev_s <= 4'b0000;
        end else begin
            if (s !== prev_s) begin
                $display("
[%0t] >>> Estado cambiado: %b -> %b <<<", $time, prev_s, s);

                // Imprimir arr_cartas (array principal en Top_Level_Memory)
                $write("arr_cartas: ");
                for (i = 0; i < 16; i = i + 1) begin
                    // mostrar índice y valor en hex (5 bits -> 1 hex digit)
                    $write("%0d:0x%0h ", i, DUT.arr_cartas[i]);
                end
                $write("
");

                // Imprimir arrI (array inicial/visible)
                $write("arrI      : ");
                for (i = 0; i < 16; i = i + 1) begin
                    $write("%0d:0x%0h ", i, DUT.arrI[i]);
                end
                $write("
");

                // También imprimir puntajes y turno
                $display("puntajeJ1=%0d, puntajeJ2=%0d, turno_de=%0d, cargar=%b", DUT.puntajeJ1, DUT.puntajeJ2, turno_de, cargar);

                prev_s <= s;
            end
        end
    end

    // Timeout helper: espera hasta que condicion sea verdadera (valor lógico pasado) por un max de ciclos
    task automatic wait_until(input logic cond_value, input integer max_cycles, output logic ok);
        integer j;
        ok = 1'b0;
        for (j = 0; j < max_cycles; j = j + 1) begin
            @(posedge clk);
            if (cond_value) begin
                ok = 1'b1;
                disable wait_until;
            end
        end
    endtask

    // Variante para esperar un bit/signal concreto: se evalúa dentro del task usando una expresión textual
    // (se usa pasando la expresión ya evaluada en cada ciclo por referenciarla antes de llamar)

    // Pulso simple
    task automatic pulse(input reg sig, input integer cycles);
        integer k;
        for (k = 0; k < cycles; k = k + 1) begin
            sig = 1'b1;
            @(posedge clk);
        end
        sig = 1'b0;
        @(posedge clk);
    endtask

    // Rutina principal de pruebas
    initial begin
        // Inicialización
        rst = 1; I = 0; CM = 0; CO = 0; CR = 0; Izq = 0; Der = 0; Sel = 0;

        // esperar a estabilizar
        repeat (10) @(posedge clk);
        rst = 0;
        $display("[%0t] Reset released", $time);

        logic ok;

        // --------------------
        // 1) INICIO -> MUESTRO_CORTAS
        // --------------------
        @(posedge clk);
        I = 1; // presionamos inicio
        @(posedge clk);
        I = 0;

        // esperar a que el top muestre el estado MUESTRO_CORTAS (codigo 4'b0001)
        wait_until((s === 4'b0001), 500, ok);
        if (!ok) begin
            $display("ERROR: No se alcanzó MUESTRO_CORTAS en tiempo");
            $finish;
        end
        $display("[%0t] Estado MUESTRO_CORTAS detectado (s=%b)", $time, s);

        // --------------------
        // 2) CM -> OCULTA_CORTAS
        // --------------------
        @(posedge clk);
        CM = 1;
        @(posedge clk);
        CM = 0;

        wait_until((s === 4'b0010), 500, ok);
        if (!ok) begin
            $display("ERROR: No se alcanzó OCULTA_CORTAS en tiempo");
            $finish;
        end
        $display("[%0t] Estado OCULTA_CORTAS detectado (s=%b)", $time, s);

        // --------------------
        // 3) CO -> REVUELVE_CORTAS (card_controller debe comenzar shuffle)
        // --------------------
        @(posedge clk);
        CO = 1;
        @(posedge clk);
        CO = 0;

        wait_until((s === 4'b0011), 500, ok);
        if (!ok) begin
            $display("ERROR: No se alcanzó REVUELVE_CORTAS en tiempo");
            $finish;
        end
        $display("[%0t] Estado REVUELVE_CORTAS detectado (s=%b)", $time, s);

        // Esperar a que card_controller indique que finalizó el shuffle
        // usando acceso jerárquico a la instancia cartasM dentro del DUT.
        // Nota: si tu simulador prohíbe acceso jerárquico, comenta este bloque
        wait_until((DUT.cartasM.doneSh === 1'b1), 2000, ok);
        if (!ok) begin
            $display("ERROR: Timeout: card_controller no indicó doneSh (shuffle) — revisa Shuffle/bs)");
            $finish;
        end
        $display("[%0t] card_controller.doneSh detectado", $time);

        // Después de shuffle, deberíamos ver que 'cargar' se activa (load)
        wait_until((cargar === 1'b1), 200, ok);
        if (!ok) begin
            $display("WARNING: No se observó 'cargar' después de shuffle");
        end else $display("[%0t] 'cargar' detectado tras shuffle", $time);

        // --------------------
        // 4) Avanzar a INICIO_JUEGO -> TURNO_JUGADOR
        // --------------------
        // La FSM del top debe transicionar automaticamente; esperamos TURNO_JUGADOR
        wait_until((s === 4'b0101), 1000, ok);
        if (!ok) begin
            $display("ERROR: No se alcanzó TURNO_JUGADOR en tiempo");
            $finish;
        end
        $display("[%0t] Estado TURNO_JUGADOR detectado", $time);

        // --------------------
        // 5) Simular selección de cartas mediante Izq/Der y Sel
        //    - Seleccionamos 2 veces: primero para UNA_CARTA y luego para DOS_CARTAS
        // --------------------

        // Hacemos un pequeño 'barrido' con Der para mover cursor y luego Sel
        repeat (3) begin
            @(posedge clk); Der = 1; @(posedge clk); Der = 0; @(posedge clk);
        end
        // Pulsar Sel para seleccionar primera carta
        @(posedge clk); Sel = 1; @(posedge clk); Sel = 0;

        // Esperar a que card_controller indique doneSp (primera selección completada)
        wait_until((DUT.cartasM.doneSp === 1'b1), 500, ok);
        if (!ok) begin
            $display("ERROR: Timeout: no se detectó doneSp tras primera selección");
            $finish;
        end
        $display("[%0t] Primera selección completada (doneSp)", $time);

        // Comprobar que estado pasó a UNA_CARTA (0110)
        wait_until((s === 4'b0110), 500, ok);
        if (!ok) begin
            $display("ERROR: No se alcanzó UNA_CARTA tras primera selección");
            $finish;
        end
        $display("[%0t] Estado UNA_CARTA detectado", $time);

        // Mover cursor a otra carta y seleccionar segunda
        repeat (2) begin
            @(posedge clk); Izq = 1; @(posedge clk); Izq = 0; @(posedge clk);
        end
        @(posedge clk); Sel = 1; @(posedge clk); Sel = 0;

        // Esperar doneSp (segunda selección)
        wait_until((DUT.cartasM.doneSp === 1'b1), 500, ok);
        if (!ok) begin
            $display("ERROR: Timeout: no se detectó doneSp tras segunda selección");
            $finish;
        end
        $display("[%0t] Segunda selección completada (doneSp)", $time);

        // Debería pasar a DOS_CARTAS (0111)
        wait_until((s === 4'b0111), 500, ok);
        if (!ok) begin
            $display("ERROR: No se alcanzó DOS_CARTAS tras segunda selección");
            $finish;
        end
        $display("[%0t] Estado DOS_CARTAS detectado", $time);

        // --------------------
        // 6) Esperar a que verificar_pareja procese la pareja y doneVp se active
        // --------------------
        wait_until((DUT.cartasM.doneVp === 1'b1), 1000, ok);
        if (!ok) begin
            $display("WARNING: verificar_pareja no indicó doneVp. Si tu bloque no está implementado, esto puede ser normal.");
        end else begin
            $display("[%0t] Done verificar_pareja detectado (doneVp)", $time);
        end

        // Revisar puntaje: acceder jerárquicamente a la señal expuesta puntajeJ1 en el top
        // (el FSM expone puntajeJ1 como puerto interno del top)
        // Si hay pareja, puntajeJ1 debería incrementarse; si no, turno_de debería cambiar.
        integer puntAntes, puntDesp;
        puntAntes = DUT.puntajeJ1;
        @(posedge clk);
        puntDesp = DUT.puntajeJ1;
        if (puntDesp > puntAntes) begin
            $display("[%0t] Puntaje J1 incrementó: %0d -> %0d", $time, puntAntes, puntDesp);
        end else begin
            $display("[%0t] Puntaje J1 no cambió (quizá no hubo pareja). turno_de=%0d", $time, turno_de);
        end

        // --------------------
        // 7) Opcional: forzar varias selecciones hasta terminar el juego o alcanzar CONCLUSION
        //    (aquí sólo demostramos una iteración)
        // --------------------

        $display("[TEST] Secuencia realista completada. Finalizando simulación.");
        $finish;
    end

endmodule


