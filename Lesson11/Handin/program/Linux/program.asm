.include "m32def.inc"

;Entry point
.org 0x0000
rjmp INIT
;USART received interrupt
.org 0x1A
jmp USART_Received

INIT:
	;Initialize the stack
	LDI	R16, low(RAMEND)
    OUT	SPL, R16
	LDI	R16, high(RAMEND)
    OUT	SPH, R16

	;Setup USART

	;Half the baud rate divider to get closer to a clean 9600 baud rate
	ldi R16, (1<<U2X)
	out UCSRA, R16

	;Set Baud Rate to 9600 at 1MHz clock
	ldi R16, 0b00000000
	out	UBRRH, R16
	
	ldi R16, 0b00001100		
	out UBRRL, R16

	;Enable receiver and transmitter
	ldi R16, (1<<RXEN)|(1<<TXEN)|(1<<RXCIE)
	out	UCSRB, R16

	; Set frame format: 8data, 1stop bit
	ldi	R16, (1<<URSEL)|(3<<UCSZ0)
	out	UCSRC, R16

	sei									;Enable global interrupts, must be the last thing to be enabled!
	jmp Main

Main:	
;Just loop
rjmp Main

;Waits for an empty transmit buffer and then moves R16 to the transmit buffer
USART_Transmit: 
USART_Transmit_Start:
	; Wait for empty transmit buffer
	sbis	UCSRA,	UDRE
	rjmp	USART_Transmit_Start
	out	UDR, R16
ret

USART_Received:
	in R16, UDR				;Read in the received character

	cpi R16, 'a'			;Compare with 'a' and branch if lower
	brlo USART_Received_Capital_Check

	cpi R16, 0x7B			;Compare with the value after 'z' and branch if equal or higher				
	brsh USART_Received_End

	subi R16, 0x20			;If we are within the range a-z then subtract 0x20 to get the capital letter and jump to the end.
	rjmp USART_Received_End
	
USART_Received_Capital_Check:
	cpi R16, 'A'			;Compare with 'A' and branch if lower
	brlo USART_Received_End

	cpi R16, 0x5B			;Compare with the value after 'Z' and branch if equal or higher		
	brsh USART_Received_End

	ldi R17, 0x20			;If we are within the range A-Z then add 0x20 to get the lowercase letter and jump to the end.
	add R16, R17

USART_Received_End:
	call USART_Transmit		;Echo the received and processed value
reti

