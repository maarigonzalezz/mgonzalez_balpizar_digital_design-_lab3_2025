module top_shuffle_tb;

    // -----------------------------------------------------
    // Señales
    // -----------------------------------------------------
    logic clk;
    logic rst;
    logic start, done;
    logic [79:0] in_cards_flat;   // 16 cartas * 5 bits = 80 bits
    logic [79:0] out_cards_flat;

    // -----------------------------------------------------
    // Instancia del top_shuffle
    // -----------------------------------------------------
    top_shuffle uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .out_cards_flat(out_cards_flat),
        .done(done)
    );

    // -----------------------------------------------------
    // Reloj
    // -----------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk; // periodo 10ns

    // -----------------------------------------------------
    // Inicialización de cartas: 8 símbolos, cada uno repetido 2 veces
    // -----------------------------------------------------
    initial begin
        integer i;
        logic [2:0] symbols[0:7];

        // Definir símbolos 0..7
        for (i = 0; i < 8; i++)
            symbols[i] = i;

        // Construir baraja inicial: cada símbolo aparece 2 veces, bits de estado en 0
        for (i = 0; i < 16; i++)
            in_cards_flat[i*5 +: 5] = {symbols[i/2], 2'b00};
    end

    // -----------------------------------------------------
    // Proceso principal de simulación
    // -----------------------------------------------------
    initial begin
        $display("=== INICIO DE PRUEBA TOP SHUFFLE ===");

        // Imprimir baraja inicial
        $display("\n--- Baraja inicial ---");
        print_cards(in_cards_flat);

        rst = 1; start = 0; #20;
        rst = 0; #10;

        // ----------------------------
        // Primer shuffle
        // ----------------------------
        #50;          // esperar tiempo para que el bit_shifter cambie
        start = 1; #10;
        start = 0;
        wait(done);
        $display("\n--- Barajado 1 ---");
        print_cards(out_cards_flat);
        done = 0;

        // ----------------------------
        // Segundo shuffle
        // ----------------------------
        #100;          // esperar más tiempo, bit_shifter cambia
        start = 1; #10;
        start = 0;
        wait(done);
        $display("\n--- Barajado 2 ---");
        print_cards(out_cards_flat);
        done = 0;

        // ----------------------------
        // Tercer shuffle
        // ----------------------------
        #110;          // esperar aún más tiempo
        start = 1; #10;
        start = 0;
        wait(done);
        $display("\n--- Barajado 3 ---");
        print_cards(out_cards_flat);
        done = 0;

        $display("\n=== FIN DE SIMULACIÓN ===");
        $finish;
    end

    // -----------------------------------------------------
    // Tarea auxiliar para imprimir cartas
    // -----------------------------------------------------
    task print_cards(input logic [79:0] cards_flat);
        integer k;
        begin
            for (k = 0; k < 16; k++)
                $display("Carta[%0d] = %b", k, cards_flat[k*5 +: 5]);
        end
    endtask

endmodule
