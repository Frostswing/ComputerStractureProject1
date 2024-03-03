# check if user provided string is palindrome

.data

userInput: .space 64
stringAsArray: .space 256

welcomeMsg: .asciiz "Enter a string: "
calcLengthMsg: .asciiz "Calculated length: "
newline: .asciiz "\n"
yes: .asciiz "The input is a palindrome!"
no: .asciiz "The input is not a palindrome!"
notEqualMsg: .asciiz "Outputs for loop and recursive versions are not equal"

.text

main:

	li $v0, 4
	la $a0, welcomeMsg
	syscall
	la $a0, userInput
	li $a1, 64
	li $v0, 8
	syscall

	li $v0, 4
	la $a0, userInput
	syscall
	
	# convert the string to array format
	la $a1, stringAsArray
	jal string_to_array
	
	addi $a0, $a1, 0
	
	# calculate string length
	jal get_length
	addi $a1, $v0, 0
	
	li $v0, 4
	la $a0, calcLengthMsg
	syscall
	
	li $v0, 1
	addi $a0, $a1, 0
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	addi $t0, $zero, 0
	addi $t1, $zero, 0
	la $a0, stringAsArray
	
	# Swap a0 and a1
	addi $t0, $a0, 0
	addi $a0, $a1, 0
	addi $a1, $t0, 0
	addi $t0, $zero, 0
	
	# Function call arguments are caller saved
	addi $sp, $sp, -8
	sw $a0, 4($sp)
	sw $a1, 0($sp)
	
	# check if palindrome with loop
	jal is_pali_loop
	
	# Restore function call arguments
	lw $a0, 4($sp)
	lw $a1, 0($sp)
	addi $sp, $sp, 8
	
	addi $s0, $v0, 0
	
	# check if palindrome with recursive calls
	jal is_pali_recursive
	bne $v0, $s0, not_equal
	
	beq $v0, 0, not_palindrome

	li $v0, 4
	la $a0, yes
	syscall
	j end_program

	not_palindrome:
		li $v0, 4
		la $a0, no
		syscall
		j end_program
	
	not_equal:
		li $v0, 4
		la $a0, notEqualMsg
		syscall
		
	end_program:
	li $v0, 10
	syscall
	
string_to_array:	
	add $t0, $a0, $zero
	add $t1, $a1, $zero
	addi $t2, $a0, 64

	
	to_arr_loop:
		lb $t4, ($t0)
		sw $t4, ($t1)
		
		addi $t0, $t0, 1
		addi $t1, $t1, 4
	
		bne $t0, $t2, to_arr_loop
		
	jr $ra


#################################################
#         DO NOT MODIFY ABOVE THIS LINE         #
#################################################
	
get_length:
	lb $t0, newline
	addi $sp, $sp, -4    # adjust stack 
	sw $ra, 0($sp)       # save the return address
	addi $t2, $zero, 0     # counter = 0
loop:
	lb $t1, 0($a0)       # load the byte at the current address
	beq $t1, $t0, done   # if the byte is a newline, we are done
	addi $a0, $a0, 4     # move to the next byte
	addi $t2, $t2, 1     # increment the counter
	j loop               # repeat the loop
done:
	addi $v0, $t2, 0    # calculate the length
	lw $ra, 0($sp)      # restore the return address
	addi $sp, $sp, 4    # restore the stack
	jr $ra
	


is_pali_loop:
    addi $sp, $sp, -8        # make space on stack for $ra
    sw $ra, 4($sp)           # save $ra on the stack
    sll $t0, $a0, 2          # convert length to byte offset ($a0 * 4)
    add $t0, $t0, $a1        # $t0 = address of the last character in the string
    addi $t0, $t0, -4        # adjust $t0 to point to the last character (not past it)
    add $t1, $a1, $zero      # $t1 = address of the first character
    li $v0, 1                # initially assume the string is a palindrome

loop_start:
    blt $t1, $t0, check_char # continue loop if start pointer < end pointer
    j loop_end               # if pointers have met or crossed, end loop

check_char:
    lw $t2, 0($t1)           # load word from start pointer
    lw $t3, 0($t0)           # load word from end pointer
    bne $t2, $t3, not_pali   # if words are not equal, it's not a palindrome
    addi $t1, $t1, 4         # increment start pointer by 4 bytes
    addi $t0, $t0, -4        # decrement end pointer by 4 bytes
    j loop_start             # jump back to the s the loop

not_pali:
    li $v0, 0                # set $v0 to 0 to indicate not a palindrome
    j loop_end               # skip to the end

loop_end:
    lw $ra, 4($sp)           # restore $ra from the stack
    addi $sp, $sp, 8         # clean up the stack
    jr $ra                   # return to caller



is_pali_recursive:
    addi $sp, $sp, -4        # make space on stack for $ra
	sw $ra, 0($sp)           # save the return address
	slti $t0, $a0, 2        # if length < 2, return true
    bnez $t0, is_pali_end_true # base case if length < 2 go to end_true

    sll $t2, $a0, 2          # convert length to byte offset ($a0 * 4)
	add $t2, $t2, $a1        # $t2 = address of the last character in the string
	addi $t2, $t2, -4        # adjust $t2 to point to the last character (not past it)
    lw $t1, 0($a1)           # load the first character
	lw $t2, 0($t2)           # load the last character
    bne $t2, $t1, is_pali_end_false # if first and last characters are not equal, go to end_false

    addi $a1, $a1, 4        # Increment base address
    addi $a0, $a0, -2       # Decrement length
    jal is_pali_recursive   # Recursive call
	lw $ra, 0($sp)          # Restore $ra from the stack
	addi $sp, $sp, 4        # Clean up the stack
    jr $ra                  # Return

is_pali_end_true:
    li $v0, 1               # Palindrome
    jr $ra

is_pali_end_false:
    li $v0, 0               # Not a palindrome
    jr $ra

