			;		ARM Programming Assignment #3: IEEE 754 to TNS bit-level marshaller
			;
			;		Write a program to convert a 32-bit single-precision IEEE 754 floating-point
			;		number to the Tandem Non-stop Series (TNS) format. Refer to the README for a
			;		description of the format. Convert the numbers in `floats` and write the TNS
			;		equivalents into the `tns` area, one after the other.
			;
			;		Bonus:
			;		1. (30 extra points) Implement the reverse conversion, from TNS to IEEE.
			;		2. (50 extra points) Organize the code into two subroutines, with stack
			;		support.
			;		3. (10 extra points) In the main program, implement a round-trip conversion
			;		and prove the results match the initial values in 'floats'.  Define a
			;		`FILL` region to hold the IEEE 754 results.
			;
			
			
floats		DCD		0xa0bcff0d, 0x13c0adea
tns			FILL		16
			
SIGNMASK		DCD		0x0000, 0x8000  ; Mask for sign bit
IEEEEXPMASK	DCD		0x0000, 0x7F80  ; Mask for IEEE Exponent
IEEESIGMASK	DCD		0xFFFF, 0x007F  ; Mask for IEEE Significand
TNSSIGMASK	DCD		0xFE00, 0x7FFF  ; Mask for TNS Significand
TNSEXPMASK	DCD		0x01FF, 0x0000  ; Mask for TNS Exponent
			
			adr		r0, floats	;put floats in r0
			
			;grab	the correct chunks of each number for sign, significand, and exponent
			;add		256 to exponent

			end
