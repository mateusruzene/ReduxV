module memoria_dados (
        input clk,
        input we,
        input [7:0] endereco,
        input [7:0] dado_escrita,
        output [7:0] dado_leitura
);

reg [7:0] ram [0:255];

always @ (posedge clk) begin
        if (we) begin
                ram[endereco] <= dado_escrita;
        end
end

assign dado_leitura = ram[endereco];

integer i;

initial begin
        //integer i;
        for (i=0; i<256; i=i+1)
                ram[i] = 8'h00;
end

endmodule