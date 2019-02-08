assume cs:code
code segment
start:
	mov ax,cs
	mov ds,ax
	mov ax,0
	mov es,ax
	mov si,offset int7ch
	mov di,200h
	mov cx,offset int7ch_end-offset int7ch
	cld
	rep movsb		;安装中断例程

	cli
	mov word ptr es:[7ch*4],200h
	mov word ptr es:[7ch*4+2],0		;设置中断向量
	sti

	mov ah,3	;传入参数,ah为功能号,al传递颜色
	mov al,2
	int 7ch

	mov ax,4c00h
	int 21h

	org 200h		;下面的代码按指定的偏移地址进行计算标号地址

int7ch:
	jmp short set
    table dw sub1,sub2,sub3,sub4
set:
	push bx
	cmp ah,3
	ja sret
	mov bl,ah
	mov bh,0
	add bx,bx

	call word ptr table[bx]
sret:
	pop bx
	iret

sub1:
	push bx
	push cx
	push es
	
	mov bx,0b800h
	mov es,bx
	mov bx,0
	mov cx,2000
sub1s:
	mov byte ptr es:[bx],' '
	add bx,2
	loop sub1s

	pop es
	pop cx
	pop bx
	ret

sub2:
	push bx
	push cx
	push es
	
	mov bx,0b800h
	mov es,bx
	mov bx,1
	mov cx,2000
sub2s:
	and byte ptr es:[bx],11111000b
	or es:[bx],al
	add bx,2
	loop sub2s

	pop es
	pop cx
	pop bx
	ret

sub3:
	push bx
	push cx
	push es

	mov cl,4
	shl al,cl
	
	mov bx,0b800h
	mov es,bx
	mov bx,1
	mov cx,2000
sub3s:
	and byte ptr es:[bx],10001111b
	or es:[bx],al
	add bx,2
	loop sub3s

	pop es
	pop cx
	pop bx
	ret

sub4:
	push si
	push di
	push ds
	push es
	push cx

	mov si,0b800h
	mov ds,si
	mov es,si
	mov si,160
	mov di,0
	cld
	mov cx,24

sub4s:
	push cx
	mov cx,160
	rep movsb
	pop cx
	loop sub4s

	mov cx,80
cls:
	mov byte ptr es:[di],' '
	add di,2
	loop cls

	pop cx
	pop es
	pop ds
	pop di
	pop si
	ret

int7ch_end:nop
code ends
end start
