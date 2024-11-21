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
empty_cell:            .asciiz "   "                # Adjust spacing for empty cells
enter_move:            .asciiz "Enter a move (A, D, W, S): "
win_msg:               .asciiz "Congratulations! You have reached the 512 tile!\n"
lose_msg:              .asciiz "Game over..\n"
invalid_input:         .asciiz "Invalid input. Try again.\n"
newline:               .asciiz "\n"

n:                     .word 3

.text
main:
    # Get grid size (n)
    la   $a0, n                # Load address of n
    lw   $t0, 0($a0)           # Load grid size into $t0
    move $s3, $t0              # Store n in $s3 for later use

    # Allocate memory for the grid on the stack (n * n * 4 bytes)
    mul  $t1, $t0, $t0         # Calculate n * n
    mul  $t1, $t1, 4           # Calculate total bytes (n * n * 4)
    subu $sp, $sp, $t1         # Adjust the stack pointer to create space
    move $s4, $sp              # Base address of the grid is now in $s4

    # Proceed with game logic
    jal get_game_choice
    beq $s0, 1, new_game
    beq $s0, 2, start_from_state
    exit

get_game_choice:
    print_string(menu_msg)
    read_integer
    move $s0, $v0              # Store user input in $s0
    jr $ra

new_game:
    # Randomly place two 2s in the grid
    li   $t2, 2              # Value to place in grid
    jal random_two_index     # Get two random indices in $s1, $s2

    # Store value at random index $s1
    move $a1, $s1
    jal store_random_value

    # Store value at random index $s2
    move $a1, $s2
    jal store_random_value

    # Print the modified grid
    jal print_array
    exit

store_random_value:
    # Calculate index offset dynamically
    mul  $t3, $a1, 4         # Calculate byte offset for index (index * 4)
    add  $t0, $s4, $t3       # Add offset to base address
    sw   $t2, 0($t0)         # Store value 2 at grid[index]
    jr   $ra

print_array:
    # Print grid dynamically based on n
    li   $t1, 0              # Row counter
    li   $t2, 0              # Cell counter
    move $t0, $s4            # Base address of grid

print_row:
    # Print a row separator
    print_string(grid_line)

print_cell:
    # Check if cell counter equals n (end of row)
    beq  $t2, $s3, new_row

    # Print cell value
    lw   $a0, 0($t0)         # Load cell value
    beq  $a0, 0, print_empty_cell # If 0, print empty cell
    print_integer($a0)
    j    increment_cell

print_empty_cell:
    print_string(empty_cell)
    j    increment_cell

increment_cell:
    addi $t2, $t2, 1         # Increment cell counter
    addi $t0, $t0, 4         # Move to next cell
    j    print_cell

new_row:
    # Print row ending and reset cell counter
    print_string(cell_end_border)
    addi $t1, $t1, 1         # Increment row counter
    li   $t2, 0              # Reset cell counter
    bne  $t1, $s3, print_row # Continue to next row if not done

    # Print final row separator
    print_string(grid_line)
    jr $ra

random_two_index:
    # Generate two random unique indices within grid bounds
    li   $t0, -1
    li   $t1, -1
    mul  $t2, $s3, $s3       # Calculate total cells n*n

generate_first_index:
    generate_random_number    # Generate random number
    rem  $t0, $v0, $t2       # Index = random_number % (n*n)
    bgez $t0, generate_second_index # Ensure valid index

generate_second_index:
    generate_random_number
    rem  $t1, $v0, $t2
    bne  $t1, $t0, unique_indices  # Ensure unique indices
    j    generate_second_index

unique_indices:
    move $s1, $t0            # Store first index
    move $s2, $t1            # Store second index
    jr $ra

start_from_state:
    exit