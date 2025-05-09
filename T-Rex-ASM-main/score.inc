.code
drawOnes proc
    mov dx, 1d00h
    mov al, ones
    cmp al, 0
    je print0
    cmp al, 1
    je print1
    cmp al, 2
    je print2
    cmp al, 3
    je print3
    cmp al, 4
    je print4
    cmp al, 5
    je print5
    cmp al, 6
    je print6
    cmp al, 7
    je print7
    cmp al, 8
    je print8
    cmp al, 9
    je print9
    cmp al, 10
    je goback0

    goback0:
    lea si, num9
    call printSmallLetter
    lea si, num0
    call printSmallLetter
    mov ones, 1
    inc tens
    call drawTens
    inc score
    ret
    print0:
    lea si, blank2
    call printSmallLetter
    lea si, num0
    call printSmallLetter
    inc ones
    inc score
    ret
    print1:
    lea si, num0
    call printSmallLetter
    lea si, num1
    call printSmallLetter
    inc ones
    inc score
    ret
    print2:
    lea si, num1
    call printSmallLetter
    lea si, num2
    call printSmallLetter
    inc ones
    inc score
    ret
    print3:
    lea si, num2
    call printSmallLetter
    lea si, num3
    call printSmallLetter
    inc ones
    inc score
    ret
    print4:
    lea si, num3
    call printSmallLetter
    lea si, num4
    call printSmallLetter
    inc ones
    inc score
    ret
    print5:
    lea si, num4
    call printSmallLetter
    lea si, num5
    call printSmallLetter
    inc ones
    inc score
    ret
    print6:
    lea si, num5
    call printSmallLetter
    lea si, num6
    call printSmallLetter
    inc ones
    inc score
    ret
    print7:
    lea si, num6
    call printSmallLetter
    lea si, num7
    call printSmallLetter
    inc ones
    inc score
    ret
    print8:
    lea si, num7
    call printSmallLetter
    lea si, num8
    call printSmallLetter
    inc ones
    inc score
    ret
    print9:
    lea si, num8
    call printSmallLetter
    lea si, num9
    call printSmallLetter
    mov newOnes, 1
    inc ones
    inc score
    ret
drawOnes endp

drawTens proc
    mov dx, 1c00h
    mov al, tens
    cmp al, 0
    je print00
    cmp al, 1
    je print10
    cmp al, 2
    je print20
    cmp al, 3
    je print30
    cmp al, 4
    je print40
    cmp al, 5
    je print50
    cmp al, 6
    je print60
    cmp al, 7
    je print70
    cmp al, 8
    je print80
    cmp al, 9
    je print90
    cmp al, 10
    je goback00

    goback00:
    lea si, num9
    call printSmallLetter
    lea si, num0
    call printSmallLetter
    mov tens, 0
    inc hundreds
    call drawHundreds
    ret
    print00:
    lea si, blank2
    call printSmallLetter
    lea si, num0
    call printSmallLetter
    ret
    print10:
    lea si, num0
    call printSmallLetter
    lea si, num1
    call printSmallLetter
    ret
    print20:
    lea si, num1
    call printSmallLetter
    lea si, num2
    call printSmallLetter
    ret
    print30:
    lea si, num2
    call printSmallLetter
    lea si, num3
    call printSmallLetter
    ret
    print40:
    lea si, num3
    call printSmallLetter
    lea si, num4
    call printSmallLetter
    ret
    print50:
    lea si, num4
    call printSmallLetter
    lea si, num5
    call printSmallLetter
    ret
    print60:
    lea si, num5
    call printSmallLetter
    lea si, num6
    call printSmallLetter
    ret
    print70:
    lea si, num6
    call printSmallLetter
    lea si, num7
    call printSmallLetter
    ret
    print80:
    lea si, num7
    call printSmallLetter
    lea si, num8
    call printSmallLetter
    ret
    print90:
    lea si, num8
    call printSmallLetter
    lea si, num9
    call printSmallLetter
    mov newTens, 1
    ret
drawTens endp

drawHundreds proc
    mov dx, 1b00h
    mov al, hundreds
    cmp al, 0
    je print000
    cmp al, 1
    je print100
    cmp al, 2
    je print200
    cmp al, 3
    je print300
    cmp al, 4
    je print400
    cmp al, 5
    je print500
    cmp al, 6
    je print600
    cmp al, 7
    je print700
    cmp al, 8
    je print800
    cmp al, 9
    je print900
    cmp al, 10
    je goback000

    goback000:
    lea si, num9
    call printSmallLetter
    lea si, num0
    call printSmallLetter
    mov hundreds, 0
    inc thousands
    call drawThousands
    ret
    print000:
    lea si, blank2
    call printSmallLetter
    lea si, num0
    call printSmallLetter
    ret
    print100:
    lea si, num0
    call printSmallLetter
    lea si, num1
    call printSmallLetter
    ret
    print200:
    lea si, num1
    call printSmallLetter
    lea si, num2
    call printSmallLetter
    ret
    print300:
    lea si, num2
    call printSmallLetter
    lea si, num3
    call printSmallLetter
    ret
    print400:
    lea si, num3
    call printSmallLetter
    lea si, num4
    call printSmallLetter
    ret
    print500:
    lea si, num4
    call printSmallLetter
    lea si, num5
    call printSmallLetter
    ret
    print600:
    lea si, num5
    call printSmallLetter
    lea si, num6
    call printSmallLetter
    ret
    print700:
    lea si, num6
    call printSmallLetter
    lea si, num7
    call printSmallLetter
    ret
    print800:
    lea si, num7
    call printSmallLetter
    lea si, num8
    call printSmallLetter
    ret
    print900:
    lea si, num8
    call printSmallLetter
    lea si, num9
    call printSmallLetter
    mov newHundreds, 1
    ret
drawHundreds endp

drawThousands proc
    mov dx, 1a00h
    mov al, thousands
    cmp al, 0
    je print0000
    cmp al, 1
    je print1000
    cmp al, 2
    je print2000
    cmp al, 3
    je print3000
    cmp al, 4
    je print4000
    cmp al, 5
    je print5000
    cmp al, 6
    je print6000
    cmp al, 7
    je print7000
    cmp al, 8
    je print8000
    cmp al, 9
    je print9000
    
    print0000:
    lea si, num9
    call printSmallLetter
    lea si, num0
    call printSmallLetter
    ret
    print1000:
    lea si, num0
    call printSmallLetter
    lea si, num1
    call printSmallLetter
    ret
    print2000:
    lea si, num1
    call printSmallLetter
    lea si, num2
    call printSmallLetter
    ret
    print3000:
    lea si, num2
    call printSmallLetter
    lea si, num3
    call printSmallLetter
    ret
    print4000:
    lea si, num3
    call printSmallLetter
    lea si, num4
    call printSmallLetter
    ret
    print5000:
    lea si, num4
    call printSmallLetter
    lea si, num5
    call printSmallLetter
    ret
    print6000:
    lea si, num5
    call printSmallLetter
    lea si, num6
    call printSmallLetter
    ret
    print7000:
    lea si, num6
    call printSmallLetter
    lea si, num7
    call printSmallLetter
    ret
    print8000:
    lea si, num7
    call printSmallLetter
    lea si, num8
    call printSmallLetter
    ret
    print9000:
    lea si, num8
    call printSmallLetter
    lea si, num9
    call printSmallLetter
    mov newThousands, 1
    mov thousands, 0
    ret
drawThousands endp
