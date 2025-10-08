module top_mostrar_carta_random_tb;

    // -----------------------------------------------------
    // Señales
    // -----------------------------------------------------
    logic clk;
    logic rst;
    logic start;
    logic done;
    logic [4:0] arr_cards_in [0:15];   // Array de entrada
    logic [4:0] arr_cards_out [0:15];  // Array de salida

    // -----------------------------------------------------
    // Instancia del top_mostrar_carta_random
    // -----------------------------------------------------
    top_mostrar_carta_random uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .arr_cards_in(arr_cards_in),
        .arr_cards_out(arr_cards_out),
        .done(done)
    );

    // -----------------------------------------------------
    // Reloj
    // -----------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk; // periodo 10ns

    // -----------------------------------------------------
    // Inicializar array con estado 11, excepto varias cartas en 00
    // -----------------------------------------------------
    initial begin
        integer i;
        for (i = 0; i < 16; i++)
            arr_cards_in[i] = 5'bxxxxx11; // MSB indefinidos, LSB = 11

        // Poner varias cartas en 00
        arr_cards_in[2]  = 5'bxxxxx00;
        arr_cards_in[4]  = 5'bxxxxx00;
        arr_cards_in[7]  = 5'bxxxxx00;
        arr_cards_in[10] = 5'bxxxxx00;
        arr_cards_in[12] = 5'bxxxxx00;
    end

    // -----------------------------------------------------
    // Proceso principal de simulación
    // -----------------------------------------------------
    initial begin
        $display("=== INICIO DE PRUEBA mostrar_carta_random ===");

        rst = 1; start = 0; #20;
        rst = 0; #20;

        $display("\n--- Estado antes de mostrar_carta_random ---");
        print_cards(arr_cards_in);

        // Activar módulo
        start = 1; #30;
        start = 0;

        wait(done);

        $display("\n--- Estado después de mostrar_carta_random ---");
        print_cards(arr_cards_out);

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
