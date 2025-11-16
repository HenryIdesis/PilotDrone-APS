all: drone vm

drone: parser.tab.c lex.yy.c
	@gcc -Wall -g -o drone parser.tab.c lex.yy.c

parser.tab.c parser.tab.h: parser.y
	@bison -d parser.y

lex.yy.c: lexer.l parser.tab.h
	@flex lexer.l

vm: drone_vm.c
	@gcc -Wall -g -o vm drone_vm.c

clean:
	@rm -f drone vm lex.yy.c parser.tab.c parser.tab.h program.dvm
