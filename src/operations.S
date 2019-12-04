#operations for the program so the user can add/subtract/etc
.text


#4 functions for operations called in main.
addition:
pushq %rbp
movq %rsp, %rbp 
movss %xmm11, %xmm1
movss %xmm12, %xmm0
movss %xmm1, %xmm2
addss %xmm0, %xmm1
call print_float
popq %rbp
ret

subtraction:
pushq %rbp
	movq %rsp, %rbp 
movss %xmm11, %xmm1
movss %xmm12, %xmm0
movss %xmm1, %xmm2
subss %xmm0, %xmm1
call print_float
popq %rbp
ret

division:
pushq %rbp
	movq %rsp, %rbp 
movss %xmm11, %xmm1
movss %xmm12, %xmm0
movss %xmm1, %xmm2
divss %xmm0, %xmm1
call print_float
popq %rbp
ret

multipulcation:
pushq %rbp
	movq %rsp, %rbp 
movss %xmm11, %xmm1
movss %xmm12, %xmm0
movss %xmm1, %xmm2
mulss %xmm0, %xmm1
call print_float
popq %rbp
ret
