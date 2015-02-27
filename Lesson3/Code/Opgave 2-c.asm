.include "m32def.inc"
;Initialisér programmet
RESET:
ldi	R16, 0x00	; 
out	DDRC, R16	; Set PORTC as input
ldi	R16, 255	;
out 	PORTC,R16 	; Enable pull-up on PORTC

; PORTB setup
out 	DDRB,R16 	; PORTB = output
ldi	R16, 0x00	;
out	PORTB, R16	; Turn LEDS off

;Start programløkken
LOOP:
in	R16, PINC
com	R16
ldi	R17, 0x00
or	R16, R17
brne	SET
ldi	R16, 0xFF
out	PORTB, R16
rjmp	LOOP

SET:
ldi	R16,0x80
com	R16
out	PORTB, R16
rjmp 	LOOP


