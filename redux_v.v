module redux_v (
    input clk
);

    // ======================================
    // Fios de interconexão
    // ======================================
    
    wire [7:0] current_pc;
    wire [7:0] next_pc;
    wire [7:0] instruction;
    
    // Instruction decode
    wire [3:0] opcode = instruction[7:4];
    wire [1:0] inst_ra = instruction[3:2];
    wire [1:0] inst_rb = instruction[1:0];
    wire [3:0] imm = instruction[3:0];
    
    // Control signals
    wire ctrl_increment;
    wire ctrl_branch;
    wire ctrl_invBranch;
    wire ctrl_memToReg;
    wire ctrl_ulaSrc;
    wire ctrl_regWrite;
    wire ctrl_memWrite;
    wire ctrl_destReg;
    wire [3:0] ctrl_ulaOper;

    // Is Type I Instruction? (ji, addi, jnz)
    wire is_type_i = (opcode == 4'b0001 || opcode == 4'b0100 || opcode == 4'b0111);
    
    // Register Bank signals
    wire [1:0] addrRa = is_type_i ? 2'b00 : inst_ra;
    wire [1:0] addrW  = is_type_i ? 2'b00 : inst_ra;
    wire [1:0] addrRb = inst_rb;
    wire [7:0] outRa;
    wire [7:0] outRb;
    wire [7:0] writeData;
    
    // Immediate sign extension
    wire [7:0] imm_ext = { {4{imm[3]}}, imm };
    
    // ALU signals
    wire [7:0] aluResult;
    wire aluZero;
    wire aluCarry;
    
    wire [7:0] aluOperandB = ctrl_ulaSrc ? (ctrl_increment ? 8'd1 : imm_ext) : outRb;
    
    // Data Memory signals
    wire [7:0] memDataOut;
    
    // NextPC logic
    wire [7:0] plus1 = current_pc + 1;
    wire [7:0] plusImm = current_pc + imm_ext;
    wire [7:0] nextpc_rbValue_in = (opcode == 4'b0111) ? plusImm : outRb; // jnz uses plusImm
    wire nextpc_increment_in = (opcode != 4'b0001); // 0 for ji, 1 for others
    wire nextpc_zero_in = (outRa == 8'd0); // zero flag for branch
    
    // ======================================
    // Instanciações
    // ======================================

    contador_de_programa pc_inst (
        .clk(clk),
        .rst(1'b0),
        .next_pc(next_pc),
        .current_pc(current_pc)
    );

    nextpc npc_inst (
        .plus1(plus1),
        .plusImm(plusImm),
        .rbValue(nextpc_rbValue_in),
        .zero(nextpc_zero_in),
        .increment(nextpc_increment_in),
        .branch(ctrl_branch),
        .invBranch(ctrl_invBranch),
        .out(next_pc)
    );

    memoria_instrucoes rom_inst (
        .pc(current_pc),
        .instrucao(instruction)
    );

    control_unit ctrl_inst (
        .opcode(opcode),
        .increment(ctrl_increment),
        .branch(ctrl_branch),
        .invBranch(ctrl_invBranch),
        .memToReg(ctrl_memToReg),
        .ulaSrc(ctrl_ulaSrc),
        .regWrite(ctrl_regWrite),
        .memWrite(ctrl_memWrite),
        .destReg(ctrl_destReg),
        .ulaOper(ctrl_ulaOper)
    );

    banco_registradores regsys_inst (
        .clk(clk),
        .we(ctrl_regWrite),
        .addrRa(addrRa),
        .addrRb(addrRb),
        .addrW(addrW),
        .writeData(writeData),
        .outRa(outRa),
        .outRb(outRb)
    );

    ula alu_inst (
        .Ra(outRa),
        .Rb(aluOperandB),
        .ulaOper(ctrl_ulaOper),
        .Res(aluResult),
        .Zero(aluZero),
        .Carry(aluCarry)
    );

    memoria_dados ram_inst (
        .clk(clk),
        .we(ctrl_memWrite),
        .endereco(outRb),
        .dado_escrita(outRa),
        .dado_leitura(memDataOut)
    );

    // Write back multiplexer
    assign writeData = ctrl_memToReg ? memDataOut : aluResult;

endmodule
