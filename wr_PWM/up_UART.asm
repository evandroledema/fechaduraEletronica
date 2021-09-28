;=============================================
;Bibliotecas para comunicação serial USART
;PIC 16F877A		Cristal = 16 ou 20 MHz
;=============================================
	
;=============================================
;Configuração do USART
;=============================================
iniciar_UART
	bcf		RCSTA,CREN	;limpa bit de erro por OVERRUN
	nop
	bsf		RCSTA,CREN

	bsf		STATUS, RP0
	movlw	B'00100000'	;Tx assíncrona, 8bits, Tx on, BRGH=0
	movwf	TXSTA
	movlw	k_spbrg		;Vtx=9600 baudios
	movwf	SPBRG
	bcf		STATUS, RP0

	movlw	B'10010000'	;hab. porta serial, 8bits, hab. Rx cont.
	movwf	RCSTA		
	clrf	TXREG		;limpar buffers da porta serial
	clrf	RCREG
	return

;=============================================
; Envia caracter - RS232 - hacia la PC
; 1°) Carregar Wreg = ASCII do caracter
; 2°) call  UART_TxCar
;=============================================
TxCarUART
TxCmdUART
	bsf		STATUS, RP0
TxCar1
	btfss	TXSTA,TRMT	;verifica estado da Tx antes de enviar
	goto	TxCar1		;se ainda não esta pronto, intentar de novo
	bcf		STATUS, RP0
	movwf	TXREG		;transmitir o dado
	return

;=============================================
; Sub-rotina para Receber caracter 
; 1°) call  UART_RxCar
; 2°) Pegar o caracter do Wreg
;=============================================
;-------------CARACTERES DA SENHA-------------
;=============================================
RxCarUART1 ; primeiro caractere
	bcf		flag_rx1,0	;limpa flag de recepção
	movlw	B'00100000' ;0x06 = máscara de bits não desejados
	andwf	RCSTA,W		;para verificar bits de erro
	btfss	STATUS,Z
	goto	RxError		;existe algum flag de erro = 1
	btfss	PIR1,RCIF	;verifica se dado está pronto
	return				;retorna com flag regrx<0> = 0 
	movf	RCREG,W		;le o conteúdo do Reg. => Wreg
	bsf		flag_rx1,0	;regrx<0>  = 1, indica existe dado recebido
	return
;------------------------
RxCarUART2 ; segundo caractere
	bcf		flag_rx2,0	;limpa flag de recepção
	movlw	B'00100000' ;0x06 = máscara de bits não desejados
	andwf	RCSTA,W		;para verificar bits de erro
	btfss	STATUS,Z
	goto	RxError		;existe algum flag de erro = 1
	btfss	PIR1,RCIF	;verifica se dado está pronto
	return				;retorna com flag regrx<0> = 0 
	movf	RCREG,W		;le o conteúdo do Reg. => Wreg
	bsf		flag_rx2,0	;regrx<0>  = 1, indica existe dado recebido
	return
;------------------------
RxCarUART3 ; primeiro caractere
	bcf		flag_rx3,0	;limpa flag de recepção
	movlw	B'00100000' ;0x06 = máscara de bits não desejados
	andwf	RCSTA,W		;para verificar bits de erro
	btfss	STATUS,Z
	goto	RxError		;existe algum flag de erro = 1
	btfss	PIR1,RCIF	;verifica se dado está pronto
	return				;retorna com flag regrx<0> = 0 
	movf	RCREG,W		;le o conteúdo do Reg. => Wreg
	bsf		flag_rx3,0	;regrx<0>  = 1, indica existe dado recebido
	return

;=============================================
;-------ABRIR/FECHAR/PARA MOTOR INICIAL-------
;=============================================
RxCarUART4: 
	bcf		flag_rx4,0	;limpa flag de recepção
	movlw	B'00100000' ;0x06 = máscara de bits não desejados
	andwf	RCSTA,W		;para verificar bits de erro
	btfss	STATUS,Z
	goto	RxError		;existe algum flag de erro = 1
	;call	delay_10ms
	btfss	PIR1,RCIF	;verifica se dado está pronto
	call	end_function ;retorna com flag regrx<0> = 0
	movf	RCREG,W		;le o conteúdo do Reg. => Wreg
	bsf		flag_rx4,0	;regrx<0>  = 1, indica existe dado recebido
	return

verifica_m1:	;Se O enviado atraves do bluetooth
	movf	dado_rx4,W
	xorlw	'O'	
	btfsc	STATUS,Z
	goto	comando_m1_O ;Desvia para abrir portão

verifica_m2:	;Se C enviado atraves do bluetooth
	movf	dado_rx4,W
	xorlw	'C'
	btfsc	STATUS,Z
	goto	comando_m1_C ;Desvia para fechar portão
	goto	caracter_errado

;===================================================
;CRIAR FUNÇÃO NO MAIN SÓ PRA DESLIGAR PORTÃO
;===================================================
;verifica_m3:	;Se S enviado atraves do bluetooth
;	movf	dado_rx4,W
;	xorlw	'S'
;	btfsc	STATUS,Z
;	goto	comando_m1_S ;Desvia para parar portão
	goto	caracter_errado

comando_m1_O:
	clrf	vb1
	clrf	dado_rx4
	call	abrir_fechar
	call	relay_desligado
	
comando_m1_C:
	clrf	vb1
	clrf	dado_rx4
	call	abrir_fechar
	call	relay_ligado

caracter_errado:
	clrf	vb1
	clrf	dado_rx4
	call	abrir_fechar
	call	loop_1

;=============================================
;-----ABRIR/FECHAR/PARAR PORTÃO FECHANDO------
;=============================================
RxCarUART5: ;primeiro caractere
	bcf		flag_rx5,0	;limpa flag de recepção
	movlw	B'00100000' ;0x06 = máscara de bits não desejados
	andwf	RCSTA,W		;para verificar bits de erro
	btfss	STATUS,Z
	goto	RxError		;existe algum flag de erro = 1
	;call	delay_10ms
	btfss	PIR1,RCIF	;verifica se dado está pronto
	call	lops_s333	;retorna com flag regrx<0> = 0
	movf	RCREG,W		;le o conteúdo do Reg. => Wreg
	bsf		flag_rx5,0	;regrx<0>  = 1, indica existe dado recebido
	return

verifica_blue_fechando:
	movf	dado_rx5,W
	xorlw	'C'
	btfsc	STATUS,Z
	goto	comando_blue_fechando ;Desvia acelerar ou aumentar velocidade de fechamento do portão

verifica_m1_fechando:	;Se O enviado atraves do bluetooth
	movf	dado_rx5,W
	xorlw	'O'	
	btfsc	STATUS,Z
	goto	comando_m1_O_fechando ;Desvia para abrir portão

verifica_m2_fechando:	;Se C enviado atraves do bluetooth
	movf	dado_rx5,W
	xorlw	'S'
	btfsc	STATUS,Z
	goto	comando_m1_S_fechando ;Desvia para parar portão
	goto	caracter_errado_fechando
;------------------------------------------------------------
;------------------------------------------------------------
comando_blue_fechando:
	clrf	vb2
	clrf	dado_rx5
	call	abrir_fechar
	call	velo_1

comando_m1_O_fechando:
	clrf	vb2
	clrf	dado_rx5
	call	abrir_fechar
	;call	delay_1s
	call	abreportao_fechando

comando_m1_S_fechando:
	clrf	vb2
	clrf	dado_rx5
	call	abrir_fechar
	call	desliga_tudo

caracter_errado_fechando:
	clrf	vb2
	clrf	dado_rx5
	call	abrir_fechar
	call	lops_s333	;loop relacionado ao portão enquanto fecha

;=============================================
;-----ABRIR/FECHAR/PARAR PORTÃO ABRINDO-------
;=============================================
RxCarUART6 ; primeiro caractere
	bcf		flag_rx6,0	;limpa flag de recepção
	movlw	B'00100000' ;0x06 = máscara de bits não desejados
	andwf	RCSTA,W		;para verificar bits de erro
	btfss	STATUS,Z
	goto	RxError		;existe algum flag de erro = 1
	;call	delay_10ms
	btfss	PIR1,RCIF	;verifica se dado está pronto
	call	lop_s111	;retorna com flag regrx<0> = 0
	movf	RCREG,W		;le o conteúdo do Reg. => Wreg
	bsf		flag_rx6,0	;regrx<0>  = 1, indica existe dado recebido
	return

verifica_blue_abrindo:
	movf	dado_rx6,W
	xorlw	'O'
	btfsc	STATUS,Z
	goto	comando_blue_abrindo ;Desvia acelerar ou aumentar velocidade de fechamento do portão
	;call	abrir_fechar
verifica_m1_abrindo:	;Se O enviado atraves do bluetooth
	movf	dado_rx6,W
	xorlw	'C'	
	btfsc	STATUS,Z
	goto	comando_m1_C_abrindo ;Desvia para fechar portão

verifica_m2_abrindo:	;Se C enviado atraves do bluetooth
	movf	dado_rx6,W
	xorlw	'S'
	btfsc	STATUS,Z
	goto	comando_m1_S_abrindo ;Desvia para parar portão
	goto	caracter_errado_abrindo
;----------------------------------------------------------
;----------------------------------------------------------
comando_blue_abrindo:
	clrf	vb3
	clrf	dado_rx6
	call	abrir_fechar
	call	velo_2

comando_m1_C_abrindo:
	clrf	vb3
	clrf	dado_rx6
	call	abrir_fechar
	;call	delay_1s
	call	fechaportao_abrindo

comando_m1_S_abrindo:
	clrf	vb3
	clrf	dado_rx6
	call	abrir_fechar
	call	desliga_tudo

caracter_errado_abrindo:
	clrf	vb3
	clrf	dado_rx6
	call	abrir_fechar
	call	lop_s111	;loop relacionado ao portão enquanto fecha
;======================================================	
RxError:
	bcf		RCSTA,CREN	;limpa bit de erro por OVERRUN
	nop
	bsf		RCSTA,CREN
	return
	

	