
// gcc -s -o psuedorand.o psuedorand.s
// ./psuedorand.o

.equ ITERATIONS, 200

.section .data
iseed: .word 0x41c64e6d		// starting seed
multi: .word 12345		// multiplier
incre: .word 1			// increment
modul: .word 5			// 2^5 = 32

.section .rodata
out_s: .asciz "rand()=%d\n"

.text
.global main

main:

//random number generator
/*	Linear Congruential Generator
*	seed: initial value in reg R1
*	multiplier: a in reg R2
*	increment: c in reg R9
*	modulus: m embedded in lsr and lsl (powers of 2)
*	seed = (a*seed + c) % m
*/
	push {lr}
	mov r9, #0
	ldr r0, =out_s
	ldr r1, =iseed
	ldr r3, =incre
	ldr r1, [r1]
	ldr r3, [r3]

randnum:		//line 30
	add r9, #1
	cmp r9, #ITERATIONS
	bgt end_rand

	ldr r1, =iseed
	ldr r1, [r1]
	ldr r0, =out_s
	ldr r2, =multi
	ldr r8, =modul
	ldr r2, [r2]
	ldr r8, [r8]
	mul r4, r1, r2 // r4 = seed * a
	add r5, r4, r9 // r5 = (seed * a) + c
	mov r6, r5, lsr r8 // r6 = ((seed * a) + c)/m
	mov r7, r6, lsl r8 // r7 = m * quotient
	sub r10, r5, r7 // r7 = m - (m*quotient)
	mov r1, r10
	ldr r3, =iseed
	str r1, [r3]
	bl printf
	b randnum

end_rand:
	pop {pc}


