;.include "m32def.inc"

;Definitions
.def COUNT = R20				;Assign a register to hold the count value for the incrementation
.equ S11 = PD2
.equ S10 = PD6

;Constants
.equ debounceDelay = 1			;The delay used for debouncing the switches, not that important in this application.

;Entry point
.org	0x0000
rjmp	INIT

INIT:
	;Initialize the stack
	LDI	R16, low(RAMEND)
    OUT	SPL, R16
	LDI	R16, high(RAMEND)
    OUT	SPH, R16

	;Port D Setup
	ldi	R16, ~((1<<S11)|(1<<S10))
	out	DDRD, R16				;Set S11 and S10 as input. Everything else is output.

	;PORTB setup
	ldi R16, 0xFF
	out DDRB,R16 				;PORTB = output
	ldi	R16, 0xFF				;
	out	PORTB, R16				;Turn LEDS off

	clr R16
	clr R17
	clr R18
	clr R19

	rjmp	MAIN				;Go to the main loop

MAIN:
	ldi R17, HIGH(2655)	
	ldi R16, LOW(2655)
	ldi R19, HIGH(74)	
	ldi R18, LOW(74)
	
	rcall SUM16

	ldi R19, HIGH(592)	
	ldi R18, LOW(592)

	rcall SUM16

	ldi R19, HIGH(1380)	
	ldi R18, LOW(1380)

	rcall SUM16

	ldi R19, HIGH(17352)	
	ldi R18, LOW(17352)
	
	rcall SUM16
	
	ldi R18, 5

	rcall DIV16_8

	mov R19, R18
	mov R18, R17
	mov R17, R16
	com R17
	com R18
	com R19
						
	rcall PRINT_DIODE

rjmp MAIN					;Loop

SUM16:
	add R16, R18
	adc R17, R19
ret

DIV16_8:
	
	clr ZH ;Kvotient high
	clr ZL ;Kvotient low

DIV16_8_Loop:

	adiw ZH:ZL, 1 ;Kvotient ++

	sub R16 ,R18 ;Træk nævner fra tæller
	sbci R17, 0
	brcc DIV16_8_Loop
	
	sbiw ZH:ZL, 1 ;Kvotient --

	add R16, R18 ;Læg nævner til
	
	mov R18, R16
	movw R17:R16,ZH:ZL

ret

PRINT_DIODE:
	in R16, PIND
	ori R16, 0xBB
	com R16
	tst R16
	breq PRINT_DIODE_NONE
	cpi R16, (1<<S10)|(1<<S11)
	breq PRINT_DIODE_BOTH
	sbrs R16, S10
	rjmp PRINT_DIODE_S11
PRINT_DIODE_S10:
	out PORTB, R17
	rjmp PRINT_DIODE_END
PRINT_DIODE_S11:
	out PORTB, R18
	rjmp PRINT_DIODE_END
PRINT_DIODE_BOTH:
	out PORTB, R19
	rjmp PRINT_DIODE_END
PRINT_DIODE_NONE:
	ser R16
	out PORTB, R16
PRINT_DIODE_END:
	rjmp PRINT_DIODE
ret