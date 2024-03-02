.data

inMsg: .asciiz "Enter a number: "
msg: .asciiz "Calculating F(n) for n = "
fibNum: .asciiz "\nF(n) is: "
.text

main:

	li $v0, 4
	la $a0, inMsg
	syscall

	# take input from user
	li $v0, 5
	syscall
	addi $a0, $v0, 0
	
	jal print_and_run
	
	# exit
	li $v0, 10
	syscall

print_and_run:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	add $t0, $a0, $0 

	# print message
	li $v0, 4
	la $a0, msg
	syscall

	# take input and print to screen
	add $a0, $t0, $0
	li $v0, 1
	syscall

	jal fib

	addi $a1, $v0, 0
	li $v0, 4
	la $a0, fibNum
	syscall

	li $v0, 1
	addi $a0, $a1, 0
	syscall
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra

#################################################
#         DO NOT MODIFY ABOVE THIS LINE         #
#################################################	
	
fib:
    addi $t1, $zero, 0   # $t1 = 0
    beq $a0, $t1, fib_zero # if n == 0, jump fib_zero

    addi $t1, $zero, 1   # $t1 = 1
    beq $a0, $t1, fib_one # if n == 1, jump fib_one

    # For n > 1, recursive calculation
    addi $sp, $sp, -8    # Adjust stack 
    sw $ra, 4($sp)       # Save return address $ra
    sw $a0, 0($sp)       # Save current n

    # Calculate F(n-1)
    addi $a0, $a0, -1    #  n = n - 1
    jal fib              #  F(n-1)
    addi $sp, $sp, -4    # Adjust stack
    sw $v0, 0($sp)       # Save F(n-1) result

    lw $a0, 4($sp)       # Restore original n
    addi $a0, $a0, -2    # Decrement n by 2 for F(n-2)

    jal fib              # Recursive call for F(n-2)

    lw $t0, 0($sp)       # Load F(n-1) result into $t0
    add $v0, $v0, $t0    # F(n) = F(n-1) + F(n-2)

    addi $sp, $sp, 4     # Remove F(n-1) result from stack
    lw $ra, 4($sp)       # Restore return address $ra
    addi $sp, $sp, 8     # Adjust stack back

    jr $ra               # Return to caller

fib_zero:
    addi $v0, $zero, 0   # Return 0 for F(0)
    jr $ra               # Return

fib_one:
    addi $v0, $zero, 1   # Return 1 for F(1)
    jr $ra               # Return

    addi $v0, $zero, 1          # Return 1 for F(1)
    jr $ra             
