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

delay_1ms:	
	movlw	D'47'
	movwf	contador1
	movlw	D'6'
	movwf	contador2
	decfsz	contador1,F	;
	goto	$-1
	decfsz	contador2,1
	goto	$-3
	return	

delay_2ms:	
	movlw	D'97'
	movwf	contador1
	movlw	D'11'
	movwf	contador2
	decfsz	contador1,F	;
	goto	$-1
	decfsz	contador2,1
	goto	$-3
	return	

delay_3ms:	
	movlw	D'147'
	movwf	contador1
	movlw	D'16'
	movwf	contador2
	decfsz	contador1,F	;
	goto	$-1
	decfsz	contador2,1
	goto	$-3
	return	

delay_4ms:	
	movlw	D'197'
	movwf	contador1
	movlw	D'21'
	movwf	contador2
	decfsz	contador1,F	;
	goto	$-1
	decfsz	contador2,1
	goto	$-3
	return	

delay_5ms:	
	movlw	D'247'
	movwf	contador1
	movlw	D'26'
	movwf	contador2
	decfsz	contador1,F	;
	goto	$-1
	decfsz	contador2,1
	goto	$-3
	return	

delay_10ms:
	movlw	D'240'
	movwf	contador1
	movlw	D'52'
	movwf	contador2
	decfsz	contador1,1
	goto	$-1
	decfsz	contador2,1
	goto	$-3
	return	

delay_20ms:
	movlw	D'226'
	movwf	contador1
	movlw	D'104'
	movwf	contador2
	decfsz	contador1,1
	goto	$-1
	decfsz	contador2,1
	goto	$-3
	return	

delay_50ms:
	movlw	D'185'
	movwf	contador1
	movlw	D'4'
	movwf	contador2
	movlw	D'2'
	movwf	contador3
	decfsz	contador1,1
	goto	$-1
	decfsz	contador2,1
	goto	$-3
	decfsz	contador3,1
	goto	$-5
	return

delay_100ms:
	movlw	D'117'
	movwf	contador1
	movlw	D'8'
	movwf	contador2
	movlw	D'3'
	movwf	contador3
	decfsz	contador1,1
	goto	$-1
	decfsz	contador2,1
	goto	$-3
	decfsz	contador3,1
	goto	$-5
	return

delay_500ms:
	movlw	D'92'
	movwf	contador1
	movlw	D'38'
	movwf	contador2
	movlw	D'11'
	movwf	contador3
	decfsz	contador1,F	;
	goto	$-1
	decfsz	contador2,1
	goto	$-3
	decfsz	contador3,1
	goto	$-5
	return	

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
