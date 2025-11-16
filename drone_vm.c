#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_CODE   2048
#define MAX_STACK  1024
#define MAX_LABELS 512
#define MAX_MEM    256
#define MAX_LINE   256

typedef enum {
    OP_NOP = 0,
    OP_PUSH,
    OP_LOAD,
    OP_STORE,
    OP_ADD,
    OP_SUB,
    OP_MUL,
    OP_DIV,
    OP_LT,
    OP_GT,
    OP_EQ,
    OP_JMP,
    OP_JZ,
    OP_JNZ,
    OP_UP,
    OP_DOWN,
    OP_FWD,
    OP_BACK,
    OP_TURN,
    OP_LAND,
    OP_SENSE_ALT,
    OP_SENSE_BAT,
    OP_LABEL,
    OP_HALT
} OpCode;

typedef struct {
    OpCode op;
    int arg;
} Instr;

static Instr code[MAX_CODE];
static int   ncode = 0;
static int   label_addr[MAX_LABELS];

static int stack_vm[MAX_STACK];
static int sp = 0;

static int mem[MAX_MEM];
static int reg0 = 0;
static int reg1 = 0;

static int altitude = 0;
static int bateria  = 100;
static int pos_x    = 0;
static int pos_y    = 0;

static void stack_push(int v) {
    if (sp >= MAX_STACK) {
        fprintf(stderr, "Stack overflow\n");
        exit(1);
    }
    stack_vm[sp++] = v;
}

static int stack_pop(void) {
    if (sp <= 0) {
        fprintf(stderr, "Stack underflow\n");
        exit(1);
    }
    return stack_vm[--sp];
}

static OpCode parse_op(const char *s) {
    if (strcmp(s, "PUSH") == 0) return OP_PUSH;
    if (strcmp(s, "LOAD") == 0) return OP_LOAD;
    if (strcmp(s, "STORE") == 0) return OP_STORE;
    if (strcmp(s, "ADD") == 0) return OP_ADD;
    if (strcmp(s, "SUB") == 0) return OP_SUB;
    if (strcmp(s, "MUL") == 0) return OP_MUL;
    if (strcmp(s, "DIV") == 0) return OP_DIV;
    if (strcmp(s, "LT") == 0) return OP_LT;
    if (strcmp(s, "GT") == 0) return OP_GT;
    if (strcmp(s, "EQ") == 0) return OP_EQ;
    if (strcmp(s, "JMP") == 0) return OP_JMP;
    if (strcmp(s, "JZ") == 0) return OP_JZ;
    if (strcmp(s, "JNZ") == 0) return OP_JNZ;
    if (strcmp(s, "UP") == 0) return OP_UP;
    if (strcmp(s, "DOWN") == 0) return OP_DOWN;
    if (strcmp(s, "FWD") == 0) return OP_FWD;
    if (strcmp(s, "BACK") == 0) return OP_BACK;
    if (strcmp(s, "TURN") == 0) return OP_TURN;
    if (strcmp(s, "LAND") == 0) return OP_LAND;
    if (strcmp(s, "SENSE_ALT") == 0) return OP_SENSE_ALT;
    if (strcmp(s, "SENSE_BAT") == 0) return OP_SENSE_BAT;
    if (strcmp(s, "LABEL") == 0) return OP_LABEL;
    if (strcmp(s, "HALT") == 0) return OP_HALT;
    return OP_NOP;
}

static void init_labels(void) {
    for (int i = 0; i < MAX_LABELS; i++) {
        label_addr[i] = -1;
    }
}

static void load_program(FILE *f) {
    char line[MAX_LINE];
    init_labels();
    ncode = 0;

    while (fgets(line, sizeof(line), f)) {
        char *p = line;

        while (*p == ' ' || *p == '\t') p++;
        if (*p == '\0' || *p == '\n') continue;
        if (*p == '#' || (p[0] == '/' && p[1] == '/')) continue;

        char opstr[32];
        int arg = 0;
        int n = sscanf(p, "%31s %d", opstr, &arg);
        if (n <= 0) continue;

        OpCode op = parse_op(opstr);
        if (op == OP_NOP) {
            fprintf(stderr, "Instrucao desconhecida: %s\n", opstr);
            exit(1);
        }

        if (ncode >= MAX_CODE) {
            fprintf(stderr, "Programa muito grande\n");
            exit(1);
        }

        code[ncode].op  = op;
        code[ncode].arg = (n >= 2) ? arg : 0;

        if (op == OP_LABEL) {
            int id = code[ncode].arg;
            if (id < 0 || id >= MAX_LABELS) {
                fprintf(stderr, "Label fora do limite: %d\n", id);
                exit(1);
            }
            label_addr[id] = ncode;
        }

        ncode++;
    }
}

static void exec_program(void) {
    int pc = 0;
    while (pc < ncode) {
        Instr in = code[pc];
        switch (in.op) {
            case OP_PUSH: {
                stack_push(in.arg);
                pc++;
                break;
            }
            case OP_LOAD: {
                int addr = in.arg;
                if (addr < 0 || addr >= MAX_MEM) {
                    fprintf(stderr, "Endereco invalido em LOAD: %d\n", addr);
                    exit(1);
                }
                stack_push(mem[addr]);
                pc++;
                break;
            }
            case OP_STORE: {
                int addr = in.arg;
                if (addr < 0 || addr >= MAX_MEM) {
                    fprintf(stderr, "Endereco invalido em STORE: %d\n", addr);
                    exit(1);
                }
                int v = stack_pop();
                mem[addr] = v;
                pc++;
                break;
            }
            case OP_ADD: {
                int b = stack_pop();
                int a = stack_pop();
                stack_push(a + b);
                pc++;
                break;
            }
            case OP_SUB: {
                int b = stack_pop();
                int a = stack_pop();
                stack_push(a - b);
                pc++;
                break;
            }
            case OP_MUL: {
                int b = stack_pop();
                int a = stack_pop();
                stack_push(a * b);
                pc++;
                break;
            }
            case OP_DIV: {
                int b = stack_pop();
                int a = stack_pop();
                if (b == 0) {
                    fprintf(stderr, "Divisao por zero\n");
                    exit(1);
                }
                stack_push(a / b);
                pc++;
                break;
            }
            case OP_LT: {
                int b = stack_pop();
                int a = stack_pop();
                stack_push(a < b ? 1 : 0);
                pc++;
                break;
            }
            case OP_GT: {
                int b = stack_pop();
                int a = stack_pop();
                stack_push(a > b ? 1 : 0);
                pc++;
                break;
            }
            case OP_EQ: {
                int b = stack_pop();
                int a = stack_pop();
                stack_push(a == b ? 1 : 0);
                pc++;
                break;
            }
            case OP_JMP: {
                int id = in.arg;
                if (id < 0 || id >= MAX_LABELS || label_addr[id] < 0) {
                    fprintf(stderr, "Label invalido em JMP: %d\n", id);
                    exit(1);
                }
                pc = label_addr[id];
                break;
            }
            case OP_JZ: {
                int v = stack_pop();
                if (v == 0) {
                    int id = in.arg;
                    if (id < 0 || id >= MAX_LABELS || label_addr[id] < 0) {
                        fprintf(stderr, "Label invalido em JZ: %d\n", id);
                        exit(1);
                    }
                    pc = label_addr[id];
                } else {
                    pc++;
                }
                break;
            }
            case OP_JNZ: {
                int v = stack_pop();
                if (v != 0) {
                    int id = in.arg;
                    if (id < 0 || id >= MAX_LABELS || label_addr[id] < 0) {
                        fprintf(stderr, "Label invalido em JNZ: %d\n", id);
                        exit(1);
                    }
                    pc = label_addr[id];
                } else {
                    pc++;
                }
                break;
            }
            case OP_UP: {
                int v = stack_pop();
                altitude += v;
                bateria -= (v > 0 ? 1 : 0);
                printf("DRONE: subir %d -> altitude=%d bateria=%d\n", v, altitude, bateria);
                pc++;
                break;
            }
            case OP_DOWN: {
                int v = stack_pop();
                altitude -= v;
                if (altitude < 0) altitude = 0;
                bateria -= (v > 0 ? 1 : 0);
                printf("DRONE: descer %d -> altitude=%d bateria=%d\n", v, altitude, bateria);
                pc++;
                break;
            }
            case OP_FWD: {
                int v = stack_pop();
                pos_y += v;
                bateria -= (v > 0 ? 1 : 0);
                printf("DRONE: frente %d -> pos=(%d,%d) bateria=%d\n", v, pos_x, pos_y, bateria);
                pc++;
                break;
            }
            case OP_BACK: {
                int v = stack_pop();
                pos_y -= v;
                bateria -= (v > 0 ? 1 : 0);
                printf("DRONE: tras %d -> pos=(%d,%d) bateria=%d\n", v, pos_x, pos_y, bateria);
                pc++;
                break;
            }
            case OP_TURN: {
                int v = stack_pop();
                reg0 = (reg0 + v) % 360;
                bateria -= (v != 0 ? 1 : 0);
                printf("DRONE: girar %d -> angulo=%d bateria=%d\n", v, reg0, bateria);
                pc++;
                break;
            }
            case OP_LAND: {
                altitude = 0;
                printf("DRONE: pousar -> altitude=%d bateria=%d\n", altitude, bateria);
                pc++;
                break;
            }
            case OP_SENSE_ALT: {
                stack_push(altitude);
                pc++;
                break;
            }
            case OP_SENSE_BAT: {
                stack_push(bateria);
                pc++;
                break;
            }
            case OP_LABEL: {
                pc++;
                break;
            }
            case OP_HALT: {
                printf("HALT: estado final -> altitude=%d pos=(%d,%d) bateria=%d reg0=%d reg1=%d\n",
                       altitude, pos_x, pos_y, bateria, reg0, reg1);
                return;
            }
            default: {
                fprintf(stderr, "Opcode invalido em pc=%d\n", pc);
                exit(1);
            }
        }
    }
}

int main(int argc, char **argv) {
    const char *fname = "program.dvm";
    if (argc > 1) {
        fname = argv[1];
    }

    FILE *f = fopen(fname, "r");
    if (!f) {
        perror("Erro ao abrir arquivo de programa");
        return 1;
    }

    load_program(f);
    fclose(f);

    exec_program();
    return 0;
}
