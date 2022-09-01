###############################################
#				    FUN��ES				   	  #
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

# l� um char do teclado
# return: a0 = char
readChar:
	print("Digite uma letra:\n")
	li a7, READCHAR
	ecall
	mv t0, a0
	delay(250)
	mv a0, t0
	ret

# coloca um char em mai�sculo
# argumento: a0 => char a ser formatado
# retorna 0 caso seja informado um char n�o alfab�tico
# caso contr�rio retorna o char em a0
strUpper:
	li t0, 'A'	# como estamos trabalhando com ascii, esses chars s�o n�meros na mem�ria
	blt a0, t0, noAlpha 	# (t1 < 'A') ? erro : pass
	li t0, 'Z'	
	bge a0, t0, entradaErrada	# (t1 > 'Z') ? erro ? return
	ret
	
	entradaErrada:
	li t0, 'a'
	blt a0, t0, noAlpha	# (t1 < 'a') ? erro : pass
	li t0, 'z'
	bgt a0, t0, noAlpha	# (t1 > 'z') ? erro ? return
	addi a0, a0, -32 # para converter de min�sculo para min�sculo basta pegar o c�digo ascii da letra e subtrair 32
	ret
	
	noAlpha:
	li a0, 0
	ret
	
# verifica se o usu�rio acertou uma letra da palavra
# Par�metros:
# 	- a0 = letra que foi chutada
#	- a1 = endere�o da palavra oculta
#	- a2 = endere�o da palavra resposta
# Retorna:
#	- A palavra oculta � modificada caso tenha acertado
# 	- Retorna um valor booleano em a0 se uma letra foi descoberta
validaChute:
	li t1, '_'
	li t3, '\0'
	li t4, 0	# bool t4 = false	# valor booleano que verifica se alguma letra foi descoberta
	loopVC:
	lb t0, (a1)	# coloca o char da oculta em t0
	lb t2, (a2)	# coloca o char da resposta em t2
	beq t0, t3, endVC	# sai do loop caso tenha verificado a palavra toda
		bne t0, t1, else	# Caso o char n�o esteja oculto, o pr�ximo ser� verificado
			bne a0, t2, else	# Verifica se o chute foi certo, caso n�o seja, verifica o pr�ximo char
				sb a0, (a1)	# caso o chute tenha sido correto, ser� substitu�do na palavra oculta
				li t4, 1	# bool t4 = true
	else:
	addi a1, a1, 1
	addi a2, a2, 1	# avan�a o endere�o do char da oculta e da resposta
	j loopVC

	endVC: 
	mv a0, t4	# coloca em a0 o valor booleano de acerto
	ret

# Verifica se o usu�rio acertou a palavra oculta
# par�metro: a0 => endere�o da palavra oculta
# retorna 1 se tiver aertado caso contr�rio retorna 0
verificaAcerto:
	li t0, '_'
	li t2, '\0'
	loopVA:	
		lb t1, (a0)
		beq t1, t0, errado	# se um '_' for encontrado significa que ainda existem letras ocultas
		beq t1, t2, certo	# se chegar ao final da string sem achar um '_' significa que n�o existem mais letras ocultas
		addi a0, a0, 1	# avan�a o ponteiro
		j loopVA
		
	errado:
		li a0, 0
		ret
	certo:
		li a0, 1
		ret

# Retorna a palavra que est� no �ndice especificado em um endere�o especificado
# Par�metros:
# 	- a0 => �ndice especificado
#	- a1 => endere�o do array de strings
#	- a2 => endere�o de destino
searchInArray:
	li t0, '\0'	# char de fim de string
	li t1, 0	# contador
	li t3, 0	# ponteiro do endere�o de destino
	
	loopSIA: beq t1, a0, achei	# caso tenha chegado no �ndice especificado, ele sai do loop
		addi a1, a1, 1	# avan�a o ponteiro
		lb t2, (a1)	# carraga um char
		bne t2, t0, pass	
			addi t1, t1, 1	# caso seja um char de fim de string ele avan�a o contador
		
		pass: j loopSIA
	
	achei:
		addi a1, a1, 1	# avan�a o ponteiro
		lb t1, (a1)
		sb t1, (a2)
		
		beq t1, t0, return
		addi a2, a2, 1	# avan�a o ponteiro do retorno
		j achei
		
	return: ret

# retorns lenght of a null-terminated string
# Arg:	a0 => string address
lenStr:
	li t0, '\0'
	li t1, 0	# count
	lb t2, (a0)	# carrega o primeiro char
	
	loopLS:	beq t2, t0, returnLS
		addi a0, a0, 1	# avan�a o ponteiro
		lb t2, (a0)	# carrega o char
		addi t1, t1, 1	# avan�a o contador
		j loopLS
	
	returnLS:
		mv a0, t1
		ret	# retorna o valor em a0

# Coloca na mem�ria a quantidade de '_' especificada
# Args:
#	- a0 => int nUnderlines
#	- a1 => endere�o de destino
guardaUnderlines:
	li t0, '_'
	loopGU: beqz a0, returnGU
		sb t0, (a1)
		addi a0, a0, -1	# retorna o contador
		addi a1, a1, 1	# avan�a o ponteiro
		j loopGU
	
	returnGU: ret
