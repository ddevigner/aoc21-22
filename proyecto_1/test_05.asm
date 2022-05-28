; --------------------------------------------------------------------------- ;
; File: PRUEBA_05.asm                                                         ;
; Authors: Rael Clariana (760617) & Devid Dokash (780131).                    ;
; --------------------------------------------------------------------------- ;
; Riesgos cubiertos:
;   - Dependencia de datos: LWFP-ADDFP.
;   - Dependencia de datos: ADDFP-SWFP.
;   - Riesgo estructural: ADDFP-LWSP.
;   - Riesgo estructural: ADDFP-SWFP.
;   - Riesgo estructural: ADDFP-ADDFP.
; --------------------------------------------------------------------------- ;
;   (88210000) LWFP R1,0(R1)    ; F D E M W 
;   (84211000) ADDFP R2,R1,R1   ;   F D D D E . M W 
;   (8c220004) SWFP R2,4(R1)    ;     F F F D . D D E M W 
;   (84221800) ADDFP R3,R1,R2   ;           F . F F D E . M W
;   (88210004) LWFP R1,4(R1)    ;                   F D . E M W
;   (84231000) ADDFP R2,R1,R3   ;                     F . D D D E . M W
;   (8c210008) SWFP R1,8(R1)    ;                         F F F D . E M W
;   (8821000c) LWFP R1,12(R1)   ;                               F . D E M W
;   (84221800) ADDFP R3,R1,R2   ;                                   F D D D E . M W
;   (84231800) ADDFP R3,R1,R3   ;                                     F F F D . D D E . M W
; --------------------------------------------------------------------------- ;
.code 
    LWFP R1,0(R1)   ; FP1 = @[0] = 2.5 (40200000)
    ADDFP R2,R1,R1  ; FP2 = FP1 + FP1 = 5.0 (40a00000)
    SWFP R2,4(R1)   ; @[4] = 5.0 (40a00000)
    ADDFP R3,R1,R2  ; FP3 = FP1 + FP2 = 7.5 (40f00000)
    LWFP R1,4(R1)   ; FP1 = @[4] = 5.0 (40a00000)
    ADDFP R2,R1,R3  ; FP2 = FP1 + FP3 = 12.5 (41480000)
    SWFP R1,8(R1)   ; @[8] = 5.0 (40a00000)
    LWFP R1,12(R1)  ; FP1 = @[12] = -12.5 (c1480000)
    ADDFP R3,R1,R2  ; FP3 = FP1 + FP2 = -0.0 (80000000)
    ADDFP R3,R1,R3  ; FP3 = FP1 + FP3 = -12.5 (c1480000)
.end
; --------------------------------------------------------------------------- ;