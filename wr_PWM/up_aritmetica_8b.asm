;======================================================
; Multiplicação de operandos de 8 bits
; Rpta2:Rpta1 = Mulcnd * Mulcdr
;======================================================
	cblock  
		Op1_H,Op1_L, Op2_H, Op2_L 
		conta_m8, Rpta2, Rpta1
	endc
Mulcnd	equ	Op1_L
Mulcdr	equ	Op2_L

Multi8:
	clrf	Rpta1
	clrf	Rpta2
	movlw	.8
	movwf	conta_m8
	movfw	Mulcnd
	bcf		STATUS, C
lazo_m8:
	rrf		Mulcdr, F
	btfsc	STATUS, C
	addwf	Rpta2, F
	rrf		Rpta2, F
	rrf		Rpta1, F
	decfsz	conta_m8, F
	goto	lazo_m8
	return

;======================================================
; Divisão de operandos de 8 bits
; Dividendo = Quociente * Divisor + Resto 
;======================================================
Dividendo	equ	Op1_L
Divisor		equ	Op2_L
Quociente	equ	Divisor
Resto		equ Dividendo

Divide8:
	movfw	Divisor
	clrf	Quociente
loopd
	subwf	Resto, F
	btfss	STATUS, C
	goto	fimd
	incf	Quociente, F
	goto	loopd
fimd:
	addwf	Resto, F
	return
