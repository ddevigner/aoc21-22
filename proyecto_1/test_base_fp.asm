; --------------------------------------------------------------------------- ;
; TEST_BASE_INT.asm                                                           ;
; --------------------------------------------------------------------------- ;
; Memoria: [X"3e4ccccd", 0, 0, 0, 0, 0, 0, 0, 0...]  En M(4) aparecerá un 0,4.
; Para las traducciones fp/HEX: 
;   - https://www.h-schmidt.net/FloatConverter/IEEE754.html
; --------------------------------------------------------------------------- ;
; Cronograma:
;    (88010000) LWFP R1, 0(R0)      ; F D E M W
;    (00000000) nop                 ;   F D E M W
;    (00000000) nop                 ;     F D E M W
;    (84211000) ADDFP R2, R1, R1    ;       F D E M W
;    (00000000) nop                 ;         F D E M W
;    (00000000) nop                 ;           F D E M W
;    (8c020004) SWFP R2, 4(R0)      ;             F D E M W
;    (00000000) nop                 ;               F D E M W
; --------------------------------------------------------------------------- ;
.code
    LWFP R1, 0(R0)        ; FP1 = 0.2 (3e4ccccd).
    nop                   ;
    nop                   ;
    ADDFP R2, R1, R1      ; FP2 = FP1 + FP1 = 0.4 (3ecccccd-3ecccccf)
    nop                   ;
    nop                   ;
    SWFP R2, 4(R0)        ; @[1] = 0.40000007 (3ecccccd-3ecccccf)
    nop                   ;
.end
; --------------------------------------------------------------------------- ;














