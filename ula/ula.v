module ula (
    input [7:0] Ra,
    input [7:0] Rb,
    input [3:0] ulaOper,
    output reg [7:0] Res,
    output Zero,
    output Carry
);
    // Fios de interligação (Mux inputs)
    wire [7:0] w_and, w_or, w_xor, w_not;
    wire [7:0] w_addsub;
    wire [7:0] w_shift_slr, w_shift_srr;
    wire [7:0] w_mul;
    
    // Sinal unário derivado para o Adder/Subtractor (0 = add, 1 = sub)
    // 4'b0000 é add, 4'b0001 é sub. Portanto, o bit 0 de ulaOper serve diretamente se for uma operação aritmética.
    wire op_sub = (ulaOper == 4'b0001) ? 1'b1 : 1'b0;

    // Instanciação 1: Unidade Lógica
    unidade_logica logica (
        .Ra(Ra),
        .Rb(Rb),
        .res_and(w_and),
        .res_or(w_or),
        .res_xor(w_xor),
        .res_not(w_not)
    );

    // Instanciação 2: Adder / Subtractor
    adder_subtractor aritmetica (
        .Ra(Ra),
        .Rb(Rb),
        .sub(op_sub),
        .Res(w_addsub),
        .Carry(Carry)
    );

    // Instanciação 3: Multiplier
    multiplier multiplicador (
        .Ra(Ra),
        .Rb(Rb),
        .Res(w_mul)
    );

    // Instanciação 4: Unidade de Deslocamento
    unidade_deslocamento shift (
        .Ra(Ra),
        .Rb(Rb),
        .res_slr(w_shift_slr),
        .res_srr(w_shift_srr)
    );

    // MULTIPLEXADOR PRINCIPAL (Mux controlado por ulaOper)
    always @(*) begin
        case (ulaOper)
            4'b0000: Res = w_addsub;      // Add
            4'b0001: Res = w_addsub;      // Sub
            4'b0010: Res = w_and;         // And
            4'b0011: Res = w_or;          // Or
            4'b0100: Res = w_xor;         // Xor
            4'b0101: Res = w_not;         // Not (inverte Rb)
            4'b0110: Res = w_shift_slr;   // Shift Left
            4'b0111: Res = w_shift_srr;   // Shift Right
            4'b1000: Res = w_mul;         // Multiplier
            default: Res = 8'b0;
        endcase
    end

    // Instanciação 5: Detector de Zero
    // Ligado diretamente no barramento "Res" da saída do MUX, conforme diagrama
    detector_zero zero_det (
        .Res(Res),
        .Zero(Zero)
    );

endmodule
