module control_unit (
    input [3:0] opcode,
    output reg increment,
    output reg branch,
    output reg invBranch,
    output reg memToReg,
    output reg ulaSrc,
    output reg regWrite,
    output reg memWrite,
    output reg destReg,
    output reg [3:0] ulaOper
);

    always @(*) begin
        // Valores default
        increment = 1'b0;
        branch = 1'b0;
        invBranch = 1'b0;
        memToReg = 1'b0;
        ulaSrc = 1'b0;
        regWrite = 1'b0;
        memWrite = 1'b0;
        destReg = 1'b0;
        ulaOper = 4'b0000;

        case (opcode)
            4'b0000: begin // brzr
                branch = 1'b1;
            end
            4'b0001: begin // ji
                branch = 1'b1;
            end
            4'b0010: begin // ld
                memToReg = 1'b1;
                regWrite = 1'b1;
            end
            4'b0011: begin // st
                memWrite = 1'b1;
            end
            4'b0100: begin // addi
                ulaSrc = 1'b1;
                regWrite = 1'b1;
                ulaOper = 4'b0000; // add
            end
            4'b0101: begin // inc
                increment = 1'b1;
                ulaSrc = 1'b1;
                regWrite = 1'b1;
                ulaOper = 4'b0000; // add
            end
            4'b0110: begin // dec
                increment = 1'b1;
                ulaSrc = 1'b1;
                regWrite = 1'b1;
                ulaOper = 4'b0001; // sub
            end
            4'b0111: begin // jnz
                branch = 1'b1;
                invBranch = 1'b1;
            end
            4'b1000: begin // not
                regWrite = 1'b1;
                ulaOper = 4'b0101; // not
            end
            4'b1001: begin // and
                regWrite = 1'b1;
                ulaOper = 4'b0010; // and
            end
            4'b1010: begin // or
                regWrite = 1'b1;
                ulaOper = 4'b0011; // or
            end
            4'b1011: begin // xor
                regWrite = 1'b1;
                ulaOper = 4'b0100; // xor
            end
            4'b1100: begin // add
                regWrite = 1'b1;
                ulaOper = 4'b0000; // add
            end
            4'b1101: begin // sub
                regWrite = 1'b1;
                ulaOper = 4'b0001; // sub
            end
            4'b1110: begin // slr
                regWrite = 1'b1;
                ulaOper = 4'b0110; // slr
            end
            4'b1111: begin // srr
                regWrite = 1'b1;
                ulaOper = 4'b0111; // srr
            end
            default: begin
                // Mantém os sinais zerados
            end
        endcase
    end

endmodule
