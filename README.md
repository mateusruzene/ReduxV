# Processador REDUX-V (Arquitetura Mono-ciclo)

Este projeto implementa o Datapath completo de um processador mono-ciclo baseado na arquitetura **REDUX-V**. O projeto engloba o design modular de todos os componentes de hardware, a criação de instruções customizadas para otimização de loops e a elaboração de algoritmos em Assembly nativo para validação da arquitetura.

## 🏗️ Estrutura e Partes do Projeto

O processador foi desenhado de forma modular, com cada componente possuindo responsabilidades bem definidas:

*   **`redux_v.v` (Top-Level Módulo):** O núcleo central que orquestra e conecta todo o Hardware (Datapath). Ele roteia os barramentos de fios de acordo com os sinais gerados pela Unidade de Controle e implementa os multiplexadores (MUX) e extensões de sinal (*Sign Extensions*) necessários para as operações.
*   **`control_unit` (Unidade de Controle):** O "cérebro" do processador. Decodifica o *Opcode* (os 4 bits iniciais da instrução) e gera as dezenas de sinais de controle vitais que ligam ou desligam caminhos de dados (ex: habilitação de escrita em memória, seleção de operação da ULA, controle de desvios).
*   **`ula` (Unidade Lógica e Aritmética):** Responsável por executar todas as operações matemáticas (soma, subtração, multiplicação) e lógicas (AND, OR, XOR, NOT, Shifts). Dividida em submódulos específicos para cada operação e orquestrada por um módulo principal (`ula.v`).
*   **`banco_registradores`:** A matriz física contendo os 4 registradores de trabalho de 8-bits (`R0` a `R3`).
*   **`contador_de_programa` (PC):** Um registrador síncrono que armazena o endereço da instrução atual em execução e coordena o avanço para a próxima, seja sequencialmente ou via saltos (branches). O módulo auxiliar `next_pc` calcula o próximo valor do PC.
*   **`memoria_instrucoes` (ROM):** Memória combinacional (sem clock na leitura) que atua como uma "Memória Flash". Ela armazena os algoritmos de teste (código Assembly compilado) carregados via blocos hexadecimais na inicialização.
*   **`memoria_dados` (RAM):** Memória de arquitetura híbrida (síncrona para escrita, assíncrona/combinacional para leitura). Armazena as variáveis e dados gerados durante a execução do programa.

---

## 🌟 As 3 Novas Instruções (`inc`, `dec` e `jnz`)

Para otimizar o processador e suportar a execução de laços de repetição (loops) e cópias de blocos de memória com alta performance, foram propostas e implementadas 3 novas instruções no ISA original:

1.  **`inc` (Incremento):** Soma 1 diretamente ao valor de um registrador (`Rx = Rx + 1`). Escolhida para iterar ponteiros de memória e avançar índices de vetores de forma extremamente rápida, dispensando a necessidade de gastar um registrador extra ou uma instrução maior de soma imediata.
2.  **`dec` (Decremento):** Subtrai 1 de um registrador (`Rx = Rx - 1`). Ideal para controlar laços de repetição (como contar o número de bytes restantes a serem processados até chegar a zero), permitindo uma verificação simples e nativa por parte da ULA.
3.  **`jnz` (Jump if Not Zero):** Desvio condicional. Salta para um endereço especificado *se* o registrador avaliado não for zero. Perfeita para fechar loops (ex: se o contador do `dec` ainda não esgotou, salta de volta para o topo do laço). Essa instrução economiza acessos à memória de dados, permitindo loops autossuficientes apenas com registradores.

Essas 3 instruções em conjunto permitiram criar estruturas de laço de repetição muito mais curtas e limpas, reduzindo o uso da memória de código e ciclos de hardware.

---

## 💻 Algoritmos Implementados

Três programas foram convertidos para a linguagem de máquina (Assembly REDUX-V) e injetados estaticamente na Memória de Instruções (no arquivo `memoria_instrucoes.v`):

### 1º Algoritmo: Laço Base de Repetição (`c[i] = b + i`)
Localizado no início da memória de instruções. Este algoritmo simula o preenchimento de um vetor iterativo utilizando repetição.
*   **Lógica Inteligente (Shift-Add):** Como a arquitetura só permite números imediatos pequenos (até 7 bits via instrução `addi`), o algoritmo contorna essa limitação usando somas sucessivas de um registrador por ele mesmo (`add R0, R0`), dobrando o valor (simulando um deslocamento binário) para formar constantes e endereços maiores, como 10 e 42, sem extrapolar o processador.
*   **Uso das Novas Instruções:** Faz uso intenso do `inc` para avançar o ponteiro de gravação dos dados e do conjunto `dec` + `jnz` para controlar o fim do ciclo repetitivo.

### 2º Algoritmo: Cópia de Memória de Bloco (*Memcpy*)
Inicia no endereço `0x20`. Move 10 bytes de dados armazenados a partir da posição "20" da memória RAM para a nova região no endereço "40".
*   **Funcionamento:** Ele carrega uma palavra temporariamente (`ld`), a guarda no novo destino (`st`), avança ambos os ponteiros (fonte e destino) com o `inc`, subtrai a quantidade de itens a copiar com `dec` e salta de volta ao topo do laço usando `jnz` caso a cópia não tenha terminado.
*   **Eficiência:** Graças às 3 novas instruções escolhidas, a cópia complexa de um bloco contínuo de memória inteira foi reduzida drasticamente para um loop contendo apenas **6 instruções** em Assembly.

### 3º Algoritmo: Teste Estendido de Cobertura 100%
Localizado no endereço `0x40`. Uma rotina algorítmica dedicada exclusivamente a estressar o Hardware e provar que toda a extensão de controle da ULA e do Datapath operam sem engasgos.
*   Ele submete ativamente **todas as 16 instruções** suportadas pela placa a testes lógicos, aritméticos e manipulações de RAM e PC em uma tacada contínua. 
*   O teste é concluído ancorando o Controlador do PC em um laço infinito intencional (`ji 0`), marcando o fim ordenado da simulação e congelando a geração de onda para debug.

---

## 🛠️ Como Executar com Icarus Verilog

O ambiente do processador foi otimizado para simulação de bancada usando `iverilog` e visualização física das ondas lógicas pelo `GTKWave`. Para rodar e testar o Datapath central, utilize os comandos de terminal na pasta raiz:

### Passo 1: Compilação Completa 
Para compilar toda a malha de código fonte do hardware (ignorando propositalmente arquivos de teste unitário soltos que podem fechar a simulação prematuramente):
```bash
iverilog -o redux_testador.vvp redux_v_TB.v redux_v.v banco_registradores/banco_registradores.v contador_de_programa/contador_de_programa.v control_unit/control_unit.v memoria_dados/memoria_dados.v memoria_instrucoes/memoria_instrucoes.v next_pc/nextpc.v ula/adder_subtractor.v ula/detector_zero.v ula/multiplier.v ula/ula.v ula/unidade_deslocamento.v ula/unidade_logica.v
```

### Passo 2: Execução / Emulação do Laboratório
Lance a execução do processador compilado `.vvp`. A saída preencherá dezenas de `Tempo / Regs` no seu console atestando as mudanças sistêmicas ciclo a ciclo:
```bash
vvp redux_testador.vvp
```

### Passo 3: Visualização das Ondas no GTKWave
Após o processador executar os algoritmos, será gerado automaticamente o arquivo de simulação visual `redux_v.vcd`. Em seguida, abra-o no GTKWave para auditar cada fio de bits e checar os caminhos de dados abertos no Multiplexador:
```bash
gtkwave redux_v.vcd
```

*(**Dica de Validação:** Quando instanciar a simulação, você pode testar isoladamente os antigos 1º Algoritmo e o Algoritmo Memcpy alterando unicamente a variável configurável `program_selector` de `2` (Teste Extendido) para `0` (Base) ou `1` (Memcpy) dentro do topo do arquivo `redux_v_TB.v`.)*
