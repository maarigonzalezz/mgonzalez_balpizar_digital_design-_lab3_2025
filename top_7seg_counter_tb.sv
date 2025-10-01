
module top_7seg_counter_tb;

    // -------------------------
    // Señales internas del TB
    // -------------------------
    logic clk;
    logic rst;
    logic [6:0] seg;
    logic [3:0] an;

    // -------------------------
    // Parámetros de simulación
    // -------------------------
    localparam CLOCK_FREQ_HZ_SIM = 10;   // Simulación: 10 Hz
    localparam CLK_PERIOD = 100_000_000; // 10ns * 100M = 1s, ajustamos abajo

    // -------------------------
    // Instancia del DUT
    // -------------------------
    top_7seg_counter DUT (
        .clk(clk),
        .rst(rst),
        .seg(seg),
        .an(an)
    );

    // -------------------------
    // Override del parámetro para simulación
    // -------------------------
    defparam DUT.u_clk_counter.CLOCK_FREQ_HZ = CLOCK_FREQ_HZ_SIM;

    // -------------------------
    // Generación del reloj
    // -------------------------
    initial begin
        clk = 0;
        forever #50 clk = ~clk; // Periodo de 100 ns (10 MHz real en sim)
    end

    // -------------------------
    // Estímulos
    // -------------------------
    initial begin
        // Reset inicial
        rst = 1;
        #200;
        rst = 0;

        // Correr por unos ciclos para ver el conteo 0-F
        repeat (20) begin
            #1000; // Esperar tiempo para ver cambios
            $display("Time=%0t | seg=%b | an=%b", $time, seg, an);
        end

        $stop;
    end

endmodule