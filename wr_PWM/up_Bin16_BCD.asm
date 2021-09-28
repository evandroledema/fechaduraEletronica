;*********************************************************
; Rotina para converter binário de 16 bits para 'BCD'
; entrada: binario_H:binario_L = número binario de 16 bits
; saída: dmil:umil:cent:deze:unid = equivalente decimal
;
; exemplo:
; movlw  high .20568
; movwf  binario_H
; movlw  low .20568
; movwf  binario_L
; call	  bin16_bcd
;*********************************************************
	cblock
;		binario_H, binario_L
		dmil		;digito dezena de milhar
		umil		;digito unidade de milhar
		cent		;digito centena
		deze		;digito dezena
		unid    	;digito unidade
	endc
binario_H	equ	Op1_H
binario_L	equ	Op1_L

Bin16_2_BCD:
	clrf      dmil
	clrf      umil
	clrf      cent
	clrf      deze
	clrf      unid                    
d_dmil movlw     0x27
	subwf     binario_H,W
	btfss     STATUS,C
	goto      d_mil
	btfsc     STATUS,Z
	goto      d2
	movwf     binario_H
	movlw     0x10
	subwf     binario_L,W
	movwf     binario_L
	btfss     STATUS,C
	decf      binario_H,F
d1  incf      dmil,F
	goto      d_dmil
d2  movlw     0x10
	subwf     binario_L,W
	btfss     STATUS,C
	goto      d_mil
	movwf     binario_L
	clrf      binario_H
	goto      d1
d_mil  movlw     0x03
	subwf     binario_H,W
	btfss     STATUS,C
	goto      d_cent
	btfsc     STATUS,Z
	goto      d4
	movwf     binario_H
	movlw     0xE8
	subwf     binario_L,W
	movwf     binario_L
	btfss     STATUS,C
	decf      binario_H,F
d3  incf     umil,F
	goto      d_mil
d4  movlw    0xE8
	subwf     binario_L,W
	btfss     STATUS,C
	goto      d_cent
	movwf     binario_L
	clrf      binario_H
	goto      d3
d_cent movlw     0x64
	movf      binario_H,F
	btfsc     STATUS,Z
	goto      d5
	subwf     binario_L,W
	btfss     STATUS,C
	decf      binario_H,F
	movwf     binario_L
	incf      cent,F
	goto      d_cent
d5  movlw     0x64
	subwf     binario_L,W
	btfss     STATUS,C
	goto      d_dec
	incf      cent,F
	movwf     binario_L
	goto      d5
d_dec  movlw     0x0A
	subwf     binario_L,W
	btfss     STATUS,C
	goto      d_unid
	incf      deze,F
	movwf     binario_L
	goto      d_dec
d_unid movf      binario_L,W
	movwf     unid
	return
