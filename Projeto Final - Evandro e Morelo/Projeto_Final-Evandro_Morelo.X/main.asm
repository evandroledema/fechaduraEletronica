;*******************************************************************************
;    UNIVERSIDADE FEDERAL DE MATO GROSSO                                                             
;    ENGENHARIA EL�TRICA                                                                                               
;    MICROPROCESSADORES                                                                                               
;    DATE: 2021/2                                                                                                                    
;    DISCENTES:                                                                                                                    
;    EVANDRO FERNANDES LEDEMA	                                                                 
;    MATHEUS MORELO PEREIRA
;    USU�RIOS: 123, 666, 111, 157, 124
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

;se fpress<0> retorna com 0, a tecla n�o � de um BCD
checa_BCD:
	bcf	fpress,0		;limpa flag
	movlw	0x30			
	subwf	tecla,W		;tecla - 0x30 
	btfss	STATUS,C		;C=1: 0x30 <= tecla
	return			;BCD inv�lido
	movfw	tecla	
	sublw	0x39		;0x39 - tecla
	btfsc	STATUS,C		;C=1: tecla <= 0x39
	bsf	fpress,0		;indica BCD v�lido
	return
	
;*******************************************************************************
; MAIN PROGRAM
;*******************************************************************************

setup:	
	call	Inicia_teclado	;configura PORTB e PORTC
	call	Inicia_LCD		;configura o m�dulo LCD e Portas
	call	Iniciar_senhas	;configura usuarios iniciais, Ex: 123
	call	Set_password	;configura senhas para cada usu�rio, Ex:12345
	banco0			;Banco 0
	clrf	PORTA		;Inicializa PORTA
	banco1			;Banco 1
	movlw	0x06		;Configura todos os pinos
	movwf	ADCON1		;como entrada digitais.
	movlw	0x00		;Valor utilizado para dire��o de dado
	movwf	TRISA		;RA<5:0> como sa�das. TRISA<7:6> s�o sempre lidas como '0'.
	banco0			;Banco 0
	bcf	PORTA,0		;Seta bit RA0 para 0
	bcf	PORTA,1		;Seta bit RA1 para 0
	call	envia_msg_LCD	;mostra mensagem no LCD: "PRESSIONE ON/C PARA INICIAR".

;***************************************************************************************************
;   MAIN()
;   PROGRAMA PRINCIPAL QUE CONT�M OS LOOPS PARA O FUNCIONAMENTO DA FECHADURA
;   ELETR�NICA.
;****************************************************************************************************
main:	
	;loop - aguarda o usu�rio pressionar uma tecla
	;=======================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; testa para saber se foi pressionado
	goto	$-2		; fica no loop at� ler tecla press
	;=======================================================
ON_C:	;valida operador ON/C
	movlw	'A'		;[A] = ON/C no teclado matricial
	xorwf	tecla,W		; tecla [ON/C]
	btfss	STATUS,Z		;Caso a tecla pressionada for ON/C pula proxima instru��o.
	goto	ON_C - .3		; operador inv�lido, retorna
	call	envia_msg_menu_LCD	; Envia Mensagem LCD: MENU PRESSIONE 1-ABRIR,2-OPCOES
TECLA_1_2:
	;loop - aguarda o usu�rio pressionar uma tecla
	;======================================================
	call	teclado		; para ler operador
	btfss	fpress,0		;testa para saber se foi pressionado
	goto	TECLA_1_2		; fica no loop at� ler tecla press
	;=======================================================
	movlw	'1'		;1 = [1] no teclado matricial
	xorwf	tecla,W		; tecla [1]
	btfss	STATUS,Z		;Caso a tecla pressionada for 1 pula proxima instru��o.
	goto	Testa_2		;Pula para o segundo teste
	call	envia_msg_entrar_LCD	;Envia Mensagem LCD: USUARIO:
	movlw	LCD_Linha_2	;2 linha
	call	EnviaCmdLCD	;Habilita 2 linha LCD
;================================================================
;L� 1� operando
Lop1:
	;loop - aguarda o usu�rio pressionar uma tecla
	;=======================================================
	call	teclado		; para ler operador
	btfss	fpress,0		;;testa para saber se foi pressionado
	goto	Lop1		; fica no loop at� ler BCD1
	;=======================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; Caso BCD v�lido pula pr�xima instruc�o
	goto	Lop1		; BCD1 inv�lido, retorna
	movfw	tecla		; move bcd selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	user1		; move bcd selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD para LCD
;================================================================
Usuario_2dig:
	;loop - aguarda o usu�rio pressionar uma tecla
	;=======================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD2 do usu�rio
	goto	$-2		; fica no loop at� ler BCD2 ...
	;=======================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula BCD2 v�lido
	goto	Usuario_2dig		; retorna se inv�lido
	movfw	tecla		; move bcd2 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	user2		; move bcd2 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD2 para LCD
;=================================================================
Usuario_3dig:
	;loop - aguarda o usu�rio pressionar uma tecla
	;=======================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD3 do usu�rio
	goto	$-2		; fica no loop at� ler BCD3 ...
	;=======================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD3 v�lido
	goto	Usuario_3dig		; vai verificar se � operador
	movfw	tecla		; move bcd3 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	user3		; move bcd3 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD3 para LCD
;=================================================================
	;loop - aguarda o usu�rio pressionar uma tecla
	;========================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; l� confirma��o de envio
	goto	$-2		; fica no loop at� ler confirma��o de envio ...
	;=========================================================
Enviar_user:
	;valida operador [=]
	movlw	'E'		; [E] � [=] no teclado matricial
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z		; se for tecla [=] pula a proxima instru��o
	goto	Enviar_user - .3	; operador inv�lido, retorna para loop de espera de pressionar tecla
	call	Verify_user		; Verifica se o usu�rio digitado existe
	btfsc	flag_user_err,F	;  testa, se flag = 0,  usu�rio existe, pula proxima instru��o.
	goto	Usuario_erro		; vai para tratamento de erro de usu�rio
	goto	Enviar_msg_senha	; d� continuidade ao programa e envia mensagem: "SENHA:"
	
Usuario_erro:
	;TRATAMENTO DE ERRO DE USU�RIO N�O ENCONTRADO
	call	envia_msg_erro_LCD	;Envia mensagem: "USUARIO NAO ENCONTRADO", espera 1s e segue;
	call	envia_msg_entrar_LCD	;Envia mensagem: "USUARIO:"
	movlw	LCD_Linha_2	; habilita linha 2
	call	EnviaCmdLCD	; envia comando habilitando linha 2
	bcf	user1,F		; limpa registradores
	bcf	user2,F		; com o usu�rio entrado
	bcf	user3,F		; no sistema
	goto	Lop1		; volta para o inicio do loop para que o usu�rio fa�a uma nova tentativa

Enviar_msg_senha:
	call	envia_msg_senha_LCD	; Enviar mensagem: "SENHA:"
	movlw	LCD_Linha_2	; habilita linha 2
	call	EnviaCmdLCD	; envia comando que habilita 2 linha
;======================================================================
;L� 1� operando
Lop2:
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD1 da senha
	goto	Lop2		; fica no loop at� ler BCD1
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD1 v�lido
	goto	Lop2		; BCD1 inv�lido, retorna
	movfw	tecla		; move bcd1 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	dig1		; move bcd1 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD1 para LCD
;======================================================================
Senha_2dig:
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD2 da senha
	goto	$-2		; fica no loop at� ler BCD2 ...
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 v�lido
	goto	Senha_2dig		; vai verificar se � operador
	movfw	tecla		; move bcd2 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	dig2		; move bcd2 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD2 para LCD
;======================================================================
Senha_3dig:
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD3 da senha
	goto	$-2		; fica no loop at� ler BCD3 ...
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD3 v�lido
	goto	Senha_3dig		; vai verificar se � operador
	movfw	tecla		; move bcd3 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	dig3		; move bcd3 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD3 para LCD
;======================================================================
Senha_4dig:
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD4 da senha
	goto	$-2		; fica no loop at� ler BCD4 ...
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD4 v�lido
	goto	Senha_4dig		; vai verificar se � operador
	movfw	tecla		; move bcd4 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	dig4		; move bcd4 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD4 para LCD
;======================================================================
Senha_5dig:
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD5 da senha
	goto	$-2		; fica no loop at� ler BCD5 ...
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD5 v�lido
	goto	Senha_5dig		; vai verificar se � operador
	movfw	tecla		; move bcd5 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	dig5		; move bcd5 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD5 para LCD
;======================================================================
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; se teclado pressionado pula pr�xima instru��o
	goto	$-2		; fica no loop at� pressionado...
	;=============================================================
Enviar_senha:			
	;valida operador [=]
	movlw	'E'		; [E] � [=] no teclado matricial
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z		; se for tecla [=] pula a proxima instru��o
	goto	Enviar_senha - .3	; operador inv�lido, retorna
	
;flag testa e envia para um dos labels de senha
;   pula para a verifica��o de senha de acordo com o usu�rio entrado
	btfsc	flag_user1,F		; pula se n�o � usu�rio 1
	goto	Senha1		; vai para verifica��o da senha do usu�rio 1
	btfsc	flag_user2,F		; pula se n�o � usu�rio 2
	goto	Senha2		; vai para verifica��o da senha do usu�rio 2
	btfsc	flag_user3,F		; pula se n�o � usu�rio 3
	goto	Senha3		; vai para verifica��o da senha do usu�rio 3
	btfsc	flag_user4,F		; pula se n�o � usu�rio 4
	goto	Senha4		; vai para verifica��o da senha do usu�rio 4
	btfsc	flag_user5,F		; pula se n�o � usu�rio 5
	goto	Senha5		; vai para verifica��o da senha do usu�rio 5
	goto	retorno		; salto redundante, nunca acontecer�.
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
	btfsc	flag_error,F		; pula pr�xima instru��o se a senha for correta
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
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; se teclado pressionado pula pr�xima instru��o
	goto	$-2		; fica no loop at� pressionado...
	;=============================================================
Relay_on:				
	;valida operador 1
	movlw	'1'		; tecla [1] igual 1
	xorwf	tecla,W		; tecla [1]
	btfss	STATUS,Z		; pula se tecla pressionada igual [1]
	goto	Relay_on - .3	; operador inv�lido, retorna

Relay_off:
	bcf	PORTA,0		; PORTA pino 0 setado para nivel alto, fecha fechadura
	movlw	LCD_CLEAR	; limpa LCD
	call	EnviaCmdLCD	; envia comando LCD
	call	envia_msg_LCD	; Envia Mensagem: "PRESSIONE ON/C PARA INICIAR"
	goto	main		; vai para inicio do programa

;*******************************************************************************************
;   Testa_2: op��es para mudan�a de usu�rio e senha.
;*******************************************************************************************
Testa_2:	movlw	'2'		; [2] � 2
	xorwf	tecla,W		; tecla [2]
	btfss	STATUS,Z		; pula se a tecla pressionada for 2
	goto	TECLA_1_2		; operadores inv�lidos, retorna
	call	envia_msg_opcao_LCD	; Envia Mensagem: "OPCOES MUDAR 1-USER,2-PASS"
Loop3:	
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD da op��o
	goto	$-2		; fica no loop at� ler BCD
	;=============================================================
	movlw	'1'		; [1] � 1 no teclado matricial
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z		; pula se 1 foi pressionado
	goto	Opcao2		; operador inv�lido, retorna
;Mudar um usu�rio existente
	call	Enviar_msg_change_user_LCD  ;Envia Mensagem: "USER ATUAL:"
	movlw	LCD_Linha_2	; habilita linha 2
	call	EnviaCmdLCD	; envia comando habilitando 2 linha
;======================================================================
;L� 1� operando
Lop4:
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD1 do usuario
	goto	Lop4		; fica no loop at� ler BCD1
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula se BCD1 v�lido
	goto	Lop4		; BCD1 inv�lido, retorna
	movfw	tecla		; move bcd1 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	user1		; move bcd1 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	;Envia BCD1 para LCD
;======================================================================
Usuario_4dig:
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD2 do usu�rio
	goto	$-2		; fica no loop at� ler BCD2 ...
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula se BCD2 v�lido
	goto	Usuario_4dig		; vai verificar se � operador
	movfw	tecla		; move bcd2 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	user2		; move bcd2 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	;Envia BCD2 para LCD
;======================================================================
Usuario_5dig:
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD3 do usu�rio
	goto	$-2		; fica no loop at� ler BCD3 ...
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula se BCD3 v�lido
	goto	Usuario_5dig		; vai verificar se � operador
	movfw	tecla		; move bcd3 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	user3		; move bcd3 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD3 para LCD
;======================================================================
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; pula se teclado for pressionado
	goto	$-2		; fica no loop teclado ser pressionado ...
	;=============================================================
Enviar_user2:	
	;valida operador [=]
	movlw	'E'		; [E] � [=] no teclado matricial
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z		; pula se [=] foi pressionado
	goto	Enviar_user2 - .3	; operador inv�lido, retorna
	call	Verify_user		; verifica se usu�rio existe
	btfsc	flag_user_err,F	; testa o flag, se usu�rio existe salta a pr�xima instru��o
	goto	Usuario_change_error	; vai para tratamento  de erro de usu�rio
	goto	Change_user_password	; vai para teste de senha atual
	
Usuario_change_error:
	call	envia_msg_erro_LCD	; Enviar Mensagem: "USUARIO NAO ENCONTRADO"
	call	Enviar_msg_change_user_LCD; Enviar Mensagem: "USUARIO ATUAL"
	movlw	LCD_Linha_2	; habilita 2 linha
	call	EnviaCmdLCD	; envia comando para habilitar 2 linha
	bcf	user1,F		; limpa registradores
	bcf	user2,F		; dos usu�rios
	bcf	user3,F		; para uma nova tentativa
	goto	Lop4		; volta para loop e espera pressionar teclas
	
Change_user_password:
	call	envia_msg_senha_LCD	; Envia Mensagem: "SENHA:"
	movlw	LCD_Linha_2	; habilita linha 2
	call	EnviaCmdLCD	; envia comando habilitando 2 linha
;======================================================================
;L� 1� operando
Lop_user_1:
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; se teclado pressionado salta pr�xima instru��o
	goto	Lop_user_1		; fica no loop at� ler BCD1
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula se BCD1 v�lido
	goto	Lop_user_1		; BCD1 inv�lido, retorna
	movfw	tecla		; move bcd1 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	dig1		; move bcd1 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD1 para LCD
;======================================================================
Senha_user_2:
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD2 da senha
	goto	$-2		; fica no loop at� ler BCD2 ...
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 v�lido
	goto	Senha_user_2	; vai verificar se � operador
	movfw	tecla		; move bcd2 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	dig2		; move bcd2 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD2 para LCD
;======================================================================
Senha_user_3:
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD3 da senha
	goto	$-2		; fica no loop at� ler BCD3 ...
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD3 v�lido
	goto	Senha_user_3	; vai verificar se � operador
	movfw	tecla		; move bcd3 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	dig3		; move bcd3 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD3 para LCD
;======================================================================
Senha_user_4:
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD4 da senha
	goto	$-2		; fica no loop at� ler BCD4 ...
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD4 v�lido
	goto	Senha_user_4	; vai verificar se � operador
	movfw	tecla		; move bcd4 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	dig4		; move bcd4 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD4 para LCD
;======================================================================
Senha_user_5:
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD5 da senha
	goto	$-2		; fica no loop at� ler BCD5 ...
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD5 v�lido
	goto	Senha_user_5	; vai verificar se � operador
	movfw	tecla		; move bcd5 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	dig5		; move bcd5 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD5 para LCD
;======================================================================
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD para enviar
	goto	$-2		; fica no loop at� ler BCD ...
	;=============================================================
Send_user_pass:		
	;valida operador [=]
	movlw	'E'		; [E] � =  no teclado matricial
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z		; se [=] foi pressionado salta pr�xima instru��o
	goto	Send_user_pass - .3	; operador inv�lido, retorna
	
;flag testa e envia para um dos labels de senha
; testa e salta para a rotina de acordo com o flag da do usu�rio entrado
	btfsc	flag_user1,F		;Pula se n�o for usu�rio 1
	goto	Pass_1		;vai para rotina para mudar usu�rio 1
	btfsc	flag_user2,F		;Pula se n�o for usu�rio 2
	goto	Pass_2		;vai para rotina para mudar usu�rio 2
	btfsc	flag_user3,F		;Pula se n�o for usu�rio 3
	goto	Pass_3		;vai para rotina para mudar usu�rio 3
	btfsc	flag_user4,F		;Pula se n�o for usu�rio 4
	goto	Pass_4		;vai para rotina para mudar usu�rio 4
	btfsc	flag_user5,F		;Pula se n�o for usu�rio 5
	goto	Pass_5		;vai para rotina para mudar usu�rio 5
	goto	User_retorno		;loop redundante, nunca ser� usado
Pass_1:
	call	Verify_password	;Verifica senha do usu�rio 1
	goto	User_retorno		;salta para retorno
Pass_2:
	call	Verify_password2	;Verifica senha do usu�rio 2
	goto	User_retorno		;salta para retorno
Pass_3:
	call	Verify_password3	;Verifica senha do usu�rio 3
	goto	User_retorno		;salta para retorno
Pass_4:
	call	Verify_password4	;Verifica senha do usu�rio 4
	goto	User_retorno		;salta para retorno
Pass_5:
	call	Verify_password5	;Verifica senha do usu�rio 5
User_retorno:
	btfsc	flag_error,F		; pula a pr�xima instru��o se senha correta
	goto	User_pass_error	; vai para tratamento de erro de senha
	goto	Mudar_user		; vai para rotina de mudan�a de usu�rio
	
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
;L� 1� operando
New_user1:
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; pula se tecla for pressionada
	goto	New_user1		; fica no loop at� ler BCD1
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula se BCD1 v�lido
	goto	New_user1		; BCD1 inv�lido, retorna
	movfw	tecla		; move bcd1 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	user1		; move bcd1 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD1 para LCD
;=======================================================================
New_user2:
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD2 do usu�rio
	goto	$-2		; fica no loop at� ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 v�lido
	goto	New_user2		; vai verificar se � operador
	movfw	tecla		; move bcd2 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	user2		; move bcd2 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD2 para LCD
;==============================================================
New_user3:
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD3 do usu�rio
	goto	$-2		; fica no loop at� ler BCD3 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD3 v�lido
	goto	New_user3		; vai verificar se � operador
	movfw	tecla		; move bcd3 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	user3		; move bcd3 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD3 para LCD
;===============================================================
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD2 da senha
	goto	$-2		; fica no loop at� ler BCD2 ...
	;=============================================================
Enviar_new_user:	
	;valida operador [=]
	movlw	'E'		; [E] � [=] no teclado matricial
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z		; pula pr�xima instru��o se 1 foi pressionado
	goto	Enviar_new_user - .3	; operador inv�lido, retorna
	call	New_user		; vai para rotina de mudan�a de usu�rio
	call	Exibir_novo_user_LCD	; Envia Mensagem: "NOVO USUARIO REGISTRADO"
	MOVLW	LCD_CLEAR	; limpa tela
	CALL	EnviaCmdLCD	; envia comando limpar tela LCD
	call	envia_msg_LCD	; Envia comando: "PRESSIONE ON/C PARA INICIAR"
	goto	main		; volta para inicio do programa
;Mudar senha de um usu�rio espec�fico
Opcao2:	
	movlw	'2'		; [2] � 2 no teclado matricial
	xorwf	tecla,W		; tecla [2]
	btfss	STATUS,Z		; salta pr�xima instru��o se 2 foi pressionado
	goto	Loop3		; volta para inicio do loop e aguarda pressionar o teclado
	call	envia_msg_entrar_LCD	; Envia Mensagem: "USUARIO:"
	movlw	LCD_Linha_2	; 2 linha
	call	EnviaCmdLCD	; envia comando habilitando 2 linha
;=======================================================================
;L� 1� operando
Loop_user_change_pass1:
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; salta pr�xima instru��o se teclado for pressionado
	goto	Loop_user_change_pass1	; fica no loop at� ler BCD1
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; l� BCD1 do usu�rio
	goto	Loop_user_change_pass1	; BCD1 inv�lido, retorna
	movfw	tecla		; move bcd1 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	user1		; move bcd1 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD1 para LCD
;=============================================================
Loop_user_change_pass2:
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD2 do usu�rio
	goto	$-2		; fica no loop at� ler BCD2 ...
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 v�lido
	goto	Loop_user_change_pass2	; vai verificar se � operador
	movfw	tecla		; move bcd2 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	user2		; move bcd2 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD2 para LCD
;==============================================================
Loop_user_change_pass3:
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD3 do usu�rio
	goto	$-2		; fica no loop at� ler BCD3 ...
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD3 v�lido
	goto	Loop_user_change_pass3	; vai verificar se � operador
	movfw	tecla		; move bcd3 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	user3		; move bcd3 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD3 para LCD
;===============================================================
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; salta pr�xima instru��o at� pressionar a tecla
	goto	$-2		; fica no loop at� pressionar a tecla ...
	;=============================================================
Enviar_user_change_pass:		
	;valida operador [=]
	movlw	'E'		; [E] � [=] no teclado matricial
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z		; salta a pr�xima instru��o se [=] foi pressionado
	goto	Enviar_user_change_pass - .3	; operador inv�lido, retorna
	call	Verify_user		; vai para verifica��o de usu�rio
	btfsc	flag_user_err,F	; testa e pula pr�xima instru��o se usu�rio correto
	goto	Usuario_erro_change_pass	;tratamento de erro de usu�rio
	goto	Enviar_msg_senha_change_Pass	;vai para continuidade de c�digo
	
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
;L� 1� operando
Loop_change_user_pass1:
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; salta pr�xima instru��o se o teclado foi pressionado
	goto	Loop_change_user_pass1	; fica no loop at� ler BCD1
	;=============================================================
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; l� BCD1 da senha
	goto	Loop_change_user_pass1	; BCD1 inv�lido, retorna
	movfw	tecla		; move bcd1 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	dig1		; move bcd1 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD1 para LCD
;=============================================================
Loop_change_user_pass2:
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD2 da senha
	goto	$-2		; fica no loop at� ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 v�lido
	goto	Loop_change_user_pass2	; vai verificar se � operador
	movfw	tecla		; move bcd2 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	dig2		; move bcd2 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD2 para LCD
;==============================================================
Loop_change_user_pass3:
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD3 da senha
	goto	$-2		; fica no loop at� ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 v�lido
	goto	Loop_change_user_pass3	; vai verificar se � operador
	movfw	tecla		; move bcd3 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	dig3		; move bcd3 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD3 para LCD
;===============================================================
Loop_change_user_pass4:
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD2 da senha
	goto	$-2		; fica no loop at� ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 v�lido
	goto	Loop_change_user_pass4	; vai verificar se � operador
	movfw	tecla		; move bcd4 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	dig4		; move bcd4 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD4 para LCD
;===============================================================
Loop_change_user_pass5:
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD2 da senha
	goto	$-2		; fica no loop at� ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 v�lido
	goto	Loop_change_user_pass5	; vai verificar se � operador
	movfw	tecla		; move bcd5 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	dig5		; move bcd5 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD5 para LCD
;===============================================================
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD
	goto	$-2		; fica no loop at� ler BCD ...
	;=============================================================
Enviar_senha_pass_change:			
	;valida operador [=]
	movlw	'E'		; [E] � [=] no teclado matricial
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z		; salta se [=] foi pressionado
	goto	Enviar_senha_pass_change - .3	; operador inv�lido, retorna
	
;flag testa e envia para um dos labels de senha
	btfsc	flag_user1,F		; Pula se n�o for usu�rio 1
	goto	Pass_change1	; vai para rotina para testar senha usu�rio 1
	btfsc	flag_user2,F		; Pula se n�o for usu�rio 2
	goto	Pass_change2	; vai para rotina para testar senha usu�rio 2
	btfsc	flag_user3,F		; Pula se n�o for usu�rio 3
	goto	Pass_change3	; vai para rotina para testar senha usu�rio 3
	btfsc	flag_user4,F		; Pula se n�o for usu�rio 4
	goto	Pass_change4	; vai para rotina para testar senha usu�rio 4
	btfsc	flag_user5,F		; Pula se n�o for usu�rio 5
	goto	Pass_change5	; vai para rotina para testar senha usu�rio 5
	goto	Change_pass_return	; redund�ncia, nunca ser� usada
Pass_change1:
	call	Verify_password	; verifica password do usu�rio 1
	goto	Change_pass_return	; vai para rotina de mudan�a de senha
Pass_change2:
	call	Verify_password2	; verifica password do usu�rio 2
	goto	Change_pass_return	; vai para rotina de mudan�a de senha
Pass_change3:
	call	Verify_password3	; verifica password do usu�rio 3
	goto	Change_pass_return	; vai para rotina de mudan�a de senha
Pass_change4:
	call	Verify_password4	; verifica password do usu�rio 4
	goto	Change_pass_return	; vai para rotina de mudan�a de senha
Pass_change5:
	call	Verify_password5	; verifica password do usu�rio 5
Change_pass_return:
	btfsc	flag_error,F		; testa e se senha correta salta a pr�xima instru��o
	goto	Senha_erro_pass_changer ; vai para tratamento de erro de senha
	goto	Pass_changer_routine	; vai para rotina de mudan�a de senha
	
Senha_erro_pass_changer:
	call	envia_msg_senha_erro_LCD	; Envia Mensagem: " SENHA INCORRETA" e espera 1s
	call	Exibir_old_pass_LCD	; Envia Mensagem: "SENHA ATUAL:"
	goto	Loop_change_user_pass1	; volta para loop para uma noca tentativa de senha
	
Pass_changer_routine:
	call	Exibir_NEW_pass_LCD	; Envia Mensagem: "NOVA SENHA:"
;=======================================================================================	
New_pass1:
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD1 da senha
	goto	New_pass1		; fica no loop at� ler BCD1
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula se BCD1 v�lido
	goto	Lop2		; BCD1 inv�lido, retorna
	movfw	tecla		; move bcd1 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	dig1		; move bcd1 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD1 para LCD
;=============================================================
New_pass2:
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD2 da senha
	goto	$-2		; fica no loop at� ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD2 v�lido
	goto	New_pass2		; vai verificar se � operador
	movfw	tecla		; move bcd2 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	dig2		; move bcd2 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD2 para LCD
;==============================================================
New_pass3:
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD3 da senha
	goto	$-2		; fica no loop at� ler BCD2 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD3 v�lido
	goto	New_pass3		; vai verificar se � operador
	movfw	tecla		; move bcd2 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	dig3		; move bcd2 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD2 para LCD
;===============================================================
New_pass4:
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD4 da senha
	goto	$-2		; fica no loop at� ler BCD4 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD4 v�lido
	goto	New_pass4		; vai verificar se � operador
	movfw	tecla		; move bcd4 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	dig4		; move bcd4 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD4 para LCD
;===============================================================
New_pass5:
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD5 da senha
	goto	$-2		; fica no loop at� ler BCD5 ...
	call	checa_BCD		; tecla = [0x30,0x39]
	btfss	fpress,0		; pula de BCD5 v�lido
	goto	New_pass5		; vai verificar se � operador
	movfw	tecla		; move bcd5 selecionado para registrador tecla que ser� usado para enviar informa��o LCD
	movwf	dig5		; move bcd5 selecionado para registrador user1 que ser� usado para registrar dado entrado
	call	EnviaCarLCD	; Envia BCD5 para LCD
;===============================================================
	;loop - aguarda o usu�rio pressionar uma tecla
	;=============================================================
	call	teclado		; para ler operador
	btfss	fpress,0		; l� BCD
	goto	$-2		; fica no loop at� ler BCD ...
	;=============================================================
Send_pass:	
	;valida operador [E] = [=]
	movlw	'E'		; [E] = [=]
	xorwf	tecla,W		; tecla [=]
	btfss	STATUS,Z		; salta pr�xima instru��o se [=] foi pressionada
	goto	Send_pass - .3	; operador inv�lido, retorna
	call	New_password	; vai para rotina de mudar senha de um certo usu�rio
	call	Exibir_senha_alterada_LCD	; Envia Mensagem: "SENHA ALTERADA" e aguarda 1s
	MOVLW	LCD_CLEAR	; limpa LCD
	CALL	EnviaCmdLCD	; envia comando para limpar LCD
	call	envia_msg_LCD	; Envia Mensagem: "PRESSIONE ON/C PARA INICIAR"
	goto	main		; volta para o in�cio do programa
	

	    
	#include	"up_md_lcd_driver_PIC16F.asm"
	#include	"up_mensagens_PIC16F.asm"
	#include	"up_md_atrasos.asm"
	#include	"verify_password.asm"
	#include	"user.asm"
	
	end