TITLE randomGen     (random.asm)

; Author: Alexander Hildreth
; CS271            Date: 11/15/14
; Description: Gets a number from user between 10 and 200 and
; generates that many random numbers. Displays them 10 per line.
; Sorts the numbers in decending order, then displays them again
; along with the median value. Finally, prints the array by column.

INCLUDE Irvine32.inc

; (insert constant definitions here)
	MAXVAL	equ		200
	MINVAL	equ		10
	HIVAL	equ		999
	LOVAL	equ		100

.data

;string variables
;***********************************************************************
	intro		BYTE "My name is Alex, and welcome to randomGen!",0
	inst1		BYTE "Enter a number between 10 and 200 and I will",0
	inst2		BYTE "calculate that many random numbers. I will then",0
	inst3		BYTE "display them, sort them in descending order, and",0
	inst4		BYTE "display them again, along with the median number.",0
	prompt		BYTE "Enter a number 10-200: ",0
	space		BYTE " ",0		
	medPrompt	BYTE "The median value is: ",0
	sortTitle	BYTE "The sorted array:",0
	initTitle	BYTE "The unsorted array:",0	
	byColumn	BYTE "Column Ordered- ",0
;***********************************************************************

;numeric variables
;***********************************************************************
	numRand		DWORD	?
	randArr		DWORD	MAXVAL	dup(0)
	lineCount	DWORD	0
	theMedian	DWORD	?
	currentNum	DWORD	2
	loopHolder	DWORD	?
;***********************************************************************

.code
main PROC
	
	;set random seed
	call	Randomize

	;introduce program. Passes all strings as offsets
	push	OFFSET	intro
	push	OFFSET	inst1
	push	OFFSET	inst2
	push	OFFSET	inst3
	push	OFFSET	inst4
	call	introduction

	;get number of rands from user. Passes the prompt, and passes
	; the return location by ref
	push	OFFSET	prompt
	push	OFFSET	numRand
	call	getData

	;fill array with rand values. Passes the number of values
	;specified by user, and passes the array location by ref
	push	numRand
	push	OFFSET	randArr
	call	fillArray

	;display the unsorted list
	;passes the number of generated numbers in the list, and the
	;base address of the list by reference, along with a title.
	push	OFFSET	initTitle
	push	OFFSET	space
	push	numRand
	push	OFFSET	randArr
	call	printArray

	;sorts the array in decending order
	;passes the array by reference and passes the number of items in array
	push	numRand
	push	OFFSET	randArr
	call	sortArray

	;calculates and displays the median value
	;passes the sorted array by ref and passes the number of items in array
	;as well as the string prompt
	push	OFFSET	medPrompt
	push	numRand
	push	OFFSET	randArr
	call	dispMedian

	;display the sorted list
	;passes the number of generated numbers in the list, and the
	;base address of the list by reference, along with a title.
	push	OFFSET	sortTitle
	push	OFFSET	space
	push	numRand
	push	OFFSET	randArr
	call	printArray

	;display the sorted list by column
	;same parameters as normal print function
	;with an extra title being passed by ref.
	push	OFFSET	byColumn
	push	OFFSET	sortTitle
	push	OFFSET	space
	push	numRand
	push	OFFSET	randArr
	call	printArrayCol

	exit	; exit to operating system
main ENDP

;********Additional Procedures:********

;introduction procedure
;introduces program and instructs user
;**************************************
introduction PROC
	push	ebp
	mov		ebp, esp

	mov		edx, [ebp+24]
	call	WriteString
	call	CrLf
	mov		edx, [ebp+20]
	call	WriteString
	call	CrLf
	mov		edx, [ebp+16]
	call	WriteString
	call	CrLf
	mov		edx, [ebp+12]
	call	WriteString
	call	CrLf
	mov		edx, [ebp+8]
	call	WriteString
	call	CrLf
	call	CrLf
	pop		ebp
	ret		20
introduction ENDP
;**************************************


;get data procedure
;gets the number of primes from the user
;loops back if out of range
;accepts the user prompt and ret location
;as parameters
;**************************************
getData PROC
	push	ebp
	mov		ebp, esp

	L1:
		;location of prompt into edx
		mov		edx, [ebp+12] 
		call	WriteString
		call	ReadInt
		call	CrLf

		;jump back if input is out of range
		cmp		eax, MINVAL 
		jb		L1
		cmp		eax, MAXVAL
		ja		L1

		;move accepted value into ret location
		mov		ebx, [ebp+8]
		mov		[ebx], eax
		pop		ebp
		ret		8
getData ENDP
;**************************************


;fill array procedure. Fills the passed array location
;with the number of random numbers specified by user
;**************************************
fillArray PROC

	push	ebp
	mov		ebp, esp

	;sets up loop. ECX as counter, EBX as array location,
	;and edx as array incrementer
	mov		ecx, [ebp+12]
	mov		edx, 0

	L1:
		;generate random number LOVAL - HIVAL
		mov		eax, HIVAL
		sub		eax, LOVAL
		inc		eax
		call	RandomRange
		add		eax, LOVAL

		;move rand into proper array location
		mov		ebx, [ebp+8] ;array base loc into ebx
		add		ebx, edx	 ;add edx to get proper index
		mov		[ebx], eax	 ;place rand number in array
		add		edx, 4		 ;add 4 to edx to index next location

		loop	L1
	pop		ebp
	ret		8

fillArray ENDP
;**************************************


;print array procedure
;accepts the number of generated items in the array
;as well as the array base location, and prints the array
;10 numbers per line. Passes the line counter by reference.
;**************************************
printArray PROC

	push	ebp
	mov		ebp, esp

	;set EBX as the number per line counter
	mov		ebx, 0

	;set ecx as loop counter
	mov		ecx, [ebp+12]

	;set esi as base array index
	mov		esi, [ebp+8]

	;print title
	call	CrLf
	mov		edx, [ebp+20]
	call	WriteString
	call	CrLf

	L1:
		;see if new line needed
		cmp		ebx, 10
		jl		noNewLine
		call	CrLf
		mov		ebx, 0

		noNewLine:
			;print current array value
			mov		eax, [esi]
			call	WriteInt
			mov		edx, [ebp+16]
			call	WriteString
			call	WriteString

			;increase array index and line count
			add		esi, 4
			inc		ebx

			loop	L1

	call	CrLf
	call	CrLf

	pop		ebp
	ret		16
printArray ENDP
;**************************************


;sort array procedure
;sorts the array in descending order using a bubble sort
;algorithm adapted from Irvine (6th ed) p. 352. Accepts the 
;number of generated numbers in the array and the base index 
;of the array
;**************************************
sortArray PROC
	
	push	ebp
	mov		ebp, esp

	;set loop counter
	mov		ecx, [ebp+12]
	dec		ecx

	;save outer loop counter and put array index
	;in esi
	L1:
		push	ecx
		mov		esi, [ebp+8]
	
	;retreive current array value. Compare to the next
	;and swap if next is larger	
	L2:
		mov		eax, [esi]
		cmp		[esi+4], eax
		jl		L3
		xchg	eax, [esi+4]
		mov		[esi], eax
	
	;increment to next array index and repeat
	L3:
		add		esi, 4
		loop	L2

		;once complete, retreive outer loop count and repeat
		pop		ecx
		loop	L1

	pop		ebp
	ret		8
sortArray ENDP
;**************************************


;display median procedure
;calculates and displays the median value in the sorted array
;accepts the base address of the array and the number of values
;in the array
;**************************************
dispMedian PROC
	push	ebp
	mov		ebp, esp

	;calculate the median value
	mov		edx, 0
	mov		eax, [ebp+12]
	mov		ecx, 2
	div		ecx
	;median index now in eax
	;multiply by 4 to get address offset in eax
	mov		ebx, 4
	mul		ebx

	;put base array index in esi
	mov		esi, [ebp+8]
	;increment to median value
	add		esi, eax

	;put median value in eax
	mov		eax, [esi]

	;print result
	call	CrLf
	call	CrLf
	mov		edx, [ebp+16]
	call	WriteString
	call	WriteInt
	call	CrLf
	call	CrLf

	pop		ebp
	ret		12
dispMedian ENDP
;**************************************


;column print array procedure
;accepts the number of generated items in the array
;as well as the array base location, and prints the array
;10 numbers per line, ordered in columns. Passes the line 
;counter by reference.
;**************************************
printArrayCol PROC

	push	ebp
	mov		ebp, esp

	;set EBX as the number per line counter
	mov		ebx, 0

	;set ecx as loop counter
	mov		ecx, [ebp+12]

	;set esi as base array index
	mov		esi, [ebp+8]

	;print title
	call	CrLf
	mov		edx, [ebp+24]
	call	WriteString
	mov		edx, [ebp+20]
	call	WriteString
	call	CrLf

	L1:
		;see if new line needed
		cmp		ebx, 10
		jl		noNewLine
		call	CrLf
		mov		ebx, 0
		sub		esi, 36

		noNewLine:
			;check if the data we are trying to print column wise is in array range

			push	ecx
			push	ebx

			;set max array location
			mov		eax, 4			;size per index
			mov		ebx, [ebp+12]	;number of indexes
			mov		edx, 0
			mul		ebx	
			add		eax, [ebp+8]	;add last index offset to base array loc
			mov		ecx, eax		;store in ecx

			;calculate array index the program is trying to print
			mov		eax, 36
			pop		ebx		;pop line count back into ebx
			push	ebx		;and push back into stack
			mul		ebx
			mov		ebx, eax

			mov		eax, esi
			add		eax, ebx	;10*line indexes past current in eax
			cmp		eax, ecx	
			jb		printIdx	;if still in range, print
					
			;if out of range, print spaces
			mov		edx, [ebp+16]
			call	WriteString
			call	WriteString
			call	WriteString
			call	WriteString
			call	WriteString
			pop		ebx
			pop		ecx

			inc		ecx
			jmp		noPrint
			
			printIdx:
			pop		ebx
			pop		ecx

			;move the mem index in eax into edx
			mov		edx, eax
			;dereference back into eax
			mov		eax, [edx]
			call	WriteInt
			mov		edx, [ebp+16]
			call	WriteString
			call	WriteString

			;increase array index and line count
			noPrint:
			add		esi, 4
			inc		ebx
			loop	L1

	call	CrLf
	call	CrLf

	pop		ebp
	ret		20
printArrayCol ENDP
;**************************************

END main
