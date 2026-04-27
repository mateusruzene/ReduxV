module nextpc(
        // Dados/Enderecos Recebidos
        input [7:0] plus1,
        input [7:0] plusImm,
        input [7:0] rbValue,

        input zero,

        // Sinais de Controle
        input increment,
        input branch, //?
        input invBranch,

        output [7:0] out //Endereco final que PC usara
);

wire branchcondition;
assign branchcondition = invBranch ? ~zero : zero;

wire branchout;
assign branchout = branch & branchcondition;

wire [7:0] base;
assign base = increment ? plus1 : plusImm;

assign out = branchout ? rbValue : base;

endmodule
