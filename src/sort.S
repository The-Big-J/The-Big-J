#
# sort.S
# Sorting!
#

.text

.global sort

#rdi pointer to array
#rax length of the array
sort:
	pushq %rbp
	movq %rsp, %rbp
	
	movq	%rax,	%r15	#holds number of f_numbers
	incq		%r15

bigLoop:		
	cmpq	$1,	%r15		#r15 will count down from nums of f_num to 1
	jbe		done			#then end
	movq	$0,		%r8		#start swapping from first element
	movq	$1,		%r9
	decq		%r15
smallLoop:
	cmpq	%r15,	%r8	#stop swapping here
	jae		bigLoop
	movss (%rdi, %r8, 4), %xmm0
	movss (%rdi, %r9, 4), %xmm1

	comiss %xmm0, %xmm1
	ja 		afterSwap		#if second number is bigger, don't swap
swap:
	movss %xmm1, (%rdi, %r8, 4)
	movss %xmm0, (%rdi, %r9, 4)
afterSwap:
	incq		%r8
	incq		%r9
	jmp		smallLoop


done:
	popq %rbp
	ret 
