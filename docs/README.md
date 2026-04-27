# Arquitetura REDUX-V - Memórias e Testes

Este diretório contém a implementação em Verilog dos módulos de **Memória de Dados**, **Memória de Instruções** e **Contador de Programa (PC)** do processador REDUX-V, concebidos para validar as etapas de design da arquitetura mono-ciclo.

## Algoritmos Implementados na Memória de Instruções

Para validar o funcionamento da `memoria_instrucoes.v`, foram fixados estaticamente dois programas compilados manualmente (através do código binário listado no arquivo \`main.tex\`):

### 1. Algoritmo Base
Este algoritmo executa um *loop* elementar implementando a lógica C sequencial `c[i] = b + i`. 
Ele itera 3 vezes para preencher posições de memória a partir do array baseado no ponteiro armazenado em Rados. 
*   **Técnica Destaque:** Usa a técnica de *shift-add* para gerar constantes numéricas grandes (como 42 e 10).
*   **Novas Instruções Utilizadas:** Faz uso intenso de `inc` (avançar valores iteradores/ponteiros), `dec` (para decrescer o contador do laço) e `jnz` para pular para o topo do loop sem consumir variáveis na memória principal. 

### 2. Algoritmo Customizado (Memcpy)
Este é um algoritmo dedicado a "Cópia de Memória de Bloco". Move rápida e ininterruptamente 10 bytes armazenados começando na posição da memória "20"  para o bloco em "40".
*   **Funcionamento:** Carrega a palavra (Load) no endereço em R1 temporariamnente para R3, grava (Store) a mesma palavra guardada no destino em R2. Avança ambos os ponteiros (`inc`) sequencialmente e deduz iterativamente o tamanho do bloco iterador até exaurir suas rotas repetitivas com o desvio (`jnz`).
*   **Eficiência:** Todo o laço foi reduzido drasticamente para 6 míseras instruções em Assembly devido às novas elaborações da Parte 1.


---

## Como rodar simulações usando Icarus Verilog (iverilog)

O Icarus Verilog (`iverilog`) é nosso compilador para transformar os designs em Verilog e Testbenches associados para arquivos de simulação (VVP). A engrenagem virtual (`vvp`) em seguida roda esses objetos para verificar as asserções de tempo estipuladas.

Siga os seguintes comandos de terminal para avaliar cada módulo:

### 1. Testar o Contador de Programa (PC)
```bash
# Compilar o modulo em conjunto com o testbench
iverilog -o pc.vvp contador_de_programa/contador_de_programa.v contador_de_programa/contador_de_programa_TB.v

# Executar a simulacao
vvp pc.vvp
```

### 2. Testar a Memória de Dados
```bash
# Compilar o modulo em conjunto com o testbench
iverilog -o m_dados.vvp memoria_dados/memoria_dados.v memoria_dados/memoria_dados_TB.v

# Executar a simulacao
vvp m_dados.vvp
```

### 3. Testar a Memória de Instruções
```bash
# Compilar o modulo em conjunto com o testbench
iverilog -o m_inst.vvp memoria_instrucoes/memoria_instrucoes.v memoria_instrucoes/memoria_instrucoes_TB.v

# Executar a simulacao
vvp m_inst.vvp
```
