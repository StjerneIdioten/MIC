# Makefile for programming ATmega32 using assembler
PROJECT=Opgave 2-a
PROJECT1 = Opgave 2-a 
PROJECT2 = Opgave 2-c 
PROGRAMMER=-c avrispmkII -P usb # For the large blue AVR MKII
#PROGRAMMER=-c avrisp -P /dev/ttyUSB0  # For the small green programmer

default:
	avra $(PROJECT).asm
	sudo avrdude -p m32 $(PROGRAMMER) -U flash:w:$(PROJECT).hex

fuse:
	sudo avrdude -p m32 $(PROGRAMMER) -U hfuse:w:0xd9:m -U lfuse:w:0xe4:m 

clean:
	rm -f $(PROJECT).obj $(PROJECT).hex $(PROJECT).cof $(PROJECT).eep.hex

erase:
	sudo avrdude -p m32 $(PROGRAMMER) -e

opgave2a:
	avra $(PROJECT1).asm
	sudo avrdude -p m32 $(PROGRAMMER) -U flash:w:$(PROJECT1).hex

opgave2c:
	avra $(PROJECT2).asm
	sudo avrdude -p m32 $(PROGRAMMER) -U flash:w:$(PROJECT2).hex
	
	
