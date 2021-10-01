;*******************************************************************************
;    UNIVERSIDADE FEDERAL DE MATO GROSSO                                                             
;    ENGENHARIA ELÉTRICA                                                                                               
;    MICROPROCESSADORES                                                                                               
;    DATE: 2021/2                                                                                                                    
;    DISCENTES:                                                                                                                    
;    EVANDRO FERNANDES LEDEMA	                                                                 
;    MATHEUS MORELO PEREIRA
;    USUÁRIOS: 123, 666, 111, 157, 124
;    SENHAS:12345, 11246, 22222, 69171, 56398
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
	call	Set_password
	banco0
	clrf	PORTA
	banco1	
	movlw	0x06
	movwf	ADCON1		;PORTE como E/S dig.
	movlw	0x00
	movwf	TRISA
	banco0
	bcf	PORTA,0
	bcf	PORTA,1
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
	
;flag testa e envia para um dos labels de senha
	btfsc	flag_user1,F
	goto	Senha1
	btfsc	flag_user2,F
	goto	Senha2
	btfsc	flag_user3,F
	goto	Senha3
	btfsc	flag_user4,F
	goto	Senha4
	btfsc	flag_user5,F
	goto	Senha5
	goto	retorno
Senha1:
	call	Verify_password
	goto	retorno
Senha2:
	call	Verify_password2
	goto	retorno
Senha3:
	call	Verify_password3
	goto	retorno
Senha4:
	call	Verify_password4
	goto	retorno
Senha5:
	call	Verify_password5
retorno:
	
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
	bsf	PORTA,0
	call	envia_msg_abrir_LCD
	call	Envia_cmd_fechar_LCD
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
Relay_on:				;valida operador ON/C
	movlw	'1'
	xorwf	tecla,W		; tecla [1]
	btfss	STATUS,Z
	goto	Relay_on - .3	; operador inválido, retorna

Relay_off:
	bcf	PORTA,0
	movlw	LCD_CLEAR
	call	EnviaCmdLCD
	call	envia_msg_LCD	
	goto	main
	
Testa_2:	movlw	'2'	
	xorwf	tecla,W		; tecla [2]
	btfss	STATUS,Z
	goto	TECLA_1_2		; operadores inválidos, retorna
	call	envia_msg_opcao_LCD
Loop3:	
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 
	movlw	'1'
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z
	goto	Opcao2		; operador inválido, retorna
;Mudar um usuário existente
	call	Enviar_msg_change_user_LCD
	movlw	LCD_Linha_2	
	call	EnviaCmdLCD
;=============================================================
;Lê 1° operando
Lop4:
	call	teclado		; para ler operador
	btfss	fpress,0	
	goto	Lop4		; fica no loop até ler BCD1
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0
	goto	Lop4		; BCD1 inválido, retorna
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	Lop4		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	user1		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;=============================================================
Usuario_4dig:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Usuario_4dig		; vai verificar se é operador
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	Usuario_4dig		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	user2		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;==============================================================
Usuario_5dig:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Usuario_5dig		; vai verificar se é operador
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	Usuario_5dig		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	user3		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;===============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
Enviar_user2:			;valida operador ON/C
	movlw	'E'
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z
	goto	Enviar_user2 - .3	; operador inválido, retorna
	call	Verify_user		; MENU
	btfsc	flag_user_err,F
	goto	Usuario_change_error
	goto	Change_user_password
	
	;desenvolver aquisição de users para mudar usuario

Usuario_change_error:
	call	envia_msg_erro_LCD
	call	Enviar_msg_change_user_LCD
	movlw	LCD_Linha_2	
	call	EnviaCmdLCD
	bcf	user1,F
	bcf	user2,F
	bcf	user3,F
	goto	Lop4
	
Change_user_password:
	call	envia_msg_senha_LCD
	movlw	LCD_Linha_2	
	call	EnviaCmdLCD
;=============================================================
;Lê 1° operando
Lop_user_1:
	call	teclado		; para ler operador
	btfss	fpress,0	
	goto	Lop_user_1		; fica no loop até ler BCD1
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0
	goto	Lop_user_1		; BCD1 inválido, retorna
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	Lop_user_1		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	dig1		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;=============================================================
Senha_user_2:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Senha_user_2		; vai verificar se é operador
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	Senha_user_2		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	dig2		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;==============================================================
Senha_user_3:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Senha_user_3		; vai verificar se é operador
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	Senha_user_3		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	dig3		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;===============================================================
Senha_user_4:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Senha_user_4		; vai verificar se é operador
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	Senha_user_4	; BCD1 = 0, retorna
	movfw	tecla	
	movwf	dig4		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;===============================================================
Senha_user_5:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Senha_user_5		; vai verificar se é operador
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	Senha_user_5		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	dig5		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;===============================================================

	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
Send_user_pass:			;valida operador ON/C
	movlw	'E'
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z
	goto	Send_user_pass - .3	; operador inválido, retorna
	
;flag testa e envia para um dos labels de senha
	btfsc	flag_user1,F
	goto	Pass_1
	btfsc	flag_user2,F
	goto	Pass_2
	btfsc	flag_user3,F
	goto	Pass_3
	btfsc	flag_user4,F
	goto	Pass_4
	btfsc	flag_user5,F
	goto	Pass_5
	goto	User_retorno
Pass_1:
	call	Verify_password
	goto	User_retorno
Pass_2:
	call	Verify_password2
	goto	User_retorno
Pass_3:
	call	Verify_password3
	goto	User_retorno
Pass_4:
	call	Verify_password4
	goto	User_retorno
Pass_5:
	call	Verify_password5
User_retorno:
	
	btfsc	flag_error,F
	goto	User_pass_error
	goto	Mudar_user
	
User_pass_error:
	call	envia_msg_senha_erro_LCD
	call	envia_msg_senha_LCD
	movlw	LCD_Linha_2	
	call	EnviaCmdLCD
	goto	Lop_user_1
	
Mudar_user:
	call	Enviar_msg_change_user2_LCD
	MOVLW	LCD_Linha_2	;2 linha
	CALL	EnviaCmdLCD
	;=============================================================
;Lê 1° operando
New_user1:
	call	teclado		; para ler operador
	btfss	fpress,0	
	goto	New_user1		; fica no loop até ler BCD1
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0
	goto	New_user1		; BCD1 inválido, retorna
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	New_user1		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	user1		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;=============================================================
New_user2:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	New_user2		; vai verificar se é operador
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	New_user2		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	user2		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;==============================================================
New_user3:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	New_user3		; vai verificar se é operador
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	New_user3		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	user3		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;===============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
Enviar_new_user:			;valida operador ON/C
	movlw	'E'
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z
	goto	Enviar_new_user - .3	; operador inválido, retorna
	
	call	New_user		; MENU
	call	Exibir_novo_user_LCD
	MOVLW	LCD_CLEAR
	CALL	EnviaCmdLCD
	call	envia_msg_LCD
	goto	main
;Mudar senha de um usuário específico
Opcao2:	
	movlw	'2'
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z
	goto	Loop3
	call	envia_msg_entrar_LCD
	
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	
	movlw	LCD_Linha_2	;2 linha
	call	EnviaCmdLCD
;=============================================================
;Lê 1° operando
Loop_user_change_pass1:
	call	teclado		; para ler operador
	btfss	fpress,0	
	goto	Loop_user_change_pass1		; fica no loop até ler BCD1
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0
	goto	Loop_user_change_pass1		; BCD1 inválido, retorna
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	Loop_user_change_pass1		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	user1		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;=============================================================
Loop_user_change_pass2:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Loop_user_change_pass2		; vai verificar se é operador
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	Loop_user_change_pass2		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	user2		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;==============================================================
Loop_user_change_pass3:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Loop_user_change_pass3		; vai verificar se é operador
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	Loop_user_change_pass3		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	user3		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;===============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
Enviar_user_change_pass:			;valida operador ON/C
	movlw	'E'
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z
	goto	Enviar_user_change_pass - .3	; operador inválido, retorna
	call	Verify_user		; MENU
	btfsc	flag_user_err,F
	goto	Usuario_erro_change_pass
	goto	Enviar_msg_senha_change_Pass
	
Usuario_erro_change_pass:
	call	envia_msg_erro_LCD
	call	envia_msg_entrar_LCD
	movlw	LCD_Linha_2	
	call	EnviaCmdLCD
	bcf	user1,F
	bcf	user2,F
	bcf	user3,F
	goto	Loop_user_change_pass1

Enviar_msg_senha_change_Pass:
	call	Exibir_old_pass_LCD
;=============================================================
;Lê 1° operando
Loop_change_user_pass1:
	call	teclado		; para ler operador
	btfss	fpress,0	
	goto	Loop_change_user_pass1		; fica no loop até ler BCD1
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0
	goto	Loop_change_user_pass1		; BCD1 inválido, retorna
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	Loop_change_user_pass1		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	dig1		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;=============================================================
Loop_change_user_pass2:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Loop_change_user_pass2		; vai verificar se é operador
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	Loop_change_user_pass2		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	dig2		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;==============================================================
Loop_change_user_pass3:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Loop_change_user_pass3		; vai verificar se é operador
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	Loop_change_user_pass3		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	dig3		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;===============================================================
Loop_change_user_pass4:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Loop_change_user_pass4		; vai verificar se é operador
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	Loop_change_user_pass4		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	dig4		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;===============================================================
Loop_change_user_pass5:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Loop_change_user_pass5		; vai verificar se é operador
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	Loop_change_user_pass5		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	dig5		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;===============================================================

	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
Enviar_senha_pass_change:			;valida operador ON/C
	movlw	'E'
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z
	goto	Enviar_senha_pass_change - .3	; operador inválido, retorna
	
;flag testa e envia para um dos labels de senha
	btfsc	flag_user1,F
	goto	Pass_change1
	btfsc	flag_user2,F
	goto	Pass_change2
	btfsc	flag_user3,F
	goto	Pass_change3
	btfsc	flag_user4,F
	goto	Pass_change4
	btfsc	flag_user5,F
	goto	Pass_change5
	goto	Change_pass_return
Pass_change1:
	call	Verify_password
	goto	Change_pass_return
Pass_change2:
	call	Verify_password2
	goto	Change_pass_return
Pass_change3:
	call	Verify_password3
	goto	Change_pass_return
Pass_change4:
	call	Verify_password4
	goto	Change_pass_return
Pass_change5:
	call	Verify_password5
Change_pass_return:
	btfsc	flag_error,F
	goto	Senha_erro_pass_changer
	goto	Pass_changer_routine
	
Senha_erro_pass_changer:
	call	envia_msg_senha_erro_LCD
	call	Exibir_old_pass_LCD
	goto	Loop_change_user_pass1
	
Pass_changer_routine:
	call	Exibir_NEW_pass_LCD
;=======================================================================================	
New_pass1:
	call	teclado		; para ler operador
	btfss	fpress,0	
	goto	New_pass1		; fica no loop até ler BCD1
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0
	goto	Lop2		; BCD1 inválido, retorna
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	New_pass1		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	dig1		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;=============================================================
New_pass2:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	New_pass2		; vai verificar se é operador
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	New_pass2		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	dig2		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;==============================================================
New_pass3:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	New_pass3		; vai verificar se é operador
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	New_pass3		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	dig3		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;===============================================================
New_pass4:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	New_pass4		; vai verificar se é operador
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	New_pass4		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	dig4		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;===============================================================
New_pass5:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	New_pass5		; vai verificar se é operador
	movfw	tecla	
	xorlw	0x30
	btfsc	STATUS,Z
	goto	New_pass5		; BCD1 = 0, retorna
	movfw	tecla	
	movwf	dig5		; cent = ASCII(BCD1)
	call	EnviaCarLCD
;===============================================================

	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
Send_pass:			;valida operador ON/C
	movlw	'E'
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z
	goto	Send_pass - .3	; operador inválido, retorna
	call	New_password
	call	Exibir_senha_alterada_LCD
	MOVLW	LCD_CLEAR
	CALL	EnviaCmdLCD
	call	envia_msg_LCD
	goto	main
	

	    
	#include	"up_md_lcd_driver_PIC16F.asm"
	#include	"up_mensagens_PIC16F.asm"
	#include	"up_md_atrasos.asm"
	#include	"verify_password.asm"
	#include	"user.asm"
	
	end