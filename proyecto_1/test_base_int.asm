; --------------------------------------------------------------------------- ;
; TEST_BASE_INT.asm                                                           ;
; --------------------------------------------------------------------------- ;
; INSTRUCCIONES ARITMETICAS: ADD R3, R1, R2
;   op	    rs	    rt	    rd	    shamt	funct
;   000001	00001	00010  	00011  	00000	000000  
;
; INSTRUCCIONES LW, LWFP, SW, SWFP, BEQ: LW  R1, 0(R0)  dir 0
;   op	    rs	    rt		inm
;   000010 	00000	00001 	0000000000000000 		
; --------------------------------------------------------------------------- ;
; El valor inicial de los registros es 0 (partimos de un reset). Es un bucle 
; infinito. Codigo pensado para funcionar en un procesador con saltos 
; 1-retardado que no detecta los riesgos de datos.
; 
; Queremos saltar a la posicion C, el procesador calcula la direccion haciendo 
; PC+4+ 4*ext(inm) si estamos en la 36 y queremos ir a la 12 hay que restar 24. 
; 4*ext(inm)= -24. inm = -6 = 0xFFFA. El procesador en beq calculara 
; 0xfffa*4+001C= 0xC.
; --------------------------------------------------------------------------- ;
; CRONOGRAMA
;   (08010000) LW  R1, 0(R0)   ; F D E M W
;   (08020004) LW  R2, 4(R0)   ;   F D E M W
;   (00000000) nop             ;     F D E M W
;   (00000000) nop             ;       F D E M W
;   (04221800) ADD R3, R1, R2  ;         F D E M W
;   (00000000) nop             ;           F D E M W
;   (00000000) nop             ;             F D E M W
;   (0C030008) SW  R3, 8(R0)   ;               F D E M W 
;   (1000FFFa) beq r0, r0, inm ;                 F D E M W
;   (00000000) nop             ;                   F D E M W
; --------------------------------------------------------------------------- ;
.code
    LW  R1, 0(R0)   ; R1 = 8
    LW  R2, 4(R0)   ; R2 = 12
    nop             ;
inm:
    nop             ;
    ADD R3, R1, R2  ; R3 = 20
    nop             ;
    nop             ;
    SW  R3, 8(R0)   ; @[2] = 0x14 
    beq r0, r0, inm ; Salto a inm.
    nop             ;
.end
; --------------------------------------------------------------------------- ;