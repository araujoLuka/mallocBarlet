.section .data
	topoHeap:	.quad 0
	inicioHeap: .quad 0
    x:  .quad 0

.section .text
.globl _start

iniciaAlocador:
	pushq		%rbp
    movq        %rsp, %rbp
	
    movq		$12, %rax
	movq		$0, %rdi
	syscall
	
    movq		%rax, topoHeap
	movq		%rax, inicioHeap
	
    popq		%rbp
	ret

finalizaAlocador:
	pushq		%rbp
	movq		%rsp, %rbp

	movq		inicioHeap, %rax
	movq		%rax, %rdi
	movq		$12, %rax
	syscall

	popq		%rbp
	ret

alocaMem:
    pushq       %rbp
    movq        %rsp, %rbp

	subq		$8, %rsp
	movq		16(%rbp), %rax
	movq		%rax, -8(%rbp)		# salva num_bytes em uma variavel local

	movq		topoHeap, %rax
    movq        inicioHeap, %rbx
    cmpq        %rax, %rbx
    je          novoNodo

	addq		$8, %rsp
	movq		$0, %rax
	popq		%rbp
	ret								# retorna null se heap nao estiver vazia

    novoNodo:
    movq        -8(%rbp), %rax      # rax <- num_bytes
    addq        $16, %rax           # soma 16 bytes de infos gerenciais
	addq		topoHeap, %rax		# rax <- novo topo da heap
    movq        %rax, %rdi
    movq        $12, %rax
    syscall
    
	movq		%rax, %rbx			# rbx <- topo corrente da heap
    movq        topoHeap, %rax      # rax <- recebe antigo topo da heap
    movq        $1, (%rax)			# seta a flag de uso do bloco
    movq        -8(%rbp), %rdx      # rdx <- num_bytes
    movq        %rdx, 8(%rax)		# salva o tamanho do bloco

    movq        %rbx, topoHeap      # atualiza o novo topo da heap
    jmp         endAlocaMem

    endAlocaMem:
    movq        topoHeap, %rax      # rax <- topoHeap
    movq        -8(%rbp), %rbx      # rbx <- num_bytes
    subq        %rbx, %rax			# salva o endereço do inicio do bloco para retorno
    
    addq        $8, %rsp            # libera espaco da pilha

    popq        %rbp
    ret

liberaMem:
	pushq		%rbp
	movq		%rsp, %rbp

	movq		%rax, 16(%rbp)		# rax <- parametro *bloco (endereco do bloco)
	subq		$16, %rax			# rax <- endereco da flag do bloco

	movq		$0, (%rax)

	popq		%rbp
	ret

imprimeMapa:
    pushq %rbp
    movq %rsp,%rbp
    
    popq %rbp
    ret

_start:
	subq        $8, %rsp			# abre espaco na pilha para variavel local y

	call		iniciaAlocador

	# x(global) = alocaMem(32)
	pushq		$32
	call		alocaMem
	addq		$8, %rsp

	cmpq		$0, %rax
	movq		$1, %rdi			# define codigo de retorno 1 em caso de erro de alocacao
	je			end					# salta para final do programa se alocaMem retornar zero

	movq		%rax, x				# x <- endereco do bloco

	call imprimeMapa

	# y(local) = alocaMem(50)
	pushq		$50
	call		alocaMem
	addq		$8, %rsp

	cmpq		$0, %rax
	movq		$1, %rdi			# define codigo de retorno 1 em caso de erro de alocacao
	je			end					# salta para final do programa se alocaMem retornar zero

	movq		%rax, -8(%rsp)		# y <- endereco do bloco

	call imprimeMapa

	# liberaMem(x)
	pushq		x
	call		liberaMem
    addq		$8, %rsp

	call imprimeMapa

	# x(global) = alocaMem(15)
	pushq		$15
	call		alocaMem
	addq		$8, %rsp

	cmpq		$0, %rax
	movq		$1, %rdi			# define codigo de retorno 1 em caso de erro de alocacao
	je			end					# salta para final do programa se alocaMem retornar zero

	movq		%rax, x				# x <- endereco do bloco

	movq		$0, %rdi

	end:
	addq		$8, %rsp			# libera espaco da variavel local
	call		finalizaAlocador

	movq		$60, %rax
	syscall
