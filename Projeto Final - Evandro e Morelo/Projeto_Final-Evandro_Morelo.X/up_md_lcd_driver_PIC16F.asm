	cblock
	  TEMPO1,TEMPO2
	endc

#define	    LCD_RS		PORTE,0
#define	    LCD_E		PORTE,1
#define	    LCD_DADO	PORTD

LCD_ON_NOCURSOR		EQU	0x0C	;Display on, cursor off
LCD_ON_CURSOR		EQU	0x0E	;Display on, cursor on
LCD_ON_CURSOR_BLINK	EQU	0x0F	;Display on, cursor on-blink
CURSOR_A_ESQUERDA	EQU	0x10	;Cursor à esquerda
CURSOR_A_DIREITA		EQU	0x14	;Cursor à direita
MENSAJE_ESQUERDA		EQU	0x18	;Mensagem à esquerda
MENSAJE_DIREITA		EQU	0x1C	;Mensagem à direita
LCD_CLEAR		EQU	0x01	;Limpa display e cursor home
LCD_OFF			EQU	0x008	;desligar display
LCD_Linha_1		EQU	0x80	;primeira linha
LCD_Linha_2		EQU	0xC0	;segunda linha
;====================================================================
Inicia_LCD:
	banco1
	clrf	TRISD
	clrf	TRISE
	banco0
	MOVLW	0x38		;
	CALL	EnviaCmdLCD
	MOVLW	0x38		;Modo 8b, 2 linhas de dados
	CALL	EnviaCmdLCD
	MOVLW	0x06		;Cursor, deslocamento para a direita
	CALL	EnviaCmdLCD
	MOVLW	0x0C		;Display on, cursor off
	CALL	EnviaCmdLCD
	MOVLW	0x01		;Limpa display e cursor home
	CALL	EnviaCmdLCD
	RETURN	

EnviaCarLCD:
	BSF	LCD_RS
	BSF	LCD_E
	MOVWF	LCD_DADO
	BCF	LCD_E
	MOVLW	0x06
	CALL	Delay_LCD		;1.54ms
	RETURN	

EnviaCmdLCD:
	BCF	LCD_RS		;comando
	BSF	LCD_E
	MOVWF	LCD_DADO
	BCF	LCD_E
	MOVLW	0x12
	CALL	Delay_LCD		;4.6ms
	RETURN

Delay_LCD:
	MOVWF	TEMPO2     
	MOVLW	0xFF
	MOVWF	TEMPO1
	CLRWDT
	DECFSZ	TEMPO1,F
	GOTO	$-02               
	DECFSZ	TEMPO2,F
	GOTO 	$-06                
	RETURN
