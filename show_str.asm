assume cs:code,ds:data
data segment
	db 'welcome to masm!',0
data ends

code segment
start: mov dh,8
	   mov dl,8
	   mov cl,2
	   mov ax,data
	   mov ds,ax
	   mov si,0
	   call show_str

	   mov ax,4c00h
	   int 21h
show_str: push cx
		  push si
		  push di
		  push bx
		  push ax		;防止日后子程序复用造成寄存器冲突
		  push dx
		  push es

		  mov al,160
		  mul dh

		  mov bx,ax

		  mov al,2
		  mul dl
		  add bx,ax		;bx存偏移地址
		  
		  mov ax,0b800h
		  mov es,ax

		  mov si,0
		  mov di,0
		  mov al,cl		;因下面需要用到cl=0的情况
		  mov ch,0
fkdisp:
		  mov cl,ds:[si]
		  jcxz ok
		  mov es:[bx+di],cl
		  mov es:[bx+di+1],al

		  inc si
		  add di,2

		  jmp short fkdisp

ok:		  pop es
		  pop dx
		  pop ax
		  pop bx
		  pop di
		  pop si
		  pop cx
		  ret
code ends
end start
