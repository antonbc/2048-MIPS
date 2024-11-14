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

.data
menu_msg:              .asciiz "Choose [1] or [2]: \n[1] New Game \n[2] Start from a State \n"
grid_line:             .asciiz "+---+---+---+\n"    
cell_left_border:      .asciiz "|"                 
cell_end_border:       .asciiz "|\n"             
space:                 .asciiz " "  
empty_cell:            .asciiz " "                
enter_move:            .asciiz "Enter a move (A, D, W, S): "
win_msg:               .asciiz "Congratulations! You have reached the 512 tile!\n"
lose_msg:              .asciiz "Game over..\n"
invalid_input:         .asciiz "Invalid input. Try again.\n"
enter_grid:            .asciiz "Enter a board configuration (9 numbers):\n"
newline:               .asciiz "\n"

grid_array:  .word 0, 0, 0, 0, 0, 0, 0, 0, 0   

.text

main:
    jal get_game_choice
    beq $s0, 1, new_game
    beq $s0, 2, start_from_state
    exit

get_game_choice:
    print_string(menu_msg)
    read_integer
    move $s0, $v0
    jr $ra

new_game:
    jal random_two_index    
    li   $t2, 2         
    
    # Store value at index $s1
    la   $t0, grid_array     # Load base address of the array
    mul  $t3, $s1, 4         # Calculate byte offset for $s1 (index * 4)
    add  $t0, $t0, $t3       # Add offset to base address
    sw   $t2, 0($t0)         # Store value 2 at grid_array[$s1]

    # Store value at index $s2
    la   $t0, grid_array     # Load base address of the array
    mul  $t3, $s2, 4         # Calculate byte offset for $s2 (index * 4)
    add  $t0, $t0, $t3       # Add offset to base address
    sw   $t2, 0($t0)         # Store value 2 at grid_array[$s2]

    # Print the modified array
    jal get_array
    jal  print_array

random_two_index:
    li   $a1, 9                # Upper bound for random index (0 to 8)
    generate_random_number   # Generate random number between 0 and 8
    move $s1, $a0              # Store the first random index in $t5
    print_integer($s1)
    print_string(newline)

    # Generate the second random index ensuring it's different from $t5
generate_second_index:
    li   $a1, 9                # Upper bound for random index (0 to 8)
    generate_random_number   # Generate random number
    move $s2, $a0              # Store the second random index in $t6
    beq  $s2, $s1, generate_second_index   # If indices match, regenerate
    print_integer($s2)
    print_string(newline)
    print_string(newline)
    jr $ra


get_array:
    la   $t0, grid_array     # Reset base address of grid_array
    li   $t1, 0              # Start at index 0 for printing
    jr $ra
 
print_array:
    bge  $t1, 9, initialize_grid       # If index >= 9, exit the program
    lw   $a0, 0($t0)        # Load the value from the array
    print_integer($a0)
    print_string(space)
    addi $t0, $t0, 4        # Move to the next word in the array
    addi $t1, $t1, 1        # Increment index
    j print_array           # Continue loop

initialize_grid:
    print_string(newline)
    print_string(newline)
    jal print_grid
    j end

#================= PRINT GRID ========================
print_grid:
    la   $t0, grid_array     # Load base address of the array
    li   $t1, 0              # Initialize index to 0

print_row_loop:
    print_string(grid_line)
    li   $t2, 0              # Column counter (reset for each row)

print_column_loop:
    # Print left cell border
    print_string(cell_left_border)
    lw   $a0, 0($t0)         # Load the value from grid_array
    beq $a0, 0, print_empty_cell
    blt $a0, 10, print_cell_1_digit
    blt $a0, 100, print_cell_2_digits
    blt $a0, 1000, print_cell_3_digits


print_cell_1_digit:
    move $t3, $a0  
    print_string(space)
    move $a0, $t3
    print_integer($a0)
    print_string(space)
    j increment_cell

print_cell_2_digits:
    move $t3, $a0  
    print_string(space)
    move $a0, $t3
    print_integer($a0)
    j increment_cell

print_cell_3_digits:
    print_integer($a0)
    j increment_cell

print_empty_cell:
    print_string(space)
    print_string(empty_cell)
    print_string(space)

increment_cell:
    addi $t0, $t0, 4         # Move to the next word in the array
    addi $t2, $t2, 1         # Increment column counter
    addi $t1, $t1, 1         # Increment index

    bne  $t2, 3, print_column_loop
    print_string(cell_end_border)
    bne  $t1, 9, print_row_loop
    print_string(grid_line)
    jr $ra
#========================================================


start_from_state:
    li   $t4, 0               # Initialize index to 0
    la   $t1, grid_array      # Load base address of grid_array

start_input_loop:
    read_integer              # Read integer from user
    move $t0, $v0             # Move the read value to $t0

    # Calculate offset and store value at grid_array[$t4]
    mul  $t3, $t4, 4          # Calculate byte offset for index $t4 (index * 4)
    add  $t2, $t1, $t3        # Calculate actual memory location
    sw   $t0, 0($t2)          # Store user input at grid_array[$t4]

    addi $t4, $t4, 1          # Move to the next index
    bne  $t4, 9, start_input_loop  # Repeat until all 9 positions are filled

    jal  print_grid_2           # Print the final grid state after input

print_grid_2:
    jal get_array
    jal print_array
    j end
   
swipe_up:
    
swipe_down:
swipe_left:
swipe_right:

end:
    exit