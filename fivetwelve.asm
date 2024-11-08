.macro 
    print_str(%label)
    la $a0, %label
    do_syscall(4)
.end_macro

.data
menu_msg:       .asciiz "Choose [1] New Game, [2] Start from a State, [X] Exit: "
enter_move:     .asciiz "Enter a move (A, D, W, S): "
win_msg:        .asciiz "Congratulations! You have reached the 512 tile!\n"
lose_msg:       .asciiz "Game over..\n"
invalid_input:  .asciiz "Invalid input. Try again.\n"
enter_grid:     .asciiz "Enter a board configuration (9 numbers):\n"


.text
main: