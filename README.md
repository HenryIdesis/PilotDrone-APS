# PilotDrone – APS de Linguagens de Programação

Esse repositório contém a implementação da **linguagem PilotDrone**, pensada para controlar um **drone virtual** rodando em uma máquina virtual simples (`vm`).

A ideia da APS é ter uma linguagem de alto nível (com variáveis, condicionais e laços) que seja compilada para um “assembly” próprio da VM do drone.  
Para isso eu usei:

- **Flex** para fazer a análise léxica (`lexer.l` → `lex.yy.c`)
- **Bison** para fazer a análise sintática (`parser.y` → `parser.tab.c`)
- Um programa em C que gera o arquivo `program.dvm`, que é o código que a VM entende

---

## Arquivos principais

- `grammar.ebnf` – definição da gramática da linguagem em EBNF  
- `lexer.l` – regras dos tokens (palavras-chave, identificadores, números, símbolos, etc.)  
- `parser.y` – gramática da linguagem + ações para gerar o código da VM  
- `drone_vm.c` – implementação da máquina virtual que executa o `program.dvm`  
- `makefile` – script de compilação (gera o compilador e a VM)  
- `*.pd` – programas de exemplo na linguagem PilotDrone (por exemplo `teste.pd`)  
- `program.dvm` – arquivo de saída gerado pelo compilador (assembly do drone)

---

## Como compilar

Dentro da pasta do projeto:
make
O make compila tudo e gera, pelo menos:

drone → compilador da linguagem PilotDrone

vm → máquina virtual do drone

Se quiser limpar os arquivos gerados (binários, arquivos do Flex/Bison, etc.):

bash
Copiar código
make clean
(se o alvo clean estiver definido no makefile)

Como usar
Escreva um programa em PilotDrone, por exemplo teste.pd:

txt
Copiar código
subir(10);
girar(90);
pousar();
Rode o compilador para gerar o código da VM:

bash
Copiar código
./drone < teste.pd > program.dvm
Depois, execute o programa na VM:

bash
Copiar código
./vm program.dvm
Se tudo estiver certo, a VM vai interpretar o program.dvm e simular os comandos do drone.

Sobre a linguagem PilotDrone
A linguagem foi feita para ser simples e focada em movimentos do drone, mas ao mesmo tempo cumprir os requisitos da APS.

Ela tem:

Comandos de drone, como por exemplo:

subir(N);

descer(N);

girar(N);

pousar();

Variáveis inteiras e atribuição

Expressões aritméticas básicas (+, -, *, /)

Condicionais (ex.: if / else na sintaxe escolhida)

Laços (while / outro tipo de loop, de acordo com a gramática)

A sintaxe exata (palavras-chave, estrutura do if, do while, etc.) está descrita em:

grammar.ebnf

parser.y

Exemplos
Alguns exemplos de programas estão no repositório em arquivos .pd.
Eles mostram:

uso de comandos básicos do drone

programas sequenciais simples

exemplos com variáveis / laços (quando suportados na gramática atual)

Para testar qualquer um deles, o fluxo é sempre:

bash
Copiar código
./drone < exemplo.pd > program.dvm
./vm program.dvm