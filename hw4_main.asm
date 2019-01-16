.data
map_filename: .asciiz "map3.txt"
# num words for map: 45 = (num_rows * num_cols + 2) // 4 
# map is random garbage initially
.asciiz "Don't touch this region of memory"
map: .word 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 
.asciiz "Don't touch this"
# player struct is random garbage initially
player: .word 0x2912FECD
.asciiz "Don't touch this either"
# visited[][] bit vector will always be initialized with all zeroes
# num words for visited: 6 = (num_rows * num*cols) // 32 + 1
visited: .word 0 0 0 0 0 0 
.asciiz "Really, please don't mess with this string"

welcome_msg: .asciiz "Welcome to MipsHack! Prepare for adventure!\n"
pos_str: .asciiz "Pos=["
health_str: .asciiz "] Health=["
coins_str: .asciiz "] Coins=["
your_move_str: .asciiz " Your Move: "
you_won_str: .asciiz "Congratulations! You have defeated your enemies and escaped with great riches!\n"
you_died_str: .asciiz "You died!\n"
you_failed_str: .asciiz "You have failed in your quest!\n"

.text
############################
print_map:
la $t0, map  # the function does not need to take arguments
lbu $t1, 0($t0) #first byte -> $t1
lbu $t2, 1($t0) #second byte of rows -> $t2
addi $t1, $t1, -1 #Decrement rows by 1
addi $t0, $t0, 2

li $t3, 0 #row Counter -> $t3
li $t4, 0 #col counter -> $t4

print_map_loop:
	beq $t4, $t2, post_print_map
	lbu $a0, 0($t0) #load character
	li $v0, 11 #print character
	syscall
	addi $t0, $t0, 1 #Increment map pointer
	addi $t4, $t4, 1 #Increment col
	j print_map_loop
	
post_print_map:
	beq $t3, $t1, print_map_done #If you finished printing all rows the print_map_done
	addi $t3, $t3, 1
	li $t4, 0 #Reset col counter
	li $a0, '\n'
	li $v0, 11 #print character
	syscall
	j print_map_loop

print_map_done:
jr $ra


#############################
print_player_info:
# the idea: print something like "Pos=[3,14] Health=[4] Coins=[1]"

#space
li $a0, '\n'
li $v0, 11
syscall

#health
la $t0, player	
lb $a0, 2($t0)
li $v0, 1	#print int
syscall 

#space
li $a0, '\n'
li $v0, 11
syscall

#coins
la $t0, player
lbu $a0, 3($t0)
li $v0, 1
syscall

jr $ra


.globl main
main:
la $a0, welcome_msg
li $v0, 4
syscall

# fill in arguments
la $a0, map_filename
la $a1, map
la $a2, player
jal init_game

# fill in arguments
la $a0, map
li $a1, 3
li $a2, 2
jal reveal_area

la $a0, map
la $a1, player

jal monster_attacks

li $s0, 0  # move = 0

game_loop:  # while player is not dead and move == 0:

jal print_map # takes no args

jal print_player_info # takes no args

# print prompt
la $a0, your_move_str
li $v0, 4
syscall

li $v0, 12  # read character from keyboard
syscall
move $s1, $v0  # $s1 has character entered
li $s0, 0  # move = 0

li $a0, '\n'
li $v0 11
syscall

# handle input: w, a, s or d
# map w, a, s, d  to  U, L, D, R and call player_turn()
map_wasd:
	bne $s1, 'w', map_wasd2
	li $a2, 'U'
	j call_to_player_turn
map_wasd2:	
	bne $s1, 'a', map_wasd3
	li $a2, 'L'
	j call_to_player_turn
map_wasd3:	
	bne $s1, 's', map_wasd4
	li $a2, 'D'
	j call_to_player_turn
map_wasd4:	
	bne $s1, 'd', game_loop
	li $a2, 'R'
	j call_to_player_turn
	
	
call_to_player_turn:
	la $a0, map
	la $a1, player
	#a2 is already set
	jal player_turn
# if move == 0, call reveal_area()  Otherwise, exit the loop.
	bnez $v0, game_over
#calling reveal
	la $a0, map
	la $t0, player
	lbu $a1, 0($t0)
	lbu $a2, 1($t0)
	jal reveal_area
	
j game_loop

game_over:
jal print_map
jal print_player_info
li $a0, '\n'
li $v0, 11
syscall

# choose between (1) player dead, (2) player escaped but lost, (3) player escaped and won

won:
la $a0, you_won_str
li $v0, 4
syscall
j exit

failed:
la $a0, you_failed_str
li $v0, 4
syscall
j exit

player_dead:
la $a0, you_died_str
li $v0, 4
syscall

exit:
li $v0, 10
syscall

.include "hw4.asm"
