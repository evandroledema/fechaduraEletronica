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
	call	Iniciar_senhas	;configura usuarios iniciais, Ex: 123
	call	Set_password	;configura senhas para cada usuário, Ex:12345
	banco0			;Banco 0
	clrf	PORTA		;Inicializa PORTA
	banco1			;Banco 1
	movlw	0x06		;Configura todos os pinos
	movwf	ADCON1		;como entrada digitais.
	movlw	0x00		;Valor utilizado para direção de dado
	movwf	TRISA		;RA<5:0> como saídas. TRISA<7:6> são sempre lidas como '0'.
	banco0			;Banco 0
	bcf	PORTA,0		;Seta bit RA0 para 0
	bcf	PORTA,1		;Seta bit RA1 para 0
	call	envia_msg_LCD	;mostra mensagem no LCD: "PRESSIONE ON/C PARA INICIAR".

;***************************************************************************************************
;   MAIN()
;   PROGRAMA PRINCIPAL QUE CONTÉM OS LOOPS PARA O FUNCIONAMENTO DA FECHADURA
;   ELETRÔNICA.
;****************************************************************************************************
main:	
	;loop - aguarda o usuário pressionar uma tecla
	;=======================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; testa para saber se foi pressionado
	goto	$-2		; fica no loop até ler tecla press
	;=======================================================
ON_C:	;valida operador ON/C
	movlw	'A'		;[A] = ON/C no teclado matricial
	xorwf	tecla,W		; tecla [ON/C]
	btfss	STATUS,Z		;Caso a tecla pressionada for ON/C pula proxima instrução.
	goto	ON_C - .3		; operador inválido, retorna
	call	envia_msg_menu_LCD	; Envia Mensagem LCD: MENU PRESSIONE 1-ABRIR,2-OPCOES
TECLA_1_2:
	;loop - aguarda o usuário pressionar uma tecla
	;======================================================
	call	teclado		; para ler operador
	btfss	fpress,0		;testa para saber se foi pressionado
	goto	TECLA_1_2		; fica no loop até ler tecla press
	;=======================================================
	movlw	'1'		;1 = [1] no teclado matricial
	xorwf	tecla,W		; tecla [1]
	btfss	STATUS,Z		;Caso a tecla pressionada for 1 pula proxima instrução.
	goto	Testa_2		;Pula para o segundo teste
	call	envia_msg_entrar_LCD	;Envia Mensagem LCD: USUARIO:
	movlw	LCD_Linha_2	;2 linha
	call	EnviaCmdLCD	;Habilita 2 linha LCD
;================================================================
;Lê 1° operando
Lop1:
	;loop - aguarda o usuário pressionar uma tecla
	;=======================================================
	call	teclado		; para ler operador
	btfss	fpress,0		;;testa para saber se foi pressionado
	goto	Lop1		; fica no loop até ler BCD1
	;=======================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; Caso BCD válido pula próxima instrucão
	goto	Lop1		; BCD1 inválido, retorna
	movfw	tecla		; move bcd selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	user1		; move bcd selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD para LCD
;================================================================
Usuario_2dig:
	;loop - aguarda o usuário pressionar uma tecla
	;=======================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 do usuário
	goto	$-2		; fica no loop até ler BCD2 ...
	;=======================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula BCD2 válido
	goto	Usuario_2dig		; retorna se inválido
	movfw	tecla		; move bcd2 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	user2		; move bcd2 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD2 para LCD
;=================================================================
Usuario_3dig:
	;loop - aguarda o usuário pressionar uma tecla
	;=======================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD3 do usuário
	goto	$-2		; fica no loop até ler BCD3 ...
	;=======================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD3 válido
	goto	Usuario_3dig		; vai verificar se é operador
	movfw	tecla		; move bcd3 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	user3		; move bcd3 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD3 para LCD
;=================================================================
	;loop - aguarda o usuário pressionar uma tecla
	;========================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê confirmação de envio
	goto	$-2		; fica no loop até ler confirmação de envio ...
	;=========================================================
Enviar_user:
	;valida operador [=]
	movlw	'E'		; [E] é [=] no teclado matricial
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z		; se for tecla [=] pula a proxima instrução
	goto	Enviar_user - .3	; operador inválido, retorna para loop de espera de pressionar tecla
	call	Verify_user		; Verifica se o usuário digitado existe
	btfsc	flag_user_err,F	;  testa, se flag = 0,  usuário existe, pula proxima instrução.
	goto	Usuario_erro		; vai para tratamento de erro de usuário
	goto	Enviar_msg_senha	; dá continuidade ao programa e envia mensagem: "SENHA:"
	
Usuario_erro:
	;TRATAMENTO DE ERRO DE USUÁRIO NÃO ENCONTRADO
	call	envia_msg_erro_LCD	;Envia mensagem: "USUARIO NAO ENCONTRADO", espera 1s e segue;
	call	envia_msg_entrar_LCD	;Envia mensagem: "USUARIO:"
	movlw	LCD_Linha_2	; habilita linha 2
	call	EnviaCmdLCD	; envia comando habilitando linha 2
	bcf	user1,F		; limpa registradores
	bcf	user2,F		; com o usuário entrado
	bcf	user3,F		; no sistema
	goto	Lop1		; volta para o inicio do loop para que o usuário faça uma nova tentativa

Enviar_msg_senha:
	call	envia_msg_senha_LCD	; Enviar mensagem: "SENHA:"
	movlw	LCD_Linha_2	; habilita linha 2
	call	EnviaCmdLCD	; envia comando que habilita 2 linha
;======================================================================
;Lê 1° operando
Lop2:
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD1 da senha
	goto	Lop2		; fica no loop até ler BCD1
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD1 válido
	goto	Lop2		; BCD1 inválido, retorna
	movfw	tecla		; move bcd1 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	dig1		; move bcd1 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD1 para LCD
;======================================================================
Senha_2dig:
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Senha_2dig		; vai verificar se é operador
	movfw	tecla		; move bcd2 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	dig2		; move bcd2 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD2 para LCD
;======================================================================
Senha_3dig:
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD3 da senha
	goto	$-2		; fica no loop até ler BCD3 ...
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD3 válido
	goto	Senha_3dig		; vai verificar se é operador
	movfw	tecla		; move bcd3 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	dig3		; move bcd3 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD3 para LCD
;======================================================================
Senha_4dig:
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD4 da senha
	goto	$-2		; fica no loop até ler BCD4 ...
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD4 válido
	goto	Senha_4dig		; vai verificar se é operador
	movfw	tecla		; move bcd4 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	dig4		; move bcd4 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD4 para LCD
;======================================================================
Senha_5dig:
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD5 da senha
	goto	$-2		; fica no loop até ler BCD5 ...
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD5 válido
	goto	Senha_5dig		; vai verificar se é operador
	movfw	tecla		; move bcd5 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	dig5		; move bcd5 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD5 para LCD
;======================================================================
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; se teclado pressionado pula próxima instrução
	goto	$-2		; fica no loop até pressionado...
	;=============================================================
Enviar_senha:			
	;valida operador [=]
	movlw	'E'		; [E] é [=] no teclado matricial
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z		; se for tecla [=] pula a proxima instrução
	goto	Enviar_senha - .3	; operador inválido, retorna
	
;flag testa e envia para um dos labels de senha
;   pula para a verificação de senha de acordo com o usuário entrado
	btfsc	flag_user1,F		; pula se não é usuário 1
	goto	Senha1		; vai para verificação da senha do usuário 1
	btfsc	flag_user2,F		; pula se não é usuário 2
	goto	Senha2		; vai para verificação da senha do usuário 2
	btfsc	flag_user3,F		; pula se não é usuário 3
	goto	Senha3		; vai para verificação da senha do usuário 3
	btfsc	flag_user4,F		; pula se não é usuário 4
	goto	Senha4		; vai para verificação da senha do usuário 4
	btfsc	flag_user5,F		; pula se não é usuário 5
	goto	Senha5		; vai para verificação da senha do usuário 5
	goto	retorno		; salto redundante, nunca acontecerá.
Senha1:
	call	Verify_password	; sub-rotina verificar password 1
	goto	retorno		; vai para retorno
Senha2:
	call	Verify_password2	; sub-rotina verificar password 2
	goto	retorno		; vai para retorno
Senha3:
	call	Verify_password3	; sub-rotina verificar password 3
	goto	retorno		; vai para retorno
Senha4:
	call	Verify_password4	; sub-rotina verificar password 4
	goto	retorno		; vai para retorno
Senha5:
	call	Verify_password5	; sub-rotina verificar password 5
retorno:
	btfsc	flag_error,F		; pula próxima instrução se a senha for correta
	goto	Senha_erro		; vai para tratamento de erro de senha
	goto	Abrir_fechadura	; vai para comando de abrir fechadura
	
Senha_erro:
	call	envia_msg_senha_erro_LCD    ;Envia Mensagem: "SENHA INCORRETA" e espera 1s
	call	envia_msg_senha_LCD	; Envia Mensagem: "SENHA:"
	movlw	LCD_Linha_2	; habilita 2 linha
	call	EnviaCmdLCD	; envia comando 2 linha
	goto	Lop2		; volta para inicio loop e permite uma nova tentativa
	
Abrir_fechadura:
	;rotina para abrir a fechadura
	bsf	PORTA,0		; PORTA pino 0 setado para nivel alto, abre fechadura
	call	envia_msg_abrir_LCD	; Envia Mensagem: "FECHADURA ABERTA"
	call	Envia_cmd_fechar_LCD	; Envia Mensagem: "1 PARA FECHAR"
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; se teclado pressionado pula próxima instrução
	goto	$-2		; fica no loop até pressionado...
	;=============================================================
Relay_on:				
	;valida operador 1
	movlw	'1'		; tecla [1] igual 1
	xorwf	tecla,W		; tecla [1]
	btfss	STATUS,Z		; pula se tecla pressionada igual [1]
	goto	Relay_on - .3	; operador inválido, retorna

Relay_off:
	bcf	PORTA,0		; PORTA pino 0 setado para nivel alto, fecha fechadura
	movlw	LCD_CLEAR	; limpa LCD
	call	EnviaCmdLCD	; envia comando LCD
	call	envia_msg_LCD	; Envia Mensagem: "PRESSIONE ON/C PARA INICIAR"
	goto	main		; vai para inicio do programa

;*******************************************************************************************
;   Testa_2: opções para mudança de usuário e senha.
;*******************************************************************************************
Testa_2:	movlw	'2'		; [2] é 2
	xorwf	tecla,W		; tecla [2]
	btfss	STATUS,Z		; pula se a tecla pressionada for 2
	goto	TECLA_1_2		; operadores inválidos, retorna
	call	envia_msg_opcao_LCD	; Envia Mensagem: "OPCOES MUDAR 1-USER,2-PASS"
Loop3:	
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD da opção
	goto	$-2		; fica no loop até ler BCD
	;=============================================================
	movlw	'1'		; [1] é 1 no teclado matricial
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z		; pula se 1 foi pressionado
	goto	Opcao2		; operador inválido, retorna
;Mudar um usuário existente
	call	Enviar_msg_change_user_LCD  ;Envia Mensagem: "USER ATUAL:"
	movlw	LCD_Linha_2	; habilita linha 2
	call	EnviaCmdLCD	; envia comando habilitando 2 linha
;======================================================================
;Lê 1° operando
Lop4:
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD1 do usuario
	goto	Lop4		; fica no loop até ler BCD1
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula se BCD1 válido
	goto	Lop4		; BCD1 inválido, retorna
	movfw	tecla		; move bcd1 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	user1		; move bcd1 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	;Envia BCD1 para LCD
;======================================================================
Usuario_4dig:
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 do usuário
	goto	$-2		; fica no loop até ler BCD2 ...
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula se BCD2 válido
	goto	Usuario_4dig		; vai verificar se é operador
	movfw	tecla		; move bcd2 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	user2		; move bcd2 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	;Envia BCD2 para LCD
;======================================================================
Usuario_5dig:
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD3 do usuário
	goto	$-2		; fica no loop até ler BCD3 ...
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula se BCD3 válido
	goto	Usuario_5dig		; vai verificar se é operador
	movfw	tecla		; move bcd3 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	user3		; move bcd3 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD3 para LCD
;======================================================================
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; pula se teclado for pressionado
	goto	$-2		; fica no loop teclado ser pressionado ...
	;=============================================================
Enviar_user2:	
	;valida operador [=]
	movlw	'E'		; [E] é [=] no teclado matricial
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z		; pula se [=] foi pressionado
	goto	Enviar_user2 - .3	; operador inválido, retorna
	call	Verify_user		; verifica se usuário existe
	btfsc	flag_user_err,F	; testa o flag, se usuário existe salta a próxima instrução
	goto	Usuario_change_error	; vai para tratamento  de erro de usuário
	goto	Change_user_password	; vai para teste de senha atual
	
Usuario_change_error:
	call	envia_msg_erro_LCD	; Enviar Mensagem: "USUARIO NAO ENCONTRADO"
	call	Enviar_msg_change_user_LCD; Enviar Mensagem: "USUARIO ATUAL"
	movlw	LCD_Linha_2	; habilita 2 linha
	call	EnviaCmdLCD	; envia comando para habilitar 2 linha
	bcf	user1,F		; limpa registradores
	bcf	user2,F		; dos usuários
	bcf	user3,F		; para uma nova tentativa
	goto	Lop4		; volta para loop e espera pressionar teclas
	
Change_user_password:
	call	envia_msg_senha_LCD	; Envia Mensagem: "SENHA:"
	movlw	LCD_Linha_2	; habilita linha 2
	call	EnviaCmdLCD	; envia comando habilitando 2 linha
;======================================================================
;Lê 1° operando
Lop_user_1:
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; se teclado pressionado salta próxima instrução
	goto	Lop_user_1		; fica no loop até ler BCD1
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula se BCD1 válido
	goto	Lop_user_1		; BCD1 inválido, retorna
	movfw	tecla		; move bcd1 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	dig1		; move bcd1 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD1 para LCD
;======================================================================
Senha_user_2:
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Senha_user_2	; vai verificar se é operador
	movfw	tecla		; move bcd2 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	dig2		; move bcd2 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD2 para LCD
;======================================================================
Senha_user_3:
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD3 da senha
	goto	$-2		; fica no loop até ler BCD3 ...
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD3 válido
	goto	Senha_user_3	; vai verificar se é operador
	movfw	tecla		; move bcd3 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	dig3		; move bcd3 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD3 para LCD
;======================================================================
Senha_user_4:
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD4 da senha
	goto	$-2		; fica no loop até ler BCD4 ...
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD4 válido
	goto	Senha_user_4	; vai verificar se é operador
	movfw	tecla		; move bcd4 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	dig4		; move bcd4 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD4 para LCD
;======================================================================
Senha_user_5:
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD5 da senha
	goto	$-2		; fica no loop até ler BCD5 ...
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD5 válido
	goto	Senha_user_5	; vai verificar se é operador
	movfw	tecla		; move bcd5 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	dig5		; move bcd5 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD5 para LCD
;======================================================================
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD para enviar
	goto	$-2		; fica no loop até ler BCD ...
	;=============================================================
Send_user_pass:		
	;valida operador [=]
	movlw	'E'		; [E] é =  no teclado matricial
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z		; se [=] foi pressionado salta próxima instrução
	goto	Send_user_pass - .3	; operador inválido, retorna
	
;flag testa e envia para um dos labels de senha
; testa e salta para a rotina de acordo com o flag da do usuário entrado
	btfsc	flag_user1,F		;Pula se não for usuário 1
	goto	Pass_1		;vai para rotina para mudar usuário 1
	btfsc	flag_user2,F		;Pula se não for usuário 2
	goto	Pass_2		;vai para rotina para mudar usuário 2
	btfsc	flag_user3,F		;Pula se não for usuário 3
	goto	Pass_3		;vai para rotina para mudar usuário 3
	btfsc	flag_user4,F		;Pula se não for usuário 4
	goto	Pass_4		;vai para rotina para mudar usuário 4
	btfsc	flag_user5,F		;Pula se não for usuário 5
	goto	Pass_5		;vai para rotina para mudar usuário 5
	goto	User_retorno		;loop redundante, nunca será usado
Pass_1:
	call	Verify_password	;Verifica senha do usuário 1
	goto	User_retorno		;salta para retorno
Pass_2:
	call	Verify_password2	;Verifica senha do usuário 2
	goto	User_retorno		;salta para retorno
Pass_3:
	call	Verify_password3	;Verifica senha do usuário 3
	goto	User_retorno		;salta para retorno
Pass_4:
	call	Verify_password4	;Verifica senha do usuário 4
	goto	User_retorno		;salta para retorno
Pass_5:
	call	Verify_password5	;Verifica senha do usuário 5
User_retorno:
	btfsc	flag_error,F		; pula a próxima instrução se senha correta
	goto	User_pass_error	; vai para tratamento de erro de senha
	goto	Mudar_user		; vai para rotina de mudança de usuário
	
User_pass_error:
	call	envia_msg_senha_erro_LCD    ; Envia Mensagem: "SENHA INCORRETA" e espera 1s
	call	envia_msg_senha_LCD	; Envia Mensagem: "SENHA:"
	movlw	LCD_Linha_2	; habilita 2 linha
	call	EnviaCmdLCD	; envia comando habilitando 2 linha
    	goto	Lop_user_1		; volta para inicio do loop para outra tentativa de senha
	
Mudar_user:
	call	Enviar_msg_change_user2_LCD ; Envia Mensagem : "3 DIG NEW USER"
	MOVLW	LCD_Linha_2	;2 linha
	CALL	EnviaCmdLCD	;envia comando habilitanto 2 linha
	;=============================================================
;Lê 1° operando
New_user1:
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; pula se tecla for pressionada
	goto	New_user1		; fica no loop até ler BCD1
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula se BCD1 válido
	goto	New_user1		; BCD1 inválido, retorna
	movfw	tecla		; move bcd1 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	user1		; move bcd1 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD1 para LCD
;=======================================================================
New_user2:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 do usuário
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	New_user2		; vai verificar se é operador
	movfw	tecla		; move bcd2 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	user2		; move bcd2 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD2 para LCD
;==============================================================
New_user3:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD3 do usuário
	goto	$-2		; fica no loop até ler BCD3 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD3 válido
	goto	New_user3		; vai verificar se é operador
	movfw	tecla		; move bcd3 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	user3		; move bcd3 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD3 para LCD
;===============================================================
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	;=============================================================
Enviar_new_user:	
	;valida operador [=]
	movlw	'E'		; [E] é [=] no teclado matricial
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z		; pula próxima instrução se 1 foi pressionado
	goto	Enviar_new_user - .3	; operador inválido, retorna
	call	New_user		; vai para rotina de mudança de usuário
	call	Exibir_novo_user_LCD	; Envia Mensagem: "NOVO USUARIO REGISTRADO"
	MOVLW	LCD_CLEAR	; limpa tela
	CALL	EnviaCmdLCD	; envia comando limpar tela LCD
	call	envia_msg_LCD	; Envia comando: "PRESSIONE ON/C PARA INICIAR"
	goto	main		; volta para inicio do programa
;Mudar senha de um usuário específico
Opcao2:	
	movlw	'2'		; [2] é 2 no teclado matricial
	xorwf	tecla,W		; tecla [2]
	btfss	STATUS,Z		; salta próxima instrução se 2 foi pressionado
	goto	Loop3		; volta para inicio do loop e aguarda pressionar o teclado
	call	envia_msg_entrar_LCD	; Envia Mensagem: "USUARIO:"
	movlw	LCD_Linha_2	; 2 linha
	call	EnviaCmdLCD	; envia comando habilitando 2 linha
;=======================================================================
;Lê 1° operando
Loop_user_change_pass1:
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; salta próxima instrução se teclado for pressionado
	goto	Loop_user_change_pass1	; fica no loop até ler BCD1
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; lê BCD1 do usuário
	goto	Loop_user_change_pass1	; BCD1 inválido, retorna
	movfw	tecla		; move bcd1 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	user1		; move bcd1 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD1 para LCD
;=============================================================
Loop_user_change_pass2:
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 do usuário
	goto	$-2		; fica no loop até ler BCD2 ...
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Loop_user_change_pass2	; vai verificar se é operador
	movfw	tecla		; move bcd2 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	user2		; move bcd2 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD2 para LCD
;==============================================================
Loop_user_change_pass3:
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD3 do usuário
	goto	$-2		; fica no loop até ler BCD3 ...
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD3 válido
	goto	Loop_user_change_pass3	; vai verificar se é operador
	movfw	tecla		; move bcd3 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	user3		; move bcd3 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD3 para LCD
;===============================================================
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; salta próxima instrução até pressionar a tecla
	goto	$-2		; fica no loop até pressionar a tecla ...
	;=============================================================
Enviar_user_change_pass:		
	;valida operador [=]
	movlw	'E'		; [E] é [=] no teclado matricial
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z		; salta a próxima instrução se [=] foi pressionado
	goto	Enviar_user_change_pass - .3	; operador inválido, retorna
	call	Verify_user		; vai para verificação de usuário
	btfsc	flag_user_err,F	; testa e pula próxima instrução se usuário correto
	goto	Usuario_erro_change_pass	;tratamento de erro de usuário
	goto	Enviar_msg_senha_change_Pass	;vai para continuidade de código
	
Usuario_erro_change_pass:
	call	envia_msg_erro_LCD	; Envia Mensagem: "USUARIO NAO ENCONTRADO"
	call	envia_msg_entrar_LCD	; Envia Mensagem: "USUARIO:"
	movlw	LCD_Linha_2	; linha 2
	call	EnviaCmdLCD	; envia comando habilitando 2  linha
	bcf	user1,F		; limpa registradores
	bcf	user2,F		; para que permita
	bcf	user3,F		; uma nova tentativa
	goto	Loop_user_change_pass1	;volta para o inicio do loop

Enviar_msg_senha_change_Pass:
	call	Exibir_old_pass_LCD	; Envia Mensagem: " SENHA ATUAL:"
;=============================================================
;Lê 1° operando
Loop_change_user_pass1:
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; salta próxima instrução se o teclado foi pressionado
	goto	Loop_change_user_pass1	; fica no loop até ler BCD1
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; lê BCD1 da senha
	goto	Loop_change_user_pass1	; BCD1 inválido, retorna
	movfw	tecla		; move bcd1 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	dig1		; move bcd1 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD1 para LCD
;=============================================================
Loop_change_user_pass2:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Loop_change_user_pass2	; vai verificar se é operador
	movfw	tecla		; move bcd2 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	dig2		; move bcd2 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD2 para LCD
;==============================================================
Loop_change_user_pass3:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD3 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Loop_change_user_pass3	; vai verificar se é operador
	movfw	tecla		; move bcd3 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	dig3		; move bcd3 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD3 para LCD
;===============================================================
Loop_change_user_pass4:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Loop_change_user_pass4	; vai verificar se é operador
	movfw	tecla		; move bcd4 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	dig4		; move bcd4 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD4 para LCD
;===============================================================
Loop_change_user_pass5:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	Loop_change_user_pass5	; vai verificar se é operador
	movfw	tecla		; move bcd5 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	dig5		; move bcd5 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD5 para LCD
;===============================================================
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD
	goto	$-2		; fica no loop até ler BCD ...
	;=============================================================
Enviar_senha_pass_change:			
	;valida operador [=]
	movlw	'E'		; [E] é [=] no teclado matricial
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z		; salta se [=] foi pressionado
	goto	Enviar_senha_pass_change - .3	; operador inválido, retorna
	
;flag testa e envia para um dos labels de senha
	btfsc	flag_user1,F		; Pula se não for usuário 1
	goto	Pass_change1	; vai para rotina para testar senha usuário 1
	btfsc	flag_user2,F		; Pula se não for usuário 2
	goto	Pass_change2	; vai para rotina para testar senha usuário 2
	btfsc	flag_user3,F		; Pula se não for usuário 3
	goto	Pass_change3	; vai para rotina para testar senha usuário 3
	btfsc	flag_user4,F		; Pula se não for usuário 4
	goto	Pass_change4	; vai para rotina para testar senha usuário 4
	btfsc	flag_user5,F		; Pula se não for usuário 5
	goto	Pass_change5	; vai para rotina para testar senha usuário 5
	goto	Change_pass_return	; redundância, nunca será usada
Pass_change1:
	call	Verify_password	; verifica password do usuário 1
	goto	Change_pass_return	; vai para rotina de mudança de senha
Pass_change2:
	call	Verify_password2	; verifica password do usuário 2
	goto	Change_pass_return	; vai para rotina de mudança de senha
Pass_change3:
	call	Verify_password3	; verifica password do usuário 3
	goto	Change_pass_return	; vai para rotina de mudança de senha
Pass_change4:
	call	Verify_password4	; verifica password do usuário 4
	goto	Change_pass_return	; vai para rotina de mudança de senha
Pass_change5:
	call	Verify_password5	; verifica password do usuário 5
Change_pass_return:
	btfsc	flag_error,F		; testa e se senha correta salta a próxima instrução
	goto	Senha_erro_pass_changer ; vai para tratamento de erro de senha
	goto	Pass_changer_routine	; vai para rotina de mudança de senha
	
Senha_erro_pass_changer:
	call	envia_msg_senha_erro_LCD	; Envia Mensagem: " SENHA INCORRETA" e espera 1s
	call	Exibir_old_pass_LCD	; Envia Mensagem: "SENHA ATUAL:"
	goto	Loop_change_user_pass1	; volta para loop para uma noca tentativa de senha
	
Pass_changer_routine:
	call	Exibir_NEW_pass_LCD	; Envia Mensagem: "NOVA SENHA:"
;=======================================================================================	
New_pass1:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD1 da senha
	goto	New_pass1		; fica no loop até ler BCD1
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula se BCD1 válido
	goto	Lop2		; BCD1 inválido, retorna
	movfw	tecla		; move bcd1 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	dig1		; move bcd1 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD1 para LCD
;=============================================================
New_pass2:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD2 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 válido
	goto	New_pass2		; vai verificar se é operador
	movfw	tecla		; move bcd2 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	dig2		; move bcd2 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD2 para LCD
;==============================================================
New_pass3:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD3 da senha
	goto	$-2		; fica no loop até ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD3 válido
	goto	New_pass3		; vai verificar se é operador
	movfw	tecla		; move bcd2 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	dig3		; move bcd2 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD2 para LCD
;===============================================================
New_pass4:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD4 da senha
	goto	$-2		; fica no loop até ler BCD4 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD4 válido
	goto	New_pass4		; vai verificar se é operador
	movfw	tecla		; move bcd4 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	dig4		; move bcd4 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD4 para LCD
;===============================================================
New_pass5:
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD5 da senha
	goto	$-2		; fica no loop até ler BCD5 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD5 válido
	goto	New_pass5		; vai verificar se é operador
	movfw	tecla		; move bcd5 selecionado para registrador tecla que será usado para enviar informação LCD
	movwf	dig5		; move bcd5 selecionado para registrador user1 que será usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD5 para LCD
;===============================================================
	;loop - aguarda o usuário pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; lê BCD
	goto	$-2		; fica no loop até ler BCD ...
	;=============================================================
Send_pass:	
	;valida operador [E] = [=]
	movlw	'E'		; [E] = [=]
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z		; salta próxima instrução se [=] foi pressionada
	goto	Send_pass - .3	; operador inválido, retorna
	call	New_password	; vai para rotina de mudar senha de um certo usuário
	call	Exibir_senha_alterada_LCD	; Envia Mensagem: "SENHA ALTERADA" e aguarda 1s
	MOVLW	LCD_CLEAR	; limpa LCD
	CALL	EnviaCmdLCD	; envia comando para limpar LCD
	call	envia_msg_LCD	; Envia Mensagem: "PRESSIONE ON/C PARA INICIAR"
	goto	main		; volta para o início do programa
	

	    
	#include	"up_md_lcd_driver_PIC16F.asm"
	#include	"up_mensagens_PIC16F.asm"
	#include	"up_md_atrasos.asm"
	#include	"verify_password.asm"
	#include	"user.asm"
	
	end