.data

file: .asciiz "productos.txt"
coma: .asciiz ","
saltoLinea: .asciiz "\n"
mensajeBienvenida: .asciiz "Bienvenido!!\n" 
pregunta: .asciiz "¿Qué desea comprar?\n"
input: .asciiz "Ingrese el id del producto: "
ErrorELec: .asciiz "\nID incorrecto, ingrese ID válido:  "
buffer: .space 256
espacio: .asciiz ". "
espacioMin: .asciiz " "
productos: .space 108
id: .space 28
precio: .space 28
Stock: .space 28
numb_str: .space 4


.text
.globl atoi_function
#--------------------------------------------------------------------------
#--------------------Menú------------------------------------------
#--------------------------------------------------------------------------
main :	
	li $v0, 4 
	la $a0, mensajeBienvenida
	syscall
	li $v0, 4 
	la $a0, pregunta 
	syscall
	li $v0, 4
	la $a0, input 
	syscall

			
		  						    						     						     						
#--------------------------------------------------------------------------
#--------------------Leer archivo------------------------------------------
#--------------------------------------------------------------------------

lecturaArchivo:
	li $v0, 13
	la $a0, file
	li $a1, 0
	syscall
	move $s0, $v0


	li $v0, 14
	move $a0, $s0
	la $a1, buffer
	li $a2, 200
	syscall

	li $v0,16
	move $a0,$s0
	syscall


	la $a0, productos
	la $a1, id
	la $a2, buffer
	#la $a2,precio
	#la $a3,stock
	la $a3,numb_str
	jal leerBuffer

	li $v0,10
	syscall




leerBuffer:
	addi $sp,$sp,-16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	#sw $s4, 16($sp)
	
	move $s0,$a0
	move $s1,$a1
	move $s2,$a2
	move $s3,$a3
	#move $s4,a4

	
	la $t0, coma
	lb $s4, 0($t0) #t0 = comma
	la $t1, saltoLinea
	lb $s5, 0($t1) #t1 = \n
	li $s6, 0 #nLinea numero de linea			
     
whileNotNull:
	lb $t2, ($s2) #t2 = buffer[i]
	beq $t2, 0, endFunc
	mul $t5, $s6, 12 #t5 tiene el byte donde empieza en el arreglo nombres
		
	whileNotComma:  lb $t2, ($s2) #t2 = buffer[i]
			beq $t2, $s4, isComma
			add $t6, $t5, $s0
			sb $t2, 0($t6)
			addi $s2, $s2, 1
			addi $t5, $t5, 1
			j whileNotComma
			 
	isComma:	addi $s2, $s2, 1
			
			sw $0, 0($s3) #enceramos el numb_str
			li $t6, 0 #k
			whileNotNewLine: lb $t2, ($s2)
					beq $t2, $s5, newLine
					add $t7, $t6, $s3
					sb $t2, ($t7)
					addi $t6, $t6, 1
					addi $s2, $s2, 1
					j whileNotNewLine
						
			newLine: 	move $a0, $s3
					jal atoi
					sll $t5, $s6, 2 #4*nLinea
					add $t5, $t5, $s1 #notas[nLinea]
					sw $v0, 0($t5)
					
					addi $s6, $s6, 1 #nLinea +=1
					addi $s2, $s2, 1 #i+=1
					j whileNotNull  
			
endFunc: sw $s0, 0($sp)
lw $s0, 0 ($sp)
lw $s1, 4 ($sp)
lw $s2, 8 ($sp)
lw $s3, 12 ($sp)
#lw $s4, 16 ($sp)   
addi $sp, $sp, 16	 

jr $ra




salir:
     li $v0, 10 
     syscall     
