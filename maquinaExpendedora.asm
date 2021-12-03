.data 
	textbox: .space 100
	zeroAsFloat: .float 0.0
	cienF: .float 100.0
	
	
	inicio: .asciiz "***************** MÁQUINA EXPENDEDORA *****************\n"	
	header: .asciiz "ID\t\tProducto\tPrecio\t\tStock\n" 
	
	
	intro_: .asciiz "============================================================"
	dinero_msg: .asciiz "Ingrese la monedas: \n" #Se validaran monedas solo multiplos de 5. Presiones s si ya no quiere ingresar mas monedas
	monedaNoValida: .asciiz "La moneda ingresada no es valida. Dinero devuelto.\n"
	salidaT: .asciiz "Gracias!\n"
	dinerodisp_msg: .asciiz "Su dinero: "
	id_msg: .asciiz "Ingrese ID: "
	idFail_msg: .asciiz "Producto no encontrado."
	agotado_msg: .asciiz "\tStock Bajo. Reportar al proveedor.\n"
	vuelto_msg: .asciiz "Su vuelto es:"
	vendido_msg: .asciiz "entregado! ¡Gracias por su compra! "
	saldoInsuf_msg: .asciiz "Dinero insuficiente.\nDinero devuelto: "
	
	
	salto: .asciiz "\n"
	tab: .asciiz "\t\t"
	space: .asciiz " "
	
	#------------
	prod1: .asciiz "cachito"
	prod2: .asciiz "pepitas"
	prod3: .asciiz "nachos"
	prod4: .asciiz "doritos"
	prod5: .asciiz "nachos"
	prod6: .asciiz "toditos"
	prod7: .asciiz "ruffles"
	prod8: .asciiz "takis"
	prod9: .asciiz "riskos"
	
			
	productos: .word prod1, prod2, prod3,prod4,prod5,prod6,prod7,prod8,prod9
	precios: .float 0.25, 1.50, 0.60, 0.75, 0.60, 1.75, 0.55, 1.20, 0.80 
	id: .word 10, 20, 30, 40, 50, 60, 70, 80, 90
	stock: .word 10, 10, 10, 1, 9, 10, 10, 10, 10
	
	monedas: .word 5, 10, 25, 50, 100
.text 

.globl main 
	lwc1 $f8, zeroAsFloat
	
	
	main:
		li $v0, 4
		la $a0, intro_
		syscall
	
		jal saltof
	
		jal showProducts			# Muestra productos disponibles.
		
		jal saltof
		
		jal ingreseMonedas		# Solicita monedas al usuario.
		beq $v0,$zero,main		# Retorna 0 cuando la moneda ingresada es invalida.
		
		move $t9, $v0 			# Guardando suma total de monedas.		
		
		jal saltof
		
		#Imprimr saldo disponible para la compra
		move $a0, $t9			# pasando argumento de dinero ingresado
		jal verificarWallet		#========= DINERO DISPONIBLE  $f2
		add.s $f2, $f12, $f1
		
	readIDAgain:	
		jal saltof
		
		jal ingresarID			
		move $t8, $v0			#========= INDEX PRODUCTO     $t8
		
		beq $t8,-1,readIDAgain		# index == -1? Solicita ID hasta que éste sea válido.
		
		move $a0, $t8
		jal verificarStock		# verifica el producto se está disponible.
		
		move $a0, $t8
		jal venderProducto		# verifica si el dinero es suficiente y completa el proceso de compra.
		
		jal saltof
			
		j main				# Vuelve a mostrar el menú de productos disponibles esperando a una nueva venta.
			
	exitF:	
		
		
		li $v0,10			# Finaliza el programa.
		syscall
		
		
		
	venderProducto:
		# Dado el index del producto y el dinero disponible
		# Se verifica si el dinero alcanza para comprar
		# Se retorna mensanje de vendido!
		#Se actualiza el array de stock en ese producto
		
		#  $f2 -> dinero disponible
		#  $t8  -> Index del producto 
		#  $f3 -> precio retornado
		
		#reservar memoria
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		

		#Obtener precio del producto
		lwc1 $f3, precios($a0)
		
		#Verifica si alcanza el dinero
		c.eq.s $f2, $f3
		bc1t vender
		c.lt.s $f2, $f3 # dinero < precio?
		bc1t noAlcanza
		# Caso contrario - > Vuelto -> Resta valor de Wallet
		
		jal saltof
		
		li $v0, 4
		la $a0, vuelto_msg
		syscall
		
		sub.s $f12, $f2, $f3	# dinero - precio
		jal printF	
			
		jal saltof
		
		vender:
			
			#Restar en Stock
			lw $t1,stock($t8)
			addi $t1, $t1, -1  
			
			sw $t1,stock($t8)		#actualizar valor de stock.
			
			#Imprimir mensaje del producto vendido
			lw $t2, productos($t8)
			li $v0, 4
			move $a0, $t2
			syscall
			
			li $v0, 4
			la $a0, space
			syscall
			
			li $v0, 4
			la $a0, vendido_msg
			syscall
			
			jal saltof
			
			j exit3
			
		noAlcanza:
			li $v0, 4
			la $a0, saldoInsuf_msg
			syscall
			
			li $v0, 2
			add.s $f12, $f2, $f8
			syscall
		
		exit3:
			#liberacion de memoria
			lw $ra,0($sp)
			addi $sp, $sp, 4
		
			jr $ra
		
	
	verificarWallet:
	
		#Imprimir disponi
		li $v0, 4
		la $a0, dinerodisp_msg	
		syscall
	
		#reservar memoria
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		mtc1.d $t9, $f12
		cvt.s.w $f12, $f12
		
		
		lwc1 $f13, cienF
		div.s $f12, $f12, $f13
		jal printF
				
		#liberacion de memoria
		lw $ra,0($sp)
		addi $sp, $sp, 4
		
		jr $ra
		
	
	verificarStock:
	
		#Revisar si hay stock disponible para vender
		#Si	stock < 2	Reporta escasez y Retorna 0
		#Si 	stock > 2	Retorna 1
		#Si	stock == 0 	Retorna -1. Los productos con valor cero no se mostrarán, sin embargo puede existir el ID en el registro y el usuario puede coincidir en ingresarlo.
		
		li $t0, 3		#Stock minimo sin error
		li $t4, 1
		
		#reservar memoria
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		#revisar stock
		lw $t1, stock($a0)		#obtener stock del producto con index $a0
		
		slt $t2, $t1, $t0			# stock < 2 ? -> V => t2 = 1
		beq $t1, $zero, exit1	
		beq $t2, $zero, noAlert	
		li $v0, 4
		la $a0, agotado_msg		# Emitir mensaje de agotamiento de stock
		syscall
		li $v0, 0			# 0 Producto agotado
		j exit2	
		
		noAlert:
			li $v0, 1		# 1 Producto suficiente
			j exit2
		
		exit1:
			li $v0, -1		#-1 Producto no disponible
			
		exit2:
			#liberacion de memoria
			lw $ra,0($sp)
			addi $sp, $sp, 4
		
			jr $ra


	ingresarID:
		
		#Retorna posicion en la que se encuantra el ID.
		
		#reservar memoria
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		#Imprimir mensaje de solicitud
		li $v0, 4
		la $a0, id_msg
		syscall
		
		
		#input ID
		li $v0, 5
		syscall
		move $t0, $v0
		
		
		#Recorrer array de IDs		
		li $t1, 0
		li $t2, 32	

		sigueBuscando:
			li $v0, 1
			lw $a0, id($t1)
			
			beq $t0, $a0, encontrado		# Si son iguales ve a encontrado! 	
			addi $t1, $t1, 4			# Next element, i.e., increment offset by 4.
			ble $t1, $t2, sigueBuscando
	
			li $v0, 4
			la $a0, idFail_msg		#Imprimir mensaje de error
			syscall
			
			jal saltof
			
			li $v0, -1			#Si no lo encuentra vo = -1
			j exit0
			
		encontrado:
	
			move $v0, $t1
			
		exit0:
			#liberacion de memoria
			lw $ra,0($sp)
			addi $sp, $sp, 4
		
			jr $ra
	
	ingreseMonedas:
		
		#Ingreso y validacion de monedas
		#Recibe una moneda a la vez y se considerará válida si la moneda ingresa se encuentra en el array de moneda
		
		#reservar memoria
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		li $t0, -1	#modulo
		li $t1, 5
		li $t3, 0
		li $t4, 0 	#suma
		
		
		#Mostrar mensaje para solicitar dinero
		li $v0, 4
		la $a0, dinero_msg
		syscall
		
		
		#Input para solicitar valor
		continuaIngresando:
			add $t4, $t4, $t3
			
			li $v0,5					#solicitando input MONEDA 
			syscall
			move $t3, $v0
				
			
			#Recorrer array de mondas para hacer validación.
			
			li $t1, 0
			li $t2, 20
			
		
			loopMonedas:
				lw $a0, monedas($t1)
				
				beq $t3, $a0, continuaIngresando	
				beq $t3, $zero, exit
				addi $t1, $t1, 4
				ble $t1, $t2, loopMonedas
				bgt $t1, $t2, noValido
				j continuaIngresando



			noValido:
				li $v0, 4				
				la $a0, monedaNoValida			# imprime mansaje de error
				syscall
				
				li $t4, 0
				
		
		exit:	
			# retornar valor
			move $v0, $t4
		
		#liberacion de memoria
		lw $ra,0($sp)
		addi $sp, $sp, 4
		
		jr $ra
		
	
	
	showProducts:
	
		li $v0, 4
		la $a0, inicio
		syscall
			
		li $v0, 4
		la $a0, header
		syscall
		
		#reservar memoria
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		
		li $t1, 0
		li $t2, 32	
			
		# Recorrer arrays de productos disponibles
		loop:
			
			lw $t5, stock($t1)
			
			beq $t5, $zero,siguienteP	# stock == 0 ?
			
			li $v0, 1
			lw $a0, id($t1)
			syscall
			
			jal tabf
			
			li $v0, 4
			lw $a0, productos($t1)
			syscall
			
			jal tabf

			li $v0, 2
			l.s $f12, precios($t1)
			syscall
			
			jal tabf
			
			li $v0, 1
			move $a0, $t5
			syscall
			
			jal saltof
			
		siguienteP:		
			addi $t1, $t1, 4	# Next element, i.e., increment offset by 4.

			# Done or loop once more?
			ble $t1, $t2, loop
	
		#Liberar memoria
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
		
		
	tabf:
		#reservar memoria
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		li $v0, 4
		la $a0, tab
		syscall
		
		#liberacion de memoria
		lw $ra,0($sp)
		addi $sp, $sp, 4
		
		jr $ra
	

	printZ:
	
		#reservar memoria
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		
		li $v0, 1
		syscall
		
		
		#liberacion de memoria
		lw $ra,0($sp)
		addi $sp, $sp, 4
		
		jr $ra
	
	
	printF:
	
		#reservar memoria
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		
		li $v0, 2
		syscall
		
		
		#liberacion de memoria
		lw $ra,0($sp)
		addi $sp, $sp, 4
		
		jr $ra
	
		
	saltof:
		#reservar memoria
		addi $sp, $sp, -4
		sw $ra, 0($sp)
	
		#cuerpo de funcion
		li $v0, 4
		la $a0, salto
		syscall
		
		#Liberar memoria
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra
