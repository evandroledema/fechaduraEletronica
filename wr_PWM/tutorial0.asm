LIST	p=16F876A		;tell assembler what chip we are using
	include <P16F628.inc>		;include the defaults for the chip
	__config 0x3D18			;sets the configuration settings 
					;(oscillator type etc.)
cblock 	0x20 			;start of general purpose registers
		count1 			;used in delay routine
		counta 			;used in delay routine 
		countb 			;used in delay routine
		T0
		T1
	endc
	
	org	0x0000			;org sets the origin, 0x0000 for the 16F628,
					;this is where the program starts running	
	movlw	0x07
	movwf	CMCON			;turn comparators off (make it like a 16F84)

   	bsf 	STATUS,		RP0	;select bank 1
   	movlw 	b'00000000'		;set PortB all outputs
   	movwf 	TRISB
	movwf	TRISA			;set PortA all outputs
	bcf	STATUS,		RP0	;select bank 0
	clrf	PORTA
	clrf	PORTB			;set all outputs low

Loop	
	bsf	PORTB,	7		;turn on RB7 only!
	call	Delay			;this waits for a while!
	bcf	PORTB,	7		;turn off RB7 only!.
	call	Delay
	goto	Loop			;go back and do it again

Delay	movlw	d'150'			;delay 20 ms (4 MHz clock) estado alto e baixo
	movwf	count1
d1	movlw	0xC7			;delay 1mS
	movwf	counta
	movlw	0x01
	movwf	countb
Delay_0
	decfsz	counta, f
	goto	$+1
	decfsz	countb, f
	goto	Delay_0
	decfsz	count1	,f
	goto	d1
	retlw	0x00

	end
	
	;ESSE CÓDIGO GERA UM PULSO CONFORME VALOR DO DELAY