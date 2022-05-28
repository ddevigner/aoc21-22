; --------------------------------------------------------------------------- ;
; File: PRUEBA_03.asm                                                         ;
; Authors: Rael Clariana (760617) & Devid Dokash (780131).                    ;
; --------------------------------------------------------------------------- ;
; Riesgos cubiertos:
;   - Riesgo ld-uso: LW-NOP (ignorada).
;   - Dependencia de datos: ADD-NOP (sin riesgo).
;   - Dependencia de datos: LWFP-ADDFP (+2).
;   - Riesgo estructural: ADDFP-BEQ.
;   - Riesgo de control: BEQ-ADD, BEQ-SWFP
;   - Dependencia de datos: ADD-BEQ (+2).
;   - Dependencia de datos: ADDFP-SWFP (+2).
; --------------------------------------------------------------------------- ;  
; Cronograma:
;   (08000000) LW R0,0(R0)     ; F D E M W
;   (8805fff0) LWFP R5,-16(R0) ;   F D D E M W
;   (0823000c) LW R3,12(R1)    ;     F F D E M W
;   (08220008) LW R2,8(R1)     ;         F D E M W
;   (08210004) LW R1,4(R1)     ;           F D E M W
;   (00000000) nop             ;             F D E M W
;   (88010000) LWFP R1,0(R0)   ;               F D E M W
;   (88020004) LWFP R2,4(R0)   ;                 F D E M W
;   (04221000) ADD R2,R1,R2    ;                   F D E M W
;   (84221800) ADDFP R3,R1,R2  ;                     F D D E . M W
;   (84642000) ADDFP R4,R3,R4  ;                       F F D . D D E . E M W
;   (10460002) BEQ R2,R6,60    ;                           F . F F D . D E M W
;   - Si salto no tomado:                                          ↓
;   (04030000) ADD R0,R0,R3    ;                                   F . F D E M W
;   (00000000) nop             ;                                   |     F D E M W
;   (1000fff6) BEQ R0,R0,24    ;                                   |       F D D E M W
;   (04852800) ADD R5, R4, R5  ;                                   |           F ↓ - - - -
;   (8c040008) LWFP R1,0(R0) (Sig Iter.)                           |             F F D E M W
;   ...                                                            |                 . . .
;   - Si salto tomado:                                             ↓
;   (04030000) ADD R0,R0,R3    ;                                   F . ↓ - - - -
;   (04852800) ADDFP R5,R4,R5    ;                                     F F D E M W
;   (8c040008) SWFP R5,8(R0)   ;                                           F D D D E M W
; --------------------------------------------------------------------------- ;
.code
    LW R0,0(R0)     ; R0 = @[0] = 32
    LWFP R5,-16(R0) ; R5 = @[4] = -1.618033989 (bfcf1bbd)
    LW R3,12(R1)    ; R3 = @[3] = 8 
    LW R2,8(R1)     ; R2 = @[2] = 2
    LW R1,4(R1)     ; R1 = @[1] = -1
    nop             ; No hay riesgo. UD lo ignora.
loop:
    LWFP R1,0(R0)   ; FP1 = @[8,10] = [5.64 (40b47ae1), 1.23 (3f9d70a4)]
    LWFP R2,4(R0)   ; FP2 = @[9,11] = [2.18 (400b851f), 0.95 (3f733333)]
    ADD R2,R1,R2    ; R2 += R1 = [1,0]
    ADDFP R3,R1,R2  ; FP3 = FP1 + FP2 = [7.82 (40fa3d71), 2.18 (400b851f)]
    ADDFP R4,R3,R4  ; FP4 += FP3 = [7.82 (40fa3d71), 10.0 (41200000)]
    BEQ R2,R6,60    ; Si (R2 == 0) Salto a store.
    ADD R0,R0,R3    ; R0 = R0 + R3 = R0 + 8.
    nop             ; Sin riesgo.
    BEQ R0,R0,24    ; Salto a loop.
store:
    ADDFP R5, R4, R5  ; R5 += R4 = 8.381966011 (41061c88)
    SWFP R5,8(R0)   ; @[48] = 8.381966011 (41061c88)
.end
; --------------------------------------------------------------------------- ;