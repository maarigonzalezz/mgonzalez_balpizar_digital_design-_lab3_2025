module vga(input logic clk, nxt,
			  input  logic rst,       // Reset asíncrono
			  output logic vgaclk, // 25.175 MHz VGA clock
			  output logic hsync, vsync,
			  output logic sync_b, blank_b, // To monitor 
			  output logic [7:0] r, g, b,			  
           output logic [6:0] seg);
			  
	logic [9:0] x, y;
	
	// Modulo para obtener 25MHz
	pll vgapll(.inclk0(clk), .c0(vgaclk));

	// Generador de señales para el monitor
	vgaController vgaCont(vgaclk, hsync, vsync, sync_b, blank_b, x, y);
	
	// Modulo para pintar la pantalla
	videoGen videoGen(x, y, r, g, b);
	
	//Contador
	top_7seg_counter(.clk(clk), .rst(rst), .seg(seg));
	
	
endmodule
