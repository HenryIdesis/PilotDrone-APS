%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>
%}

%option noyywrap

DIGITO  [0-9]
ID      [a-zA-Z_][a-zA-Z0-9_]*

%%

"var"           { return VAR; }
"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }

"subir"         { return SUBIR; }
"descer"        { return DESCER; }
"frente"        { return FRENTE; }
"tras"          { return TRAS; }
"pousar"        { return POUSAR; }
"girar"         { return GIRAR; }

"altitude"      { return ALTITUDE; }
"bateria"       { return BATERIA; }

"=="            { return IGUAL; }
">"             { return MAIOR; }
"<"             { return MENOR; }

"+"             { return MAIS; }
"-"             { return MENOS; }
"*"             { return MULT; }
"/"             { return DIV; }

"("             { return ABREPAR; }
")"             { return FECHAPAR; }
"{"             { return ABRECH; }
"}"             { return FECHACH; }
";"             { return PONTOEVIRG; }
"="             { return ATRIB; }

{DIGITO}+       {
                    yylval.ival = atoi(yytext);
                    return NUM;
                }

{ID}            {
                    yylval.sval = strdup(yytext);
                    return ID;
                }

[ \t\r\n]+      { /* ignora espacos em branco */ }

"//".*          { /* comentario de linha */ }

.               {
                    fprintf(stderr, "Caractere desconhecido: %s\n", yytext);
                }

%%
