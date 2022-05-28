; --------------------------------------------------------------------------- ;
; File: PRUEBA_04.asm                                                         ;
; Authors: Rael Clariana (760617) & Devid Dokash (780131).                    ;
; --------------------------------------------------------------------------- ;
; Riesgos cubiertos:
;   - Riesgo ld-uso:: LW-ADD.
;   - Riesgo ld-uso:: LW-SW.
;   - Riesgo ld-uso:: LW-BEQ.
;   - Dependencia de datos: ADD-ADD (+1).
;   - Dependencia de datos: ADD-LWFP (+1).
;   - Dependencia de datos: LWFP-ADDFP (+1).
;   - Riesgo estructural: ADDFP-ADD.
;   - Dependencia de datos: ADDFP-SWFP (+2).
; --------------------------------------------------------------------------- ;
; CRONOGRAMA:	
;   (08010000) LW R1,0(R0)      ; F D E M W
;   (04211000) ADD R2,R1,R1     ;   F D D E M W
;   (08020000) LW R2,0(R0)	    ;     F F D E M W
;   (0c430000) SW R3,0(R2)	    ;         F D D E M W
;   (08020004) LW R2 4(R0)		;           F F D E M W
;   (1022fffa) BEQ R1,R2,0		;               F D D D E M W
;   (08040000) LW R4,0(R0)		;                 F F F D E M W
;   (04842000) ADD R4,R4,R4		; 	                    F D D E M W
;   (04842000) ADD R4,R4,R4     ;		                  F F D E M W
;   (88800004) LWFP R0,4(R4)    ;			                  F D E M W 
;   (84000000) ADDFP R0,R0,R0   ;			                    F D D D E . M W
;   (04842000) ADD R4,R4,R4		;			                      F F F D . E M W
;   (8c800004) SWFP R0,4(R4)	;				                        F . D D E M W
; --------------------------------------------------------------------------- ;
.code
    LW R1, 0(R0) 	    ; R0 = 0, R1 = @[0] = 4
    ADD R2, R1, R1 	    ; R2 = R1 + R1 = 8
    LW R2, 0(R0)	    ; R0 = 0, R2 = @[0] = 4
    SW R3,0(R2)	        ; R2 = 4, R3 = 0, @[1] = 0
    LW R2, 4(R0)	    ; R0 = 0, R2 = @[1] = 0.
    BEQ R1, R2, 0	    ; R1 = 4, R2 = 0. Si R1 == R2. PC = 0, si no PC = PC+4
    LW R4,0(R0) 	    ; R0 = 0, R4 = @[0] = 4
    ADD R4, R4, R4      ; R4 = R4 + R4 = 8
    ADD R4, R4, R4      ; R4 = R4 + R4 = 16
    LWFP R0, 4(R4)      ; FP0 = @[5] = 3,14159265358979323846 (40490fdb)
    ADDFP R0, R0, R0    ; FP0 = FP0 + FP0 = 6,28318530717958647692 (40c90fdb)
    ADD R4, R4, R4      ; R4 = R4 + R4 = 32
    SWFP R0, 4(R4)      ; @[9] = 6,28318530717958647692 (40c90fdb)
.end
; --------------------------------------------------------------------------- ;