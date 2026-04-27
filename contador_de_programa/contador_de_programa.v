module contador_de_programa (
    input clk,
    input rst,
    input [7:0] next_pc,
    output reg [7:0] current_pc
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_pc <= 8'd0;
        end else begin
            current_pc <= next_pc;
        end
    end

endmodule
