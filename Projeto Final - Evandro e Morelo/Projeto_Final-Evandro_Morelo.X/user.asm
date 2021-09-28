	cblock
		flag_user_err,U1,U2,U3
	endc

Iniciar_senhas:
	movlw	'1'
	movwf	U1
	movlw	'2'
	movwf	U2
	movlw	'3'
	movwf	U3
	return

     
Verify_user:	
	clrf	flag_user_err
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
	return
	

	
