Include Irvine32.inc
Include macros.inc
BUFFER_SIZE = 1000
MAX_W = 9
MAX_INCORRECT = 10
.data
incorrect_list BYTE (MAX_W + 1) * MAX_INCORRECT DUP(0)

incorrect_count BYTE 0
str1 BYTE "Enter Word:",0
input BYTE 10 DUP(?)
score BYTE 0
Lives BYTE 3
check BYTE 1
word_list BYTE "FAST","APPLE","SPOT","TOUCH","SHOUT",0
word_list1 BYTE "VALUE","EMPLOYEE","SUCCESS","LAW","VIRUS",0
word_list2 BYTE "FINANCE","MONEY","REWARD","WALLET","WARE",0
arr_L1 BYTE 5 DUP(1)
arr_L2 BYTE 5 DUP(1)
arr_L3 BYTE 5 DUP(1)
file_L1 BYTE "C:\Users\hunaiza naveed\Downloads\Coal Project\Coal Project\level1.txt",0
file_L2 BYTE "C:\Users\hunaiza naveed\Downloads\Coal Project\Coal Project\level2.txt",0
file_L3 BYTE "C:\Users\hunaiza naveed\Downloads\Coal Project\Coal Project\level3.txt",0
file_L4 BYTE "C:\Users\hunaiza naveed\Downloads\Coal Project\Coal Project\instruction.txt",0
char BYTE 4 Dup("0")

; Store correct and incorrect guesses for display
correct_guesses BYTE 5 DUP(0)      ; Array to track if word was correctly guessed 
;incorrect_list BYTE 10 DUP(?)      ; Buffer for incorrect words
;incorrect_count BYTE 0             ; Count of incorrect guesses

; Colors
defaultColor DWORD ?               ; To store the original color

;read file
buffer BYTE BUFFER_SIZE DUP(0)
fileHandle HANDLE ?

;write high score to file
filename BYTE "C:\Users\hunaiza naveed\Downloads\Coal Project\Coal Project\high_score.txt",0
stringLength DWORD ?

.code
reset_level_data PROC
    ; — clear correct and incorrect guesses —
    mov ecx, 5
    mov edi, OFFSET correct_guesses
    xor al, al
    rep stosb

    mov ecx, 10
    mov edi, OFFSET incorrect_list
    xor al, al
    rep stosb

    mov incorrect_count, 0

    ; — re‑arm each level flags back to “still available” —
    mov ecx, 5
      mov edi, OFFSET arr_L1
      mov al, 1
    rep stosb

    mov ecx, 5
      mov edi, OFFSET arr_L2
      mov al, 1
    rep stosb

    mov ecx, 5
      mov edi, OFFSET arr_L3
      mov al, 1
    rep stosb

    ret
reset_level_data ENDP
main proc

Again:
call clrscr
call GetTextColor    ; Save default color
mov defaultColor, eax

mWrite<" 1-Quick Play",0dh,0ah," 2-Instruction",0dh,0ah," 3-Setting",0dh,0ah>
mWrite<" 4-High Score",0dh,0ah, " 5-Quit",0dh,0dh,0ah,0ah>
mWrite<"Enter Choice:",0>
mov eax,0
call readdec

cmp al,1
jne next
call Quick_play
jmp quit

next:
cmp al,2
jne next1
call instruction
jmp quit

next1:
cmp al,3
jne next2
call setting
jmp quit

next2:
cmp al,4
jne next3
      mWrite<"High Score:",0>
      mov edx,offset filename
	  call read_file
	  call crlf
jmp quit

next3:
cmp al,5
jne next4
mov check,0
jmp Quit1

next4:
mWrite <"You Enter Invalid Number",0dh,0ah>
mov eax,500
call delay
jmp Again
quit:

call readdec
cmp check,0
jne Again

Quit1:
exit
main endp

Quick_play PROC
    call clrscr
    call reset_guesses        ; Initialize tracking arrays
    call level1
    call clrscr
    call level2
    call clrscr
    call level3

    ; === 👑 Smart player message ===
    call crlf
    mov eax, green
    call SetTextColor

    ; Print 25 spaces for center alignment
    mov ecx, 25
print_spaces:
    mWrite " "
    loop print_spaces

    ; Now print the message
    mWrite <"AAP TOU BHUT SMART HOU BHAIIYA",0dh,0ah>

    mov eax, defaultColor
    call SetTextColor
    call crlf
    mov eax, 1500
    call Delay


    ret
Quick_play endp

; Reset all tracking arrays for new game
reset_guesses PROC
    mov incorrect_count, 0
    mov ecx, 5
    mov edi, OFFSET correct_guesses
    mov al, 0
    rep stosb            ; Fill correct_guesses with 0
    ret
reset_guesses ENDP

setting PROC

mWrite<" 1-change Color",0dh,0ah>
Again:
mWrite<"Enter Choice:",0>

mov eax,0
call readdec

cmp al,1
jne next
call changecolor
jmp next1
next:
mWrite<"You enter Invalid number",0dh,0ah>
mov eax,500
call delay
jmp Again

next1:
ret
setting endp

changecolor PROC

call clrscr
mWrite<" 1-Blue",0dh,0ah," 2-White",0dh,0ah," 3-Green",0dh,0ah>
mWrite<" 4-Red",0dh,0ah," 5-Magenta",0dh,0ah," 6-Yellow",0dh,0ah>
mWrite<" 7-Cyan",0dh,0ah," 8-Brown",0dh,0ah>
mWrite<"Select Color:",0>
mov eax,0
call readdec

cmp al,1
jne next
mov eax,blue
call settextcolor
jmp quit

next:
cmp al,2
jne next1
mov eax,white
call settextcolor
jmp quit

next1:
cmp al,3
jne next2
mov eax,green
call settextcolor
jmp quit

next2:
cmp al,4
jne next3
mov eax,red
call settextcolor
jmp quit

next3:
cmp al,5
jne next4
mov eax,magenta
call settextcolor
jmp quit

next4:
cmp al,6
jne next5
mov eax,yellow
call settextcolor
jmp quit

next5:
cmp al,7
jne next6
mov eax,cyan
call settextcolor
jmp quit

next6:
cmp al,8
jne next7
mov eax,brown
call settextcolor
jmp quit
next7:
mWrite <"You Enter Invalid Number",0dh,0ah>
quit:

ret
changecolor endp

; Helper procedure - Save incorrect guess
save_incorrect_guess PROC
    cmp     incorrect_count, MAX_INCORRECT
    jge     too_many        ; no more slots

    ; calculate destination: incorrect_list + count*(MAX_W+1)
    movzx   eax, incorrect_count
    mov     ebx, MAX_W+1
    mul     ebx             ; EAX = EAX * EBX
    lea     edi, incorrect_list
    add     edi, eax

    ; copy input[0..] including the null terminator
    lea     esi, input
copy_loop:
    lodsb                   ; AL = [ESI], ESI++
    stosb                   ; [EDI] = AL, EDI++
    test    al, al
    jnz     copy_loop       ; keep going until you hit the 0

    ; bump the count
    inc     incorrect_count

too_many:
    ret
save_incorrect_guess ENDP

; Display correct and incorrect words
display_word_lists PROC
    ; AL = current level (1, 2, or 3)
    
    ; Display correct words in green
    mov eax, green
    call SetTextColor
    
	call crlf
    mWrite<"Correct guesses: ",0>
    
    cmp bl, 1
    je show_level1
    cmp bl, 2
    je show_level2
    cmp bl, 3
    je show_level3
    jmp check_wrong

show_level1:
    mov al, correct_guesses[0]
    cmp al, 1
    jne ck1_2
    mWrite<"FAST ",0>
ck1_2:
    mov al, correct_guesses[1]
    cmp al, 1
    jne ck1_3
    mWrite<"APPLE ",0>
ck1_3:
    mov al, correct_guesses[2]
    cmp al, 1
    jne ck1_4
    mWrite<"SPOT ",0>
ck1_4:
    mov al, correct_guesses[3]
    cmp al, 1
    jne ck1_5
    mWrite<"TOUCH ",0>
ck1_5:
    mov al, correct_guesses[4]
    cmp al, 1
    jne check_wrong
    mWrite<"SHOUT ",0>
    jmp check_wrong

show_level2:
    mov al, correct_guesses[0]
    cmp al, 1
    jne ck2_2
    mWrite<"VALUE ",0>
ck2_2:
    mov al, correct_guesses[1]
    cmp al, 1
    jne ck2_3
    mWrite<"EMPLOYEE ",0>
ck2_3:
    mov al, correct_guesses[2]
    cmp al, 1
    jne ck2_4
    mWrite<"SUCCESS ",0>
ck2_4:
    mov al, correct_guesses[3]
    cmp al, 1
    jne ck2_5
    mWrite<"LAW ",0>
ck2_5:
    mov al, correct_guesses[4]
    cmp al, 1
    jne check_wrong
    mWrite<"VIRUS ",0>
    jmp check_wrong

show_level3:
    mov al, correct_guesses[0]
    cmp al, 1
    jne ck3_2
    mWrite<"FINANCE ",0>
ck3_2:
    mov al, correct_guesses[1]
    cmp al, 1
    jne ck3_3
    mWrite<"MONEY ",0>
ck3_3:
    mov al, correct_guesses[2]
    cmp al, 1
    jne ck3_4
    mWrite<"REWARD ",0>
ck3_4:
    mov al, correct_guesses[3]
    cmp al, 1
    jne ck3_5
    mWrite<"WALLET ",0>
ck3_5:
    mov al, correct_guesses[4]
    cmp al, 1
    jne check_wrong
    mWrite<"WARE ",0>

check_wrong:
    call Crlf

  ; print header
    mov     eax, red
    call    SetTextColor
    mWrite  <"Incorrect guesses: ",0>

    ; if none, skip
    movzx   ecx, incorrect_count
    cmp     ecx, 0
    je      done_list

    ; start at the first wrong word
    lea     edx, incorrect_list

print_wrong_loop:
    ; EDX → a null‑terminated word
    call    WriteString
    mWrite  <" ",0>

    ; advance EDX by MAX_W+1 to the next slot
    add     edx, MAX_W+1

    loop    print_wrong_loop

done_list:
    call    Crlf
    mov     eax, defaultColor
    call    SetTextColor
    ret
display_word_lists ENDP


; Display colored grid
display_colored_grid PROC
    ; Save current text color
    mov eax, cyan    ; Set grid color to cyan
    call SetTextColor
    
    ; Display buffer content
    mov edx, OFFSET buffer
    call WriteString
    
    ; Restore default color
    mov eax, defaultColor
    call SetTextColor
    ret
display_colored_grid ENDP

level1 PROC
    ; Reset tracking
	call reset_level_data
    mov ecx, 5
    mov edi, OFFSET correct_guesses
    mov al, 0
    rep stosb
    mov incorrect_count, 0

whileloop:
      cmp lives, 0
	  je quit
      mWrite<"Lives:",0>
      movzx eax, lives
      call writedec
      mWrite<"     Score:",0>
      movzx eax, score
      call WriteDec
	  call crlf
	  call crlf

      ; Read file and display colored grid
	  mov edx, OFFSET file_L1
	  call OpenInputFile
      mov fileHandle, eax
      
      ; Check for file error
      cmp eax, INVALID_HANDLE_VALUE
      jne file_ok
      mWrite<"Cannot open file",0dh,0ah>
      jmp next_level
      
file_ok:
      ; Read file content
      mov edx, OFFSET buffer
      mov ecx, BUFFER_SIZE
      call ReadFromFile
      mov buffer[eax], 0    ; Null-terminate
      
      ; Display colored grid
      call display_colored_grid
      
      ; Close file
      mov eax, fileHandle
      call CloseFile
      
      ; Display word lists
	  mov bl,1
      call display_word_lists
      call crlf

	  mov edx, OFFSET str1
	  call writestring

	  mov edx, OFFSET input
      mov ecx, 9
      call ReadString

	  mov al, arr_L1[0]
	  cmp al, 1
	  jne else1

	  ; Check "FAST"
	  cld
	  mov esi, OFFSET input
	  mov edi, OFFSET word_list[0]
	  mov ecx, 4
	  repe cmpsb
	  jnZ else1
	  
	  ; Word found - display in green
	  mov eax, green
	  call SetTextColor
	  mWrite<"Your entered word found",0dh,0ah>
	  mov eax, defaultColor
	  call SetTextColor
	  
	  ; Mark as correct
	  mov correct_guesses[0], 1
	  
	  inc score
	  mov arr_L1[0], 0
	  jmp next
	  
else1:
	  mov al, arr_L1[1]
	  cmp al, 1
	  jne else2
	  
	  ; Check "APPLE"
	  cld
	  mov esi, OFFSET input
	  mov edi, OFFSET word_list[4]
	  mov ecx, 5
	  repe cmpsb
	  jnz else2
	  
	  ; Word found - display in green
	  mov eax, green
	  call SetTextColor
	  mWrite<"Your entered word found",0dh,0ah>
	  mov eax, defaultColor
	  call SetTextColor
	  
	  ; Mark as correct
	  mov correct_guesses[1], 1
	  
	  inc score
	  mov arr_L1[1], 0
	  jmp next
	  
else2:
      mov al, arr_L1[2]
	  cmp al, 1
	  jne else3
	  
	  ; Check "SPOT"
	  cld
	  mov esi, OFFSET input
	  mov edi, OFFSET word_list[9]
	  mov ecx, 4
	  repe cmpsb
	  jnz else3
	  
	  ; Word found - display in green
	  mov eax, green
	  call SetTextColor
	  mWrite<"Your entered word found",0dh,0ah>
	  mov eax, defaultColor
	  call SetTextColor
	  
	  ; Mark as correct
	  mov correct_guesses[2], 1
	  
	  inc score
	  mov arr_L1[2], 0
	  jmp next
	  
else3:
      mov al, arr_L1[3]
	  cmp al, 1
	  jne else4
	  
	  ; Check "TOUCH"
	  cld
	  mov esi, OFFSET input
	  mov edi, OFFSET word_list[13]
	  mov ecx, 5
	  repe cmpsb
	  jnz else4
	  
	  ; Word found - display in green
	  mov eax, green
	  call SetTextColor
	  mWrite<"Your entered word found",0dh,0ah>
	  mov eax, defaultColor
	  call SetTextColor
	  
	  ; Mark as correct
	  mov correct_guesses[3], 1
	  
	  inc score
	  mov arr_L1[3], 0
	  jmp next
	  
else4:
      mov al, arr_L1[4]
	  cmp al, 1
	  jne else5
	  
	  ; Check "SHOUT" - Fixed line 336
	  cld
	  mov esi, OFFSET input
	  mov edi, OFFSET word_list[18]
	  mov ecx, 5
	  repe cmpsb
	  jnz else5
	  
	  ; Word found - display in green
	  mov eax, green
	  call SetTextColor
	  mWrite<"Your entered word found",0dh,0ah>
	  mov eax, defaultColor
	  call SetTextColor
	  
	  ; Mark as correct
	  mov correct_guesses[4], 1
	  
	  inc score
	  mov arr_L1[4], 0
	  jmp next
	  
else5:
      ; Word not found - display in red
      mov eax, red
      call SetTextColor
      mWrite<"You enter word not found!",0dh,0ah>
      mov eax, defaultColor
      call SetTextColor
      
      ; Save incorrect guess
      call save_incorrect_guess
      
	  dec lives
	  
next:
MOV EAX, 500
CALL delay
call clrscr
MOV AL, score
cmp al, 5
jl whileloop

next_level:
quit:
ret
level1 endp

level2 Proc
call reset_level_data
    mov ecx, 5
    mov edi, OFFSET correct_guesses
    mov al, 0
    rep stosb
    mov incorrect_count, 0

whileloop:
      cmp lives, 0
	  je quit
      mWrite<"Lives:",0>
      movzx eax, lives
      call writedec
      mWrite<"     Score:",0>
      movzx eax, score
      call WriteDec
	  call crlf
	  call crlf

      ; Read file and display colored grid
	  mov edx, OFFSET file_L2
	  call OpenInputFile
      mov fileHandle, eax
      
      ; Check for file error
      cmp eax, INVALID_HANDLE_VALUE
      jne file_ok
      mWrite<"Cannot open file",0dh,0ah>
      jmp next_level
      
file_ok:
      ; Read file content
      mov edx, OFFSET buffer
      mov ecx, BUFFER_SIZE
      call ReadFromFile
      mov buffer[eax], 0    ; Null-terminate
      
      ; Display colored grid
      call display_colored_grid
      
      ; Close file
      mov eax, fileHandle
      call CloseFile
      
      ; Display word lists
	  mov bl,2
      call display_word_lists
      call crlf

	  mov edx, OFFSET str1
	  call writestring

	  mov edx, OFFSET input
      mov ecx, 9
      call ReadString

	  mov al, arr_L2[0]
	  cmp al, 1
	  jne else1

	  ; Check "VALUE"
	  cld
	  mov esi, OFFSET input
	  mov edi, OFFSET word_list1[0]
	  mov ecx, 5
	  repe cmpsb
	  jnZ else1
	  
	  ; Word found - display in green
	  mov eax, green
	  call SetTextColor
	  mWrite<"Your entered word found",0dh,0ah>
	  mov eax, defaultColor
	  call SetTextColor
	  
	  mov correct_guesses[0],1
	  inc score
	  mov arr_L2[0], 0
	  jmp next
	  
else1:
	  mov al, arr_L2[1]
	  cmp al, 1
	  jne else2
	  
	  ; Check "EMPLOYEE"
	  cld
	  mov esi, OFFSET input
	  mov edi, OFFSET word_list1[5]
	  mov ecx, 8
	  repe cmpsb
	  jnz else2
	  
	  ; Word found - display in green
	  mov eax, green
	  call SetTextColor
	  mWrite<"Your entered word found",0dh,0ah>
	  mov eax, defaultColor
	  call SetTextColor
	  mov correct_guesses[1],1

	  inc score
	  mov arr_L2[1], 0
	  jmp next
	  
else2:
      mov al, arr_L2[2]
	  cmp al, 1
	  jne else3
	  
	  ; Check "SUCCESS"
	  cld
	  mov esi, OFFSET input
	  mov edi, OFFSET word_list1[13]
	  mov ecx, 7
	  repe cmpsb
	  jnz else3
	  
	  ; Word found - display in green
	  mov eax, green
	  call SetTextColor
	  mWrite<"Your entered word found",0dh,0ah>
	  mov eax, defaultColor
	  call SetTextColor
	  mov correct_guesses[2],1

	  inc score
	  mov arr_L2[2], 0
	  jmp next
	  
else3:
      mov al, arr_L2[3]
	  cmp al, 1
	  jne else4
	  
	  ; Check "LAW"
	  cld
	  mov esi, OFFSET input
	  mov edi, OFFSET word_list1[20]
	  mov ecx, 3
	  repe cmpsb
	  jnz else4
	  
	  ; Word found - display in green
	  mov eax, green
	  call SetTextColor
	  mWrite<"Your entered word found",0dh,0ah>
	  mov eax, defaultColor
	  call SetTextColor
	  mov correct_guesses[3],1

	  inc score
	  mov arr_L2[3], 0
	  jmp next
	  
else4:
      mov al, arr_L2[4]
	  cmp al, 1
	  jne else5
	  
	  ; Check "VIRUS"
	  cld
	  mov esi, OFFSET input
	  mov edi, OFFSET word_list1[23]
	  mov ecx, 5
	  repe cmpsb
	  jnz else5
	  
	  ; Word found - display in green
	  mov eax, green
	  call SetTextColor
	  mWrite<"Your entered word found",0dh,0ah>
	  mov eax, defaultColor
	  call SetTextColor
	  mov correct_guesses[4],1
	  
	  inc score
	  mov arr_L2[4], 0
	  jmp next
	  
else5:
      ; Word not found - display in red
      mov eax, red
      call SetTextColor
      mWrite<"You enter word not found!",0dh,0ah>
      mov eax, defaultColor
      call SetTextColor
      
      ; Save incorrect guess
      call save_incorrect_guess
      
	  dec lives
	  
next:
MOV EAX, 500
CALL delay
call clrscr
MOV AL, score
cmp al, 10
jl whileloop

next_level:
quit:
ret
level2 endp

level3 Proc
call reset_level_data
whileloop:
      cmp lives, 0
	  je quit
      mWrite<"Lives:",0>
      movzx eax, lives
      call writedec
      mWrite<"     Score:",0>
      movzx eax, score
      call WriteDec
	  call crlf
	  call crlf

      ; Read file and display colored grid
	  mov edx, OFFSET file_L3
	  call OpenInputFile
      mov fileHandle, eax
      
      ; Check for file error
      cmp eax, INVALID_HANDLE_VALUE
      jne file_ok
      mWrite<"Cannot open file",0dh,0ah>
      jmp next_level
      
file_ok:
      ; Read file content
      mov edx, OFFSET buffer
      mov ecx, BUFFER_SIZE
      call ReadFromFile
      mov buffer[eax], 0    ; Null-terminate
      
      ; Display colored grid
      call display_colored_grid
      
      ; Close file
      mov eax, fileHandle
      call CloseFile
      
      ; Display word lists
	  MOV BL,3
      call display_word_lists
      call crlf

	  mov edx, OFFSET str1
	  call writestring

	  mov edx, OFFSET input
      mov ecx, 9
      call ReadString

	  mov al, arr_L3[0]
	  cmp al, 1
	  jne else1

	  ; Check "FINANCE"
	  cld
	  mov esi, OFFSET input
	  mov edi, OFFSET word_list2[0]
	  mov ecx, 7
	  repe cmpsb
	  jnZ else1
	  
	  ; Word found - display in green
	  mov eax, green
	  call SetTextColor
	  mov correct_guesses[0],1
	  mWrite<"Your entered word found",0dh,0ah>
	  mov eax, defaultColor
	  call SetTextColor
	  
	  inc score
	  mov arr_L3[0], 0
	  jmp next
	  
else1:
	  mov al, arr_L3[1]
	  cmp al, 1
	  jne else2
	  
	  ; Check "MONEY"
	  cld
	  mov esi, OFFSET input
	  mov edi, OFFSET word_list2[7]
	  mov ecx, 5
	  repe cmpsb
	  jnz else2
	  
	  ; Word found - display in green
	  mov eax, green
	  call SetTextColor
	  mov correct_guesses[1],1
	  mWrite<"Your entered word found",0dh,0ah>
	  mov eax, defaultColor
	  call SetTextColor
	  
	  inc score
	  mov arr_L3[1], 0
	  jmp next
	  
else2:
      mov al, arr_L3[2]
	  cmp al, 1
	  jne else3
	  
	  ; Check "REWARD"
	  cld
	  mov esi, OFFSET input
	  mov edi, OFFSET word_list2[12]
	  mov ecx, 6
	  repe cmpsb
	  jnz else3
	  
	  ; Word found - display in green
	  mov eax, green
	  call SetTextColor
	  mov correct_guesses[2],1
	  mWrite<"Your entered word found",0dh,0ah>
	  mov eax, defaultColor
	  call SetTextColor
	  
	  inc score
	  mov arr_L3[2], 0
	  jmp next
	  
else3:
      mov al, arr_L3[3]
	  cmp al, 1
	  jne else4
	  
	  ; Check "WALLET"
	  cld
	  mov esi, OFFSET input
	  mov edi, OFFSET word_list2[18]
	  mov ecx, 6
	  repe cmpsb
	  jnz else4
	  
	  ; Word found - display in green
	  mov eax, green
	  call SetTextColor
	  mov correct_guesses[3],1
	  mWrite<"Your entered word found",0dh,0ah>
	  mov eax, defaultColor
	  call SetTextColor
	  
	  inc score
	  mov arr_L3[3], 0
	  jmp next
	  
else4:
      mov al, arr_L3[4]
	  cmp al, 1
	  jne else5
	  
	  ; Check "WARE" - Fixed line 545
	  cld
	  mov esi, OFFSET input
	  mov edi, OFFSET word_list2[24]
	  mov ecx, 4
	  repe cmpsb
	  jnz else5
	  
	  ; Word found - display in green
	  mov eax, green
	  call SetTextColor
	  mov correct_guesses[4],1
	  mWrite<"Your entered word found",0dh,0ah>
	  mov eax, defaultColor
	  call SetTextColor
	  
	  inc score
	  mov arr_L3[4], 0
	  jmp next
	  
else5:
      ; Word not found - display in red
      mov eax, red
      call SetTextColor
      mWrite<"You enter word not found!",0dh,0ah>
      mov eax, defaultColor
      call SetTextColor
      
      ; Save incorrect guess
      call save_incorrect_guess
      
	  dec lives
	  
next:
MOV EAX, 500
CALL delay
call clrscr
MOV AL, score
cmp al, 15
jl whileloop

next_level:
quit:
ret
level3 endp

read_file proc
call OpenInputFile
mov fileHandle,eax
; Check for errors.
cmp eax,INVALID_HANDLE_VALUE ; error opening file?
jne file_ok ; no: skip
mWrite <"Cannot open file",0dh,0ah>
jmp quit ; and quit
file_ok:
; Read the file into a buffer.
mov edx,OFFSET buffer
mov ecx,BUFFER_SIZE
call ReadFromFile
jnc check_buffer_size ; error reading?
mWrite "Error reading file. " ; yes: show error message
call WriteWindowsMsg
jmp close_file
check_buffer_size:
cmp eax,BUFFER_SIZE ; buffer large enough?
jb buf_size_ok ; yes
mWrite <"Error: Buffer too small for the file",0dh,0ah>
jmp quit ; and quit
buf_size_ok:
mov buffer[eax],0 ; insert null terminator
mov edx,OFFSET buffer ; display the buffer
call WriteString
call Crlf
close_file:
mov eax,fileHandle
call CloseFile
quit:
ret
read_file endp

instruction PROC
      mov edx,offset file_L4
	  call read_file
	  call crlf
ret
instruction endp

write_file PROC
    
	; Create a new text file.
	 mov edx,OFFSET filename 
	 call CreateOutputFile 
	 mov fileHandle,eax 
	 
	 ; Check for errors. 
	 cmp eax, INVALID_HANDLE_VALUE ; error found? 
	 jne file_ok ; no: skip 
	 mWrite<"Cannot create file",0dh,0ah,0> ; display error 
	 jmp quit 
	 file_ok: 

	 mov eax,0
	 cld
	 mov al,score
	 mov edi,offset char
	 stosd

	 ; Write the buffer to the output file.
     mov eax,fileHandle
     mov edx,offset char
     mov ecx,4
     call WriteToFile
     call CloseFile

    quit:

ret
write_file endp

end main
