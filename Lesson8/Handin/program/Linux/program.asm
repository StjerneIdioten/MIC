.include "m32def.inc"

;Definitions
.def COUNT = R20				;Assign a register to hold the count value for the incrementation
.def SWITCH_STATE = R19			;Register to hold the value of the switches

;Constants
.equ segmentCount = 5			;The amount of segments to loop through
.equ debounceDelay = 1			;The delay used for debouncing the switches, not that important in this application.

.org	0x60
segments: .db	0xBF, 0xF7, 0xFB, 0xFD, 0xFE, 0xEF ;Create a list of segment values in program memory

;Entry point
.org	0x0000
rjmp	INIT

INIT:
	;Initialize the stack
	LDI	R16, low(RAMEND)
    OUT	SPL, R16
	LDI	R16, high(RAMEND)
    OUT	SPH, R16

	;Port C Setup
	ldi	R16, 0x00				;Load in input mask 
	out	DDRC, R16				;Set PORTC as input
	ldi	R16, 0xFF				;Load in pullup mask for all pins on port.
	out PORTC,R16 				;Enable pull-up on PORTC

	;PORTB setup
	out DDRB,R16 				;PORTB = output, since R16 is still loaded with 0xFF
	ldi	R16, 0xFF				;
	out	PORTB, R16				;Turn LEDS off

	;Misc setup
	ldi COUNT, 0x00				;Value used for incrementing the display
	rcall INCREMENT_7SEG		;So that the display starts with showing segment a

	rjmp	MAIN				;Go to the main loop

MAIN:							;Total cycles: READ_SWITCH + 1 + 1 + INCREMENT_7SEG + DELAY_MS(SWITCH_STATE) + 2 =
								;1,018ms + The switches time to settle + 24us + ((1000 * SWITCH_STATE) + 7) * 1us + 4us =
								;Worst Case: 256,053ms + The switches time to settle 

	rcall READ_SWITCH			;Read in the value of the switches
	tst SWITCH_STATE			;Test if the switches are activated
	breq MAIN					;If they werent, then restart
	rcall INCREMENT_7SEG		;If they were, then increment the display
	mov R16,SWITCH_STATE		;Load in the value of the switches into R16
	rcall DELAY_MS				;Create a delay with the switch value
	rjmp MAIN					;Loop

READ_SWITCH:					;Total cycles: 3 + 1 + DELAYS_MS(debounceDelay) + 1 + 1 + (READ_SWITCH Branch) + 1 + 4 = 1us * 11 + 1,007ms + (READ_SWITCH Branch) = 1,018ms + The switches time to settle 
	in	SWITCH_STATE, PINC		;Load in the current state of the buttons
	ldi	R16,debounceDelay		;The time in ms that the delay routine shall stall the microcontroller.
	rcall DELAY_MS				;Call the delay subroutine.
	in	R16, PINC				;Load in the new current state of the buttons.
	cp	R16, SWITCH_STATE		;Compare the previous state of the switches to the current state.				
	brne READ_SWITCH			;If they are equal then i assume that the switches have settled.
	com SWITCH_STATE			;Reverse all bits since the switches are active low.
ret

DELAY_MS:	;Read in value of delay in R16, 1-255
									; Cycles to execute 
;----------------------------------/4 cycles, ldi and rcall, +1 cycle if using "call" 
	DELAY_MS_1:	;------------------/    
	ldi R17, 198 ;				   /    
	DELAY_MS_0: ;-------------/    /    
	nop ;				      /B   /A   
	dec R17 ;			      /    /    
	brne DELAY_MS_0 ;---------/    /
	nop ;						   / 
	nop ;						   /
	dec R16 ;			           /    
	brne DELAY_MS_1  ;-------------/    
ret	;------------------------------/4 cycles
; Block B: 199*(1+1+1+2)-1 = 994
; Block A: R16*(1+B+1+1+1+2)-1 = 999, at R16=1; 254999, at R16=255  
; Total # of cycles is: 8 + A = 1007, at R16=1; 255007, at R16=255
; The delay would be perfect, if it was used as a macro. But the rest of the program adds some delay too.

INCREMENT_7SEG:					;Total Delay: 4 + 1 + 1 + 1 + 1 + 1 + 3 + 1 + 1 + 1 + (3 or 4) + 4 = Max 24 * 1us = 24us
	ldi ZH, high(segments<<1)	;load in the high byte of the address of the first value in segments.
	ldi ZL, low(segments<<1)	;load in the low byte of the address of the first value in segments.
	add ZL, COUNT				;Add the offset to get the correct segment
	ldi R16, 0					;Load 0 into R16
	adc ZH, R16					;Add the carry to ZH if there is one from the offset of ZL

	lpm R16, Z					;Load the value that Z points to, into R16
	out PORTB, R16				;Display it on the display

	ldi R16, segmentCount		;Load in the value of how many segments there are.
	cp COUNT, R16				;Check if we have reached the limit of how many segments there are.
	breq INCREMENT_7SEG_RESTART_COUNT;Jump to restart the counter if it's time to loop over.
	inc	COUNT					;If it was not time to loop over, then increment the counter.
	rjmp INCREMENT_7SEG_RETURN	;Jump to main and loop again.
INCREMENT_7SEG_RESTART_COUNT:					
	ldi COUNT, 0x00				;Reset the counter
INCREMENT_7SEG_RETURN:
ret