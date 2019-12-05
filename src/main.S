#
# Main entry point for application
#

.data

# argc and argv 
argc: .long 0
argv: .quad 0

float_array: .fill 400
float_array_size: .long 0

.text

.global _start

repeatmsg: .ascii "Repeat input values? (Enter 1 to repeat, otherwise, enter anything to continue the program) "
.equ replen,.-repeatmsg

rep2: .ascii "Repeat operation choices? (Enter 1 to repeat, otherwise, enter anything to exit)  "
.equ rep2len,.-rep2

prompt_msg: .ascii "\033[92m"
			.ascii "Please enter at least 2 floating-point numbers, up to a maximum of 5. To exit input choices, enter nothing and press enter\n"
.equ promptlen,.-prompt_msg 

prec_err_msg:	.ascii "\033[93m"
				.ascii "Precision error detected.\033[39m"
.equ prec_err_len,.-prec_err_msg

prompt_msg2: .ascii "1 for add, 2 for sub, 3 for mul, 4 for div, 5 for sort\n"
.equ promptlen2,.-prompt_msg2

addmsg: .ascii "Sum is: "
.equ addlen,.-addmsg

submsg: .ascii "Difference is: "
.equ sublen,.-addmsg

mulmsg: .ascii "Product is: "
.equ mullen,.-addmsg

divmsg: .ascii "Quotient is: "
.equ divlen,.-addmsg

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
	
.start1:
	movl $1, %eax
	movl $1, %edi
	movq $promptlen, %rdx
	leaq prompt_msg, %rsi
	syscall 
	# Load pointer to our float array 
	leaq float_array, %rdi 
	movl $0, float_array_size
	movq $0, %r9
.loop:
	pushq %rdi 
	movl $0, %eax
	movl $0, %edi
	movl $128, %edx
	leaq -128(%rbp), %rsi
	syscall 

	cmpb $0xA, -128(%rbp)
	je .inputComplete

	leaq -128(%rbp), %rsi 
	call parse_float 
	
	popq %rdi
	movss %xmm0, (%rdi)
	addq $4, %rdi 
	addl $1, float_array_size
	
	cmpq $3, %r9
	ja .inputComplete
	incq %r9
	jmp .loop 

.error_float:
	movl $1, %eax
	movl $1, %edi
	movl $error_string_len, %edx
	leaq error_string, %rsi
	syscall
	jmp .loop 

.inputComplete:
	movl $1, %eax
	movl $1, %edi
	movq $replen, %rdx
	leaq repeatmsg, %rsi
	syscall 
	
	movl $0, %eax
	movl $0, %edi
	movl $128, %edx
	leaq -128(%rbp), %rsi
	syscall 
	
	cmpb $0x31, -128(%rbp)
	je .start1

	movss (float_array), %xmm11
	movss (float_array+4), %xmm12
	movss (float_array+8), %xmm13
	movss (float_array+12), %xmm14
	movss (float_array+16), %xmm15
	
.opchoice:
	
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
	
	cmpb $0x35, -128(%rbp)
	je .sort
	
	
	
.add:
	movl $1, %eax
	movl $1, %edi
	movq $addlen, %rdx
	leaq addmsg, %rsi
	syscall 
	call addition
	jmp .end

.sub:
movl $1, %eax
	movl $1, %edi
	movq $sublen, %rdx
	leaq submsg, %rsi
	syscall 
	call subtraction
	jmp .end

.mul:
movl $1, %eax
	movl $1, %edi
	movq $mullen, %rdx
	leaq mulmsg, %rsi
	syscall 
	call multipulcation
	jmp .end

.div:
movl $1, %eax
	movl $1, %edi
	movq $divlen, %rdx
	leaq divmsg, %rsi
	syscall 
	call division
	jmp .end

.sort:
	leaq float_array, %rdi
	movq $0, %rax
	movl float_array_size, %eax
	addq $20, %rdi
	call sort

.end:
	call print_endl
	movl $1, %eax
	movl $1, %edi
	movq $rep2len, %rdx
	leaq rep2, %rsi
	syscall 
	
	movl $0, %eax
	movl $0, %edi
	movl $128, %edx
	leaq -128(%rbp), %rsi
	syscall 
	
	cmpb $0x31, -128(%rbp)
	je .opchoice
	
	movl $60, %eax
	syscall
