.section .data
	ocp: .string "+"
	lvr: .string "-"
	dta: .string "#"
	nln: .string "\n"
	msg: .string "Hello World\n"
.section .text
.globl _start

printChar:
	pushq %rbp
	movq %rsp, %rbp

	movq 24(%rbp), %rbx
	movq 16(%rbp), %rsi
	movq $1, %rdx
	
	movq $1, %rax
	movq $1, %rdi	# stdout
	while:
	cmpq $0, %rbx
	jle end_print
	syscall
	subq $1, %rbx
	jmp while

	end_print:
	popq %rbp
	ret

_start:
	movq $1, %rax
	movq $1, %rdi	# stdout
	movq $msg, %rsi
	movq $12, %rdx
	syscall

	pushq $1
	pushq $lvr
	call printChar
	addq $8, %rsp

	pushq $30
	pushq $dta
	call printChar
	addq $8, %rsp

	pushq $1
	pushq $ocp
	call printChar
	addq $8, %rsp

	pushq $50
	pushq $dta
	call printChar
	addq $8, %rsp

	pushq $1
	pushq $nln
	call printChar
	addq $8, %rsp

	movq $60, %rax
	movq $0, %rdi
	syscall
