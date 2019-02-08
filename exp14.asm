assume cs:code
code segment
s:	db 9,8,7,4,2,0

start:
	mov si,offset s
	mov ax,cs
	mov ds,ax
	mov ax,0b800h
	mov es,ax
	mov di,160*12+36*2
	mov cx,6
flag:
	mov al,ds:[si]
	out 70h,al
	in al,71h
	call showtime
	cmp si,2
	jb showfk1
	je showfk2
	cmp si,5
	jb showfk3
next:
	inc si
	loop flag
	
	mov ax,4c00h
	int 21h

showfk1:
	mov byte ptr es:[di],'/'
	add di,2
	jmp short next

showfk2:
	mov byte ptr es:[di],' '
	add di,2
	jmp short next

showfk3:
	mov byte ptr es:[di],':'
	add di,2
	jmp short next

showtime:
	push ax
	push cx
	push es

	mov ah,al
	mov cl,4
	shr ah,cl
	and al,00001111b

	add ah,30h
	add al,30h

	mov byte ptr es:[di],ah
	mov byte ptr es:[di+2],al	;要加2
	add di,4

	pop es
	pop cx
	pop ax
	ret
code ends
end start
