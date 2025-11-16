%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);

FILE *saida;

typedef struct {
    char *nome;
    int addr;
} Simbolo;

#define MAX_VARS 256

static Simbolo tabela[MAX_VARS];
static int nvars = 0;

static int novo_simbolo(const char *nome) {
    for (int i = 0; i < nvars; i++) {
        if (strcmp(tabela[i].nome, nome) == 0) {
            return tabela[i].addr;
        }
    }
    if (nvars >= MAX_VARS) {
        fprintf(stderr, "Muitas variaveis declaradas\n");
        exit(1);
    }
    tabela[nvars].nome = strdup(nome);
    tabela[nvars].addr = nvars;
    return tabela[nvars++].addr;
}

static int busca_simbolo(const char *nome) {
    for (int i = 0; i < nvars; i++) {
        if (strcmp(tabela[i].nome, nome) == 0) {
            return tabela[i].addr;
        }
    }
    fprintf(stderr, "Variavel nao declarada: %s\n", nome);
    exit(1);
}

static int lbl_count = 0;
static int novo_label(void) {
    return lbl_count++;
}

/* pilha de labels para while aninhado */
static int lbl_ini[64];
static int lbl_fim[64];
static int topo_loop = -1;

/* pilha de labels para if aninhado */
static int if_end[64];
static int topo_if = -1;

static void push_loop(int ini, int fim) {
    if (topo_loop >= 63) {
        fprintf(stderr, "Muitos loops aninhados\n");
        exit(1);
    }
    topo_loop++;
    lbl_ini[topo_loop] = ini;
    lbl_fim[topo_loop] = fim;
}

static void topo_labels(int *ini, int *fim) {
    if (topo_loop < 0) {
        fprintf(stderr, "Pilha de loops vazia\n");
        exit(1);
    }
    *ini = lbl_ini[topo_loop];
    *fim = lbl_fim[topo_loop];
}

static void pop_loop(int *ini, int *fim) {
    if (topo_loop < 0) {
        fprintf(stderr, "Pilha de loops vazia\n");
        exit(1);
    }
    *ini = lbl_ini[topo_loop];
    *fim = lbl_fim[topo_loop];
    topo_loop--;
}

/* helpers para gerar codigo da VM (maquina de pilha simples) */

static void gen_push_const(int v) {
    fprintf(saida, "PUSH %d\n", v);
}

static void gen_load(int addr) {
    fprintf(saida, "LOAD %d\n", addr);
}

static void gen_store(int addr) {
    fprintf(saida, "STORE %d\n", addr);
}

%}

%union {
    int ival;
    char *sval;
}

/* tokens vindos do lexer */
%token VAR IF ELSE WHILE
%token SUBIR DESCER FRENTE TRAS POUSAR GIRAR
%token MAIS MENOS MULT DIV
%token MAIOR MENOR IGUAL
%token ABREPAR FECHAPAR ABRECH FECHACH
%token PONTOEVIRG ATRIB
%token ALTITUDE BATERIA

%token <ival> NUM
%token <sval> ID

%left MAIS MENOS
%left MULT DIV
%left MAIOR MENOR IGUAL

%type <ival> expressao

%start programa

%%

programa
    : comandos
      {
          fprintf(saida, "HALT\n");
      }
    ;

comandos
    : /* vazio */
    | comandos comando
    ;

comando
    : declaracao
    | atribuicao PONTOEVIRG
    | comando_drone PONTOEVIRG
    | comando_if
    | comando_while
    ;

declaracao
    : VAR ID PONTOEVIRG
      {
          int addr = novo_simbolo($2);
          gen_push_const(0);
          gen_store(addr);
      }
    | VAR ID ATRIB expressao PONTOEVIRG
      {
          int addr = novo_simbolo($2);
          gen_store(addr);
      }
    ;

atribuicao
    : ID ATRIB expressao
      {
          int addr = busca_simbolo($1);
          gen_store(addr);
      }
    ;

comando_drone
    : SUBIR ABREPAR expressao FECHAPAR
      {
          /* expressao deixa valor no topo da pilha */
          fprintf(saida, "UP\n");
      }
    | DESCER ABREPAR expressao FECHAPAR
      {
          fprintf(saida, "DOWN\n");
      }
    | FRENTE ABREPAR expressao FECHAPAR
      {
          fprintf(saida, "FWD\n");
      }
    | TRAS ABREPAR expressao FECHAPAR
      {
          fprintf(saida, "BACK\n");
      }
    | GIRAR ABREPAR expressao FECHAPAR
      {
          fprintf(saida, "TURN\n");
      }
    | POUSAR ABREPAR FECHAPAR
      {
          fprintf(saida, "LAND\n");
      }
    ;

/* if(cond) bloco;  -- sem else para simplificar */
comando_if
    : IF ABREPAR expressao FECHAPAR
      {
          int l_end = novo_label();
          if (topo_if >= 63) {
              fprintf(stderr, "Muitos ifs aninhados\n");
              exit(1);
          }
          topo_if++;
          if_end[topo_if] = l_end;
          fprintf(saida, "JZ %d\n", l_end);
      }
      bloco
      {
          int l_end = if_end[topo_if--];
          fprintf(saida, "LABEL %d\n", l_end);
      }
    ;

comando_while
    : WHILE
      {
          int li = novo_label();
          int lf = novo_label();
          push_loop(li, lf);
          fprintf(saida, "LABEL %d\n", li);
      }
      ABREPAR expressao FECHAPAR
      {
          int li, lf;
          topo_labels(&li, &lf);
          fprintf(saida, "JZ %d\n", lf);
      }
      bloco
      {
          int li, lf;
          pop_loop(&li, &lf);
          fprintf(saida, "JMP %d\n", li);
          fprintf(saida, "LABEL %d\n", lf);
      }
    ;

bloco
    : comando
    | ABRECH comandos FECHACH
    ;

expressao
    : expressao MAIS expressao
      {
          fprintf(saida, "ADD\n");
          $$ = 0;
      }
    | expressao MENOS expressao
      {
          fprintf(saida, "SUB\n");
          $$ = 0;
      }
    | expressao MULT expressao
      {
          fprintf(saida, "MUL\n");
          $$ = 0;
      }
    | expressao DIV expressao
      {
          fprintf(saida, "DIV\n");
          $$ = 0;
      }
    | expressao MAIOR expressao
      {
          fprintf(saida, "GT\n");
          $$ = 0;
      }
    | expressao MENOR expressao
      {
          fprintf(saida, "LT\n");
          $$ = 0;
      }
    | expressao IGUAL expressao
      {
          fprintf(saida, "EQ\n");
          $$ = 0;
      }
    | ABREPAR expressao FECHAPAR
      {
          $$ = 0;
      }
    | NUM
      {
          gen_push_const($1);
          $$ = 0;
      }
    | ID
      {
          int addr = busca_simbolo($1);
          gen_load(addr);
          $$ = 0;
      }
    | ALTITUDE
      {
          fprintf(saida, "SENSE_ALT\n");
          $$ = 0;
      }
    | BATERIA
      {
          fprintf(saida, "SENSE_BAT\n");
          $$ = 0;
      }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro de sintaxe: %s\n", s);
}

int main(void) {
    saida = stdout;
    return yyparse();
}
