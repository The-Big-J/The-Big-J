#
# sort.S
# Sorting!
#

.text

.global sort

# bubble sort : O(n^2)	
	
	# [4.5, 2.3, 94.2, 43.3, 10.3]
	# r8 = 1
	# r9 = 1

#rdi pointer to array
#rax length of the array
sort:
	pushq %rbp
	movq %rsp, %rbp
	
	movq	%rax,	%r15	#holds number of f_numbers
	movq	%r15,	%r14
	decq		%r14				#holds number of f_numbers minus 1

#if there are 5 numbers, then big loop 5 times
	movq	$1,	%r8
BigLoop:		
	cmpq	%r15,	%r8
	jae		done
	movq	$1,		%r9
SmallLoop:
	cmpq	%r14,	%r9
	jae		BigLoop
	movss (%rdi, %r9, 4), %xmm0
	movss (%rdi, %r9, 4), %xmm1
	
	

	
done:
	popq %rbp
	ret 
