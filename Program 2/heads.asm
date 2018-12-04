; Arpad Voros
; ECE 109 Program 2 / HEADS
; November 20th, 2018
; 
; moves a block, loaded in by head.obj around using WASD controls
; changes colours by pressing RYGB + space of block
; stays within bounds of LC3 display
; press Q to quit
; all inputs should be lowercase

	.ORIG x3000
	
INIT
	LD R0, STRPOS			; load in starting position
	ST R0, POSITION			; set current position to starting position
	
	AND R6, R6, #0			; set indicator (for painter) to 0
	BR PREPREPAINT			; prepare repaint
	
USERINPUT
	GETC					; gets character into R0
	
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
	LD R3, WHITEOFFSET		; load in WHITEOFFSET to skip over white (x7FFF) blocks
	BR COLOURLOOP			; continue to colourloop to change all non-white (x7FFF) colours
	
RED			.FILL x7C00		; colour for RED
	
TURNBLUE
	LD R1, TOPLT			; load in first position of block colours (x5000)
	LD R2, BLUE				; set new colour to BLUE
	LD R3, WHITEOFFSET		; load in WHITEOFFSET to skip over white (x7FFF) blocks
	BR COLOURLOOP			; continue to colourloop to change all non-white (x7FFF) colours
	
BLUE		.FILL x001F		; colour for BLUE

TURNGREEN
	LD R1, TOPLT			; load in first position of block colours (x5000)
	LD R2, GREEN			; set new colour to GREEN
	LD R3, WHITEOFFSET		; load in WHITEOFFSET to skip over white (x7FFF) blocks
	BR COLOURLOOP			; continue to colourloop to change all non-white (x7FFF) colours
	
GREEN		.FILL x03E0		; colour for GREEN

TURNYELLOW
	LD R1, TOPLT			; load in first position of block colours (x5000)
	LD R2, YELLOW			; set new colour to YELLOW
	LD R3, WHITEOFFSET		; load in WHITEOFFSET to skip over white (x7FFF) blocks
	BR COLOURLOOP			; continue to colourloop to change all non-white (x7FFF) colours
	
YELLOW		.FILL x7FED		; colour for YELLOW

TURNWHITE
	LD R1, TOPLT			; load in first position of block colours (x5000)
	LD R2, WHITE			; set new colour to WHITE
	LD R3, WHITEOFFSET		; load in WHITEOFFSET to skip over white (x7FFF) blocks
	BR COLOURLOOP			; continue to colourloop to change all non-white (x7FFF) colours
	
WHITE		.FILL xFFFF		; colour for white (NOT x7FFF white). It is not the same so that the 'face' pattern of the block will not be changedby WHITEOFFSET
WHITEOFFSET	.FILL x8001		; x8001 is -x7FFF, is used to skip over x7FFF white. anything NOT x7FFF white will be changed on block
	
QUIT
	AND R6, R6, #0			; change R6 (indicator) to 1, meaning time to clear the block
	ADD R6, R6, #1
	ST R6, QUITTING			; also store 1 into QUITTING to indicate its time to end program
	
	BR PREPREPAINT			; prepare repaint
	
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
	LD R0, TOPLT			; index of TOPLEFT (from head.obj), aka colour address
	LD R1, FIRSTPIX			; address of very first pixel in LC3 display
	LD R2, POSITION			; position of block (this is used to calculate whether block is within display or not)
	ADD R3, R1, R2			; adds position to the very first pixel to get TRUE position
	AND R4, R4, #0			; creates counter, used to paint each line
	
	BR REPAINT

POSITION	.BLKW #1		; position value
STRPOS		.FILL x1F40		; starting position value
FIRSTPIX	.FILL xC000		; address of first pixel 
TOPLT		.FILL x5000		; colour address beginning
	
REPAINT
	ADD R6, R6, #0			
	BRz BLOCK				; if it is in BLOCK mode (r6 = 0)
	BR RESET				; if it is in RESET mode (r6 = 1)
	
BLOCK
	LDR R1, R0, #0			; loads in colour value of the block 
	BRz USERINPUT			; if reached the end of the block, get new input
	BRnp PAINT				; otherwise, paint the pixel
	
RESET
	LD R5, QUITTING			; checks if QUITTING = TRUE
	ADD R5, R5, #-1
	BRz TOCONCLUDE			; if QUITTING = TRUE, change destination once block is finished being painted black

	LDR R1, R0, #0			
	ADD R6, R1, #0			; changes r6, if end of clearing (R1 = x0000, end of 'string'), preps to paint in BLOCK mode
	BRz CHANGEPOS			; goes to change position (since block at current position is cleared, so now position is updated and painted in BLOCK mode)
	
TOCONCLUDE
	LDR R1, R0, #0			
	ADD R6, R1, #0			; changes r6, if end of clearing (R1 = x0000, end of 'string')
	BRz CONCLUDE 			; if end of clearing, conclude the end of program (since in this case QUITTING = TRUE)
	
							; otherwise, (not end of clearing)
	AND R1, R1, #0			; the colour value is 0, or x0000, or black
	BR PAINT				; paint the pixel
	
PAINT
	ADD R5, R4, #-8			; checks if new line needs to be painted
	BRz NXTLINE				; if needs new line, break away to change TRUE position, otherwise continue below
	
CONTPAINT
	STR R1, R3, #0			; stores colour value into TRUE position
	
	ADD R0, R0, #1			; increments colour address
	ADD R3, R3, #1			; increments TRUE position
	ADD R4, R4, #1			; increments counter
	BR REPAINT
	
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
	
CONCLUDE					; resets some stuff so when ran again, runs normally
	LD R0, STRPOS			; changes POSITION to starting position
	ST R0, POSITION
	
	AND R1, R1, #0
	ST R1, QUITTING			; QUITTING = FALSE
	HALT					; halts program

.END