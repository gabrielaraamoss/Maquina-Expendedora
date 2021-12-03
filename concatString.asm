 .data
 	#myVariableName:   .space 1024    # 1 kilobyte buffer 
 	string1:    .asciiz "He"  
  	string2:    .asciiz "llo"  
  	finalStr:   .space 256       # A 256 bytes buffer  
  	
.text  
	main:  
   		la $s1, finalStr  
   		la $s2, string1  
  		la $s3, string2 
  	
  		copyFirstString:  
  			lb $t0, ($s2)                  # get character at address  
   			beqz $t0, copySecondString
  			sb $t0, ($s1)                  # else store current character in the buffer  
  			addi $s2, $s2, 1               # string1 pointer points a position forward  
  			addi $s1, $s1, 1               # same for finalStr pointer  
  			j copyFirstString              # loop  
  		
  		copySecondString:  
  			lb $t0, ($s3)                  # get character at address  
   			beqz $t0, exit
  			sb $t0, ($s1)                  # else store current character in the buffer  
  			addi $s3, $s3, 1               # string1 pointer points a position forward  
  			addi $s1, $s1, 1               # same for finalStr pointer  
  			j copySecondString              # loop  
  		
  		exit:
  			lb $t0, ($s2)
  			li $v0, 4
  			la $a0, 0($t0)
  			syscall
  		
  		li $v0, 10
  		syscall
