;============================================
msg_senha:
	movlw	.13
	call	TxCarUART
	movlw	'E'
	call	TxCarUART
	movlw	'n'
	call	TxCarUART
	movlw	's'
	call	TxCarUART
	movlw	'i'
	call	TxCarUART
	movlw	'r'
	call	TxCarUART
	movlw	'a'
	call	TxCarUART
	movlw	' '
	call	TxCarUART
	movlw	's'
	call	TxCarUART
	movlw	'e'
	call	TxCarUART
	movlw	'n'
	call	TxCarUART
	movlw	'h'
	call	TxCarUART
	movlw	'a'
	call	TxCarUART
	movlw	':'
	call	TxCarUART
	movlw	' '
	call	TxCarUART
	return

abrir_fechar:
	movlw	.13
	call	TxCarUART
	movlw	'('
	call	TxCarUART
	movlw	'O'
	call	TxCarUART
	movlw	')'
	call	TxCarUART
	movlw	'A'
	call	TxCarUART
	movlw	'b'
	call	TxCarUART
	movlw	'r'
	call	TxCarUART
	movlw	'i'
	call	TxCarUART
	movlw	'r'
	call	TxCarUART
	movlw	' '
	call	TxCarUART
	movlw	'/'
	call	TxCarUART
	movlw	' '
	call	TxCarUART
	movlw	'('
	call	TxCarUART
	movlw	'C'
	call	TxCarUART
	movlw	')'
	call	TxCarUART
	movlw	'F'
	call	TxCarUART
	movlw	'e'
	call	TxCarUART
	movlw	'c'
	call	TxCarUART
	movlw	'h'
	call	TxCarUART
	movlw	'a'
	call	TxCarUART
	movlw	'r'
	call	TxCarUART
	movlw	' '
	call	TxCarUART
	movlw	'/'
	call	TxCarUART
	movlw	' '
	call	TxCarUART
	movlw	'('
	call	TxCarUART
	movlw	'S'
	call	TxCarUART
	movlw	')'
	call	TxCarUART
	movlw	'P'
	call	TxCarUART
	movlw	'a'
	call	TxCarUART
	movlw	'r'
	call	TxCarUART
	movlw	'a'
	call	TxCarUART
	movlw	'r'
	call	TxCarUART
	movlw	' '
	call	TxCarUART
	movlw	':'
	call	TxCarUART
	movlw	' '
	call	TxCarUART
	return

limpa_tela
	movlw	0x0C	
	call	TxCarUART
	return


msg_senha_errada:
	movlw	.13
	call	TxCarUART
	movlw	'S'
	call	TxCarUART
	movlw	'e'
	call	TxCarUART
	movlw	'n'
	call	TxCarUART
	movlw	'h'
	call	TxCarUART
	movlw	'a'
	call	TxCarUART
	movlw	' '
	call	TxCarUART
	movlw	'e'
	call	TxCarUART
	movlw	'r'
	call	TxCarUART
	movlw	'r'
	call	TxCarUART
	movlw	'a'
	call	TxCarUART
	movlw	'd'
	call	TxCarUART
	movlw	'a'
	call	TxCarUART
	movlw	'!'
	call	TxCarUART
	return

msg_senha_correta:
	movlw	.13
	call	TxCarUART
	movlw	'S'
	call	TxCarUART
	movlw	'e'
	call	TxCarUART
	movlw	'n'
	call	TxCarUART
	movlw	'h'
	call	TxCarUART
	movlw	'a'
	call	TxCarUART
	movlw	' '
	call	TxCarUART
	movlw	'c'
	call	TxCarUART
	movlw	'o'
	call	TxCarUART
	movlw	'r'
	call	TxCarUART
	movlw	'r'
	call	TxCarUART
	movlw	'e'
	call	TxCarUART
	movlw	't'
	call	TxCarUART
	movlw	'a'
	call	TxCarUART
	movlw	'!'
	call	TxCarUART
	return

