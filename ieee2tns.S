			
floats		DCD		0x40200000, 0x40200000	;converts to 20000101
tns			FILL		16
result		FILL		16
			
			
SIGNMASK		DCD		0x80000000  ; Mask for sign bit
IEEEEXPMASK	DCD		0x7F800000  ; Mask for IEEE Exponent
IEEESIGMASK	DCD		0x007FFFFF  ; Mask for IEEE Significand
TNSSIGMASK	DCD		0x7FFFFE00  ; Mask for TNS Significand
TNSEXPMASK	DCD		0x000001FF  ; Mask for TNS Exponent
			
main
			;simple	ieee to tns using floats
			adr		r3, floats
			ldr		r0, [r3], #4
			stmdb	sp!, {r0}
			bl		ieeetotns
			mov		r4, r0
			ldr		r0, [r3]
			stmdb	sp!, {r0}
			bl		ieeetotns
			mov		r5, r0
			adr		r3,tns
			stmia	r3!,{r4,r5}
			adr		r3,floats
			ldr		r0,[r3]
			stmdb	sp!,{r0}
			bl		ieeetotns
			mov		r4,r0
			stmdb	sp!,{r0}
			bl		tnstoieee
			mov		r5,r0
			adr		r6,result
			stmia	r6!,{r4,r5}
			adr		r3,floats
			ldr		r0,[r3,#4]
			stmdb	sp!,{r0}
			bl		ieeetotns
			mov		r4,r0
			stmdb	sp!,{r0}
			bl		tnstoieee
			mov		r5,r0
			stmia	r6!,{r4,r5}
			
			end
			
ieeetotns
			ldmia	sp!,{r0}
			stmdb	sp!,{r3,r4,r5,r6,r7,lr}
			adr		r1, SIGNMASK
			ldr		r1,[r1]
			adr		r2, IEEEEXPMASK
			ldr		r2,[r2]
			adr		r3, IEEESIGMASK
			ldr		r3,[r3]
			
			;Convert	from IEEE to TNS
			and		r4, r0, r1
			and		r5, r2, r0
			mov		r5, r5, lsr #23
			add		r5, r5, #129
			and		r6, r3, r0
			add		r6, r7, r6, lsl #8
			orr		r0, r4, r5          ; combine
			orr		r0, r0, r6
			;		r0 now holds IEEE to TNS converted word
			ldmia	sp!,{r3,r4,r5,r6,r7,lr}
			mov		pc, lr
			
			;		Load TNS Masks
tnstoieee
			ldmia	sp!,{r0}
			stmdb	sp!,{r3,r4,r5,r6,r7,lr}
			adr		r1, SIGNMASK
			ldr		r1,[r1]
			adr		r2, TNSSIGMASK
			ldr		r2,[r2]
			adr		r3, TNSEXPMASK
			ldr		r3,[r3]
			;		Convert back to IEEE
			and		r4, r0, r1
			and		r5, r2, r0
			mov		r5, r5, lsr #8
			and		r6, r3, r0
			sub		r6, r6, #129
			add		r6, r7, r6, lsl #23
			
			;		combine
			orr		r0, r4, r5
			orr		r0, r0, r6
			;		r0 now holds TNS to IEEE converted word
			ldmia	sp!,{r3,r4,r5,r6,r7,lr}
			mov		pc, lr
			
