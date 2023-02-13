.section .data
	topoHeap:	.quad 0
	inicioHeap: .quad 0
.section .text
.globl _start
iniciaAlocador:
	pushq		%rbp
	movq		$12, %rax
	movq		$0, %rdi
	syscall
	movq		%rax, topoHeap
	movq		topoHeap, inicioHeap
	popq		%rbp
	ret
_start:
	call		iniciaAlocador
	movq		$60, %rax
	movq		$0, %rdi
	syscall
