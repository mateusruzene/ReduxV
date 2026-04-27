module unidade_logica(
    input [7:0] Ra,
    input [7:0] Rb,
    output [7:0] res_and,
    output [7:0] res_or,
    output [7:0] res_xor,
    output [7:0] res_not
);
    assign res_and = Ra & Rb;
    assign res_or  = Ra | Rb;
    assign res_xor = Ra ^ Rb;
    assign res_not = ~Rb; // Redux-V not operation uses Rb
endmodule
