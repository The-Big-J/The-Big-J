#operations for the program so the user can add/subtract/etc
.text

.global addition
.global subtraction
.global division
.global multipulcation 


#4 functions for operations called in main.
addition:
	pushq %rbp
	movq %rsp, %rbp 
	movss %xmm11, %xmm1
	movss %xmm12, %xmm0 #moves first two values into xmm1 and xmm0
	movss %xmm1, %xmm2
	addss %xmm0, %xmm1 #does addition operation of xmm0 and xmm1 and stores in xmm1
	call print_float #calls print_float which will print the value in xmm1
	popq %rbp
	ret #returns to the line after it was called

subtraction:
	pushq %rbp
	movq %rsp, %rbp 
	movss %xmm11, %xmm1
	movss %xmm12, %xmm0
	movss %xmm1, %xmm2
	subss %xmm0, %xmm1 #does subtraction operation of xmm0 and xmm1 and stores in xmm1
	call print_float
	popq %rbp
	ret

division:
	pushq %rbp
	movq %rsp, %rbp 
	movss %xmm11, %xmm1
	movss %xmm12, %xmm0
	movss %xmm1, %xmm2
	divss %xmm0, %xmm1  #does division operation of xmm0 and xmm1 and stores in xmm1
	call print_float
	popq %rbp
	ret

multipulcation:
	pushq %rbp
	movq %rsp, %rbp 
	movss %xmm11, %xmm1
	movss %xmm12, %xmm0
	movss %xmm1, %xmm2
	mulss %xmm0, %xmm1  #does multipulcation operation of xmm0 and xmm1 and stores in xmm1
	call print_float
	popq %rbp
	ret
