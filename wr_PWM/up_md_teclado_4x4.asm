#Define Linha1  PORTD,3
#Define Linha2  PORTD,2
#Define Linha3  PORTD,1
#Define Linha4  PORTD,0

#Define Col1	PORTA,0
#Define Col2	PORTA,1
#Define Col3	PORTA,2
#Define Col4	PORTA,3

	cblock
	   tecla,conta_kp,fpress,ptr_car
	endc

;txt_calc:
;	addwf 	PCL, F
;	dt		"  Calculadora"	; 13c

ascii_key:
	addwf	PCL,F
	dt		"A0E+123-456*789/"

;mostrar "calculadora" no LCD

Inicia_teclado:
	movlw	0x0F
	iorwf	PORTD,F		;desabilita linhas
	banco1
	iorwf	TRISA,F		;PORTB<3:0> input
	movlw	0xF0
	andwf	TRISD,F		;PORTC<3:0> output
	banco0
	return
	
teclado:
	clrf	fpress
	clrf	conta_kp
	decf	conta_kp,F	; conta_kp = -1
;varredura de linha_1
	bcf		Linha1		; habilita linha 1
	call	delay_50ms
	call	scan_cols	; varredura das 4 colunas
	bsf		Linha1		; desabilita linha 1
;varredura de linha_2
	bcf		Linha2		; habilita linha 2
	call	delay_50ms
	call	scan_cols	; varredura das 4 colunas
	bsf		Linha2		; desabilita linha 2
;varredura de linha_3
	bcf		Linha3		; habilita linha 3
	call	delay_50ms
	call	scan_cols	; varredura das 4 colunas
	bsf		Linha3		; desabilita linha 3
;varredura de linha_4
	bcf		Linha4		; habilita linha 4
	call	delay_50ms
	call	scan_cols	; varredura das 4 colunas
	bsf		Linha4		; desabilita linha 4
;sair de sub-rotina de teclado
	return

;Varredura das 4 colunas para detectar tecla pressionada
;Testa se algum pino de PORTB<3:0> está em zero
scan_cols:
	incf	conta_kp,F	;incrementa apontador de teclas
	btfss	Col1		;se não detecta press na col1, pula
	;se detecta press, irá para codificar a tecla
	call	codifica	; 0:[A=on], 4:[1], 8:[4], 12:[7]
	incf	conta_kp,F
	btfss	Col2		;se não detecta press na col2, pula
    call	codifica	; 1:[0], 5:[2], 9:[5], 13:[8]
	incf	conta_kp,F
	btfss	Col3		;se não detecta press na col3, pula
	call	codifica	; 2:[E=exe], 6:[3], 10:[6], 14:[9]
	incf	conta_kp,F
	btfss	Col4		;se não detecta press na col4, pula
	call	codifica	; 3:[+], 7:[-], 11:[*], 15:[/]
	
;-----------------
;bluetooth	
;-----------------
	return
codifica:
	movfw	conta_kp	;apontador tem localização da tecla press
	call	ascii_key	;obtem o ASCII da tecla press
	movwf	tecla		;tecla = ASCII(tecla press)
	bsf		fpress,0	;ativa flag, indica que uma tecla foi press
	call	delay_20ms
ld_deb:
	call	delay_50ms	;p/debouncing
	btfss	Col1
	call	ld_deb		;espera a tecla de col1, ser solta
	btfss	Col2
	call	ld_deb		;espera a tecla de col2, ser solta
	btfss	Col3
	call	ld_deb		;espera a tecla de col3, ser solta
	btfss	Col4
	call	ld_deb		;espera a tecla de col4, ser solta
	return