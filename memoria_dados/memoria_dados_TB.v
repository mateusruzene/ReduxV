`timescale 1ns / 1ps

module memoria_dados_TB;
        reg clk;
        reg we;
        reg [7:0] endereco;
        reg [7:0] dado_escrita;
        wire [7:0] dado_leitura;

        memoria_dados uut (
                .clk(clk),
                .we(we),
                .endereco(endereco),
                .dado_escrita(dado_escrita),
                .dado_leitura(dado_leitura)
        );

        always #5 clk = ~clk;

        initial begin
                clk = 0;
                we = 0;
                endereco = 0;
                dado_escrita = 0;

                $display("Tempo: %0t | WE: %b | Addr: %h | Escrita: %h | Leitura: %h", $time, we, endereco, dado_escrita, dado_leitura);

                #10;
                we=1; endereco = 8'h10; dado_escrita = 8'hAA;
                $display("Tempo: %0t | WE: %b | Addr: %h | Escrita: %h | Leitura: %h", $time, we, endereco, dado_escrita, dado_leitura);
                #10;

                we=1; endereco = 8'h20; dado_escrita = 8'h55;
                $display("Tempo: %0t | WE: %b | Addr: %h | Escrita: %h | Leitura: %h", $time, we, endereco, dado_escrita, dado_leitura);
                #10;

                we=0; endereco = 8'h10;
                $display("Tempo: %0t | WE: %b | Addr: %h | Escrita: %h | Leitura: %h", $time, we, endereco, dado_escrita, dado_leitura);
                #10;
                if (dado_leitura == 8'hAA) begin
                        $display("Endereco 0x10 leu 0xAA");
                end
                else begin
                        $display("Endereco 0x10 falhou");
                end

                #20;
                $display("Fim do teste");
                $finish;
        end
endmodule