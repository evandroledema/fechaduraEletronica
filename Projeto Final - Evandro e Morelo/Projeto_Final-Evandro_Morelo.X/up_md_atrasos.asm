;******************************************************************
;* Rotinas para gerar atrasos de tempo,
;* reg. "contador1,2,3" para estabelecer o tempo de atraso
;* frequência de clock = 16.000 Mhz
; UFMT: Jun/2017
;******************************************************************

	cblock
		contador1	;registradores usados para atraso
		contador2
		contador3
	endc
;*****************************************************************
;	Rotina de atraso de 1s, usada para aumentar o tempo de
;	uma mensagem no LCD antes de enviar uma próxima mensagem.
;*****************************************************************
delay_1s:
	movlw	D'189'
	movwf	contador1
	movlw	D'75'
	movwf	contador2
	movlw	D'21'
	movwf	contador3
	decfsz	contador1,1
	goto	$-1
	decfsz	contador2,1
	goto	$-3
	decfsz	contador3,1
	goto	$-5
	return
