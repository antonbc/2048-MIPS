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

.macro exit
    do_syscall(10)                
.end_macro

.data
menu_msg:              .asciiz "Choose [1] or [2]: \n[1] New Game \n[2] Start from a State \n"
grid_line:             .asciiz "+---+---+---+\n"    # Horizontal border line
cell_left_border:      .asciiz "| "                 # Left border of each cell
cell_end_border:       .asciiz "|\n"               # Right border for each cell row end
space:                 .asciiz " "
enter_move:            .asciiz "Enter a move (A, D, W, S): "
win_msg:               .asciiz "Congratulations! You have reached the 512 tile!\n"
lose_msg:              .asciiz "Game over..\n"
invalid_input:         .asciiz "Invalid input. Try again.\n"
enter_grid:            .asciiz "Enter a board configuration (9 numbers):\n"

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
    subu $sp, $sp, 36       # Move stack pointer down by 36 bytes
    sw $ra, 32($sp)         # Save return address to stack

    li $t0, 0               
    li $t1, 9               
    move $t2, $sp           
    
initialize_grid:
    sw $t0, 0($t2)
    addiu $t2, $t2, 4
    subi $t1, $t1, 1
    bgez $t1, initialize_grid

    jal print_grid          # Call print_grid to display the initial grid
    lw $ra, 32($sp)         # Restore return address
    addu $sp, $sp, 36       # Restore stack pointer
    jr $ra

print_grid:
    li $t2, 3               # Row count (3 rows)
    li $t3, 0               # Column index (0-8)
    move $t4, $sp           # Pointer to start of grid on stack

print_rows:
    print_string(grid_line)     # Print top border of each row
    print_string(cell_left_border) # Print left border for each row

print_cells:
    lw $a0, 0($t4)              # Load the next cell value
    print_integer($a0)          # Print the cell value
    print_string(space)
    addiu $t4, $t4, 4           # Move to the next cell
    addiu $t3, $t3, 1           # Increment column index

    # Check if end of row (3 columns)
    li $t5, 3
    rem $t6, $t3, $t5
    bnez $t6, continue_cells

    # End of row, print right border and reset column index
    print_string(cell_end_border)
    addiu $t2, $t2, -1          # Decrement row count
    li $t3, 0                   # Reset column index for new row

    # Check if all rows are printed
    bgtz $t2, print_rows

    # Print the last horizontal line at the bottom of the grid
    print_string(grid_line)
    jr $ra

continue_cells:
    print_string(cell_left_border)  # Print left border for next cell
    b print_cells                   # Continue to next cell

start_from_state:
    exit
