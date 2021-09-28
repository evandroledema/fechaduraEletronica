PROGRAMA_PORTAO:

; --- Mapeamento de Hardware (PARADOXUS PEPTO) ---
	#define bank0   bcf     STATUS,RB0
	#define bank1   bsf     STATUS,RB0
	#define         S1              PORTB,RB0                               ;Botão S1 ligado ao pino RB0 abre portao
	#define         S2              PORTB,RB1                               ;fim de curso S2 ligado ao pino RB1 indica 
	#define         S3              PORTB,RB2       ;fim de curso s2 ligado ao pino RB2
	#define         S4              PORTB,RB3       ;fim de curso s4 ligado ao pino RB3
	#define         led1    TRISB,RB5
	#define         led2    TRISB,RB7
	;movlw          H'FF'                           ;W = B'11111111'
	;movwf          PORTB                           ;RB7 (configurado como saída) inicia em HIGH

;	#Define Linha1  PORTD,3
;	#Define Linha2  PORTD,2
;	#Define Linha3  PORTD,1
;	#Define Linha4  PORTD,0

;=-----------------------------------------
	movlw   0x07
	movwf   CMCON                   ;turn comparators off (make it like a 16F84)
;------------------------------------------

	bcf		fpress,0		;limpa flag
	movlw	0x30			
	subwf	tecla,W			;tecla - 0x30

	;bcf                     INTCON,T0IF                                     ;Sim, limpa flag do Time r0
	movlw           D'150'                                          ;Move literal 108d para work
	movwf           TMR0                                            ;Reinicia TMR0
	movlw   0x07
	movwf   CMCON                   ;turn comparators off (make it like a 16F84)
	bsf     STATUS,         RP0     ;select bank 1
	bcf     STATUS,         RP0     ;select bank 0
;----------------------------------------;
;PORTÃO EM QUALQUER POSIÇÃO MENOS ABERTO OU FECHADO
;----------------------------------------;
;loop01
;       btfss   S2
;       nop
;       btfsc   S2
;       nop
;       btfsc   S4      
;       goto    loop02
;----------------------------------------;
;VERIFICA QUAIS FINS DE CURSO ESTÃO APERTADO. VERIFICA SE PORTÃO ESTÁ ABERTO OU FECHADO
;----------------------------------------;


Lop1:
	clrf	teste1
	call	teclado			; lê BCD1 de op1
	btfss	fpress,0
	goto	$-2				; fica no loop até ler BCD1

		
loop_1:
	btfss   S2              ;Botão/fim de curso S2 pressionado? (potão fechado?)
	goto    loop_5  	;Sim, desvia para instruções loop_2
	btfss   S4              ;Fim de curso S4 presionado? (Portão aberto?)
	goto    loop_4  	;Sim, desvia para instruções loop_3
loop02:
	btfss   S1
	goto    relay_desligado
	btfss   S3
	goto    relay_ligado
	goto    loop_1
;----------------------------------------;
loop_2: ;se botao de abrir portao pressionado
	btfss   S1
	goto    relay_desligado ;Sim, desvia para instruções relay. função responsável por comandar relé e abrir portão
;----------------------------------------;
loop_3: ;se botao de fecha portao pressionado
	btfss   S3                       ;Botão S3 apertado?
	goto    relay_ligado ;então vai pro relay para trocar posição para FECHAR PORTÃO
	goto    loop_1
	relay_desligado:        ;botão S1 abre portao
	BSF STATUS, RP0 ;SELECT BANK 01
	BCF PORTB, 7 ;SET RC2 AS OUTPUT
	BCF STATUS, RP0 ;SELECT BANK 00
	movlw   H'00'

	movwf   TRISB

	goto    INIT_1  ;vai pra função que inicia sinal de pwm pro portão
	relay_ligado: ;botão S3 fecha portao
	BSF STATUS, RP0 ;SELECT BANK 01
	BCF PORTB, 7 ;SET RC2 AS OUTPUT
	BCF STATUS, RP0 ;SELECT BANK 00
	movlw   H'FF'

	movwf   TRISB
        ;movwf  TRISB
        ;faz relay: posição desligado (FECHA POPTÃO)
	goto    INIT    ;vai pra função que inicia sinal de pwm pro portão
;----------------------------------------;
;----------PARTE DO CODIGO RESPONSÁVEL POR MANDAR O SINAL PWM----------------
INIT:           ;ABRE PORTÃO!!!
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
	MOVLW 0x00
	;IORWF FADE_STATE, W

	BTFSS STATUS, Z ;IF FADE_STATE == 0 GOTO INC_CCPR1L
;	GOTO DEC_CCPR1L ;ELSE GOTO DEC_CCPR1L

INC_CCPR1L:
	;btfss      S4
	;goto   desliga_1
	movlw   D'150' ;TEMPO QUE FICA EM ESTADO ON
	xorwf   CCPR1L,W

	addwf   CCPR1L  ;INCREMENT CCPR1L
	;GOTO CHANGE_STATE_0 


	;CHANGE_STATE:
	COMF FADE_STATE, F 
	btfss   S2
	goto    desliga
	btfss   S1
	goto    abreportao_fechando
	goto    INC_CCPR1L

desliga:
	movlw   D'0' ;TEMPO QUE FICA EM ESTADO ON
	xorwf   CCPR1L,W
	subwf   CCPR1L  ;desincrementa CCPR1L
	movlw D'6'

;--CRIO DELAY DE 1 SEGUNDO---;
	movwf CounterC
	movlw D'24'
	movwf CounterB
	movlw D'168'
	movwf CounterA
	h2
	decfsz CounterA,1
	goto h2
	decfsz CounterB,1


	goto h2
	decfsz CounterC,1
	goto h2

;--DEPOIS DO DELAY DE 1 SEGUNDO VOLTO PRO INICIO---;
	goto loop_5

loop_5:
	btfss   S1
	goto    relay_desligado
	goto    loop_5


;========================================================================;
INIT_1:         ;ABRE PORTÃO!!!
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

	MOVLW 0x00
	;IORWF FADE_STATE, W


	BTFSS STATUS, Z ;IF FADE_STATE == 0 GOTO INC_CCPR1L
;       GOTO DEC_CCPR1L ;ELSE GOTO DEC_CCPR1L


INC_CCPR1L_1:
	movlw   D'150' ;TEMPO QUE FICA EM ESTADO ON
	xorwf   CCPR1L,W

	addwf   CCPR1L  ;INCREMENT CCPR1L
	;GOTO CHANGE_STATE_0 


	;CHANGE_STATE:
	COMF FADE_STATE, F 
	btfss   S4
	goto    desliga_1
	btfss   S3
	goto    fechaportao_abrindo
	GOTO INC_CCPR1L_1

desliga_1:
	movlw   D'0' ;TEMPO QUE FICA EM ESTADO ON
	xorwf   CCPR1L,W

	subwf   CCPR1L  ;desincrementa CCPR1L
	movlw D'6'
;--CRIO DELAY DE 1 SEGUNDO---;
	movwf CounterC
	movlw D'24'
	movwf CounterB
	movlw D'168'
	movwf CounterA
	h1
	decfsz CounterA,1
	goto h1
	decfsz CounterB,1
	goto h1
	decfsz CounterC,1
	goto h1
	;--DEPOIS DO DELAY DE 1 SEGUNDO VOLTO PRO INICIO---;
	goto loop_4

	fechaportao_abrindo:
	movlw   D'0' ;TEMPO QUE FICA EM ESTADO ON
	xorwf   CCPR1L,W

	subwf   CCPR1L  ;desincrementa CCPR1L

	call 	delay_1s

abreportao_fechando:
	movlw   D'0' ;TEMPO QUE FICA EM ESTADO ON
	xorwf   CCPR1L,W

	subwf   CCPR1L  ;desincrementa CCPR1L

	call	delay_1s

	goto    relay_desligado

loop_4:
	btfss   S3
	goto    relay_ligado
	goto    loop_4

;----------------
;--DELAY DE 50S--
;----------------
;delay_50ms:
;	movlw	D'185'
;	movwf	contador1
;	movlw	D'4'
;	movwf	contador2
;	movlw	D'2'
;	movwf	contador3
;	decfsz	contador1,1
;	goto	$-1
;	decfsz	contador2,1
;	goto	$-3
;	decfsz	contador3,1
;	goto	$-5
;	return
