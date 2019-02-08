assume cs:code
code segment
start:
	mov ax,cs
	mov ds,ax
	mov ax,0
	mov es,ax
	mov si,offset int7ch
	mov di,200h
	mov cx,offset int7chend-offset int7ch
	cld
	rep movsb

	cli
	mov word ptr es:[7ch*4],200h
	mov word ptr es:[7ch*4+2],0
	sti
	
	mov ax,4c00h
	int 21h

int7ch:
	push ax
	push cx
	push dx 

	add ah,2
	mov al,1
	push ax			;计算ah,al

	mov ax,dx
	mov dx,0
	mov cx,1440
	div cx
	push ax			;此时al中为面号
	mov ax,dx
	mov dl,18
	div dl
	mov ch,al		;设置磁道号
	inc ah
	mov cl,ah		;设置扇区号
	pop ax
	mov dh,al		;设置面号
	mov dl,0

	pop ax			;设置ah,al
	int 13h

	pop	dx
	pop cx
	pop ax
	iret
int7chend:nop
code ends
end start
