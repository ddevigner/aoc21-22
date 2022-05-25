; --------------------------------------------------------------------------- ;
; PRUEBA_02.asm                                                               ;
; Authors: Rael Clariana (760617) & Devid Dokash (780131).                    ;
; --------------------------------------------------------------------------- ;
; Riesgos cubiertos:
;   - Dependencia de datos: ADD-ADD (+1), ADD-SW (+1), ADD-LW (+2), 
;       ADD-BEQ (+2), ADD-LWFP (+1,+2), LWFP-ADDFP (+1), ADDFP-SWFP (+1).
;   - Riesgo ld-uso:: LW-ADD (+1).
;   - Riesgo de control: BEQ-BEQ, BEQ-ADD. 
;   - Riesgo estructural: ADDFP-SWFP.
; --------------------------------------------------------------------------- ;
; Cronograma:
;   (08010000) LW R1, 0(R0)     ; F D E M W
;   (08020004) LW R2, 4(R0)     ;   F D E M W
;   (08030008) LW R3, 8(R0)     ;     F D E M W
;   (04431800) ADD R3, R2, R3   ;       F D D E M W
;   (04431800) ADD R3, R2, R3   ;         F F D E M W
;   (04231800) ADD R3, R1, R3   ;             F D E M W
;   (0c03000c) SW R3, 12(R0)    ;               F D E M W
;   (08610000) LW R1, 0(R3)     ;                 F D E M W
;   (08620004) LW R2, 4(R3)     ;                   F D E M W
;   (04231800) ADD R3, R1, R3   ;                     F D E M W
;   (04442000) ADD R4, R2, R4   ;                       F D E M W
;   (10030001) BEQ R0, R3, 52   ;                         F D D E M W
;   - Si salto no tomado:       ;                           ↓   
;   (1000fffc) BEQ R0, R0, 36   ;                           F F D E M W
;   (04842000) ADD R4, R4, R4   ;                           |   F ↓ - - - -
;   (04231800) ADD R3, R1, R3 (Sig. Iter.)                  |     F F D E M W
;   ...                         ;                           |         . . .
;   - Si salto tomado:          ;                           ↓       
;   (1000fffc) BEQ R0, R0, 36   ;                           F ↓ - - - -
;   (04842000) ADD R4, R4, R4   ;                             F F D E M W 
;   (88800000) LWFP R0, 0(R4)   ;                                 F D E M W
;   (88810004) LWFP R1, 4(R4)   ;                                   F D E M W
;   (84010800) ADDFP R1, R0, R1 ;                                     F D D D E . E M W
;   (8c810008) SWFP R1, 8(R4)   ;                                       F F F D . D D D E M W
; --------------------------------------------------------------------------- ;
; [0, 1, ... , n-1, n]: valor en la iteracion i. 
.code
    LW R1, 0(R0)        ; R1 = @[0] = 4.
    LW R2, 4(R0)        ; R2 = @[1] = 8.
    LW R3, 8(R0)        ; R3 = @[2] = 12.
    ADD R3, R2, R3      ; R3 = R2 + R3 = 20.
    ADD R3, R2, R3      ; R3 = R2 + R3 = 28.
    ADD R3, R1, R3      ; R3 = R1 + R3 = 32.
    SW R3, 12(R0)       ; @[12] = 32.
    LW R1, 0(R3)        ; R1 = @[8] = -4.
    LW R2, 4(R3)        ; R1 = @[9] = 1.
loop:
    ADD R3, R1, R3      ; R3 -= 4 = [32,28..0]
    ADD R4, R2, R4      ; R4 += 1 = [1..8]
    BEQ R0, R3, 52      ; Si (R3 == 0) Salto a fp_code.
    BEQ R0, R0, 36      ; Salto a loop.
fp_code:
    ADD R4, R4, R4      ; R4 += R4 = 16
    LWFP R0, 0(R4)      ; R0 = @[4] = 2.56 (4023d70a)
    LWFP R1, 4(R4)      ; R0 = @[5] = 1.44 (3fb851ec)
    ADDFP R1, R0, R1    ; R1 += R0 = 4.0 (40800000)
    SWFP R1, 8(R4)      ; @[6] = 4.0 (40800000)
.end
; --------------------------------------------------------------------------- ;