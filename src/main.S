#
# Main entry point for application
#

.data

# argc and argv 
argc: .long 0
argv: .quad 0

float_array: .fill 400

.text

.global _start

prompt_msg: .ascii "Please enter some floating-point numbers, to exit, enter nothing and press enter\n"
.equ promptlen,.-prompt_msg 

test_float: .ascii "-124.552\n"
.equ test_float_len,.-test_float 

_start:
	# Save command line parameters
	movl (%rsp), %eax 
	movq 8(%rsp), %rbx
	movl %eax, argc
	movq %rbx, argv 

	# Setup stack frame 
	pushq %rbp
	movq %rsp, %rbp 

	movl $1, %eax
	movl $1, %edi
	movq $promptlen, %rdx
	leaq prompt_msg, %rsi
	syscall 
	# Load pointer to our float array 
	leaq float_array, %rdi 
.loop:
	pushq %rdi 
	movl $0, %eax
	movl $0, %edi
	movl $128, %edx
	leaq -128(%rbp), %rsi
	syscall 

	cmpb $0xA, -128(%rbp)
	je .end 

	pushq %rax 
	leaq -128(%rbp), %rsi
	call verify_float
	cmpl $1, %eax
	je .end
	popq %rax 

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
