// g++ psuedorandwithrgb.s -lwiringPi -g -o psuedorandwithrgb
// ./psuedorandwithrgb
// gcc psuedorand.o -g
// ./psuedorand.o

.equ ITERATIONS, 20
.equ INPUT, 0
.equ OUTPUT, 1
.equ LOW, 0
.equ HIGH, 1

.equ RED_PIN, 21
.equ GRN_PIN, 22
.equ BLU_PIN, 23

.equ RED_ST, 0
.equ GRN_ST, 1
.equ BLU_ST, 2

.equ DELAY, 500


.section .data
iseed: .word 0x41c64e6d		// starting seed
multi: .word 12345		// multiplier
incre: .word 1			// increment
modul: .word 8			// 2^10 = 1048576

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

	bl wiringPiSetup



	mov r0, #0



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

	mrc p15, 0, r3, c9, c13, 0 // must have enable_ccr compiled for kernel
	add r5, r5, r3

	mov r6, r5, lsr r8 // r6 = ((seed * a) + c)/m
	mov r7, r6, lsl r8 // r7 = m * quotient
	sub r10, r5, r7 // r7 = m - (m*quotient)
	mov r1, r10
	ldr r3, =iseed
	str r1, [r3]
	bl printf
	b colortest

colortest:
	mov r1, r10
	mov r2, #85
	cmp r1, r2
	blt on_red

	mov r2, #170
	cmp r1, r2
	blt on_blu

	b on_grn

on_red:
	mov r0, #RED_PIN
	mov r1, #OUTPUT
	bl pinMode

	mov r0, #RED_PIN
	mov r1, #HIGH
	bl digitalWrite

	mov r0, #DELAY
	bl delay

	mov r0, #RED_PIN
	mov r1, #LOW
	bl digitalWrite
	b randnum

on_grn:
	mov r0, #GRN_PIN
	mov r1, #OUTPUT
	bl pinMode

	mov r0, #GRN_PIN
	mov r1, #OUTPUT
	bl digitalWrite

	mov r0, #DELAY
	bl delay

	mov r0, #GRN_PIN
	mov r1, #LOW
	bl digitalWrite
	b randnum

on_blu:
	mov r0, #BLU_PIN
	mov r1, #OUTPUT
	bl pinMode

	mov r0, #BLU_PIN
	mov r1, #HIGH
	bl digitalWrite


	mov r0, #DELAY
	bl delay

	mov r0, #BLU_PIN
	mov r1, #LOW
	bl digitalWrite
	b randnum

end_rand:
	pop {pc}


