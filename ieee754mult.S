floats				DCD		0xa0bcff0d, 0x13c0adea ;0x40400000, 0x40200000 ;0xa0bcff0d, 0x13c0adea
result				FILL		8
bitmask1				EQU		0x00000001
bitmask2				EQU		0x00000002
bitmask3				EQU		0x00000004
bitmask4				EQU		0x00000008
bitmask5				EQU		0x00000010
bitmask6				EQU		0x00000020
bitmask7				EQU		0x00000040
bitmask8				EQU		0x00000050
bitmask9				EQU		0x00000100
bitmask10				EQU		0x00000200
bitmask11				EQU		0x00000400
bitmask12				EQU		0x00000800
bitmask13				EQU		0x00001000
bitmask14				EQU		0x00002000
bitmask15				EQU		0x00004000
bitmask16				EQU		0x00008000
bitmask17				EQU		0x00010000
bitmask18				EQU		0x00020000
bitmask19				EQU		0x00040000
bitmask20				EQU		0x00080000
bitmask21				EQU		0x00100000
bitmask22				EQU		0x00200000
bitmask23				EQU		0x00400000
bitmask24				EQU		0x00800000
bitmask25				EQU		0x01000000
bitmask26				EQU		0x02000000
bitmask27				EQU		0x04000000
bitmask28				EQU		0x08000000
bitmask29				EQU		0x10000000
bitmask30				EQU		0x20000000
bitmask31				EQU		0x40000000
bitmask32				EQU		0x80000000
signmask				EQU		0x80000000
					
exponentmask			DCD		0x7F800000	;=mov 7F add bitmask24
fractionmask			EQU		0x007FFFFF	;=bitmask24-1
bias					EQU		127
					
					bal		main
					
mul
					ldmia	SP!,{R0,R1}	;load op1 and op2
					stmdb	SP!,{R4,R5,R6,R9,LR} ;store calleee save regs
					mov		R2,#1		;shift bit
					mov		R3,#-1		;shift count
					mov		R9,#0		;result
					mov		R6,#0		;carry
mul_loop
					cmp		R3,#32		;"
					beq		mul_return
					tst		R0,R2			;test shifting bit against multiplier
					lsl		R2,R2,#1
					add		R3,R3,#1
					beq		mul_loop				;if R3rd bit is zero, loop
					;else	perform the shift-add
					;get		the bits that shift out, add them to the carry (R6)
					mov		R5,R2				;carry bit
					sub		R5,R5,#1				;sub 1, now all bits < carry_bit are 1
					ror		R5,R5,R3				;rotate right by shift index
					ror		R5,R5,#1
					and		R5,R1,R5				;and with the multiplicand
					mov		R4,#32
					sub		R4,R4,R3				;get the number of bits to lsr the result to be added to the cary
					lsr		R5,R5,R4
					add		R6,R6,R5
					mov		R4,R1			;now set up R4 for adding the mulitplicand and carry
					lsl		R4,R4,R3			;shift temp R3 bits
					adds		R9,R9,R4			;add into result register, sets flags
					addcs	R6,R6,#1			;set the carry bit if an add ever sets it
					bal		mul_loop				;loop
mul_return
					mov		R0,R9	;store result in return register
					mov		R1,R6
					ldmia	SP!,{R4,R5,R6,R9,LR}
					mov		PC,LR ;branch back to call
					
getNumSigFigs
					ldmia	SP!,{R0,R1}
					stmdb	SP!,{R2,R3,R4,LR}
					mov		R2,#1	;shift bit
					mov		R3,#0  	;count
					mov		R4,#0	;index
getNumSigFigs_loop_R0
					lsl		R2,R2,#1
					tst		R0,R2
					addeq	R3,R3,#1
					movne	R4,R3
					beq		getNumSigFigs_loop_R0
					mov		R2,#1	;shift bit
					mov		R3,#0  	;count
					;getNumSigFigs_loop_R1
					lsl		R2,R2,#1
					tst		R1,R2
					addeq	R3,R3,#1
					;beq		getNumSigFigs_loop_R1
					;R4		has previous sig fig
					;R3		has current sig fig
					;larger	is the sigfig for mult op
					cmp		R3,R4
					movlt	R4,R3
					
getNumSigFigs_return
					;need	to subtract the value from 23
					;RSB		R0,R4,#23
					mov		R0,R4
					ldmia	SP!,{R2,R3,R4,LR}
					mov		PC,LR
					
main
					adr		R4,floats
					ldr		R3,[R4],#4
					ldr		R4,[R4]
					mov		R2,#bitmask24
					sub		R2,R2,#1
					;load	fractions into r0,r1, insert the implied bit
					;{r0,R1}	are the significands
					and		R0,R3,R2
					and		R1,R4,R2
					orr		R0,R0,#bitmask24
					orr		R1,R1,#bitmask24
					;store	into R9 the number of sig figs for rounding later
					stmdb	SP!,{R0,R1}	;still need these after
					stmdb	SP!, {R0,R1}	;params
					bl		getNumSigFigs
					mov		R9,R0
					ldmia	SP!,{R0,R1}
					;store	sign in R6
					and		R6,R3,#signmask
					and		R5,R4,#signmask
					eor		R6,R6,R5
					;load	exponent into {r2,R3}
					mov		R5,#0x7F000000
					add		R5,R5,#bitmask24
					and		R2,R3,R5
					and		R3,R4,R5
					lsr		R2,R2,#23
					lsr		R3,R3,#23
					;result	exponent
					add		R5,R2,R3
					sub		R5,R5,#bias
					;now		multiplying the significands
					stmdb	SP!,{R0,R1}	;params
					bl		mul
					;		{R1R0} has result from mul
					;shift	the result right by 23 bits, since implicit bit is 24th bit in multiplier, the result
					;get		the bits shifting out of R1, to put them into R0, get R0 bits shifted out, if they are
					mov		R2,R1
					mov		r1,#0
					ror		R2,R2,#23
					mvn		R3,#0xFF
					and		R3,R0,R3
					lsl		R3,R3,#8
					lsr		R0,R0,#23
					orr		R0,R0,R2
					mov		R1,R3
					;result	reg-mem {R0R1} where R0 has the result shifted by 23 bits, and R1 has the bits shifted out of R0
					;R5		has the biased new exponenet
					;R0R1	has result
main_normalize_loop
					mvn		R2,#0xFF000000
					cmp		R0,#bitmask24
					bge		normalize_right
					;less	than, implied bit isnt set, need to shift left
normalize_left
					lsl		R0,R0,#1
					lsls		R1,R1,#1
					addcs	R0,R0,#1
					sub		R5,R5,#1
					cmp		R0,#bitmask24
					blt		normalize_left
					
normalize_right
					cmp		R0,R2
					ble		main_return
					lsr		R1,R1,#1
					lsrs		R0,R0,#1
					orrcs	R1,R1,#0x80000000
					add		R5,R5,#1
					bal		normalize_right
main_return
					
					;R6		has the sign bit
					;R0		has the significand
					;R1		has the bits shifted out of R0
					;R5		has the new biased exponenet... is it > or < -127, then error
					
					;overflow
					cmp		R5,#0xFF
					movge	R5,#0xFF
					movge	R0,#0
					movge	R6,#0
					bge		exit
					;underflow
					cmplt	R5,#1
					movlt	R5,#0xFF
					movlt	R0,#0
					movlt	R6,#0
					blt		exit
					;R9		+ guard and carry bits
					sub		R9,R9,#2
					cmp		R9,#0
					bge		roundWithR0Only
					lsl		R0,R0,#2
					and		R2,R1,#0xC0000000
					orr		R0,R0,R2, lsr #30
					mov		R9,#0
					mov		R8,#1
					
roundWithR0Only
					;round	result
					mov		R2,#1
					lsl		R2,R2,R9
					sub		R2,R2,#1
					mvn		R2,R2
					and		R2,R0,R2
					mov		R3,#1
					add		R3,R2,R3,lsl R9
					;R2		is lower round number, R3 is upper round number
					;R4		has the "middle value"
					mov		R4,#1
					lsl		R4,R4,R9
					lsr		R4,R4,#1
					add		R4,R2,R4
					;round	to nearest, ties to even with R1 having the guard and carry bit
					;round	to nearest?
					cmp		R0,R4
					movgt	R0,R3
					movlt	R0,R2
					bgt		exit
					blt		exit
					mov		R4,#1
					tst		R2,R4,lsl R9
					moveq	R0,R2
					beq		skip
					tstne	R3,R4,lsl R9
					moveq	R0,R3
skip
					;Is		R0 normalized? Then call normalize loop
					;if		guard and carry bits expanded into R1, then need to shift the result right by two bits?
					cmp		R8,#1
					lsreq	R0,R0,#2
					mov		R4,#0xFF000000
					and		R4,R0,R4
					cmp		R4,#0
					bne		main_normalize_loop
					tst		R0, #bitmask25 ;was bitmask24, why?
					bne		main_normalize_loop
					;rounding	successful, and normalized
exit
					mvn		R2,#bitmask24
					and		R0,R0,R2
					orr		R0,R0,R6
					orr		R0,R0,R5,lsl	#23
					
					adr		R2,result
					str		R0,[R2]
					end
