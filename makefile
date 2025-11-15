# Compilador e ferramentas
CC = gcc
LEX = flex
YACC = bison -d
CFLAGS = -Wall

# Nomes dos arquivos
TARGET = drone
LEX_FILE = lexer.l
YACC_FILE = parser.y

# Regras
VM = vm
VM_SRC = drone_vm.c

all: $(TARGET) $(VM)

$(TARGET): parser.tab.c lex.yy.c
	$(CC) $(CFLAGS) parser.tab.c lex.yy.c -o $(TARGET)

$(VM): $(VM_SRC)
	$(CC) $(CFLAGS) $(VM_SRC) -o $(VM)

parser.tab.c parser.tab.h: $(YACC_FILE)
	$(YACC) $(YACC_FILE)

lex.yy.c: $(LEX_FILE)
	$(LEX) $(LEX_FILE)

clean:
	rm -f lex.yy.c parser.tab.c parser.tab.h $(TARGET)

.PHONY: all clean