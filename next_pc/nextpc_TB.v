`timescale 1ns / 1ps

module nextpc_TB;
reg [7:0] plus1;
reg [7:0] plusImm;
reg [7:0] rbValue;
reg increment, branch, invBranch, zero;
wire [7:0] out;

nextpc uut (
        .plus1(plus1),
        .plusImm(plusImm),
        .rbValue(rbValue),
        .increment(increment),
        .branch(branch),
        .invBranch(invBranch),
        .zero(zero),
        .out(out)
);



initial begin
        $display("Tempo Inicial: %0t | Inc: %b | TakeBranch: %b | Saida PC: %h", $time, increment, branch, out);

        plus1 = 8'h01;
        plusImm = 8'h10;
        rbValue = 8'hFF;

        increment = 1; branch = 0; invBranch = 0; zero = 0;
        $display("Tempo: %0t | Inc: %b | TakeBranch: %b | Saida PC: %h", $time, increment, branch, out);
        #10;
        $display("Normal: Esperado 01, obtido %h", out);


        increment = 0; branch = 0; invBranch = 0; zero = 0;
        $display("Tempo: %0t | Inc: %b | TakeBranch: %b | Saida PC: %h", $time, increment, branch, out);
        #10;
        $display("ji (Imm): Esperado 10, obtido %h", out);


        increment = 1; branch = 1; invBranch = 0; zero = 1;
        $display("Tempo: %0t | Inc: %b | TakeBranch: %b | Saida PC: %h", $time, increment, branch, out);
        #10;
        $display("brzr (Beq): Esperado FF, obtido %h", out);


        increment = 1; branch = 1; invBranch = 1; zero = 0;
        $display("Tempo: %0t | Inc: %b | TakeBranch: %b | Saida PC: %h", $time, increment, branch, out);
        #10;
        $display("jnz (Bneq): Esperado FF, obtido %h", out);


        $finish;
end

endmodule
