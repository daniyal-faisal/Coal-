.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode: DWORD
Include irvine32.inc
.data

xFence BYTE 52 DUP("_"), 0 ;boundary

line BYTE "####################################################################################", 0
main1 BYTE "WELCOME TO OUR SNAKE GAME!!!!", 0
creds BYTE "CREATED BY:", 0
rafay BYTE "- 23K-0689 - 'Rafay Khan'", 0
daniyal BYTE "- 23K-0629 - 'Daniyal Faisal'", 0

diff1 BYTE "IT HAS THREE LEVELS OF DIFFICULTY", 0
diff2 BYTE "1. Hard     2. Medium     3. Easy", 0

strScore BYTE "SCORE: ",0
score BYTE 0

invalidInput BYTE "invalid input",0
gameover BYTE "GAME OVER!!!! THE SNAKE DIED :(", 0
strPoints BYTE " FINAL SCORE: ",0

snake BYTE "*", 104 DUP("*")

xPreyPos BYTE ?
yPreyPos BYTE ?

horizAxis BYTE 45,44,43,42,41, 100 DUP(?) ;To store coordinates of snake
vertAxis BYTE 15,15,15,15,15, 100 DUP(?)
;fixed positions

horizAxisFence BYTE 34,34,84,84 ;xcord topline,xcord bottom,right
vertAxisFence BYTE 5,24,5,24 	;ycord topline,ycord bottom,right-top,print


inputChar BYTE "+"					
lastInputChar BYTE ?				

Difficultyprmpt BYTE "ENTER DIFFICULTY (1 - 3): ",0
difficulty	DWORD 0
retryprmpt BYTE "PLAY AGAIN? (1/0) ",0
.code
main PROC
	call MainMenu
	call ChooseDifficulty

	call ClrScr
	call DrawFence			
	call DrawScoreboard			

	mov esi,0
	mov ecx,5 ;Draw Initail Snake
	drawSnake:
		call DrawPlayer			
		inc esi
		loop drawSnake

	call Randomize
	call CreateRandomPrey ;Place random food
	call DrawPrey			

	gameLoop::
		mov dl,43
		mov dh,4
		call Gotoxy

		; get user key input
		call ReadKey
        jz noKey	;no key pressed					
		processInput:
		mov bl, inputChar
		mov lastInputChar, bl
		mov inputChar,al	

		noKey:
		cmp inputChar,"x"	
		je playagn						

		cmp inputChar,"w"
		je checkTop

		cmp inputChar,"s"
		je checkBottom

		cmp inputChar,"a"
		je checkLeft

		cmp inputChar,"d"
		je checkRight
		jne gameLoop					



		checkBottom:	
		cmp lastInputChar, "w"
		je dontChgDirection		
		mov cl, vertAxisFence[1]
		dec cl					
		cmp vertAxis[0],cl
		jl moveDown
		je died					

		checkLeft:		
		cmp lastInputChar, "+"	;for first time dont start with left
		je dontGoLeft
		cmp lastInputChar, "d"
		je dontChgDirection
		mov cl, horizAxisFence[0]
		inc cl
		cmp horizAxis[0],cl
		jg moveLeft
		je died						

		checkRight:		
		cmp lastInputChar, "a"
		je dontChgDirection
		mov cl, horizAxisFence[2]
		dec cl
		cmp horizAxis[0],cl
		jl moveRight
		je died					

		checkTop:		
		cmp lastInputChar, "s"
		je dontChgDirection
		mov cl, vertAxisFence[0]
		inc cl
		cmp vertAxis,cl
		jg moveUp
		je died				
		
		moveUp:		
		mov eax, difficulty		
		add eax, difficulty
		call delay
		mov esi, 0			
		call UpdatePlayer	
		mov ah, vertAxis[esi]	
		mov al, horizAxis[esi]	 
		dec vertAxis[esi]		
		call DrawPlayer		
		call DrawBody
		call CheckSnake

		
		moveDown:			
		mov eax, difficulty
		add eax, difficulty
		call delay
		mov esi, 0
		call UpdatePlayer
		mov ah, vertAxis[esi]
		mov al, horizAxis[esi]
		inc vertAxis[esi]
		call DrawPlayer
		call DrawBody
		call CheckSnake


		moveLeft:			
		mov eax, difficulty
		call delay
		mov esi, 0
		call UpdatePlayer
		mov ah, vertAxis[esi]
		mov al, horizAxis[esi]
		dec horizAxis[esi]
		call DrawPlayer
		call DrawBody
		call CheckSnake


		moveRight:			
		mov eax, difficulty
		call delay
		mov esi, 0
		call UpdatePlayer
		mov ah, vertAxis[esi]
		mov al, horizAxis[esi]
		inc horizAxis[esi]
		call DrawPlayer
		call DrawBody
		call CheckSnake

		checkPrey::
		mov esi,0
		mov bl,horizAxis[0]
		cmp bl,xPreyPos
		jne gameloop			
		mov bl,vertAxis[0]
		cmp bl,yPreyPos
		jne gameloop			
		call EatingPrey				

jmp gameLoop					


	dontChgDirection:		
	mov inputChar, bl		
	jmp noKey				

	dontGoLeft:				
	mov	inputChar, "+"		
	jmp gameLoop			

	died::
	call YouDied
	 
	playagn::			
	call ReinitializeGame	
	
	exitgame::
	call clrscr
	exit
INVOKE ExitProcess,0
main ENDP

MainMenu PROC

mov dh, 4 ;row
mov dl, 20;col
call GoToXY
mov edx, OFFSET line
call WriteString

mov dh, 7
mov dl, 48
call GoToXY
mov edx, OFFSET main1
call WriteString
	
mov dh, 10
mov dl, 47
call GoToXY
mov edx, OFFSET diff1
call WriteString

mov dh, 11
mov dl, 47
call GoToXY
mov edx, OFFSET diff2
call WriteString

mov dh, 17
mov dl, 20
call GoToXY
mov edx, OFFSET line
call WriteString

mov dh, 23
mov dl, 75
call GoToXY
mov edx, OFFSET creds
call WriteString

mov dh, 24
mov dl, 85
call GoToXY
mov edx, OFFSET rafay
call WriteString

mov dh, 25
mov dl, 85
call GoToXY
mov edx, OFFSET daniyal
call WriteString

ret
MainMenu ENDP

DrawFence PROC	
	;horizAxisFence BYTE 34,34,84,84 ;xcord topline,xcord bottom,right	
	;vertAxisFence BYTE 5,24,5,24 ;	ycord topline,ycord bottom,right-top,print
	
	mov dl,horizAxisFence[0];col
	mov dh,vertAxisFence[0];row
	call Gotoxy	
	mov edx,OFFSET xFence
	call WriteString		

	mov dl,horizAxisFence[1]
	mov dh,vertAxisFence[1]
	call Gotoxy	
	mov edx,OFFSET xFence		
	call WriteString		

	mov dl, horizAxisFence[2]
	mov dh, vertAxisFence[2]
	mov eax,"|"	
	inc vertAxisFence[3]
	L11: 
	call Gotoxy	
	call WriteChar	
	inc dh
	cmp dh, vertAxisFence[3]		
	jl L11

	mov dl, horizAxisFence[0]
	mov dh, vertAxisFence[0]
	mov eax,"|"	
	L12: 
	call Gotoxy	
	call WriteChar	
	inc dh
	cmp dh, vertAxisFence[3]		
	jl L12
	ret
DrawFence ENDP


DrawScoreboard PROC			
	mov dl,34
	mov dh,4
	call Gotoxy
	mov edx,OFFSET strScore	
	call WriteString
	mov eax,"0"
	call WriteChar			
	ret
DrawScoreboard ENDP


Choosedifficulty PROC
	
	mov edx, 0
	mov dh, 14
	mov dl, 47
	call GoToXY

	mov edx,OFFSET Difficultyprmpt
	call WriteString
	mov esi, 40 ;Multiply difficulty by 40 to set speed				
	mov eax,0
	call readInt
	cmp ax,1				
	jl invalidspeed
	cmp ax, 3
	jg invalidspeed
	mul esi	
	mov difficulty, eax		
	ret

	invalidspeed:			
	mov dl,105				
	mov dh,1
	call Gotoxy	
	mov edx, OFFSET invalidInput
	call WriteString
	mov ax, 1500
	call delay
	mov dl,16	
	mov dh,47
	call Gotoxy	
	call Choosedifficulty	; recurse	
	ret
Choosedifficulty ENDP

DrawPlayer PROC			
	mov dl,horizAxis[esi]
	mov dh,vertAxis[esi]
	call Gotoxy
	mov dl, al			
	mov al, snake[esi]		
	call WriteChar
	mov al, dl			
	ret
DrawPlayer ENDP

UpdatePlayer PROC		
	mov dl, horizAxis[esi]
	mov dh,vertAxis[esi]
	call Gotoxy
	mov dl, al			
	mov al, " "
	call WriteChar
	mov al, dl
	ret
UpdatePlayer ENDP

DrawPrey PROC			
	mov eax,blue (blue * 16)
	call SetTextColor	
	mov dl,xPreyPos
	mov dh,yPreyPos
	call Gotoxy
	mov al,"X"
	call WriteChar
	mov eax,white (black * 16)
	call SetTextColor
	ret
DrawPrey ENDP

CreateRandomPrey PROC			
	mov eax,49
	call RandomRange	
	add eax, 35	;horizontal range 35-84		
	mov xPreyPos,al
	mov eax,17
	call RandomRange	
	add eax, 6	; vertical range: 6-23		
	mov yPreyPos,al

	mov ecx, 5 ; Initial Snake Length = 5
	add cl, score ;New Snake Length = 5 + score				
	mov esi, 0 ;find conflict
checkPreyhorizAxis:
	movzx eax,  xPreyPos
	cmp al, horizAxis[esi]	;cmp with snake position	
	je checkPreyvertAxis			
	continueloop:
	inc esi
loop checkPreyhorizAxis
	ret							
	checkPreyvertAxis:
	movzx eax, yPreyPos			
	cmp al, vertAxis[esi]; colliding with snake
	jne continueloop			
	call CreateRandomPrey ;conflict found, recurse again	
CreateRandomPrey ENDP

CheckSnake PROC				
	mov al, horizAxis[0] 
	mov ah, vertAxis[0] 
	mov esi,4				
	add cl,score ;Loop whole snake array
checkhorizAxisition:
	cmp horizAxis[esi], al		
	je horizAxisSame ;Colliding horizontally
	contloop:
	inc esi
loop checkhorizAxisition
	jmp checkPrey
	horizAxisSame:				
	cmp vertAxis[esi], ah
	je died ;Snake Colliding with itself					
	jmp contloop

CheckSnake ENDP

DrawBody PROC				
		mov ecx, 4
		add cl, score; Find snake Length	
		printbodyloop:	
		inc esi				
		call UpdatePlayer ;Remove old snake part
		mov dl, horizAxis[esi] ;current location
		mov dh, vertAxis[esi]	
		mov vertAxis[esi], ah ;stored next Head location stored in array
		mov horizAxis[esi], al	
		mov al, dl
		mov ah,dh			
		call DrawPlayer
		cmp esi, ecx
		jl printbodyloop
	ret
DrawBody ENDP

EatingPrey PROC
	; snake is eating Prey
	inc score
	mov ebx,4
	add bl, score
	mov esi, ebx
	mov ah, vertAxis[esi-1]
	mov al, horizAxis[esi-1]	
	mov horizAxis[esi], al		
	mov vertAxis[esi], ah		
	;set the new body part of snake aligned
	;make sure it doesnot ziczac

	cmp horizAxis[esi-2], al		
	jne checky				

	cmp vertAxis[esi-2], ah		
	jl incy			
	jg decy
	incy:					
	inc vertAxis[esi]
	jmp continue
	decy:					
	dec vertAxis[esi]
	jmp continue

	checky:					
	cmp vertAxis[esi-2], ah		
	jl incx
	jg decx
	incx:					
	inc horizAxis[esi]			
	jmp continue
	decx:					
	dec horizAxis[esi]

	continue:
	call DrawPlayer
	call CreateRandomPrey
	call DrawPrey
	
	mov dl,41
	mov dh,4
	call Gotoxy
	mov al,score
	call WriteDec
	ret
EatingPrey ENDP


YouDied PROC
	mov eax, 1000
	call delay
	Call ClrScr

	mov dh, 4
	mov dl, 20
	call GoToXY
	mov edx, OFFSET line
	call WriteString

	mov dh, 17
	mov dl, 20
	call GoToXY
	mov edx, OFFSET line
	call WriteString

	mov dl,	47
	mov dh, 7
	call Gotoxy
	mov edx, OFFSET gameover
	call WriteString

	mov dl,	53
	mov dh, 10
	call Gotoxy
	mov edx, OFFSET strPoints
	call WriteString

	mov dl,	67
	mov dh, 10
	call Gotoxy
	movzx eax, score
	call WriteDec

	mov dl,	52
	mov dh, 14
	call Gotoxy
	mov edx, OFFSET retryprmpt
	call WriteString

	retry:
	call ReadInt
	cmp al, 1
	je playagn				
	cmp al, 0
	je exitgame				

	mov dh,	17
	call Gotoxy
	mov edx, OFFSET invalidInput	
	call WriteString		
	mov dl,	56
	mov dh, 19
	call Gotoxy
	jmp retry						
YouDied ENDP

ReinitializeGame PROC		
	mov horizAxis[0], 45
	mov horizAxis[1], 44
	mov horizAxis[2], 43
	mov horizAxis[3], 42
	mov horizAxis[4], 41
	mov vertAxis[0], 15
	mov vertAxis[1], 15
	mov vertAxis[2], 15
	mov vertAxis[3], 15
	mov vertAxis[4], 15			
	mov score,0				
	mov lastInputChar, 0
	mov	inputChar, "+"			
	dec vertAxisFence[3]			
	Call ClrScr
	jmp main				
ReinitializeGame ENDP
END main

