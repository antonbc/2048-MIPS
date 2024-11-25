.macro do_syscall(%n) # Performs syscalls
    li $v0, %n
    syscall
.end_macro

.macro read_integer # reads input integer
    do_syscall(5)                 
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

.macro set_all_save_registers_to_zero
    li $s0, 0
    li $s1, 0
    li $s2, 0
    li $s3, 0
    li $s4, 0
    li $s5, 0
    li $s6, 0
    li $s7, 0
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
    li $t0, 0
    li $t1, 0
    li $t2, 0
    li $t3, 0
    li $t4, 0
    li $t5, 0
    li $t6, 0
    li $t7, 0
    li $t8, 0
    li $t9, 0
.end_macro

.data
menu_msg:              .asciiz "Choose [1] or [2]: \n[1] New Game \n[2] Start from a State \n"
grid_line:             .asciiz "+---+---+---+\n"    
cell_left_border:      .asciiz "|"                 
cell_end_border:       .asciiz "|\n"              
cell_space:            .asciiz " "  
empty_cell:            .asciiz " "             
enter_move:            .asciiz "Enter a move (A, D, W, S): "
win_msg:               .asciiz "Congratulations! You have reached the 512 tile!\n"
lose_msg:              .asciiz "Game over..\n"
invalid_input:         .asciiz "Invalid input. Try again.\n"
newline:               .asciiz "\n"

n:                     .word 3 # Grid size (can be changed to any value)

.text
main:
    la   $a0, n                # Load address of n
    lw   $t0, 0($a0)           # Load grid size into $t0
    move $s3, $t0              # Store n in $s3 for later use

    # Calculate total grid memory size (n * n * 4 bytes for integers)
    mul  $t1, $t0, $t0         # n * n (number of cells)
    mul  $t1, $t1, 4           # n * n * 4 (bytes per cell)

    # Allocate space for the grid and the return address
    addi $t1, $t1, 4           # Add 4 bytes for the return address
    subu $sp, $sp, $t1         # Adjust stack pointer to create space
    move $s4, $sp              # Base address of the grid is now in $s4

    # Store the return address at the top of the allocated space
    sw   $ra, 0($s4)           # Save return address at the top of the allocated space

game_choice_loop:
    jal get_game_choice
    beq $s0, 1, new_game
    beq $s0, 2, start_from_state
    j game_choice_loop

get_game_choice:
    print_string(menu_msg)
    read_integer
    move $s0, $v0              # Store user input in $s0
    jr $ra

new_game:
    # Randomly place two 2s in the grid

    jal random_two_index     # Get two random indices in $s1, $s2
    jal store_random_value
    jal play_game

    exit

store_random_value:
    # Store value at calculated grid memory address
    li   $t2, 2              # Value to place in grid
    mul  $t0, $s1, 4          # $t0 = $s1 * 4 (byte offset)
    add  $t0, $s4, $t0        # $t0 = base address ($s4) + offset
    li   $t2, 2               # Load the value 2
    sw   $t2, 0($t0)          # Store 2 at the calculated address

    # Store 2 at the location indexed by $s2
    mul  $t1, $s2, 4          # $t1 = $s2 * 4 (byte offset)
    add  $t1, $s4, $t1        # $t1 = base address ($s4) + offset
    li   $t2, 2               # Load the value 2 again
    sw   $t2, 0($t1)          # Store 2 at the calculated address

    jal print_array
    jr   $ra  

print_array:
    li   $t1, 0              # Row counter (initialize to 0)
    li   $t2, 0              # Cell counter (initialize to 0)
    move $t0, $s4            # Base address of grid (stored in $s4)

print_row:
    # Print a row separator
    print_string(grid_line)

print_cell:
    # Check if cell counter equals n (end of row)
    beq  $t2, $s3, new_row
    print_string(cell_left_border)
    # Print cell value
    lw   $a0, 0($t0)         # Load cell value from grid
    beq  $a0, 0, print_empty_cell # If 0, print empty cell

    move $t3, $a0            # Store value in $t3 for further processing
    beq $t3, 0, print_empty_cell
    ble  $t3, 9, print_single_digit
    ble  $t3, 99, print_double_digit
    ble  $t3, 999, print_triple_digit
    j    increment_cell      # Skip to increment after printing

print_empty_cell:
    # Handle empty cell (value is 0)
    print_string(cell_space) # Add spacing for alignment
    print_string(empty_cell) # Print empty cell representation
    print_string(cell_space) # Add spacing for alignment
    j    increment_cell      # Continue to next cell

print_single_digit:
    # Print single-digit number with proper spacing
    print_string(cell_space) # Add leading space for alignment
    print_integer($t3)       # Print the single-digit number
    print_string(cell_space) # Add trailing space for alignment
    j    increment_cell

print_double_digit:
    # Print double-digit number with proper spacing
    print_string(cell_space) # Add leading space for alignment
    print_integer($t3)       # Print the double-digit number
    j    increment_cell

print_triple_digit:
    # Print triple-digit number directly without extra spacing
    print_integer($t3)       # Print the triple-digit number
    j    increment_cell

increment_cell:
    addi $t2, $t2, 1         # Increment cell counter
    addi $t0, $t0, 4         # Move to next cell (4 bytes per integer)
    j    print_cell

new_row:
    # Print row ending and reset cell counter
    print_string(cell_end_border)
    addi $t1, $t1, 1         # Increment row counter
    li   $t2, 0              # Reset cell counter
    bne  $t1, $s3, print_row # Continue to next row if not done

    # Print final row separator
    print_string(grid_line)
    jr $ra                    # Return from the function

random_two_index:
    # Generate two random unique indices within grid bounds
    mul  $t2, $s3, $s3       # Calculate total cells n*n
    print_string(newline)

generate_first_index:
    move   $a1, $t2
    generate_random_number    # Generate random number
    move $s1, $a0              # Store the first random index in $t5

generate_second_index:
    move   $a1, $t2
    generate_random_number
    move $s2, $a0              # Store the second random index in $t6
    bne  $s2, $s1, generate_two_index_end  # Ensure unique indices
    j    generate_second_index

generate_two_index_end:
    jr $ra

start_from_state:
    li   $t0, 0              # Cell counter (initialize to 0)
    move $t1, $s4            # Base address of the grid in $s4
    mul  $t2, $s3, $s3       # Calculate total cells (n * n)

input_loop:
    # Check if all inputs are collected
    beq  $t0, $t2, input_done

    # Read input integer
    read_integer
    move $t3, $v0            # Move the input value to $a0 for processing

validate_input:
    beq  $t3, 2, store_input
    beq  $t3, 4, store_input
    beq  $t3, 8, store_input
    beq  $t3, 16, store_input
    beq  $t3, 32, store_input
    beq  $t3, 64, store_input
    beq  $t3, 128, store_input
    beq  $t3, 256, store_input
    beq  $t3, 512, store_input

    # If input is invalid, discard and re-read
    j    input_loop

store_input:
    # Store the valid input in the grid memory
    sw   $t3, 0($t1)         # Store the value at the current memory address
    addi $t1, $t1, 4         # Move to the next memory address
    addi $t0, $t0, 1         # Increment cell counter
    j    input_loop          # Continue to the next cell

input_done:
    lw   $ra, 0($s4)         # Load return address
    jal print_array
    j play_game


play_game:
    