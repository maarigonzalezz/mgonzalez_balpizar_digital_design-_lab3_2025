module vga(input logic clk, nxt,
			  input  logic rst,       // Reset asíncrono
			  output logic [6:0] seg, // Segmentos del display (a-g)
			  output logic vgaclk, // 25.175 MHz VGA clock
			  output logic hsync, vsync,
			  output logic sync_b, blank_b, // To monitor 
			  output logic [7:0] r, g, b);
			  
	logic [9:0] x, y;
	
	// Modulo para obtener 25MHz
	pll vgapll(.inclk0(clk), .c0(vgaclk));

	// Generador de señales para el monitor
	vgaController vgaCont(vgaclk, hsync, vsync, sync_b, blank_b, x, y);
	
	// Modulo para pintar la pantalla
	videoGen videoGen(x, y, r, g, b);
	
	//contador
	top_7seg_counter(.clk(clk), .rst(rst), .seg(seg));
	
endmodule
