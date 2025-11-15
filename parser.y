%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);

FILE *saida;
%}

%token VAR IF ELSE WHILE
%token SUBIR DESCER FRENTE TRAS POUSAR GIRAR
%token MAIS MENOS MULT DIV MAIOR MENOR IGUAL
%token ABREPAR FECHAPAR ABRECH FECHACH PONTOEVIRG ATRIB
%token NUM ID

%left MAIS MENOS
%left MULT DIV

%start programa

%%

programa
    : declaracoes
      {
          fprintf(saida, "HALT\n");
      }
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

comando
    : SUBIR ABREPAR NUM FECHAPAR PONTOEVIRG
        { fprintf(saida, "ASC %d\n", $3); }
    | DESCER ABREPAR NUM FECHAPAR PONTOEVIRG
        { fprintf(saida, "DESC %d\n", $3); }
    | FRENTE ABREPAR NUM FECHAPAR PONTOEVIRG
        { fprintf(saida, "FWD %d\n", $3); }
    | TRAS ABREPAR NUM FECHAPAR PONTOEVIRG
        { fprintf(saida, "BACK %d\n", $3); }
    | GIRAR ABREPAR NUM FECHAPAR PONTOEVIRG
        { fprintf(saida, "ROT %d\n", $3); }
    | POUSAR ABREPAR FECHAPAR PONTOEVIRG
        { fprintf(saida, "LAND\n"); }
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

int main(void) {
    saida = fopen("program.dvm", "w");
    if (!saida) {
        perror("erro abrindo program.dvm");
        return 1;
    }

    if (yyparse() == 0) {
      printf("compilou\n");
    }
    fclose(saida);
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Erro de sintaxe: %s\n", s);
}