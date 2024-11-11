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
enter_move:            .asciiz "Enter a move (A, D, W, S): "
win_msg:               .asciiz "Congratulations! You have reached the 512 tile!\n"
lose_msg:              .asciiz "Game over..\n"
invalid_input:         .asciiz "Invalid input. Try again.\n"
enter_grid:            .asciiz "Enter a board configuration (9 numbers):\n"
newline:               .asciiz "\n"
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
    # Allocate 36 bytes on the stack for a 3x3 grid (9 integers)
    subu $sp, $sp, 36       # Move stack pointer down by 36 bytes
    sw $ra, 32($sp)         # Save return address to stack

    # Initialize the grid with zeros
    li $t0, 0               # Initialize with zeros
    li $t1, 9               # Loop counter for 9 positions
    move $t2, $sp           # Pointer to the start of grid on stack

initialize_grid:
    sw $t0, 0($t2)          # Store 0 at the current grid position
    addiu $t2, $t2, 4       # Move to the next grid position
    subi $t1, $t1, 1
    bgtz $t1, initialize_grid

    # Print the initialized grid
    jal print_grid

    # Restore the stack and return
    lw $ra, 32($sp)         # Restore return address
    addiu $sp, $sp, 36      # Deallocate grid space on stack
    jr $ra

print_grid:
    li $t3, 0               # $t3 = row counter

print_rows:
    print_string(grid_line) # Print the top border of each row
    li $t4, 0               # $t4 = column counter

print_columns:
    print_string(cell_left_border) # Print the left border of each cell
    print_string(space)

    # Calculate address of the cell in the stack grid
    sll $t5, $t3, 2         # Calculate row offset (row index * 4 bytes)
    mul $t5, $t5, 3         # Move to current row (0, 12, 24, etc.)
    add $t5, $t5, $t4       # Add column offset
    sll $t5, $t5, 2         # Multiply by 4 (word size)
    add $t0, $sp, $t5       # Calculate address of cell
    lw $a0, 0($t0)          # Load cell value
    print_integer($a0)      # Print cell value
    print_string(space)

    addi $t4, $t4, 1        # Move to the next column
    li $t6, 3
    blt $t4, $t6, print_columns # Loop through columns

    # Print right border for end of row
    print_string(cell_end_border)
    
    # Move to the next row
    addi $t3, $t3, 1
    li $t6, 3
    blt $t3, $t6, print_rows

    print_string(grid_line) # Print bottom border
    #jr $ra

random_two_index:
    li $a1, 9               # upperbounds of the random number generated
    generate_random_number
    move $t5, $a0           # $t5 contains the first random index
    print_integer($t5)
    print_string(newline)

    # Generate the second random index, ensuring it's different from $t5
generate_second_index:
    li $a1, 9               
    generate_random_number
    move $t6, $a0           # $t6 contains the second random index
    beq $t6, $t5, generate_second_index   # If equal, regenerate
    print_integer($t6)
    print_string(newline)

    jr $ra

start_from_state:
    exit