# Arquitectura y organizacion de computadores 2
## [Proyecto 1](https://github.com/ddevigner/aoc21-22/tree/main/proyecto_1)
Implementación y ampliacion de un procesador MIPS segmentado a 5 ciclos de las siguientes características:
  - Instruction-set original: ADD, BEQ, LW, SW y NOP.
  - Implementación de ruta de datos para operaciones en coma flotante y ampliación del instruction-set: ADDFP, LWFP, SWFP.
  - Implementación de una unidad de anticipación para dependencia de datos.
  - Implementación de una unidad de detección para la detección de riesgos:
    - ld-uso, beq-uso, riesgos de control o riesgos estructurales.

## [Fast-MIPS](https://github.com/ddevigner/aoc2-21-22/tree/main/fast-mips)
Programa que traduce un programa ensamblador MIPS (Proyecto 1), codifica las instrucciones y las parsea en formato RAM de VHDL.
- Ubicado en la carpeta [fast-mips/dist/](https://github.com/ddevigner/aoc2-21-22/tree/main/fast-mips/dist)[fast-mips.exe](https://github.com/ddevigner/aoc2-21-22/blob/main/fast-mips/dist/fast-mips.exe)
- Utilizacion
```bash
  fast-mips <file>
```
