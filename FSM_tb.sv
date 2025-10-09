module FSM_tb;

    // Señales de entrada
    logic        rst, clk;
    logic [1:0]  cartas_seleccionadas;
    logic        tiempo_terminado;
    logic        inicio;
    logic        se_eligio_carta;
    logic        cartas_mostradas;
    logic        cartas_ocultas;
    logic        cartas_revueltas;
    
    // Señales de salida
    logic [1:0]  ganador;
    logic [3:0]  state;
    
    // Instancia del módulo FSM
    FSM dut (
        .rst(rst),
        .clk(clk),
        .cartas_seleccionadas(cartas_seleccionadas),
        .tiempo_terminado(tiempo_terminado),
        .inicio(inicio),
        .se_eligio_carta(se_eligio_carta),
        .cartas_mostradas(cartas_mostradas),
        .cartas_ocultas(cartas_ocultas),
        .cartas_revueltas(cartas_revueltas),
        .ganador(ganador),
        .state(state)
    );
    
    // Generación de reloj
    always #5 clk = ~clk;
    
    // Tareas para verificar estados
    task check_state;
        input [3:0] expected_state;
        input string state_name;
        begin
            if (state !== expected_state) begin
                $display("ERROR: En tiempo %0t, estado esperado %s (%b), pero se obtuvo %b", 
                         $time, state_name, expected_state, state);
                $finish;
            end else begin
                $display("OK: En tiempo %0t, estado %s (%b)", $time, state_name, state);
            end
        end
    endtask
    
    task check_ganador;
        input [1:0] expected_ganador;
        input string ganador_name;
        begin
            if (ganador !== expected_ganador) begin
                $display("ERROR: En tiempo %0t, ganador esperado %s (%b), pero se obtuvo %b", 
                         $time, ganador_name, expected_ganador, ganador);
                $finish;
            end else begin
                $display("OK: En tiempo %0t, ganador %s (%b)", $time, ganador_name, ganador);
            end
        end
    endtask
    
    // Test sequence
    initial begin
        // Inicializar señales
        clk = 0;
        rst = 1;
        inicio = 0;
        cartas_mostradas = 0;
        cartas_ocultas = 0;
        cartas_revueltas = 0;
        se_eligio_carta = 0;
        tiempo_terminado = 0;
        cartas_seleccionadas = 2'b00;
        
        $display("=== INICIANDO TESTBENCH ===");
        
        // Test 1: Reset
        $display("\n--- Test 1: Reset ---");
        #10;
        rst = 0;
        #10;
        check_state(4'b0000, "INICIO");
        check_ganador(2'b00, "NINGUNO");
        
        // Test 2: Secuencia inicial
        $display("\n--- Test 2: Secuencia inicial ---");
        inicio = 1;
        #10;
        check_state(4'b0001, "MUESTRO_CORTAS");
        
        cartas_mostradas = 1;
        #10;
        check_state(4'b0010, "OCULTA_CORTAS");
        
        cartas_ocultas = 1;
        #10;
        check_state(4'b0011, "REVUELVE_CORTAS");
        
        cartas_revueltas = 1;
        #10;
        check_state(4'b0100, "INICIO_JUEGO");
        #10;
        check_state(4'b0101, "TURNO_JUGADOR");
        
        // Test 3: Selección de cartas (sin pareja)
        $display("\n--- Test 3: Selección de cartas sin pareja ---");
        inicio = 0;
        cartas_mostradas = 0;
        cartas_ocultas = 0;
        cartas_revueltas = 0;
        
        // Primera carta
        se_eligio_carta = 1;
        cartas_seleccionadas = 2'b01; // Carta 1
        #10;
        check_state(4'b0110, "UNA_CARTA");
        
        // Segunda carta (diferente)
        cartas_seleccionadas = 2'b10; // Carta 2 (diferente)
        #10;
        check_state(4'b0111, "DOS_CARTAS");
        
        // Debería volver a TURNO_JUGADOR (sin pareja)
        se_eligio_carta = 0;
        #10;
        check_state(4'b0101, "TURNO_JUGADOR");
        
        // Test 4: Selección de cartas (con pareja)
        $display("\n--- Test 4: Selección de cartas con pareja ---");
        // Primera carta
        se_eligio_carta = 1;
        cartas_seleccionadas = 2'b01; // Carta 1
        #10;
        check_state(4'b0110, "UNA_CARTA");
        
        // Segunda carta (igual - pareja)
        cartas_seleccionadas = 2'b01; // Carta 1 (misma)
        #10;
        check_state(4'b0111, "DOS_CARTAS");
        
        // Debería volver a TURNO_JUGADOR (con pareja)
        se_eligio_carta = 0;
        #10;
        check_state(4'b0101, "TURNO_JUGADOR");
        
        // Test 5: Tiempo terminado
        $display("\n--- Test 5: Tiempo terminado ---");
        tiempo_terminado = 1;
        #10;
        check_state(4'b1000, "MOSTRAR_RANDOM");
        
        tiempo_terminado = 0;
        #10;
        check_state(4'b0101, "TURNO_JUGADOR");
        
        // Test 6: Simular juego completo hasta conclusión
        $display("\n--- Test 6: Simular juego completo ---");
        
        // Forzar que se encuentren todas las parejas
        // (En una implementación real, esto dependería del estado interno)
        // Simulamos múltiples parejas hasta llegar a 8 puntos totales
        
        repeat(8) begin
            // Seleccionar pareja
            se_eligio_carta = 1;
            cartas_seleccionadas = 2'b01;
            #10; // UNA_CARTA
            cartas_seleccionadas = 2'b01; 
            #10; // DOS_CARTAS
            se_eligio_carta = 0;
            #10; // TURNO_JUGADOR
        end
        
        // Verificar que vamos a NO_MAS_PAREJAS después de la última pareja
        check_state(4'b1001, "NO_MAS_PAREJAS");
        #10;
        check_state(4'b1010, "CONCLUSION");
        
        // Test 7: Volver al inicio
        $display("\n--- Test 7: Volver al inicio ---");
        inicio = 1;
        #10;
        check_state(4'b0000, "INICIO");
        
        $display("\n=== TODOS LOS TESTS PASARON EXITOSAMENTE ===");
        $finish;
    end
    
    // Monitoreo de cambios de estado
    always @(state) begin
        $display("Cambio de estado: %b en tiempo %0t", state, $time);
    end
    
    // Monitoreo de cambios en ganador
    always @(ganador) begin
        $display("Cambio en ganador: %b en tiempo %0t", ganador, $time);
    end

endmodule