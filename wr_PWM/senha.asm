numero_senha:	
	movlw	0x39
	movwf	dig1 ;coloca numero 9 como primeiro digito da senha
	movlw	0x37
	movwf	dig2 ;coloca numero 7 como primeiro digito da senha
	movlw	0x34
	movwf	dig1 ;coloca numero 4 como primeiro digito da senha
	return
;======================================
;--VERIFICA SENHA DIGITADA NO TECLADO--
;======================================
teclado_1:
	movf	tecla1,W
	xorlw	0x39
	btfsc	STATUS,Z
	goto	teclado_2
	goto	errado1

teclado_2:
	movf	tecla2,W
	xorlw	0x37
	btfsc	STATUS,Z
	goto	teclado_3
	goto	errado1

teclado_3:
	movf	tecla3,W
	xorlw	0x34
	btfsc	STATUS,Z
	goto	certo1
	goto	errado1
;==================================
;VERIFICA BLUETOOTH
;==================================
blue_1:
	movf	dado_rx1,W
	xorlw	'9'
	btfsc	STATUS,Z
	goto	blue_2
	goto	errado1
blue_2:
	movf	dado_rx2,W
	xorlw	'7'
	btfsc	STATUS,Z
	goto	blue_3
	goto	errado1
blue_3:
	movf	dado_rx3,W
	xorlw	'4'
	btfsc	STATUS,Z
	goto	certo1
	goto	errado1
;--------------------------------------
;------------SENHA CORRETA-------------
;--------------------------------------
certo1:
	BCF STATUS, RP0 ;SELECT BANK 00
	bcf	PORTC,3	;DESLIGA LED SENHA ERRADA
	bcf	PORTC,4	;DESLIGA LED ENSIRA SENHA
	bsf	PORTC,5	;LIGA LED SENHA CORRETA
	call	msg_senha_correta
;delay de 3 segundos
	call	delay_1s
	call	delay_1s
	call	delay_1s
	bcf		PORTC,5
;limpa teclas
	clrf tecla1
	clrf tecla2
	clrf tecla3
;limpa bluetooth
	clrf dado_rx1
	clrf dado_rx2
	clrf dado_rx3
;--------------------------------------
;--------CHAMA PRA ABRIR PORTAO--------
;--------------------------------------
	call	PROGRAMA_PORTAO

;--------------------------------------
;------------SENHA ERRADA--------------
;--------------------------------------
errado1:
	BCF STATUS, RP0 ;SELECT BANK 00
	bsf	PORTC,3	;LIGA LED SENHA ERRADA
	bcf	PORTC,4	;DESLIGA LED ENSIRA SENHA
	bcf	PORTC,5	;DESLIGA LED SENHA CORRETA
	call	msg_senha_errada ;manda mensagem errada pro bluetooth
;delay de 3 segundos
	call	delay_1s
	call	delay_1s
	call	delay_1s
;limpa teclas
	clrf tecla1
	clrf tecla2
	clrf tecla3
;limpa bluetooth
	clrf dado_rx1
	clrf dado_rx2
	clrf dado_rx3

	call	setup