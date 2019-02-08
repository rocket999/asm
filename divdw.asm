assume cs:code,ss:stack
stack segment
	dw 8 dup(0)
stack ends
code segment 
start:
	mov ax,stack
	mov ss,ax
	mov sp,10h
	mov ax,4240h
	mov dx,000fh
	mov cx,0ah
	call divdw

	mov ax,4c00h
	int 21h
divdw: 
	push ax
	mov ax,dx
	mov dx,0
	div cx
	mov bx,ax   ;bx为商等会要到高位(dx),现在的dx是余数(rem(H/N)*65536)
	pop ax
	div cx
	mov cx,dx
	mov dx,bx
	ret
code ends
end start
