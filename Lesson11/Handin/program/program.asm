;.include "m32def.inc"

;Entry point
.org 0x0000
rjmp INIT

.include "USART_library.asm"

INIT:
	;Initialize the stack
	LDI	R16, low(RAMEND)
    OUT	SPL, R16
	LDI	R16, high(RAMEND)
    OUT	SPH, R16

	USART_Init 0b00000000,0b00000110

	jmp Loop

Loop:	
	call USART_Receive
	ldi R16, 'A'
	call USART_Transmit
	USART_Newline

rjmp Loop

