assume cs:code,ds:data,ss:stack
data segment
	db 'welcome to masm!'
	db 02h,24h,71h
data ends
stack segment
	dw 8 dup(0)
stack ends
code segment
start:
	mov ax,data
	mov ds,ax
	mov ax,stack
	mov ss,ax
	mov sp,10h
	mov ax,0b872h
	mov es,ax
	mov bx,0
	mov si,0
	mov di,0
	mov cx,3
 s0:push cx
 	mov di,0		;每次外层循环开始要给di和bx赋0
	mov bx,0
 	mov cx,16
 s1:
	mov al,ds:[di]
	mov es:[bx],al
	mov al,ds:10h[si]
	mov es:[bx+1],al	;不能内存到内存

	add bx,2
	inc di
	loop s1

	pop cx
	inc si		;取不同颜色

	mov ax,es
	add ax,0ah
	mov es,ax	;以上三句给段地址加0ah即给偏移地址加160d

	loop s0

	mov ax,4c00h
	int 21h
code ends
end start
