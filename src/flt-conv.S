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

# String constants
error_string: .ascii "Failed to parse float: Malformed float"
.equ error_string_len,.-error_string 

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
# rax holds the length of the string
# rsi pointer to the bro string
# Returns the number of leading zeroes in r11
string_to_int:
	pushq %rbp
	movq %rsp, %rbp
	
	# Register cleanup 
	xorq %r15, %r15
	xorq %r11, %r11 
	subq $1, %rax 
	
	# Check if the number is negative,
	# if so, do some fancy stuff
	cmpb $'-', 1(%rsi)
	jne .cont

	# If we are negative... 
	addq $1, %rsi
	subq $1, %rax
	movq $1, %r15 
	
	# Otherwise, setup the regst of everything 
.cont:
	addq %rax, %rsi
	movq %rax, %r10 # This will be used as a counter
	# Save rsi for later
	pushq %rsi
	# This is a simple loop that will
	# count the number of leading zeroes in a parsed
	# number 
	subq %rax, %rsi 
.zero_loop:
	# set if the stringy boi is zero 
	cmpb $'0', (%rsi)
	je .zero_found
	jmp .after_zero_loop 
.zero_found:
	# If there is a zero, increment both the counter and pointer
	incq %r11 
	incq %rsi 
	jmp .zero_loop 
.after_zero_loop: 
	# Restore rsi and clear some things out
	popq %rsi 
	xorl %eax, %eax
	xorl %ecx, %ecx

	# Setup the initial vals for the numloop
	movq $1, %r13 
	movb (%rsi), %al
	subb $0x30, %al
.numloop:
	# Decrement counter
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
	# Two's complement of rcx, if negative
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

# Verifies a string is a valid floating point number
# String in rsi, length in rax
# Return 1 for BAD and 0 for OK
verify_float:
	pushq %rbp
	movq %rsp, %rbp 
	# Flag for a decimal point at rbp-16
	movb $0, -16(%rbp)
	# LOOP
.verify_loop:
	cmpb $0xA, (%rsi)
	je .done79 
	cmpb $'.', (%rsi)
	jne .cont1 
	cmpb $1, -16(%rbp)
	je .error_verify_float
	movb $1, -16(%rbp) 
.cont1: 
	cmpb $':', (%rsi)
	jae .error_verify_float
	cmpb $'/', (%rsi)
	jbe .error_verify_float 
.verify_loop_tail:
	incq %rsi 
	decq %rax
	jz .done69
	jmp .verify_loop
.done79:
	movl $0, %eax 
.error_verify_float:
	movl $1, %eax 
.done69:
	popq %rbp 
	ret


# Returns length of string pointed to by rsi in rax
# You can specify two delimiters to search for. 
# One is in bh, and the other is in bl
# The delimiter that was hit will be stored in dl
strlen: 
	pushq %rbp
	movq %rsp, %rbp

	pushq %rsi # Saves rsi
	xorq %rax, %rax 
.strlen_loop:
	cmpb %bl, (%rsi)
	movb %bl, %dl 
	je .strlen_done 
	cmpb %bh, (%rsi)
	movb %bh, %dl 
	je .strlen_done 
	incq %rax
	incq %rsi 
	jmp .strlen_loop 
.strlen_done:
	popq %rsi 
	popq %rbp
	ret 

# Parses a float from a string
# rsi has the string
# rax is the length of the string
parse_float:
	pushq %rbp
	movq %rsp, %rbp

	# Save rsi in rdi 
	movq %rsi, %rdi 

	# Use our strlen function to search for either a decimal point 
	# or a newline
	movb $'.', %bl
	movb $0xA, %bh
	call strlen 

	# dl has the delimiter that was hit, so compare and see if we have
	# another string to parse
	cmpb $0xA, %dl 
	je .end_float_parse

	# Save the old strlen
	pushq %rax 

	# Strlen again, but of rsi + rax + 1
	addq %rax, %rsi
	addq $1, %rsi
	movq %rsi, -256(%rbp) 
	call strlen 

	# Quick swap of first and last strlens
	popq %rbx 
	pushq %rax 
	movq %rbx, %rax 

	# Check that dl is a newline and not something else
	cmpb $0xA, %dl
	je .end_float_parse 

	# Print out an error string
	leaq error_string, %rsi
	movl $error_string_len, %edx
	movl $1, %eax
	movl $1, %edi
	syscall
	jmp .parse_float_end 

.end_float_parse:

	# Convert the first number to an integer
	movq %rdi, %rsi
	decq %rsi
	incq %rax 
	call string_to_int

	# Convert the parsed integer to a float
	cmpq $0, %rax
	jge .continue_float_parse
	movb $1, -199(%rbp)
	jmp .boi
.continue_float_parse:
	movb $0, -199(%rbp)
.boi: 
	cvtsi2ss %eax, %xmm0 

	# Convert the second number to an integer
	popq %rax 
	pushq %rax # Pop and restore rax because we need it
	movq -256(%rbp), %rsi
	decq %rsi 
	incq %rax 
	call string_to_int 

	# Now, the number of leading zeroes will be in r11
	movq %rax, %rbx 
	popq %rax
	addq %r11, %rax
	# r11 + rax = the number of decimals we have
	movl $10, %ecx 
	cvtsi2ss %ecx, %xmm1 # xmm1 = number of decimals
	
	# rbp-199 has a flag if we're negative
	cmpb $1, -199(%rbp)
	jne .continue1
	negq %rbx 
.continue1: 
	cvtsi2ss %ebx, %xmm2 # xmm2 = the number
	movss %xmm1, %xmm4 	
	# Multiply 10 by the number of decimals 
	cmpl $1, %eax
	je .end_pow_loop
	decl %eax
.pow_loop:
	mulss %xmm1, %xmm4
	decl %eax 
	cmpl $0, %eax
	ja .pow_loop
	
.end_pow_loop:
	# Divide the result by the number of decimal places
	divss %xmm4, %xmm2 # xmm2 = xmm2 / xmm1

	# Add the two numbers together to get the float
	addss %xmm2, %xmm0 

.parse_float_end: 
	popq %rbp
	ret 
