module banco_registradores (
    input clk,
    input we,
    input [1:0] addrRa,
    input [1:0] addrRb,
    input [1:0] addrW,
    input [7:0] writeData,
    output [7:0] outRa,
    output [7:0] outRb
);

    reg [7:0] regs [0:3];
    integer i;

    initial begin
        for (i = 0; i < 4; i = i + 1) begin
            regs[i] = 8'd0;
        end
    end

    always @(posedge clk) begin
        if (we) begin
            regs[addrW] <= writeData;
        end
    end

    // Read asynchronously (combinational read)
    assign outRa = regs[addrRa];
    assign outRb = regs[addrRb];

endmodule
