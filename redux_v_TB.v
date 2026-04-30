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
        end else if (program_selector == 1) begin
            cpu.pc_inst.current_pc = 8'h20;
        end else if (program_selector == 2) begin
            cpu.pc_inst.current_pc = 8'h40;
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
