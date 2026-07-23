# memory — Test Plan

**Bloque:** `memory` (8 palabras de 2*WIDTH bits, write sincrono / read asincrono)
**Documento de referencia:** RTL and Verification Lab — Synopsys, Octubre 2025
**Verificado bajo:** `academy2026-uvm-lab / uvm_tb / memory_verification`
**Herramientas:** VCS V-2023.12-SP2-8, UVM-1.2, URG, Verdi
**Version del testplan:** 2.0

## 1. Alcance

Verificacion completa de la memoria en dos fases:

- **Fase 1 (standalone, v1.0)**: 11 checks, 6 escenarios. Firmada.
- **Fase 2 (UVM, v2.0)**: env UVM con reference model (array asociativo),
  coverage de address space, patrones write-then-read por direccion.

**Nota**: la memoria NO tiene reset per spec. Los reads a direcciones no
escritas devuelven valores no definidos y se filtran en el scoreboard.

## 2. Features del DUT

| ID          | Feature                                        | Referencia spec           |
| ----------- | ---------------------------------------------- | ------------------------- |
| FEAT-MEM-01 | Memoria de 8 palabras                          | *"2*WIDTH per 8 words memory"* |
| FEAT-MEM-02 | Ancho de palabra = 2*WIDTH bits                | Idem                      |
| FEAT-MEM-03 | Escritura sincrona (posedge clk)               | *"synchronous for writing data"* |
| FEAT-MEM-04 | Lectura asincrona (combinacional)              | *"asynchronous for reading data"* |
| FEAT-MEM-05 | Enable de escritura (memoryWrite)              | *"a pin to enable the writing"* |
| FEAT-MEM-06 | Enable de lectura (memoryRead)                 | *"a pin to enable the reading"* |
| FEAT-MEM-07 | Sin reset                                       | Convencion del proyecto   |

## 3. Matriz de requerimientos

### 3.1 Requerimientos funcionales

| ID          | Descripcion                                                       | Metodo | Fase 1 | Fase 2 | Status |
| ----------- | ----------------------------------------------------------------- | ------ | ------ | ------ | ------ |
| REQ-MEM-01  | Write en posedge clk cuando memoryWrite=1 captura data en addr    | DIR + RND + SCB + COV | ESC 1, 2 | `cg_memory.cx_addr_wr_en.[*][high]` | **PASS** |
| REQ-MEM-02  | Read asincrono: data_out = mem[addr] sin esperar clk              | DIR + RND + SCB + COV | ESC 5 | `cg_memory.cx_addr_rd_en.[*][high]` | **PASS** |
| REQ-MEM-03  | memoryWrite=0 no modifica memoria (retencion)                     | DIR + CHK | ESC 3 | Filtrado por written_mask | **PASS** |
| REQ-MEM-04  | memoryRead=0 fuerza data_out=0 (gating)                           | DIR + CHK + SCB | ESC 4 | `num_gating_checked` | **PASS** |
| REQ-MEM-05  | 8 palabras direccionables (0-7)                                   | DIR + COV | ESC 2 | `cg_memory.cp_addr` (8 bins) | **PASS** |
| REQ-MEM-06  | Ancho de datos 2*WIDTH bits                                        | STR    | Compile | Toggle 16-bit 100% | **PASS** |
| REQ-MEM-07  | Interfaz cumple spec mandatorio                                    | REVIEW | Diff con spec | Diff | **PASS** |

### 3.2 Requerimientos de consistencia y acceso

| ID          | Descripcion                                                    | Metodo | Fase 1 | Fase 2 | Status |
| ----------- | -------------------------------------------------------------- | ------ | ------ | ------ | ------ |
| REQ-CON-01  | Overwrite: escritura en misma addr sobreescribe valor previo   | DIR + CHK | ESC 6 | Scoreboard | **PASS** |
| REQ-CON-02  | Direcciones altas (>7) se enmascaran a los 3 LSB               | REVIEW | Diseno | Diseno | **PASS** |
| REQ-ACC-01  | Write-then-read en la misma direccion (cada una de las 8)      | COV    | N/A    | `cg_transitions.cp_write_read_addr` (8 bins) | **PASS** |
| REQ-ACC-02  | Idle, read-only, write-only, write+read simultaneos            | COV    | N/A    | `cg_access_patterns.cp_action` (4 bins) | **PASS** |
| REQ-ACC-03  | Cada direccion con memoryWrite=0 y memoryWrite=1               | COV    | N/A    | `cg_memory.cx_addr_wr_en` (16 bins) | **PASS** |
| REQ-ACC-04  | Cada direccion con memoryRead=0 y memoryRead=1                 | COV    | N/A    | `cg_memory.cx_addr_rd_en` (16 bins) | **PASS** |

## 4. Fase 1 — Standalone TB

Ver v1.0 del testplan. 11/11 PASS.

## 5. Fase 2 — Env UVM

### 5.1 Reference model

Array asociativo `bit [15:0] model_mem [0:7]` mas mascara `written_mask`
para filtrar reads a direcciones no escritas (uninit).

Verificaciones del scoreboard por transaccion:
1. Si `memoryRead=0`: verifica `memoryOutData=0` (gating)
2. Si `memoryRead=1` y direccion escrita previamente: compara con `model_mem`
3. Si `memoryRead=1` y direccion no escrita: skip (contador `num_reads_skipped`)
4. Si `memoryWrite=1`: actualiza `model_mem[addr]` y `written_mask[addr]`

### 5.2 Functional coverage

**`cg_memory`**:
- `cp_addr` (8 bins individuales por direccion)
- `cp_wr_en`, `cp_rd_en` (2 bins c/u)
- `cp_write_data` (5 rangos 16-bit, `iff memoryWrite`)
- `cp_read_data` (5 rangos 16-bit, `iff memoryRead`)
- `cx_addr_wr_en` (16 bins): cada direccion con wr_en=0 y wr_en=1
- `cx_addr_rd_en` (16 bins): cada direccion con rd_en=0 y rd_en=1

**`cg_access_patterns`**:
- `cp_action` (4 bins): idle/read_only/write_only/write_read

**`cg_transitions`**:
- `cp_write_read_addr` (8 bins): patron write-then-read por cada direccion

### 5.3 Structural coverage

Filtrado a `memory` + `testbench`. Score >= 99% en `testbench`.

### 5.4 Waivers

- Watchdog `uvm_fatal` en testbench envuelto en pragma.

### 5.5 Sequences

| Sequence                | Proposito                                          | # tx |
| ----------------------- | -------------------------------------------------- | ---- |
| `memory_seq_rand`       | Aleatorias con action dist balanceada              | 1000 |
| `memory_write_all_seq`  | Popula las 8 direcciones antes de reads aleatorios | 8    |
| `memory_directed_seq`   | Write-then-read por dir, overwrites, edge cases    | ~30  |
| `memory_coverage_seq`   | Closure exhaustivo (rangos, crosses, transiciones) | ~80  |

### 5.6 Tests

| Test                     | Proposito                                    |
| ------------------------ | -------------------------------------------- |
| `memory_random_test`     | write_all + 1000 tx aleatorias               |
| `memory_directed_test`   | Casos borde                                  |
| `memory_coverage_test`   | Closure de covergroups                       |
| `memory_regression_test` | Encadena los 4                                |

## 6. Criterios de aceptacion (Fase 2)

- [ ] Scoreboard: 0 errores
- [ ] Functional coverage: 100% en los 3 covergroups
- [ ] Structural coverage: score `testbench` >= 99%
- [ ] Todos los REQ en PASS

### Comando de sign-off

```bash
cd sim/
make clean
make regress
```

## 7. Referencias

- **Spec:** RTL and Verification Lab — Synopsys, Octubre 2025
- **RTL del DUT:** `rtl/memory.sv`
- **Standalone TB (Fase 1):** `sim/tb_memory.sv`
- **Env UVM (Fase 2):** `tb/memory_*.sv`
