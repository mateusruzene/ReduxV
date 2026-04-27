`timescale 1ns/1ps

module memoria_instrucoes_TB;

    reg [7:0] pc;
    wire [7:0] instrucao;

    memoria_instrucoes uut (
        .pc(pc),
        .instrucao(instrucao)
    );

    initial begin
        $dumpfile("memoria_instrucoes.vcd");
        $dumpvars(0, memoria_instrucoes_TB);
        
        // Testa Algoritmo Base
        $display("--- Testando 1o Algoritmo Base ---");
        for (pc = 8'h00; pc <= 8'h13; pc = pc + 1) begin
            #10;
            $display("PC: 0x%h | Instrucao: 0x%h", pc, instrucao);
        end
        
        #20;
        
        // Testa Algoritmo Customizado (Memcpy)
        $display("--- Testando 2o Algoritmo Customizado ---");
        for (pc = 8'h20; pc <= 8'h25; pc = pc + 1) begin
            #10;
            $display("PC: 0x%h | Instrucao: 0x%h", pc, instrucao);
        end

        $finish;
    end

endmodule
