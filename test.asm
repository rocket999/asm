assume cs:code,ds:data
data segment
	db 10 dup(0)
data ends

code segment
start:
	mov ax,10660
	mov bx,data
	mov ds,bx
	mov si,0
	call dtoc

	mov dh,8
	mov dl,3
	mov cl,2
	call show_str
	
	mov ax,4c00h
	int 21h
	
dtoc:     push ax
		  push bx
		  push cx
		  push dx
		  push si

      	  mov bx,0
		  push bx		;在字符串最后加0
		  mov bx,10

fkdiv:	  mov dx,0
		  div bx
		  add dx,30h
		  push dx
		  mov cx,ax
		  jcxz write		
		  jmp short fkdiv
		  	
write:
		  pop cx
		  mov ds:[si],cx	;要先写入，否则字符串最后的0无法写入
		  jcxz finish
		  inc si
		  jmp short write

finish:	  pop si
		  pop dx
		  pop cx
		  pop bx
		  pop ax
		  ret

show_str: push cx
		  push si
		  push di
		  push bx
		  push ax		;防止日后子程序复用造成寄存器冲突
		  
		  mov al,160		;看要求dh和dl是否减1
		  mul dh				
								
		  mov bx,ax
			
		  mov al,2
		  mul dl			
		  add bx,ax		;bx存偏移地址
		  
		  mov ax,0b800h
		  mov es,ax

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
ok:		  pop ax
		  pop bx
		  pop di
		  pop si
		  pop cx
		  ret
code ends
end start

