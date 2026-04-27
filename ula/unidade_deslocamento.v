module unidade_deslocamento(
    input [7:0] Ra,
    input [7:0] Rb,
    output [7:0] res_slr,
    output [7:0] res_srr
);
    assign res_slr = Ra << Rb;
    assign res_srr = Ra >> Rb;
endmodule
