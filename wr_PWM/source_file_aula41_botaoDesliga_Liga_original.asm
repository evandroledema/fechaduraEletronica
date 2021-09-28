PROCESSOR '16F876A'
	INCLUDE <P16F876A.INC>

	__CONFIG _XT_OSC & _WDT_OFF & _PWRTE_OFF & _CP_OFF & _LVP_OFF & _BODEN_OFF

	CBLOCK 0x20
	D1
	D2
	FADE_STATE ;IF = 0x00 INCREMENT CCPR1L ELSE DECREMENT CCPR1L
	D3
	ENDC
	
	ORG 0x0000
	
	; --- Mapeamento de Hardware (PARADOXUS PEPTO) ---
	#define		LED1	PORTA,3				;LED1 ligado ao pino RA3
	#define		LED2	PORTA,2				;LED2 ligado ao pino RA2
	#define		S1		PORTB,RB0				;Botão S1 ligado ao pino RB0
	#define		S2		PORTB,RB1				;Botão S2 ligado ao pino RB1
	#define		S3		PORTB,RB2	;botao s2 ligado ao pino RB2


					;Não, desvia para saída da interrupção
	bcf			INTCON,T0IF					;Sim, limpa flag do Timer0
	movlw		D'150'						;Move literal 108d para work
;	movwf		TMR0						;Reinicia TMR0
	
loop:
	btfsc	S1
	goto	loop	
	btfss	S1							;Botão 1 pressionado?
	goto	INIT					;Sim, desvia para inc_PWM
	
	
	

	
INIT:
	;PWM PERIOD = [(PR2)+1] * 4 * TOSC * (TMR2 PRESCALE VALUE) ;PR2 = TMR2 PERIOD REGISTER, TOSC = PIC CLOCK PERIOD (FOSC = 1 / TOSC)
	;PWM DUTY CYCLE = (CCPR1L:CCP1CON<5:4>) * TOSC * (TMR2 PRESCALE VALUE)
	
	;;;SET PWM FREQUENCY;;;
	BSF STATUS, RP0 ;seleciona BANK 01
	MOVLW D'250' ;coloca em PR2 o valor 128 em DECIMAL SO THE PWM PERIOD = 2064uS => PWM FREQUENCY = 484Hz
	MOVWF PR2
	BCF STATUS, RP0 ;selecionaBANK 00
	

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
	
MAIN:
	
	MOVLW 0x00
	;IORWF FADE_STATE, W
	
	BTFSS STATUS, Z ;IF FADE_STATE == 0 GOTO INC_CCPR1L
;	GOTO DEC_CCPR1L ;ELSE GOTO DEC_CCPR1L
	
INC_CCPR1L:
	movlw	D'240' ;TEMPO QUE FICA EM ESTADO ON
    btfss	S2
	goto 	desliga
	xorwf	CCPR1L,W
	addwf	CCPR1L	;INCREMENT CCPR1L
	;GOTO CHANGE_STATE_0 
		
	
;CHANGE_STATE:
	COMF FADE_STATE, F 

	GOTO INC_CCPR1L

desliga:
	CLRF	CCPR1L
	CLRF	RB0
	btfss	S2
	goto	desliga
	goto	loop
	
end	
