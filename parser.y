%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);
FILE *saida;

static int lbl_count = 0;
static int novo_label(void) {
    return lbl_count++;
}

/* pilha de labels para while aninhado */
static int lbl_ini[64];
static int lbl_fim[64];
static int topo_loop = -1;
%}

%token VAR IF ELSE WHILE
%token SUBIR DESCER FRENTE TRAS POUSAR GIRAR
%token MAIS MENOS MULT DIV MAIOR MENOR IGUAL
%token ABREPAR FECHAPAR ABRECH FECHACH PONTOEVIRG ATRIB
%token NUM ID

%left MAIS MENOS
%left MULT DIV
%left MAIOR MENOR IGUAL

%start programa

%%

programa
    : declaracoes
      {
          fprintf(saida, "HALT\n");
      }
    ;

declaracoes
    : /* vazio */
    | declaracoes declaracao
    ;

declaracao
    : atribuicao
    | condicional
    | loop
    | comando
    ;

atribuicao:
      VAR ID PONTOEVIRG
    | VAR ID ATRIB expressao PONTOEVIRG
    | ID ATRIB expressao PONTOEVIRG
    ;

condicional
    : IF ABREPAR expressao FECHAPAR bloco
    | IF ABREPAR expressao FECHAPAR bloco ELSE bloco
    ;

loop
    : cabecalho_while bloco
      {
          fprintf(saida, "JMP L%d\n", lbl_ini[topo_loop]);
          fprintf(saida, "L%d:\n", lbl_fim[topo_loop]);
          topo_loop--;
      }
    ;

cabecalho_while
    : WHILE ABREPAR
      {
          topo_loop++;
          lbl_ini[topo_loop] = novo_label();
          lbl_fim[topo_loop] = novo_label();
          fprintf(saida, "L%d:\n", lbl_ini[topo_loop]);
      }
      expressao FECHAPAR
      {
          fprintf(saida, "JZ L%d\n", lbl_fim[topo_loop]);
      }
    ;

bloco
    : ABRECH declaracoes FECHACH
    ;

comando
    : SUBIR   ABREPAR NUM FECHAPAR PONTOEVIRG
        { fprintf(saida, "ASC %d\n",   $3); }
    | DESCER  ABREPAR NUM FECHAPAR PONTOEVIRG
        { fprintf(saida, "DESC %d\n",  $3); }
    | FRENTE  ABREPAR NUM FECHAPAR PONTOEVIRG
        { fprintf(saida, "FWD %d\n",   $3); }
    | TRAS    ABREPAR NUM FECHAPAR PONTOEVIRG
        { fprintf(saida, "BACK %d\n",  $3); }
    | GIRAR   ABREPAR NUM FECHAPAR PONTOEVIRG
        { fprintf(saida, "ROT %d\n",   $3); }
    | POUSAR  ABREPAR FECHAPAR PONTOEVIRG
        { fprintf(saida, "LAND\n"); }
    ;

expressao
    : termo
    | expressao MAIS  termo   { fprintf(saida, "ADD\n"); }
    | expressao MENOS termo   { fprintf(saida, "SUB\n"); }
    | expressao MULT  termo   { fprintf(saida, "MUL\n"); }
    | expressao DIV   termo   { fprintf(saida, "DIV\n"); }
    | expressao MAIOR termo   { fprintf(saida, "GT\n"); }
    | expressao MENOR termo   { fprintf(saida, "LT\n"); }
    | expressao IGUAL termo   { fprintf(saida, "EQ\n"); }
    ;

termo
    : NUM
        { fprintf(saida, "PUSH %d\n", $1); }
    | ID
        { fprintf(saida, "PUSH 0\n"); }
    | ABREPAR expressao FECHAPAR
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
