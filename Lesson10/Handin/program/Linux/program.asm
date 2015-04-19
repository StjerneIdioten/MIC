;.include "m32def.inc"

;Defines
.equ Seg_A = PB6				;Pin of the A segment
.equ Seg_G = PB5				;Pin of the G segment
.equ Seg_D = PB1				;Pin of the D segment

.def tick = R0					;Tick register
.def tick_5Hz = R20				;Tick 5Hz register
.def tick_2Hz = R21				;Tick 2Hz register
.def tick_1Hz = R22				;Tick 1Hz register

;Entry point
.org 0x0000
rjmp INIT

;Timer0 interrupt
.org 0x0014
jmp Timer0_Interrupt

Timer0_Interrupt:
	inc tick					;Increment the tick	
reti

INIT:
	;Initialize the stack
	LDI	R16, low(RAMEND)
    OUT	SPL, R16
	LDI	R16, high(RAMEND)
    OUT	SPH, R16

	;PORTB setup
	ldi R16, 0xFF			
	out DDRB, R16	
	out PORTB, R16		

	;Timer0
	ldi	R16, 0b00001100			; CTC-mode, 1/256 prescaling -> 39 cycles pr. 10ms.
	out	TCCR0, R16				;
	ldi	R16, 0x00				; Counter0 initialization
	out	TCNT0, R16				;
	ldi	R16, 38					; 38+1 cycles = 10[ms] for every output compare match
	out	OCR0, R16				;

	;Enable interrupts
	ldi	R16, (1<<OCIE0)			; enable interrupt on output compare match for timer0
	out	TIMSK, R16				; timer/interrupt masking register
	sei							; enable global interrupt

	jmp Loop

Loop:	
	tst tick					;Test if there has been a tick					
	breq Loop					;Loop if not
	dec tick					;Decrement if there was one

Tick_5Hz_Handling:				;Handles the strobe of the A segment

	inc tick_5Hz				;Increment the 5Hz tick variable
	cpi tick_5Hz, 10			;5Hz = 1/5 = 0.2s, but when it's toggled as a blink, then it becomes 0.2s/2 = 0.1s 
	brne Tick_2Hz_Handling		;Skip if we have not reached the correct delay
		
	clr tick_5Hz				;Clear the 5Hz tick variable
	in R16, PORTB				;Load in the current status of the segments
	mov R17, R16				;Move R16 into R17 for later calculations
	com R17						;Complement this value since the segments are active low. R16 can stay complemented and therefore save me a cycle.
	andi R16, (1<<Seg_A)		;Mask out everything but the bit we are toggling
	andi R17, (1<<Seg_G)|(1<<Seg_D) ;Create a mask where everything but the other two segments are masked out
	or R16, R17					;Or the two masks to get a mask where the segment is toggled and the other two are kept as they were
	com R16						;Complement to accomodate active low
	out PORTB, R16				;Output to the port

Tick_2Hz_Handling:

	inc tick_2Hz				;Increment the 2Hz tick variable
	cpi tick_2Hz, 25			;2Hz = 1/2 = 0.5s, but when it's toggled as a blink, then it becomes 0.5s/2 = 0.25s 
	brne Tick_1Hz_Handling		;Skip if we have not reached the correct delay
			
	clr tick_2Hz				;Clear the 2Hz tick variable
	in R16, PORTB				;Load in the current status of the segments
	mov R17, R16				;Move R16 into R17 for later calculations
	com R17						;Complement this value since the segments are active low. R16 can stay complemented and therefore save me a cycle.
	andi R16, (1<<Seg_G)		;Mask out everything but the bit we are toggling
	andi R17, (1<<Seg_A)|(1<<Seg_D) ;Create a mask where everything but the other two segments are masked out
	or R16, R17					;Or the two masks to get a mask where the segment is toggled and the other two are kept as they were
	com R16						;Complement to accomodate active low
	out PORTB, R16				;Output to the port

Tick_1Hz_Handling:

	inc tick_1Hz				;Increment the 1Hz tick variable
	cpi tick_1Hz, 50			;1Hz = 1/1 = 1s, but when it's toggled as a blink, then it becomes 1s/2 = 0.5s 
	brne Loop					;Skip if we have not reached the correct delay
			
	clr tick_1Hz				;Clear the 1Hz tick variable
	in R16, PORTB				;Load in the current status of the segments
	mov R17, R16				;Move R16 into R17 for later calculations
	com R17						;Complement this value since the segments are active low. R16 can stay complemented and therefore save me a cycle.
	andi R16, (1<<Seg_D)		;Mask out everything but the bit we are toggling
	andi R17, (1<<Seg_A)|(1<<Seg_G) ;Create a mask where everything but the other two segments are masked out
	or R16, R17					;Or the two masks to get a mask where the segment is toggled and the other two are kept as they were
	com R16						;Complement to accomodate active low
	out PORTB, R16				;Output to the port

rjmp Loop

