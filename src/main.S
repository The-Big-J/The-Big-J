#
# Main entry point for application
#

.text

.global _start
.extern float_to_int

prompt_msg: .ascii "Please enter some floating-point numbers, to exit, enter nothing and press enter\n"
.equ promptlen,.-prompt_msg 

_start:
	pushq %rbp
	movq %rsp, %rbp 

	movl $1, %eax
	movl $1, %edi
	movq $promptlen, %rdx
	leaq prompt_msg, %rsi
	syscall 

.loop:
	movl $0, %eax
	movl $0, %edi
	movl $128, %edx
	leaq -128(%rbp), %rsi
	syscall 

	cmpb $0xA, -128(%rbp)
	je .end 
	jmp .loop 

.end:
	# Print out all the shit

	movl $60, %eax
	syscall
