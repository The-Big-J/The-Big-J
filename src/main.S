#
# Main entry point for application
#

.data

# argc and argv 
argc: .long 0
argv: .quad 0

float_array: .fill 40
float_array_size: .long 0

.text

.global _start

repeatmsg: .ascii "Repeat input values? (Enter 1 to repeat, otherwise, enter anything to continue the program) "
.equ replen,.-repeatmsg

rep2: .ascii "Repeat operation choices? (Enter 1 to repeat, otherwise, enter anything to exit)  "
.equ rep2len,.-rep2

prompt_msg: .ascii "\033[92m"
			.ascii "Please enter at least 2 floating-point numbers, up to a maximum of 5. \nTo exit input choices, enter nothing and press enter\n"
			.ascii "\033[39m"
.equ promptlen,.-prompt_msg 

prec_err_msg:	.ascii "\033[93m"
				.ascii "Precision error detected.\033[39m"
.equ prec_err_len,.-prec_err_msg

prompt_msg2: .ascii "Enter the following number for operations of the first two numbers: \n1 for Addition \n2 for Subtraction \n3 for Multipulcation \n4 for Division \n5 for a sorted list of the numbers \nWARNING: Entering any other character will terminate the program\n"
.equ promptlen2,.-prompt_msg2

addmsg: .ascii "Sum is: "
.equ addlen,.-addmsg

submsg: .ascii "Difference is: "
.equ sublen,.-submsg 

mulmsg: .ascii "Product is: "
.equ mullen,.-mulmsg 

divmsg: .ascii "Quotient is: "
.equ divlen,.-divmsg 

endmsg: .ascii "Program has ended: Goodbye!\n"
.equ endlen,.-endmsg 

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
	# Write prompt_msg
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
	syscall #reads input

	cmpb $0xA, -128(%rbp)
	je .inputComplete #if user enters nothing, will jump to .inputComplete which will stop the user input

	call verify_float 
	cmpq $0, %rax
	jne .error_float #calls verify_float to check if the float parsed correctly. if not, jumps to .error_float

	leaq -128(%rbp), %rsi 
	call parse_float #calls parse_float instruction
	
	popq %rdi
	movss %xmm0, (%rdi) 
	addq $4, %rdi #stores the converted input value into float_array, rdi is a pointer which is incremented by 4
	addl $1, float_array_size
	
	cmpq $3, %r9 #check if user entered the max of 5 inputs. If so, jumps to .inputComplete. if not, repeats the loop.
	ja .inputComplete
	incq %r9
	jmp .loop 

.error_float:
	movl $1, %eax
	movl $1, %edi
	movl $error_string_len, %edx
	leaq error_string, %rsi
	syscall
	popq %rdi 
	jmp .loop #will display error_string, which occurs when the program is unable to parse the float.

.inputComplete:
	movl $1, %eax
	movl $1, %edi
	movq $replen, %rdx
	leaq repeatmsg, %rsi
	syscall #asks and prompts the user if they want to re-enter inputs. 
	
	movl $0, %eax
	movl $0, %edi
	movl $128, %edx
	leaq -128(%rbp), %rsi
	syscall 
	cmpb $0x31, -128(%rbp)
	je .start1 #If user enters "1", it will jump to .start1 to redo the inputs. Otherwise, will continue the program.

	movss (float_array), %xmm11
	movss (float_array+4), %xmm12
	movss (float_array+8), %xmm13
	movss (float_array+12), %xmm14
	movss (float_array+16), %xmm15 #All five user input values are stored in xmm11-15. If user entered less than 5, the corresponding register will have a "0" in the register.
	
.opchoice:
	
	movl $1, %eax
	movl $1, %edi
	movq $promptlen2, %rdx
	leaq prompt_msg2, %rsi
	syscall #program will ask what operations they want to choose
	
	movl $0, %eax
	movl $0, %edi
	movl $128, %edx
	leaq -128(%rbp), %rsi
	syscall  #user input, they can choose 1-5 for an operation
	
	cmpb $0x31, -128(%rbp)
	je .add #if user enters 1, jumps to .add

	cmpb $0x32, -128(%rbp)
	je .sub #if user enters 2, jumps to sub
	
	cmpb $0x33, -128(%rbp)
	je .mul #if user enters 3, jumps to mul
	
	cmpb $0x34, -128(%rbp)
	je .div #if user enters 4, jumps to div
	
	cmpb $0x35, -128(%rbp)
	je .sort #if user enters 5, jumps to sort
	
	jmp .terminate #if user did not enter 1,2,3,4,5, the program will jump to terminate
	
.add:
	movl $1, %eax
	movl $1, %edi
	movq $addlen, %rdx
	leaq addmsg, %rsi
	syscall 
	call addition 
	jmp .end #writes addmsg, calls addition, jumps to .end

.sub:
	movl $1, %eax
	movl $1, %edi
	movq $sublen, %rdx
	leaq submsg, %rsi
	syscall 
	call subtraction
	jmp .end #writes submsg, calls subtraction, jumps to .end

.mul:
	movl $1, %eax
	movl $1, %edi
	movq $mullen, %rdx
	leaq mulmsg, %rsi
	syscall 
	call multipulcation
	jmp .end #writes mulmsg, calls multipulcation, jumps to .end

.div:
	movl $1, %eax
	movl $1, %edi
	movq $divlen, %rdx
	leaq divmsg, %rsi
	syscall 
	call division
	jmp .end #writes divmsg, calls division, jumps to .end

.sort:
	leaq float_array, %rdi
	movq $0, %rax
	movl float_array_size, %eax
	addq $20, %rdi
	call sort #load address of float_array to %rdi, clears rax and moves the size of the array into eax, adds $20 into rdi for the maximum amount of values inputted, calls sort.

.end:
	call print_endl
	movl $1, %eax
	movl $1, %edi
	movq $rep2len, %rdx
	leaq rep2, %rsi
	syscall #asks the user if they want to repeat operation choices
	
	movl $0, %eax
	movl $0, %edi
	movl $128, %edx
	leaq -128(%rbp), %rsi
	syscall #reads user input
	
	cmpb $0x31, -128(%rbp)
	je .opchoice #if user enters 1, will repeat operation choices. otherwise, will continue to terminate.

.terminate:
	movl $1, %eax
	movl $1, %edi
	movq $endlen, %rdx
	leaq endmsg, %rsi
	syscall 
	movl $60, %eax
	syscall
