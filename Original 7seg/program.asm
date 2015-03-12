; ***********************************
; * 7-segment display
; * Leon Bonde Larsen
; ***********************************
; * Written for MIC ATmega32A board
; * Output the value of switches 0-3
; * as hex value on 7-segment display
; ***********************************

	.include "m32def.inc"

.org	0x0000
	rjmp	init

.org	0x60
digits:	.include "digits_table.asm"

init:	.include "setup_stack.asm"	
	.include "setup_io.asm"

	rjmp	main

; ***********************************
; * Main program
; ***********************************
main:	in	R16,PINC 		; read port C
	com	R16					; take complement to accomodate active low
	ldi 	R17, 0x0F		; load mask
	and 	R16, R17		; mask out high nibble

	ldi	ZH,high(digits<<1)	; make high byte of Z point at address of digit 0
	ldi 	ZL,low(digits<<1)	; make low byte of Z point at address of digit 0

	add	ZL, R16			; Offset Z to point at the digit corresponding to switches
	ldi	R16, 0			; Load zero
	adc	ZH, R16			; Add high byte of Z with carry

	lpm	R16, Z			; Load the data that Z points to
	out	PORTB, R16		; Display data on port
	rjmp	main			; Loop forever


