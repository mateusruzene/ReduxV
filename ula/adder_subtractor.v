module adder_subtractor(
    input [7:0] Ra,
    input [7:0] Rb,
    input sub,
    output [7:0] Res,
    output Carry
);
    wire [8:0] temp_res;
    // Operação 9-bits para capturar o Carry
    assign temp_res = sub ? (Ra - Rb) : (Ra + Rb);
    assign Res = temp_res[7:0];
    assign Carry = temp_res[8];
endmodule
