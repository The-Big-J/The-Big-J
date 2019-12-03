#
# Main entry point for application
#

.text

.global _start

prompt_msg: .ascii "Please enter some floating-point numbers, to exit, enter nothing and press enter\n"
.equ promptlen,.-prompt_msg 

test_float: .ascii "-124.552\n"
.equ test_float_len,.-test_float 

# argc and argv 
argc: .long 0
argv: .quad 0

float_array: .fill 400

_start:
	# Save command line parameters
	movl (%rsp), argc
	movq 8(%rsp), argv  

	# Setup stack frame 
	pushq %rbp
	movq %rsp, %rbp 

	leaq test_float, %rsi
	movl $test_float_len, %eax
	call parse_float 

	movl $1, %eax
	movl $1, %edi
	movq $promptlen, %rdx
	leaq prompt_msg, %rsi
	syscall 

.loop:
	pushq %rdi 
	movl $0, %eax
	movl $0, %edi
	movl $128, %edx
	leaq -128(%rbp), %rsi
	syscall 

	cmpb $0xA, -128(%rbp)
	je .end 

	leaq -128(%rbp), %rsi 
	call parse_float 
	
	popq %rdi
	movss %xmm0, (%rdi)
	addq $4, %rdi 

	jmp .loop 

.end:
	# Print out all the shit

	movl $60, %eax
	syscall
