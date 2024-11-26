.macro do_syscall(%n) # Performs syscalls
    li $v0, %n
    syscall
.end_macro

.macro read_integer # reads input integer
    do_syscall(5)                 
.end_macro

.macro read_string # reads input integer
    do_syscall(12)     
    move $a0, $v0            
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
    j play_game

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

    # Save $ra before calling print_array
    addi $sp, $sp, -4         # Allocate space on the stack
    sw   $ra, 0($sp)          # Save the return address

    # Call print_array
    jal print_array

    # Restore $ra after print_array returns
    lw   $ra, 0($sp)          # Restore the return address
    addi $sp, $sp, 4          # Deallocate stack space

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
    beq  $t3, 0, store_input
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

# working code
random_tile_generator:
    mul  $t2, $s3, $s3       # Calculate total cells n*n
    move $a1, $t2            # Set $a1 to total number of cells (n * n)
    
generate_random_index:
    generate_random_number   # Generate random number between 0 and n*n-1
    move $s1, $a0            # Store the random index in $s1
    
    # Calculate the memory address for the random index
    mul  $t0, $s1, 4         # Calculate byte offset (index * 4)
    add  $t0, $s4, $t0       # Add the base address of the grid ($s4)

    lw   $t3, 0($t0)         # Load the value at the random index
    
    # If the cell is empty (value == 0), place a 2 at the random index
    beq  $t3, $zero, place_two
    
    # If the cell is not empty, generate a new index
    j    generate_random_index

place_two:
    li   $t3, 2              # Load the value 2
    sw   $t3, 0($t0)         # Store the value 2 at the calculated address
    jr   $ra                 # Return from function

play_game:
    set_all_temp_registers_to_zero
    print_string(enter_move)        # Prompt user for move
    read_string                     # Read user input string
    move $t1, $a0

    # Check if the user wants to exit the game
    li   $t0, 88                    # ASCII value for 'X'
    beq  $t1, $t0, end_game         # If 'X', exit the game

    # Check if the user wants to disable random tile generator (input '3')
    li   $t0, 51                    # ASCII value for '3'
    beq  $t1, $t0, disable_random_generator

    # Check if the user wants to enable random tile generator (input '4')
    li   $t0, 52                    # ASCII value for '4'
    beq  $t1, $t0, enable_random_generator

    li   $t0, 65                    # ASCII value for 'A' (swipe left)
    beq  $t1, $t0, swipe_left       # If 'A', swipe left

    li   $t0, 68                    # ASCII value for 'D' (swipe right)
    beq  $t1, $t0, swipe_right      # If 'D', swipe right

    li   $t0, 87                    # ASCII value for 'W' (swipe up)
    beq  $t1, $t0, swipe_up         # If 'W', swipe up

    li   $t0, 83                    # ASCII value for 'S' (swipe down)
    beq  $t1, $t0, swipe_down       # If 'S', swipe down
    print_string(invalid_input) 
    # If the input is invalid, continue the game without any action
    j    play_game

# Disable Random Generator
disable_random_generator:
    li   $s5, 0                     # Set flag to 0 (disable random generator)
    j    play_game                  # Continue game loop

# Enable Random Generator
enable_random_generator:
    li   $s5, 1                     # Set flag to 1 (enable random generator)
    j    play_game                  # Continue game loop




swipe_right:
    li   $t0, 0               # Start with the first row index (0, 1, 2 for rows)

swipe_right_row:
    # Calculate the base address of the current row
    mul $t9, $s3, 4
    mul  $t1, $t0, $t9         # $t1 = row_index * 12 (3 integers * 4 bytes each)
    add  $t2, $s4, $t1        # $t2 = base address + row offset (points to the row)

    # Load the 3 values in the row into registers
    lw   $t3, 0($t2)          # Load the leftmost value into $t3
    lw   $t4, 4($t2)          # Load the middle value into $t4
    lw   $t5, 8($t2)          # Load the rightmost value into $t5

    # Step 1: Handle case where leftmost value needs to move to the rightmost slot
    # If both middle and rightmost are zero, move the leftmost to rightmost
    beq  $t4, $zero, check_rightmost
    j    shift_and_merge

check_rightmost:
    beq  $t5, $zero, move_leftmost_to_rightmost   # If both middle and rightmost are zero, move leftmost to rightmost
    j    shift_and_merge

move_leftmost_to_rightmost:
    move $t5, $t3             # Move leftmost to rightmost slot
    li   $t3, 0               # Set leftmost to 0
    li   $t4, 0               # Set middle to 0

shift_and_merge:
    # Step 2: Shift non-zero values to the right
    # Use $a0, $a1, $a2 as temporary "array" for the shifted row
    li   $a0, 0               # First slot (leftmost)
    li   $a1, 0               # Second slot (middle)
    li   $a2, 0               # Third slot (rightmost)

    # Check each value from right to left and populate temporary slots
    bne  $t5, $zero, store_t5
    j    check_t4

store_t5:
    move $a2, $t5             # Place $t5 in the rightmost slot
    j    check_t4

check_t4:
    bne  $t4, $zero, store_t4
    j    check_t3

store_t4:
    # If $a2 is empty, move $t4 there; otherwise, place it in $a1
    beq  $a2, $zero, store_t4_in_a2
    move $a1, $t4
    j    check_t3

store_t4_in_a2:
    move $a2, $t4             # Place $t4 in the rightmost slot
    j    check_t3

check_t3:
    bne  $t3, $zero, store_t3
    j    merge_values

store_t3:
    # If $a1 is empty, move $t3 there; otherwise, place it in $a0
    beq  $a1, $zero, store_t3_in_a1
    move $a0, $t3
    j    merge_values

store_t3_in_a1:
    move $a1, $t3             # Place $t3 in the middle slot
    j    merge_values

# Step 3: Merge values
merge_values:
    # Check if $a2 and $a1 are the same, and merge if so
    beq  $a2, $a1, merge_a2_a1
    j    check_a1_a0

merge_a2_a1:
    add  $a2, $a2, $a1        # Merge $a2 and $a1
    li   $a1, 0               # Clear $a1 (merged)

    # After merging $a2 and $a1, shift $a0 into $a1 (if $a0 != 0)
    bne  $a0, $zero, shift_a0_to_a1
    j    check_a1_a0

shift_a0_to_a1:
    move $a1, $a0             # Move $a0 to $a1
    li   $a0, 0               # Clear $a0
    j    check_a1_a0

check_a1_a0:
    # Check if $a1 and $a0 are the same, and merge if so
    beq  $a1, $a0, merge_a1_a0
    j    store_back

merge_a1_a0:
    add  $a1, $a1, $a0        # Merge $a1 and $a0
    li   $a0, 0               # Clear $a0 (merged)

# Step 4: Store the values back in memory
store_back:
    sw   $a0, 0($t2)          # Store the leftmost value
    sw   $a1, 4($t2)          # Store the middle value
    sw   $a2, 8($t2)          # Store the rightmost value

    # Move to the next row
    addi $t0, $t0, 1          # Increment row index
    move   $t6, $s3               # Total number of rows
    bne  $t0, $t6, swipe_right_row

    # After processing all rows, print the grid and return
    jal random_tile_generator
    jal  print_array          # Print the updated grid

    j play_game




swipe_left:
    li   $t0, 0               # Start with the first row index (0, 1, 2 for rows)

swipe_left_row:
    # Calculate the base address of the current row
    mul  $t9, $s3, 4
    mul  $t1, $t0, $t9         # $t1 = row_index * 12 (3 integers * 4 bytes each)
    add  $t2, $s4, $t1        # $t2 = base address + row offset (points to the row)

    # Load the 3 values in the row into registers
    lw   $t3, 0($t2)          # Load the leftmost value into $t3
    lw   $t4, 4($t2)          # Load the middle value into $t4
    lw   $t5, 8($t2)          # Load the rightmost value into $t5

    # Step 1: Handle case where rightmost value needs to move to the leftmost slot
    # If both middle and leftmost are zero, move the rightmost to leftmost
    beq  $t4, $zero, check_leftmost
    j    shift_and_merge_left

check_leftmost:
    beq  $t3, $zero, move_rightmost_to_leftmost   # If both middle and leftmost are zero, move rightmost to leftmost
    j    shift_and_merge_left

move_rightmost_to_leftmost:
    move $t3, $t5             # Move rightmost to leftmost slot
    li   $t5, 0               # Set rightmost to 0
    li   $t4, 0               # Set middle to 0

shift_and_merge_left:
    # Step 2: Shift non-zero values to the left
    # Use $a0, $a1, $a2 as temporary "array" for the shifted row
    li   $a0, 0               # First slot (leftmost)
    li   $a1, 0               # Second slot (middle)
    li   $a2, 0               # Third slot (rightmost)

    # Check each value from left to right and populate temporary slots
    bne  $t3, $zero, store_t3_left
    j    check_t4_left

store_t3_left:
    move $a0, $t3             # Place $t3 in the leftmost slot
    j    check_t4_left

check_t4_left:
    bne  $t4, $zero, store_t4_left
    j    check_t5_left

store_t4_left:
    # If $a0 is empty, move $t4 there; otherwise, place it in $a1
    beq  $a0, $zero, store_t4_in_a0
    move $a1, $t4
    j    check_t5_left

store_t4_in_a0:
    move $a0, $t4             # Place $t4 in the leftmost slot
    j    check_t5_left

check_t5_left:
    bne  $t5, $zero, store_t5_left
    j    merge_values_left

store_t5_left:
    # If $a1 is empty, move $t5 there; otherwise, place it in $a2
    beq  $a1, $zero, store_t5_in_a1
    move $a2, $t5
    j    merge_values_left

store_t5_in_a1:
    move $a1, $t5             # Place $t5 in the middle slot
    j    merge_values_left

# Step 3: Merge values
merge_values_left:
    # Check if $a0 and $a1 are the same, and merge if so
    beq  $a0, $a1, merge_a0_a1_left
    j    check_a1_a2_left

merge_a0_a1_left:
    add  $a0, $a0, $a1        # Merge $a0 and $a1
    li   $a1, 0               # Clear $a1 (merged)

    # After merging $a0 and $a1, shift $a2 into $a1 (if $a2 != 0)
    bne  $a2, $zero, shift_a2_to_a1_left
    j    check_a1_a2_left

shift_a2_to_a1_left:
    move $a1, $a2             # Move $a2 to $a1
    li   $a2, 0               # Clear $a2
    j    check_a1_a2_left

check_a1_a2_left:
    # Check if $a1 and $a2 are the same, and merge if so
    beq  $a1, $a2, merge_a1_a2_left
    j    store_back_left

merge_a1_a2_left:
    add  $a1, $a1, $a2        # Merge $a1 and $a2
    li   $a2, 0               # Clear $a2 (merged)

# Step 4: Store the values back in memory
store_back_left:
    sw   $a0, 0($t2)          # Store the leftmost value
    sw   $a1, 4($t2)          # Store the middle value
    sw   $a2, 8($t2)          # Store the rightmost value

    # Move to the next row
    addi $t0, $t0, 1          # Increment row index
    move $t6, $s3             # Total number of rows
    bne  $t0, $t6, swipe_left_row

    # After processing all rows, print the grid and return
    jal random_tile_generator
    jal print_array           # Print the updated grid

    j play_game




swipe_up:
    li   $t0, 0               # Start with the first column index (0, 1, 2 for columns)

swipe_up_column_up:
    # Calculate the base address of the current column
    mul  $t1, $t0, 4          # $t1 = column_index * 4 (4 bytes per element)
    add  $t2, $s4, $t1        # $t2 = base address + column offset (points to the column)

    # Load the 3 values in the column into registers
    lw   $t3, 0($t2)          # Top value
    lw   $t4, 12($t2)         # Middle value
    lw   $t5, 24($t2)         # Bottom value

    # Step 1: Shift non-zero values upwards
    li   $a0, 0               # Clear temporary slots (top)
    li   $a1, 0               # Clear temporary slots (middle)
    li   $a2, 0               # Clear temporary slots (bottom)

    # Check each value from top to bottom and shift to temporary slots
    bne  $t3, $zero, shift_t3_up
    j    check_t4_up

shift_t3_up:
    move $a0, $t3             # Place $t3 in the top slot
    j    check_t4_up

check_t4_up:
    bne  $t4, $zero, shift_t4_up
    j    check_t5_up

shift_t4_up:
    beq  $a0, $zero, store_t4_top_up
    move $a1, $t4             # Place $t4 in the second slot
    j    check_t5_up

store_t4_top_up:
    move $a0, $t4             # Place $t4 in the top slot
    j    check_t5_up

check_t5_up:
    bne  $t5, $zero, shift_t5_up
    j    merge_values_up

shift_t5_up:
    beq  $a0, $zero, store_t5_top_up
    beq  $a1, $zero, store_t5_middle_up
    move $a2, $t5             # Place $t5 in the bottom slot
    j    merge_values_up

store_t5_top_up:
    move $a0, $t5             # Place $t5 in the top slot
    j    merge_values_up

store_t5_middle_up:
    move $a1, $t5             # Place $t5 in the middle slot
    j    merge_values_up

# Step 2: Merge values
merge_values_up:
    # Merge top two values if they are equal
    beq  $a0, $a1, merge_a0_a1_up
    j    check_a1_a2_up

merge_a0_a1_up:
    add  $a0, $a0, $a1        # Merge $a0 and $a1
    li   $a1, 0               # Clear $a1
    bne  $a2, $zero, shift_a2_to_a1_up
    j    store_back_up

shift_a2_to_a1_up:
    move $a1, $a2             # Shift $a2 into $a1
    li   $a2, 0               # Clear $a2
    j    store_back_up

check_a1_a2_up:
    beq  $a1, $a2, merge_a1_a2_up
    j    store_back_up

merge_a1_a2_up:
    add  $a1, $a1, $a2        # Merge $a1 and $a2
    li   $a2, 0               # Clear $a2
    j    store_back_up

# Step 3: Store the values back in memory
store_back_up:
    sw   $a0, 0($t2)          # Store the topmost value
    sw   $a1, 12($t2)         # Store the middle value
    sw   $a2, 24($t2)         # Store the bottommost value

    # Move to the next column
    addi $t0, $t0, 1          # Increment column index
    li   $t6, 3               # Total number of columns (3)
    bne  $t0, $t6, swipe_up_column_up

    # After processing all columns, print the grid and return
    jal  random_tile_generator
    jal  print_array          # Print the updated grid

    j    play_game




swipe_down:
    li   $t0, 0               # Start with the first column index (0, 1, 2 for columns)

swipe_down_column_down:
    # Calculate the base address of the current column
    mul  $t1, $t0, 4          # $t1 = column_index * 4 (4 bytes per element)
    add  $t2, $s4, $t1        # $t2 = base address + column offset (points to the column)

    # Load the 3 values in the column into registers
    lw   $t3, 0($t2)          # Top value
    lw   $t4, 12($t2)         # Middle value
    lw   $t5, 24($t2)         # Bottom value

    # Step 1: Shift non-zero values downward
    li   $a0, 0               # Clear temporary slots (top)
    li   $a1, 0               # Clear temporary slots (middle)
    li   $a2, 0               # Clear temporary slots (bottom)

    # Check each value from bottom to top and shift to temporary slots
    bne  $t5, $zero, shift_t5_down
    j    check_t4_down

shift_t5_down:
    move $a2, $t5             # Place $t5 in the bottom slot
    j    check_t4_down

check_t4_down:
    bne  $t4, $zero, shift_t4_down
    j    check_t3_down

shift_t4_down:
    beq  $a2, $zero, store_t4_bottom_down
    move $a1, $t4             # Place $t4 in the middle slot
    j    check_t3_down

store_t4_bottom_down:
    move $a2, $t4             # Place $t4 in the bottom slot
    j    check_t3_down

check_t3_down:
    bne  $t3, $zero, shift_t3_down
    j    merge_values_down

shift_t3_down:
    beq  $a2, $zero, store_t3_bottom_down
    beq  $a1, $zero, store_t3_middle_down
    move $a0, $t3             # Place $t3 in the top slot
    j    merge_values_down

store_t3_bottom_down:
    move $a2, $t3             # Place $t3 in the bottom slot
    j    merge_values_down

store_t3_middle_down:
    move $a1, $t3             # Place $t3 in the middle slot
    j    merge_values_down

# Step 2: Merge values downward
merge_values_down:
    # Merge bottom two values if they are equal
    beq  $a2, $a1, merge_a2_a1_down
    j    check_a1_a0_down

merge_a2_a1_down:
    add  $a2, $a2, $a1        # Merge $a2 and $a1
    li   $a1, 0               # Clear $a1
    bne  $a0, $zero, shift_a0_to_a1_down
    j    store_back_down

shift_a0_to_a1_down:
    move $a1, $a0             # Shift $a0 into $a1
    li   $a0, 0               # Clear $a0
    j    store_back_down

check_a1_a0_down:
    beq  $a1, $a0, merge_a1_a0_down
    j    store_back_down

merge_a1_a0_down:
    add  $a1, $a1, $a0        # Merge $a1 and $a0
    li   $a0, 0               # Clear $a0
    j    store_back_down

# Step 3: Store the values back in memory
store_back_down:
    sw   $a0, 0($t2)          # Store the topmost value
    sw   $a1, 12($t2)         # Store the middle value
    sw   $a2, 24($t2)         # Store the bottommost value

    # Move to the next column
    addi $t0, $t0, 1          # Increment column index
    li   $t6, 3               # Total number of columns (3)
    bne  $t0, $t6, swipe_down_column_down

    # After processing all columns, print the grid and return
    jal  random_tile_generator
    jal  print_array          # Print the updated grid

    j    play_game



end_game:
    exit