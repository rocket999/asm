assume cs:code
code segment
start:
	mov ax,cs
	mov ds,ax
	mov si,offset do
	mov ax,0
	mov es,ax
	mov di,200h
	mov cx,offset doend-offset do
	cld
	rep movsb

	mov ax,0
	mov es,ax
	mov word ptr es:[7ch*4],200h
	mov word ptr es:[7ch*4+2],0

	mov ax,4c00h
	int 21h

do:	push bp

	mov bp,sp
	dec cx 		;已经显示了一个!
	jcxz ok
	add [bp+2],bx
	
ok: pop bp
	iret

doend:nop
code ends
end start
