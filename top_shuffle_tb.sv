module top_shuffle_tb;

    // -----------------------------------------------------
    // Señales
    // -----------------------------------------------------
    logic clk;
    logic rst;
    logic start, done;
    logic [4:0] arr_cards [0:15]; // Salida directa del shuffle

    // -----------------------------------------------------
    // Instancia del top_shuffle
    // -----------------------------------------------------
    top_shuffle uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .arr_cards(arr_cards)
    );

    // -----------------------------------------------------
    // Reloj
    // -----------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk; // periodo 10ns

    // -----------------------------------------------------
    // Proceso principal de simulación
    // -----------------------------------------------------
    initial begin
        $display("=== INICIO DE PRUEBA TOP SHUFFLE ===");

        rst = 1; start = 0; #20;
        rst = 0; #10;

        // ----------------------------
        // Primer shuffle
        // ----------------------------
        #50;
        start = 1; #10;
        start = 0;
        wait(done);
        $display("\n--- Barajado 1 ---");
        print_cards(arr_cards);
        done = 0;

        // ----------------------------
        // Segundo shuffle
        // ----------------------------
        #100;
        start = 1; #10;
        start = 0;
        wait(done);
        $display("\n--- Barajado 2 ---");
        print_cards(arr_cards);
        done = 0;

        // ----------------------------
        // Tercer shuffle
        // ----------------------------
        #110;
        start = 1; #10;
        start = 0;
        wait(done);
        $display("\n--- Barajado 3 ---");
        print_cards(arr_cards);
        done = 0;

        $display("\n=== FIN DE SIMULACIÓN ===");
        $finish;
    end

    // -----------------------------------------------------
    // Tarea auxiliar para imprimir cartas (MSB → LSB)
    // -----------------------------------------------------
    task print_cards(input logic [4:0] cards [0:15]);
        integer k;
        begin
            $display("\n--- Baraja ---");
            for (k = 0; k < 16; k++)
                $display("Carta[%0d] = %b", k, cards[k]);
        end
    endtask

endmodule
