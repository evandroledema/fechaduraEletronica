	list	p=16f877a
	
;==============================================
; Vetor de R E S E T
;==============================================
	org		0x00			; vetor de Reset

	
    
CompararSenha:
;tranca_eletronica.c,29 :: 		char CompararSenha()
;tranca_eletronica.c,31 :: 		char i = 0;
	CLRF	CompararSenha_i_L0+0
;tranca_eletronica.c,32 :: 		for(i=0; i < 6; i++)
	CLRF	CompararSenha_i_L0+0
L_CompararSenha0:
	MOVLW	6
	SUBWF      CompararSenha_i_L0+0, 0
	BTFSC	RP1_bit, 0
	GOTO       L_CompararSenha1
;tranca_eletronica.c,34 :: 		if(senha[i] != Eeprom_Read(i)) return(0);
	MOVF       CompararSenha_i_L0+0, 0
	ADDWF      _senha+0, 0
	MOVWF      FSRPTR
	MOVF       INDF, 0
	MOVWF      FLOC__CompararSenha+0
	MOVF       CompararSenha_i_L0+0, 0
	MOVWF      FARG_EEPROM_Read_Address+0
	CALL       _EEPROM_Read+0
	MOVF       FLOC__CompararSenha+0, 0
	XORWF      R0+0, 0
	BTFSC      RP1_bit, 2
	GOTO       L_CompararSenha3
	CLRF       R0+0
	GOTO       L_end_CompararSenha
L_CompararSenha3:
;tranca_eletronica.c,32 :: 		for(i=0; i < 6; i++)
	INCF	CompararSenha_i_L0+0, 1
;tranca_eletronica.c,35 :: 		}
	GOTO	L_CompararSenha0
L_CompararSenha1:
;tranca_eletronica.c,37 :: 		return (1);
	MOVLW      1
	MOVWF      R0+0
;tranca_eletronica.c,38 :: 		}
L_end_CompararSenha:
	RETURN
; end of _CompararSenha

_GravarSenhaNaEeprom:

;tranca_eletronica.c,40 :: 		void GravarSenhaNaEeprom()
;tranca_eletronica.c,43 :: 		for(i=0; i < 6; i++)
	CLRF       GravarSenhaNaEeprom_i_L0+0
L_GravarSenhaNaEeprom4:
	MOVLW      6
	SUBWF      GravarSenhaNaEeprom_i_L0+0, 0
	BTFSC      RP1_bit, 0
	GOTO       L_GravarSenhaNaEeprom5
;tranca_eletronica.c,45 :: 		Eeprom_Write(i, senha[i]);
	MOVF       GravarSenhaNaEeprom_i_L0+0, 0
	MOVWF      FARG_EEPROM_Write_Address+0
	MOVF       GravarSenhaNaEeprom_i_L0+0, 0
	ADDWF      _senha+0, 0
	MOVWF      FSRPTR
	MOVF       INDF, 0
	MOVWF      FARG_EEPROM_Write_data_+0
	CALL       _EEPROM_Write+0
;tranca_eletronica.c,43 :: 		for(i=0; i < 6; i++)
	INCF       GravarSenhaNaEeprom_i_L0+0, 1
;tranca_eletronica.c,46 :: 		}
	GOTO       L_GravarSenhaNaEeprom4
L_GravarSenhaNaEeprom5:
;tranca_eletronica.c,47 :: 		}
L_end_GravarSenhaNaEeprom:
	RETURN
; end of _GravarSenhaNaEeprom

_LimparSenha:

;tranca_eletronica.c,49 :: 		void LimparSenha()
;tranca_eletronica.c,52 :: 		for(i=0; i < 6; i++)
	CLRF       R1+0
L_LimparSenha7:
	MOVLW      6
	SUBWF      R1+0, 0
	BTFSC      RP1_bit, 0
	GOTO       L_LimparSenha8
;tranca_eletronica.c,54 :: 		senha[i] = '0';
	MOVF       R1+0, 0
	ADDWF      _senha+0, 0
	MOVWF      FSRPTR
	MOVLW      48
	MOVWF      INDF
;tranca_eletronica.c,52 :: 		for(i=0; i < 6; i++)
	INCF       R1+0, 1
;tranca_eletronica.c,55 :: 		}
	GOTO       L_LimparSenha7
L_LimparSenha8:
;tranca_eletronica.c,56 :: 		}
L_end_LimparSenha:
	RETURN
; end of _LimparSenha

_main:

;tranca_eletronica.c,58 :: 		void main()
;tranca_eletronica.c,61 :: 		TRISB=0b10000000;
	MOVLW      128
	MOVWF      TRISB0_bit
;tranca_eletronica.c,62 :: 		PORTB=0;
	CLRF       RB0_bit
;tranca_eletronica.c,64 :: 		Keypad_Init();
	CALL       _Keypad_Init+0
;tranca_eletronica.c,65 :: 		Lcd_Init();
	CALL       _Lcd_Init+0
;tranca_eletronica.c,66 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tranca_eletronica.c,67 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tranca_eletronica.c,69 :: 		Ptr2 = textos[3];
	MOVF       _textos+3, 0
	MOVWF      _Ptr2+0
;tranca_eletronica.c,70 :: 		Lcd_Out(1, 1, Ptr2);
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVF       _textos+3, 0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;tranca_eletronica.c,72 :: 		while(1)
L_main10:
;tranca_eletronica.c,75 :: 		if(tentativas < 3)
	MOVLW      3
	SUBWF      _tentativas+0, 0
	BTFSC      RP1_bit, 0
	GOTO       L_main12
;tranca_eletronica.c,77 :: 		kp = Keypad_Key_Click();
	CALL       _Keypad_Key_Click+0
	MOVF       R0+0, 0
	MOVWF      _kp+0
;tranca_eletronica.c,79 :: 		if(kp)
	MOVF       R0+0, 0
	BTFSC      RP1_bit, 2
	GOTO       L_main13
;tranca_eletronica.c,81 :: 		if(kp % 4 == 0)
	MOVLW      3
	ANDWF      _kp+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORLW      0
	BTFSS      RP1_bit, 2
	GOTO       L_main14
;tranca_eletronica.c,84 :: 		}
	GOTO       L_main15
L_main14:
;tranca_eletronica.c,85 :: 		else if(kp == 13) //Limpar
	MOVF       _kp+0, 0
	XORLW      13
	BTFSS      RP1_bit, 2
	GOTO       L_main16
;tranca_eletronica.c,87 :: 		LimparSenha();
	CALL       _LimparSenha+0
;tranca_eletronica.c,88 :: 		cliques = 0;
	CLRF       _cliques+0
;tranca_eletronica.c,89 :: 		}
	GOTO       L_main17
L_main16:
;tranca_eletronica.c,90 :: 		else if(kp == 15) //Enter
	MOVF       _kp+0, 0
	XORLW      15
	BTFSS      RP1_bit, 2
	GOTO       L_main18
;tranca_eletronica.c,92 :: 		cliques = 0;
	CLRF       _cliques+0
;tranca_eletronica.c,93 :: 		if(PORTB.F7 == 1) //Verificar entrada da senha
	BTFSS      RB0_bit, 7
	GOTO       L_main19
;tranca_eletronica.c,95 :: 		if(CompararSenha()) //Sucesso
	CALL       _CompararSenha+0
	MOVF       R0+0, 0
	BTFSC      RP1_bit, 2
	GOTO       L_main20
;tranca_eletronica.c,97 :: 		PORTB.F0 = ~PORTB.F0;
	MOVLW      1
	XORWF      RB0_bit, 1
;tranca_eletronica.c,98 :: 		Ptr1 = textos[0];
	MOVF       _textos+0, 0
	MOVWF      _Ptr1+0
;tranca_eletronica.c,99 :: 		LimparSenha();
	CALL       _LimparSenha+0
;tranca_eletronica.c,100 :: 		}
	GOTO       L_main21
L_main20:
;tranca_eletronica.c,103 :: 		tentativas++;
	INCF       _tentativas+0, 1
;tranca_eletronica.c,104 :: 		Ptr1 = textos[1];
	MOVF       _textos+1, 0
	MOVWF      _Ptr1+0
;tranca_eletronica.c,105 :: 		LimparSenha();
	CALL       _LimparSenha+0
;tranca_eletronica.c,106 :: 		}
L_main21:
;tranca_eletronica.c,107 :: 		}
	GOTO       L_main22
L_main19:
;tranca_eletronica.c,110 :: 		GravarSenhaNaEeprom();
	CALL       _GravarSenhaNaEeprom+0
;tranca_eletronica.c,111 :: 		Ptr1 = textos[2];
	MOVF       _textos+2, 0
	MOVWF      _Ptr1+0
;tranca_eletronica.c,112 :: 		LimparSenha();
	CALL       _LimparSenha+0
;tranca_eletronica.c,113 :: 		}
L_main22:
;tranca_eletronica.c,115 :: 		Lcd_Out(1, 1, Ptr1);
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVF       _Ptr1+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;tranca_eletronica.c,116 :: 		Delay_ms(2000);
	MOVLW      21
	MOVWF      R11+0
	MOVLW      75
	MOVWF      R12+0
	MOVLW      190
	MOVWF      R13+0
L_main23:
	DECFSZ     R13+0, 1
	GOTO       L_main23
	DECFSZ     R12+0, 1
	GOTO       L_main23
	DECFSZ     R11+0, 1
	GOTO       L_main23
	NOP
;tranca_eletronica.c,117 :: 		}
	GOTO       L_main24
L_main18:
;tranca_eletronica.c,120 :: 		switch(kp)
	GOTO       L_main25
;tranca_eletronica.c,122 :: 		case 1: kp = 49; break; //1
L_main27:
	MOVLW      49
	MOVWF      _kp+0
	GOTO       L_main26
;tranca_eletronica.c,123 :: 		case 2: kp = 50; break; //2
L_main28:
	MOVLW      50
	MOVWF      _kp+0
	GOTO       L_main26
;tranca_eletronica.c,124 :: 		case 3: kp = 51; break; //3
L_main29:
	MOVLW      51
	MOVWF      _kp+0
	GOTO       L_main26
;tranca_eletronica.c,125 :: 		case 5: kp = 52; break; //4
L_main30:
	MOVLW      52
	MOVWF      _kp+0
	GOTO       L_main26
;tranca_eletronica.c,126 :: 		case 6: kp = 53; break; //5
L_main31:
	MOVLW      53
	MOVWF      _kp+0
	GOTO       L_main26
;tranca_eletronica.c,127 :: 		case 7: kp = 54; break; //6
L_main32:
	MOVLW      54
	MOVWF      _kp+0
	GOTO       L_main26
;tranca_eletronica.c,128 :: 		case 9: kp = 55; break; //7
L_main33:
	MOVLW      55
	MOVWF      _kp+0
	GOTO       L_main26
;tranca_eletronica.c,129 :: 		case 10: kp = 56; break;//8
L_main34:
	MOVLW      56
	MOVWF      _kp+0
	GOTO       L_main26
;tranca_eletronica.c,130 :: 		case 11: kp = 57; break;//9
L_main35:
	MOVLW      57
	MOVWF      _kp+0
	GOTO       L_main26
;tranca_eletronica.c,131 :: 		case 14: kp = 48; break;//0
L_main36:
	MOVLW      48
	MOVWF      _kp+0
	GOTO       L_main26
;tranca_eletronica.c,132 :: 		}
L_main25:
	MOVF       _kp+0, 0
	XORLW      1
	BTFSC      RP1_bit, 2
	GOTO       L_main27
	MOVF       _kp+0, 0
	XORLW      2
	BTFSC      RP1_bit, 2
	GOTO       L_main28
	MOVF       _kp+0, 0
	XORLW      3
	BTFSC      RP1_bit, 2
	GOTO       L_main29
	MOVF       _kp+0, 0
	XORLW      5
	BTFSC      RP1_bit, 2
	GOTO       L_main30
	MOVF       _kp+0, 0
	XORLW      6
	BTFSC      RP1_bit, 2
	GOTO       L_main31
	MOVF       _kp+0, 0
	XORLW      7
	BTFSC      RP1_bit, 2
	GOTO       L_main32
	MOVF       _kp+0, 0
	XORLW      9
	BTFSC      RP1_bit, 2
	GOTO       L_main33
	MOVF       _kp+0, 0
	XORLW      10
	BTFSC      RP1_bit, 2
	GOTO       L_main34
	MOVF       _kp+0, 0
	XORLW      11
	BTFSC      RP1_bit, 2
	GOTO       L_main35
	MOVF       _kp+0, 0
	XORLW      14
	BTFSC      RP1_bit, 2
	GOTO       L_main36
L_main26:
;tranca_eletronica.c,134 :: 		if(cliques < 6)
	MOVLW      6
	SUBWF      _cliques+0, 0
	BTFSC      RP1_bit, 0
	GOTO       L_main37
;tranca_eletronica.c,136 :: 		for(i=0; i < 5; i++)
	CLRF       main_i_L0+0
L_main38:
	MOVLW      5
	SUBWF      main_i_L0+0, 0
	BTFSC      RP1_bit, 0
	GOTO       L_main39
;tranca_eletronica.c,137 :: 		senha[i] = senha[i+1];
	MOVF       main_i_L0+0, 0
	ADDWF      _senha+0, 0
	MOVWF      R2+0
	MOVF       main_i_L0+0, 0
	ADDLW      1
	MOVWF      R0+0
	CLRF       R0+1
	BTFSC      RP1_bit, 0
	INCF       R0+1, 1
	MOVF       R0+0, 0
	ADDWF      _senha+0, 0
	MOVWF      FSRPTR
	MOVF       INDF, 0
	MOVWF      R0+0
	MOVF       R2+0, 0
	MOVWF      FSRPTR
	MOVF       R0+0, 0
	MOVWF      INDF
;tranca_eletronica.c,136 :: 		for(i=0; i < 5; i++)
	INCF       main_i_L0+0, 1
;tranca_eletronica.c,137 :: 		senha[i] = senha[i+1];
	GOTO       L_main38
L_main39:
;tranca_eletronica.c,138 :: 		senha[5] = kp;
	MOVLW      5
	ADDWF      _senha+0, 0
	MOVWF      FSRPTR
	MOVF       _kp+0, 0
	MOVWF      INDF
;tranca_eletronica.c,139 :: 		}
L_main37:
;tranca_eletronica.c,141 :: 		}
L_main24:
L_main17:
L_main15:
;tranca_eletronica.c,142 :: 		}
	GOTO       L_main41
L_main13:
;tranca_eletronica.c,145 :: 		if(PORTB.F7) Ptr2 = textos[3];
	BTFSS      RB0_bit, 7
	GOTO       L_main42
	MOVF       _textos+3, 0
	MOVWF      _Ptr2+0
	GOTO       L_main43
L_main42:
;tranca_eletronica.c,146 :: 		else Ptr2 = textos[4];
	MOVF       _textos+4, 0
	MOVWF      _Ptr2+0
L_main43:
;tranca_eletronica.c,147 :: 		}
L_main41:
;tranca_eletronica.c,148 :: 		}
	GOTO       L_main44
L_main12:
;tranca_eletronica.c,151 :: 		Ptr2 = textos[5];
	MOVF       _textos+5, 0
	MOVWF      _Ptr2+0
;tranca_eletronica.c,152 :: 		PORTB.F1 = 1;
	BSF        RB0_bit, 1
;tranca_eletronica.c,153 :: 		}
L_main44:
;tranca_eletronica.c,155 :: 		Lcd_Out(1,1, Ptr2);
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVF       _Ptr2+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;tranca_eletronica.c,156 :: 		Lcd_Out(2,8, senha);
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      8
	MOVWF      FARG_Lcd_Out_column+0
	MOVF       _senha+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;tranca_eletronica.c,158 :: 		Delay_ms(100);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      4
	MOVWF      R12+0
	MOVLW      186
	MOVWF      R13+0
L_main45:
	DECFSZ     R13+0, 1
	GOTO       L_main45
	DECFSZ     R12+0, 1
	GOTO       L_main45
	DECFSZ     R11+0, 1
	GOTO       L_main45
	NOP
;tranca_eletronica.c,160 :: 		}
	GOTO       L_main10
;tranca_eletronica.c,161 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
