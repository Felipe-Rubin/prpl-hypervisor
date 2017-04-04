/*
Copyright (c) 2016, prpl Foundation

Permission to use, copy, modify, and/or distribute this software for any purpose with or without 
fee is hereby granted, provided that the above copyright notice and this permission notice appear 
in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE
INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE 
FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM 
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, 
ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

This code was written by Carlos Moratelli at Embedded System Group (GSE) at PUCRS/Brazil.

*/

#include <hypercall_defines.h>




    .section .exception
    .org    0xf8
_ebase:
    .word   0x80000000
_imgptr:
    .word   -1
	

	.section .vector0
	.global _isr
_isr:
	.set noreorder
	.set noat

	addi  $sp, $sp, -104
	sw    $at, 16($sp)
	sw    $v0, 20($sp)
	sw    $v1, 24($sp)
	sw    $a0, 28($sp)
	sw    $a1, 32($sp)
	sw    $a2, 36($sp)
	sw    $a3, 40($sp)
	sw    $t0, 44($sp)
	sw    $t1, 48($sp)
	sw    $t2, 52($sp)
	sw    $t3, 56($sp)
	sw    $t4, 60($sp)
	sw    $t5, 64($sp)
	sw    $t6, 68($sp)
	sw    $t7, 72($sp)
	sw    $t8, 76($sp)
	sw    $t9, 80($sp)
	sw    $ra, 84($sp)
	mfc0  $k0, $14        #C0_EPC=14 (Exception PC)
	sw    $k0, 88($sp)
	mfhi  $k1
	sw    $k1, 92($sp)
	mflo  $k1
	sw    $k1, 96($sp)

	mfc0  $a0, $12
	mfc0  $a1, $13

	la    $t9, _irq_handler
	jalr  $t9
	nop
	
	#Restore all temporary registers
	lw    $at, 16($sp)
	lw    $v0, 20($sp)
	lw    $v1, 24($sp)
	lw    $a0, 28($sp)
	lw    $a1, 32($sp)
	lw    $a2, 36($sp)
	lw    $a3, 40($sp)
	lw    $t0, 44($sp)
	lw    $t1, 48($sp)
	lw    $t2, 52($sp)
	lw    $t3, 56($sp)
	lw    $t4, 60($sp)
	lw    $t5, 64($sp)
	lw    $t6, 68($sp)
	lw    $t7, 72($sp)
	lw    $t8, 76($sp)
	lw    $t9, 80($sp)
	lw    $ra, 84($sp)
	lw    $k0, 88($sp)
	lw    $k1, 92($sp)
	mthi  $k1
	lw    $k1, 96($sp)
	mtlo  $k1
	addi  $sp, $sp, 104
isr_return:
	mtc0  $k0, $14	
	eret
	
	
	.set at
	.align 2
	.section .e_entry
	.global _entry
_entry:
	.set noreorder

	la	$gp, _gp
	la	$sp, _stack

	# clear the .bss
	la	$a0, _bss_end
	la	$a1, _bss_start
$BSS_CLEAR:
	sw	$zero, 0($a1)
	slt	$v1, $a1, $a0
	addiu	$a1, $a1, 4
	bnez	$v1, $BSS_CLEAR
	nop

	jal     init_mem
	nop
	jal     init_proc
	nop
	jal     init_network
	nop
        jal     main
        nop
$L1:
	beq	$zero, $zero, $L1
	nop

