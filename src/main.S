#
# Main entry point for application
#

.text

.global _start

_start:
	movl $60, %eax
	syscall
