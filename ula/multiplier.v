module multiplier(
    input [7:0] Ra,
    input [7:0] Rb,
    output [7:0] Res
);
    assign Res = Ra * Rb;
endmodule
