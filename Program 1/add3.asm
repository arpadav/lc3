; Arpad Voros
; November 6th, 2018
; Adds every 3rd number INCLUSIVELY between 2 inputs
; --- therefore if input is 3 and 6, it will add 3 and 6 (=9)
; --- if input is 2 and 9, it will add 2, 5, and 8 (=15)
; --- if input is 10 and 11, it will just be 10
; --- largest sum (i think) is 0 to 99 = 1683

	.ORIG x3000
	BR FIRST
	
; MAIN/FUNDAMENTAL FUNCTIONS. One router (GONEXT) with a bunch of arithmetic functions	

GONEXT
	ADD R0, R2, #0		; DEPENDS on R2 (phase of program), acts as ROUTER
	BRz SECOND			; break to second prompt
	ADD R0, R2, #-1
	BRz VALID1			; validifies length and size of first number
	ADD R0, R2, #-2
	BRz VALID2			; validifies length and size of second number
	ADD R0, R2, #-3	
	BRz PREPARECONV1	; prepare to convert first number
	ADD R0, R2, #-4
	BRz PREPARECONV2	; prepare to convert second number
	ADD R0, R2, #-5
	BRz CHECKSERROR		; checks for size error (if INPUT2 is less than INPUT1)
	ADD R0, R2, #-6
	BRz CLEAR1			; 1st stage clearing
	ADD R0, R2, #-7
	BRz CLEAR2			; 2nd stage clearing
	ADD R0, R2, #-8
	BRz CLEAR3			; 3rd stage clearing
	HALT

GETCHECK
	GETC
	ADD R3, R0, #0		; temporarily stores character into R3
	OUT					; prints out character regardless of what it is
	ADD R0, R3, #-10	; goes to next part of program if ENTER is pressed
	BRz GONEXT
	LD R4, NEG30
	ADD R0, R3, R4		; checks if hex value < #0
	BRn GETCHECK		; if below, gets next character without storing it
	LD R4, ABV9
	ADD R0, R3, R4		; checks if hex value > #9
	BRp GETCHECK		; if above, gets next character without storing it
	STR R3, R1, #0		; stores input char (r3) into r1 (loaded @ INPUT(1 or 2))
    ADD R1, R1, #1      ; increment R1, new location for storage
    BR GETCHECK      	; will iterate thru prompt if not new line
	
CHECKLENGTH
	LDR R0, R1, #0		; load R1 (address of either input) into R0
	BRz CHECKLERROR		; if R0 is 0 (end of string), break
	ADD R3, R3, #1		; R3 is length (incremented when not end of string)
	ADD R1, R1, #1		; Add 1 to address (next character)
	BR CHECKLENGTH		; repeat
	
CONVERT
	ADD R5, R5, R4		; add first digit (R4) to second digit (R5) 
	ADD R3, R3, #-1		; decrement R3 counter (set to 10 because base 10)
	BRp CONVERT			; repeat until you have added the first digit (in 10's place) 10 times to the second digit (in 1's place)
	STR R5, R1, #0		; store that value into R1 (address for NUM1 or NUM2)
	ADD R2, R2, #1		; increment phase
	BR GONEXT

CONVERTONE
	STR R4, R1, #0
	ADD R2, R2, #1
	BR GONEXT
	
ADD3
	ADD R3, R3, #3		; add first number and 3 (used as counter (next number to add in sequence), if R3 < NUM2)
	ADD R1, R1, R3		; add first number to R3 counter (used as SUM)
	ADD R0, R3, R5
	BRnz ADD3			; iterate thru until you OVERSTEP sum
	NOT R3, R3
	ADD R3, R3, #1		; negate last number in sequence since we OVERSTEPPED
	ADD R1, R1, R3		; add to SUM since we OVERSTEPPED, get actual SUM
	LEA R6, SUM			; get address for SUM
	STR R1, R6, #0		; STORE SUM INTO SUM
	LEA R5, OUTPUT		; store character representation of the SUM into OUTPUT (to be read)
	AND R3, R3, #0
	AND R2, R2, #0		; set stuff equal to 0 for next step
	BR FOURDIGITS		; call 4 digits (largest sum is 0-99 = 1683, therefore 4 characters is max that has to be displayed)
	
PRINTOUTPUT
	LEA R0, OUTPROMPT1	; print OUTPROMPTs with INPUT1, INPUT2, and OUTPUT
	PUTS
	LEA R0, INPUT1
	PUTS
	LEA R0, OUTPROMPT2
	PUTS
	LEA R0, INPUT2
	PUTS
	LEA R0, OUTPROMPT3
	PUTS
	LEA R0, OUTPUT
	PUTS
	BR CLEAR			; clear some memory for next calculation
	
; DUAL FUNCTIONS (one for each member)	

FIRST
	LEA R0, PROMPT1
	PUTS				; prints first prompt
	LEA R1, INPUT1
	AND R2, R2, #0		; R2 is 0 (first phase of program, input 1)
	BR GETCHECK
	
SECOND
	LEA R0, PROMPT2
	PUTS				; prints second prompt
	LEA R1, INPUT2
	ADD R2, R2, #1		; R2 is incremented (second phase of program, input 2)
	BR GETCHECK

VALID1
	AND R3, R3, #0		; resets R3 to 0
	LEA R1, INPUT1
	BRp CHECKLENGTH		; checks length of INPUT1
	
VALID2
	AND R3, R3, #0		; resets R3 to 0
	LEA R1, INPUT2
	BRp CHECKLENGTH		; checks length of INPUT2
	
PREPARECONV1			; prepare to convert INPUT1 to NUM1
	LD R6, NEG30		; load x-30 into R6
	AND R3, R3, #0		
	ADD R3, R3, #10		; R3 = 10, decrimented in conversion (for base 10)
	LEA R1, INPUT1
	LDR R4, R1, #0
	ADD R4, R4, R6		; R4 = first character - x30 ASCII offset
	LDR R5, R1, #1
	LEA R1, NUM1		; store NUM1 address into R1
	ADD R5, R5, #0
	BRz CONVERTONE		; if number is one digit long
	ADD R5, R5, R6		; R5 = second character - x30 ASCII offset
	BR CONVERT
	
PREPARECONV2			; prepare to convert INPUT2 to NUM2
	LD R6, NEG30		; load x-30 into R6
	AND R3, R3, #0
	ADD R3, R3, #10		; R3 = 10, decrimented in conversion (for base 10)
	LEA R1, INPUT2
	LDR R4, R1, #0
	ADD R4, R4, R6		; R4 = first character - x30 ASCII offset
	LDR R5, R1, #1
	LEA R1, NUM2		; store NUM2 address into R1
	ADD R5, R5, #0
	BRz CONVERTONE		; if number is one digit long
	ADD R5, R5, R6		; R5 = second character - x30 ASCII offset
	BR CONVERT
	
; SYNTAX, DISPLAY, AND MEMORY FUNCTIONS	

FOURDIGITS
	LD R0, NEG1000		; add #-1000 to number, if < 0, move to 3 digits. if > 0, repeat to see how many number are in the 1000's place
	ADD R3, R3, #1		; increment counter (how many times #1000 fits into the SUM)
	ADD R1, R1, R0		; add #-1000 to number
	BRzp FOURDIGITS		; repeat if SUM > 1000
	LD R0, POS1000		; load in #1000
	LD R4, POS30		; load in x30 for ASCII offset
	ADD R1, R1, R0		; add back 1000 to SUM since we OVERSTEPPED
	ADD R3, R3, #-1		; decrement counter since we OVERSTEPPED
	BRz THREEDIGITS		; if the counter was 0, there is NO FOURTH DIGIT (in 1000's place, continue to 3 digits)
	ADD R3, R3, R4		; otherwise add ASCII offset to counter (the FOURTH DIGIT IN 1000's place)
	STR R3, R5, #0		; store it into first slot of OUTPUT
	ADD R5, R5, #1		; increment OUTPUT address (first next character storage)
	AND R3, R3, #0		; reset counter
	ADD R2, R2, #1		; add 1 to indicator (to display 0's from now on instead of ignoring them)
	BR THREEDIGITS
	
THREEDIGITS
	LD R0, NEG100		; same as 4DIGITS but with #100 instead of #1000
	ADD R3, R3, #1		; increment counter (how many times #100 fits into the remaining SUM)
	ADD R1, R1, R0
	BRzp THREEDIGITS	; loop through and OVERSTEP to find how many #100's are in remaining SUM
	LD R0, POS100		; load #100 to fix OVERSTEPPING
	LD R4, POS30		; load in x30 for ASCII offset
	ADD R1, R1, R0		; add back #100 since we OVERSTEPPED in loop
	ADD R3, R3, #-1		; decrement counter to fix OVERSTEPPING
	ADD R6, R2, R3		; indicator indicates to skip to TWODIGITS, or display 0 in 100's place
	BRz TWODIGITS		; if indicator is 0, sum is 2DIGITS and will not display 0
	AND R2, R2, #0
	ADD R2, R2, #1		; if indicator was 0 and there is a num in 100's place, set indicator to 1
	ADD R3, R3, R4		; otherwise, ADD ASCII offset to counter (how many times 100 was in remaining SUM)
	STR R3, R5, #0		; store that into next OUTPUT address
	ADD R5, R5, #1		; increment OUTPUT address to store following values
	AND R3, R3, #0		; reset counter
	BR TWODIGITS

TWODIGITS
	ADD R3, R3, #1		; add 1 to counter (how many times 10 is in remaining SUM)
	ADD R1, R1, #-10	; decrement remaining SUM by 10
	BRzp TWODIGITS		; repeat until you find how many times 10 was in remaining SUM
	LD R4, POS30		; load in x30 for ASCII offset
	ADD R1, R1, #10		; add 10 back to remainging sum to fix OVERSTEPPING
	ADD R1, R1, R4		; add ASCII offset to remaining sum (last number in 1's position)
	ADD R3, R3, #-1		; decrement counter to fix OVERSTEPPING
	ADD R6, R2, R3		; indicator indicates to skip to ONEDIGIT, or display 0 in 10's place
	BRz ONEDIGIT
	ADD R3, R3, R4		; add ASCII offset to counter to get second to last number (in 10's position)
	STR R3, R5, #0		; store 10's position number
	ADD R5, R5, #1		; increment OUTPUT address to store following value
	BR ONEDIGIT
	
ONEDIGIT
	STR R1, R5, #0		; store 1's position number
	BR PRINTOUTPUT
	
CHECKLERROR
	ADD R2, R2, #1		; increment R2 for next phase
	ADD R3, R3, #-2 	; checks if number too many digits (>2)
	BRp CALLERROR		; if the length is >2, calls error, ends program
	BRnz GONEXT			; otherwise (if length <= 2), go next
	
CHECKSERROR
	LD R6, NUM1			; load contents of NUM1 into R6
	LD R1, NUM2			; load contents of NUM2 into R1
	NOT R6, R6
	ADD R6, R6, #1		; 2sc R6
	ADD R1, R1, R6		; add it to R1 (NUM2 - NUM1)
	BRn CALLERROR		; if negative, invalid input
	AND R1, R1, #0		; otherwise, get ready for ADD3
	AND R5, R5, #0
	LD R3, NUM1			; store first number (NUM1) into R3
	ADD R1, R1, R3		; store first number (NUM1) into R1
	LD R4, NUM2			; store second number (NUM2) into R4
	NOT R5, R4
	ADD R5, R5, #1		; store NEGATIVE second number (-NUM2) into R5
	BR ADD3				; call ADD3
	
CALLERROR
	LEA R0, ERRORSTR	; prints error message
	PUTS
	BR CLEAR			; clears some memory
	
CLEAR
	LEA R1, NUM1
	AND R2, R2, #0
	ADD R2, R2, #6		; phase changes to 6 here (can be called early thats why its not R2 += 1)
	AND R5, R5, #0
	AND R6, R6, #0
	STR R5, R1, #0		; clears NUM1
	STR R5, R1, #1		; clears NUM2
	STR R5, R1, #2		; clears SUM
	AND R1, R1, #0
	BR GONEXT

CLEAR1
	LEA R3, INPUT1		; set to clear mem of INPUT1
	BR CLEARSUM
	
CLEAR2 
	LEA R3, INPUT2		; set to clear mem of INPUT2
	BR CLEARSUM

CLEAR3
	LEA R3, OUTPUT		; set to clear mem of OUTPUT
	BR CLEARSUM
	
CLEARSUM
	STR R5, R3, #0		; iterates thru a memory location 8 addresses long and clears it
	ADD R3, R3, #1
	ADD R1, R1, #1
	ADD R0, R1, #-8
	BRn CLEARSUM
	AND R1, R1, #0
	ADD R2, R2, #1		; increments phase
	BR GONEXT
	
NEG30		.FILL #-48
ABV9		.FILL #-57

PROMPT1		.STRINGZ "\nEnter Start Number > "
PROMPT2		.STRINGZ "Enter End Number > "
OUTPROMPT2	.STRINGZ " and "
OUTPROMPT3	.STRINGZ " is "

INPUT1 		.BLKW #8
INPUT2		.BLKW #8

POS30 		.FILL #48
POS100		.FILL #100
POS1000		.FILL #1000
NEG100		.FILL #-100
NEG1000		.FILL #-1000

NUM1		.BLKW #1
NUM2		.BLKW #1
SUM			.BLKW #1

OUTPUT		.BLKW #8

ERRORSTR 	.STRINGZ "ERROR! Invalid Entry!"
OUTPROMPT1	.STRINGZ "The sum of every third number between "

.END
