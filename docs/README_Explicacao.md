# Guia de Estudo: Entendendo a Implementação REDUX-V

Este documento foi criado para ajudar você a entender profundamente o código fornecido e ser capaz de explicá-lo com clareza para professores ou colegas. Ele é dividido em uma explicação da **Gramática do Verilog**, as **Estruturas de Código** das memórias, e a lógica engenhosa dos **Algoritmos Assembly**.

---

## 1. Gramática Básica do Verilog (O mínimo para entender o código)

O Verilog **não é uma linguagem de programação sequencial**, é uma Linguagem de Descrição de Hardware (HDL). A principal diferença é que no Verilog **tudo acontece ao mesmo tempo** físico (em paralelo).

*   **`module` e `endmodule`**: Cada arquivo nosso reflete um bloco (caixa) de hardware físico com pinos. Ele tem portas de entrada (`input`) e saída (`output`).
*   **`wire`**: É literalmente um "fio" de cobre. Ele não armazena energia ou sinal; ele apenas o conecta de uma ponta à outra. Ele reage instantaneamente sem relógio.
*   **`reg`**: Apesar do nome (*Register*), **não representa necessariamente um registrador flip-flop físico**. Um `reg` é uma variável do Verilog capaz de segurar (memorizar) um valor momentâneo dentro de blocos ativados por gatilhos.
*   **`always @(posedge clk)`**: Bloco Procedural **Síncrono**. Significa: *"Sempre que o sinal de clock pular de 0 para 1 (borda de subida ou positive-edge), dispare simultaneamente tudo que está aqui"*. Em hardware sequencial assim, usamos o operador `<=`.
*   **`always @(*)`**: Bloco Procedural **Combinacional** (sem relógio). O hardware reavalia seu valor na hora. Usamos o asterisco que descreve *"qualquer mudança instantânea que rolar em fios das entradas disparará de imediato"*. Usamos apenas `=`, operador de barramento sem barreiras de tempo.
*   **`[7:0]`**: Significa um barramento (*bus*) de dados. Nós avisamos para a placa: *"A partir de agora as portas de dados do nosso harwarde não possuem apenas 1 fio, e sim um chicote de 8 fios correndo energia em paralelo (1 Byte ou bits de 0 a 7)"*.

---

## 2. Por que as Memórias foram feitas desta forma? (A lógica do Design)

### A. Memória de Instruções (`memoria_instrucoes.v`)
*   **Por que a saída dela não usa Clock? (`always @(*)`)**
    Nos processadores monociclo (e de acordo com o Datapath do nosso relatório `main.tex`), a Etapa de Leitura de Instrução (*Fetch*) precisa enviar sua saída quase no tempo de "0" do instante em que a fresta do tempo abre, para dar fôlego ao processador (ULA / Controle / etc) rodar até o final da via do ciclo em que ela pertence. Logo a leitura é *Combinacional*. Puxou o `pc` na entrada -> `instrucao` voa na saída no mesmo momento de forma fluida e passiva.
*   **O que é esse `initial begin`?**
    Essa ROM simula uma "Memória Flash". Quando o processador é ligado na placa-mãe, como ele vai buscar código? O `initial begin` é nosso Gravador. Ele escreve apenas $1$ única vez injetando a força o programa (os blocos hexadecimais *Opcode*) preenchidos dentro da ROM *antes mesmo do relógio físico piscar pela primeira vez*.

### B. Contador de Programa (`contador_de_programa.v`)
*   **Por que Síncrono `posedge clk` diferente da Memória de Intsruções?**
    O Contador é um **Registrador físico de 8-bits!** Trata-se de um circuito barril (Sequencial). Essa classe contém uma "barreira fechada a cadeado" que só é aberta quando a mola solavanca (`posedge clk`). O PC precisa segurar firme a ponteira da instrução e só ceder avançando pro próximo degrau (`next_pc`) após receber a batidinha autorizada do Maestro (o Clock). Já o reset `if (rst)` prevê que por segurança o Hardware inteiro deve ter um botão de emergência universal limpando pra base estaca `00`.

### C. Memória de Dados (`memoria_dados.v`)
*   **Memórias mistas síncronas-assíncronas:** A arquitetura pede uma lógica *Harvard*. Essa MDU de arquitetura emula o design das L1-Cache: A Leitura (Load do operando via *M[R[rb]]*) desce pela corredeira em formato de fiação não-temporizada (o mesmo que a Mem de Insts usa `always @(*)`); Ao contrário, pregar valores estáticos no armazenamento RAM (O Store) seria brutal por picos de oscilação elétrica caso fossem reativas/assíncronas também, por isso amarramos o gatilho da RAM `if (we) ram[addr] <= data_in` à coleira do pulso rítmico do Clock!

---

## 3. Como Explicar os Algoritmos da Prova "Assembly"

### 1º Algoritmo (A Base de Repetição da Arquitetura)
O objetivo C clássico da prova é preencher dados sequencialmente rodando uma somatória (`c[i] = b + i`). Mas o Processador REDUX-V com seu minúsculo Imediato em um campo de OPCODE de 4-bits sofre um abalo lógico: Ele **chora e desaba ao tentar comportar valores Imediatos/Numéricos maiores que 7**. *Ex: Impossível mandar o comando AddI 42 pra criar um vetor no endereço "42" nativamente.*

**Como contornamos com inteligência em hardware? (A técnica do Shift-Add)**
Na inicialização resolvemos essa deficiência através de pura Matemática e Deslocamento (Multiplicativo de Bits). O nosso script simula o binário a seguir.
Se formos gerar um escalar $42$: Começa se lançando uma *raiz elementar de 5* pela instrução barata base que o Imediato alcança (`addi 5`). Após injetado no Banco local R0, rodamos um soma com ele próprio encadeado (`add R0, R0`). No campo lógico isso gera o dobro dinamicamente (`R0 = 5+5 = 10`... depois `20`... e então `40` exponencialmente multiplicativo e milagroso). Fechamos a sobra com mais um pingo (`addi 2`). Pimba, carregou-se o gigantismo do #42 ignorando falência técnica de blocos.

A Repetição na base inferior do laço jorrou glória valendo-se das customizações de Processador requisitadas em pauta:
*   `inc` e `dec` são nossas engrenagens pra iterar ponteiro e varrer o vetor rodando de Byte em Byte de graça a cada *Loop clock* com performance. Ele decresce a meta residual até a poeira baixar!

### 2º Algoritmo ("Memcpy" - A arte de copiar vetores)
Proposto e desenhado como a instrução suprema para Cópia Direta por Blocos (Move um bloco gigante do ponteiro inicial `0x20` copiado colando nos novos endereços de ponteiro alvo final `0x40`).

**Por que este modelo é requintado em Hardware REDUX?**
Nós reduzimos a lógica colossal a míseros de 6 comandos absolutos Assembly! A coreografia: O Hardware carrega dados do pulmão `R1` mandando respiro pro Operando temporário transito do `R3` no instante que logo depois a Unidade arremata a gravura do temporário pra RAM do pulmão alvo `R2` fechando o rito via LoaS+Store.
Enquanto o `dec R0` minguar o montante que sobrou da rotina à pagar (como número de caixas), usamos do belo desvio negativo enxuto `jnz -5` para saltar cegamente repuxando pro início local (loop condicional para se não enxgou a zerada).

*(**Sua carta na manga:** Se alguém ou o Professor perguntarem "Eeeii, por que saltou de trás '-5' posições se contando no código são 6 posições absolutas acima de distância para voltar ao início?", Responda enfático: "No ciclo de hardware, no momento da decisão da soma, o nosso Adder do Datapath já avançou precocemente na árvore temporal pra PC+1 no registrador. Portanto ele precisa compensar um passo por engrenagem mecânica do caminho!")*
