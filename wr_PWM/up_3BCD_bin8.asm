;********************************************************
; Rotina para converter 3BCD para binário de 8 bits
; O numero decimal: cent:deze:unid <= 255
; O número binario: binario_L
;********************************************************
	cblock
		binario8
;		cent		;digito centena
;		deze		;digito dezena
;		unit    	;digito unidade
	endc

BCD_2_bin8:
	clrw
	btfsc	cent,1
	addlw	.200		;se BCD(cent) = 2
	btfsc	cent,0
	addlw	.100		;se BCD(cent) = 1
	movwf	binario8	;= BCD(cent)

	movlw	0x30
	subwf	deze,F		;BCD(deze) = ASCII(deze) - 0x30
	movf	deze,W
	addwf	deze,W		;Wreg = 2*BCD(deze)
	addwf	deze,F		;3*BCD(deze)
	addwf	deze,F		;5*BCD(deze)	C=0
	rlf		deze,W		;Wreg = 10*BCD(deze)
	addwf	binario8,F	;= BCD(cent) + 10*BCD(deze)

	movlw	0x30
	subwf	unid,W		;BCD(unid)
	addwf	binario8,F	;= BCD(cent) + 10*BCD(deze) + BCD(unid)
	return
