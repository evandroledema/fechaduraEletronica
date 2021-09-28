;********************************************************
; biblioteca para usar o modulo CAD
; Resultado da amostragem em Binario10H:Binario10L
;********************************************************
	cblock
		Binario10H, Binario10L
		conta_ad
	endc

Iniciar_AN0:				;Escolhe AN0 e inicia a aquisição
	movlw	0x81			;clock Fosc/32 (Max.20MHz), Ch0, CAD on
	movwf	ADCON0
	return
Iniciar_AN1:				;Escolhe AN1 e inicia a aquisição
	movlw	0x89			;clock Fosc/32 (Max.20MHz), Ch1, CAD on
	movwf	ADCON0
	return
Iniciar_AN3:				;Escolhe AN3 e inicia a aquisição
	movlw	0x99			;clock Fosc/32 (Max.20MHz), Ch3, CAD on
	movwf	ADCON0
	return
Converte_AD:
	movlw	.26				;Tadq >= 20us (Fclock = 16MHz)
	movwf	conta_ad
	decfsz	conta_ad,F		;(3N+3)c   (inclui CALL)
	goto	$ - 1			;aguarda tempo de aquisição
	bsf		ADCON0,GO_DONE	;começa a conversão AD
	btfsc 	ADCON0,GO_DONE	;espera a conversão AD terminar
	goto	$ - 1
	movfw	ADRESH			;Carrega em W o valor de tensão convertido
	movwf	Binario10H
	banco1 
	movf	ADRESL,W
	banco0
	movwf	Binario10L   	;Resultado em Binario10
	return
