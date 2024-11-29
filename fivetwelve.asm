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
start_from_state_msg:  .asciiz "Enter a board configuration:\n"
grid_line:             .asciiz "+---+---+---+\n"    
cell_left_border:      .asciiz "|"                 
cell_end_border:       .asciiz "|\n"              
cell_space:            .asciiz " "  
empty_cell:            .asciiz " "             
enter_move:            .asciiz "Enter a move (A, D, W, S, 3, 4): "
win_msg:               .asciiz "Congratulations! You have reached the 512 tile!\n"
lose_msg:              .asciiz "Game over..\n"
invalid_input:         .asciiz "Invalid input. Try again.\n"
newline:               .asciiz "\n"
n:                     .word 3 # Grid size (can be changed to any value)

.text
main:
    set_all_registers_to_zero
    li $s5, 4
    la   $a0, n                # Load address of n
    lw   $t0, 0($a0)           # Load grid size into $t0
    move $s3, $t0              # Store n in $s3 for later use

    # Calculate total grid memory size (n * n * 4 bytes for integers)
    mul  $t1, $t0, $t0         # n * n (number of cells)
    mul  $t1, $t1, 4           # n * n * 4 (bytes per cell)

    #addi $t1, $t1, $t1  #backup grid

    # Allocate space for the grid and the return address
    add $t1, $t1, 4           # Add 4 bytes for the return address
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

    # Save $ra before calling print_grid
    addi $sp, $sp, -4         # Allocate space on the stack
    sw   $ra, 0($sp)          # Save the return address

    # Call print_grid
    jal print_grid

    # Restore $ra after print_grid returns
    lw   $ra, 0($sp)          # Restore the return address
    addi $sp, $sp, 4          # Deallocate stack space

    jr   $ra  

print_grid:
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

 



start_from_state:
    print_string(start_from_state_msg)
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
    jal print_grid
    j play_game



#===================================================================================================================
#============================================= GAME MECHANICS ====================================================+=
#===================================================================================================================

play_game:
    jal check_game_status
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


# working code
random_tile_generator:
    beq $t8, $zero, none_merged
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
    jal print_grid                 # Return from function
    j play_game

none_merged:
    jal print_grid
    j play_game

# Disable Random Generator
disable_random_generator:
    li   $s5, 3                     # Set flag to 0 (disable random generator)
    j    play_game                  # Continue game loop

# Enable Random Generator
enable_random_generator:
    li   $s5, 4                     # Set flag to 1 (enable random generator)
    j    play_game                  # Continue game loop



# MAAYOS
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

#$t3 = leftmost
#$t4 = middle
#$t5 = rightmost
check_rightmost:
    beq  $t5, $zero, check_leftmost_nonzero   # If both middle and rightmost are zero, move leftmost to rightmost
    j    shift_and_merge

check_leftmost_nonzero:
    bne $t3, $zero, move_leftmost_to_rightmost
    j shift_and_merge

move_leftmost_to_rightmost:
    li $t8, 1
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
    bne  $t5, $zero, store_t5 # if rightmost is non zero retain slot
    j    check_t4

store_t5:
    move $a2, $t5             # Place $t5 in the rightmost slot
    j    check_t4

check_t4:
    bne  $t4, $zero, store_t4 # if middle is not zero retain slot
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
    li $t8, 1   # a pair of cells merged

    # After merging $a2 and $a1, shift $a0 into $a1 (if $a0 != 0)
    bne  $a0, $zero, shift_a0_to_a1
    j    check_a1_a0

shift_a0_to_a1:
    move $a1, $a0             # Move $a0 to $a1
    li   $a0, 0               # Clear $a0

check_a1_a0:
    # Check if $a1 and $a0 are the same, and merge if so
    beq  $a0, $zero, store_back
    beq  $a1, $a0, merge_a1_a0
    j    store_back

merge_a1_a0:
    add  $a1, $a1, $a0        # Merge $a1 and $a0
    li   $a0, 0               # Clear $a0 (merged)
    li $t8, 1   # a pair of cells merged

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
    beq $s5, 4, random_tile_generator
    jal  print_grid          # Print the updated grid

    j play_game



#sira sira amp
swipe_left:
    li   $t0, 0               # Start with the first row index (0, 1, 2 for rows)
    li   $t8, 0

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
    li $t8, 1
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
    li $t8, 1
    # After merging $a0 and $a1, shift $a2 into $a1 (if $a2 != 0)
    bne  $a2, $zero, shift_a2_to_a1_left
    j    check_a1_a2_left

shift_a2_to_a1_left:
    move $a1, $a2             # Move $a2 to $a1
    li   $a2, 0               # Clear $a2

check_a1_a2_left:
    # Check if $a1 and $a2 are the same, and merge if so
    beq $a2, $zero, store_back_left
    beq  $a1, $a2, merge_a1_a2_left
    j    store_back_left

merge_a1_a2_left:
    add  $a1, $a1, $a2        # Merge $a1 and $a2
    li   $a2, 0               # Clear $a2 (merged)
    li $t8, 1

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
    beq $s5, 4, random_tile_generator
    jal  print_grid          # Print the updated grid

    j play_game



swipe_up:
    li   $t0, 0               # Start with the first column index (0, 1, 2 for columns)
    li   $t8, 0               # Reset movement/merge flag

swipe_up_column:
    # Calculate the base address of the current column
    mul  $t1, $t0, 4          # $t1 = column_index * 4 (4 bytes per element)
    add  $t2, $s4, $t1        # $t2 = base address + column offset (points to the column)

    # Load the 3 values in the column into registers
    lw   $t3, 0($t2)          # Top value
    lw   $t4, 12($t2)         # Middle value
    lw   $t5, 24($t2)         # Bottom value


    # Check $t3 (topmost value) first
    beq $t4, $zero, check_topmost
    j shift_and_merge_top

#$t3 = top
#$t4 = mid
#$t5 = bot
check_topmost:
    beq $t3, $zero, check_bottommost_nonzero
    j shift_and_merge_top

check_bottommost_nonzero:
    bne $t5, $zero, move_bottommost_to_topmost
    j shift_and_merge_top

move_bottommost_to_topmost:
    li $t8, 1
    move $t3, $t5             # Move bottom to top
    li   $t5, 0               # Set leftmost to 0
    li   $t4, 0               # Set middle to 0

shift_and_merge_top:
    li   $a0, 0               # Temporary slot for topmost
    li   $a1, 0               # Temporary slot for middle
    li   $a2, 0               # Temporary slot for bottommost

    bne $t3, $zero, store_t3_up
    j check_t4_up

store_t3_up:
    move $a0, $t3 
    j    check_t4_up

check_t4_up:
    bne  $t4, $zero, store_t4_up
    j    check_t5_up

store_t4_up:
    li $t8, 1
    beq  $a0, $zero, store_t4_in_a0_up
    move $a1, $t4
    j    check_t5_up

store_t4_in_a0_up:
    move $a0, $t4             
    j    check_t5_up

check_t5_up:
    bne  $t5, $zero, store_t5_up
    j    merge_values_up

store_t5_up:
    # Place $t5 in the lowest available slot
    beq  $a1, $zero, store_t5_in_a1_up
    move $a2, $t5
    j    merge_values_up

store_t5_in_a1_up:
    move $a1, $t5             # Place $t5 in the middle slot
    j    merge_values_up

# Step 2: Merge values
merge_values_up:
    beq  $a0, $a1, merge_a0_a1_up
    j    check_a1_a2_up

merge_a0_a1_up:
    add  $a0, $a0, $a1        # Merge $a0 and $a1
    li   $a1, 0               # Clear $a1
    li   $t8, 1               # Mark merge detected
    bne  $a2, $zero, shift_a2_to_a1_up
    j    check_a1_a2_up

shift_a2_to_a1_up:
    move $a1, $a2             # Move $a2 to $a1
    li   $a2, 0               # Clear $a2

check_a1_a2_up:
    # Check if $a1 and $a2 are equal and merge if so
    beq $a1, $zero, store_back_up
    beq  $a1, $a2, merge_a1_a2_up
    j    store_back_up

merge_a1_a2_up:
    add  $a1, $a1, $a2        # Merge $a1 and $a2
    li   $a2, 0               # Clear $a2
    li   $t8, 1               # Mark merge detected

# Step 3: Store the values back in memory
store_back_up:
    sw   $a0, 0($t2)          # Store the topmost value
    sw   $a1, 12($t2)         # Store the middle value
    sw   $a2, 24($t2)         # Store the bottommost value

    # Move to the next column
    addi $t0, $t0, 1          # Increment column index
    li   $t6, 3               # Total number of columns (3)
    bne  $t0, $t6, swipe_up_column

    # Generate a new tile if any movement or merge occurred
    beq $s5, 4, random_tile_generator

    # Print the grid and return to the game loop
    jal  print_grid
    j    play_game





swipe_down:
    li   $t0, 0               # Start with the first column index (0, 1, 2 for columns)
    li   $t8, 0 # check if a cell merges

swipe_down_column:
    # Calculate the base address of the current column
    mul  $t1, $t0, 4          # $t1 = column_index * 4 (4 bytes per element)
    add  $t2, $s4, $t1        # $t2 = base address + column offset (points to the column)

    # Load the 3 values in the column into registers
    lw   $t3, 0($t2)          # Top value
    lw   $t4, 12($t2)         # Middle value
    lw   $t5, 24($t2)         # Bottom value


    # Check each value from bottom to top and shift to temporary slots
    beq $t4, $zero, check_bottommost
    j shift_and_merge_bot

#$t3 = top
#$t4 = mid
#$t5 = bot
check_bottommost:
    beq $t5, $zero, check_topmost_nonzero
    j shift_and_merge_bot

check_topmost_nonzero:
    bne $t3, $zero, move_topmost_to_bottommost
    j shift_and_merge_bot

move_topmost_to_bottommost:
    li $t8, 1
    move $t5, $t3             # Move leftmost to rightmost slot
    li   $t3, 0               # Set leftmost to 0
    li   $t4, 0               # Set middle to 0

shift_and_merge_bot:
        # Step 1: Shift non-zero values downward
    li   $a0, 0               # Clear temporary slots (top)
    li   $a1, 0               # Clear temporary slots (middle)
    li   $a2, 0               # Clear temporary slots (bottom)

    bne  $t5, $zero, store_t5_down # if rightmost is non zero retain slot
    j    check_t4_down

store_t5_down:
    move $a2, $t5             # Place $t5 in the bottom slot
    j    check_t4_down

check_t4_down:
    bne  $t4, $zero, store_t4_down
    j    check_t3_down

store_t4_down:
    beq  $a2, $zero, store_t4_in_a2_down
    move $a1, $t4            # Place $t4 in the middle slot
    j    check_t3_down

store_t4_in_a2_down:
    move $a2, $t4             # Place $t4 in the rightmost slot
    j    check_t3_down

check_t3_down:
    bne  $t3, $zero, store_t3_down
    j    merge_values_down

store_t3_down:
    # If $a1 is empty, move $t3 there; otherwise, place it in $a0
    beq  $a1, $zero, store_t3_in_a1_down
    move $a0, $t3
    j    merge_values_down

store_t3_in_a1_down:
    move $a1, $t3             # Place $t3 in the middle slot
    j    merge_values_down

# Step 3: Merge values
merge_values_down:
    # Check if $a2 and $a1 are the same, and merge if so
    beq  $a2, $a1, merge_a2_a1_down
    j    check_a1_a0_down

merge_a2_a1_down:
    add  $a2, $a2, $a1        # Merge $a2 and $a1
    li   $a1, 0               # Clear $a1 (merged)
    li $t8, 1   # a pair of cells merged

    # After merging $a2 and $a1, shift $a0 into $a1 (if $a0 != 0)
    bne  $a0, $zero, shift_a0_to_a1_down
    j    check_a1_a0_down

shift_a0_to_a1_down:
    move $a1, $a0             # Move $a0 to $a1
    li   $a0, 0               # Clear $a0

check_a1_a0_down:
    # Check if $a1 and $a0 are the same, and merge if so
    beq  $a0, $zero, store_back_down
    beq  $a1, $a0, merge_a1_a0_down
    j    store_back_down

merge_a1_a0_down:
    add  $a1, $a1, $a0        # Merge $a1 and $a0
    li   $a0, 0               # Clear $a0 (merged)
    li $t8, 1   # a pair of cells merged

# Step 4: Store the values back in memory
store_back_down:
    sw   $a0, 0($t2)          # Store the leftmost value
    sw   $a1, 12($t2)          # Store the middle value
    sw   $a2, 24($t2)          # Store the rightmost value

    # Move to the next row
    addi $t0, $t0, 1          # Increment row index
    move   $t6, $s3               # Total number of rows
    bne  $t0, $t6, swipe_down_column

    # After processing all rows, print the grid and return
    beq $s5, 4, random_tile_generator
    jal  print_grid          # Print the updated grid

    j play_game




#==================== Win/Lose CHECKER ==============================

check_game_status:
    # Initialize variables
    li   $t0, 0                # Start index (0)
    li   $t1, 9                # Total number of cells (3x3 grid)

check_cells_loop:
    # Exit loop if all cells are checked
    beq  $t0, $t1, check_neighbors_loop

    # Load grid[$t0] value
    mul  $t3, $t0, 4           # Offset = index * 4
    add  $t3, $s4, $t3         # Address = grid base + offset
    lw   $t4, 0($t3)           # Load grid[$t0] value into $t4

    # If the current cell is 0, there is still space to play
    beq  $t4, $zero, game_continues
    beq  $t4, 512, win_game    # If cell value is 512, player wins

    # Increment index to check the next cell
    addi $t0, $t0, 1
    j check_cells_loop         # Repeat for the next cell

check_neighbors_loop:
    li   $t0, 0                # Reset index for neighbor checks

neighbor_check_loop:
    # Exit loop if all cells are checked
    beq  $t0, $t1, game_over

    # Load current cell value
    mul  $t3, $t0, 4           # Offset = index * 4
    add  $t3, $s4, $t3         # Address = grid base + offset
    lw   $t4, 0($t3)           # Load grid[$t0] value into $t4

    # Check top neighbor
    blt  $t0, 3, skip_top_check  # Skip if no top neighbor
    sub  $t5, $t0, 3            # $t5 = index - 3 (top neighbor)
    mul  $t6, $t5, 4            # Offset = top index * 4
    add  $t6, $s4, $t6          # Address = grid base + offset
    lw   $t7, 0($t6)            # Load top neighbor value
    beq  $t4, $t7, game_continues # If equal, game can continue

skip_top_check:
    # Check bottom neighbor
    addi $t5, $t0, 3            # $t5 = index + 3 (bottom neighbor)
    bge  $t5, 9, skip_bottom_check # Skip if no bottom neighbor
    mul  $t6, $t5, 4            # Offset = bottom index * 4
    add  $t6, $s4, $t6          # Address = grid base + offset
    lw   $t7, 0($t6)            # Load bottom neighbor value
    beq  $t4, $t7, game_continues # If equal, game can continue

skip_bottom_check:
    # Check left neighbor
    rem  $t8, $t0, 3            # $t8 = index % 3
    beq  $t8, $zero, skip_left_check # Skip if no left neighbor
    subi $t5, $t0, 1            # $t5 = index - 1 (left neighbor)
    mul  $t6, $t5, 4            # Offset = left index * 4
    add  $t6, $s4, $t6          # Address = grid base + offset
    lw   $t7, 0($t6)            # Load left neighbor value
    beq  $t4, $t7, game_continues # If equal, game can continue

skip_left_check:
    # Check right neighbor
    addi $t5, $t0, 1            # $t5 = index + 1 (right neighbor)
    rem  $t8, $t5, 3            # $t8 = (index + 1) % 3
    beq  $t8, $zero, skip_right_check # Skip if no right neighbor
    mul  $t6, $t5, 4            # Offset = right index * 4
    add  $t6, $s4, $t6          # Address = grid base + offset
    lw   $t7, 0($t6)            # Load right neighbor value
    beq  $t4, $t7, game_continues # If equal, game can continue

skip_right_check:
    # Increment index to check the next cell
    addi $t0, $t0, 1
    j neighbor_check_loop       # Repeat for the next cell

game_over:
    print_string(lose_msg)      # Print "Game Over" message
    exit

game_continues:
    jr $ra                      # Return to the caller

win_game:
    print_string(win_msg)       # Print "You Win!" message
    exit









end_game:
    exit