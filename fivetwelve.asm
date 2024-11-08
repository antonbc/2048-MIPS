.macro do_syscall(%n)
    	li $v0, %n
    	syscall
.end_macro

.macro read_integer
    	do_syscall(5)                 
.end_macro

.macro print_integer(%label)
    	move $a0, %label            
    	do_syscall(1)                 
.end_macro

.macro print_str(%label)
    	la $a0, %label
    	do_syscall(4)
.end_macro

.macro exit
   	    do_syscall(10)                
.end_macro

.data
menu_msg:       .asciiz "Choose [1] New Game \n [2] Start from a State \n"
enter_move:     .asciiz "Enter a move (A, D, W, S): "
win_msg:        .asciiz "Congratulations! You have reached the 512 tile!\n"
lose_msg:       .asciiz "Game over..\n"
invalid_input:  .asciiz "Invalid input. Try again.\n"
enter_grid:     .asciiz "Enter a board configuration (9 numbers):\n"


.text
main:
    
    exit