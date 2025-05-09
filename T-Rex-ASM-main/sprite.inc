.code
drawDino PROC 
    cmp al, 1       ;check whether dino is dead or not
    je deadDino
    cmp al, 2
    je rightDino
    cmp al, 3
    je leftDino
    mov al, 0
    call calcXY
    lea si, dino    ; load sprite to SI
    jmp returnSeq1
    
    deadDino:
    mov al, 0
    call calcXY
    lea si, dead
    jmp returnSeq1

    rightDino:
    mov al, 0
    call calcXY
    lea si, dino2
    jmp returnSeq1

    leftDino:
    mov al, 0
    call calcXY
    lea si, dino3
    jmp returnSeq1

    returnSeq1:
    mov bx, 0f0fh
    call drawImg
    ret
drawDino ENDP

getRandomNumber PROC
    push cx
    MOV AH, 00h  ; interrupts to get system time        
    INT 1AH      ; CX:DX now hold number of clock ticks since midnight      

    mov  ax, dx
    xor  dx, dx
    mov  cx, 10
    div  cx       ; here dx contains the remainder of the division - from 0 to 9
    
    cmp dl, 0
    je zero
    cmp dl, 1
    je one
    cmp dl, 2
    je two
    cmp dl, 3
    je three
    cmp dl, 4
    je four
    cmp dl, 5
    je five
    cmp dl, 6
    je six
    cmp dl, 7
    je seven
    cmp dl, 8
    je eight
    mov newSpriteLocator, 0bh
    jmp goBack
    zero:
    mov newSpriteLocator, 14h
    jmp goBack
    one:
    mov newSpriteLocator, 12h
    jmp goBack
    two:
    mov newSpriteLocator, 10h
    jmp goBack
    three:
    mov newSpriteLocator, 0eh
    jmp goBack
    four:
    mov newSpriteLocator, 0ch
    jmp goBack
    five:
    mov newSpriteLocator, 0ah
    jmp goBack
    six:
    mov newSpriteLocator, 08h
    jmp goBack
    seven:
    mov newSpriteLocator, 0bh
    jmp goBack
    eight:
    mov newSpriteLocator, 13h
    jmp goBack

    goBack:
    pop cx
    ret
getRandomNumber ENDP

drawBoulder PROC
    call getRandomNumber2
    mov ax, dx

    and ax, 3 

    mov bx, ax
    shl bx, 1       ; * 2 because each entry is a word
    
    mov randSprite, bx
    lea si, sprites
    add si, bx      
    mov si, [si]   

    mov al, 0
    mov dx, 150bh
    call calcXY
    mov bx, 0f0fh
    call drawImg
    ret
drawBoulder ENDP

drawBoulder2 proc
    mov al, 0
    call calcXY
    mov bx, randSprite
    lea si, sprites
    add si, bx      
    mov si, [si]    
    mov bx, 0f0fh
    call drawImg
    ret
drawBoulder2 endp

drawBoulder3 PROC
    call getRandomNumber2
    mov ax, dx
    ; random number is now in ax
    and ax, 3 ; assuming 4 sprites, we mask with 3 to get a number between 0 and 3

    mov bx, ax
    shl bx, 1       ; mul by 2 (each entry is a word)
    
    mov randSprite2, bx
    lea si, sprites
    add si, bx      
    mov si, [si]    

    mov al, 0
    mov dx, 150bh
    call calcXY
    mov bx, 0f0fh
    call drawImg
    ret
drawBoulder3 ENDP

drawBoulder4 proc
    mov al, 0
    call calcXY
    mov bx, randSprite2
    lea si, sprites
    add si, bx     
    mov si, [si]    
    mov bx, 0f0fh
    call drawImg
    ret
drawBoulder4 endp

getRandomNumber2 PROC
    push cx
    MOV AH, 00h  ; interrupts to get system time        
    INT 1AH      ; CX:DX now hold number of clock ticks since midnight      

    mov  ax, dx
    xor  dx, dx
    mov  cx, 5
    div  cx       ; here dx contains the remainder of the division - from 0 to 9
    pop  cx
    ret
getRandomNumber2 ENDP

printLetter PROC
    mov al, 0
    call calcXY
    mov bx, 0f0fh
    call drawImg
    ret
printLetter ENDP

printSmallLetter PROC
    mov al, 2
    call calcXY
    mov bx, 0a0ah
    call drawImg
    ret
printSmallLetter ENDP

calcXY PROC   ; calculate x and y pos of image
    push ax
    mov ax, @code
    mov ds, ax
    pop ax      
    push dx
    cmp al, 0
    je fifbyfif
    cmp al, 2
    je twobytwo
    cmp al, 3
    je onebyone

    fifbyfif:
    mov ax, 15      ; sprite size by pixel
    mul dh
    mov di, ax
    mov ax, 15*320 ; sprite size * screen size
    jmp returnSeq

    twobytwo:
    mov ax, 10      ; sprite size by pixel
    mul dh
    mov di, ax
    mov ax, 10*320 ; sprite size * screen size
    jmp returnSeq

    onebyone:
    mov ax, 1      ; sprite size by pixel
    mul dh
    mov di, ax
    mov ax, 1*320 ; sprite size * screen size
    jmp returnSeq

    returnSeq:
    mov bx, 0
    add bl, dl
    mul bx 
    add di, ax     ; placed all the calculated pos into DI
    pop dx 
    ret
calcXY ENDP

drawImg PROC 
    push cx 
    mov ax, 0A000h  ; segment address of video memory 
    mov es, ax      ; moving to es allows pixel manipulation 
    mov cl, bl  ; height
    y_axis:
        push di
        mov ch, bh ; width
    x_axis:
        mov al, [SI] ; ds:si (segment:offset), move 1 pixel db into al
        xor al, byte ptr es:[di]   ; xor al with first di pos
        mov byte ptr es:[di], al  ; updates the pixel on the screen with xor result
        inc si
        inc di
        dec ch
        jnz x_axis  
    pop di
    add di, 320     ; move to new line of sprite
    dec cl 
    jnz y_axis
    pop cx
    ret
drawImg ENDP

checkInput proc     ; check input for name
	cmp al, 'a'
    je letA
    cmp al, 'b'
    je letB
    cmp al, 'c'
    je letC
    cmp al, 'd'
    je letD
    cmp al, 'e'
    je letE
    cmp al, 'f'
    je letF
    cmp al, 'g'
    je letG
    cmp al, 'h'
    je letH
    cmp al, 'i'
    je letI
    cmp al, 'j'
    je letJ
    cmp al, 'k'
    je letK
    cmp al, 'l'
    je letL
    cmp al, 'm'
    je letM
    cmp al, 'n'
    je letN
    cmp al, 'o'
    je letO
    cmp al, 'p'
    je letP
    cmp al, 'q'
    je letQ
    cmp al, 'r'
    je letR
    cmp al, 's'
    je letS
    cmp al, 't'
    je letT
    cmp al, 'u'
    je letU
    cmp al, 'v'
    je letV
    cmp al, 'w'
    je letW
    cmp al, 'x'
    je letX
    cmp al, 'y'
    je letY
    cmp al, 'z'
    je letZ
    ret

    letA:
    lea si,  smallA
    ret
    letB:
    lea si,  smallB
    ret
    letC:
    lea si,  smallC
    ret
    letD:
    lea si,  smallD
    ret
    letE:
    lea si,  smallE
    ret
    letF:
    lea si,  smallF
    ret
    letG:
    lea si,  smallG
    ret
    letH:
    lea si,  smallH
    ret
    letI:
    lea si,  smallI
    ret
    letJ:
    lea si,  smallJ
    ret
    letK:
    lea si,  smallK
    ret
    letL:
    lea si,  smallL
    ret
    letM:
    lea si,  smallM
    ret
    letN:
    lea si,  smallN
    ret
    letO:
    lea si,  smallO
    ret
    letP:
    lea si,  smallP
    ret
    letQ:
    lea si,  smallQ
    ret
    letR:
    lea si,  smallR
    ret
    letS:
    lea si,  smallS
    ret
    letT:
    lea si,  smallT
    ret
    letU:
    lea si,  smallU
    ret
    letV:
    lea si,  smallV
    ret
    letW:
    lea si,  smallW
    ret
    letX:
    lea si,  smallX
    ret
    letY:
    lea si,  smallY
    ret
    letZ:
    lea si,  smallZ
    ret
checkInput endp

gameOverScreen PROC ; prints game over screen
    mov dx, 4e3ah
    lea si, bigg
    call calcXYbuffer
    mov bx, 1315h
    call drawImg
    add dh, 21
    lea si, biga
    call calcXYbuffer
    mov bx, 1215h
    call drawImg
    add dh, 20
    lea si, bigm
    call calcXYbuffer
    mov bx, 1415h
    call drawImg
    add dh, 22
    lea si, bige
    call calcXYbuffer
    mov bx, 1314h
    call drawImg
    add dh, 25
    lea si, bigo
    call calcXYbuffer
    mov bx, 1214h
    call drawImg
    add dh, 20
    lea si, bigv
    call calcXYbuffer
    mov bx, 1214h
    call drawImg
    add dh, 20
    lea si, bige
    call calcXYbuffer
    mov bx, 1314h
    call drawImg
    add dh, 21
    lea si, bigr
    call calcXYbuffer
    mov bx, 1214h
    call drawImg
    ret
gameOverScreen ENDP

enterName proc
    mov dx, 6b53h
    lea si, smallasse
    call calcXYbuffer
    mov bx, 0c0dh
    call drawImg
    add dh, 12
    lea si, smallassn
    call calcXYbuffer
    mov bx, 0a0dh
    call drawImg
    add dh, 10
    lea si, smallasst
    call calcXYbuffer
    mov bx, 0b0dh
    call drawImg
    add dh, 11
    lea si, smallasse
    call calcXYbuffer
    mov bx, 0c0dh
    call drawImg
    add dh, 12
    lea si, smallassr
    call calcXYbuffer
    mov bx, 0b0dh
    call drawImg
    add dh, 15
    lea si, smallassn
    call calcXYbuffer
    mov bx, 0a0dh
    call drawImg
    add dh, 10
    lea si, smallassa
    call calcXYbuffer
    mov bx, 0a0dh
    call drawImg
    add dh, 10
    lea si, smallassm
    call calcXYbuffer
    mov bx, 0e0dh
    call drawImg
    add dh, 14
    lea si, smallasse
    call calcXYbuffer
    mov bx, 0c0dh
    call drawImg
    mov bp, 0
    mov dx, 0e0bh
    blankLoop:
        lea si, blank
        call printSmallLetter
        inc dh
        inc bp
    cmp bp, 4
    jne blankLoop
    ret
enterName endp

calcXYbuffer proc
    mov al, 3
    call calcXY
    ret
calcXYbuffer endp

tryAgainScreen proc ; prints try again screen
    mov dx, 7154h
    lea si, smallasst
    call calcXYbuffer
    mov bx, 0b0dh
    call drawImg
    add dh, 11
    lea si, smallassr
    call calcXYbuffer
    mov bx, 0b0dh
    call drawImg
    add dh, 11
    lea si, smallassy
    call calcXYbuffer
    mov bx, 0c0dh
    call drawImg
    add dh, 15
    lea si, smallassa
    call calcXYbuffer
    mov bx, 0a0dh
    call drawImg
    add dh, 10
    lea si, smallassg
    call calcXYbuffer
    mov bx, 0b0dh
    call drawImg
    add dh, 11
    lea si, smallassa
    call calcXYbuffer
    mov bx, 0a0dh
    call drawImg
    add dh, 10
    lea si, smallassi
    call calcXYbuffer
    mov bx, 0a0dh
    call drawImg
    add dh, 10
    lea si, smallassn
    call calcXYbuffer
    mov bx, 0a0dh
    call drawImg
    add dh, 10
    lea si, questionmark
    call calcXYbuffer
    mov bx, 0b0dh
    call drawImg
    mov dx, 796dh
    lea si, smallassy
    call calcXYbuffer
    mov bx, 0c0dh
    call drawImg
    add dh, 12
    lea si, smallasse
    call calcXYbuffer
    mov bx, 0c0dh
    call drawImg
    add dh, 12
    lea si, smallasss
    call calcXYbuffer
    mov bx, 0c0dh
    call drawImg
    add dh, 32
    lea si, smallassn
    call calcXYbuffer
    mov bx, 0a0dh
    call drawImg
    add dh, 10
    lea si, smallasso
    call calcXYbuffer
    mov bx, 0b0dh
    call drawImg
    ret
tryAgainScreen endp

drawhearts proc
    mov dx, 1800h
    lea si, heart
    call printSmallLetter
    mov dx, 1700h
    lea si, heart
    call printSmallLetter
    mov dx, 1600h
    lea si, heart
    call printSmallLetter
    ret
drawhearts endp

menu proc
    mov dx, 4818h
    lea si, trex1
    call calcXYbuffer
    mov bx, 2112h
    call drawImg
    add dh, 33
    lea si, trex2
    call calcXYbuffer
    mov bx, 2112h
    call drawImg
    mov dx, 5d2ah
    lea si, trex3
    call calcXYbuffer
    mov bx, 3130h
    call drawImg
    add dh, 31h
    lea si, trex4
    call calcXYbuffer
    mov bx, 3030h
    call drawImg
    add dh, 30h
    lea si, trex5
    call calcXYbuffer
    mov bx, 3030h
    call drawImg
    add dh, 30h
    inc dl
    lea si, trex6
    call calcXYbuffer
    mov bx, 092eh
    call drawImg
    mov dx, 4d2ah
    lea si, trex7
    call calcXYbuffer
    mov bx, 1001h
    call drawImg
    mov dx, 6e64h
    lea si, smallasss
    call calcXYbuffer
    mov bx, 0c0dh
    call drawImg
    add dh, 12
    lea si, smallasst
    call calcXYbuffer
    mov bx, 0b0dh
    call drawImg
    add dh, 11
    lea si, smallassa
    call calcXYbuffer
    mov bx, 0a0dh
    call drawImg
    add dh, 10
    lea si, smallassr
    call calcXYbuffer
    mov bx, 0b0dh
    call drawImg
    add dh, 11
    lea si, smallasst
    call calcXYbuffer
    mov bx, 0b0dh
    call drawImg
    add dh, 14
    lea si, smallassg
    call calcXYbuffer
    mov bx, 0b0dh
    call drawImg
    add dh, 11
    lea si, smallassa
    call calcXYbuffer
    mov bx, 0a0dh
    call drawImg
    add dh, 10
    lea si, smallassm
    call calcXYbuffer
    mov bx, 0e0dh
    call drawImg
    add dh, 14
    lea si, smallasse
    call calcXYbuffer
    mov bx, 0c0dh
    call drawImg
    mov dx, 7375h
    lea si, smallassh
    call calcXYbuffer
    mov bx, 0a0dh
    call drawImg
    add dh, 10
    lea si, smallassi
    call calcXYbuffer
    mov bx, 0a0dh
    call drawImg
    add dh, 10
    add dl, 4
    lea si, dash
    call calcXYbuffer
    mov bx, 0605h
    call drawImg
    add dh, 6
    sub dl, 4
    lea si, smallasss
    call calcXYbuffer
    mov bx, 0c0dh
    call drawImg
    add dh, 12
    lea si, smallassc
    call calcXYbuffer
    mov bx, 0b0dh
    call drawImg
    add dh, 11
    lea si, smallasso
    call calcXYbuffer
    mov bx, 0b0dh
    call drawImg
    add dh, 11
    lea si, smallassr
    call calcXYbuffer
    mov bx, 0b0dh
    call drawImg
    add dh, 11
    lea si, smallasse
    call calcXYbuffer
    mov bx, 0c0dh
    call drawImg
    add dh, 12
    lea si, smallasss
    call calcXYbuffer
    mov bx, 0c0dh
    call drawImg
    mov dx, 8b85h
    lea si, smallasse
    call calcXYbuffer
    mov bx, 0c0dh
    call drawImg
    add dh, 12
    lea si, smallassx
    call calcXYbuffer
    mov bx, 0d0dh
    call drawImg
    add dh, 13
    lea si, smallassi
    call calcXYbuffer
    mov bx, 0a0dh
    call drawImg
    add dh, 10
    lea si, smallasst
    call calcXYbuffer
    mov bx, 0b0dh
    call drawImg
    ret
menu endp

drawclouds2 proc
    mov dx, 1c0bh
    lea si, cloud1
    call calcXYbuffer
    mov bx, 1e0fh
    call drawImg
    add dh, 75
    add dl, 5
    lea si, cloud1
    call calcXYbuffer
    mov bx, 1e0fh
    call drawImg
    ret
drawclouds2 endp

drawclouds proc
    mov dx, 3a02h
    lea si, cloud3
    call calcXYbuffer
    mov bx, 2d11h
    call drawImg
    mov dx, 1c0bh
    lea si, cloud1
    call calcXYbuffer
    mov bx, 1e0fh
    call drawImg
    mov dx, 0c510h
    lea si, cloud2
    call calcXYbuffer
    mov bx, 1e0ch
    call drawImg
    add dh, 1eh
    add dl, 2
    lea si, cloud3
    call calcXYbuffer
    mov bx, 2d11h
    call drawImg
    mov dx, 0235h
    lea si, cloud3
    call calcXYbuffer
    mov bx, 2d11h
    call drawImg
    add dh, 2eh
    add dl, 0ch
    lea si, cloud2
    call calcXYbuffer
    mov bx, 1e0ch
    call drawImg
    mov dx, 1b05h
    lea si, cloud3
    mov al, 2
    call calcXY
    mov bx, 2d11h
    call drawImg
    ret
drawclouds endp

leaderboardScreen proc
    mov dx, 7008h
    lea si, leaderboard1
    call calcXYbuffer
    mov bx, 2184h
    call drawImg
    add dh, 33
    add dl, 2
    lea si, leaderboard2
    call calcXYbuffer
    mov bx, 3008h
    call drawImg
    add dl, 26
    lea si, leaderboard3
    call calcXYbuffer
    mov bx, 3068h
    call drawImg
    add dh, 48
    mov dl, 08h
    lea si, leaderboard4
    call calcXYbuffer
    mov bx, 1984h
    call drawImg
    mov dx, 8092h
    lea si, bracketb
    call calcXYbuffer
    mov bx, 270fh
    call drawImg
    add dh, 40
    inc dl
    lea si, smallassa
    call calcXYbuffer
    mov bx, 0a0dh
    call drawImg
    add dh, 11
    lea si, smallassc
    call calcXYbuffer
    mov bx, 0b0dh
    call drawImg
    add dh, 12
    lea si, smallassk
    call calcXYbuffer
    mov bx, 0a0dh
    call drawImg
    ret
leaderboardScreen endp

