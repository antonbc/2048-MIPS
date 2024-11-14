.macro do_syscall(%n) # Performs syscalls
    	li $v0, %n
    	syscall
.end_macro

.macro read_integer # reads input integer
    	do_syscall(5)                 
.end_macro

.macro read_string # reads input integer
    	do_syscall(8)                 
.end_macro

.macro print_integer(%label) # print an integer
    	move $a0, %label            
    	do_syscall(1)                 
.end_macro

.macro print_string(%label) # print a string
    	la $a0, %label
    	do_syscall(4)
.end_macro

.macro generate_random_number
    do_syscall(42)
.end_macro

.macro exit
   	    do_syscall(10)                
.end_macro

.macro set_all_registers_to_zero
    li $s0, 0
    li $s1, 0
    li $s2, 0
    li $s3, 0
    li $s4, 0
    li $s5, 0
    li $s6, 0
    li $s7, 0
    li $t8, 0
.end_macro

.macro set_all_temp_registers_to_zero
    li $t0, 0
    li $t1, 0
    li $t2, 0
    li $t3, 0
    li $t4, 0
    li $t5, 0
    li $t6, 0
    li $t7, 0
    li $t9, 0
.end_macro

.macro print_all_registers
    print_integer($s0)
    print_string(space)
    print_integer($s1)
    print_string(space)
    print_integer($s2)
    print_string(space)
    print_integer($s3)
    print_string(space)
    print_integer($s4)
    print_string(space)
    print_integer($s5)
    print_string(space)
    print_integer($s6)
    print_string(space)
    print_integer($s7)
    print_string(space)
    print_integer($t8)
    print_string(newline)
    print_string(newline)
.end_macro

.data
menu_msg:              .asciiz "Choose [1] or [2]: \n[1] New Game \n[2] Start from a State \n"
grid_line:             .asciiz "+---+---+---+\n"    
cell_left_border:      .asciiz "|"                  
cell_end_border:       .asciiz "|\n"              
space:                 .asciiz " "  
empty_cell:            .asciiz " "                
enter_move:            .asciiz "Enter a move (A, D, W, S): "
invalid_input_msg:     .asciiz "Invalid input. Try again.\n"
win_msg:               .asciiz "Congratulations! You have reached the 512 tile!\n"
lose_msg:              .asciiz "Game over..\n"
newline:               .asciiz "\n"

.text

main:
    jal get_game_choice
    beq $t0, 1, new_game
    beq $t0, 2, start_from_state
    exit

get_game_choice:
    print_string(menu_msg)
    read_integer
    move $t0, $v0
    jr $ra

new_game:
    set_all_registers_to_zero
    jal random_two_index   
    jal print_grid
    j game_loop

# Function to set the specified register based on the index in $a0 to the value in $t0
set_register_value:
    beq $a0, 0, set_s0_value
    beq $a0, 1, set_s1_value
    beq $a0, 2, set_s2_value
    beq $a0, 3, set_s3_value
    beq $a0, 4, set_s4_value
    beq $a0, 5, set_s5_value
    beq $a0, 6, set_s6_value
    beq $a0, 7, set_s7_value
    beq $a0, 8, set_t8_value
    jr $ra                     # Return if the index is out of bounds (should not happen)

set_s0_value:
    move $s0, $t0
    jr $ra
set_s1_value:
    move $s1, $t0
    jr $ra
set_s2_value:
    move $s2, $t0
    jr $ra
set_s3_value:
    move $s3, $t0
    jr $ra
set_s4_value:
    move $s4, $t0
    jr $ra
set_s5_value:
    move $s5, $t0
    jr $ra
set_s6_value:
    move $s6, $t0
    jr $ra
set_s7_value:
    move $s7, $t0
    jr $ra
set_t8_value:
    move $t8, $t0
    jr $ra

# Main function to initialize random indices and set registers
random_two_index:
    addi $sp, $sp, -4         # Adjust stack pointer to allocate space
    sw   $ra, 0($sp)          # Store $ra on the stack

    li   $t0, 2                 # Load the value 2 to store
    li   $a1, 9               # Upper bound for random index (0 to 8)
    generate_random_number    # Generate first random index
    move $t1, $a0             # Store the first random index in $t1
    print_integer($t1)        # Debug: print the value of t1
    print_string(newline)
    move $a0, $t1             # Move index $t1 to argument register $a0
    jal set_register_value    # Call set_register_value to place 2 at index t1
    jal generate_second_index # Jump to generate_second_index function

    lw   $ra, 0($sp)          # Load $ra back from the stack
    addi $sp, $sp, 4          # Restore stack pointer

    jr   $ra                  # Return to the caller

generate_second_index:
    addi $sp, $sp, -4         # Adjust stack pointer to allocate space
    sw   $ra, 0($sp)          # Store $ra on the stack

generate_second_loop:
    generate_random_number    # Generate second random index
    move $t2, $a0             # Store the second random index in $t2
    beq  $t2, $t1, generate_second_loop # If indices match, regenerate
    print_integer($t2)        # Debug: print the value of t2
    print_string(newline)
    move $a0, $t2             # Move index $t2 to argument register $a0
    jal set_register_value    # Call set_register_value to place 2 at index t2

    lw   $ra, 0($sp)          # Load $ra back from the stack
    addi $sp, $sp, 4          # Restore stack pointer

    jr   $ra                  # Return to the caller

print_grid:
    li   $t3, 0              # Initialize index to 0 (this will be our grid index)

print_row_loop:
    print_string(grid_line)   # Print grid border line for each row
    li   $t4, 0               # Reset column counter for each row

print_column_loop:
    print_string(cell_left_border)   # Print cell border

    # Determine which register to use based on the current index in $t3
    beq $t3, 0, print_s0
    beq $t3, 1, print_s1
    beq $t3, 2, print_s2
    beq $t3, 3, print_s3
    beq $t3, 4, print_s4
    beq $t3, 5, print_s5
    beq $t3, 6, print_s6
    beq $t3, 7, print_s7
    beq $t3, 8, print_t8

    j increment_cell

print_s0:
    move $t0, $s0
    j print_cell

print_s1:
    move $t0, $s1
    j print_cell

print_s2:
    move $t0, $s2
    j print_cell

print_s3:
    move $t0, $s3
    j print_cell

print_s4:
    move $t0, $s4
    j print_cell

print_s5:
    move $t0, $s5
    j print_cell

print_s6:
    move $t0, $s6
    j print_cell

print_s7:
    move $t0, $s7
    j print_cell

print_t8:
    move $t0, $t8
    j print_cell

print_cell:
    beq  $t0, 0, print_empty_cell
    blt  $t0, 10, print_cell_1_digit
    blt  $t0, 100, print_cell_2_digits
    blt  $t0, 1000, print_cell_3_digits

print_cell_1_digit:
    print_string(space)
    print_integer($t0)
    print_string(space)
    j increment_cell

print_cell_2_digits:
    print_string(space)
    print_integer($t0)
    j increment_cell

print_cell_3_digits:
    print_integer($t0)
    j increment_cell

print_empty_cell:
    print_string(space)
    print_string(empty_cell)
    print_string(space)
    j increment_cell

increment_cell:
    addi $t4, $t4, 1         # Increment column counter
    addi $t3, $t3, 1         # Increment grid index
    bne  $t4, 3, print_column_loop   # Move to next column if not finished with row
    print_string(cell_end_border)    # Print the right border of the row
    bne  $t3, 9, print_row_loop      # If not finished with all 9 cells, start next row
    print_string(grid_line)          # Print the final grid line after the last row
    jr $ra
start_from_state:
    li   $t4, 0                   # Initialize index to 0

start_input_loop:
    read_integer                   # Read integer from user
    move $t0, $v0                  # Move the read value to $t0

validate_input:
    # Check if $t0 is one of the valid values (0, 2, 4, 8, 16, 32, 64, 128, 256, 512)
    li $t5, 0                      # Set comparison value
    beq $t0, $t5, store_value      # If $t0 == 0, it's valid
    li $t5, 2
    beq $t0, $t5, store_value
    li $t5, 4
    beq $t0, $t5, store_value
    li $t5, 8
    beq $t0, $t5, store_value
    li $t5, 16
    beq $t0, $t5, store_value
    li $t5, 32
    beq $t0, $t5, store_value
    li $t5, 64
    beq $t0, $t5, store_value
    li $t5, 128
    beq $t0, $t5, store_value
    li $t5, 256
    beq $t0, $t5, store_value
    li $t5, 512
    beq $t0, $t5, store_value

    # If none of the valid values match, prompt for input again
    print_string(invalid_input_msg)  # Prompt for valid input
    j start_input_loop               # Restart input loop

store_value:
    # Store value in registers based on the index $t4
    beq $t4, 0, store_in_s0
    beq $t4, 1, store_in_s1
    beq $t4, 2, store_in_s2
    beq $t4, 3, store_in_s3
    beq $t4, 4, store_in_s4
    beq $t4, 5, store_in_s5
    beq $t4, 6, store_in_s6
    beq $t4, 7, store_in_s7
    beq $t4, 8, store_in_t8

increment_index:
    addi $t4, $t4, 1               # Move to the next index
    bne  $t4, 9, start_input_loop   # Repeat until all 9 positions are filled

    jal print_grid
    j game_loop

# Store value logic
store_in_s0:
    move $s0, $t0
    j increment_index
store_in_s1:
    move $s1, $t0
    j increment_index
store_in_s2:
    move $s2, $t0
    j increment_index
store_in_s3:
    move $s3, $t0
    j increment_index
store_in_s4:
    move $s4, $t0
    j increment_index
store_in_s5:
    move $s5, $t0
    j increment_index
store_in_s6:
    move $s6, $t0
    j increment_index
store_in_s7:
    move $s7, $t0
    j increment_index
store_in_t8:
    move $t8, $t0
    j increment_index


game_loop:
    print_string(enter_move)
    read_string
    j game_loop

end:
    exit