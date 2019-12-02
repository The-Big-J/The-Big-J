#
# Main entry point for application
#

.text

.global _start
.extern float_to_int

prompt_msg: .ascii "Please enter some floating-point numbers, and press CTRL+D to stop.\n"
.equ promptlen,.-prompt_msg 

_start:
	movl $1, %eax
	movl $1, %edi
	movq $promptlen, %rdx
	leaq prompt_msg, %rsi
	syscall 

.loop:
	movl $0, %eax
	movl $0, %edi
	movq $128, %edx
	leaq -128(%rbp), %rsi
	syscall 

	cmpq $4, -128(%rbp)
	je .end 
	jmp .loop 


.end:
	# Print out all the shit

	movl $60, %eax
	syscall
