# VaMP3 Makefile

AS = vasmm68k_mot
ASFLAGS = -m68080 -Fhunkexe -Iinclude -Iinclude: -Isrc

all: build/VaMP3

build/VaMP3: vamp3.s
	$(AS) $(ASFLAGS) -o $@ $<

clean:
	-delete build/VaMP3

