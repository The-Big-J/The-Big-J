#
# sort.S
# Sorting!
#

.include "common.S"

.text

.global sort
.global print_endl

#rdi pointer to array
#rax length of the array
sort:
	pushq %rbp
	movq %rsp, %rbp

	pushq	%rax
	movq	%rax,	%r15	#holds number of f_numbers
	#incq			%r15

bigLoop:		
	cmpq	$1,	%r15		#r15 will count down from nums of f_num to 1
	jbe		done				#then end
	movq	$0,		%r8		#start swapping from first element
	movq	$1,		%r9
	subq	$1,		%r15
smallLoop:
	cmpq	%r15,		%r8	#stop swapping here
	jae		bigLoop
	movss -20(%rdi, %r8, 4), %xmm0
	movss -20(%rdi, %r9, 4), %xmm1

	comiss %xmm0, %xmm1
	ja 		afterSwap		#if second number is bigger, don't swap
swap:
	movss %xmm1, -20(%rdi, %r8, 4)
	movss %xmm0, -20(%rdi, %r9, 4)
afterSwap:
	incq		%r8
	incq		%r9
	jmp		smallLoop

done:

	popq %rax
	movq %rax, %r15
	movq $0, %r8
printing_loop:
	cmpq	$0, %r15
	jbe after_printing
	decq %r15
	push %rdi
	call print_endl
	movss -20(%rdi, %r8, 4), %xmm1
	push %r15
	push %r8
	call print_float
	pop %r8
	pop %r15
	addq $1, %r8
	pop %rdi
	jmp printing_loop

after_printing:
	call print_endl
	popq %rbp
	ret 
	
# Prints the char in al to STDOUT 
print_endl:
	pushq %rbp
	pushq %rdi
	movq %rsp, %rbp

	# Quick thing to print a single char
	movb $'\n', -1(%rbp)
	leaq -1(%rbp), %rsi
	movl $1, %edi
	movl $1, %eax
	movl $1, %edx
	syscall 

	popq %rdi
	popq %rbp
	ret 
