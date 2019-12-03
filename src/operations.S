#operations for the program so the user can add/subtract/etc
.text
.extern float_array


#4 functions for operations called in main.
addition:
movss (float_array), %xmm0
movss (float_array+4), %xmm1
movss %xmm0, %xmm2
addss %xmm1, %xmm0
call print_float

subtraction:
movss %xmm2, %xmm0 
subss %xmm1, %xmm0 
call print_float

division:
movss %xmm2, %xmm0
divss %xmm1, %xmm0
call print_float

multipulcation:
movss %xmm2, %xmm0
mulss %xmm1, %xmm0
call print_float
