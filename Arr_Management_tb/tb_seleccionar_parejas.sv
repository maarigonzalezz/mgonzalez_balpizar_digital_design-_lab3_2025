`timescale 1ns/1ps

module tb_seleccionar_parejas;

  logic clk, rst, start;
  logic Izq, Der, Sel;
  logic [4:0] arr_in [0:15];
  logic [4:0] arr_out [0:15];
  logic [1:0] cartas_seleccionadas;
  logic done;
  int num = 3'd0;

  seleccionar_parejas uut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .Izq(Izq),
    .Der(Der),
    .Sel(Sel),
    .arr_in(arr_in),
    .arr_out(arr_out),
    .cartas_seleccionadas(cartas_seleccionadas),
    .done(done)
  );

  // reloj 100 MHz
  always #5 clk = ~clk;

  // ----- Utilidades -----
  task print_arr(string tag);
    $display("\n--- %s ---", tag);
    for (int i = 0; i < 16; i++) $write("%b ", arr_out[i]);
    $display("\n");
  endtask

  task pulse_start;
    start = 1; @(posedge clk); start = 0; @(posedge clk);
  endtask

  task press_der;   Der = 1; @(posedge clk); Der = 0; @(posedge clk);   endtask
  task press_izq;   Izq = 1; @(posedge clk); Izq = 0; @(posedge clk);   endtask
  task press_sel;   Sel = 1; @(posedge clk); Sel = 0; @(posedge clk);   endtask

  initial begin
    clk = 0; rst = 0;
    start = 0; Izq = 0; Der = 0; Sel = 0;

    // Inicializar arr_in con valores secuenciales
    for (int i = 0; i <= 15; i += 2) begin
            arr_in[i][4:2]   = num[2:0];
            arr_in[i][1:0]   = 00;
            arr_in[i+1][4:2] = num[2:0];
            arr_in[i+1][1:0] = 00;
            num += 1;
        end
		  
	$display("Contenido de arr_in:");
    for (int i = 0; i < 16; i++) begin
      $write("%b ", arr_in[i]);
    end
    $display("\n");   


    $display("==== INICIO TB seleccionar_parejas (salida registrada) ====");

    // Reset activo-bajo
    @(posedge clk); rst = 1'b1;
    @(posedge clk); rst = 1'b0; // aplica reset
    @(posedge clk); rst = 1'b1; // libera reset

    // -------- RONDA 1 --------
    $display("\n[START ronda 1]");
    pulse_start();

    // Mover derecha 2 veces
    press_der();
    press_der();

    // Seleccionar en index actual
    press_sel();

    // -------- RONDA 2 (wrap) --------
    $display("\n[START ronda 2]");
    pulse_start();

    // Ir a la izquierda una vez (de 0 -> 15)
    press_izq();
    press_sel();

    $display("\n==== FIN TB ====");
    repeat (5) @(posedge clk);
    $stop;
  end

  // ----- Monitoreo y captura en el ciclo de done -----
  always @(posedge clk) begin
    $display("t=%0t | running=%b | index=%0d | done=%b | cartas_sel=%b",
             $time, uut.running, uut.index, done, cartas_seleccionadas);

    // Imprimir arr_out exactamente cuando done=1 (pulso de 1 ciclo)
    if (done) begin
      print_arr($sformatf("arr_out @ done (t=%0t, index=%0d)", $time, uut.index));
    end
  end

endmodule
