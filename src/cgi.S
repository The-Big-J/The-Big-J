#
# CGI shit
#
.equ O_CREAT,64
.equ O_RDWR,2
.data

cgi_file: .asciz "myform.cgi"
.equ cgi_file_len,.-cgi_file 

.text

.global cgi_do_stuff

cgi_do_stuff:
	movq %rsp, %rbp

	movl $2, %eax
	leaq cgi_file, %rdi
	movl $O_CREAT, %esi
	movl $2, %edx
	syscall
	movq %rax, -32(%rbp)

	movl $1, %eax
	movq -32(%rbp), %rdi
	leaq -32(%rbp), %rsi
	movl $31, %edx
	syscall

	movl $60, %eax
	syscall
