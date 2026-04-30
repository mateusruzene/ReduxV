`timescale 1ns / 1ps

module redux_v_TB;

    reg clk;

    // Instancia o processador completo
    redux_v cpu (
        .clk(clk)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Periodo do clock: 10ns
    end

    initial begin
        $monitor("Tempo=%0t | PC=%h | Inst=%h | Regs: R0=%h R1=%h R2=%h R3=%h | M[1]=%h",
                 $time, cpu.current_pc, cpu.instruction, 
                 cpu.regsys_inst.regs[0], cpu.regsys_inst.regs[1], 
                 cpu.regsys_inst.regs[2], cpu.regsys_inst.regs[3],
                 cpu.ram_inst.ram[1]);
    end

    // Parameter to specify which program to run
    // 0: Program 1 (Base Alg - offset 0x00)
    // 1: Program 2 (Memcpy - offset 0x20)
    // 2: Program 3 (Test all ops - offset 0x40)
    reg [1:0] program_selector = 2; // Default to Program 3 test

    initial begin
        $display("===================================================================");
        $display(" Iniciando Teste da Arquitetura REDUX-V Completa");
        $display(" Program Selector = %d", program_selector);
        $display("===================================================================");
        
        $dumpfile("redux_v.vcd");
        $dumpvars(0, redux_v_TB);

        // Force PC to start at the selected offset
        if (program_selector == 0) begin
            cpu.pc_inst.current_pc = 8'h00;
            $display("--- Carregando 1o Algoritmo Base ---");
            cpu.rom_inst.rom[8'h00] = 8'hD0; // sub R0, R0
            cpu.rom_inst.rom[8'h01] = 8'h45; // addi 5
            cpu.rom_inst.rom[8'h02] = 8'hC0; // add R0, R0
            cpu.rom_inst.rom[8'h03] = 8'hC0; // add R0, R0
            cpu.rom_inst.rom[8'h04] = 8'hC0; // add R0, R0
            cpu.rom_inst.rom[8'h05] = 8'h42; // addi 2
            cpu.rom_inst.rom[8'h06] = 8'hD5; // sub R1, R1
            cpu.rom_inst.rom[8'h07] = 8'hC4; // add R1, R0
            cpu.rom_inst.rom[8'h08] = 8'hD0; // sub R0, R0
            cpu.rom_inst.rom[8'h09] = 8'h45; // addi 5
            cpu.rom_inst.rom[8'h0A] = 8'hC0; // add R0, R0
            cpu.rom_inst.rom[8'h0B] = 8'hDA; // sub R2, R2
            cpu.rom_inst.rom[8'h0C] = 8'hC8; // add R2, R0
            cpu.rom_inst.rom[8'h0D] = 8'hD0; // sub R0, R0
            cpu.rom_inst.rom[8'h0E] = 8'h43; // addi 3
            cpu.rom_inst.rom[8'h0F] = 8'h36; // st R1, R2
            cpu.rom_inst.rom[8'h10] = 8'h55; // inc R1, R1
            cpu.rom_inst.rom[8'h11] = 8'h5A; // inc R2, R2
            cpu.rom_inst.rom[8'h12] = 8'h60; // dec R0, R0
            cpu.rom_inst.rom[8'h13] = 8'h7C; // jnz -4

        end else if (program_selector == 1) begin
            cpu.pc_inst.current_pc = 8'h20;
            $display("--- Carregando 2o Algoritmo Customizado (Memcpy) ---");
            cpu.rom_inst.rom[8'h00] = 8'h2D; // ld R3, R1
            cpu.rom_inst.rom[8'h01] = 8'h3E; // st R3, R2
            cpu.rom_inst.rom[8'h02] = 8'h55; // inc R1, R1
            cpu.rom_inst.rom[8'h03] = 8'h5A; // inc R2, R2
            cpu.rom_inst.rom[8'h04] = 8'h60; // dec R0, R0
            cpu.rom_inst.rom[8'h05] = 8'h7B; // jnz -5
            cpu.rom_inst.rom[8'h06] = 8'h10; // ji 0 (endless loop to stop execution)

        end else if (program_selector == 2) begin
            cpu.pc_inst.current_pc = 8'h40;
            $display("--- Carregando 3o Algoritmo: Teste de todas as instrucoes ---");
            cpu.rom_inst.rom[8'h00] = 8'h41; // addi 1
            cpu.rom_inst.rom[8'h01] = 8'h55; // inc R1, R1
            cpu.rom_inst.rom[8'h02] = 8'h65; // dec R1, R1
            cpu.rom_inst.rom[8'h03] = 8'h88; // not R2, R0
            cpu.rom_inst.rom[8'h04] = 8'h98; // and R2, R0
            cpu.rom_inst.rom[8'h05] = 8'hA8; // or R2, R0
            cpu.rom_inst.rom[8'h06] = 8'hB9; // xor R2, R1
            cpu.rom_inst.rom[8'h07] = 8'hC8; // add R2, R0
            cpu.rom_inst.rom[8'h08] = 8'hD8; // sub R2, R0
            cpu.rom_inst.rom[8'h09] = 8'hE8; // slr R2, R0
            cpu.rom_inst.rom[8'h0A] = 8'hF8; // srr R2, R0
            cpu.rom_inst.rom[8'h0B] = 8'h38; // st R2, R0
            cpu.rom_inst.rom[8'h0C] = 8'h2C; // ld R3, R0
            cpu.rom_inst.rom[8'h0D] = 8'h08; // brzr R2, R0
            cpu.rom_inst.rom[8'h0E] = 8'h71; // jnz 1
            cpu.rom_inst.rom[8'h0F] = 8'h10; // ji 0

        end

        // Run for a specific number of cycles depending on the program
        if (program_selector == 2) begin
            #300; // Time enough to test all sequential instructions
        end else begin
            #5000;
        end

        $display("===================================================================");
        $display(" Final do Teste. Executado %0t ns", $time);
        $display(" Memoria / Registradores no momento da interrupcao:");
        $display(" R0: %h, R1: %h, R2: %h, R3: %h", 
                 cpu.regsys_inst.regs[0], cpu.regsys_inst.regs[1], 
                 cpu.regsys_inst.regs[2], cpu.regsys_inst.regs[3]);
        $display(" PC Final: %h", cpu.current_pc);
        $display("===================================================================");

        $finish;
    end

    // Monitoramento para facilitar visualizacao
    /*
    always @(posedge clk) begin
        $display("Tempo=%0t | PC=%h | Inst=%h | Regs: R0=%h R1=%h R2=%h R3=%h | M[1]=%h",
                 $time, cpu.current_pc, cpu.instruction, 
                 cpu.regsys_inst.regs[0], cpu.regsys_inst.regs[1], 
                 cpu.regsys_inst.regs[2], cpu.regsys_inst.regs[3],
                 cpu.ram_inst.ram[1]);
    end
    */

endmodule
