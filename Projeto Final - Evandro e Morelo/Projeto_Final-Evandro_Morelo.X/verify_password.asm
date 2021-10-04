	cblock
		flag_error
		p1,p2,p3,p4,p5	;SENHA 1
		a1,a2,a3,a4,a5	;SENHA 2
		b1,b2,b3,b4,b5	;SENHA 3
		c1,c2,c3,c4,c5	;SENHA 4
		d1,d2,d3,d4,d5	;SENHA 5
	endc

;****************************************************************
 ;	CARREGA SENHAS PADROES DO SISTEMA
 ;****************************************************************
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
	
	movlw	'1'
	movwf	a1	;coloca numero 1 como primeiro digito da senha
	movlw	'1'
	movwf	a2	;coloca numero 2 como primeiro digito da senha
	movlw	'2'
	movwf	a3	;coloca numero 3 como primeiro digito da senha
	movlw	'4'
	movwf	a4	 ;coloca numero 4 como primeiro digito da senha
	movlw	'6'
	movwf	a5	 ;coloca numero 5 como primeiro digito da senha
	
	movlw	'2'
	movwf	b1	;coloca numero 1 como primeiro digito da senha
	movlw	'2'
	movwf	b2	;coloca numero 2 como primeiro digito da senha
	movlw	'2'
	movwf	b3	;coloca numero 3 como primeiro digito da senha
	movlw	'2'
	movwf	b4	 ;coloca numero 4 como primeiro digito da senha
	movlw	'2'
	movwf	b5	 ;coloca numero 5 como primeiro digito da senha
	
	movlw	'6'
	movwf	c1	;coloca numero 1 como primeiro digito da senha
	movlw	'9'
	movwf	c2	;coloca numero 2 como primeiro digito da senha
	movlw	'1'
	movwf	c3	;coloca numero 3 como primeiro digito da senha
	movlw	'7'
	movwf	c4	 ;coloca numero 4 como primeiro digito da senha
	movlw	'1'
	movwf	c5	 ;coloca numero 5 como primeiro digito da senha
	
	movlw	'5'
	movwf	d1	;coloca numero 1 como primeiro digito da senha
	movlw	'6'
	movwf	d2	;coloca numero 2 como primeiro digito da senha
	movlw	'3'
	movwf	d3	;coloca numero 3 como primeiro digito da senha
	movlw	'9'
	movwf	d4	 ;coloca numero 4 como primeiro digito da senha
	movlw	'8'
	movwf	d5	 ;coloca numero 5 como primeiro digito da senha
	return

 ;********************************************************************
 ;	VERIFICA SENHAS DE ACORDO COM USUARIO SELECIONADO
 ;********************************************************************
Verify_password:
	clrf	flag_error	    ; LIMPA FLAG ERRO
	movfw	dig1	    ; MOVE DIGITO 1 DO USUARIO PARA W
	xorwf	p1,0	    ; XOR COM ENTRE DIG1 E P1
	btfss	STATUS,Z	    ; SE XOR = 0 (Z = 1, SIGNIFICA DIGITO CORRETO) SALTA PROXIMA INSTRUCAO
	bsf	flag_error,F	    ; SETA FLAG ERRO = 1
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
	btfss	STATUS,Z  ; SALTA PARA A VERIFICAÇÃO DA PROXIMA SENHA  
	bsf	flag_error,F	
	return		; RETORNA PARA PROGRAMA PRINCIPAL

Verify_password2:
	clrf	flag_error	;LIMPA FLAG ERRO PARA UMA NOVA TENTATIVA
	movfw	dig1
	xorwf	a1,0
	btfss	STATUS,Z
	bsf	flag_error,F
	movfw	dig2
	xorwf	a2,0
	btfss	STATUS,Z
	bsf	flag_error,F
	movfw	dig3
	xorwf	a3,0
	btfss	STATUS,Z
	bsf	flag_error,F
	movfw	dig4
	xorwf	a4,0
	btfss	STATUS,Z
	bsf	flag_error,F
	movfw	dig5
	xorwf	a5,0
	btfss	STATUS,Z
	bsf	flag_error,F
	return

Verify_password3:
	clrf	flag_error
	movfw	dig1
	xorwf	b1,0
	btfss	STATUS,Z
	bsf	flag_error,F
	movfw	dig2
	xorwf	b2,0
	btfss	STATUS,Z
	bsf	flag_error,F
	movfw	dig3
	xorwf	b3,0
	btfss	STATUS,Z
	bsf	flag_error,F
	movfw	dig4
	xorwf	b4,0
	btfss	STATUS,Z
	bsf	flag_error,F
	movfw	dig5
	xorwf	b5,0
	btfss	STATUS,Z
	bsf	flag_error,F
	return

Verify_password4:
	clrf	flag_error
	movfw	dig1
	xorwf	c1,0
	btfss	STATUS,Z
	bsf	flag_error,F
	movfw	dig2
	xorwf	c2,0
	btfss	STATUS,Z
	bsf	flag_error,F
	movfw	dig3
	xorwf	c3,0
	btfss	STATUS,Z
	bsf	flag_error,F
	movfw	dig4
	xorwf	c4,0
	btfss	STATUS,Z
	bsf	flag_error,F
	movfw	dig5
	xorwf	c5,0
	btfss	STATUS,Z
	bsf	flag_error,F
	return
	
Verify_password5:
	clrf	flag_error
	movfw	dig1
	xorwf	d1,0
	btfss	STATUS,Z
	bsf	flag_error,F
	movfw	dig2
	xorwf	d2,0
	btfss	STATUS,Z
	bsf	flag_error,F
	movfw	dig3
	xorwf	d3,0
	btfss	STATUS,Z
	bsf	flag_error,F
	movfw	dig4
	xorwf	d4,0
	btfss	STATUS,Z
	bsf	flag_error,F
	movfw	dig5
	xorwf	d5,0
	btfss	STATUS,Z
	bsf	flag_error,F
	return		; SE TODAS SENHAS NÃO FOREM CORRETOS ENTÃO FLAG ERRO = 1
	
 ;****************************************************************
 ;	MUDA SENHA DE ACORDO COM USUARIO SELECIONADO
 ;****************************************************************
New_password:
	;flag testa e envia para um dos labels de senha
	btfsc	flag_user1,F
	goto	change_pass_U
	btfsc	flag_user2,F
	goto	change_pass_A
	btfsc	flag_user3,F
	goto	change_pass_B
	btfsc	flag_user4,F
	goto	change_pass_C
	btfsc	flag_user5,F
	goto	change_pass_D
	return
change_pass_U:
	movfw	dig1
	movwf	p1
	movfw	dig2
	movwf	p2
	movfw	dig3
	movwf	p3
	movfw	dig4
	movwf	p4
	movfw	dig5
	movwf	p5
	return
change_pass_A:
	movfw	dig1
	movwf	a1
	movfw	dig2
	movwf	a2
	movfw	dig3
	movwf	a3
	movfw	dig4
	movwf	a4
	movfw	dig5
	movwf	a5
	return
change_pass_B:
	movfw	dig1
	movwf	b1
	movfw	dig2
	movwf	b2
	movfw	dig3
	movwf	b3
	movfw	dig4
	movwf	b4
	movfw	dig5
	movwf	b5
	return
change_pass_C:
	movfw	dig1
	movwf	c1
	movfw	dig2
	movwf	c2
	movfw	dig3
	movwf	c3
	movfw	dig4
	movwf	c4
	movfw	dig5
	movwf	c5
	return
change_pass_D:
	movfw	dig1
	movwf	d1
	movfw	dig2
	movwf	d2
	movfw	dig3
	movwf	d3
	movfw	dig4
	movwf	d4
	movfw	dig5
	movwf	d5
	return