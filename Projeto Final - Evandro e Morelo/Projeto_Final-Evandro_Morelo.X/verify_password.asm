	cblock
		flag_error,p1,p2,p3,p4,p5
	endc

Set_password:
	movlw	'1'
	movwf	p1	;coloca numero 1 como primeiro digito da senha
	movlw	'2'
	movwf	p2	;coloca numero 2 como primeiro digito da senha
	movlw	'3'
	movwf	p3	;coloca numero 3 como primeiro digito da senha
	movlw	'4'
	movwf	p4	 ;coloca numero 4 como primeiro digito da senha
	movlw	'5'
	movwf	p5	 ;coloca numero 5 como primeiro digito da senha
	return

Verify_password:
	clrf	flag_error
	call	Set_password
	movfw	dig1
	xorwf	p1,0
	btfss	STATUS,Z
	bsf	flag_error,F
	movfw	dig2
	xorwf	p2,0
	btfss	STATUS,Z
	bsf	flag_error,F
	movfw	dig3
	xorwf	p3,0
	btfss	STATUS,Z
	bsf	flag_error,F
	movfw	dig4
	xorwf	p4,0
	btfss	STATUS,Z
	bsf	flag_error,F
	movfw	dig5
	xorwf	p5,0
	btfss	STATUS,Z
	bsf	flag_error,F
	return

	
