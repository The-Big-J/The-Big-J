#
# Float to int and string conversions 
#
.text

# This is used to disable the external symbols in common.S
# We need the externs to be disabled in common.S because those symbols
# are actually declared in this source file. Other files can include
# common.S and it will declare externs for flt-conf.S so they dont need
# to explicitly do that
.equ FLT_CONV_S,1

.include "common.S"

.global int_to_string
.global string_to_int
.global int_to_float
.global float_to_int
.global print_float
.global print_char
.global read_char
.global parse_float 

# Converts the int in rax to a string and stores it in rsi
# This function will assume that at least 32 bytes of space are allocated for the buffer pointed
# to by rsi
int_to_string:
	pushq %rbp
	movq %rsp, %rbp
	# Clear rdx
	xorl %edx, %edx 
	# Move 10 to rbx 
	movq $10, %rbx
	movq %rsi, %rcx
	decq %rcx 
	xorq %r15, %r15 
	# Sign extend and check if negative
	cmpl $0, %eax
	jge .printloop
	# So it's negative...
	negq %rax
	movq $1, %r15 
.printloop:
	movq $10, %r14
	divq %r14 
	addb $0x30, %dl
	movb %dl, (%rcx)
	xorl %edx, %edx
	# If the quotient is zero, stop
	cmpl $0, %eax
	je .doprint
	decq %rcx
	jmp .printloop
.doprint:
	# Handle if negative
	cmpq $0, %r15
	je .finishprint
	decq %rcx 
	movb $'-', (%rcx)
.finishprint:
	popq %rbp
	ret 

# Converts the string in rsi to an integer and returns it in rax
# rax holds the count
# rsi pointer to the bro string
string_to_int:
	pushq %rbp
	movq %rsp, %rbp
.restart:
	xorq %r15, %r15
	subq $1, %rax 
	cmpb $'-', 1(%rsi)
	jne .cont
	addq $1, %rsi
	subq $1, %rax
	movq $1, %r15
.cont:
	addq %rax, %rsi
	movq %rax, %r10 # This will be used as a counter
	# Perform an xor to clear the regs
	xorl %eax, %eax
	xorl %ecx, %ecx
	movq $1, %r13 
	movb (%rsi), %al
	subb $0x30, %al
.numloop:
	decq %r10
	# Multiply the value in al by r13
	mulq %r13
	# Add it to rcx
	addl %eax, %ecx
	# If the counter is zero, we're done
	cmp $0, %r10
	je .done
	# Decrement counter & rsi
	#decq %r10
	decq %rsi
	# Do a multiplication of r13 * 10
	movq %r13, %rax
	movq $10, %r12
	mulq %r12
	movq %rax, %r13
	movl $0, %eax
	# Get the next char ready
	movb (%rsi), %al
	subb $0x30, %al
	jmp .numloop
.done:
	# Actually not done, just need to see if it was negative
	cmpq $1, %r15
	jne .reallydone
	# Two's complement of rcx
	negq %rcx
.reallydone:
	movq %rcx, %rax
	popq %rbp
	ret


# Converts the float to an integer. the non-fractional part of the integer is stored in rax, and the fractional part is stored in rbx
# RAX will be negative if the float is negative, but RBX will always be positive
# float will be in xmm1
float_to_int:
	# First step is to convert, with truncation, the float to eax 
	cvttss2si	%xmm1, %eax
	# Save non-truncated value in xmm1 to xmm3 
	movss		%xmm1, %xmm2 
	cvtsi2ss	%eax, %xmm1
	subss		%xmm2, %xmm1 
	movl 		$100000, %ecx
	cvtsi2ss	%ecx, %xmm2 
	mulss		%xmm2, %xmm1 
	cvtss2si	%xmm1, %ebx
	negl 		%ebx
	ret 

# Prints the int in rax to stdout
print_int:
	pushq %rbp
	movq %rsp, %rbp 
	leaq -32(%rbp), %rsi
	call int_to_string
	# Print
	movl $1, %eax
	movl $1, %edi
	movq %r10, %rdx
	syscall
	popq %rbp
	ret 

# Prompts a user with the prompt in rsi
# length of your prompt should be in rdx
# The buffer you want the user input to be put into
# should be in rdi
# You'll need at least 128 bytes of space for this string
prompt_user:
	pushq %rbp
	movq %rsp, %rbp

	# Print out the prompt string
	movl $1, %eax
	movl $1, %edi
	syscall

	# Read the input
	movl $0, %eax
	movl $0, %edi
	movq %rdi, %rsi 
	movl $128, %edx
	syscall 

	popq %rbp
	ret 

# Prints the char in al to STDOUT 
print_char:
	pushq %rbp
	movq %rsp, %rbp

	# Quick thing to print a single char
	movb %al, -1(%rbp)
	leaq -1(%rbp), %rsi
	movl $1, %edi
	movl $1, %eax
	movl $1, %edx
	syscall 

	popq %rbp
	ret 

# Reads a single char from stdin
# Note: This will read a large string
# and just return the first char in al 
read_char:
	pushq %rbp
	movq %rsp, %rbp

	# Read 32 chars into stack buffer
	leaq -32(%rbp), %rsi
	movl $0, %eax
	movl $0, %edi
	movl $32, %edx
	syscall

	movb -32(%rbp), %al 

	popq %rbp
	ret 

# Prints a floating point number to stdout
# Float will be in xmm1
print_float:
	pushq %rbp
	movq %rsp, %rbp

	# Convert the float 
	call float_to_int 
	# Save the fractional part
	# which is in EBX
	pushq %rbx

	# Print out the non-fractional part
	# (Already in EAX) 
	call print_int
	
	# Print out a single decimal point
	movb $'.', %al 
	call print_char 

	# Print out the fractional part, but
	# fist pop the fraction in RAX 
	popq %rax
	call print_int 

	popq %rbp 
	ret 

# Reads an integer from stdin
read_int:
	pushq %rbp
	movq %rsp, %rbp

	popq %rbp 
	ret 

# Reads a float from stdin
# returns it in xmm1
read_float:
	pushq %rbp
	movq %rsp, %rbp


	popq %rbp
	ret 

# Parses a float from a string
# rsi has the string
# rax is the length of the string
parse_float:
	pushq %rbp
	movq %rsp, %rbp

	pushq %rsi 
	movq $0, %r11 
.string_loop:
	cmpb $'.', (%rsi)
	je .parse_done 
	decq %rsi 
	incq %r11 

.parse_done:
	popq %r10 
	# Convert the first part to an integer
	movq %r11, %r12 
	subq %rax, %r12 
	movq %r11, %rax 
	pushq %r12 
	call string_to_int 
	popq %rbx 
	pushq %rax 
	addq %rbx, %rsi 
	call string_to_int 
	popq %rbx

	# Whole is in rbx
	# Fraction is in ebx
	cvtsi2ss %rbx, %xmm0 
	cvtsi2ss %rax, %xmm1
	
	#divss %xmm1, 10000
	popq %rbp
	ret 
