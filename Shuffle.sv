module Shuffle (
    input  logic        clk,              // Reloj principal para la lógica secuencial
    input  logic        rst,              // Reset asíncrono para inicializar señales
    input  logic        start,            // Señal para iniciar el shuffle
    input  logic [7:0]  seed,            // Semilla pseudoaleatoria de 8 bits
    output logic [79:0] out_cards_flat,  // Baraja final de 16 cartas * 5 bits
    output logic        done              // Señal que indica que el shuffle terminó
);

    // ------------------------------------------------------
    // Variables internas
    // ------------------------------------------------------
    logic [2:0] pool_comb[0:15];  // Pool barajado temporal (combinacional)
    logic [79:0] result_comb;      // Resultado del shuffle (combinacional)
    logic running;                 // Indica si el shuffle está en progreso

    // ------------------------------------------------------
    // Parte combinacional: realiza Fisher-Yates para mezclar símbolos
    // ------------------------------------------------------
    always_comb begin
        logic [2:0] symbols_pool[0:15]; // Pool local de símbolos para el shuffle
        int i, j;                        // Índices de iteración
        logic [2:0] tmp;                 // Variable temporal para swap
        logic [7:0] rand_val;            // Valor pseudoaleatorio generado a partir de la semilla

        // Inicializar pool con cada símbolo del 000 al 111, repetido dos veces
        for (i=0; i<8; i=i+1) begin
            symbols_pool[2*i]   = i[2:0];   // Primera aparición del símbolo i
            symbols_pool[2*i+1] = i[2:0];   // Segunda aparición del símbolo i
        end

        rand_val = seed; // Inicializar LFSR pseudoaleatorio con la semilla de entrada

        // Algoritmo Fisher-Yates: mezcla combinacional de 16 símbolos
        for (i=15; i>0; i=i-1) begin
            // Generar nuevo valor pseudoaleatorio mediante LFSR tipo Galois
            rand_val = {rand_val[6:0], rand_val[7]^rand_val[5]^rand_val[4]^rand_val[3]};
            j = rand_val % (i+1);           // Índice de intercambio dentro del rango

            // Intercambiar símbolos en la posición i y j
            tmp = symbols_pool[i];
            symbols_pool[i] = symbols_pool[j];
            symbols_pool[j] = tmp;
        end

        // Construir resultado final combinacional con los bits de estado siempre 00
        for (i=0; i<16; i=i+1) begin
            result_comb[i*5 +:5] = {symbols_pool[i], 2'b00};
        end
    end

    // ------------------------------------------------------
    // Parte secuencial: captura resultado combinacional y controla 'done'
    // ------------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            out_cards_flat <= 0;  // Reiniciar salida
            done           <= 0;  // Reiniciar indicador de finalización
            running        <= 0;  // Shuffle no está en curso
        end else begin
            if (start && !running) begin
                running <= 1;     // Inicia el shuffle
                done    <= 0;     // Marca que aún no terminó
            end
            if (running) begin
                out_cards_flat <= result_comb; // Captura la baraja combinacional
                done           <= 1;           // Indica que el shuffle finalizó
                running        <= 0;           // Reset de estado de ejecución
            end
        end
    end

endmodule