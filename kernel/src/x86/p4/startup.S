/*********************************************************************
 *                
 * Copyright (C) 2001,  Karlsruhe University
 *                
 * File path:     x86/p4/startup.S
 * Description:   Startup code for Pentium4 processors.
 *                
 * @LICENSE@
 *                
 * $Id: startup.S,v 1.5 2001/11/22 13:39:08 skoglund Exp $
 *                
 ********************************************************************/
.globl	_start
.section .init

#include <config.h>
#include <x86/config.h>
#include <x86/cpu.h>

#if (__GNUC__ >= 3)
# define INIT_PAGING	_Z11init_pagingv
# define INIT		_Z4initv
#else
# define INIT_PAGING	init_paging__Fv
# define INIT		init__Fv
#endif
	
_start:
	/* Save the multiboot info structure pointer (ebx) to physical
	   address of kernel_arg. We assume that the kernel IS multibooted.
	   This value is later on passed to the root task */
	/* UD: Actually, we should save the mbi flags as well - just for the
	   case where we AREN'T multibooted. */
	movl	%ebx, kernel_arg - KERNEL_OFFSET
	cli	/* disable int's */
	cld	/* clear direction flag */
	mov	%ds, %ax
	mov	%ax, %es
	mov	%ax, %fs
	jmp	1f
1:
	nop
	nop
	mov	%ax, %gs
	mov	%ax, %ss

	/* load temporary stack pointer */
	lea	_mini_stack-4, %esp
	/* set up paging */
	call	INIT_PAGING


	/* Enable various CPU features. */
	mov	$IA32_MISC_ENABLE, %ecx
	sub	%eax, %eax
	sub	%edx, %edx
#if defined(CONFIG_PERFMON)
	add	$IA32_ENABLE_PERFMON, %eax
#endif
#if defined(CONFIG_X86_P4_BTS)
	add	$IA32_ENABLE_BRANCH_TRACE, %eax
#endif
#if defined(CONFIG_X86_P4_PEBS)
	add	$IA32_ENABLE_PEBS, %eax
#endif
	wrmsr

	/* still running in 1:1 mapped area
	   jump to the top level init function */ 
	jmp	INIT


	.space	1024
	.globl	_mini_stack
_mini_stack:

	.section .mb_header
	.align	4
_mb_header:
        .long   0x1BADB002			/* magic */
        .long   0x00000000			/* flags */
        .long   - 0x00000000 - 0x1BADB002	/* check */
