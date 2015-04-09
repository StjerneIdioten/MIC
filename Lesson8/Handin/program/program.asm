;.include "m32def.inc"

;Definitions
.equ S11 = PD2				;Switch 11
.equ S10 = PD6				;Switch 10

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
	out	DDRD, R16			;Set S11 and S10 as input. Everything else is output.

	;PORTB setup
	ldi R16, 0xFF			
	out DDRB,R16 			;PORTB = output
	ldi	R16, 0xFF			;
	out	PORTB, R16			;Turn LEDS off

	clr R16					;Clear the registers
	clr R17					;
	clr R18					;	
	clr R19					;

	rjmp	MAIN			;Go to the main loop

MAIN:

	ldi R17, HIGH(2655)		;Load in 2655	
	ldi R16, LOW(2655)		;

	ldi R19, HIGH(74)		;Load in 74	
	ldi R18, LOW(74)		;
	
	rcall SUM16				;Add 2655 to 74
	
	ldi R19, HIGH(592)		;Load in 592
	ldi R18, LOW(592)		;

	rcall SUM16				;Add 592 to the previous sum which was 2729
	
	ldi R19, HIGH(1380)		;Load in 1380
	ldi R18, LOW(1380)		;
	
	rcall SUM16				;Add 1380 to the previous sum which was 3321

	ldi R19, HIGH(17352)	;Load in 17352	
	ldi R18, LOW(17352)		;
	
	rcall SUM16				;Add 17352 to the previous sum which was 4701
				
	ldi R18, 5				;Load in 5

	rcall DIV16_8			;Divide the previous sum which was 22053 with 5

	mov R19, R18			;Move the returned results one register up
	mov R18, R17			;
	mov R17, R16			;

	com R17					;Complement the result to accomodate the active low display
	com R18					;
	com R19					;
		
	rcall PRINT_DIODE		;Go to the printout subroutine		

rjmp MAIN					;Loop


SUM16:						;Add two 16 bit numbers together. Does not support an overflow into the 17th bit
	add R16, R18			;Add the lsb parts together
	adc R17, R19			;Add the msb parts together with carry
ret


DIV16_8:					;Divide a 16 bit value with an 8 bit value
	
	clr ZH					;Quotient high
	clr ZL					;Quotient low

DIV16_8_Loop:

	adiw ZH:ZL, 1			;Quotient ++
	sub R16 ,R18			;Subract the denominator from the lsb of the numerator
	sbci R17, 0				;Subract the carry from the msb of the numerator
	brcc DIV16_8_Loop		;If we did not go below zero, loop.
	sbiw ZH:ZL, 1			;Quotient --
	add R16, R18			;Add the denominator to the numerator
							;I don't need to add any carry since i know this will never result in a carry due to the nature of the addition.
	mov R18, R16			;Output the leftover value to R18
	movw R17:R16,ZH:ZL		;Output the quotient to R17:R16
ret

PRINT_DIODE:
	in R16, PIND			;Read in the pins
	ori R16, 0xBB			;Mask out the value of all other pins, that the buttons.
	com R16					;Complement so that we can test for zero
	tst R16					;Test for zero
	breq PRINT_DIODE_NONE	;Branch to none, if no switches was activated.
	cpi R16, (1<<S10)|(1<<S11) ;If not zero, then compare with a mask where both switches are activated.
	breq PRINT_DIODE_BOTH	;Branch if both were activated
	sbrs R16, S10			;If they werent both activated, then check if S10 is activated.
	rjmp PRINT_DIODE_S11	;Branch to S11 handling, if S10 was not active.
PRINT_DIODE_S10:			;Go to S10 handling if S10 was active.
	out PORTB, R17			;Output the LSB of the quotient
	rjmp PRINT_DIODE_END	;Jump to the end
PRINT_DIODE_S11:			;S11 handling
	out PORTB, R18			;Output the MSB of the quotient
	rjmp PRINT_DIODE_END	;Jump to the end
PRINT_DIODE_BOTH:			;Both switches active, handling
	out PORTB, R19			;Output the leftover value
	rjmp PRINT_DIODE_END	;Jump to the end
PRINT_DIODE_NONE:			;No switches active, handling
	ser R16					;Set the register to accomodate active low
	out PORTB, R16			;Clear the display
PRINT_DIODE_END:			;Loop, handling
	rjmp PRINT_DIODE		;Loop
ret