#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_PROG 256
#define MAX_MEM 256

#define OP_NOP       0
#define OP_HALT      1
#define OP_LOADI     2
#define OP_LOAD      3
#define OP_STORE     4
#define OP_ADD       5
#define OP_SUB       6
#define OP_JMP       7
#define OP_JZ        8
#define OP_ASC       9
#define OP_DESC     10
#define OP_FWD      11
#define OP_BACK     12
#define OP_ROT      13
#define OP_LAND     14
#define OP_READ_BAT 15
#define OP_READ_ALT 16

struct Instrucao {
    int op;
    int a;
    int b;
};

void imprime_estado(int pc, int r0, int r1,
                    int altitude, int bateria,
                    int x, int y, int angulo) {
    printf("pc=%d R0=%d R1=%d alt=%d bat=%d x=%d y=%d heading=%d\n",
           pc, r0, r1, altitude, bateria, x, y, angulo);
}

int carrega_programa(const char *nome, struct Instrucao prog[], int max_prog) {
    FILE *f = fopen(nome, "r");
    char linha[128];
    int n = 0;

    if (f == NULL) {
        perror("erro abrindo arquivo de programa");
        return -1;
    }

    while (fgets(linha, sizeof(linha), f) != NULL && n < max_prog) {
        char op[32];
        int a = 0;
        int b = 0;
        int q;

        if (linha[0] == '#' || linha[0] == '\n') {
            continue;
        }

        q = sscanf(linha, "%31s %d %d", op, &a, &b);
        if (q <= 0) {
            continue;
        }

        if (strcmp(op, "HALT") == 0) {
            prog[n].op = OP_HALT;
            prog[n].a = 0;
            prog[n].b = 0;
        } else if (strcmp(op, "NOP") == 0) {
            prog[n].op = OP_NOP;
            prog[n].a = 0;
            prog[n].b = 0;
        } else if (strcmp(op, "LOADI") == 0) {
            prog[n].op = OP_LOADI;
            prog[n].a = a;
            prog[n].b = b;
        } else if (strcmp(op, "LOAD") == 0) {
            prog[n].op = OP_LOAD;
            prog[n].a = a;
            prog[n].b = b;
        } else if (strcmp(op, "STORE") == 0) {
            prog[n].op = OP_STORE;
            prog[n].a = a;
            prog[n].b = b;
        } else if (strcmp(op, "ADD") == 0) {
            prog[n].op = OP_ADD;
            prog[n].a = a;
            prog[n].b = b;
        } else if (strcmp(op, "SUB") == 0) {
            prog[n].op = OP_SUB;
            prog[n].a = a;
            prog[n].b = b;
        } else if (strcmp(op, "JMP") == 0) {
            prog[n].op = OP_JMP;
            prog[n].a = a;
            prog[n].b = 0;
        } else if (strcmp(op, "JZ") == 0) {
            prog[n].op = OP_JZ;
            prog[n].a = a;
            prog[n].b = b;
        } else if (strcmp(op, "ASC") == 0) {
            prog[n].op = OP_ASC;
            prog[n].a = a;
            prog[n].b = 0;
        } else if (strcmp(op, "DESC") == 0) {
            prog[n].op = OP_DESC;
            prog[n].a = a;
            prog[n].b = 0;
        } else if (strcmp(op, "FWD") == 0) {
            prog[n].op = OP_FWD;
            prog[n].a = a;
            prog[n].b = 0;
        } else if (strcmp(op, "BACK") == 0) {
            prog[n].op = OP_BACK;
            prog[n].a = a;
            prog[n].b = 0;
        } else if (strcmp(op, "ROT") == 0) {
            prog[n].op = OP_ROT;
            prog[n].a = a;
            prog[n].b = 0;
        } else if (strcmp(op, "LAND") == 0) {
            prog[n].op = OP_LAND;
            prog[n].a = 0;
            prog[n].b = 0;
        } else if (strcmp(op, "READ_BAT") == 0) {
            prog[n].op = OP_READ_BAT;
            prog[n].a = a;
            prog[n].b = 0;
        } else if (strcmp(op, "READ_ALT") == 0) {
            prog[n].op = OP_READ_ALT;
            prog[n].a = a;
            prog[n].b = 0;
        } else {
            continue;
        }

        n++;
    }

    fclose(f);
    return n;
}

int main(int argc, char *argv[]) {
    const char *arquivo = "program.dvm";
    struct Instrucao prog[MAX_PROG];
    int prog_tam;
    int mem[MAX_MEM];
    int i;

    int r0 = 0;
    int r1 = 0;
    int pc = 0;
    int rodando = 1;

    int altitude = 0;
    int bateria = 100;
    int x = 0;
    int y = 0;
    int angulo = 0;

    if (argc > 1) {
        arquivo = argv[1];
    }

    prog_tam = carrega_programa(arquivo, prog, MAX_PROG);
    if (prog_tam <= 0) {
        fprintf(stderr, "programa vazio ou invalido\n");
        return 1;
    }

    for (i = 0; i < MAX_MEM; i++) {
        mem[i] = 0;
    }

    while (rodando) {
        struct Instrucao inst;

        if (pc < 0 || pc >= prog_tam) {
            break;
        }

        inst = prog[pc];
        imprime_estado(pc, r0, r1, altitude, bateria, x, y, angulo);

        switch (inst.op) {
        case OP_NOP:
            pc++;
            break;

        case OP_HALT:
            rodando = 0;
            break;

        case OP_LOADI:
            if (inst.a == 0) {
                r0 = inst.b;
            } else if (inst.a == 1) {
                r1 = inst.b;
            }
            pc++;
            break;

        case OP_LOAD:
            if (inst.b >= 0 && inst.b < MAX_MEM) {
                if (inst.a == 0) {
                    r0 = mem[inst.b];
                } else if (inst.a == 1) {
                    r1 = mem[inst.b];
                }
            }
            pc++;
            break;

        case OP_STORE:
            if (inst.b >= 0 && inst.b < MAX_MEM) {
                if (inst.a == 0) {
                    mem[inst.b] = r0;
                } else if (inst.a == 1) {
                    mem[inst.b] = r1;
                }
            }
            pc++;
            break;

        case OP_ADD:
            if (inst.a == 0) {
                r0 += inst.b;
            } else if (inst.a == 1) {
                r1 += inst.b;
            }
            pc++;
            break;

        case OP_SUB:
            if (inst.a == 0) {
                r0 -= inst.b;
            } else if (inst.a == 1) {
                r1 -= inst.b;
            }
            pc++;
            break;

        case OP_JMP:
            pc = inst.a;
            break;

        case OP_JZ: {
            int valor = 0;
            if (inst.a == 0) {
                valor = r0;
            } else if (inst.a == 1) {
                valor = r1;
            }
            if (valor == 0) {
                pc = inst.b;
            } else {
                pc++;
            }
            break;
        }

        case OP_ASC:
            altitude += inst.a;
            if (inst.a > 0) {
                bateria -= inst.a / 10;
                if (bateria < 0) {
                    bateria = 0;
                }
            }
            pc++;
            break;

        case OP_DESC:
            altitude -= inst.a;
            if (altitude < 0) {
                altitude = 0;
            }
            pc++;
            break;

        case OP_FWD:
            x += inst.a;
            pc++;
            break;

        case OP_BACK:
            x -= inst.a;
            pc++;
            break;

        case OP_ROT:
            angulo += inst.a;
            angulo %= 360;
            if (angulo < 0) {
                angulo += 360;
            }
            pc++;
            break;

        case OP_LAND:
            altitude = 0;
            pc++;
            break;

        case OP_READ_BAT:
            if (inst.a == 0) {
                r0 = bateria;
            } else if (inst.a == 1) {
                r1 = bateria;
            }
            pc++;
            break;

        case OP_READ_ALT:
            if (inst.a == 0) {
                r0 = altitude;
            } else if (inst.a == 1) {
                r1 = altitude;
            }
            pc++;
            break;

        default:
            rodando = 0;
            break;
        }
    }

    imprime_estado(pc, r0, r1, altitude, bateria, x, y, angulo);
    return 0;
}
