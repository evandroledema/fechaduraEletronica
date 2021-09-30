	cblock
		flag_user_err
		U1,U2,U3
		A1,A2,A3
		B1,B2,B3
		C1,C2,C3
		D1,D2,D3
		flag_user1,flag_user2,flag_user3,flag_user4,flag_user5
	endc

Iniciar_senhas:
	movlw	'1'
	movwf	U1
	movlw	'2'
	movwf	U2
	movlw	'3'
	movwf	U3
	movlw	'6'
	movwf	A1
	movlw	'6'
	movwf	A2
	movlw	'6'
	movwf	A3
	movlw	'1'
	movwf	B1
	movlw	'1'
	movwf	B2
	movlw	'1'
	movwf	B3
	movlw	'1'
	movwf	C1
	movlw	'5'
	movwf	C2
	movlw	'7'
	movwf	C3
	movlw	'1'
	movwf	D1
	movlw	'2'
	movwf	D2
	movlw	'4'
	movwf	D3
	return

     
Verify_user:	
	clrf	flag_user_err
	clrf	flag_user1
	movfw	user1
	xorwf	U1,0
	btfss	STATUS,Z
	bsf	flag_user_err,F
	movfw	user2
	xorwf	U2,0
	btfss	STATUS,Z
	bsf	flag_user_err,F
	movfw	user3
	xorwf	U3,0
	btfss	STATUS,Z
	bsf	flag_user_err,F
	btfss	flag_user_err,F
	bsf	flag_user1,F
	btfsc	flag_user1,F
	return
	
	clrf	flag_user_err
	clrf	flag_user2
	movfw	user1
	xorwf	A1,0
	btfss	STATUS,Z
	bsf	flag_user_err,F
	movfw	user2
	xorwf	A2,0
	btfss	STATUS,Z
	bsf	flag_user_err,F
	movfw	user3
	xorwf	A3,0
	btfss	STATUS,Z
	bsf	flag_user_err,F
	btfss	flag_user_err,F
	bsf	flag_user2,F
	btfsc	flag_user2,F
	return
	
	clrf	flag_user_err
	clrf	flag_user3
	movfw	user1
	xorwf	B1,0
	btfss	STATUS,Z
	bsf	flag_user_err,F
	movfw	user2
	xorwf	B2,0
	btfss	STATUS,Z
	bsf	flag_user_err,F
	movfw	user3
	xorwf	B3,0
	btfss	STATUS,Z
	bsf	flag_user_err,F
	btfss	flag_user_err,F
	bsf	flag_user3,F
	btfsc	flag_user3,F
	return
	
	clrf	flag_user_err
	clrf	flag_user4
	movfw	user1
	xorwf	C1,0
	btfss	STATUS,Z
	bsf	flag_user_err,F
	movfw	user2
	xorwf	C2,0
	btfss	STATUS,Z
	bsf	flag_user_err,F
	movfw	user3
	xorwf	C3,0
	btfss	STATUS,Z
	bsf	flag_user_err,F
	btfss	flag_user_err,F
	bsf	flag_user4,F
	btfsc	flag_user4,F
	return
	
	clrf	flag_user_err
	clrf	flag_user5
	movfw	user1
	xorwf	D1,0
	btfss	STATUS,Z
	bsf	flag_user_err,F
	movfw	user2
	xorwf	D2,0
	btfss	STATUS,Z
	bsf	flag_user_err,F
	movfw	user3
	xorwf	D3,0
	btfss	STATUS,Z
	bsf	flag_user_err,F
	btfss	flag_user_err,F
	bsf	flag_user5,F
	return

New_user:
	;flag testa e envia para um dos labels de senha
	btfsc	flag_user1,F
	goto	change_U
	btfsc	flag_user2,F
	goto	change_A
	btfsc	flag_user3,F
	goto	change_B
	btfsc	flag_user4,F
	goto	change_C
	btfsc	flag_user5,F
	goto	change_D
	goto	User_retorno
change_U:
	movfw	user1
	movwf	U1
	movfw	user2
	movwf	U2
	movfw	user3
	movwf	U3
	return
change_A:
	movfw	user1
	movwf	A1
	movfw	user2
	movwf	A2
	movfw	user3
	movwf	A3
	return
change_B:
	movfw	user1
	movwf	B1
	movfw	user2
	movwf	B2
	movfw	user3
	movwf	B3
	return
change_C:
	movfw	user1
	movwf	C1
	movfw	user2
	movwf	C2
	movfw	user3
	movwf	C3
	return
change_D:
	movfw	user1
	movwf	D1
	movfw	user2
	movwf	D2
	movfw	user3
	movwf	D3
	return
	