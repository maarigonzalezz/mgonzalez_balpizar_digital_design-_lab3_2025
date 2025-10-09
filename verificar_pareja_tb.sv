`timescale 1ns/1ns

module verificar_pareja_tb;

    // -----------------------------------------------------
    // Señales del DUT
    // -----------------------------------------------------
    logic clk;
    logic rst;
    logic start;
    logic [4:0] arr_cards_in [0:15];
    logic [4:0] arr_cards_out [0:15];
    logic done;
    logic hubo_pareja;

    // -----------------------------------------------------
    // Instancia del DUT
    // -----------------------------------------------------
    verificar_pareja uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .arr_cards_in(arr_cards_in),
        .arr_cards_out(arr_cards_out),
        .done(done),
        .hubo_pareja(hubo_pareja)
    );

    // -----------------------------------------------------
    // Generador de reloj
    // -----------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    // -----------------------------------------------------
    // Secuencia de prueba principal
    // -----------------------------------------------------
    initial begin
        $display("\n=== INICIO DE PRUEBA verificar_pareja ===\n");

        rst = 1; start = 0;
        #20;
        rst = 0;
        #10;

        // Caso 1: hay pareja
        initialize_cards();
        arr_cards_in[0] = 5'b10101; // carta abierta 1
        arr_cards_in[1] = 5'b10101; // carta abierta 2, misma simbología → pareja
        run_test(1);

        // Caso 2: dos abiertas pero no coinciden
        initialize_cards();
        arr_cards_in[0] = 5'b01101;
        arr_cards_in[1] = 5'b10001;
        run_test(2);

        $display("\n=== FIN DE SIMULACIÓN ===");
        $finish;
    end

    // -----------------------------------------------------
    // Tarea para inicializar cartas cerradas (estado 11)
    // -----------------------------------------------------
    task initialize_cards();
        integer k;
        begin
            for (k = 0; k < 16; k = k + 1)
                arr_cards_in[k] = 5'b00011; // símbolo = 000, estado = 11
        end
    endtask

    // -----------------------------------------------------
    // Ejecuta DUT y espera done
    // -----------------------------------------------------
    task run_test(input integer case_num);
        integer k;
        begin
				
				 // Aplicar reset rápido
				  rst = 1;
				  @(posedge clk);
				  rst = 0;
				  @(posedge clk);
				
		  
            $display("\n--- Antes del Caso %0d ---", case_num);
            for (k=0; k<16; k=k+1)
                $display("Carta[%0d] = %b", k, arr_cards_in[k]);

            start = 1;
            @(posedge clk);
            start = 0;
            wait(done == 1);

            $display("--- Caso %0d terminado: hubo_pareja=%b ---", case_num, hubo_pareja);
            $display("--- Después del Caso %0d ---", case_num);
            for (k=0; k<16; k=k+1)
                $display("Carta[%0d] = %b", k, arr_cards_out[k]);

					 
				// Aplicar reset rápido
				 rst = 1;
				 @(posedge clk);
				 rst = 0;
				 @(posedge clk);
				 
            #10;
        end
    endtask

endmodule
