#
# Various utils
#

.include "common.S"

.text 

mode: .asciz "rw"

# Create a readable/writable file at the path specified by rsi
create_file:
	pushq %rbp
	movq %rsp, %rbp

	# Syscall for open
	movl $2, %eax 
	movq %rsi, %rdi
	leaq mode, %rsi 
	movq $O_CREAT, %rdx
	syscall

	# Immediately close the file descriptor
	movq %rax, %rdi 
	movq $3, %rax 
	syscall

	popq %rbp
	ret 

# Opens file in rax as read/write
open_file:
	pushq %rbp
	movq %rbp, %rsp

	# Syscall for open
	movl $2, %eax
	movq %rsi, %rdi
	leaq mode, %rsi
	movq $O_APPEND, %rdx
	syscall
	# Return is now in rax

	popq %rbp
	ret 

# Close the fd specified by rax
close_file:
	pushq %rbp
	movq %rbp,%rsp

	# Syscall for close
	movq %rax, %rdi
	movl $3, %eax
	syscall

	popq %rbp
	ret

