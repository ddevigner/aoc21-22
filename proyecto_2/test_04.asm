; --------------------------------------------------------------------------- ;
; TEST_04.asm                                                                 ;
; Authors: Rael Clariana (760617) & Devid Dokash (780131).                    ;
; Description: codigo simple para probar el funcionamiento del mips con la    ;
;   memoria cache.                                                            ;
; Usage: utilizar la memoria de instrucciones y datos puestos en el fichero   ;
;   tests_rams.txt.                                                           ;
; --------------------------------------------------------------------------- ;
.code
    LW R0,0(R0)    ; R0 = @[0] = FE;
    LW R1,0(R0)    ; R1 = @[254] = 1;
    ADD R1,R1,R1   ; R1 = R1 + R1 = 2;
    ADD R1,R1,R1   ; R1 = R1 + R1 = 4;
    SW R0,0(R1)    ; @[4] = FE;
    ADD R1,R1,R1   ; R1 = R1 + R1 = 8;
    LW R2,0(R0)    ; R2 = 1
    ADD R0,R2,R0   ; R0 = FF
    NOP
    SW R0,0(R1)    ; @[8] = FF
.end
; --------------------------------------------------------------------------- ;