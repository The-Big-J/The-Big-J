#
# Float to int and string conversions 
#
.text

.include "common.S"

.global int_to_string
.global string_to_int
.global int_to_float
.global float_to_int 

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
	mulps		%xmm2, %xmm1 
	cvttss2si	%xmm1, %ebx
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

# Prints a floating point number to stdout
# Float will be in xmm1
print_float:
	pushq %rbp
	movq %rsp, %rbp

	# Convert the float 
	call float_to_int 
	# Save the results
	pushq %rbx
	# Print out the non-fractional part
	call print_int
	# Print out the fractional part
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
