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

http: .string "Content-type: text/html\n"
.equ htmllen,.-http 

prompt_msg: .ascii "Please enter some floating-point numbers, to exit, enter nothing and press enter\n"
.equ promptlen,.-prompt_msg 

prompt_msg2: .ascii "1 for add, 2 for sub, 3 for mul, 4 for div\n"
.equ promptlen2,.-prompt_msg2

test_float: .ascii "-124.552\n"
.equ test_float_len,.-test_float 

_start:
	# Save command line parameters
	movl (%rsp), %eax 
	movq 8(%rsp), %rbx
	movl %eax, argc
	movq %rbx, argv 
	
#.cgi:
#	decq %rsp
#	cmpq $':', %rsp
#	jne .cgi
	
#.cgi2:
#	incq %rsp
#	cmpq $'=', %rsp
#	jne .cgi2
#	incq %rsp

#.cgi3:
#	movl $0, %eax
#	movl $0, %edi
#	movl $128, %edx
#	leaq -128(%rbp), %rsi
#	syscall 
#	incq %rsp
#	cmpq $'&', %rsp
#	jne .cgi3
	
	
	
	
	# Setup stack frame 
	pushq %rbp
	movq %rsp, %rbp 

	movl $1, %eax
	movl $1, %edi
	movq $htmllen, %rdx
	leaq http, %rsi
	syscall

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

	leaq -128(%rbp), %rsi 
	call parse_float 
	
	popq %rdi
	movss %xmm0, (%rdi)
	addq $4, %rdi 
	
	cmpq $3, %r9
	ja .OPQRST
	incq %r9
	jmp .loop 

.OPQRST:
	movss -20(%rdi), %xmm11
	movss -16(%rdi), %xmm12
	movss -12(%rdi), %xmm13
	movss -8(%rdi), %xmm14
	movss -4(%rdi), %xmm15
	
	movl $1, %eax
	movl $1, %edi
	movq $promptlen2, %rdx
	leaq prompt_msg2, %rsi
	syscall 
	
	movl $0, %eax
	movl $0, %edi
	movl $128, %edx
	leaq -128(%rbp), %rsi
	syscall 
	
	cmpb $0x31, -128(%rbp)
	je .add

	cmpb $0x32, -128(%rbp)
	je .sub
	
	cmpb $0x33, -128(%rbp)
	je .mul
	
	cmpb $0x34, -128(%rbp)
	je .div
	
.add:
call addition
jmp .end

.sub:
call subtraction
jmp .end

.mul:
call multipulcation
jmp .end

.div:
call division
jmp .end

.end:
	call sort

	movl $60, %eax
	syscall
