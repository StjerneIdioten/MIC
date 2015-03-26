
.include "DelayMacros.asm"

.include "m32def.inc"

.equ segmentCount = 5 ;The amount of segments to loop through
.equ delayTime = 5 ;The delay routine used is about 39.2ms per 1 increase in value.

.def COUNT = R20 ;Assign a register to hold the count value for the incrementation
.def PREV_BUTTON = R21 ;Assign a register to hold the value of the previous button state
.org	0x0000
rjmp	INIT

.org	0x60
segments: .db	0xBF, 0xF7, 0xFB, 0xFD, 0xFE, 0xEF ;Create a list of segment values in program memory

INIT:
;Port C Setup
ldi	R16, 0x00	;Load in input mask 
out	DDRC, R16	;Set PORTC as input
ldi	R16, 0xFF	;Load in pullup mask for all pins on port.
out PORTC,R16 	;Enable pull-up on PORTC

;PORTB setup
out DDRB,R16 	;PORTB = output, since R16 is still loaded with 0xFF
ldi	R16, 0xFF	;
out	PORTB, R16	;Turn LEDS off

;Misc setup
ldi COUNT, 0x00
in PREV_BUTTON, PINC

rjmp	MAIN

MAIN:

in	R19, PINC			  ;Load in the current state of the buttons
DELAY delayTime			  ;Delay for the delayTime ~ 200ms
in	R16, PINC			  ;Load in the new current state of the buttons
cp	R16, R19				
brne MAIN				  ;If they are equal then the button has settled
cp	PREV_BUTTON, R19	  ;Now compare the new button state with the old button state, if they are not equal then increment the counter.
breq MAIN
	
mov PREV_BUTTON, R19	  ;Assign the new button state as the previous button state for the next increment of the display.

ldi ZH, high(segments<<1) ;load in the high byte of the address of the first value in segments.
ldi ZL, low(segments<<1)  ;load in the low byte of the address of the first value in segments.
add ZL, COUNT			  ;Add the offset to get the correct segment
ldi R16, 0				  ;Load 0 into R16
adc ZH, R16				  ;Add the carry to ZH if there is one from the offset of ZL

lpm R16, Z				  ;Load the value that Z points to, into R16
out PORTB, R16			  ;Display it on the display

ldi R16, segmentCount	  ;Load in the value of how many segments there are.
cp COUNT, R16			  ;Check if we have reached the limit of how many segments there are.
breq	RESTART			  ;Jump to restart the counter if it's time to loop over.
inc	COUNT				  ;If it was not time to loop over, then increment the counter.
rjmp	MAIN			  ;Jump to main and loop again.
RESTART:					
ldi COUNT, 0x00			  ;Reset the counter
rjmp	MAIN
