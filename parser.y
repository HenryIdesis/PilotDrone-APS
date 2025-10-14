%{
#include "parser.tab.h"
%}
%token VAR IF ELSE WHILE
%token SUBIR DESCER FRENTE TRAS POUSAR GIRAR
%token MAIS MENOS MULT DIV MAIOR MENOR IGUAL
%token ABREPAR FECHAPAR ABRECH FECHACH PONTOEVIRG ATRIB
%token NUM ID
%%

programa:
      /* vazio */
    | programa declaracao
    ;
declaracao:
      atribuicao
    | condicional
    | loop
    | comando
    ;
atribuicao:
      VAR ID ATRIB expressao PONTOEVIRG
    ;
condicional:
      IF ABREPAR expressao FECHAPAR bloco
    | IF ABREPAR expressao FECHAPAR bloco ELSE bloco
    ;
loop:
      WHILE ABREPAR expressao FECHAPAR bloco
    ;
bloco:
      ABRECH declaracoes FECHACH
    ;
declaracoes:
      /* vazio */
    | declaracoes declaracao
    ;
comando:
      SUBIR ABREPAR NUM FECHAPAR PONTOEVIRG
    | DESCER ABREPAR NUM FECHAPAR PONTOEVIRG
    | FRENTE ABREPAR NUM FECHAPAR PONTOEVIRG
    | TRAS ABREPAR NUM FECHAPAR PONTOEVIRG
    | POUSAR ABREPAR FECHAPAR PONTOEVIRG
    | GIRAR ABREPAR NUM FECHAPAR PONTOEVIRG
    ;
expressao:
      termo
    | expressao operador termo
    ;
operador:
      MAIS | MENOS | MULT | DIV | MAIOR | MENOR | IGUAL
    ;
termo:
      NUM
    | ID
    ;

%%