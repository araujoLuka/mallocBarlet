.section .data
	ocp: .string "+"
	lvr: .string "-"
	dta: .string "#"
    wll: .string "_"
	nln: .string "\n"
	msg: .string "* Mapa da Heap *\n\n"
	ini: .string "Inicio -> ["
	top: .string "] <- Topo\n"
.section .text
.globl printHeadder
.globl printNodo
.globl printFooter

# printStr(char *s, long int qtde)
printStr:
	pushq %rbp
	movq %rsp, %rbp

	movq 16(%rbp), %rsi	# rsi <- string a ser impressa
	movq 24(%rbp), %rdx	# rdx <- quantidade de caracteres
	movq $1, %rax		# codigo para syscall write
	movq $1, %rdi		# imprime em stdout
	syscall

	popq %rbp
	ret

# printChar(char *c, long int repet)
printChar:
	pushq %rbp
	movq %rsp, %rbp

	movq 16(%rbp), %rsi	# rsi <- char a ser impresso
	movq 24(%rbp), %rbx	# rbx <- repet (quantas vezes imprimir o char)
	movq $1, %rax		# codigo para syscall write
	movq $1, %rdi		# imprime em stdout
	movq $1, %rdx		# um caractere a imprimir

	while:
	cmpq $0, %rbx
	jle end_print
	syscall
	subq $1, %rbx
	jmp while

	end_print:
	popq %rbp
	ret

printHeadder:
	pushq %rbp
	movq %rsp, %rbp

	pushq $18
	pushq $msg
	call printStr
	addq $16, %rsp

	pushq $11
	pushq $ini
	call printStr
	addq $16, %rsp

	popq %rbp
	ret

printFooter:
	pushq %rbp
	movq %rsp, %rbp

	pushq $10
	pushq $top
	call printStr
	addq $16, %rsp

	pushq $150
	pushq $wll
	call printChar
	addq $16, %rsp

	pushq $2
	pushq $nln
	call printChar
	addq $16, %rsp

	popq %rbp
	ret

# printNodo(long int flag, long int tam_bloco)
printNodo:
	pushq %rbp
	movq %rsp, %rbp

	pushq $1
	movq 16(%rbp), %rax
	cmpq $0, %rax
	je pLivre
	pOcup:
		pushq $ocp
		jmp printCall
	pLivre:
		pushq $lvr
	
	printCall:
	call printChar
	addq $16, %rsp

	movq 24(%rbp), %rax
    sar %rax
	pushq %rax
	pushq $dta
	call printChar
	addq $16, %rsp

	popq %rbp
	ret
