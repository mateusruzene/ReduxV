module memoria_instrucoes (
    input [7:0] pc,
    output reg [7:0] instrucao
);

    reg [7:0] rom [0:255]; // 256 bytes de memoria de instrucoes (max para PC de 8-bits)

    integer i;
    initial begin
        // Inicializa a memória com zero
        for (i = 0; i < 256; i = i + 1) begin
            rom[i] = 8'h00;
        end

        /*
        // 1º Algoritmo Base
        rom[8'h00] = 8'hD0; // sub R0, R0
        rom[8'h01] = 8'h45; // addi 5
        rom[8'h02] = 8'hC0; // add R0, R0
        rom[8'h03] = 8'hC0; // add R0, R0
        rom[8'h04] = 8'hC0; // add R0, R0
        rom[8'h05] = 8'h42; // addi 2
        rom[8'h06] = 8'hD5; // sub R1, R1
        rom[8'h07] = 8'hC4; // add R1, R0
        rom[8'h08] = 8'hD0; // sub R0, R0
        rom[8'h09] = 8'h45; // addi 5
        rom[8'h0A] = 8'hC0; // add R0, R0
        rom[8'h0B] = 8'hDA; // sub R2, R2
        rom[8'h0C] = 8'hC8; // add R2, R0
        rom[8'h0D] = 8'hD0; // sub R0, R0
        rom[8'h0E] = 8'h43; // addi 3
        rom[8'h0F] = 8'h36; // st R1, R2
        rom[8'h10] = 8'h55; // inc R1, R1
        rom[8'h11] = 8'h5A; // inc R2, R2
        rom[8'h12] = 8'h60; // dec R0, R0
        rom[8'h13] = 8'h7C; // jnz -4

        // 2º Algoritmo Customizado (Memcpy)
        rom[8'h20] = 8'h2D; // ld R3, R1
        rom[8'h21] = 8'h3E; // st R3, R2
        rom[8'h22] = 8'h55; // inc R1, R1
        rom[8'h23] = 8'h5A; // inc R2, R2
        rom[8'h24] = 8'h60; // dec R0, R0
        rom[8'h25] = 8'h7B; // jnz -5
        rom[8'h26] = 8'h10; // ji 0 (endless loop to stop execution)
        
        // 3º Algoritmo: Teste de todas as instruções
        rom[8'h40] = 8'h41; // addi 1      (R0 = 1)
        rom[8'h41] = 8'h55; // inc R1, R1  (R1 = R1+1 = 1)
        rom[8'h42] = 8'h65; // dec R1, R1  (R1 = R1-1 = 0)
        rom[8'h43] = 8'h88; // not R2, R0  (R2 = ~1 = 254)
        rom[8'h44] = 8'h98; // and R2, R0  (R2 = 254 & 1 = 0)
        rom[8'h45] = 8'hA8; // or R2, R0   (R2 = 0 | 1 = 1)
        rom[8'h46] = 8'hB9; // xor R2, R1  (R2 = 1 ^ 0 = 1)
        rom[8'h47] = 8'hC8; // add R2, R0  (R2 = 1 + 1 = 2)
        rom[8'h48] = 8'hD8; // sub R2, R0  (R2 = 2 - 1 = 1)
        rom[8'h49] = 8'hE8; // slr R2, R0  (R2 = 1 << 1 = 2)
        rom[8'h4A] = 8'hF8; // srr R2, R0  (R2 = 2 >> 1 = 1)
        rom[8'h4B] = 8'h38; // st R2, R0   (M[1] = 1)
        rom[8'h4C] = 8'h2C; // ld R3, R0   (R3 = M[1] = 1)
        rom[8'h4D] = 8'h08; // brzr R2, R0 (if R2==0, jump. But R2=1, NO jump).
        rom[8'h4E] = 8'h71; // jnz 1       (if R0!=0, jump +1 to 0x4F. R0=1, JUMPS).
        rom[8'h4F] = 8'h10; // ji 0        (PC = PC + 0, loop infinito)
        */
    end

    always @(*) begin
        instrucao = rom[pc];
    end

endmodule
