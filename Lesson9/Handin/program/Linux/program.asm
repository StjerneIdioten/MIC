.include "m32def.inc"

;Entry point
.org	0x0000
rjmp	INIT

INIT:
	;Initialize the stack
	LDI	R16, low(RAMEND)
    OUT	SPL, R16
	LDI	R16, high(RAMEND)
    OUT	SPH, R16

	;Port A Setup
	ldi	R16, ~((1<<PA0))	;Set PA0/ADC0 as input
	out	DDRA, R16			;

	;PORTB setup
	ldi R16, (1<<PB3)		;Set PB3/OC0 as output
	out DDRB, R16			;

	;Setup timer0
	ldi R16, 0b01101010		;Fast PWN, Non-inverting, PWM-frequency = ~3906,25 Hz
	out TCCR0, R16			;
	ldi R16, ~0x00			;Turn off the led.
	call PWM_Set			;

	;Setup ADC
	ldi R16, 0b10000101		;Turn on ADC, ADC-Frequency = Clock/32 =125000
	out ADCSR, R16			;

	ldi R16, 0b00100000		;AREF, left justified, ADC0
	out ADMUX, R16			;

	

	rjmp	MAIN			;Go to the main loop

MAIN:	
	
	call Pot_Read			;Read the potentiometer
	call PWM_Set			;Set the duty cycle of the pwn

rjmp MAIN					;Loop

Pot_Read:
	sbi ADCSR, ADSC			;Start a conversion
Pot_Read_Loop:
	sbis ADCSR, ADIF		;Check if the conversion is over yet
	rjmp Pot_Read_Loop		;Loop if not
	sbi ADCSR, ADIF			;Clear the flag
	in R16, ADCH			;Read in the most significant byte of the result
ret

PWM_Set:
	com R16					;Complement the returned value to accomodate the active-low led
	out OCR0, R16			;Set the duty cycle
ret
