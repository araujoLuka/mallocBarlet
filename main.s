.section .data
	topoHeap:	.quad 0
	inicioHeap: .quad 0
    X:  .quad 0

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
    addq        -8(%rbp), %rax      # rax <- num_bytes
    addq        $16, %rax           # soma 16 bytes de infos gerenciais
    movq        %rax, %rdi
    movq        $12, %rax
    syscall
    
	movq		%rax, %rbx			# rbx <- topo corrente da heap
    movq        topoHeap, %rax      # rax <- recebe antigo topo da heap
    movq        $1, (%rax)			# seta a flag de uso do bloco
    movq        -8(%rbp), %rdx      # rdx <- num_bytes
    movq        %rdx, 8(%rax)		# salva o tamanho do bloco

    movq        %rax, topoHeap      # atualiza o novo topo da heap
    jmp         endAlocaMem

    endAlocaMem:
    movq        topoHeap, %rax      # rax <- topoHeap
    movq        -8(%rbp), %rbx      # rbx <- num_bytes
    subq        %rbx, %rax			# salva o endereço do inicio do bloco para retorno
    
    addq        $8, %rsp            # libera espaco da pilha

    popq        %rbp
    ret

_start:
	call		iniciaAlocador
    
	call		finalizaAlocador

	movq		$60, %rax
	movq		$0, %rdi
	syscall
