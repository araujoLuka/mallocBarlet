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

	movq		topoHeap, %rax
    movq        inicioHeap, %rbx
    cmpq        %rax, %rbx
    je          novoNodo

    novoNodo:
    addq        16(%rbp), %rax      # rax <- num_bytes
    addq        $16, %rax           # soma 16 bytes de infos gerenciais
    movq        %rax, %rbx
    movq        $12, %rax
    movq        %rbx, %rdi
    syscall
    
    movq        topoHeap, %rbx      # rbx <- recebe antigo topo da heap
    addq        $16, %rbx
    movq        $1, -16(%rbx)       # seta a flag de uso do bloco
    movq        16(%rbp), %rdx      # rdx <- num_bytes
    movq        %rdx, -8(%rbx)      # salva o tamanho do bloco

    addq        $8, %rsp            # libera espaco da pilha
    movq        %rax, topoHeap      # atualiza o novo topo da heap

    jmp         endAlocaMem

    endAlocaMem:
    # salva o endereço do inicio do bloco em rax
    movq        topoHeap, %rax      # rax <- topoHeap
    movq        16(%rbp), %rbx      # rbx <- num_bytes
    subq        %rbx, %rax          # rax <- rax - rbx
    
    popq        %rbp
    ret

_start:
	call		iniciaAlocador
    
	call		finalizaAlocador

	movq		$60, %rax
	movq		$0, %rdi
	syscall
