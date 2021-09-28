;**********************************************************************
; Rotinas para as mensagens de texto a serem enviadas no LCD
;**********************************************************************
envia_msg_LCD:
	MOVLW	LCD_Linha_1	;1 linha
	CALL	EnviaCmdLCD
	
	MOVLW	'P'
	CALL	EnviaCarLCD    
	MOVLW	'R'
	CALL	EnviaCarLCD  
	MOVLW	'E'
	CALL	EnviaCarLCD  
	MOVLW	'S'
	CALL	EnviaCarLCD  
	MOVLW	'S'
	CALL	EnviaCarLCD  
	MOVLW	'I'
	CALL	EnviaCarLCD  
	MOVLW	'O'
	CALL	EnviaCarLCD  
	MOVLW	'N'
	CALL	EnviaCarLCD  
	MOVLW	'E'
	CALL	EnviaCarLCD  
	MOVLW	' '
	CALL	EnviaCarLCD  
	MOVLW	'O'
	CALL	EnviaCarLCD  
	MOVLW	'N'
	CALL	EnviaCarLCD  
	MOVLW	'/'
	CALL	EnviaCarLCD  
	MOVLW	'C'
	CALL	EnviaCarLCD  
	
	MOVLW	LCD_Linha_2	;2 linha
	CALL	EnviaCmdLCD
	MOVLW	'P'
	CALL	EnviaCarLCD  
	MOVLW	'A'
	CALL	EnviaCarLCD  
	MOVLW	'R'
	CALL	EnviaCarLCD  
	MOVLW	'A'
	CALL	EnviaCarLCD  
	MOVLW	' '
	CALL	EnviaCarLCD  
	MOVLW	'I'
	CALL	EnviaCarLCD  
	MOVLW	'N'
	CALL	EnviaCarLCD  
	MOVLW	'I'
	CALL	EnviaCarLCD  
	MOVLW	'C'
	CALL	EnviaCarLCD  
	MOVLW	'I'
	CALL	EnviaCarLCD  
	MOVLW	'A'
	CALL	EnviaCarLCD  
	MOVLW	'R'
	CALL	EnviaCarLCD  
	
	RETURN	
;+++++++++++++++++++++++++++++++++++++++++++++
envia_msg_menu_LCD:
	MOVLW	LCD_Linha_1	;1 linha
	CALL	EnviaCmdLCD
	
	MOVLW	'M'
	CALL	EnviaCarLCD    
	MOVLW	'E'
	CALL	EnviaCarLCD  
	MOVLW	'N'
	CALL	EnviaCarLCD  
	MOVLW	'U'
	CALL	EnviaCarLCD  
	MOVLW	':'
	CALL	EnviaCarLCD  
	MOVLW	' '
	CALL	EnviaCarLCD  
	MOVLW	'P'
	CALL	EnviaCarLCD  
	MOVLW	'R'
	CALL	EnviaCarLCD  
	MOVLW	'E'
	CALL	EnviaCarLCD  
	MOVLW	'S'
	CALL	EnviaCarLCD  
	MOVLW	'S'
	CALL	EnviaCarLCD  
	MOVLW	'I'
	CALL	EnviaCarLCD  
	MOVLW	'O'
	CALL	EnviaCarLCD  
	MOVLW	'N'
	CALL	EnviaCarLCD  
	MOVLW	'E'
	CALL	EnviaCarLCD  
	
	MOVLW	LCD_Linha_2	;2 linha
	CALL	EnviaCmdLCD
	MOVLW	'1'
	CALL	EnviaCarLCD  
	MOVLW	'-'
	CALL	EnviaCarLCD  
	MOVLW	'A'
	CALL	EnviaCarLCD  
	MOVLW	'B'
	CALL	EnviaCarLCD  
	MOVLW	'R'
	CALL	EnviaCarLCD  
	MOVLW	'I'
	CALL	EnviaCarLCD  
	MOVLW	'R'
	CALL	EnviaCarLCD  
	MOVLW	','
	CALL	EnviaCarLCD  
	MOVLW	'2'
	CALL	EnviaCarLCD  
	MOVLW	'-'
	CALL	EnviaCarLCD  
	MOVLW	'O'
	CALL	EnviaCarLCD  
	MOVLW	'P'
	CALL	EnviaCarLCD  
	MOVLW	'C'
	CALL	EnviaCarLCD  
	MOVLW	'O'
	CALL	EnviaCarLCD  
	MOVLW	'E'
	CALL	EnviaCarLCD  
	MOVLW	'S'
	CALL	EnviaCarLCD  
	RETURN
;++++++++++++++++++++++++++++++++++++++++++++++++++    
envia_msg_entrar_LCD:
	MOVLW	LCD_CLEAR
	CALL	EnviaCmdLCD
	MOVLW	LCD_Linha_1	;1 linha
	CALL	EnviaCmdLCD
	MOVLW	'U'
	CALL	EnviaCarLCD    
	MOVLW	'S'
	CALL	EnviaCarLCD  
	MOVLW	'U'
	CALL	EnviaCarLCD  
	MOVLW	'A'
	CALL	EnviaCarLCD  
	MOVLW	'R'
	CALL	EnviaCarLCD  
	MOVLW	'I'
	CALL	EnviaCarLCD  
	MOVLW	'O'
	CALL	EnviaCarLCD  
	MOVLW	':'
	CALL	EnviaCarLCD  
	RETURN
;++++++++++++++++++++++++++++++++++++++++++++++++++++
envia_msg_erro_LCD:
	MOVLW	LCD_CLEAR
	CALL	EnviaCmdLCD
	MOVLW	LCD_Linha_1	;1 linha
	CALL	EnviaCmdLCD
	MOVLW	'U'
	CALL	EnviaCarLCD    
	MOVLW	'S'
	CALL	EnviaCarLCD  
	MOVLW	'U'
	CALL	EnviaCarLCD  
	MOVLW	'A'
	CALL	EnviaCarLCD  
	MOVLW	'R'
	CALL	EnviaCarLCD  
	MOVLW	'I'
	CALL	EnviaCarLCD  
	MOVLW	'O'
	CALL	EnviaCarLCD  
	MOVLW	' '
	CALL	EnviaCarLCD  
	MOVLW	'N'
	CALL	EnviaCarLCD  
	MOVLW	'A'
	CALL	EnviaCarLCD  
	MOVLW	'O'
	CALL	EnviaCarLCD
	MOVLW	LCD_Linha_2	;1 linha
	CALL	EnviaCmdLCD
	MOVLW	'E'
	CALL	EnviaCarLCD
	MOVLW	'N'
	CALL	EnviaCarLCD
	MOVLW	'C'
	CALL	EnviaCarLCD
	MOVLW	'O'
	CALL	EnviaCarLCD
	MOVLW	'N'
	CALL	EnviaCarLCD
	MOVLW	'T'
	CALL	EnviaCarLCD
	MOVLW	'R'
	CALL	EnviaCarLCD
	MOVLW	'A'
	CALL	EnviaCarLCD
	MOVLW	'D'
	CALL	EnviaCarLCD
	MOVLW	'O'
	CALL	EnviaCarLCD
	CALL	delay_1s
	RETURN
;+++++++++++++++++++++++++++++++++++++++++++++++++
envia_msg_senha_LCD:
	MOVLW	LCD_CLEAR
	CALL	EnviaCmdLCD
	MOVLW	LCD_Linha_1	;1 linha
	CALL	EnviaCmdLCD
	MOVLW	'S'
	CALL	EnviaCarLCD    
	MOVLW	'E'
	CALL	EnviaCarLCD  
	MOVLW	'N'
	CALL	EnviaCarLCD  
	MOVLW	'H'
	CALL	EnviaCarLCD  
	MOVLW	'A'  
	CALL	EnviaCarLCD  
	MOVLW	':'
	CALL	EnviaCarLCD  
	RETURN
;++++++++++++++++++++++++++++++++++++++++++++++++++=
envia_msg_senha_erro_LCD:
	MOVLW	LCD_CLEAR
	CALL	EnviaCmdLCD
	MOVLW	LCD_Linha_1	;1 linha
	CALL	EnviaCmdLCD
	MOVLW	'S'
	CALL	EnviaCarLCD    
	MOVLW	'E'
	CALL	EnviaCarLCD  
	MOVLW	'N'
	CALL	EnviaCarLCD  
	MOVLW	'H'
	CALL	EnviaCarLCD  
	MOVLW	'A'
	CALL	EnviaCarLCD  
	MOVLW	LCD_Linha_2	;1 linha
	CALL	EnviaCmdLCD
	MOVLW	'I'
	CALL	EnviaCarLCD
	MOVLW	'N'
	CALL	EnviaCarLCD
	MOVLW	'C'
	CALL	EnviaCarLCD
	MOVLW	'O'
	CALL	EnviaCarLCD
	MOVLW	'R'
	CALL	EnviaCarLCD
	MOVLW	'R'
	CALL	EnviaCarLCD
	MOVLW	'E'
	CALL	EnviaCarLCD
	MOVLW	'T'
	CALL	EnviaCarLCD
	MOVLW	'A'
	CALL	EnviaCarLCD
	CALL	delay_1s
	RETURN
;++++++++++++++++++++++++++++++++++++++++++++++++++=
envia_msg_abrir_LCD:
	MOVLW	LCD_CLEAR
	CALL	EnviaCmdLCD
	MOVLW	LCD_Linha_1	;1 linha
	CALL	EnviaCmdLCD
	MOVLW	'F'
	CALL	EnviaCarLCD    
	MOVLW	'E'
	CALL	EnviaCarLCD  
	MOVLW	'C'
	CALL	EnviaCarLCD  
	MOVLW	'H'
	CALL	EnviaCarLCD  
	MOVLW	'A'
	CALL	EnviaCarLCD  
	MOVLW	'D'
	CALL	EnviaCarLCD  
	MOVLW	'U'
	CALL	EnviaCarLCD  
	MOVLW	'R'
	CALL	EnviaCarLCD  
	MOVLW	'A'
	CALL	EnviaCarLCD  
	
	MOVLW	LCD_Linha_2	;1 linha
	CALL	EnviaCmdLCD
	MOVLW	'A'
	CALL	EnviaCarLCD
	MOVLW	'B'
	CALL	EnviaCarLCD
	MOVLW	'E'
	CALL	EnviaCarLCD
	MOVLW	'R'
	CALL	EnviaCarLCD
	MOVLW	'T'
	CALL	EnviaCarLCD
	MOVLW	'A'
	CALL	EnviaCarLCD
	CALL	delay_1s
	RETURN