PilotDrone – APS de Linguagens de Programação

Esse repositório é a entrega da APS de Linguagens de Programação.
Aqui eu criei uma linguagem própria, chamada PilotDrone, que serve para controlar um drone virtual rodando em uma máquina virtual simples (vm).

A ideia é:

Eu escrevo um programa em PilotDrone (.pd).

O compilador (feito com Flex + Bison) transforma esse código em um “assembly” simples da VM.

A máquina virtual lê esse arquivo e simula o comportamento do drone (subir, descer, andar, girar, etc.).

Tudo isso cumpre os requisitos da APS: EBNF, Flex/Bison, VM com registradores, memória, sensores e instruções suficientes para ser Turing-completa.

Stack usada

Flex – análise léxica (lexer.l → lex.yy.c)

Bison – análise sintática e geração de código (parser.y → parser.tab.c)

C – tanto para o compilador quanto para a máquina virtual (drone_vm.c)

Makefile – pra não ter que decorar os comandos de compilação 😉

Organização do repositório

Arquivos principais:

grammar.ebnf
Definição da gramática da linguagem PilotDrone em EBNF. Aqui aparecem:

definição de programa

comandos

if, while

expressões

sensores (altitude, bateria), etc.

lexer.l
Descreve os tokens da linguagem:

palavras-chave (var, if, while, subir, frente, pousar…)

identificadores

números

operadores (+, -, *, /, >, <, ==, =…)

símbolos ((, ), {, }, ;)

parser.y
Contém a gramática em Bison e, nas ações semânticas, a geração do “assembly” da VM.
O yyparse() lê o código PilotDrone e escreve instruções como PUSH, LOAD, JZ, UP, FWD, etc. na saída padrão (que eu redireciono para program.dvm).

drone_vm.c
Implementação da máquina virtual do drone.
Aqui eu tenho:

2 registradores (reg0 e reg1)

memória de variáveis (mem[MAX_MEM])

pilha de execução (stack_vm)

sensores somente leitura:

altitude

bateria

conjunto de instruções: aritmética, comparação, saltos (JZ, JMP), operações de pilha e os comandos específicos do drone (UP, DOWN, FWD, BACK, TURN, LAND, SENSE_ALT, SENSE_BAT).

makefile
Cuida de gerar:

drone → compilador da linguagem PilotDrone

vm → máquina virtual do drone

*.pd
Programas de exemplo na linguagem PilotDrone:

teste.pd

while.pd

teste_completo.pd

program.dvm
Arquivo de “assembly” gerado pelo compilador. É o que a VM lê e executa.
(Não precisa ficar versionado; pode ser gerado sempre que rodar o compilador.)

Como compilar

Pré-requisitos: gcc, flex e bison instalados.

Dentro da pasta do projeto, basta rodar:

make


Isso vai gerar:

drone – o compilador da linguagem PilotDrone

vm – a máquina virtual que executa o program.dvm

Se quiser limpar tudo que foi gerado (binários, arquivos do Flex/Bison, etc.):

make clean

Como usar

O fluxo geral é sempre:

Escrever um arquivo .pd com código PilotDrone.

Rodar o compilador (drone) e redirecionar a saída para program.dvm.

Rodar a VM (vm) passando o program.dvm.

Exemplo genérico:

./drone < exemplo.pd > program.dvm
./vm program.dvm


Se tudo estiver certo, a VM imprime no terminal o que o drone está fazendo (subir, descer, frente, etc.) e o estado final.

A linguagem PilotDrone (visão geral)

A PilotDrone é uma linguagem bem simples, feita só para essa APS, mas que tem:

1. Variáveis e atribuição

Declaração:

var x;
var y = 10;


Atribuição e expressões inteiras:

x = 20 + 30;
y = x * 2;
x = y - 5;

2. Expressões

Operadores suportados:

Aritméticos: +, -, *, /

Relacionais: >, <, ==

As expressões são avaliadas em uma pilha na VM, usando instruções como PUSH, ADD, SUB, MUL, DIV, GT, LT, EQ.

3. Comandos do drone

Comandos básicos (todos recebem inteiros, exceto pousar):

subir(N);
descer(N);
frente(N);
tras(N);
girar(N);
pousar();


Na VM, eles viram instruções como UP, DOWN, FWD, BACK, TURN, LAND e atualizam:

altitude

posição (pos_x, pos_y)

bateria

4. Sensores (somente leitura)

A linguagem expõe dois sensores:

altitude – altura atual do drone

bateria – nível de bateria

Eles aparecem como valores em expressões, por exemplo:

if (bateria > 80) {
    frente(20);
}


Na VM, isso usa instruções SENSE_ALT e SENSE_BAT, que empurram os valores na pilha.

5. Condicionais (if)

A linguagem suporta if (condição) { ... } (sem else na versão atual):

if (bateria > 80) {
    frente(20);
}


O compilador traduz a condição para código de pilha e depois gera um:

JZ label_fim

bloco de comandos

LABEL label_fim

6. Laços (while)

Também há while (condição) { ... }:

while (altitude < 50) {
    subir(10);
}


Isso é traduzido mais ou menos para:

LABEL ini

código da condição

JZ fim

corpo do laço

JMP ini

LABEL fim

Programas de exemplo
1. teste.pd – variáveis + comandos básicos
var passo = 10;
var altura_final;

altura_final = 20 + 30;

frente(passo);
subir(altura_final);
pousar();


Demonstra:

declaração com e sem inicialização

expressão aritmética

uso de variáveis como argumentos dos comandos de drone

Como rodar:

./drone < teste.pd > program.dvm
./vm program.dvm

2. while.pd – laço com sensor
while (altitude < 50) {
    subir(10);
}

pousar();


Demonstra:

uso de while

leitura do sensor altitude dentro da condição

efeito acumulativo: o drone sobe até atingir a altura desejada

3. teste_completo.pd – tudo junto
var alvo_altura = 50;
var passos = 10;

while (altitude < alvo_altura) {
    subir(passos);
    passos = passos + 5;
}

if (bateria > 80) {
    frente(20);
}

pousar();


Demonstra:

variáveis com inicialização

laço while com sensor + variável

atualização de variável dentro do laço

condicional if usando o sensor bateria

vários comandos de drone combinados

Observações finais

Alguns warnings aparecem ao compilar arquivos gerados pelo Flex (lex.yy.c), do tipo “função definida e não utilizada”. Eles são normais e não afetam a execução.

O objetivo principal aqui é mostrar o fluxo completo:

linguagem em EBNF

análise léxica/sintática com Flex/Bison

geração de código para uma VM própria

exemplos que usam variáveis, condicionais, laços e comandos da VM.

Com isso, o projeto fecha os requisitos da APS e ainda deixa a PilotDrone pronta para ganhar novos comandos ou recursos no futuro, se eu quiser brincar mais com ela.