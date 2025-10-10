module Shuffle_tb;

    // Señales de prueba
    logic clk;
    logic rst;
    logic start;
    logic [7:0] seed;
    logic [4:0] arr_cards [0:15];
    logic done;

    // Instancia del módulo Shuffle
    Shuffle uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .seed(seed),
        .arr_cards(arr_cards),
        .done(done)
    );

    // Registro para capturar done en el top-level
    logic done_reg;
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            done_reg <= 0;
        else
            done_reg <= done;
    end

    // Reloj
    initial clk = 0;
    always #5 clk = ~clk; // 100MHz aprox

    // Test sequence
    initial begin
        rst = 1;
        start = 0;
        seed = 8'hA5;

        #12;
        rst = 0;

        #10;
        start = 1;   // Inicia el shuffle
        #10;
        start = 0;   // Pulso de start

        // Esperar unos ciclos para ver done
        #50;

        $finish;
    end

    // Monitoreo
    initial begin
        $display("Tiempo | done | done_reg");
        $monitor("%4t |   %b  |    %b", $time, done, done_reg);
    end

endmodule

