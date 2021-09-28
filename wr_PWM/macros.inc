
banco0	macro
	bcf	STATUS,RP0
	endm

banco1	macro
	bsf	STATUS,RP0
	endm

;macro: salta parr endx, se regx = literal
je_rl	macro	regx, lit, endx
	movlw	lit
	xorwf	regx,W
	btfsc	STATUS,Z
	goto	endx
	endm

;macro: captura BCD em regx
bcd_k	macro	regx
	call	teclado
	btfss	fpress,0
	goto	$-2
	call	valida_BCD
	btfss	fpress,0
	goto	$ - 5
	movfw	code_tecla
	movwf	regx
	endm
