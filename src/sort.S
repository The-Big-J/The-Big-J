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
	
	

	popq %rbp
	ret 
