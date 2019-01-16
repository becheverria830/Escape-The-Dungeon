# Britney Echeverria
# bpecheverria
# 111607143

#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################

.text

# Part I
init_game:
li $v0, -1
li $v1, -1

addi $sp, $sp, -20
sw $ra, 0($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
sw $s3, 16($sp)

move $s0, $a0	#s0 = file name
move $s1, $a1	#s1 = map_ptr
move $s2, $a2	#s2 = player_ptr

move $a0, $s0	#a0 = file name
li $a1, 0	#a1 = flag = 0 (read only)
li $a2, 0	#a2 = mode	
li $v0, 13
syscall		#open

move $a0, $v0	#a0 = file descriptor
move $s3, $v0	#s3 = file descriptor
move $a1, $s1	#a1 = map_ptr
li $a2, 6	#a2 = first 4 numbers
li $v0, 14
syscall 	#read

lbu $t0, 0($s1)	#t0 = first digit of row
addi $t0, $t0, -48	
lbu $t1, 1($s1)	#t1 = second digit of row
addi $t1, $t1, -48
lbu $t2, 3($s1)	#t2 = first digit of col
addi $t2, $t2, -48
lbu $t3, 4($s1)	#t3 = second digit of col
addi $t3, $t3, -48

li $t4, 10		#tens place
mul $t0, $t0, $t4	#make first digit the tens place
add $t0, $t0, $t1	#add tens + ones
#t0 = rows
sb $t0, 0($s1)	


mul $t2, $t2, $t4	
add $t1, $t2, $t3	
#t1 = cols
sb $t1, 1($s1)

mul $t2, $t0, $t1	#t2 = row*col = matrix size
li $t3, 0		#t3 = counter
li $t5, 0		#t5 = ind. char
addi $s1, $s1, 2 	#incremement string pointer

####################################################

move $a0, $s3	#a0 = file descriptor
move $a1, $s1	#a1 = map struct
li $a2, 1	#a2 = 1 byte at a time


loop_matrix:
	li $v0, 14
	syscall 	#read
	
	beq $t3, $t2, loop_matrix_done
	lbu $t5, 0($s1)		#t5 = ind. char
	beq $t5, '@', found_player_coords
	beq $t5, '\n', skip_end_line
	#loop_matrix_2:
	ori $t5, $t5, 0x80
	sb $t5, 0($s1)		#store changed value
	addi $t3, $t3, 1	#incr. counter
	addi $s1, $s1, 1	#incr. pointer
	move $a1, $s1
	j loop_matrix
found_player_coords:
	div $t3, $t1 	#size/cols; quotient = rows, remainder = cols
	mfhi $t6	#col
	mflo $t7	#rows
	sb $t7, 0($s2)
	sb $t6, 1($s2)
	addi $t3, $t3, 1	#incr. counter
	addi $s1, $s1, 1	#incr. pointer
	move $a1, $s1
	j loop_matrix
skip_end_line:
	#addi $s1, $s1, 1
	j loop_matrix
loop_matrix_done:

	move $a0, $s3	#a0 = file descriptor
	move $a1, $s1	#a1 = map_ptr
	li $a2, 3	#a2 = first 2 numbers
	li $v0, 14
	syscall 	#read
	
	lb $t5, 0($s1)		#ten's place of health
	addi $t5, $t5, -48
	lb $t6, 1($s1)		#one's place of health
	addi $t6, $t6, -48
	
	li $t4, 10
	mul $t5, $t5, $t4
	add $t5, $t5, $t6	#t5 = health
	sb $t5, 2($s2)
	
	li $t4, 0		#t4 = starting coins
	sb $t4, 3($s2)	
	
	move $a0, $s3
	li $v0, 16		#close
	syscall 


lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)	
addi $sp, $sp, 20
jr $ra


########################################################################################################################################
# Part II
is_valid_cell:
li $v0, -1
li $v1, -1

#error check pt 1
bltz $a1, return_pt2
bltz $a2, return_pt2

lb $t0, 0($a0)	#t0 = map rows
lb $t1, 1($a0)	#t1 = map cols

bge $a1, $t0, return_pt2	#row check
bge $a2, $t1, return_pt2	#col check

li $v0, 0

return_pt2:
jr $ra

########################################################################################################################################
# Part III
get_cell:
li $v0, -1
li $v1, -1

move $t2, $a0	#t2 = map
move $t3, $a1	#t3 = i
move $t4, $a2	#t4 = j

#error-check
bltz $t3, return_pt3
bltz $t4, return_pt3

lbu $t0, 0($t2)		#t0 = R (number of rows in map)
lbu $t1, 1($t2)		#t1 = C (number of rows in map) 

bge $t3, $t0, return_pt3	#row check
bge $t4, $t1, return_pt3	#col check

addi $t2, $t2, 2	#incremement map pointer

mul $t5, $t3, $t1	#t5 = i*C
add $t5, $t5, $t4	#t5 = i*C+j
add $t2, $t2, $t5	#t2 = base + (i*C+j)
lbu $v0, 0($t2)

return_pt3:
jr $ra

########################################################################################################################################
# Part IV
set_cell:
li $v0, -1
li $v1, -1

addi $sp, $sp, -24
sw $ra, 0($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
sw $s3, 16($sp)
sw $s4, 20($sp)

#error-check
bltz $a1, return_pt4
bltz $a2, return_pt4

move $s0, $a0		#s0 = map
lbu $s1, 0($s0)		#s1 = numRow
lbu $s2, 1($s0)		#s2 = numCol
move $s3, $a3		#s3 = character
addi $s0, $s0, 2	#inc map counter

bge $a1, $s1, return_pt4	#row check
bge $a2, $s2, return_pt4	#col check

#arguments already correct

jal is_valid_cell

bnez $v0, return_pt4

mul $s4, $a1, $s2	#s4 = i*C
add $s4, $s4, $a2	#s4 = i*C+j
add $s0, $s0, $s4	#s0 = base + (i*C+j)
sb $s3, 0($s0)

return_pt4:

lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
addi $sp, $sp, 24
jr $ra

##########################################################################################################################
# Part V
reveal_area:
li $v0, -1
li $v1, -1

addi $sp, $sp, -32
sw $ra, 0($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
sw $s3, 16($sp)
sw $s4, 20($sp)
sw $s5, 24($sp)
sw $s6, 28($sp)


move $s0, $a0		#s0 = map
move $s1, $a1		#s1 = row of current
move $s2, $a2		#s2 = col of current
lbu $s3, 0($s0)		#s3 = numRows
lbu $s4, 1($s0)		#s4 = numCols	
#center
center_cell:
	#(i,j)
	move $s5, $s1		#s5 = i
	move $s6, $s2		#s6 = j
	#get_cell	
	move $a0, $s0		#a0 = map struct
	move $a1, $s5		#a1 = i
	move $a2, $s6		#a2 = j
	jal get_cell
	move $t0, $v0 		#t0 = ascii? value of cell
	andi $t0, $t0, 127	#and with 01111111
	#set_cell
	move $a0, $s0		#a0 = map struct
	move $a1, $s5		#a1 = i
	move $a2, $s6		#a2 = j
	move $a3, $t0		#a3 = char
	jal set_cell
	
#up-left
up_left:
	#(i-1,j-1)
	move $s5, $s1	
	addi $s5, $s5, -1	#s5 = i-1
	move $s6, $s2	
	addi $s6, $s6, -1	#s6 = j-1
	#get_cell
	move $a0, $s0		#a0 = map struct
	move $a1, $s5		#a1 = i'
	move $a2, $s6		#a2 = j'
	jal get_cell
	move $t0, $v0 		#t0 = ascii? value of cell
	andi $t0, $t0, 127	#and with 01111111
	#set_cell
	move $a0, $s0		#a0 = map struct
	move $a1, $s5		#a1 = i'
	move $a2, $s6		#a2 = j'
	move $a3, $t0		#a3 = char
	jal set_cell

#up
up:
	#(i-1,j)
	move $s5, $s1	
	addi $s5, $s5, -1	#s5 = i-1
	move $s6, $s2		#s6 = j
	#get_cell
	move $a0, $s0		#a0 = map struct
	move $a1, $s5		#a1 = i'
	move $a2, $s6		#a2 = j'
	jal get_cell
	move $t0, $v0 		#t0 = ascii? value of cell
	andi $t0, $t0, 127	#and with 01111111
	#set_cell
	move $a0, $s0		#a0 = map struct
	move $a1, $s5		#a1 = i'
	move $a2, $s6		#a2 = j'
	move $a3, $t0		#a3 = char
	jal set_cell
#up-right
up_right:
	#(i-1,j+1)
	move $s5, $s1	
	addi $s5, $s5, -1	#s5 = i-1
	move $s6, $s2		
	addi $s6, $s6, 1	#s6 = j+1
	#get_cell	
	move $a0, $s0		#a0 = map struct
	move $a1, $s5		#a1 = i'
	move $a2, $s6		#a2 = j'
	jal get_cell	
	move $t0, $v0 		#t0 = ascii? value of cell
	andi $t0, $t0, 127	#and with 01111111
	#set_cell
	move $a0, $s0		#a0 = map struct
	move $a1, $s5		#a1 = i'
	move $a2, $s6		#a2 = j'
	move $a3, $t0		#a3 = char
	jal set_cell

#left
left:
	#(i,j-1)
	move $s5, $s1		#s5 = i
	move $s6, $s2		
	addi $s6, $s6, -1	#s6 = j-1
	#get_cell	
	move $a0, $s0		#a0 = map struct
	move $a1, $s5		#a1 = i'
	move $a2, $s6		#a2 = j'
	jal get_cell
	move $t0, $v0 		#t0 = ascii? value of cell
	andi $t0, $t0, 127	#and with 01111111
	#set_cell
	move $a0, $s0		#a0 = map struct
	move $a1, $s5		#a1 = i'
	move $a2, $s6		#a2 = j'
	move $a3, $t0		#a3 = char
	jal set_cell

#right
right:
	#(i,j+1)
	move $s5, $s1		#s5 = i
	move $s6, $s2		
	addi $s6, $s6, 1	#s6 = j+1
	#get_cell	
	move $a0, $s0		#a0 = map struct
	move $a1, $s5		#a1 = i'
	move $a2, $s6		#a2 = j'
	jal get_cell
	move $t0, $v0 		#t0 = ascii? value of cell
	andi $t0, $t0, 127	#and with 01111111
	#set_cell
	move $a0, $s0		#a0 = map struct
	move $a1, $s5		#a1 = i'
	move $a2, $s6		#a2 = j'
	move $a3, $t0		#a3 = char
	jal set_cell

#bottom-left
bottom_left:
	#(i+1,j-1)
	move $s5, $s1		
	addi $s5, $s5, 1	#s5 = i+1
	move $s6, $s2		
	addi $s6, $s6, -1	#s6 = j-1
	#get_cell
	move $a0, $s0		#a0 = map struct
	move $a1, $s5		#a1 = i'
	move $a2, $s6		#a2 = j'
	jal get_cell
	move $t0, $v0 		#t0 = ascii? value of cell
	andi $t0, $t0, 127	#and with 01111111
	#set_cell
	move $a0, $s0		#a0 = map struct
	move $a1, $s5		#a1 = i'
	move $a2, $s6		#a2 = j'
	move $a3, $t0		#a3 = char
	jal set_cell

#bottom
bottom:
	#(i+1,j)
	move $s5, $s1		
	addi $s5, $s5, 1	#s5 = i+1
	move $s6, $s2		#s6 = j
	#get_cell
	move $a0, $s0		#a0 = map struct
	move $a1, $s5		#a1 = i'
	move $a2, $s6		#a2 = j'
	jal get_cell
	move $t0, $v0 		#t0 = ascii? value of cell
	andi $t0, $t0, 127	#and with 01111111
	#set_cell
	move $a0, $s0		#a0 = map struct
	move $a1, $s5		#a1 = i'
	move $a2, $s6		#a2 = j'
	move $a3, $t0		#a3 = char
	jal set_cell

#bottom-right
bottom_right:
	#(i+1,j+1)
	move $s5, $s1		
	addi $s5, $s5, 1	#s5 = i+1
	move $s6, $s2	
	addi $s6, $s6, 1	#s6 = j+1	
	#get_cell
	move $a0, $s0		#a0 = map struct
	move $a1, $s5		#a1 = i'
	move $a2, $s6		#a2 = j'
	jal get_cell
	move $t0, $v0 		#t0 = ascii? value of cell
	andi $t0, $t0, 127	#and with 01111111
	#set_cell
	move $a0, $s0		#a0 = map struct
	move $a1, $s5		#a1 = i'
	move $a2, $s6		#a2 = j'
	move $a3, $t0		#a3 = char
	jal set_cell


lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
lw $s5, 24($sp)
lw $s6, 28($sp)
addi $sp, $sp, 32
jr $ra

#########################################################################################################################
# Part VI
get_attack_target:
li $v0, -1
li $v1, -1

addi $sp, $sp, -16
sw $ra, 0($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)

move $s0, $a0		#s0 = map struct
lbu $s1, 0($a1)		#s1 = player's i
lbu $s2, 1($a1)		#s2 = player's j

#error check for direction
beq $a2, 'U', get_up
beq $a2, 'D', get_down
beq $a2, 'L', get_left
beq $a2, 'R', get_right
jr $ra	#else, error

get_up:
	#(i-1, j)
	addi $s1, $s1, -1
	j find_target

get_down:
	#(i+1, j)
	addi $s1, $s1, 1
	j find_target
	
get_left:
	#(i, j-1)
	addi $s1, $s1, -1
	j find_target
	
get_right:
	#(i, j+1)
	addi $s1, $s1, 1
	j find_target
	
find_target:
	move $a0, $s0		#a0 = map struct
	move $a1, $s1		#a1 = i
	move $a2, $s2		#a2 = j

	jal get_cell
	
	beq $v0, 'm', return_pt6
	beq $v0, 'B', return_pt6
	beq $v0, '/', return_pt6
	li $v0, -1	#else, error


return_pt6:

lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
addi $sp, $sp, 16
jr $ra

#############################################################################################################
# Part VII
monster_attacks:
li $v0, 0
li $v1, -1

addi $sp, $sp, -20
sw $ra, 0($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
sw $s3, 16($sp)

move $s0, $a0			#s0 = map struct
lbu $s1, 0($a1)			#s1 = player's i
lbu $s2, 1($a1)			#s2 = player's j

li $s3, 0			#s3 = total possible damage
check_monster_up:
	#(i-1, j)
	#get
	move $a0, $s0		#a0 = map
	addi $t0, $s1, -1		
	move $a1, $t0		#a1 = i-1
	move $a2, $s2		#a2 = j
	
	jal get_cell
	
	li $t0, -1		#if there was an error...
	beq $v0, $t0, check_monster_down
	bne $v0, 'm', check_monster_up2
	addi $s3, $s3, 1	#its m
	j check_monster_down
	check_monster_up2:
	bne $v0, 'B', check_monster_down
	addi $s3, $s3, 2	#its B
check_monster_down:
	#(i+1, j)
	#get
	move $a0, $s0		#a0 = map
	addi $t0, $s1, 1		
	move $a1, $t0		#a1 = i+1
	move $a2, $s2		#a2 = j
	
	jal get_cell
	
	li $t0, -1		#if there was an error...
	beq $v0, $t0, check_monster_left
	bne $v0, 'm', check_monster_down2
	addi $s3, $s3, 1	#its m
	j check_monster_left
	check_monster_down2:
	bne $v0, 'B', check_monster_left
	addi $s3, $s3, 2	#its B
check_monster_left:
	#(i, j-1)
	#get
	move $a0, $s0		#a0 = map	
	move $a1, $s1		#a1 = i
	addi $t0, $s2, -1
	move $a2, $t0		#a2 = j-1
	
	jal get_cell
	
	li $t0, -1		#if there was an error...
	beq $v0, $t0, check_monster_right
	bne $v0, 'm', check_monster_left2
	addi $s3, $s3, 1	#its m
	j check_monster_right
	check_monster_left2:
	bne $v0, 'B', check_monster_right
	addi $s3, $s3, 2	#its B
check_monster_right:
	#(i, j+1)
	#get
	move $a0, $s0		#a0 = map	
	move $a1, $s1		#a1 = i
	addi $t0, $s2, 1
	move $a2, $t0		#a2 = j+1
	
	jal get_cell
	
	li $t0, -1		#if there was an error...
	beq $v0, $t0, done_checking
	bne $v0, 'm', check_monster_right2
	addi $s3, $s3, 1	#its m
	j done_checking
	check_monster_right2:
	bne $v0, 'B', done_checking
	addi $s3, $s3, 2	#its B

done_checking:

move $v0, $s3

lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
addi $sp, $sp, 20
jr $ra

################################################################################
# Part VIII
player_move:
li $v0, -1
li $v1, -1

addi $sp, $sp, -28
sw $ra, 0($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
sw $s3, 16($sp)
sw $s4, 20($sp)
sw $s5, 24($sp)

move $s0, $a0		#s0 = map
move $s1, $a1		#s1 = player
move $s2, $a2		#s2 = target's i
move $s3, $a3		#s3 = target's j
#subtract monster attack in player health

move $a0, $s0		#a0 = map
move $a1, $s1		#a1 = player

jal monster_attacks

move $t0, $v0		#t0 = amount of damage
lb $t1, 2($s1)		#t1 = current health
sub $t1, $t1, $t0	#t1 = new health
sb $t1, 2($s1)		#replace health

lbu $s4, 0($s1)		#s4 = player's i
lbu $s5, 1($s1)		#s5 = player's j

blez $t1, player_killed



#get what kind of target
move $a0, $s0		#a0 = map
move $a1, $s2		#a1 = target's i
move $a2, $s3		#a2 = target's j

jal get_cell

beq $v0, '.', target_dot
beq $v0, '$', target_dollar
beq $v0, '*', target_star
beq $v0, '/', target_door #if this doesnt branch, somethings wrong
j return_pt8

target_dot:
	#set current to dot
	move $a0, $s0		#a0 = map
	move $a1, $s4		#a1 = player's i
	move $a2, $s5		#a2 = player's j
	li $a3, '.'		#a3 = .
	jal set_cell
	lw $ra, 0($sp)
	
	#set target to @
	move $a0, $s0		#a0 = map
	move $a1, $s2		#a1 = target's i
	move $a2, $s3 		#a2 = target's j
	li $a3, '@'		#a3 = @
	jal set_cell
	lw $ra, 0($sp)
	
	#change player struct
	sb $s2, 0($s1)
	sb $s3, 1($s1)
	
	li $v0, 0		#return 0
	j return_pt8
target_dollar:
	#set current to dot
	move $a0, $s0		#a0 = map
	move $a1, $s4		#a1 = player's i
	move $a2, $s5		#a2 = player's j
	li $a3, '.'		#a3 = .
	jal set_cell
	lw $ra, 0($sp)
	
	#set target to @
	move $a0, $s0		#a0 = map
	move $a1, $s2		#a1 = target's i
	move $a2, $s3 		#a2 = target's j
	li $a3, '@'		#a3 = @
	jal set_cell
	lw $ra, 0($sp)
	
	#change player struct
	sb $s2, 0($s1)
	sb $s3, 1($s1)
	
	#add to coins
	lbu $t9, 3($s1)
	addi $t9, $t9, 1
	sb $t9, 3($s1)
	
	li $v0, 0		#return 0
	j return_pt8
target_star:
	#set current to dot
	move $a0, $s0		#a0 = map
	move $a1, $s4		#a1 = player's i
	move $a2, $s5		#a2 = player's j
	li $a3, '.'		#a3 = .
	jal set_cell
	lw $ra, 0($sp)
	
	#set target to @
	move $a0, $s0		#a0 = map
	move $a1, $s2		#a1 = target's i
	move $a2, $s3 		#a2 = target's j
	li $a3, '@'		#a3 = @
	jal set_cell
	lw $ra, 0($sp)
	
	#change player struct
	sb $s2, 0($s1)
	sb $s3, 1($s1)
	
	#add to coins
	lbu $t9, 3($s1)
	addi $t9, $t9, 5
	sb $t9, 3($s1)
	
	li $v0, 0		#return 0
	j return_pt8
target_door:
	#set current to dot
	move $a0, $s0		#a0 = map
	move $a1, $s4		#a1 = player's i
	move $a2, $s5		#a2 = player's j
	li $a3, '.'		#a3 = .
	jal set_cell
	lw $ra, 0($sp)
	
	#set target to @
	move $a0, $s0		#a0 = map
	move $a1, $s2		#a1 = target's i
	move $a2, $s3 		#a2 = target's j
	li $a3, '@'		#a3 = @
	jal set_cell
	lw $ra, 0($sp)
	
	#change player struct
	sb $s2, 0($s1)
	sb $s3, 1($s1)
	
	li $v0, -1		#return -1
	j return_pt8
player_killed:
	#set current to X
	move $a0, $s0		#a0 = map
	move $a1, $s4		#a1 = player's i
	move $a2, $s5		#a2 = player's j
	li $a3, 'X'		#a3 = X
	jal set_cell
	lw $ra, 0($sp)
	li $v0, 0		#return 0

return_pt8:
lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
lw $s5, 24($sp)
addi $sp, $sp, 28
jr $ra


###############################################################################
# Part IX
complete_attack:
li $v0, -1
li $v1, -1

addi $sp, $sp, -20
sw $ra, 0($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
sw $s3, 16($sp)


move $s0, $a0	#s0 = map struct
move $s1, $a1	#s1 = player struct
move $s2, $a2	#s2 = target's i
move $s3, $a3	#s3 = target's j

move $a0, $s0	#a0 = map
move $a1, $s2	#a1 = i
move $a2, $s3	#a2 = j

jal get_cell

beq $v0, 'm', m_attack
beq $v0, 'B', B_attack
beq $v0, '/', door_attack

m_attack:
	lb $t0, 2($s1)		#t0 = player health
	addi $t0, $t0, -1	#-1 health
	sb $t0, 2($s1)
	
	move $a0, $s0		#a0 = map
	move $a1, $s2		#a1 = target's i
	move $a2, $s3		#a2 = target's j
	li $a3, '$'		#a3 = character
	
	jal set_cell
	
	j return_pt9
B_attack:
	lb $t0, 2($s1)		#t0 = player health
	addi $t0, $t0, -2	#-2 health
	sb $t0, 2($s1)
	
	move $a0, $s0		#a0 = map
	move $a1, $s2		#a1 = target's i
	move $a2, $s3		#a2 = target's j
	li $a3, '*'		#a3 = character
	
	jal set_cell
	
	j return_pt9
	
door_attack:
	move $a0, $s0		#a0 = map
	move $a1, $s2		#a1 = target's i
	move $a2, $s3		#a2 = target's j
	li $a3, '.'		#a3 = character
	
	jal set_cell
	
	j return_pt9
return_pt9:

lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
addi $sp, $sp, 20
jr $ra

################################################################################
# Part X
player_turn:
li $v0, -1
li $v1, -1

addi $sp, $sp, -32
sw $ra, 0($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
sw $s3, 16($sp)
sw $s4, 20($sp)
sw $s5, 24($sp)
sw $s6, 28($sp)

move $s0, $a0		#s0 = map
move $s1, $a1		#s1 = player
move $s2, $a2		#s2 = direction

#check if direction is valid
beq $s2, 'U', valid_dir
beq $s2, 'D', valid_dir
beq $s2, 'L', valid_dir
beq $s2, 'R', valid_dir
jr $ra		#else, return -1

valid_dir:
lbu $s3, 0($s1)		#s3 = player's i
lbu $s4, 1($s1)		#s4 = player's j

#set up direction to see if target is a valid cell
check_U:
	bne $s2, 'U', check_D
	#up: (i-1,j)
	move $a0, $s0		#a0 = map
	addi $s5, $s3, -1			#s5 = i'
	move $a1, $s5		#a1 = i-1
	move $s6, $s4				#s6 = j'
	move $a2, $s6		#a2 = j

	jal is_valid_cell
	bnez $v0, make_return_value_0
	j check_if_wall

check_D:
	bne $s2, 'D', check_L
	#down: (i+1,j)
	move $a0, $s0		#a0 = map
	addi $s5, $s3, 1		
	move $a1, $s5		#a1 = i+1
	move $s6, $s4
	move $a2, $s6		#a2 = j
	
	jal is_valid_cell
	bnez $v0, make_return_value_0
	j check_if_wall
	
check_L:
	bne $s2, 'L', check_R
	#left: (i,j-1)
	move $a0, $s0		#a0 = map
	move $s5, $s3
	move $a1, $s5		#a1 = i
	addi $s6, $s4, -1	
	move $a2, $s6		#a2 = j-1
	
	jal is_valid_cell
	bnez $v0, make_return_value_0	
	j check_if_wall
	
check_R:
	#right: (i,j+1)
	move $a0, $s0		#a0 = map
	move $s5, $s3
	move $a1, $s5		#a1 = i
	addi $s6, $s4, 1	
	move $a2, $s6		#a2 = j+1
	
	jal is_valid_cell
	bnez $v0, make_return_value_0	
	j check_if_wall
	
#call get_cell to see if target is "#"
check_if_wall:
	move $a0, $s0	#a0 = map
	move $a1, $s5	#a1 = i'
	move $a1, $s6	#a2 = j'
	
	jal get_cell
	li $t0, '#'
	beq $v0, $t0, make_return_value_0
	
check_if_attackable:
	move $a0, $s0	#a0 = map
	move $a1, $s1	#a1 = player
	move $a2, $s2	#a3 = direction
	
	jal get_attack_target	

	li $t0, -1
	beq $v0, $t0, call_player_move	#not attackable
	
	move $a0, $s0	#a0 = map
	move $a1, $s1	#a1 = player
	move $a2, $s5	#a2 = i'
	move $a3, $s6	#a3 = j'
	
	jal complete_attack
	j make_return_value_0
	
call_player_move:
	move $a0, $s0	#a0 = map
	move $a1, $s1	#a1 = player
	move $a2, $s5	#a2 = i'
	move $a3, $s6	#a3 = j'
	
	jal player_move
	#v0 = v0
	j return_pt10
	
make_return_value_0:
li $v0, 0
return_pt10:

lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
lw $s5, 24($sp)
lw $s6, 28($sp)
addi $sp, $sp, 32

jr $ra

##############
#need to do last 2 push for each offset
# Part XI
flood_fill_reveal:
li $v0, -1
li $v1, -1

addi $sp, $sp, -32
sw $ra, 0($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
sw $s3, 16($sp)
sw $s4, 20($sp)
sw $s5, 24($sp)
sw $fp, 28($sp)

move $s0, $a0	#s0 = map
lbu $t0, 0($s0)	#t0 = numRows
lbu $t1, 1($s0)	#t1 = numCols
move $s1, $a1	#s1 = row
move $s2, $a2	#s2 = col
move $s3, $a3	#s3 = visited matrix

bltz $s1, return_pt11	
bltz $s2, return_pt11
bge $s1, $t0, return_pt11
bge $s2, $t1, return_pt11

move $fp, $sp		#fp = sp
addi $sp, $sp, -8
sw $s1, 0($sp)		#s1 = row
sw $s2, 4($sp)		#s2 = col


while_loop:
	beq $fp, $sp, while_loop_done
	lbu $s1, 0($sp)		#s1 = row = sp.pop
	lbu $s2, 1($sp)		#s2 = col = sp.pop
	
	#make current visible
	
	#get cell
	move $a0, $s0		#a0 = map
	move $a1, $s1		#a1 = row
	move $a2, $s2		#a2 = col
	jal get_cell
	
	#unhide it
	move $t2, $v0		#t2 = char
	xori $t2, $t2, 0x80
	
	#set cell
	move $a0, $s0		#a0 = map
	move $a1, $s1		#a1 = row
	move $a2, $s2		#a2 = col
	move $a3, $t2		#a3 = unhidden char
	jal set_cell
	
	#mark it visited
	move $a0, $s3		#a0 = visited matrix
	move $a1, $s1		#a1 = row
	move $a2, $s2		#a2 = col
	li $a3, 1		#a3 = 1				#??????
	jal set_cell
	
	
	#UP:(i-1,j)
	check_u:
	move $s4, $s1		#s4 = i
	move $s5, $s2		#s5 = j
	addi $s4, $s4, -1	#s4 = i-1
	
	move $a0, $s0		#a0 = map
	move $a1, $s4		#a1 = i
	move $a2, $s5		#a2 = j
	jal get_cell
	
	move $t4, $v0		#t4 = gotten cell
	li $t5, 174
	bne $t4, $t5, check_d
	
	#change cell to visited
	move $a0, $s0		#a0 = map
	move $a1, $s4		#a1 = i'
	move $a2, $s5		#a2 = j'
	addi $t4, $t4, -128	#visited
	move $a3, $t4
	jal set_cell
	
	#set to visited in visited matrix
	move $a0, $s3		#a0 = visited matrix
	move $a1, $s4		#a1 = i'
	move $a2, $s5		#a2 = j'
	li $a3, 1		#a3 = 1				
	jal set_cell
	
	addi $sp, $sp, -8
	sw $s4, 0($sp)
	sw $s5, 4($sp)
	
	#DOWN:(i+1,j)
	check_d:
	move $s4, $s1		#s4 = i
	move $s5, $s2		#s5 = j
	addi $s4, $s4, 1	#s4 = i+1
	
	move $a0, $s0		#a0 = map
	move $a1, $s4		#a1 = i'	
	move $a2, $s5		#a2 = j'
	jal get_cell
	
	move $t4, $v0		#t4 = gotten cell
	li $t5, 174
	bne $t4, $t5, check_l
	
	#change cell to visited
	move $a0, $s0		#a0 = map
	move $a1, $s4		#a1 = i'
	move $a2, $s5		#a2 = j'
	addi $t4, $t4, -128	#visited
	move $a3, $t4
	jal set_cell
	
	#set to visited in visited matrix
	move $a0, $s3		#a0 = visited matrix
	move $a1, $s4		#a1 = i'
	move $a2, $s5		#a2 = j'
	li $a3, 1		#a3 = 1				
	jal set_cell
	
	addi $sp, $sp, -8
	sw $s4, 0($sp)
	sw $s5, 4($sp)
	
	#LEFT:(i,j-1)
	check_l:
	move $s4, $s1		#s4 = i
	move $s5, $s2		#s5 = j
	addi $s5, $s5, -1	#s5 = j-1
	
	move $a0, $s0		#a0 = map
	move $a1, $s4		#a1 = i'	
	move $a2, $s5		#a2 = j'
	jal get_cell
	
	move $t4, $v0		#t4 = gotten cell
	li $t5, 174
	bne $t4, $t5, check_r
	
	#change cell to visited
	move $a0, $s0		#a0 = map
	move $a1, $s4		#a1 = i'
	move $a2, $s5		#a2 = j'
	addi $t4, $t4, -128	#visited
	move $a3, $t4
	jal set_cell
	
	#set to visited in visited matrix
	move $a0, $s3		#a0 = visited matrix
	move $a1, $s4		#a1 = i'
	move $a2, $s5		#a2 = j'
	li $a3, 1		#a3 = 1				
	jal set_cell
	
	addi $sp, $sp, -8
	sw $s4, 0($sp)
	sw $s5, 4($sp)
	
	#RIGHT:(i,j+1)
	check_r:
	move $s4, $s1		#s4 = i
	move $s5, $s2		#s5 = j
	addi $s5, $s5, 1	#s5 = j+1
	
	move $a0, $s0		#a0 = map
	move $a1, $s4		#a1 = i'	
	move $a2, $s5		#a2 = j'
	jal get_cell
	
	move $t4, $v0		#t4 = gotten cell
	li $t5, 174
	bne $t4, $t5, while_loop2
	
	#change cell to visited
	move $a0, $s0		#a0 = map
	move $a1, $s4		#a1 = i'
	move $a2, $s5		#a2 = j'
	addi $t4, $t4, -128	#visited
	move $a3, $t4
	jal set_cell
	
	#set to visited in visited matrix
	move $a0, $s3		#a0 = visited matrix
	move $a1, $s4		#a1 = i'
	move $a2, $s5		#a2 = j'
	li $a3, 1		#a3 = 1				
	jal set_cell
	
	while_loop2:
	addi $sp, $sp, -8
	sw $s4, 0($sp)
	sw $s5, 4($sp)
	
	j while_loop
	
	
while_loop_done:
li $v0, 0
return_pt11:

lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
lw $s5, 24($sp)
lw $fp, 28($sp)
addi $sp, $sp, 32
jr $ra

#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################
