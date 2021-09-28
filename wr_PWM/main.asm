	list      p=16f877A
	#INCLUDE <P16F877A.INC>
	#include <macros.inc>
	__CONFIG H'2F02'
	ERRORLEVEL -302, -305
;LIST
	;__CONFIG _XT_OSC & _WDT_OFF & _PWRTE_OFF & _CP_OFF & _LVP_OFF & _BODEN_OFF

Fosc	  equ	.16000000		; Hz: Fclock do sistema
baudrate equ	.9600			; bps: taxa de transmissão
k_spbrg  equ	Fosc/baudrate/.64 - 1 ; BRGH = 1

	CBLOCK 0X20
		Loper,D1,D2,FADE_STATE ;IF = 0x00 INCREMENT CCPR1L ELSE DECREMENT CCPR1L
  		D3,T1,CounterC,CounterB,CounterA,contador1,contador2,contador3,tecla1,tecla2,tecla3,teste1,conta_dig,dig1,dig2,dig3,giga,contador
		dado_rx1,dado_rx2,dado_rx3,dado_rx4,dado_rx5,dado_rx6
		flag_rx,flag_rx1,flag_rx2,flag_rx3,flag_rx4,flag_rx5,flag_rx6
		v1,v2,v3
		vb1,vb2,vb3
	ENDC

	ORG 0x00
;AQUI ERA 
	goto	setup
;	goto	PROGRAMA_PORTAO	
	org	0x04
	#include "up_md_teclado_4x4.asm"


;=======================================
;-INICIO LEITURA DO TECLADO E BLUETOOTH-
;=======================================
setup:
;===============================
;LIGA LED ENSIRA SENHA
;===============================
	BSF STATUS, RP0 ;SELECT BANK 01
	BCF PORTC, 4 ;SET RC2 AS OUTPUT
	BCF PORTC, 3
	BCF PORTC, 5
	BCF STATUS, RP0 ;SELECT BANK 00
;---------------------------------------------------
	bsf	PORTC,4	;Acende LED de add senha
	bcf	PORTC,3	;Apaga LED de senha errada
	bcf	PORTC,5	;Apaga LED de senha correta
;---------------------------------------------------
;	BSF STATUS, RP0 ;SELECT BANK 01
;	BCF PORTC, 4 ;SET RC2 AS OUTPUT
;	BCF STATUS, RP0 ;SELECT BANK 00
;	movlw   H'FF'
;	movwf   TRISC
	call iniciar_UART
	call msg_senha
	call	Inicia_teclado	;configura PORTB e PORTC
;	call	Inicia_LCD		;configura LCD e Portas
	banco1	
	movlw	0x06
	movwf	ADCON1			;PORTE como E/S dig.
	banco0

MAIN:
calculadora:
;	movlw	LCD_CLEAR
;	call	EnviaCmdLCD		; limpa LCD
;mostrar "calculadora" no LCD
	;call	env_msg_calc
;operandos:
	;movlw	0xC1
	;call	EnviaCmdLCD		; cursor = endereço 0xC1 

	movlw	.3
	movwf	conta_dig		;n° de digitos de Op1

;Lê 1° operando
Lop1_teclado:

	call	teclado			; lê BCD1 de op1
	btfss	fpress,0		;se nenhuma tecla, vai pra bluetooth
	call	RxTx1			;primeiro bluetooth			
	
	movfw	tecla	
	movwf	tecla1
	movwf	cent			; cent = ASCII(BCD1)
	call	EnviaCarLCD
	decf	conta_dig,F

Lop2_teclado:
	call	teclado			; lê BCD2 ou operador
	btfss	fpress,0
	call	RxTx2			;segundo bluetooth
		
	movfw	tecla
	movwf	tecla2
	movwf	deze			; deze = ASCII(BCD2)
	
	call	EnviaCarLCD
	decf	conta_dig,F

Lop3_teclado:
	call	teclado			; lê BCD3 ou operador
	btfss	fpress,0
	call	RxTx3			;terceiro bluetooth
	
	movfw	tecla
	movwf	tecla3
	movwf	unid			; deze = ASCII(BCD2)
	
	call	EnviaCarLCD
	decf	conta_dig,F

;---------------------------------------
;--------FIM DA LEITURA DO TECLADO------
;---------------------------------------

;=======================================
;--------------TESTE SENHA--------------
;=======================================
	call	numero_senha ;onde esta armazenado as senhas corretas
	btfss	fpress,1 ;se botão apertado, ele vai pra debaixo
	call	teclado_1 ;verifica senha de
;---------------------------------------
;---------FIM TESTE DE SENHA------------
;---------------------------------------

;=======================================
;------------COMEÇA PORTÃO--------------
;=======================================


PROGRAMA_PORTAO:
; --- Mapeamento de Hardware
	#define bank0   bcf     STATUS,RB0
	#define bank1   bsf     STATUS,RB0
	#define	S1	PORTB,RB0	;Botão S1 ligado ao pino RB0 abre portao
	#define	S2	PORTB,RB1	;fim de curso S2 ligado ao pino RB1 indica 
	#define	S3	PORTB,RB2	;fim de curso s2 ligado ao pino RB2
	#define	S4	PORTB,RB3	;fim de curso s4 ligado ao pino RB3
	#define	S5	PORTB,RB4	;o fim de curso que decta fechamento do portão e faz fechamento suave 
	#define	led1	TRISB,RB5

	BSF STATUS, RP0 ;SELECT BANK 01
	BCF PORTC, 0 ;SET RC2 AS OUTPUT
	clrf fpress
;========================================================
;para a instrução s5, basta copiar um pwm gerado
;e reduzir o valor do tempo on
;usar nova função para nao detectar sensor de proximidade
;========================================================     
;=======================================
	;#define         led2    TRISC,RC0
	;movlw          H'FF'                           ;W = B'11111111'
	;movwf          PORTB                           ;RB7 (configurado como saída) inicia em HIGH
;------------------------------------------
	movlw   0x07
	movwf   CMCON                   ;turn comparators off (make it like a 16F84)
;------------------------------------------

	bcf		fpress,0		;limpa flag
	movlw	0x30			
	subwf	tecla,W			;tecla - 0x30

	;bcf                     INTCON,T0IF                                     ;Sim, limpa flag do Time r0
	movlw	D'150'                                          ;Move literal 108d para work
	movwf	TMR0                                            ;Reinicia TMR0
	movlw	0x07
	movwf	CMCON                   ;turn comparators off (make it like a 16F84)
	bsf	STATUS,RP0     ;select bank 1
	bcf	STATUS,RP0     ;select bank 0
;========================================================
;------------INICIA NOVO COMANDO BLUETOOTH---------------
;========================================================
	call	limpa_tela 		;limpa tela
	call	abrir_fechar	;manda frase (O)Abrir / (C)Fechar / (S)Parar: 

;======================================================================================
;VERIFICA QUAIS FINS DE CURSO ESTÃO APERTADO. VERIFICA SE PORTÃO ESTÁ ABERTO OU FECHADO
;======================================================================================
loop_1:
	btfss	S2		;Botão/fim de curso S2 pressionado? (potão fechado?)
	goto	loop_5  ;Sim, desvia para instruções loop_5
	btfss	S4		;Fim de curso S4 presionado? (Portão aberto?)
	goto	loop_4  ;Sim, desvia para instruções loop_4

;----------------------------------------------------
;VERIFICA QUAL BOTÃO APERTADO (ABRIR OU FECHAR PORTÃO
;----------------------------------------------------
loop02:
	btfss	S1
	goto	relay_desligado
	btfss	S3
	goto	relay_ligado
;--------------------------------------------------
;--------------VERIFICA BLUETOOTH------------------
;--------------------------------------------------
	goto	verifica_se_caractere_entrou
;--------------------------------------------------
end_function:
	goto	loop_1 ;Volta pro inicio e verifica se algum fim de curso apertado
;==================================================
;-------MANTÉM RELÉ DESLIGADO E ABRE PORTÃO--------
;==================================================
relay_desligado:        ;botão S1 abre portao
;jogar o set da porta lá em cima
;depois usar só bsf e bcf na saida da portaC
	BCF STATUS, RP0 ;SELECT BANK 00
	bcf		PORTC,0
	goto    INIT_1  ;vai pra função que inicia sinal de pwm pro portão
;==================================================
;-------MANTÉM RELÉ LIGADO E DESLIGA PORTÃO--------
;==================================================
relay_ligado: ;botão S3 fecha portao
	BCF STATUS, RP0 ;SELECT BANK 00
	bsf		PORTC,0
	goto    INIT    ;vai pra função que inicia sinal de pwm pro portão
;==================================================

;==================================================
;PARTE DO CODIGO RESPONSÁVEL POR MANDAR O SINAL PWM
;==================================================
INIT:           ;FECHA PORTÃO!!! S3
;PWM PERIOD = [(PR2)+1] * 4 * TOSC * (TMR2 PRESCALE VALUE) ;PR2 = TMR2 PERIOD REGISTER, TOSC = PIC CLOCK PERIOD (FOSC = 1 / TOSC)
;PWM DUTY CYCLE = (CCPR1L:CCP1CON<5:4>) * TOSC * (TMR2 PRESCALE VALUE)
	;;;SET PWM FREQUENCY;;;
	BSF STATUS, RP0 ;seleciona BANK 01
	MOVLW D'250' ;coloca em PR2 o valor 128 em DECIMAL SO THE PWM PERIOD = 2064uS => PWM FREQUENCY = 484Hz

	MOVWF PR2
	bcf     STATUS,         RP0     ;select bank 0
	CLRF CCPR1L 
	MOVLW B'00001100' 
	MOVWF CCP1CON
	;;;SET PWM PIN TO OUTPUT MODE;;;
	BSF STATUS, RP0 ;SELECT BANK 01
	BCF TRISC, 2 ;SET RC2 AS OUTPUT, TO USE FOR PWM
	BCF STATUS, RP0  ;SELECT BANK 00
        ;;SET tempo 2 do PRESCALE;;;

	MOVLW B'00000010'
	MOVWF T2CON
        ;;;limpo TIMER 2;;;
	CLRF TMR2
        ;;;habilito TIMER 2;;;
	BSF T2CON, TMR2ON

	CLRF FADE_STATE

MAIN_0:
	;MOVLW 0x00
	;IORWF FADE_STATE, W
	;BTFSS STATUS, Z ;IF FADE_STATE == 0 GOTO INC_CCPR1L
	movlw   D'180' ;TEMPO QUE FICA EM ESTADO ON estava 150	
INC_CCPR1L:
	xorwf   CCPR1L,W
	addwf   CCPR1L  ;INCREMENT CCPR1L
	;GOTO CHANGE_STATE_0 
	COMF	FADE_STATE,F

lop_s3:
	btfss   S2
	goto    desliga
	btfss   S1
	goto    abreportao_fechando
	btfss	S5
	goto	fecha_suave_fodase
	call	delay_500ms

lops_s33:
	btfss   S2
	goto    desliga
	btfss	S5
	goto	fecha_suave_fodase
	btfss   S1
	goto    abreportao_fechando
	call	delay_10ms
;-------------------------------------------------------------
	goto	blue_fechando	;verifica entrada do bluetooth
;-------------------------------------------------------------
lops_s333:	
	btfss   S3
	goto	velo_1
	goto    lops_s33
;=====================================
;------------DESLIGA O PWM------------
;=====================================
desliga:
	movlw   D'0' ;TEMPO QUE FICA EM ESTADO ON
	xorwf   CCPR1L,W
	subwf   CCPR1L  ;desincrementa CCPR1L
	movlw 	D'6'
	call	delay_1s
	goto	loop_5
;=====================================
loop_5:	;FIM DE CURSO S2 APERTADO / INVERTE SENTIDO DO MOTOR
	btfss   S1
	goto    relay_desligado
	goto    loop_5
;==========================================
;----ALTERA VELOCIDADE: PORTAO ABRINDO-----
;==========================================
velo_1:	;checa qual velocidade que está
	movf	CCPR1L,W
	xorlw	D'180'
	btfsc	STATUS,Z
	call	velo_11
	call	velo_12
velo_11:	;desliga PWM
	movlw   D'0' ;TEMPO QUE FICA EM ESTADO ON
	xorwf   CCPR1L,W
	subwf   CCPR1L  ;desincrementa CCPR1L

	call	delay_100ms

	movlw   D'250' ;TEMPO QUE FICA EM ESTADO ON
	xorwf   CCPR1L,W

	addwf   CCPR1L  ;valor de duty cycle 100%
	call	delay_500ms
	;call	abrir_fechar
	goto	lop_s3
velo_12:	;desliga PWM
	movlw   D'0' ;TEMPO QUE FICA EM ESTADO ON
	xorwf   CCPR1L,W
	subwf   CCPR1L  ;desincrementa CCPR1L

	call	delay_100ms

	movlw   D'180' ;TEMPO QUE FICA EM ESTADO ON
	xorwf   CCPR1L,W

	addwf   CCPR1L  ;valor de duty cycle 72%
	call	delay_500ms
	;call	abrir_fechar
	goto	lop_s3

;============================================================
;------------------------ABRE O PORTÃO-----------------------
;============================================================
INIT_1:	;ABRE PORTÃO!!! s1
;PWM PERIOD = [(PR2)+1] * 4 * TOSC * (TMR2 PRESCALE VALUE) ;PR2 = TMR2 PERIOD REGISTER, TOSC = PIC CLOCK PERIOD (FOSC = 1 / TOSC)
;PWM DUTY CYCLE = (CCPR1L:CCP1CON<5:4>) * TOSC * (TMR2 PRESCALE VALUE)
;;;SET PWM FREQUENCY;;;
	BSF STATUS, RP0 ;seleciona BANK 01
	MOVLW D'250' ;coloca em PR2 o valor 128 em DECIMAL SO THE PWM PERIOD = 2064uS => PWM FREQUENCY = 484Hz
	MOVWF PR2

	bcf     STATUS,         RP0     ;select bank 0

	CLRF CCPR1L 
	MOVLW B'00001100' 
	MOVWF CCP1CON

;;;SET PWM PIN TO OUTPUT MODE;;;
	BSF STATUS, RP0 ;SELECT BANK 01
	BCF TRISC, 2 ;SET RC2 AS OUTPUT, TO USE FOR PWM
	BCF STATUS, RP0  ;SELECT BANK 00

;;SET tempo 2 do PRESCALE;;;
	MOVLW B'00000010'
	MOVWF T2CON

;;;limpo TIMER 2;;;
	CLRF TMR2

;;;habilito TIMER 2;;;
	BSF T2CON, TMR2ON

	CLRF FADE_STATE

MAIN_1:
	;MOVLW 0x00
	;IORWF FADE_STATE, W
	;BTFSS STATUS, Z ;IF FADE_STATE == 0 GOTO INC_CCPR1L
	;GOTO DEC_CCPR1L ;ELSE GOTO DEC_CCPR1L
	movlw   D'180' ;TEMPO QUE FICA EM ESTADO ON
	
INC_CCPR1L_1:
	xorwf   CCPR1L,W
	addwf   CCPR1L  ;INCREMENT CCPR1L
	;GOTO CHANGE_STATE_0 
	;CHANGE_STATE:
	COMF FADE_STATE, F 
;Esse primeiro loop é porque ele pode detectar o apertar do s1
;ocorre por ser muito rapido
lop_s1:
	btfss   S4
	goto    desliga_1
	btfss   S3
	goto    fechaportao_abrindo
	call	delay_500ms

lop_s11:
	btfss   S4
	goto    desliga_1
	btfss   S3
	goto    fechaportao_abrindo
	call	delay_10ms
;-------------------------------------------------------------
	goto	blue_abrindo	;verifica entrada do bluetooth
;-------------------------------------------------------------
lop_s111:
	btfss   S1
	goto    velo_2
	GOTO 	lop_s11
;==========================================
;----ALTERA VELOCIDADE: PORTAO ABRINDO-----
;==========================================
velo_2:	;checa qual velocidade
	movf	CCPR1L,W
	xorlw	D'180'
	btfsc	STATUS,Z
	call	velo_21
	call	velo_22
velo_21:	;desliga PWM
	movlw   D'0' ;TEMPO QUE FICA EM ESTADO ON
	xorwf   CCPR1L,W
	subwf   CCPR1L  ;desliga PWM

	call	delay_100ms

	movlw   D'250' ;TEMPO QUE FICA EM ESTADO ON
	xorwf   CCPR1L,W

	addwf   CCPR1L  ;valor do duty cicle: 100%
	call	delay_500ms
	call	lop_s1
velo_22:
	movlw   D'0' ;TEMPO QUE FICA EM ESTADO ON
	xorwf   CCPR1L,W
	subwf   CCPR1L  ;desliga PWM

	call	delay_100ms

	movlw   D'180' ;TEMPO QUE FICA EM ESTADO ON
	xorwf   CCPR1L,W

	addwf   CCPR1L  ;valor do duty cicle: 72%
	call	delay_500ms
	call	lop_s1
;----------------------------------
;DEMAIS COMPLEMENTOS
;----------------------------------
desliga_1:
	movlw   D'0' ;TEMPO QUE FICA EM ESTADO ON
	xorwf   CCPR1L,W

	subwf   CCPR1L  ;desincrementa CCPR1L
	movlw	D'6'
	call	delay_1s
	;--DEPOIS DO DELAY DE 1 SEGUNDO VOLTO PRO INICIO---;
	goto loop_4

fechaportao_abrindo:
	movlw   D'0' ;TEMPO QUE FICA EM ESTADO ON
	xorwf   CCPR1L,W
	subwf   CCPR1L  ;desincrementa CCPR1L
	call 	delay_1s

	goto	relay_ligado

abreportao_fechando:
	movlw   D'0' ;TEMPO QUE FICA EM ESTADO ON
	xorwf   CCPR1L,W
	subwf   CCPR1L  ;desincrementa CCPR1L
	call	delay_1s

	goto    relay_desligado

loop_4:	;PORTÃO ABERTO / INVERTE ROTAÇÃO DO MOTOR
	btfss   S3
	goto    relay_ligado
	goto    loop_4


desliga_tudo: ;RESPONSÁVEL POR PARAR O PORTÃO
	movlw   D'0' ;TEMPO QUE FICA EM ESTADO ON
	xorwf   CCPR1L,W
	subwf   CCPR1L  ;desincrementa CCPR1L
	call	delay_1s
	goto	loop_1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

fecha_suave_fodase:
	movlw   D'0' ;TEMPO QUE FICA EM ESTADO ON
	xorwf   CCPR1L,W
	subwf   CCPR1L  ;desliga PWM

	call	delay_10ms

	movlw   D'75' ;TEMPO QUE FICA EM ESTADO ON
	xorwf   CCPR1L,W

	addwf   CCPR1L  ;valor do duty cicle: 100%

suave_mesmo:
	btfss   S2
	goto    desliga
	goto	suave_mesmo

;==================================
;----------FIM DO PORTÃO-----------
;==================================

;============================
;-----leitura bluetooth------
;============================

;============================
;----------SENHA-------------
;============================
RxTx1:	;primeiro
	call	RxCarUART1
	btfss	flag_rx1,0	;testa flag, se Rx Cmd pula
	call	Lop1_teclado	;se nao apertado, volta teclado
	movwf	dado_rx1	;caracter do comando que recebeu\\
	call	Lop2_teclado

RxTx2:	;segundo
	call	RxCarUART2
	btfss	flag_rx2,0	;testa flag, se Rx Cmd pula
	call	Lop2_teclado	;se nao apertado, volta teclado
	movwf	dado_rx2	;caracter do comando que recebeu\\
	call	Lop3_teclado

RxTx3:	;terceiro
	call	RxCarUART3
	btfss	flag_rx3,0	;testa flag, se Rx Cmd pula
	call	Lop3_teclado	;se nao apertado, volta teclado
	movwf	dado_rx3	;caracter do comando que recebeu\\

verificador_blue1:
	call	RxCarUART3
	btfss	flag_rx3,0	;testa flag, se Rx dado pula
	goto	$ - .2
	xorlw	.13			;[Enter]
	btfss	STATUS,Z
	goto	verificador_blue1		;retorna se não for [Enter]
	call	blue_1
	return

;===============================================
;-----------INICIO ABRIR E FECHAR---------------
;-----------------------------------------------
verifica_se_caractere_entrou:
	call	delay_10ms
	movf	vb1,W
	xorlw	'?'
	call	delay_10ms
	btfsc	STATUS,Z
	call	verificador_enter_m1

	call	RxCarUART4
	btfss	flag_rx4,0	;testa flag, se Rx Cmd pula
	return				;se nao apertado, volta teclado
	movwf	dado_rx4	;caracter do comando que recebeu\\
	
verificador_enter_m1:
	call	delay_10ms
	movlw	'?'
	movwf	vb1
	call	RxCarUART4
	btfss	flag_rx4,0	;testa flag, se Rx dado pula
	goto	$ - .4
	xorlw	.13			;[Enter]
	btfss	STATUS,Z
	goto	vb_inicio	;retorna se não for [Enter] JOGA PARA FUNÇÃO CASO APERTE BACKSPACE
	goto	verifica_m1

vb_inicio:
	clrf	vb1
	clrf	dado_rx4
	call	abrir_fechar
	goto	loop_1
;===============================================
;----------------ENQUANTO FECHA-----------------
;===============================================
blue_fechando:
	call	delay_10ms
	movf	vb2,W
	xorlw	'?'
	call	delay_10ms
	btfsc	STATUS,Z
	call	verificador_blue_fechando ;se caracter add, ele pula verificação e verifica só se enter apertado

	call	RxCarUART5
	btfss	flag_rx5,0	;testa flag, se Rx Cmd pula
	return				;se nao apertado, volta teclado
	movwf	dado_rx5	;caracter do comando que recebeu\\

verificador_blue_fechando:
	call	delay_10ms
	movlw	'?'
	movwf	vb2
	call	RxCarUART5
	btfss	flag_rx5,0	;testa flag, se Rx dado pula
	goto	$ - .4
	xorlw	.13			;[Enter]
	btfss	STATUS,Z
	goto	vbc			;retorna se não for [Enter]
	goto	verifica_blue_fechando

vbc:
	clrf	vb2
	goto	lops_s333

;===============================================
;----------------ENQUANTO ABRE-----------------
;===============================================
blue_abrindo:
	call	delay_10ms
	movf	vb3,W
	xorlw	'?'
	call	delay_10ms
	btfsc	STATUS,Z
	call	verificador_blue_abrindo

	call	RxCarUART6
	btfss	flag_rx6,0	;testa flag, se Rx Cmd pula
	return				;se nao apertado, volta teclado
	movwf	dado_rx6	;caracter do comando que recebeu\\

verificador_blue_abrindo:
	call	delay_10ms
	movlw	'?'
	movwf	vb3
	call	RxCarUART6
	btfss	flag_rx6,0	;testa flag, se Rx dado pula
	goto	$ - .4
	xorlw	.13			;[Enter]
	btfss	STATUS,Z
	goto	vba		;retorna se não for [Enter] FUNÇÃO FEITA PARA CASO APERTE BACKSPACE
	goto	verifica_blue_abrindo

vba:
	clrf	vb3
	goto	lop_s111

;========================================================
;-----------BIBLIOTECAS RELACIONADAS AO PORTAO-----------
;========================================================
	#include "senha.asm"
	#include "up_aritmetica_8b.asm"
	#include "up_3BCD_bin8.asm"
	#include "up_Bin16_BCD.asm"
	#include "up_md_lcd_driver.asm"
	#include "up_md_atrasos.asm"
;----------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------
;--BIBLIOTECAS RELACIONADAS AO BLUETOOTH--
;----------------------------------------------------------------------------------------------
	#include "up_CAD.asm"
	#include "up_UART.asm"
	#include "up_msg.asm"
	end