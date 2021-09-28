;*******************************************************************************
;    UNIVERSIDADE FEDERAL DE MATO GROSSO                                                             
;    ENGENHARIA ELÉTRICA                                                                                               
;    MICROPROCESSADORES                                                                                               
;    DATE: 2021/2                                                                                                                    
;    DISCENTES:                                                                                                                    
;    EVANDRO FERNANDES LEDEMA	                                                                 
;    MATHEUS MORELO PEREIRA
;                                                                             
;*******************************************************************************
	list	p=16f877a	
	#include	<p16f877a.inc>
	#include	<macros.inc>
	__CONFIG H'2F02'
	ERRORLEVEL -302, -305  

;======================================================================
	cblock	0x20
		dig1,dig2,dig3,dig4,dig5,user1,user2,user3,Loper
	endc
	org	0x00
	goto	setup
	org	0x04
	#include	"up_md_teclado_4x4.asm"
;======================================================================

;se fpress<0> retorna com 0, a tecla não é de um BCD
checa_BCD:
	bcf	fpress,0		;limpa flag
	movlw	0x30			
	subwf	tecla,W		;tecla - 0x30 
	btfss	STATUS,C		;C=1: 0x30 <= tecla
	return			;BCD inválido
	movfw	tecla	
	sublw	0x39		;0x39 - tecla
	btfsc	STATUS,C		;C=1: tecla <= 0x39
	bsf	fpress,0		;indica BCD válido
	return
	
;*******************************************************************************
; MAIN PROGRAM
;*******************************************************************************

setup:	
	call	Inicia_teclado	;configura PORTB e PORTC
	call	Inicia_LCD		;configura o módulo LCD e Portas
	call	Iniciar_senhas
	banco0
	clrf	PORTA
	banco1	
	movlw	0x06
	movwf	ADCON1		;PORTE como E/S dig.
	movlw	0x00
	movwf	TRISA
	banco0
	bcf	PORTA,0
	call	envia_msg_LCD	;mostra mensagem no LCD

main:	

	call	teclado		; para ler operador
	btfss	fpress,0	
	goto	$-2		; fica no loop até ler tecla press
ON_C:				;valida operador ON/C
	movlw	'A'
	xorwf	tecla,W		; tecla [ON/C]
	btfss	STATUS,Z
	goto	ON_C - .3		; operador inválido, retorna
	call	envia_msg_menu_LCD	; MENU
TECLA_1_2:
	call	teclado		; para ler operador
	btfss	fpress,0	
	goto	TECLA_1_2		; fica no loop até ler tecla press
	movlw	'1'	
	xorwf	tecla,W		; tecla [1]
	btfss	STATUS,Z
	goto	Testa_2
	call	envia_msg_entrar_LCD
	movlw	LCD_Linha_2	;2 linha
	call	EnviaCmdLCD
;=============================================================
;Lê 1° operando
Lop1:
	call	teclado		; para ler operador
	btfss	fpress,0	
	goto	Lop1		; fica no loop até ler BCD1
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0
	goto	Lop1		; BCD1 inválido, retorna
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	Lop1		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	user1		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;=============================================================
Usuario_2dig:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Usuario_2dig		; vai verificar se é operador
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	Usuario_2dig		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	user2		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;==============================================================
Usuario_3dig:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Usuario_3dig		; vai verificar se é operador
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	Usuario_3dig		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	user3		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;===============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
Enviar_user:			;valida operador ON/C
	movlw	'E'
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z
	goto	Enviar_user - .3	; operador inválido, retorna
	call	Verify_user		; MENU
	btfsc	flag_user_err,F
	goto	Usuario_erro
	goto	Enviar_msg_senha
	
Usuario_erro:
	call	envia_msg_erro_LCD
	call	envia_msg_entrar_LCD
	movlw	LCD_Linha_2	
	call	EnviaCmdLCD
	bcf	user1,F
	bcf	user2,F
	bcf	user3,F
	goto	Lop1
	
Enviar_msg_senha:
	call	envia_msg_senha_LCD
	movlw	LCD_Linha_2	
	call	EnviaCmdLCD
;=============================================================
;Lê 1° operando
Lop2:
	call	teclado		; para ler operador
	btfss	fpress,0	
	goto	Lop2		; fica no loop até ler BCD1
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0
	goto	Lop2		; BCD1 inválido, retorna
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	Lop2		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	dig1		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;=============================================================
Senha_2dig:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Senha_2dig		; vai verificar se é operador
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	Senha_2dig		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	dig2		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;==============================================================
Senha_3dig:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Senha_3dig		; vai verificar se é operador
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	Senha_3dig		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	dig3		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;===============================================================
Senha_4dig:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Senha_4dig		; vai verificar se é operador
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	Senha_4dig		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	dig4		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;===============================================================
Senha_5dig:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Senha_5dig		; vai verificar se é operador
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	Senha_5dig		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	dig5		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;===============================================================

	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
Enviar_senha:			;valida operador ON/C
	movlw	'E'
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z
	goto	Enviar_senha - .3	; operador inválido, retorna
	call	Verify_password	; MENU
	btfsc	flag_error,F
	goto	Senha_erro
	goto	Abrir_fechadura
	
Senha_erro:
	call	envia_msg_senha_erro_LCD
	call	envia_msg_senha_LCD
	movlw	LCD_Linha_2	
	call	EnviaCmdLCD
	goto	Lop2
	
Abrir_fechadura:
	call	envia_msg_abrir_LCD
	
;COLOCAR COMANDOS PARA POLARIZAR BOBINA DO RELÉ
	
;=========================================================
;------------------LIGA RELÉ E ABRE FECHADURA-------------------------------
;=========================================================
Relay_on:
;jogar o set da porta lá em cima
;depois usar só bsf e bcf na saida da portaC
	;BCF	STATUS, RP0	;SELECT BANK 00
	banco0
	bsf	PORTC,4
;=========================================================
;------------------DESLIGA RELÉ E FECHA LOCK----------------------------------
;=========================================================
Relay_off:
	;BCF	STATUS, RP0	;SELECT BANK 00
	;banco0
	;bcf	PORTC,4
;=========================================================
	SLEEP
	
Testa_2:	movlw	'2'	
	xorwf	tecla,W		; tecla [2]
	btfss	STATUS,Z
	goto	TECLA_1_2		; operadores inválidos, retorna
	;desenvolver aqui	
	goto	main
    
	#include	"up_md_lcd_driver_PIC16F.asm"
	#include	"up_mensagens_PIC16F.asm"
	#include	"up_md_atrasos.asm"
	#include	"verify_password.asm"
	#include	"user.asm"
	
	end