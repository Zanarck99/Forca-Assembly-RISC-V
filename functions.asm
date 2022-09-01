###############################################
#				    FUNÇÕES				   	  #
###############################################

# Print line break
# return: none
printQuebra:
	li a7, CHAR
	li a0, '\n'
	ecall
	ret

# Printa a palavra oculta
# return: none
printOculta:
	li a7, STRING
	mv a0, OCULTA
	ecall
	ret

# lê um char do teclado
# return: a0 = char
readChar:
	print("Digite uma letra:\n")
	li a7, READCHAR
	ecall
	mv t0, a0
	delay(250)
	mv a0, t0
	ret

# coloca um char em maiúsculo
# argumento: a0 => char a ser formatado
# retorna 0 caso seja informado um char não alfabético
# caso contrário retorna o char em a0
strUpper:
	li t0, 'A'	# como estamos trabalhando com ascii, esses chars são números na memória
	blt a0, t0, noAlpha 	# (t1 < 'A') ? erro : pass
	li t0, 'Z'	
	bge a0, t0, entradaErrada	# (t1 > 'Z') ? erro ? return
	ret
	
	entradaErrada:
	li t0, 'a'
	blt a0, t0, noAlpha	# (t1 < 'a') ? erro : pass
	li t0, 'z'
	bgt a0, t0, noAlpha	# (t1 > 'z') ? erro ? return
	addi a0, a0, -32 # para converter de minúsculo para minúsculo basta pegar o código ascii da letra e subtrair 32
	ret
	
	noAlpha:
	li a0, 0
	ret
	
# verifica se o usuário acertou uma letra da palavra
# Parâmetros:
# 	- a0 = letra que foi chutada
#	- a1 = endereço da palavra oculta
#	- a2 = endereço da palavra resposta
# Retorna:
#	- A palavra oculta é modificada caso tenha acertado
# 	- Retorna um valor booleano em a0 se uma letra foi descoberta
validaChute:
	li t1, '_'
	li t3, '\0'
	li t4, 0	# bool t4 = false	# valor booleano que verifica se alguma letra foi descoberta
	loopVC:
	lb t0, (a1)	# coloca o char da oculta em t0
	lb t2, (a2)	# coloca o char da resposta em t2
	beq t0, t3, endVC	# sai do loop caso tenha verificado a palavra toda
		bne t0, t1, else	# Caso o char não esteja oculto, o próximo será verificado
			bne a0, t2, else	# Verifica se o chute foi certo, caso não seja, verifica o próximo char
				sb a0, (a1)	# caso o chute tenha sido correto, será substituído na palavra oculta
				li t4, 1	# bool t4 = true
	else:
	addi a1, a1, 1
	addi a2, a2, 1	# avança o endereço do char da oculta e da resposta
	j loopVC

	endVC: 
	mv a0, t4	# coloca em a0 o valor booleano de acerto
	ret

# Verifica se o usuário acertou a palavra oculta
# parâmetro: a0 => endereço da palavra oculta
# retorna 1 se tiver aertado caso contrário retorna 0
verificaAcerto:
	li t0, '_'
	li t2, '\0'
	loopVA:	
		lb t1, (a0)
		beq t1, t0, errado	# se um '_' for encontrado significa que ainda existem letras ocultas
		beq t1, t2, certo	# se chegar ao final da string sem achar um '_' significa que não existem mais letras ocultas
		addi a0, a0, 1	# avança o ponteiro
		j loopVA
		
	errado:
		li a0, 0
		ret
	certo:
		li a0, 1
		ret

# Retorna a palavra que está no índice especificado em um endereço especificado
# Parâmetros:
# 	- a0 => índice especificado
#	- a1 => endereço do array de strings
#	- a2 => endereço de destino
searchInArray:
	li t0, '\0'	# char de fim de string
	li t1, 0	# contador
	li t3, 0	# ponteiro do endereço de destino
	
	loopSIA: beq t1, a0, achei	# caso tenha chegado no índice especificado, ele sai do loop
		addi a1, a1, 1	# avança o ponteiro
		lb t2, (a1)	# carraga um char
		bne t2, t0, pass	
			addi t1, t1, 1	# caso seja um char de fim de string ele avança o contador
		
		pass: j loopSIA
	
	achei:
		addi a1, a1, 1	# avança o ponteiro
		lb t1, (a1)
		sb t1, (a2)
		
		beq t1, t0, return
		addi a2, a2, 1	# avança o ponteiro do retorno
		j achei
		
	return: ret

# retorns lenght of a null-terminated string
# Arg:	a0 => string address
lenStr:
	li t0, '\0'
	li t1, 0	# count
	lb t2, (a0)	# carrega o primeiro char
	
	loopLS:	beq t2, t0, returnLS
		addi a0, a0, 1	# avança o ponteiro
		lb t2, (a0)	# carrega o char
		addi t1, t1, 1	# avança o contador
		j loopLS
	
	returnLS:
		mv a0, t1
		ret	# retorna o valor em a0

# Coloca na memória a quantidade de '_' especificada
# Args:
#	- a0 => int nUnderlines
#	- a1 => endereço de destino
guardaUnderlines:
	li t0, '_'
	loopGU: beqz a0, returnGU
		sb t0, (a1)
		addi a0, a0, -1	# retorna o contador
		addi a1, a1, 1	# avança o ponteiro
		j loopGU
	
	returnGU: ret
