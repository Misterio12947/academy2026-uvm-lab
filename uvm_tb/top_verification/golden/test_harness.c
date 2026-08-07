//==============================================================================
// test_harness.c
// Harness en C puro para validar el golden model cpu_model.c SIN VCS.
// Corre el programa conocido (ADD 5+3 -> STORE -> LOAD -> NOP) y verifica
// que la logica del pipeline produce los resultados esperados.
//==============================================================================

#include <stdio.h>
#include <stdint.h>

// Prototipos del modelo (definidos en cpu_model.c)
void cpu_model_reset(void);
void cpu_model_step(uint8_t cmd_in, uint8_t din_1, uint8_t din_2, uint8_t din_3,
                    uint8_t rst,
                    uint8_t *dout_high, uint8_t *dout_low,
                    uint8_t *cpu_rdy, uint8_t *zero, uint8_t *error);

// Helper: construye cmd_in de 7 bits
static uint8_t mk_cmd(uint8_t mA, uint8_t mB, uint8_t op) {
    return ((mA & 0x3) << 5) | ((mB & 0x3) << 3) | (op & 0x7);
}

// Nombres de estado/opcode para debug
static const char* isa_name(uint8_t op) {
    switch (op & 0x7) {
        case 0: return "ADD  "; case 1: return "SUB  ";
        case 2: return "MUL  "; case 3: return "DIV  ";
        case 4: return "NOP0 "; case 5: return "LOAD ";
        case 6: return "STORE"; case 7: return "NOP1 ";
    }
    return "?????";
}

int main(void) {
    uint8_t dh, dl, rdy, z, e;
    int cyc = 0;

    printf("=================================================================\n");
    printf("  Golden model - validacion ciclo a ciclo (programa conocido)\n");
    printf("=================================================================\n");

    // Reset (3 ciclos con rst=1, como el TB)
    for (int i = 0; i < 3; i++) {
        cpu_model_step(0, 0, 0, 0, /*rst=*/1, &dh, &dl, &rdy, &z, &e);
    }
    printf("[reset aplicado]\n\n");

    // Programa: (mismo que la sanity_seq / tb_explore)
    //   NOP inicial (warmup)
    //   ADD 5+3=8
    //   STORE addr=5 (escribe dout previo)
    //   LOAD  addr=5 (lee mem[5])
    //   NOP (mantiene estado)
    //   ADD 10+20=30
    //   SUB 50-8=42
    //   NOPs de drenaje
    struct { uint8_t mA, mB, op, d1, d2, d3; const char *note; } prog[] = {
        {0,0,4, 0x00,0x00,0x00, "NOP warmup"},
        {0,1,0, 5,   3,   0,    "ADD 5+3=8"},
        {0,0,6, 5,   0,   0,    "STORE addr=5"},
        {0,0,5, 5,   0,   0,    "LOAD addr=5"},
        {0,0,4, 0xDE,0xAD,0xBE, "NOP mantiene"},
        {0,1,0, 10,  20,  0,    "ADD 10+20=30"},
        {0,1,1, 50,  8,   0,    "SUB 50-8=42"},
        {0,0,4, 0,   0,   0,    "NOP drenaje"},
        {0,0,4, 0,   0,   0,    "NOP drenaje"},
        {0,0,4, 0,   0,   0,    "NOP drenaje"},
    };
    int nprog = sizeof(prog)/sizeof(prog[0]);

    printf("Ciclo | cmd(mux/op)      | dout   | rdy z e | nota\n");
    printf("------+------------------+--------+---------+------------------\n");

    // Cada instruccion son 4 ciclos. Presentamos cmd estable 4 ciclos.
    for (int p = 0; p < nprog; p++) {
        uint8_t cmd = mk_cmd(prog[p].mA, prog[p].mB, prog[p].op);
        for (int k = 0; k < 4; k++) {
            cpu_model_step(cmd, prog[p].d1, prog[p].d2, prog[p].d3, 0,
                           &dh, &dl, &rdy, &z, &e);
            cyc++;
            uint16_t dout = ((uint16_t)dh << 8) | dl;
            printf("%5d | %s %d/%d       | 0x%04X | %d   %d %d | %s\n",
                   cyc, isa_name(prog[p].op), prog[p].mA, prog[p].mB,
                   dout, rdy, z, e,
                   (k==0 ? prog[p].note : ""));
        }
    }

    printf("\n=================================================================\n");
    printf("  Chequeos automaticos (en los cpu_rdy):\n");
    printf("=================================================================\n");

    // Re-corremos capturando SOLO los resultados en cpu_rdy para verificar
    cpu_model_reset();
    for (int i = 0; i < 3; i++)
        cpu_model_step(0,0,0,0,1,&dh,&dl,&rdy,&z,&e);

    int checks = 0, fails = 0;
    uint16_t results[64]; int nres = 0;

    for (int p = 0; p < nprog; p++) {
        uint8_t cmd = mk_cmd(prog[p].mA, prog[p].mB, prog[p].op);
        for (int k = 0; k < 4; k++) {
            cpu_model_step(cmd, prog[p].d1, prog[p].d2, prog[p].d3, 0,
                           &dh, &dl, &rdy, &z, &e);
            if (rdy) {
                uint16_t dout = ((uint16_t)dh << 8) | dl;
                results[nres++] = dout;
            }
        }
    }

    // Con la latencia del pipeline, los resultados aparecen desfasados.
    // Imprimimos la secuencia de resultados observados en cpu_rdy.
    printf("Secuencia de dout observada en cpu_rdy (%d pulsos):\n  ", nres);
    for (int i = 0; i < nres; i++) printf("0x%04X ", results[i]);
    printf("\n\n");

    // Verificacion clave: en algun punto debe aparecer 0x0008 (ADD 5+3),
    // que el STORE guarda y el LOAD recupera; y 0x001E (30), 0x002A (42).
    int found_08 = 0, found_1e = 0, found_2a = 0;
    for (int i = 0; i < nres; i++) {
        if (results[i] == 0x0008) found_08 = 1;
        if (results[i] == 0x001E) found_1e = 1;
        if (results[i] == 0x002A) found_2a = 1;
    }

    checks = 3;
    printf("  [%s] ADD 5+3=0x0008 aparece en la secuencia\n",
           found_08 ? "PASS" : "FAIL"); if(!found_08) fails++;
    printf("  [%s] ADD 10+20=0x001E aparece en la secuencia\n",
           found_1e ? "PASS" : "FAIL"); if(!found_1e) fails++;
    printf("  [%s] SUB 50-8=0x002A aparece en la secuencia\n",
           found_2a ? "PASS" : "FAIL"); if(!found_2a) fails++;

    printf("\n  Total: %d checks, %d fallos\n", checks, fails);
    printf("=================================================================\n");

    return fails ? 1 : 0;
}
