module detector_zero(
    input [7:0] Res,
    output Zero
);
    // Detector de Zero via NOR de 8 entradas (conforme spec)
    assign Zero = ~(Res[0] | Res[1] | Res[2] | Res[3] | Res[4] | Res[5] | Res[6] | Res[7]);
endmodule
