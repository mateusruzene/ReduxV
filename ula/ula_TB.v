`timescale 1ns / 1ps

module ula_TB;

    reg [7:0] Ra;
    reg [7:0] Rb;
    reg [3:0] ulaOper;
    wire [7:0] Res;
    wire Zero;
    wire Carry;

    // Instantiate ULA (Top-Level Mux + Submodules)
    ula uut (
        .Ra(Ra),
        .Rb(Rb),
        .ulaOper(ulaOper),
        .Res(Res),
        .Zero(Zero),
        .Carry(Carry)
    );

    initial begin
        // Initialize Inputs
        Ra = 0;
        Rb = 0;
        ulaOper = 0;

        // Monitor outputs
        $monitor("Time=%0d | ulaOper=%b | Ra=%d Rb=%d | Res=%8b (hex:%h) Zero=%b Carry=%b", 
                 $time, ulaOper, Ra, Rb, Res, Res, Zero, Carry);

        // Test vectors
        #10;
        
        // ADD
        Ra = 8'd10; Rb = 8'd5; ulaOper = 4'b0000;
        #10;
        if (Res !== 8'd15 || Zero !== 1'b0 || Carry !== 1'b0) $display("ERROR: ADD failed");
        
        // ADD with Carry Overflow
        Ra = 8'd250; Rb = 8'd10; ulaOper = 4'b0000;
        #10; // 250+10 = 260 -> 8-bit: 4 (00000100), Carry: 1
        if (Res !== 8'd4 || Zero !== 1'b0 || Carry !== 1'b1) $display("ERROR: ADD Carry failed");

        // SUB
        Ra = 8'd20; Rb = 8'd20; ulaOper = 4'b0001; 
        #10;
        if (Res !== 8'd0 || Zero !== 1'b1) $display("ERROR: SUB failed (Zero flag issue)");
        
        Ra = 8'd50; Rb = 8'd15; ulaOper = 4'b0001;
        #10;
        if (Res !== 8'd35 || Zero !== 1'b0) $display("ERROR: SUB failed");

        // AND
        Ra = 8'b10101010; Rb = 8'b11110000; ulaOper = 4'b0010;
        #10;
        if (Res !== 8'b10100000) $display("ERROR: AND failed");

        // OR
        Ra = 8'b10101010; Rb = 8'b00001111; ulaOper = 4'b0011;
        #10;
        if (Res !== 8'b10101111) $display("ERROR: OR failed");

        // XOR
        Ra = 8'b11110000; Rb = 8'b10101010; ulaOper = 4'b0100;
        #10;
        if (Res !== 8'b01011010) $display("ERROR: XOR failed");

        // NOT (Ra=don't care, Rb is inverted)
        Ra = 8'd0; Rb = 8'b11110000; ulaOper = 4'b0101;
        #10;
        if (Res !== 8'b00001111) $display("ERROR: NOT failed");

        // Shift Left Register (SLR)
        Ra = 8'b00001111; Rb = 8'd2; ulaOper = 4'b0110;
        #10;
        if (Res !== 8'b00111100) $display("ERROR: SLR failed");

        // Shift Right Register (SRR)
        Ra = 8'b11110000; Rb = 8'd3; ulaOper = 4'b0111;
        #10;
        if (Res !== 8'b00011110) $display("ERROR: SRR failed");

        // Multiplier
        Ra = 8'd5; Rb = 8'd6; ulaOper = 4'b1000;
        #10;
        if (Res !== 8'd30 || Zero !== 1'b0) $display("ERROR: MUL failed");

        // Test Zero Flag independent
        Ra = 8'd0; Rb = 8'd0; ulaOper = 4'b0010; // 0 & 0
        #10;
        if (Zero !== 1'b1) $display("ERROR: ZERO flag failed on AND");

        $display("Todos os testes estruturais e de datapath rodaram com sucesso.");
        $finish;
    end

endmodule
