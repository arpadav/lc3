; Arpad Voros
; ECE 109 Program 3 / WORM
; November 29th, 2018
; 
; moves a block with trail, loaded in by worm_head.obj around using WASD controls
; changes colours by pressing RYGB + space of block
; stays within bounds of LC3 display
; a bug appears on the screen, colour loaded in by bug_head.obj and locations by bug_locs.obj
; if any of the pixels from the worm head overlap with the bug, the bug is "eaten"
; when the bug is eaten, the trail is cleared and a new bug appears on the screen
; press Q to quit and restart showing bugs
; all inputs must be lowercase

	.ORIG x3000
	
INIT
	LD R0, STRPOS			; load in starting position
	ST R0, POSITION			; set current position to starting position
	
	LDI R1, TOPLT
	ST R1, CCOLOUR			; set current colour to 
	
	AND R6, R6, #0			; set indicator (for painter) to 0
	ADD R5, R6, #1			; set bug indicator (if 1, bug is painting. if 0, block is painting)
	ST R5, BUGSTATUS
	
	BR GETNEWBUG			; prepare paint bug
	
KBSRPtr		.FILL xFE00		; using I/O, keyboard status register
KBDRPtr		.FILL xFE02		; using I/O, keyboard data register
	
USERINPUT
	LD R6, BUGSTATUS		; if bug status is 1, its time to paint block now
	ADD R6, R6, #-1			; set indicator (for painter) to 0 if bugstatus is 1
	BRz PREPREPAINT			; prepare repainting of block
	
	JSR CHECKCOLLISION		; sub routine: check if there has been a collision (bug is eaten)
	
GETTINGC					; same as GETC but with I/O
	LDI R0, KBSRPtr			; gets status into R0
	BRzp GETTINGC
	LDI R0, KBDRPtr			; once status is ready, gets character into R0
	
	LD R1, ASCIIW			; checks if 'w' has been pressed
	JSR CHECK
	BRz MOVEUP				; if so, move up
	
	LD R1, ASCIIA			; checks if 'a' has been pressed
	JSR CHECK
	BRz MOVELT				; if so, move left
	
	LD R1, ASCIIS			; checks if 's' has been pressed
	JSR CHECK
	BRz MOVEDN				; if so, move down
	
	LD R1, ASCIID			; checks if 'd' has been pressed
	JSR CHECK
	BRz MOVERT				; if so, move right
	
	LD R1, ASCIIR			; checks if 'r' has been pressed
	JSR CHECK
	BRz TURNRED				; if so, turn the block red

	LD R1, ASCIIG			; checks if 'g' has been pressed
	JSR CHECK
	BRz TURNGREEN			; if so, turn the block green
	
	LD R1, ASCIIB			; checks if 'b' has been pressed
	JSR CHECK
	BRz TURNBLUE			; if so, turn the block blue
	
	LD R1, ASCIIY			; checks if 'y' has been pressed
	JSR CHECK
	BRz TURNYELLOW			; if so, turn the block yellow
	
	LD R1, SPACE			; checks if ' ' has been pressed (space bar)
	JSR CHECK
	BRz TURNWHITE			; if so, turn the block white
	
	LD R1, ASCIIQ			; checks if 'q' has been pressed
	JSR CHECK
	BRz QUIT				; if so, quit the program (halt)
	
	BR USERINPUT			; if none are pressed, ignore and get a new character
	
ASCIIW		.FILL x0077		; ascii code for w
ASCIIA		.FILL x0061		; ascii code for a
ASCIIS		.FILL x0073		; ascii code for s
ASCIID		.FILL x0064		; ascii code for d

ASCIIR		.FILL x0072		; ascii code for r
ASCIIG		.FILL x0067		; ascii code for g
ASCIIB		.FILL x0062		; ascii code for b
ASCIIY		.FILL x0079		; ascii code for y
SPACE		.FILL x0020		; ascii code for space

ASCIIQ		.FILL x0071		; ascii code for q

CHECK
	NOT R1, R1				; inverts the ASCII code for button pressed
	ADD R1, R1, #1
	ADD R2, R0, R1			; adds to R0 (input character)
	RET						; returns to see if a command needs to be executed

CHECKCOLLISION				; checks if there has been a collision with the bug (bug is eaten)
	LD R0, COLLISION		; load in hit box of the bug
	LD R1, POSITION			; load in position of worm_head
	LD R4, FIRSTPIX			; xC000 offset for position
CHECKLOOP
	LDR R2, R0, #0			; load in pixel of hitbox
	BRz RETURNCHECK			; if x0000, end of hitbox reached, return to previous statement
	NOT R2, R2
	ADD R2, R2, #1			; invert value of hitbox pixel
	ADD R3, R1, R2			; add to position of worm_head
	BRz CLEARSCREEN			; if they equal, go to CLEARSCREEN
	ADD R0, R0, #1			; if they do not equal, increment hitbox address and loop through all pixels of hitbox
	BR CHECKLOOP
RETURNCHECK					; return 
	RET
	
MOVEUP
	LD R0, POSITION			; loads in position of the block
	
	LD R2, UPBOUND			; checks if it is within bounds
	ADD R2, R2, R0
	BRn USERINPUT			; if out of bounds, position does not change and nothing is painted
	
	LD R1, VERT				; if within bounds, load in vertical offset
	NOT R1, R1
	ADD R1, R1, #1			; negate vertical offset
	ADD R0, R0, R1
	ST R0, NEXTPOS			; subtract vertical offset from position and store in NEXTPOS

	AND R6, R6, #0
	ADD R6, R6, #1			; set indicator to 1, meaning block is first cleared before painted with NEXTPOS
	BR PREPREPAINT

UPBOUND		.FILL xFC87		; addresses for upper bound range from x0300 to x0378 (with xC000 offset)
							; xFC87 is -x0378, negative of max upper bound position value. 
							; if UPBOUND + POSITION = negative, the block will not move up
MOVELT
	LD R0, POSITION			; loads in position of the block
	
	LD R2, SIDEBOUND		; checks if it is within bounds
	AND R2, R2, R0
	BRz USERINPUT			; if out of bounds, position does not change and nothing is painted
	
	ADD R0, R0, #-8			; if within bounds, move position left by 8 pixels
	ST R0, NEXTPOS			; store in NEXTPOS

	AND R6, R6, #0
	ADD R6, R6, #1			; set indicator to 1, meaning block is first cleared before painted with NEXTPOS
	BR PREPREPAINT
	
SIDEBOUND	.FILL x00FF		; will use 0000000011111111 (x00FF) and will AND with current position
							; addresses for left bound all end in x~~00, (like x0300 and x3700)
							; so if x00FF is ANDed with POSITION and it equals ZERO, position cant move more left
							
							; this is also used for right bound
							; addresses for right bound all end in x~~78, (like x0378 and x3778)
							; so if x00FF is ANDed with POSITION and it equals x0078, position cant move more right

MOVEDN
	LD R0, POSITION			; loads in position of the block
	
	LD R2, DNBOUND			; checks if it is within bounds
	ADD R2, R2, R0
	BRzp USERINPUT			; if out of bounds, position does not change and nothing is painted
	
	LD R1, VERT				; if within bounds, load in vertical offset
	ADD R0, R0, R1
	ST R0, NEXTPOS			; add vertical offset to position and store in NEXTPOS

	AND R6, R6, #0
	ADD R6, R6, #1			; set indicator to 1, meaning block is first cleared before painted with NEXTPOS
	BR PREPREPAINT

DNBOUND		.FILL xC900		; addresses for lower bound range from x3700 to x3778 (with xC000 offset)
							; xC900 is -x3700, negative of min lower bound position value. 
							; if DNBOUND + POSITION = zero or positive, the block will not move down

MOVERT
	LD R0, POSITION			; loads in position of the block
	
	LD R2, SIDEBOUND		; checks if it is within bounds
	LD R3, RTBOUND
	AND R2, R2, R0
	ADD R2, R2, R3
	BRz USERINPUT			; if out of bounds, position does not change and nothing is painted
	
	ADD R0, R0, #8			; if within bounds, move position right by 8 pixels
	ST R0, NEXTPOS			; store in NEXTPOS

	AND R6, R6, #0
	ADD R6, R6, #1			; set indicator to 1, meaning block is first cleared before painted with NEXTPOS
	BR PREPREPAINT

RTBOUND		.FILL xFF88		; xFF88 is equal to -x0078 to check if it is on right bound
							; see comments on SIDEBOUND for more details

NEXTPOS		.BLKW #1		; set 1 address for NEXTPOS
	
TURNRED
	LD R1, TOPLT			; load in first position of block colours (x5000)
	LD R2, RED				; set new colour to RED
	ST R2, CCOLOUR			; load in R2 into current colour
	LD R3, WHITEOFFSET		; load in WHITEOFFSET to skip over white (x7FFF) blocks
	BR COLOURLOOP			; continue to colourloop to change all non-white (x7FFF) colours
	
RED			.FILL x7C00		; colour for RED
	
TURNBLUE
	LD R1, TOPLT			; load in first position of block colours (x5000)
	LD R2, BLUE				; set new colour to BLUE
	ST R2, CCOLOUR			; load in R2 into current colour
	LD R3, WHITEOFFSET		; load in WHITEOFFSET to skip over white (x7FFF) blocks
	BR COLOURLOOP			; continue to colourloop to change all non-white (x7FFF) colours
	
BLUE		.FILL x001F		; colour for BLUE

TURNGREEN
	LD R1, TOPLT			; load in first position of block colours (x5000)
	LD R2, GREEN			; set new colour to GREEN
	ST R2, CCOLOUR			; load in R2 into current colour
	LD R3, WHITEOFFSET		; load in WHITEOFFSET to skip over white (x7FFF) blocks
	BR COLOURLOOP			; continue to colourloop to change all non-white (x7FFF) colours
	
GREEN		.FILL x03E0		; colour for GREEN

TURNYELLOW
	LD R1, TOPLT			; load in first position of block colours (x5000)
	LD R2, YELLOW			; set new colour to YELLOW
	ST R2, CCOLOUR			; load in R2 into current colour
	LD R3, WHITEOFFSET		; load in WHITEOFFSET to skip over white (x7FFF) blocks
	BR COLOURLOOP			; continue to colourloop to change all non-white (x7FFF) colours
	
YELLOW		.FILL x7FED		; colour for YELLOW

TURNWHITE
	LD R1, TOPLT			; load in first position of block colours (x5000)
	LD R2, WHITE			; set new colour to WHITE
	ST R2, CCOLOUR			; load in R2 into current colour
	LD R3, WHITEOFFSET		; load in WHITEOFFSET to skip over white (x7FFF) blocks
	BR COLOURLOOP			; continue to colourloop to change all non-white (x7FFF) colours
	
WHITE		.FILL xFFFF		; colour for white (NOT x7FFF white). It is not the same so that the 'face' pattern of the block will not be changedby WHITEOFFSET
WHITEOFFSET	.FILL x8001		; x8001 is -x7FFF, is used to skip over x7FFF white. anything NOT x7FFF white will be changed on block
	
CCOLOUR		.BLKW #1		; the current colour of the worm head
BUGSTATUS	.BLKW #1		; if bug status is 1, the bug is being painted. if 0, the worm head is being painted

GETNEWBUG
	AND R0, R0, #0			; stores 1 into BUGSTATUS
	ADD R0, R0, #1
	ST R0, BUGSTATUS
	
	LD R0, TOPLTBUGPOS
	LDR R1, R0, #0			; load in x position of the bug
	BRz THELASTBUG			; if 0, the last bug has been painted
	LDR R2, R0, #1			; load in y position of the bug
	BRz THELASTBUG			; if 0, the last bug has been painted
	
	ADD R0, R0, #2			; increment the TOPLTBUGPOS by 2, so u get 2 new coordinates next time
	ST R0, TOPLTBUGPOS
	
	ADD R2, R2, R2
	ADD R2, R2, R2
	ADD R2, R2, R2
	ADD R2, R2, R2
	ADD R2, R2, R2
	ADD R2, R2, R2
	ADD R2, R2, R2			; multiply y by 128
	
	ADD R3, R1, R2			; add x and y coordinates and store into POSITIONBUG
	ST R3, POSITIONBUG
	
	JSR COLLISIONREPORT
	
	BR PREPREPAINTBUG		; go to prep repaint bug

POSITION	.BLKW #1		; position value of worm head
STRPOS		.FILL x1F40		; starting position value
FIRSTPIX	.FILL xC000		; address of first pixel 
TOPLT		.FILL x5000		; colour address beginning of worm head
	
CLEARSCREEN
	AND R1, R1, #0			; R1 is x0000 (black) to be painted with
	LD R3, FIRSTPIX			; load starting pixel into R3
	LD R6, LASTPIXNEG		; load the negative version of last pixel into R6
CLEARLOOP
	ADD R5, R3, R6			; check if you reached end of display
	BRz CHECKCONCLUDE		; if so, check if we are trying to quit the program or paint a new bug
	LDR R5, R3, #0			; if the pixel is black, increment R3 and loop again
	BRz CONTCLEAR
	STR R1, R3, #0			; otherwise store x0000 (black) into the pixel (to clear it)
RETURN
	ADD R5, R3, R6			; check at the end if you need to get a new bug since now the screen is cleared.
	BRz GETNEWBUG
CONTCLEAR
	ADD R3, R3, #1			; increment R3 and loop again
	BR CLEARLOOP
	
CHECKCONCLUDE
	LD R5, QUITTING			; load in QUITTING, if = 1, we are quitting the program, otherwise continue
	ADD R5, R5, #-1
	BRz CONCLUDE
	BRnp RETURN
	
LASTPIXNEG	.FILL x0201		; -xFDFF or x0201
	
QUIT
	AND R6, R6, #0			; change R6 (indicator) to 1, meaning time to clear the block
	ADD R6, R6, #1
	ST R6, QUITTING			; also store 1 into QUITTING to indicate its time to end program
	
	BR CLEARSCREEN			; prepare clear screen
	
QUITTING	.FILL x0000		; quitting variable. if 1, means its time to quit the program
	
COLOURLOOP					; loop is called to change x5000 colours (from head.obj) when rygb + space are pressed
	LDR R4, R1, #0			; load in first colour @ x5000
	ADD R6, R4, #0
	BRz PREPREPAINT			; check if reached the end of 'string' of pixels (from head.obj)
	ADD R6, R3, R4			; if there are more pixels to change colours for, check if the colour is white (x7FFF)
	BRz SKIP				; if it is white (x7FFF), do NOT change colour
	STR R2, R1, #0			; if it is NOT white, change colour to selected colour
SKIP
	ADD R1, R1, #1			; increment position to get next pixel colour
	BR COLOURLOOP			; continue through loop until end of block is reached

PREPREPAINT
	AND R5, R5, #0
	ST R5, BUGSTATUS		; set BUGSTATUS to 0 (since in PREP-REPAINT we are not painting a bug)
	
	LD R0, TOPLT			; index of TOPLEFT (from worm_head.obj), aka colour address of worm head
	LD R1, FIRSTPIX			; address of very first pixel in LC3 display
	LD R2, POSITION			; position of worm_head (this is used to calculate whether block is within display or not)
	ADD R3, R1, R2			; adds position to the very first pixel to get TRUE position
	AND R4, R4, #0			; creates counter, used to paint each line
	
	BR REPAINT

PREPREPAINTBUG
	LD R0, TOPLTBUG			; index of TOPLEFT (from bug_head.obj), aka colour address of bug head
	LD R1, FIRSTPIX			; address of very first pixel in LC3 display
	LD R2, POSITIONBUG		; position of bug_head (this is used to calculate whether block is within display or not)
	ADD R3, R1, R2			; adds position to the very first pixel to get TRUE position
	AND R4, R4, #0			; creates counter, used to paint each line
	AND R6, R6, #0			; R6 = 0 so that we can be painting in BLOCK mode
	
	BR REPAINT

POSITIONBUG	.BLKW #1		; position value of bug
TOPLTBUG	.FILL x5200		; colour address beginning of bug
TOPLTBUGPOS	.FILL x5400		; address of bug coordinates
STPLTBUGPOS	.FILL x5400		; static address of bug coordinates
COLLISION	.FILL x5800		; address of all pixels worm_head POSITION has to be to eat bug
	
REPAINT
	ADD R6, R6, #0			
	BRz BLOCK				; if it is in BLOCK mode (r6 = 0)
	BR RESET				; if it is in RESET mode (r6 = 1)
	
BLOCK
	LDR R1, R0, #0			; loads in colour value of the block 
	BRz USERINPUT			; if reached the end of the block, get new input
	BRnp PAINT				; otherwise, paint the pixel
	
RESET
	LDR R1, R0, #0			
	ADD R6, R1, #0			; changes r6, if end of clearing (R1 = x0000, end of 'string'), preps to paint in BLOCK mode
	BRz CHANGEPOS			; goes to change position (since block at current position is cleared, so now position is updated and painted in BLOCK mode)
	
	LD R5, BUGSTATUS		; if BUGSTATUS = 1, just normally paint the bug, whereas 
	BRp PAINT				; if BUGSTATUS = 0, the trail will be painted in this part
	
	LD R1, CCOLOUR			; reset block with current colour (trail)
	BR PAINT				; paint the pixel
	
PAINT
	ADD R5, R4, #-8			; checks if new line needs to be painted
	BRz NXTLINE				; if needs new line, break away to change TRUE position, otherwise continue below
CONTPAINT
	STR R1, R3, #0			; stores colour value into TRUE position
	
	ADD R0, R0, #1			; increments colour address
	ADD R3, R3, #1			; increments TRUE position
	ADD R4, R4, #1			; increments counter
	
	BR REPAINT				; jump back to REPAINT
	
NXTLINE
	LD R5, NXT				; next line OFFSET
	AND R4, R4, #0			; reset counter
	ADD R3, R3, #-8			; change TRUE position to first pixel of next line
	ADD R3, R3, R5
	BR CONTPAINT			; continue painting

NXT			.FILL x0080		; next line OFFSET
VERT		.FILL x0400		; 8 * next line OFFSET (for vertical movement)
	
CHANGEPOS					; only called after previous block has been cleared
	LD R1, NEXTPOS
	ST R1, POSITION			; store updated position to POSITION, go back to prepare repaint (and R6 will be 0 so its painting in BLOCK mode, not RESET mode)
	BR PREPREPAINT
	
COLLISIONREPORT				; sets up new hitbox coordinates into location COLLISION
	AND R4, R4, #0			; set counter to 0
	LD R0, POSITIONBUG		; get position of the bug
	LD R1, NXT				; load in single line offset
	LD R2, VERT				; load in 8 line offset
	LD R3, COLLISION		; load in address of where values are being stored
	
	NOT R6, R1				; some math to find last pixel of hitbox: (or lower right hand pixel of bug)
	ADD R6, R6, #8			; inverting single line offset, adding 1 (to make negative), and adding 7 (for edge)
	ADD R6, R6, R2			; adding 8 line offset to it
	ADD R6, R6, R0			; adding bug position to it
	NOT R6, R6
	ADD R6, R6, #1			; inverting it. this inverted last pixel value will be used to know when to stop the hitbox loop
	ST R6, ENDCOLLISION
	
	NOT R5, R2				; some math to find first pixel of hitbox: (or 7 pixels to the left of the bugs position, and up 7 rows)
	ADD R5, R5, #-6			; inverting 8 line offset, adding 1 (to make negative), and adding -7 (for edge)
	ADD R5, R5, R1			; adding single line offset (this only makes the hitbox start 7 rows above and 7 pixels to the left of bug position)
	ADD R0, R0, R5			; add offset to bug position, and start loop (where R0 = pixel of the hitbox)
COLLISIONLOOP
	LD R6, ENDCOLLISION		; load in NEGATIVE last pixel of hitbox
	ADD R6, R6, R0			; see if it equals current hitbox pixel
	BRzp RETURNCOLL			; if so, return from subdivision
	ADD R6, R4, #-15		; if not, add -15 to counter (hitbox is 15 pixels wide since both boxes are 8x8 pixels (8 + 8 - 1))
	BRz NEXTLINECOLL		; if counter = 15, go to next line
CONTCOLLISION
	STR R0, R3, #0			; store the hitbox pixel address into R3 (COLLISION + offset)
	ADD R0, R0, #1			; increment hitbox pixel
	ADD R3, R3, #1			; increment storing address
	ADD R4, R4, #1			; increment counter
	BR COLLISIONLOOP		; loop until you reach last pixel of hitbox
NEXTLINECOLL
	AND R4, R4, #0			; set counter to 0
	ADD R0, R0, #-15
	ADD R0, R0, R1			; set hitbox pixel one row down, 15 pixels to the left and return
	BR CONTCOLLISION
RETURNCOLL
	RET						; return from subdivision
	
ENDCOLLISION	.BLKW #1

THELASTBUG					; when the last bug has already been painted
	LD R0, STPLTBUGPOS		; store in the origin address of bug locations so first bug will appear again
	ST R0, TOPLTBUGPOS
	BR GETNEWBUG
	
CONCLUDE					; resets some stuff so when ran again, runs normally
	LD R0, STRPOS			; changes POSITION to starting position
	ST R0, POSITION
	
	LD R0, STPLTBUGPOS		; store in the origin address of bug locations so when you press Q and continue, the first bug will appear again
	ST R0, TOPLTBUGPOS
	
	AND R1, R1, #0
	ST R1, QUITTING			; QUITTING = FALSE
	HALT					; halts program

.END