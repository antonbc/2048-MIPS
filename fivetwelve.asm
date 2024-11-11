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
grid_line:             .asciiz "+---+---+---+\n"    # Horizontal border line
cell_left_border:      .asciiz "|"                 # Left border of each cell
cell_end_border:       .asciiz "|\n"             # Right border for each cell row end
space:                 .asciiz " "  
empty_cell:            .asciiz "   "                
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
    jal start_from_state
    exit

get_game_choice:
    print_string(menu_msg)
    read_integer
    move $s0, $v0
    jr $ra

new_game:
    jal random_two_index       # Call the random_two_index function

    li   $t2, 2            # Example: New value to store at index 3
    # Calculate the offset and store the value
    
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
    la   $t0, grid_array     # Reset base address of grid_array
    li   $t1, 0              # Start at index 0 for printing

print_loop:
    bge  $t1, 9, end       # If index >= 9, exit the program
    lw   $a0, 0($t0)        # Load the value from the array
    print_integer($a0)

    print_string(newline)

    addi $t0, $t0, 4        # Move to the next word in the array
    addi $t1, $t1, 1        # Increment index
    j print_loop            # Continue loop

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

end:
    exit
start_from_state:
    exit


#     # Place '2' in the cells at positions given by $t5 and $t6
#     li   $t2, 2                # Value to store (2)
#     la   $t3, grid_array       # Load base address of grid again
#     sll  $t5, $t5, 2           # Convert $t5 index to byte offset
#     sll  $t6, $t6, 2           # Convert $t6 index to byte offset
#     add  $t7, $t3, $t5         # Calculate address for first random index
#     sw   $t2, 0($t7)           # Store 2 at that position
#     add  $t7, $t3, $t6         # Calculate address for second random index
#     sw   $t2, 0($t7)           # Store 2 at that position

#     # Print the initialized grid with two '2's
#     jal print_grid

#     jr $ra

# print_grid:
#     li   $t3, 0                # Row counter

# print_rows:
#     print_string(grid_line)    # Print the top border of each row
#     li   $t4, 0                # Column counter

# print_columns:
#     print_string(cell_left_border)  # Print left border of the cell

#     # Calculate address of the cell in the grid
#     sll  $t5, $t3, 2           # Row offset (row index * 4 bytes)
#     mul  $t5, $t5, 3           # Move to the current row (0, 12, 24, etc.)
#     add  $t5, $t5, $t4         # Add column offset
#     sll  $t5, $t5, 2           # Multiply by 4 (word size)
#     la   $t0, grid_array       # Load base address of the grid
#     add  $t7, $t0, $t5         # Calculate address of the current cell
#     lw   $a0, 0($t7)           # Load cell value

#     # Print either '2' or empty space
#     bnez $a0, print_integer_cell
#     print_string(empty_cell)
#     j skip_print

# print_integer_cell:
#     print_string(space)
#     print_integer($a0)
#     print_string(space)
#     print_string(cell_end_border)
#     jr $ra

# skip_print:
#     addi $t4, $t4, 1           # Move to the next column
#     li   $t6, 3
#     blt  $t4, $t6, print_columns   # Loop through columns

#     # Print right border for the end of the row
#     print_string(cell_end_border)

#     addi $t3, $t3, 1           # Move to the next row
#     li   $t6, 3
#     blt  $t3, $t6, print_rows

#     print_string(grid_line)    # Print bottom border
#     jr $ra
