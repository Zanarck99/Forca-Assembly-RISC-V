.data
# global:
menu: .string "Bem vindo à forca\nPressione uma tecla\n"
.include ".\forca.txt"	# Coloca na memória todas as possíveis palavras do jogo; label: palavras

.include ".\macros.asm"

###############################################
#					 MAIN					  #
###############################################

.text
lui PALAVRA, 0x10000	# Endereço da palavra resposta
lui OCULTA, 0x10001	# Endereço da palavra oculta

# Escolha da palavra resposta:
# Temos na memória 101 palavras, então o computador vai escolher uma palavra aleatória pra jogo
li a7, RANDINT
li a1, 100	# gera um inteiro aleatório de 0 a 100
ecall

# Agora temos o índice da palavra escolhida, vamos agora buscar a palavra na memória pelo índice
# e também descobrir seu tamanho

# a0 já foi escolhido pelo sistema
la a1, palavras
mv a2, PALAVRA
jal searchInArray

# agora que temos a palavra resposta, vamos precisar saber o tamanho dela para podermos printar a oculta

mv a0, PALAVRA
jal lenStr	# retorna o tamanho da palavra em a0

# agora temos a quantidade de underlines da oculta, então vamos colocá-los na memória

# a quantidade a ser guardada está em a0
mv a1, OCULTA
jal guardaUnderlines

# Início da interface de jogo:
print("Bem vindo à forca\nPressione uma tecla\n")

li a7, READCHAR
ecall	# inicia o jogo; retorno despresado
li a7, SLEEP
li a0, 250
ecall	# pausa a execução do programa por 250 milissegundos
jal printQuebra
jal printOculta
jal printQuebra
li s0, 5	# quantidade inicial de vidas

# game loop:
tryAgain: jal readChar	# lê o primeiro chute | res em a0
	mv t0, a0
	jal printQuebra
	mv a0, t0
	jal strUpper
	beqz a0, tryAgain	# se a entrada for inválida ele solicita um novo input
	mv a1, OCULTA	# carrega o endereço do primeiro char da paravra oculta
	mv a2, PALAVRA	# carrega o endereço do primeiro char da resposta
	jal validaChute
	bnez a0, acertou	# caso o usuário não tenha acertado uma letra ele perde uma vida
		addi s0, s0, -1
		print("ERRADO! Vidas restantes: ")
		li a7, 1
		mv a0, s0
		ecall
		beqz s0, perdeu	# caso as vidas tenham chegado a 0 é game over
	acertou:
	jal printQuebra
	jal printOculta
	jal printQuebra
	mv a0, OCULTA
	jal verificaAcerto
	bnez a0, ganhou
	
	j tryAgain

ganhou:
jal printQuebra
print("Parabéns, você ganhou!!!")
j exit

perdeu:
jal printQuebra
print("Você perdeu... :(\nA palavra era ")
li a7, STRING
mv a0, PALAVRA
ecall

exit:
li a7, EXIT
ecall

.include ".\functions.asm"
