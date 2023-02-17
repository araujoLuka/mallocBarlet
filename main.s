.section .data
    inicioHeap: .quad 0
    topoHeap:   .quad 0
    topoBloco:  .quad 0
    tamBloco:   .quad 0
    a: .quad 0
    b: .quad 0
    c: .quad 0
    d: .quad 0
    e: .quad 0

.section .text
.globl _start

iniciaAlocador:
    pushq %rbp
    movq %rsp, %rbp
    
    movq $12, %rax
    movq $0, %rdi
    syscall
    
    movq %rax, inicioHeap
    movq %rax, topoHeap
    movq %rax, topoBloco
    movq $4096, tamBloco
    
    popq %rbp
    ret

finalizaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    movq inicioHeap, %rax
    movq %rax, %rdi
    movq $12, %rax
    syscall
    movq %rax, topoHeap
    movq %rax, topoBloco

    popq %rbp
    ret

alocaMem:
    pushq %rbp
    movq %rsp, %rbp

    movq inicioHeap, %rax
    movq topoHeap, %rbx
    cmpq %rax, %rbx
    je novoNodo                 # gera um novo nodo se a heap estiver vazia

    # busca um nodo com um bloco de tamanho menor ou igual a num_bytes
    buscaNodo:
    movq inicioHeap, %rax
    movq 16(%rbp), %rbx         # rbx <- num_bytes
    loopBusca:
    cmpq topoHeap, %rax
    jge novoNodo
    movq (%rax), %rdi
    cmpq $1, %rdi               # verifica se o bloco esta ocupado
    je proxNodo
    movq 8(%rax), %rdi
    cmpq %rbx, %rdi             # verifica se o tamanho do bloco eh maior ou igual que num_bytes
    jge verificaBloco
    proxNodo:
    addq 8(%rax), %rax
    addq $16, %rax
    jmp loopBusca

    # aloca um novo nodo e atualiza o topo da heap
    novoNodo:
    movq 16(%rbp), %rax         # rax <- num_bytes
    movq $0, %rbx               # rbx <- 0 (tamanho do bloco) 
    loopBloco:
    subq tamBloco, %rax
    addq tamBloco, %rbx
    cmpq $0, %rax
    jg loopBloco
    
    movq %rbx, %rax             # rax <- tamanho do bloco a alocar
    addq topoHeap, %rax         # rax <- novo topo da heap

    movq %rax, %rdi
    movq $12, %rax
    syscall

    movq %rax, %rdx             # rdx <- topo corrente da heap
    movq topoHeap, %rax         # rax <- recebe antigo topo da heap
    movq $1, (%rax)             # seta a flag de uso do bloco
    movq 16(%rbp), %rcx         # rcx <- num_bytes
    movq %rcx, 8(%rax)          # salva o tamanho do bloco
    movq %rdx, topoHeap         # atualiza o novo topo da heap
    
    jmp ajustaBloco

    verificaBloco:
    cmpq %rax, topoBloco
    jne alocaNodo
    movq 8(%rax), %rbx
    movq 16(%rbp), %rdi
    addq $16, topoBloco
    addq %rdi, topoBloco
    movq topoBloco, %rdx
    movq $2, (%rdx)
    subq %rdi, %rbx
    subq $16, %rbx
    movq %rbx, 8(%rdx)
    movq %rdx, topoBloco        # salva o endereco do topo do bloco

    # aloca o bloco em um nodo ja existente com o endereco em %rax
    alocaNodo:
    movq 16(%rbp), %rdx         # rdx <- num_bytes

    movq $1, (%rax)             # seta a flag de uso do bloco
    movq 8(%rax), %rdi
    movq %rdx, 8(%rax)
    addq $16, %rax              # rax <- endereco do inicio do bloco que sera retornado
    movq %rax, %rbx
    addq %rdx, %rbx
    movq $2, (%rbx)
    subq %rdx, %rdi
    subq $16, %rdi
    movq %rdi, 8(%rbx)
    jmp endAlocaMem

    ajustaBloco:
    addq $16, %rax              # rax <- endereco do inicio do bloco que sera retornado
    movq %rax, %rdx
    addq %rcx, %rdx
    movq $2, (%rdx)             # seta que o restante do bloco esta livre
    subq %rcx, %rbx
    subq $16, %rbx
    movq %rbx, 8(%rdx)          # salva o total de bytes restantes do bloco
    movq %rdx, topoBloco        # salva o endereco do topo do bloco
    jmp endAlocaMem

    # rax contem o endereco do bloco que sera retornado
    endAlocaMem:
    popq %rbp
    ret

liberaMem:
    pushq %rbp
    movq %rsp, %rbp

    movq 16(%rbp), %rax         # rax <- parametro *bloco (endereco do nodo)
    subq $16, %rax              # rax <- endereco da flag do nodo

    movq $0, (%rax)
    
	loopLibera:
		movq 8(%rax), %rbx
		addq $16, %rbx
		addq %rax, %rbx				# rbx <- endereco do prox nodo

		cmpq topoBloco, %rbx		# verifica se o endereco do prox nodo eh o topo do bloco
		je atualizaTopoBloco

		verificaFragmentacao:
			cmpq $1, (%rbx)
			jne desfragmenta
			jmp endLibera

		desfragmenta:
			movq 8(%rbx), %rdx			# rdx <- tamanho do prox nodo
			addq $16, %rdx				# soma 16 bytes gerenciais em rdx
			movq 8(%rax), %rcx			# rcx <- tamanho do nodo atual
			addq %rdx, %rcx				# rcx <- novo tamanho do nodo
			movq %rcx, 8(%rax)
			jmp loopLibera

		atualizaTopoBloco:
			movq topoBloco, %rbx
			movq 8(%rbx), %rbx
			addq $16, %rbx

			movq $2, (%rax)
			addq %rbx, 8(%rax)

			movq %rax, topoBloco
			jmp endLibera

    endLibera:
    popq %rbp
    ret

imprimeMapa:
    pushq %rbp
    movq %rsp, %rbp

    call printHeadder

    subq $8, %rsp               # abre espaco para variavel local
    movq inicioHeap, %rax       # rax <- inicioHeap
    movq %rax, 8(%rsp)          # inicia a variavel que caminha na heap com inicioHeap

    loopMapa:
		movq 8(%rsp), %rax
		cmpq topoHeap, %rax
		jge endLoop

		pushq 8(%rax)               # parametro 2: tam_bloco
		pushq (%rax)                # parametro 1: flag de uso do bloco
		call printNodo
		addq $16, %rsp              # libera espaco na pilha

		movq 8(%rsp), %rax
		movq 8(%rax), %rbx          # rbx <- tam_bloco
		addq $16, %rbx              # rbx <- rbx + 16 (espaco infos gerenciais)
		addq %rbx, %rax             # avanca para o proximo bloco
		movq %rax, 8(%rsp)
		jmp loopMapa

    endLoop:
    addq $8, %rsp
    call printFooter

    popq %rbp
    ret

_start:
    subq $16, %rsp              # abre espaco na pilha para as variaveis locais

    # a primeira variavel armazena o valor de retorno que sera usado ao fim do programa
    movq $0, 16(%rsp)           # 16(%rsp) = ret = 0
    
    # a segunda variavel vai ser usada para armazenar a segunda alocacao na heap
    movq $0, 8(%rsp)            # 8(%rsp) = y = NULL

    call iniciaAlocador
    call imprimeMapa

    # a = alocaMem(100)
    pushq $100
    call alocaMem
    addq $8, %rsp
    movq %rax, a                # a <- endereco do bloco

    call imprimeMapa

    # b = alocaMem(130)
    pushq $130
    call alocaMem
    addq $8, %rsp
    movq %rax, b                # b <- endereco do bloco

    call imprimeMapa

    # c = alocaMem(120)
    pushq $100
    call alocaMem
    addq $8, %rsp
    movq %rax, c                # c <- endereco do bloco

    call imprimeMapa

    # d = alocaMem(110)
    pushq $110
    call alocaMem
    addq $8, %rsp
    movq %rax, d                # d <- endereco do bloco

    call imprimeMapa


    # liberaMem(b)
    pushq b
    call liberaMem
    addq $8, %rsp

    call imprimeMapa

    # liberaMem(d)
    pushq d
    call liberaMem
    addq $8, %rsp

    call imprimeMapa


    # b = alocaMem(50)
    pushq $50
    call alocaMem
    addq $8, %rsp
    movq %rax, b                # b <- endereco do bloco

    call imprimeMapa

    # d = alocaMem(90)
    pushq $90
    call alocaMem
    addq $8, %rsp
    movq %rax, d                # d <- endereco do bloco

    call imprimeMapa

    # e = alocaMem(40)
    pushq $40
    call alocaMem
    addq $8, %rsp
    movq %rax, e                # e <- endereco do bloco

    call imprimeMapa

    # liberaMem(c)
    pushq c
    call liberaMem
    addq $8, %rsp

    call imprimeMapa

    # liberaMem(a)
    pushq a
    call liberaMem
    addq $8, %rsp

    call imprimeMapa

    # liberaMem(b)
    pushq b
    call liberaMem
    addq $8, %rsp

    call imprimeMapa

    # liberaMem(d)
    pushq d
    call liberaMem
    addq $8, %rsp

    call imprimeMapa

    # liberaMem(e)
    pushq e
    call liberaMem
    addq $8, %rsp

    call imprimeMapa


    movq $1, 16(%rsp)           # define codigo de retorno 0
    end:
    addq $16, %rsp	            # libera espaco das variaveis locais
    call finalizaAlocador

    movq 16(%rsp), %rdi	        # rdi <- endereco de retorno do programa
    movq $60, %rax
    syscall
