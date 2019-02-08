assume cs:code,ds:temp,ss:stack,es:data
data segment
	db '1975','1976','1977','1978','1979','1980','1981','1982','1983'
	db '1984','1985','1986','1987','1988','1989','1990','1991','1992'
	db '1993','1994','1995'		;年份

	dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
	dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000	;公司年收入

	dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
	dw 11542,14430,15257,17800			;公司雇员人数
data ends

temp segment
	dw 8 dup(0)
temp ends

stack segment
	dw 16 dup(0)
stack ends 

code segment
start:
	mov ax,stack
	mov ss,ax
	mov sp,20h
	mov ax,data
	mov es,ax
	mov ax,temp 
	mov ds,ax		

	mov cx,21
	mov si,0
	mov di,0
	mov bx,0
	mov dh,2
s:	
	push cx
	mov ax,es:[bx]
	mov ds:[si],ax
	mov ax,es:[bx+2]
	mov ds:[si+2],ax
	mov byte ptr ds:[si+4],0
	mov dl,2		;每行开始初始化列
	mov cl,2		;颜色(可根据自己喜好修改)
	call show_str

	push dx   			;保存行的信息
	mov ax,es:54h[bx]
	mov dx,es:56h[bx]
	call dtoc
	pop dx
	add dl,15
	call show_str
	
	push dx
	mov ax,es:0a8h[di]
	mov dx,0
	call dtoc
	pop dx
	add dl,15
	call show_str

	push dx
	push cx
	mov ax,es:54h[bx]
	mov dx,es:56h[bx]
	mov cx,es:0a8h[di]
	call divdw		;为了使除法不溢出，其实本实验本身就不会溢出
	call dtoc
	pop cx
	pop dx
	add dl,15
	call show_str

	add bx,4
	add di,2
	inc dh			;换行
	
	pop cx
    loop s
    mov ax,4c00h
    int 21h

divdw: 
	push bx
	push ax
	
	mov ax,dx
	mov dx,0
	div cx
	mov bx,ax   ;bx为商等会要到高位(dx),现在的dx是余数(rem(H/N)*65536)
	pop ax
	div cx
	mov cx,dx
	mov dx,bx

	pop bx 	
	ret

dtoc:     push ax
		  push bx
		  push cx
		  push dx
		  push si
			
		  mov si,0
      	  mov bx,0
		  push bx		;在字符串最后加0

fkdiv:	  
		  mov cx,10
		  call divdw
		  add cx,30h
		  push cx		;余数在cx
		  mov cx,dx
		  add cx,ax
		  jcxz write		;商为零时结束循环
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
		  push es
		  push dx

		  
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
ok:		  
		  pop dx
		  pop es
		  pop ax
		  pop bx
		  pop di
		  pop si
		  pop cx
		  ret

code ends
end start
