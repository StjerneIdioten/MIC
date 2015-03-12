/*
 * 7seg_dec.asm
 *
 *  Created: 05-03-2015 22:59:30
 *   Author: Jonas A. L. Andersen
 */ 

;Defines for 7segment display values

.equ seg0=0b10100000
.equ seg1=0b11110011
.equ seg2=0b10010100
.equ seg3=0b10010001
.equ seg4=0b11000011
.equ seg5=0b10001001
.equ seg6=0b10001000
.equ seg7=0b10110011
.equ seg8=0b10000000
.equ seg9=0b10000001
.equ segE=0b10001100

;Initialize the program

RESET:

;Port C Setup
ldi	R16, 0x00	;Load in input mask 
out	DDRC, R16	;Set PORTC as input
ldi	R16, 0xFF	;Load in pullup mask for all pins on port.
out PORTC,R16 	;Enable pull-up on PORTC

;PORTB setup
ldi	R16, 0xFF	;Load in out mask for all pins on port.
out DDRB,R16 	;PORTB = output
ldi	R16, 0x00	;
out	PORTB, R16	;Turn LEDS off

;Start Program Loop
LOOP:

in	R16, PINC	;Load the value of the buttons into R16

cpi R16, 0xFF	;Test if the buttons are equal to a pattern, in this case zero(Display is active low).
breq SEG0_TRUE	;If the values were equal, then we know which button was pressed. In this case none. Jump to SEG0_TRUE if they were equal.			
				;The rest are just the same code with different values.
								
cpi R16, 0b11111110	
breq SEG1_TRUE

cpi R16, 0b11111101	
breq SEG2_TRUE

cpi R16, 0b11111011	
breq SEG3_TRUE

cpi R16, 0b11110111		
breq SEG4_TRUE

cpi R16, 0b11101111		
breq SEG5_TRUE

cpi R16, 0b11011111		
breq SEG6_TRUE

cpi R16, 0b10111111	
breq SEG7_TRUE

cpi R16, 0b01111111	
breq SEG8_TRUE

				;If more that one button is pressed, the pattern won't match our checks and we will output E and loop again.	
ldi R16,segE	;Load in the value representing that there is an error, E
out PORTB, R16	;Load E to the display
rjmp LOOP		;Loop again

SEG0_TRUE:
ldi R16,seg0	;Load in the value that represents zero on the display
out	PORTB, R16	;Make the display display zero
rjmp	LOOP	;Go back and loop

SEG1_TRUE:
ldi R16,seg1	
out	PORTB, R16	
rjmp	LOOP	

SEG2_TRUE:
ldi R16,seg2	
out	PORTB, R16	
rjmp	LOOP	

SEG3_TRUE:
ldi R16,seg3	
out	PORTB, R16	
rjmp	LOOP	

SEG4_TRUE:
ldi R16,seg4	
out	PORTB, R16	
rjmp	LOOP

SEG5_TRUE:
ldi R16,seg5	
out	PORTB, R16	
rjmp	LOOP	

SEG6_TRUE:
ldi R16,seg6	
out	PORTB, R16	
rjmp	LOOP	

SEG7_TRUE:
ldi R16,seg7	
out	PORTB, R16	
rjmp	LOOP	

SEG8_TRUE:
ldi R16,seg8	
out	PORTB, R16	
rjmp	LOOP	

SEG9_TRUE:
ldi R16,seg9	
out	PORTB, R16	
rjmp	LOOP		
