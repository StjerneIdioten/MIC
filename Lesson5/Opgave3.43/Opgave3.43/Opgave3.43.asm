/*
 * Opgave3.asm
 *
 *  Created: 06-03-2015 10:26:39
 *   Author: StjerneIdioten
 */ 


.equ TEMP0=0x60
.equ TEMP1=0x61
.equ TEMP2=0x62
.equ TEMP3=0x63
.equ TEMP4=0x64
.equ TEMP5=0x65

RESET:

ldi R29,0x11  
sts TEMP0,R29
sts TEMP1,R29
sts TEMP2,R29
sts TEMP3,R29
sts TEMP4,R29
sts TEMP5,R29


