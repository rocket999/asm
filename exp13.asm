assume cs:code
code segment
start:
	mov ax,cs
	mov ds,ax
	mov si,offset do
	mov ax,0
	mov es,ax		;es:di指向目标地址
	mov di,200h
	mov cx,offset doend-offset do
	cld			;正向传送
	rep movsb

	mov ax,0
	mov es,ax
	mov word ptr es:[7ch*4],200h
	mov word ptr es:[7ch*4+2],0

	mov ax,4c00h
	int 21h

do:	push ax
	push bx
	push cx
	push dx
	push ds
	push es
	push si
	push di
	
	mov ax,160
	mul dh
	mov bx,ax
	mov ax,2
	mul dl
	add bx,ax

	mov ax,0b800h
	mov es,ax
	
	mov ch,0
	mov di,0
	mov al,cl

s:	mov cl,ds:[si]
	jcxz ok
	mov es:[bx+di],cl
	mov es:[bx+di+1],al
	inc si
	add di,2
	jmp short s

ok:	pop	di
	pop si
	pop es
	pop ds
	pop dx
	pop cx
	pop bx
	pop ax
	iret

doend:nop
code ends
end start
