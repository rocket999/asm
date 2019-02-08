assume cs:codesg,ds:datasg
datasg segment
	db "Beginner's All-purpose Symbolic Instruction Code.",0
datasg ends

codesg segment
begin:	mov ax,datasg
		mov ds,ax
		mov si,0
		call letterc
		
		mov dh,8
		mov dl,8
		mov cl,2
		call show_str

		mov ax,4c00h
		int 21h

	letterc:
		push cx
		push si

		mov ch,0
	fkletter:
		mov cl,[si]
		jcxz finish
		cmp cl,97
		jb notransfer
		cmp cl,122
		ja notransfer
		and byte ptr [si],11011111b
	notransfer:
		inc si
		jmp short fkletter

	finish:
		pop si
		pop cx
		ret
		
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
codesg ends
end begin
