`timescale 1ns/1ps

module contador_de_programa_TB;

    reg clk;
    reg rst;
    reg [7:0] next_pc;
    wire [7:0] current_pc;

    contador_de_programa uut (
        .clk(clk),
        .rst(rst),
        .next_pc(next_pc),
        .current_pc(current_pc)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        next_pc = 8'd0;
        #10;
        rst = 0;
        
        next_pc = 8'd5;
        #10;
        
        next_pc = 8'd10;
        #10;

        next_pc = 8'd12;
        #10;
        
        $finish;
    end

    initial begin
        $monitor("Time=%0t | rst=%b | next_pc=0x%h | current_pc=0x%h", $time, rst, next_pc, current_pc);
    end

endmodule
