%option noyywrap nounput noinput

%{
#include "parser.tab.h"
%}

DIGITO      [0-9]
LETRA       [A-Za-z]
ID          {LETRA}({LETRA}|{DIGITO})*

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

{DIGITO}+       { return NUM; }
{ID}            { return ID; }
[ \t\r\n]+      ;
.               ;

%%