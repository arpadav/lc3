; Arpad Voros
; physics bouncing ball because I am bored

	.ORIG x3000
	BR INIT
	
; strings because they are long
BALLSIZEPRMPT	.STRINGZ "Enter the radius of your ball (in pixels, 1-60): "

INIT
	LD R0, TINT
	STI R0, TMI
	
	JSR FINDDIVISOR
	
	AND R0, R0, #0
	ADD R0, R0, #1
	ST R0, CLEARING
	JSR DISPBALL
	JSR RESETBALL
	
	JSR CLEARINPUT
	
	BR SETSTATS
	
FINDDIVISOR
	LD R0, ONESEC
	NOT R0, R0
	ADD R0, R0, #1
	
	LD R1, TINT
	AND R2, R2, #0
	AND R3, R3, #0
FDLOOP
	ADD R3, R3, #1
	ADD R2, R2, R1
	ADD R4, R2, R0
	BRn FDLOOP
FDRET
	ST R3, DIVISOR
	RET
	
CLEARINPUT
	LEA R0, INPUT
	AND R3, R3, #0
CILOOP
	LDR R1, R0, #0
	BRz CIRET
	STR R3, R0, #0
	ADD R0, R0, #1
	BR CILOOP
CIRET
	RET
	
; timing
TIMELOOP
	LDI R0, TMR
	BRzp TIMELOOP
	BR BALLUPDATE

SETSTATS
	LEA R0, BALLSIZEPRMPT
	PUTS
	LEA R1, INPUT
	BR GETTINGNUM
	
GETTINGNUM
	GETC
	ADD R3, R0, #0		; temporarily stores character into R3
	ADD R0, R3, #-10	; goes to next part of program if ENTER is pressed
	BRz CONVINPUT
	
	LD R4, ABV9
	ADD R0, R3, R4		; checks if hex value > #9
	BRp GETTINGNUM		; if above, gets next character without storing it
	
	LD R4, NEG30
	ADD R0, R3, R4		; checks if hex value < #0
	BRn GETTINGNUM		; if below, gets next character without storing it
	
	ADD R0, R3, #0
	OUT
	
	STR R3, R1, #0		; stores input char (r3) into r1
	
    ADD R1, R1, #1      ; increment R1, new location for storage
	LDR R0, R1, #0
	BRnp CONVINPUT
	
    BR GETTINGNUM      	; will iterate thru prompt if not new line
	

TMR				.FILL xFE08
TMI				.FILL xFE0A
ONESEC			.FILL #10000		; one second in milliseconds
TINT			.FILL #10		; time interval (in milliseconds)
DELTAT			.BLKW #1
DIVISOR			.BLKW #1

KBSRPtr			.FILL xFE00		; using I/O, keyboard status register
KBDRPtr			.FILL xFE02		; using I/O, keyboard data register

; other
INPUT			.BLKW x0010
CLEARING		.FILL #0
NEG30			.FILL #-48
ABV9			.FILL #-57
MAXRAD			.FILL #-60
NEWLINE			.STRINGZ "\n"
	
CONVINPUT
	LEA R1, INPUT
	LDR R6, R1, #0
	BRz RADINERROR
	
	ADD R1, R1, #-1
	AND R6, R6, #0
CINLOOP
	ADD R6, R6, #1
	ADD R1, R1, #1
	LDR R0, R1, #0
	BRnp CINLOOP
	
	LEA R1, INPUT
	LEA R0, NEWLINE
	PUTS
	
	LDR R0, R1, #0		; load in 10's digit
	AND R4, R4, #0
	AND R3, R3, #0
	ADD R3, R3, #10
	
	LD R2, NEG30
	ADD R0, R0, R2		; take away ascii offset
	
	ADD R5, R6, #-2		; -2 because overcounted by 1
	BRz CONTCONV		; length of input is 1
	
CONV10SLOOP
	ADD R4, R4, R0 
	ADD R3, R3, #-1
	BRz CONTCONV
	BR CONV10SLOOP
	ADD R1, R1, #1
CONTCONV
	LDR R3, R1, #0		; load in 1's digit
	ADD R4, R4, R3		; add to sum
	ADD R4, R4, R2		; take away ascii offset again
	BRz RADINERROR
	
	LD R2, MAXRAD
	ADD R0, R4, R2
	BRp RADINERROR
	
	ST R4, BALLRADIUS
	BR CALCBALLCOORDS
	
RADINERROR
	LEA R0, MRERRORMSG
	PUTS
	AND R0, R0, #0
	ADD R0, R0, #12
	ST R0, BALLRADIUS
	
	BR CALCBALLCOORDS

MRERRORMSG		.STRINGZ "Radius must be between 1-60. Default radius set to 12.\n"

TOTIMELOOP
	BR TIMELOOP

LEAVETODISPBALL
	JSR DISPBALL
	LEA R0, DONELOADING
	PUTS
ENTERTOCONT
	GETC
	ADD R2, R0, #-10
	BRnp ENTERTOCONT
	BR TIMELOOP
	
; BALL methods
BALLUPDATE
	JSR CHECKLR
	
	LD R0, DELTAT
	LD R1, TINT
	ADD R0, R0, R1
	ST R0, DELTAT
	
	LD R1, GRAVITY
	JSR MULTR1BYR0
	
	ADD R6, R1, #0
	LD R2, ONESEC
	NOT R2, R2
	ADD R2, R2, #1
	AND R4, R4, #0
CALCV
	ADD R4, R4, #1
	ADD R6, R6, R2
	BRp CALCV
	ADD R1, R4, #0
	
	LD R0, LINEOFFSET
	JSR MULTR1BYR0
	LD R2, BALLV
	ADD R2, R2, R1
	ST R2, BALLV
	ADD R6, R2, #0
	
	LD R2, LASTPIX
	LD R3, BOTBOUND
	AND R2, R2, R3
	LD R3, BOTLINENEG
	ADD R2, R2, R3
	BRzp IFBALLBOUNCE	
BUCONT
	AND R0, R0, #0
	ADD R0, R0, #1
	ST R0, CLEARING
	JSR DISPBALL
	
	LD R2, BALLADRSCRDS
BULOOP
	LDR R3, R2, #0
	BRz BUEND
	ADD R3, R3, R6
	STR R3, R2, #0
	ADD R2, R2, #1
	BR BULOOP
BUEND
	JSR DISPBALL
	BR TOTIMELOOP

CHECKLR
	; LDI R0, KBSRPtr			; gets status into R0
	; BRn CHECKRET
	LDI R0, KBDRPtr			; load in character pressed into R0
	LD R1, ASCIIA
	ADD R0, R0, R1
	BRz GOLEFT
	LD R1, ASCIID
	ADD R0, R0, R1
	BRz GORIGHT
	RET
GOLEFT
	LD R0, BALLV
	ADD R0, R0, #-1
	ST R0, BALLV
	AND R0, R0, #0
	STI R0, KBDRPtr
	RET
GORIGHT
	LD R0, BALLV
	ADD R0, R0, #1
	ST R0, BALLV
	AND R0, R0, #0
	STI R0, KBDRPtr
	RET
CHECKRET
	RET
	
IFBALLBOUNCE
	LD R0, BOUNCING
	BRz BALLBOUNCE
	AND R0, R0, #0
	ST R0, BOUNCING
	BR BUCONT
	
RESETBALL
	LD R6, BALLADRSCRDS
RBLOOP
	AND R1, R1, #0
	LDR R0, R6, #0
	BRz RBRET
	STR R1, R6, #0
	ADD R6, R6, #1
	BR RBLOOP
RBRET
	RET

DISPBALL
	LD R1, BALLADRSCRDS
	LD R2, CLEARING
	BRz NORMCOLOUR
	AND R2, R2, #0
	ST R2, CLEARING
	BR CONTDB
NORMCOLOUR
	LD R2, BALLCOLOUR
CONTDB
	LD R3, DISPOFFSET
DBLOOP
	LDR R0, R1, #0
	BRz DBRET
	ADD R0, R0, R3
	STR R2, R0, #0
	ADD R1, R1, #1
	BR DBLOOP
DBRET
	ADD R1, R1, #-1
	LDR R0, R1, #0
	ST R0, LASTPIX
	RET
	
BALLBOUNCE
	LD R0, BALLV
	NOT R0, R0
	ADD R0, R0, #1
	ST R0, BALLV
	
	AND R1, R1, #0
	ST R1, DELTAT
	
	ADD R1, R1, #1
	ST R1, BOUNCING
	
	BR BALLUPDATE

ENDBOUNCE
	AND R0, R0, #0
	ST R0, BALLV
	
	AND R1, R1, #0
	ST R1, DELTAT
	
	ST R1, BOUNCING
	BR BALLUPDATE

; BALL stats
BALLADRSCRDS	.FILL x5000		; address where painted ball pixels are stored
BALLINITX		.FILL #64		; starting x position. #64 for center
BALLINITY		.FILL #50		; starting y position (+y = up and -y = down) #61 for center
BALLPOS			.BLKW #1		; balls position used in painting
BALLRADIUS		.FILL #12		; ball radius
BALLCOLOUR		.FILL x001F		; ball colour = blue
BALLELASTICITY	.FILL #0		; negative = bouncing will fade. 0 = constant bouncing. positive = bouncing increases (dont use positive...)
BALLV			.FILL x0001		; ft/s, initially down1
GRAVITY			.FILL #5		; 40 ft/second^2. 1ft = 1 pixel (pos = downward and neg = upward ikik)
BOUNCING		.BLKW #1		; 1 if bouncing, 0 if not bouncing

ASCIIA			.FILL xFF9F
ASCIID			.FILL xFF9C
	
; math and calculations
CALCBALLCOORDS
	JSR CLEARINPUT
	
	LEA R0, LOADINGBALL
	PUTS
	
	LD R0, LINEOFFSET
	LD R1, BALLINITY
	LD R2, BOTOFFSET
	NOT R4, R1					; inverting R1 and adding to BOTOFFSET (+1 already included)
	ADD R1, R4, R2				; finding true y coordinate of ball
	JSR MULTR1BYR0
	
	LD R2, BALLINITX
	
	ADD R3, R1, R2
	ST R3, BALLPOS
	BR PREPCALCBALLBOUNDS
	
PREPCALCBALLBOUNDS
	LD R0, BALLRADIUS
	ST R0, YCALC
	
	LD R1, LINEOFFSET
	NOT R1, R1
	ADD R1, R1, #1
	JSR MULTR1BYR0
	ADD R3, R3, R1
	
	LD R0, BALLRADIUS
	NOT R0, R0
	ADD R0, R0, #1
	ST R0, XCALC				; starting topleft pixel of the ball (-r, r)
	ADD R3, R3, R0				; getting initial position of pixel being checked
	
	LD R6, BALLADRSCRDS			; loading x5000 into R6
	
	BR CALCBALLBOUNDS
	
CALCBALLBOUNDS					; x^2 + y^2 <= r^2
	LD R1, XCALC
	JSR ABSR1					; R1 = |R1|
	ADD R0, R1, #0
	JSR MULTR1BYR0				; R1 = R1^2
	ADD R4, R1, #0				; store in R4 for a bit (x^2 part of eq)
	
	LD R1, YCALC
	JSR ABSR1					; R1 = |R1|
	ADD R0, R1, #0
	JSR MULTR1BYR0				; R1 = R1^2
	ADD R4, R1, R4				; R4 = x^2 + y^2
	
	LD R0, BALLRADIUS
	ADD R1, R0, #0
	JSR MULTR1BYR0				; R1 = r^2
	
	NOT R1, R1
	ADD R1, R1, #1				; R1 = -(r^2)
	
	ADD R1, R1, R4
	BRzp NEXTBALLBOUNDS			; n = outside circle. z = everything BUT circle edge. p = inside circle
	
	STR R3, R6, #0				; store the address into BALLADRSCRDS address
	ADD R6, R6, #1				; increment to store into next address
	BR NEXTBALLBOUNDS
	
NEXTBALLBOUNDS
	LD R0, XCALC	
	LD R1, BALLRADIUS
	NOT R1, R1
	ADD R1, R1, #1
	ADD R2, R0, R1				; check if x position is too far right. if so, set to -r and decrement ycalc
	BRz NXTLINEBND
	
	ADD R0, R0, #1				; increment x position
	ADD R3, R3, #1				; increment x in pixel being checked (r3) as well as XCALC
	ST R0, XCALC
	BR CALCBALLBOUNDS
	
NXTLINEBND
	ST R1, XCALC				; R1 = -r
	
	ADD R3, R3, R1
	ADD R3, R3, R1				; moving pixel being checked (r3) back 2r
	LD R4, LINEOFFSET
	ADD R3, R3, R4				; moving pixel being checked (r3) down one line
	
	LD R0, YCALC
	ADD R0, R0, #-1
	
	NOT R1, R1
	ADD R1, R1, #1
	
	ADD R2, R0, R1
	BRn LEAVETODISPBALL
	
	ST R0, YCALC
	BR CALCBALLBOUNDS
	
	
; I wanted to use peasant multiplication but a bitshift right seems too difficult for lc3
; R0 MUST BE POSITIVE
MULTR1BYR0						; multiplication function. multiplies R1 by R0. Uses R2 as placeholder. Puts result into R1
	ADD R2, R1, #0
	BRz MULTRET
MULTLOOP
	ADD R0, R0, #-1				; R0 acts as counter. MUST be positive
	BRz MULTRET
	ADD R1, R1, R2
	BR MULTLOOP
MULTERROR
	LEA R0, MULTERRORMSG
	PUTS
	HALT
MULTRET
	RET
	
; absolute value of R1, stored in R1 (R1 = |R1|)
ABSR1
	ADD R1, R1, #0
	BRzp A1RET
	NOT R1, R1
	ADD R1, R1, #1
A1RET
	RET
	
; LC3 stats
DISPOFFSET		.FILL xC000
LINEOFFSET		.FILL x0080
BOTOFFSET		.FILL #124
BOTBOUND		.FILL xFF00
BOTLINENEG		.FILL xC300
LASTPIX			.BLKW #1

; math and calculations stats
XCALC			.BLKW #1
YCALC			.BLKW #1

; more strings
LOADINGBALL		.STRINGZ "Calculating ball... Loading...\n"
DONELOADING		.STRINGZ "Press 'enter' to continue.\n"
MULTERRORMSG	.STRINGZ "ERROR: R0 is negative when MULTR1BYR0 is called.\n"
	
.END