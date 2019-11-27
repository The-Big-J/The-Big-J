#
# Main entry point for application
#

.text

.global _start
.extern float_to_int

_start:
	movl $30291, %eax
	cvtsi2ss %eax, %xmm1
	sqrtss %xmm1, %xmm1
	call float_to_int
	
	movl $60, %eax
	syscall
