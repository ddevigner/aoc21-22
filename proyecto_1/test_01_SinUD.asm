; --------------------------------------------------------------------------- ;
; test_01_SinUD.asm                                                                 ;
; Authors: Rael Clariana (760617) & Devid Dokash (780131).                    ;
; --------------------------------------------------------------------------- ;
; Riesgos cubiertos:
;   - Riesgo ld-uso: LW-LW, LW-ADD.
;   - Dependencia de datos: ADD-SW (+1), ADD-BEQ (+1,+2).
;   - Riesgo de control: BEQ-BEQ, BEQ-SW.
; --------------------------------------------------------------------------- ;
; Cronograma:
;   (08010000) LW R1, 0(R0)   ; F D E M W
;   (00000000) nop            ;   F D E M W
;   (08220000) LW R2, 0(R1)   ;     F D E M W
;   (00000000) nop            ;       F D E M W
;   (0843ffec) LW R3, -20(R2) ;         F D E M W
;   (0804000c) LW R4, 12(R0)  ;           F D E M W
;   (00000000) nop            ;             F D E M W
;   (04852800) ADD R5, R4, R5 ;               F D E M W
;   (0c05000c) SW R5, 12(R0)  ;                 F D E M W
;   (04010000) ADD R0, R0, R1 ;                   F D E M W
;   (00000000) nop            ;                     F D E M W
;   (00000000) nop            ;                       F D E M W
;   (10030001) BEQ R0, R3, 56 ;                         F D E M W
;   - Si salto no tomado:     ;                           ↓   
;   (1000fffa) BEQ R0, R0, 18 ;                           F D E M W                    
;   (04452800) ADD R5, R2, R5 ;                           |     F ↓ - - - -
;   (0804000c) LW R4, 12(R0) (Sig. Iter.)                 |       F F D E M W
;   ...                       ;                           |           . . .
;   - Si salto tomado:        ;                           ↓
;   (1000fffa) BEQ R0, R0, 12 ;                           F ↓ - - - -
;   (04452800) ADD R5, R2, R5 ;                             F F D E M W
;   (0c450000) SW R5, 0(R2)   ;                                 F D E M W
; --------------------------------------------------------------------------- ;
; [0, 1, ... , n-1, n]: valor en la iteracion i. 
.code
    LW R1, 0(R0)    ; R1 = @[0] = 4.
    nop
    LW R2, 0(R1)    ; R2 = @[1] = 28.
    nop
    LW R3, -20(R2)  ; R3 = @[2] = 16.
loop:
    LW R4, 12(R0)   ; R4 = @[3,4,5,6] = [2,3,4,5].
    nop
    ADD R5, R4, R5  ; R5 += R4 = [2,5,9,14].
    SW R5, 12(R0)   ; @[3,4,5,6] = [2,5,9,14].
    ADD R0, R0, R1  ; R0 += R1 = [4,8,12,16]
    nop
    nop
    BEQ R0, R3, 56  ; Si (R0 == 16) Salto a store.
    BEQ R0, R0, 18  ; Salto a loop.
store:
    ADD R5, R2, R5  ; R5 += R2 = 42
    SW R5, 0(R2)    ; @[7] = 14.
.end
; --------------------------------------------------------------------------- ;