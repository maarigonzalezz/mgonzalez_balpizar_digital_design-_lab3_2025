// Modulo encargado de generar las VSYNC y HSYNC necesarias para el controllador VGA

module vgaController #(parameter HACTIVE = 10'd640,   // Cantidad de píxeles horizontales activos (visible)
    HFP = 10'd16,       										// Front Porch horizontal 
    HSYN = 10'd96,      										// Duración del pulso de sincronización horizontal
    HBP = 10'd48,       										// Back Porch horizontal 
    HMAX = HACTIVE + HFP + HSYN + HBP, 					// Total de píxeles horizontales 
    VBP = 10'd33,       										// Back Porch vertical 
    VACTIVE = 10'd480,  										// Cantidad de líneas verticales activas (visibles)
    VFP = 10'd10,       										// Front Porch vertical
    VSYN = 10'd2,       										// Duración del pulso de sincronización vertical
    VMAX = VACTIVE + VFP + VSYN + VBP  					// Total de líneas verticales
)
(
    input logic vgaclk,          		// Señal de reloj de entrada para la VGA
    output logic hsync, vsync,   		// Señales de sincronización horizontal y vertical
    output logic sync_b, blank_b,		// Señales de sincronización y de área visible
    output logic [9:0] x, y      		// Coordenadas actuales de píxeles 
);

// Contadores para las posiciones horizontal (x) y vertical (y)
always @(posedge vgaclk) begin
    // Incrementa el contador horizontal x en cada ciclo de reloj
    if (x < HMAX) begin
        x <= x + 1;  // Si no ha llegado al max, incrementa el contador horizontal
    end else begin
        x <= 0;      // Si alcanza el max, reinicia el contador horizontal y pasa al siguiente píxel vertical
        if (y < VMAX) begin
            y <= y + 1;  // Si no ha llegado al max vertical, incrementa el contador vertical
        end else begin
            y <= 0;      // Si alcanzó el max vertical, reinicia el contador vertical
        end
    end
end

// Genera las señales de sincronización horizontal (hsync) y vertical (vsync)
// Active Low (invertidas con ~)
assign hsync = ~(x >= HACTIVE + HFP & x < HACTIVE + HFP + HSYN); 
assign vsync = ~(y >= VACTIVE + VFP & y < VACTIVE + VFP + VSYN); 

// La señal sync_b se activa con active VSYNC & HSYNC
assign sync_b = hsync & vsync;

// blank_b determina si estamos en la región visible (dentro de los píxeles activos)
// (x < HACTIVE y y < VACTIVE)
assign blank_b = (x < HACTIVE) & (y < VACTIVE);

endmodule
