.model small
.386
.stack 1024

.data
    include sprite.inc       ; sprite related procs
    include fifteen.inc      ; include all sprites except alphabet
    include alphabet.inc     ; alphabet and numbers for score and name input
    include score.inc        ; score printing

    randSprite dw 0          ; random sprite from sprites array
    randSprite2 dw 0

    curDinoXY dw 0           ; cur = current dh = x, dl = y

    delayVarBig dd 20000        ;walking
    delayVarMed dd 10687        ;jumping
    delayVarSmol dd 15000


    isJumpFall db 0          ; is dino jumping or falling flag

    ones db 0                ; scores, ones
    newOnes db 0             ; flag if ones is repeating
    tens db 0
    newTens db 0
    hundreds db 0
    newHundreds db 0
    thousands db 0
    newThousands db 0

    ; Background color variables
    bgColor db 0Bh           ; Default cyan background
    grassColor db 02h        ; Default green grass
    isYellowBg db 0          ; Flag to track if we're using yellow background

    ans db 0            ; used for menu buttons and try again buttons
    dinoCycle db 2      ; dino animation
    curArrowPos dw 0    ; use to preserve arrow pos
    counter db 0        ; counter for dino animation
    firstjump db 0      ; flag whether dino has jumped (for tutorial)

    hearts db 0         ; lives

    ;leaderboard related vars
    handle dw ?                     ; url of file used to store score (scores.txt)
    filename db 'scores.txt', 0
    nameBuffer db 5 dup(?)
    scores db 00h, 7*50 dup (0)
    score dw 0
    scorebuffer db 000h, 000h
    username db 'ELSA$'

    newboulderpos dw 0          ; holds second obstacle pos
    firstboulderpos dw 0        ; holds first obstacle pos
    newSpriteLocator db 0       ; x pos to determine whether we printing the 2nd obstacle
    newSpriteFlag db 0          ; flag if new obstacle was printed alr
    didfirstend db 0            ; flag to determine if first obstacle has reached the end
    diedtowhat db 0             ; determine if we died to 1st or 2nd obstacle

    isBird db 0          ; flag to check if current obstacle is a bird
    isNewBird db 0
    birdYPosition db 08h       ; Y-position of the bird (update to match your bird sprite)
    firstObstacleType db 0     ; 0 = boulder/cacti, 1 = bird, 2 = potion
    secondObstacleType db 0    ; 0 = boulder/cacti, 1 = bird, 2 = potion
    isPotion db 0             ; flag to check if current obstacle is a potion
    isNewPotion db 0          ; flag for second potion

    birdHitboxHeight db 02h

    ; array for different obstacles
    sprites dw OFFSET boulder, OFFSET boulder2, OFFSET boulder3, OFFSET cacti, OFFSET cacti2, OFFSET bird, OFFSET potion
.code

main PROC
    mov ax, @code
    mov ds, ax
    ; screen initialization
    mov ax, 0013h
    int 10h

    mov ax, @data
    mov ds, ax

    call cls

    ;var init:
    mov ones, 0
    mov tens, 0
    mov hundreds, 0
    mov thousands, 0
    mov hearts, 3
    mov score, 0
    mov firstjump, 0

    call resetDelay     ; initialize default spd of obstacles

    call menu
    call drawclouds
    ; dino animation
    mov al, 2           ; to know what dino sprite to print
    mov dx, 010bh       ; cursor pos of dino
    call drawDino

    lea si, arrow
    mov dx, 6464h
    call arrowMove      ; print arrow
    mov ans, 0
    promptLoop2:
        call ReadCharWithTimeout
        cmp ah, 48h         ; up arrow key
        je goUp
        cmp ah, 50h         ; down arrow key
        je goDown
        cmp al, 0dh         ; enter
        je confirm2
        mov curArrowPos, dx
        call walkCycle
        mov dx, curArrowPos
        jmp promptLoop2

    goUp:
        cmp dx, 6975h
        je startchoice
        cmp dx, 7f85h
        je hiscorechoice
        jmp returnPrompt

        startchoice:
            lea si, arrow
            call arrowMove
            lea si, arrow
            mov dx, 6464h
            call arrowMove
            mov ans, 0
            jmp promptLoop2

    goDown:
        cmp dx, 6464h
        je hiscoreChoice
        cmp dx, 6975h
        je exitchoice
        jmp returnPrompt

        hiscoreChoice:
            lea si, arrow
            call arrowMove
            lea si, arrow
            mov dx, 6975h
            call arrowMove
            mov ans, 1
            jmp promptLoop2

        exitChoice:
            lea si, arrow
            call arrowMove
            lea si, arrow
            mov dx, 7f85h
            call arrowMove
            mov ans, 2
            jmp promptLoop2

        returnPrompt:
        jmp promptLoop2

    confirm2:
        mov al, ans
        cmp al, 1
        je gotohiscore
        cmp al, 2
        je exitgame
        jmp maingame

    gotohiscore:
    call leaderboard

    exitgame:
    mov ah, 4CH
    int 21h

    maingame:
    call cls
    call drawhearts
    call drawclouds
    call drawclouds2
    cmp firstjump, 2
    jne gotutorial
    jmp m1

    gotutorial:
        call tutorial

    m1:
    ; draw default dino pos
    mov dx, 010bh
    mov dinoCycle, 2
    mov al, 2
    call drawDino
    mov curDinoXY, dx
    ; draw 0000 numbers
    call drawOnes
    mov dx, 1c00h
    lea si, num0
    call printSmallLetter
    mov dx, 1b00h
    lea si, num0
    call printSmallLetter
    mov dx, 1a00h
    lea si, num0
    call printSmallLetter
    infloop:
        mov newboulderpos, 0
        mov firstboulderpos, 0
        mov newSpriteFlag, 0
        mov newSpriteLocator, 0
        mov didfirstend, 0
        mov firstObstacleType, 0  ; Reset obstacle type

        mov counter, 0
        call getRandomNumber
        cmp isBird, 1
        je spawn_first_bird
        cmp isPotion, 1
        je spawn_first_potion
        call drawBoulder
        mov firstObstacleType, 0  ; Set as ground obstacle
        jmp after_first_spawn

        spawn_first_bird:
        call drawBird
        mov firstObstacleType, 1    ; Mark as bird type
        mov isBird, 0               ; Reset flag
        jmp after_first_spawn

        spawn_first_potion:
        call drawPotion
        mov firstObstacleType, 2    ; Mark as potion type
        mov isPotion, 0             ; Reset flag
        jmp after_first_spawn

       after_first_spawn:
       mov firstboulderpos, dx

        l1:
            jmp checkEnd
        l3:
            cmp newSpriteFlag, 1
            je l2
            mov dx, firstboulderpos
            cmp dh, newSpriteLocator
            je printnewsprite
        l2:
            call ReadCharWithTimeout
            cmp al, 'w'
            je moveup
            cmp al, ' '
            je moveUp
            cmp al, 'x'
            je gomain
            call decPos


         skipUpdate:
            call printDebugInfo
            call checkCollision
            inc counter
            cmp counter, 3
            jne l1
            jmp animate


    checkEnd:
        cmp didfirstend, 1
        je l4
        mov dx, firstboulderpos
        cmp dh, 00h
        jle slidestop1
        mov firstboulderpos, dx
        jmp l4

    slidestop1:
        ; Clear the first obstacle before drawing the new one
        mov dx, firstboulderpos
        cmp firstObstacleType, 1
        je clear_bird1_slide
        cmp firstObstacleType, 2
        je clear_potion1_slide
        mov al, 0
        call drawBoulder2
        jmp after_clear1

    clear_bird1_slide:
        mov dl, birdYPosition
        mov al, 0
        call drawBird
        jmp after_clear1

    clear_potion1_slide:
        mov dl, birdYPosition
        mov al, 0
        call drawPotion

    after_clear1:
        call drawBoulder2
        mov didfirstend, 1
        mov firstboulderpos, dx
        call drawOnes
        l4:
        cmp newSpriteFlag, 1
        jne l3
        mov dx, newboulderpos
        cmp dh, 00h
        je slidestop2
        mov newboulderpos, dx
        jmp l3

    slidestop2:
        ; Clear the second obstacle before drawing the new one
        mov dx, newboulderpos
        cmp secondObstacleType, 1
        je clear_bird2_slide
        cmp secondObstacleType, 2
        je clear_potion2_slide
        mov al, 0
        call drawBoulder4
        jmp after_clear2

    clear_bird2_slide:
        mov dl, birdYPosition
        mov al, 0
        call drawBird2
        jmp after_clear2

    clear_potion2_slide:
        mov dl, birdYPosition
        mov al, 0
        call drawPotion2

    after_clear2:
        call drawBoulder4
        call drawOnes
        call decDelay
        jmp infloop

    printnewsprite:
        mov firstboulderpos, dx
        mov dx, 150bh
        ; Clear any existing second obstacle before drawing new one
        cmp newSpriteFlag, 1
        jne skip_clear
        mov dx, newboulderpos
        cmp secondObstacleType, 1
        je clear_bird2_new
        cmp secondObstacleType, 2
        je clear_potion2_new
        mov al, 0
        call drawBoulder4
        jmp skip_clear

    clear_bird2_new:
        mov dl, birdYPosition
        mov al, 0
        call drawBird2
        jmp skip_clear

    clear_potion2_new:
        mov dl, birdYPosition
        mov al, 0
        call drawPotion2

    skip_clear:
        mov dx, 150bh
        call drawBoulder2
        call drawBoulder2

        call getRandomNumber2
        cmp isNewBird, 1
        je spawn_second_bird
        cmp isNewPotion, 1
        je spawn_second_potion
        call drawBoulder3
        jmp after_second_spawn

        spawn_second_bird:
        call drawBird2
        mov secondObstacleType, 1   ; Mark as bird type
        mov isNewBird, 0            ; Reset flag
        jmp after_second_spawn

        spawn_second_potion:
        call drawPotion2
        mov secondObstacleType, 2   ; Mark as potion type
        mov isNewPotion, 0          ; Reset flag
        jmp after_second_spawn

        after_second_spawn:
        mov newboulderpos, dx
        mov newSpriteFlag, 1
        jmp l2

        animate:
            mov counter, 0
            mov dx, 010bh
            mov al, dinoCycle
            cmp al, 2
            je leftfoot2
            cmp al, 3
            je rightfoot2
            mov al, 0
            call drawDino
            mov al, 2
            call drawDino
            mov dinoCycle, 2
            jmp l4

            leftfoot2:
                mov al, 2
                call drawDino
                mov al, 3
                call drawDino
                mov dinoCycle, 3
                jmp l4

            rightfoot2:
                mov al, 3
                call drawDino
                mov al, 2
                call drawDino
                mov dinoCycle, 2
                jmp l4

    gotutorial2:
        call tutorial
        jmp m2

    ; dino jump while still continuing obstacle slide
    moveup:
    cmp firstjump, 2
    jne gotutorial2
    m2:
    mov dx, 010bh
    mov ecx, 4
    mov isJumpFall, 1
    jumpLoop:
        ; Clear current position first
        mov al, 0
        call drawDino
        ; Update position for next frame
        dec dl
        mov curDinoXY, dx
        ; Draw dino at new position
        mov al, 2
        call drawDino
        call delayy
        call printDebugInfo
        call checkEnd2
        l5:
        call checkCollision
        mov dx, curDinoXY
    loop jumpLoop
    mov ecx, 4
    mov isJumpFall, 0
    fallLoop:
        ; Clear current position first
        mov al, 0
        call drawDino
        ; Update position for next frame
        inc dl
        mov curDinoXY, dx
        ; Draw dino at new position
        mov al, 2
        call drawDino
        call delayy
        call printDebugInfo
        call checkEnd2
        call checkCollision
        l6:
        mov dx, curDinoXY
    loop fallLoop
    ; Clear final position
    mov al, 0
    call drawDino
    ; Reset to base position
    mov dx, 010bh
    mov curDinoXY, dx
    ; Draw final dino
    mov al, 2
    call drawDino
    mov diedtowhat, 2
    call checkCollision
    mov diedtowhat, 0
    jmp l1

checkend2:
    cmp didfirstend, 1
    je checkNewSprite
    mov dx, firstboulderpos
    cmp dh, 00h
    je stopfirst
    cmp newspriteflag, 1
    je decboth
    cmp dh, newSpriteLocator
    je printNewSprite2
    jmp decfirst

    checkNewSprite:
    mov dx, newboulderpos
    cmp dh, 00h
    je restart
    jmp decnew

    restart:
        call decdelay
        call drawBoulder4
        call drawOnes
        mov newboulderpos, 0
        mov firstboulderpos, 0
        mov newSpriteFlag, 0
        mov newSpriteLocator, 0
        mov didfirstend, 0
        call getRandomNumber

        call drawBoulder
        mov firstboulderpos, dx
        jmp isjumping

    stopfirst:
        call drawBoulder2
        mov firstboulderpos, dx
        mov didfirstend, 1
        call drawOnes
        jmp decnew

    decnew:
        mov dx, newboulderpos
        call drawBoulder4
        dec dh
        call drawBoulder4
        call delayy
        mov newboulderpos, dx
        jmp isjumping

    decboth:
        call drawBoulder2
        dec dh
        call drawBoulder2
        call delayy
        mov firstboulderpos, dx
        mov dx, newboulderpos
        call drawBoulder4
        dec dh
        call drawBoulder4
        mov newboulderpos, dx
        jmp isjumping

    decfirst:
        call drawBoulder2
        dec dh
        call drawBoulder2
        call delayy
        mov firstboulderpos, dx
        jmp isjumping

    printNewSprite2:
        mov firstboulderpos, dx
        mov dx, 150bh
        call drawBoulder2
        call drawBoulder2
        call drawBoulder3
        mov newboulderpos, dx
        mov newSpriteFlag, 1
        mov dx, firstboulderpos
        call decfirst

    isjumping:
        mov al, isJumpFall
        cmp al, 1
        je l5
        jmp l6

    goMain:
        call main

main ENDP

decPos proc
    cmp didfirstend, 1
    je addDelay
    mov dx, firstboulderpos
    ; Check if obstacle is at dino's position
    cmp dh, 01h
    je clear_first_obstacle
    call drawBoulder2
    dec dh
    call drawBoulder2
    call delay
    mov firstboulderpos, dx
    cmp newSpriteFlag, 1
    jne returnsequence
    mov dx, newboulderpos
    ; Check if second obstacle is at dino's position
    cmp dh, 01h
    je clear_second_obstacle
    call drawBoulder4
    dec dh
    call drawBoulder4
    mov newboulderpos, dx
    returnsequence:
    ret

    clear_first_obstacle:
    ; Clear first obstacle if it reaches dino's position
    mov al, 0
    call drawBoulder2
    mov firstboulderpos, 0
    mov didfirstend, 1
    jmp returnsequence

    clear_second_obstacle:
    ; Clear second obstacle if it reaches dino's position
    mov al, 0
    call drawBoulder4
    mov newboulderpos, 0
    mov newSpriteFlag, 0
    jmp returnsequence

    addDelay:
    cmp newSpriteFlag, 1
    jne returnsequence
    mov dx, newboulderpos
    ; Check if second obstacle is at dino's position
    cmp dh, 01h
    je clear_second_obstacle
    call drawBoulder4
    dec dh
    call drawBoulder4
    call delay
    mov newboulderpos, dx
    ret
decPos endp

writeToRec proc  ; insert new score into hiscore list
    ; fetch handle
    mov ax, 3d02h
    lea dx, filename
    int 21h
    jnc continueReading2

    ; create file if there is an error opening file
    mov ax, 3c00h
    mov cx, 0
    lea dx, filename
    int 21h

    continueReading2:
    mov handle, ax ; return ax as handle

    ; go to start of file
    mov ax, 4200h
    mov bx, handle
    mov cx, 0
    mov dx, 0
    int 21h

    ; read from file
    mov ah, 3fh
    mov bx, handle
    mov cx, 2eh             ; 7*5 + 1
    lea dx, scores
    int 21h

    ; insert rec
    lea di, scores
    xor ax, ax
    mov al, byte ptr [di]
    mov bl, 07h       ; go to the last score rec
    mul bl
    xor ah, ah
    add di, ax        ; move di to the the last byte of the last rec
    add di, 01h
    insrec:
        lea si, username
        mov cx, 05h
        inpname:      ; insert each letter of the username into last rec
            mov dl, byte ptr [si]
            mov byte ptr [di], dl
            inc si
            inc di
        loop inpname
            lea si, scorebuffer ; insert score
            mov dh, byte ptr [si]
            mov dl, byte ptr [si+1]
            mov byte ptr [di], dh
            mov byte ptr [di+1], dl

            ; increment score size
            lea si, scores
            mov ch, byte ptr [si]
            inc ch
            mov byte ptr [si], ch

            ;sort using bubble sort
            mov dh, ch
            ; ch = outer loop counter
            ; dh = inner loop counter
            outsort:
                lea si, scores
                lea di, scores
                add si, 07h  ; 07h is the low byte of the first rec score
                add di, 07h
                push cx
                mov ch, dh
                insort:
                    mov di, si
                    mov ah, byte ptr [si]
                    mov al, byte ptr [si-1]
                    mov bh, byte ptr [si+7]
                    mov bl, byte ptr [si+6]
                    cmp ax, bx
                    jge noswap
                    add di, 01h
                    sub si, 06h
                    mov dl, 07h
                    swapscore:
                        mov bh, byte ptr [di]
                        mov bl, byte ptr [si]
                        mov byte ptr [di], bl
                        mov byte ptr [si], bh
                        inc si
                        inc di
                        dec dl
                        jnz swapscore
                    noswap:
                    add si, 07h
                    dec ch
                jnz insort
                pop cx
                dec dh
                dec ch
            jnz outsort

            ; cap hiscores to 5 recs
            lea si, scores
            mov al, byte ptr [si]
            cmp al, 05h
            jle undercap
            mov al, 05h
            undercap:
            mov byte ptr[si], al

            ; go to start of file
            mov ax, 4200h
            mov bx, handle
            mov cx, 0
            mov dx, 0
            int 21h
            ; write to file
            mov ah, 40h
            mov bx, handle
            lea dx, scores
            mov cx, 2eh
            int 21h
            ; close file
            mov ah, 3eh
            mov bx, handle
            int 21h
            ret
writeToRec endp


tutorial proc
    mov dx, 8761h
    lea si, wtojump
    call calcXYbuffer
    mov bx, 1907h
    call drawImg
    add dh, 19h
    lea si, wtojump2
    call calcXYbuffer
    mov bx, 1e07h
    call drawImg
    inc firstjump
    ret
tutorial endp

walkCycle proc
    push ax
    mov dx, 010bh
    mov al, dinoCycle
    cmp al, 2
    je rightfoot
    cmp al, 3
    je leftfoot

    rightfoot:
    mov al, 2
    call drawDino
    mov al, 3
    call drawDino
    call longDelay
    mov dinoCycle, 3
    pop ax
    ret

    leftfoot:
    mov al, 3
    call drawDino
    mov al, 2
    call drawDino
    call longDelay
    call longDelay
    mov dinoCycle, 2
    pop ax
    ret
walkCycle endp

leaderboard proc
    call cls
    call drawclouds
    mov dx, 0c510h
    lea si, cloud2
    call calcXYbuffer
    mov bx, 1e0ch
    call drawImg
    ;call drawclouds2
    call leaderboardScreen
    ; fetch handle
    mov ax, 3d02h
    lea dx, filename
    int 21h
    jnc continueReading

    mov ax, 3c00h
    mov cx, 0
    lea dx, filename
    int 21h

    mov bx, handle
    lea dx, scores
    mov ax, 4000h
    mov cx, 1
    int 21h
    jmp promptLoop3

    continueReading:
    mov handle, ax
    ; go to start of file
    mov ax, 4200h
    mov bx, handle
    mov cx, 0
    mov dx, 0
    int 21h

    ; read from file
    mov ah, 3fh
    mov bx, handle
    mov cx, 2eh           ; 7*5 + 1
    lea dx, scores
    int 21h

    lea si, scores
    mov ch, byte ptr [si] ; ch = number of records (05h)
    cmp ch, 0
    je promptLoop3
    inc si                ; inc bcuz actual data starts from si+1
    mov dx, 0710h
    push dx
    iterScores:
        lea di, nameBuffer
        mov cl, 05h       ; 4 letter name + '$'
        nameloop:
            mov dl, byte ptr [si]
            mov byte ptr [di], dl
            inc di
            inc si
            dec cl
            jnz nameloop

        mov ah, 02h
        mov dl, 0ah
        int 21h

        mov ah, 02h           ; BIOS set cursor position function
        mov bh, 00h           ; Page number (usually 0)
        pop dx
        int 10h               ; Call BIOS interrupt 10h to set cursor position
        add dh, 2
        push dx

        lea dx, nameBuffer
        mov ah, 09h
        int 21h

        mov ah, 02h
        mov dl, 20h
        int 21h

        mov ah, byte ptr [si]
        inc si
        mov al, byte ptr [si]
        push cx
        mov cx, 04h     ; 0000 format score
        hexToDec:       ; convert to decimal
            xor dx, dx
            mov bx, 0ah
            div bx
            push dx
        loop hexToDec
        mov cx, 04h
        printNum:       ; print score
            pop dx
            add dx, '0'
            mov ah, 02
            int 21h
        loop printNum
        inc si
        pop cx
        dec ch
        mov ah, 02h
        mov dl, 10
        int 21h
    jnz iterScores
    promptLoop3:
        call readchar
        cmp al, 'b'
        je goBackMain
        jmp promptLoop3
    goBackMain:
        call main
leaderboard endp

cls proc
    mov ax, 0A000h
    mov es, ax
    ; Use bgColor for background
    xor di, di
    mov cx, 320*185
    mov al, bgColor
    rep stosb

    mov cx, 320*20
    mov al, grassColor         ; Use grassColor for grass
    rep stosb
    ret
cls endp

deadcls proc
    ; Clear first obstacle (bird, potion, or boulder)
    mov dx, firstboulderpos
    cmp firstObstacleType, 1
    je clear_bird1
    cmp firstObstacleType, 2
    je clear_potion1
    ; Otherwise, it's a boulder
    mov al, 0
    call drawBoulder2
    jmp after_clear1

clear_bird1:
    mov dl, birdYPosition
    mov al, 0
    call drawBird
    jmp after_clear1

clear_potion1:
    mov dl, birdYPosition
    mov al, 0
    call drawPotion

after_clear1:
    ; Clear second obstacle if present
    cmp newSpriteFlag, 1
    jne after_clear2
    mov dx, newboulderpos
    cmp secondObstacleType, 1
    je clear_bird2
    cmp secondObstacleType, 2
    je clear_potion2
    ; Otherwise, it's a boulder
    mov al, 0
    call drawBoulder4
    jmp after_clear2

clear_bird2:
    mov dl, birdYPosition
    mov al, 0
    call drawBird2
    jmp after_clear2

clear_potion2:
    mov dl, birdYPosition
    mov al, 0
    call drawPotion2

after_clear2:
    call cls
    mov dx, 010bh
    mov al, 1       ; flag for dead dino sprite
    call drawDino   ; draw dead dino sprite
    call gameOverScreen
    call drawclouds
    call drawclouds2
    call tryAgainScreen
    lea si, arrow
    mov dx, 706dh
    call arrowMove
    mov ans, 0
    promptLoop:
        call ReadChar
        cmp al, 4bh
        je goLeft
        cmp al, 4dh
        je goRight
        cmp al, 0dh
        je confirm
        jmp promptLoop

    goLeft:
        lea si, arrow
        sub dh, 56
        call arrowMove
        lea si, arrow
        add dh, 56
        call arrowMove
        mov ans, 0
        jmp promptLoop

    goRight:
        lea si, arrow
        mov dx, 706dh
        call arrowMove
        lea si, arrow
        add dh, 56
        call arrowMove
        mov ans, 1
        jmp promptLoop

    confirm:
        mov al, ans
        cmp al, 0
        je yesAns
        call main
        yesAns:
        call restartGame

deadcls endp

arrowMove proc
    call calcXYbuffer
    mov bx, 070ch
    call drawImg
    ret
arrowMove endp

restartGame proc
    mov ones, 0
    mov tens, 0
    mov hundreds, 0
    mov thousands, 0
    mov hearts, 3
    mov score, 0
    mov dinoCycle, 2
    mov firstjump, 0
    call resetDelay
    call drawclouds
    call drawclouds2

    mov ax, @code
    mov ds, ax

    call cls
    call drawclouds
    call drawclouds2

    mov ax, @data
    mov ds, ax

    cmp firstjump, 2
    jne gotutorial3
    jmp m3

    gotutorial3:
        call tutorial

    m3:
    mov dx, 010bh
    mov al, 2
    call drawDino
    mov curDinoXY, dx
    call drawOnes
    mov dx, 1c00h
    lea si, num0
    call printSmallLetter
    mov dx, 1b00h
    lea si, num0
    call printSmallLetter
    mov dx, 1a00h
    lea si, num0
    call printSmallLetter

    call drawhearts

    jmp infloop
restartGame endp

decDelay PROC
    cmp delayVarBig, 20000
    jle skipDec

    sub delayVarBig, 3791
    sub delayVarMed, 2067
    ;sub delayVarSmol, 1000

    skipDec:
        ret
decDelay ENDP

resetDelay PROC
    mov delayVarBig, 65500
    mov delayVarMed, 35000
    mov delayVarSmol, 15000
    ret
resetDelay ENDP

printDebugInfo PROC
    push ax
    push bx
    push cx
    push dx

    ; Save screen position to restore after debug
    mov ah, 03h  ; Get cursor position
    mov bh, 0    ; Page number
    int 10h      ; DH=row, DL=column
    push dx      ; Save cursor position

    ; Position cursor for debug info
    mov ah, 02h
    mov bh, 0
    mov dh, 1    ; Row 1
    mov dl, 1    ; Column 1
    int 10h

    ; Print bird position
    mov ah, 02h
    mov dl, 'B'  ; B for Bird
    int 21h
    mov dl, ':'
    int 21h

    mov al, birdYPosition
    add al, '0'  ; Convert to ASCII
    mov dl, al
    int 21h

    ; Space
    mov dl, ' '
    int 21h

    ; Print dino position
    mov dl, 'D'  ; D for Dino
    int 21h
    mov dl, ':'
    int 21h

    mov dx, curDinoXY
    mov al, dl   ; Get Y position
    add al, '0'  ; Convert to ASCII
    mov dl, al
    int 21h

    ; Restore cursor position
    pop dx
    mov ah, 02h
    mov bh, 0
    int 10h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
printDebugInfo ENDP

checkCollision PROC
    push ax
    push bx
    push dx

    ; Get positions
    mov dx, firstboulderpos  ; Get obstacle position
    mov bx, curDinoXY        ; Get dino position

    ; if they match, we may have a collision
    cmp bh, dh               ; Compare X positions
    jne check_second_obstacle

    ; First check if it's a potion
    cmp firstObstacleType, 2 ; 2 = potion
    je check_potion_first

    ; Then check if it's a bird
    cmp firstObstacleType, 1 ; 1 = bird
    je check_bird_first

    ; If not potion or bird, it's a ground obstacle
    mov al, dl               ; Obstacle Y position
    sub al, bl               ; Subtract dino Y position
    cmp al, 0                ; Check if Y positions match
    je collision_with_first
    jmp check_second_obstacle

check_potion_first:
    ; Potion collection logic
    mov al, bl               ; Dino Y position
    mov ah, birdYPosition    ; Potion Y position
    
    ; If dino Y <= potion Y + height, dino is within or below potion
    add ah, birdHitboxHeight
    cmp al, ah
    jg no_collision
    
    ; Now check if dino is high enough to hit potion
    mov ah, birdYPosition
    cmp al, ah
    jl no_collision
    
    ; If we got here, dino Y is between potion top and bottom - COLLECT!
    jmp collect_potion_first

check_bird_first:
    ; Bird collision logic - compare dino's Y position with bird's position
    mov al, bl               ; Dino Y position (Y component of curDinoXY)
    mov ah, birdYPosition    ; Bird Y position

    ; If dino Y <= bird Y + height, dino is within or below bird, COLLISION POSSIBLE
    add ah, birdHitboxHeight    ; Bird Y position + height
    cmp al, ah               ; Compare: Is dino below bird bottom?
    jg no_collision          ; If dino Y > bird bottom Y, no collision

    ; Now check if dino is high enough to hit bird
    mov ah, birdYPosition
    cmp al, ah               ; Compare: Is dino above bird top?
    jl no_collision          ; If dino Y < bird Y, no collision

    ; If we got here, dino Y is between bird top and bottom - COLLISION!
    jmp collision_with_first

collect_potion_first:
    ; Clear the potion
    mov dx, firstboulderpos
    mov dl, birdYPosition
    mov al, 0
    call drawPotion
    
    ; Check if we have less than 3 hearts
    mov al, hearts
    cmp al, 3
    je add_score_first
    
    ; Recover a heart
    inc hearts
    mov dx, 1800h
    lea si, heart
    call printSmallLetter
    jmp after_potion_first
    
add_score_first:
    ; Add 20 points to score
    mov ax, score
    add ax, 20
    mov score, ax
    call drawOnes
    
after_potion_first:
    ; Clear the potion from the game and reset obstacle type
    mov firstboulderpos, 0
    mov firstObstacleType, 0
    mov isPotion, 0
    mov newSpriteFlag, 0  ; Reset sprite flag to allow new obstacles
    mov didfirstend, 1    ; Mark first obstacle as done
    jmp no_collision

collision_with_first:
    ; Collision with first obstacle (bird or ground obstacle)
    mov diedtowhat, 1
    pop dx
    pop bx
    pop ax
    call EmptyKeyboardBuffer
    dec hearts
    jmp gameOver

check_second_obstacle:
    ; Check if there's a second obstacle
    cmp newSpriteFlag, 1
    jne no_collision

    mov dx, newboulderpos    ; Get second obstacle position

    ; Simple X position check
    cmp bh, dh               ; Compare X positions
    jne no_collision

    ; First check if it's a potion
    cmp secondObstacleType, 2 ; 2 = potion
    je check_potion_second

    ; Then check if it's a bird
    cmp secondObstacleType, 1 ; 1 = bird
    je check_bird_second

    ; If not potion or bird, it's a ground obstacle
    mov al, dl               ; Obstacle Y position
    sub al, bl               ; Subtract dino Y position
    cmp al, 0                ; Check if Y positions match
    je collision_with_second
    jmp no_collision

check_potion_second:
    ; Potion collection logic for second potion
    mov al, bl               ; Dino Y position
    mov ah, birdYPosition    ; Potion Y position
    
    ; If dino Y <= potion Y + height, dino is within or below potion
    add ah, birdHitboxHeight
    cmp al, ah
    jg no_collision
    
    ; Now check if dino is high enough to hit potion
    mov ah, birdYPosition
    cmp al, ah
    jl no_collision
    
    ; If we got here, dino Y is between potion top and bottom - COLLECT!
    jmp collect_potion_second

check_bird_second:
    ; Bird collision logic for second bird
    mov al, bl               ; Dino Y position
    mov ah, birdYPosition    ; Bird Y position

    ; If dino Y <= bird Y + height, dino is within or below bird, COLLISION POSSIBLE
    add ah, birdHitboxHeight    ; Bird Y position + height
    cmp al, ah               ; Compare: Is dino below bird bottom?
    jg no_collision          ; If dino Y > bird bottom Y, no collision

    ; Now check if dino is high enough to hit bird
    mov ah, birdYPosition
    cmp al, ah               ; Compare: Is dino above bird top?
    jl no_collision          ; If dino Y < bird Y, no collision

    ; If we got here, dino Y is between bird top and bottom - COLLISION!
    jmp collision_with_second

collect_potion_second:
    ; Clear the potion
    mov dx, newboulderpos
    mov dl, birdYPosition
    mov al, 0
    call drawPotion2
    
    ; Check if we have less than 3 hearts
    mov al, hearts
    cmp al, 3
    je add_score_second
    
    ; Recover a heart
    inc hearts
    mov dx, 1800h
    lea si, heart
    call printSmallLetter
    jmp after_potion_second
    
add_score_second:
    ; Add 20 points to score
    mov ax, score
    add ax, 20
    mov score, ax
    call drawOnes
    
after_potion_second:
    ; Clear the potion from the game and reset obstacle type
    mov newboulderpos, 0
    mov secondObstacleType, 0
    mov isNewPotion, 0
    mov newSpriteFlag, 0  ; Reset sprite flag to allow new obstacles
    jmp no_collision

collision_with_second:
    ; Collision with second obstacle (bird or ground obstacle)
    mov diedtowhat, 2
    pop dx
    pop bx
    pop ax
    call EmptyKeyboardBuffer
    dec hearts
    jmp gameOver

no_collision:
    pop dx
    pop bx
    pop ax
    ret

gameOver:
    ; Store the collision position
    push dx
    
    ; Clear the dino at collision position first
    mov dx, curDinoXY
    mov al, 0
    call drawDino
    
    cmp diedtowhat, 1
    je boulder1print
    cmp diedtowhat, 2
    je boulder2print
    cmp diedtowhat, 3
    je boulder1print
    cmp diedtowhat, 4
    je boulder2print

boulder1print:
    mov dx, newboulderpos
    call drawBoulder4
    mov dx, firstboulderpos
    ; If it's a bird, we need to clear it at the bird's Y position
    cmp firstObstacleType, 1
    jne not_bird1
    mov dl, birdYPosition
    mov al, 0
    call drawBird      ; Clear the bird sprite
    jmp over1
not_bird1:
    call drawBoulder2
    jmp over1

boulder2print:
    mov dx, newboulderpos
    ; If it's a bird, we need to clear it at the bird's Y position
    cmp secondObstacleType, 1
    jne not_bird2
    mov dl, birdYPosition
    mov al, 0
    call drawBird      ; Clear the bird sprite
    jmp over1
not_bird2:
    call drawBoulder4
    jmp over1

over1:
    mov diedtowhat, 0
    ; Draw the dead dino at base position
    mov dx, 010bh
    mov al, 1       ; flag for dead dino sprite
    call drawDino   ; draw dead dino sprite
    mov al, hearts
    cmp al, 0
    jne reset

    call gameOverScreen
    call enterName
    mov dx, 1600h
    lea si, heart
    call printSmallLetter
    mov cx, 4
    mov dx, 0e0bh
    lea bp, username
    readcharacter:
        call ReadChar
        mov byte ptr ds:[bp], al
        inc bp
        call checkInput
        push si
        lea si, blank
        call printSmallLetter
        pop si
        call printSmallLetter
        inc dh
    loop readcharacter
    mov byte ptr ds:[bp], '$'
    mov ax, score
    dec ax
    lea si, scorebuffer
    mov byte ptr [si+1], al
    call writeToRec
    call deadcls

minus1:
    mov dx, 1800h
    lea si, heart
    call printSmallLetter
    call rloop

minus2:
    mov dx, 1700h
    lea si, heart
    call printSmallLetter
    call rloop

reset:
    mov al, hearts
    cmp al, 2
    je minus1
    cmp al, 1
    je minus2
    rloop:
        mov dx, 0f08h
        lea si, num3
        call printSmallLetter
        call longDelay
        call longDelay
        call longDelay
        call longDelay
        mov dx, 0f08h
        lea si, num3
        call printSmallLetter
        lea si, num2
        call printSmallLetter
        call longDelay
        call longDelay
        call longDelay
        call longDelay
        mov dx, 0f08h
        lea si, num2
        call printSmallLetter
        lea si, num1
        call printSmallLetter
        call longDelay
        call longDelay
        call longDelay
        call longDelay
        mov dx, 0f08h
        lea si, num1
        call printSmallLetter
        ; Clear dead dino
        mov dx, 010bh
        mov al, 0
        call drawDino
        ; Draw new dino
        mov al, 2
        call drawDino
        mov curDinoXY, dx
        call EmptyKeyboardBuffer
        call resetDelay
        jmp infloop

checkCollision ENDP

randomDelay PROC
    push ax
    push bx
    push cx
    push dx

        mov ah, 00h
        int 1ah

        mov ax, dx
        mov dx, 00h
        mov bx, 8h
        div bx
        add al, 1
        mov bx, 2
        mul bx

        mov cx, ax
        randDelayLoop:
            nop
        loop randDelayLoop



    pop dx
    pop cx
    pop bx
    pop ax
    ret
randomDelay ENDP

delayy PROC
MOV AX, @DATA
MOV DS, AX
    push cx
    push ax

    mov ecx, delayVarMed  ; delay speed
    delay_loop:
        nop         ; no operation
        loop delay_loop

    pop ax
    pop cx
    ret
Delayy ENDP

Delay PROC
MOV AX, @DATA
MOV DS, AX

    push cx
    push ax

    mov ecx, delayVarBig
    delay1:
        nop
        loop delay1

    mov ecx, delayVarSmol
    delay2:
        nop
        loop delay2

    pop ax
    pop cx
    ret
Delay ENDP

longDelay proc
MOV AX, @DATA
MOV DS, AX
    push cx
    push ax

    mov ax, 65500
    movzx ecx, ax   ; delay speed
    d1:
        nop
        loop d1

    mov ax, 65500
movzx ecx, ax
    d2:
        nop
        loop d2

     mov ax, 65500
movzx ecx, ax
    d3:
        nop
        loop d3

    pop ax
    pop cx
    ret
longDelay endp

ReadChar PROC
    mov ah, 07h
    int 21h
    ret
ReadChar ENDP

ReadCharWithTimeout PROC
    mov ah, 1
    int 16h
    jz noKey
    mov ah, 0
    int 16h
call EmptyKeyboardBuffer
    ret
    noKey:
    ret
ReadCharWithTimeout ENDP

EmptyKeyboardBuffer PROC
    push ax
    .more:
        mov  ah, 01h        ; BIOS.ReadKeyboardStatus
        int  16h            ; -> AX ZF
        jz   .done          ; No key waiting aka buffer is empty
        mov  ah, 00h        ; BIOS.ReadKeyboardCharacter
        int  16h            ; -> AX
        jmp  .more          ; Go see if more keys are waiting
    .done:
        pop  ax
        ret
EmptyKeyboardBuffer ENDP

checkColorTransition PROC
    push ax
    push bx
    push cx
    push dx

    ; Check if score is divisible by 5
    mov ax, score
    mov bl, 20
    div bl
    cmp ah, 0          ; If remainder is 0, score is divisible by 5
    jne skip_transition

    ; Toggle background color
    mov al, isYellowBg
    cmp al, 0
    je switch_to_yellow
    ; Switch back to cyan
    mov bgColor, 0Bh
    mov grassColor, 02h
    mov isYellowBg, 0
    jmp do_transition

switch_to_yellow:
    mov bgColor, 0Eh    ; Yellow background
    mov grassColor, 06h ; Brown grass
    mov isYellowBg, 1

do_transition:
    call cls            ; Redraw screen with new colors
    call drawclouds     ; Redraw clouds
    call drawclouds2
    
    ; Redraw hearts based on remaining lives
    mov al, hearts
    cmp al, 3
    je draw_three_hearts
    cmp al, 2
    je draw_two_hearts
    cmp al, 1
    je draw_one_heart
    jmp skip_hearts

draw_three_hearts:
    mov dx, 1800h
    lea si, heart
    call printSmallLetter
    mov dx, 1700h
    lea si, heart
    call printSmallLetter
    mov dx, 1600h
    lea si, heart
    call printSmallLetter
    jmp skip_hearts

draw_two_hearts:
    mov dx, 1700h
    lea si, heart
    call printSmallLetter
    mov dx, 1600h
    lea si, heart
    call printSmallLetter
    jmp skip_hearts

draw_one_heart:
    mov dx, 1600h
    lea si, heart
    call printSmallLetter

skip_hearts:
    ; Redraw score
    mov dx, 1d00h
    mov al, ones
    call drawOnes
    mov dx, 1c00h
    lea si, num0
    call printSmallLetter
    mov dx, 1b00h
    lea si, num0
    call printSmallLetter
    mov dx, 1a00h
    lea si, num0
    call printSmallLetter
    ; Draw dino at its current position only
    mov dx, curDinoXY
    mov al, 2
    call drawDino
    ; Redraw obstacles at their current positions after transition, only if visible
    mov dx, firstboulderpos
    cmp dh, 0
    jle skip_first_obstacle
    call drawBoulder2
skip_first_obstacle:
    cmp newSpriteFlag, 1
    jne skip_second_obstacle
    mov dx, newboulderpos
    cmp dh, 0
    jle skip_second_obstacle
    call drawBoulder4
skip_second_obstacle:

skip_transition:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
checkColorTransition ENDP

END main
