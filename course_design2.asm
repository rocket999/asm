;分三个段，避免偏移地址因代码的复制而改变
;第一段为安装程序，第二段为引导程序，第三段为系统程序

assume cs:InstallCode
InstallCode segment
start:
	mov ax,loadsys
	mov es,ax
	mov bx,0

	mov al,1
	mov ch,0
	mov cl,1
	mov dh,0
	mov dl,0		;将引导程序安装在软盘的0面,0道,1扇区

	mov ah,3
	int 13h
	
	mov ax,code
	mov es,ax
	mov bx,0		;将系统程序安装在0,0,2开始的15个扇区中

	mov al,15
	mov cl,2
	
	mov ah,3
	int 13h

	mov ax,4c00h		;安装完成后返回
	int 21h

InstallCode ends

assume cs:loadsys
loadsys segment
	mov ax,2000h		;将系统程序加载到2000:0处执行
	mov es,ax
	mov bx,0

	mov al,15
	mov ah,2
	mov ch,0
	mov cl,2
	mov dl,0
	mov dh,0
	int 13h
	
	mov ax,2000h
	push ax
	mov ax,0
	push ax
	retf
loadsys ends

assume cs:code
code segment
menu:
	jmp short showMenu
	choice1 db '1) reset pc',0
	choice2 db '2) start system',0
	choice3 db '3) clock',0
	choice4 db '4) set clock',0
	choiceoff dw choice1,choice2,choice3,choice4
	systable dw sys_reset,os_start,sys_clock,sys_set_clock
showMenu:
	mov dh,8
	mov dl,8
	mov ax,cs
	mov ds,ax
	mov bp,0
	mov cx,4
	show_choice:
		push cx
		mov cl,2
		mov si,choiceoff[bp]		;通过bp改变偏移地址
		call show_str
		add bp,2
		add dh,2
		pop cx
	loop show_choice

	mov ah,0
	int 16h

	mov bx,0
	mov bl,al
	mov al,30h
	sub bl,al
	sub bl,1
	add bx,bx
	call word ptr systable[bx]

	;cmp al,'1'
	;je sys_reset
	;cmp al,'2'
	;je os_start
	;cmp al,'3'
	;je sys_clock
	;cmp al,'4'
	;jmp near ptr sys_set_clock

sys_reset:
	mov ax,0ffffh
	push ax
	mov ax,0
	push ax
	retf

os_start:
	mov ax,0
	mov es,ax
	mov bx,7c00h

	mov al,1
	mov ch,0
	mov cl,1
	mov dh,0
	mov dl,80h
	
	mov ah,2
	int 13h

	mov ax,0
	push ax
	mov ax,7c00h
	push ax
	retf

sys_clock:
	call clear 
	jmp short write_clock
	clock db '00/00/00 00:00:00',0
	clock_color db 02h
	clock_table db 9,8,7,4,2,0
write_clock:
	mov si,0	;si指向clock
	mov di,0	;di指向clock_table
	mov cx,6
	write:
	push cx
		mov al,clock_table[di]
		out 70h,al
		in al,71h
		mov ah,al
		mov cl,4
		shr ah,cl
		and al,00001111b
		add ah,30h
		add al,30h
		mov clock[si],ah
		mov clock[si+1],al
		inc di
		add si,3
	pop cx
	loop write

	mov dh,8
	mov dl,8
	mov si,offset clock
	mov ax,cs
	mov ds,ax
	mov cl,clock_color[0]
	call show_str

	mov ah,0
	int 16h
	
	cmp ah,1		;ah中为扫描码
	je clock_return
	cmp ah,3bh
	je change_color

	jmp short write_clock

clock_return:
	call clear
	jmp near ptr menu


change_color:
	inc clock_color
	jmp near ptr write_clock

sys_set_clock:
	jmp short setclock
	clockformat db 'yy/mm/dd hh:mm:ss'
setclock:
	call clear
	mov ax,cs
	mov ds,ax
	mov si,offset clockformat
	call getstr
	call set_time
	call clear
	jmp near ptr menu

set_time:	jmp short set
cltable 		db 9,8,7,4,2,0
	
set:		mov bx,0
			mov cx,6
			shit:
				mov dh,ds:[si]
				inc si
				mov dl,ds:[si]
				add si,2
				mov al,30h
				sub dh,al		;ASCII码再减去30h才为实际的BCD码
				sub dl,al
				shl dh,1
				shl dh,1
				shl dh,1
				shl dh,1
				or dl,dh		;组合成一个dl修改
				mov al,cltable[bx]
				out 70h,al
				mov al,dl
				out	71h,al 
				inc bx
			loop shit
			ret

charstack:	jmp short charstart
table		dw charpush,charpop,charshow
top 		dw 0	;栈顶

charstart:	push bx
			push dx
			push di
			push es

			cmp ah,2
			ja sret
			mov bl,ah
			mov bh,0
			add bx,bx
			call word ptr table[bx]

charpush:	mov bx,top
			mov [si][bx],al		;ds:si指向字符栈空间
			inc top
			jmp sret

charpop:	cmp top,0
			je sret
			dec top
			mov bx,top
			mov al,[si][bx]
			jmp sret

charshow:	mov bx,0b800h
			mov es,bx
			mov al,160
			mov ah,0
			mul dh
			mov di,ax
			add dl,dl
			mov dh,0
			add di,dx

			mov bx,0

charshows:	cmp bx,top		;!=0
			jne noempty
			mov byte ptr es:[di],' '
			jmp sret

noempty:	mov al,[si][bx]
			mov es:[di],al
			mov byte ptr es:[di+2],' '
			inc bx
				add di,2
			jmp charshows
	
sret:		pop es
			pop di
			pop dx
			pop bx
			ret

getstr:		push ax

getstrs:	mov ah,0
			int 16h
			cmp al,20h
			jb nochar		;ASCII码小于20h说明不是字符
			mov ah,0
			call charstack	;字符入栈
			mov ah,2
			mov dh,8
			mov dl,8
			call charstack	;显示字符
			jmp getstrs

nochar:		cmp ah,0eh		;backspace的扫描码
			je backspace
			cmp ah,1ch
			je enter
			jmp getstrs		;其他键就继续输入
backspace:  mov ah,1
			call charstack
			mov ah,2
			call charstack
			jmp getstrs
enter:		mov al,0	;说明压进的是0
			mov ah,0	;压栈
			call charstack
			mov ah,2
			call charstack
			pop ax
			ret

clear:
	push ax
	push bx
	push cx
	push es
	mov ax,0b800h
	mov es,ax
	mov bx,0
	mov cx,2000
  s:mov byte ptr es:[bx],' '
  	add bx,2
	loop s
	pop es
	pop cx
	pop bx
	pop ax
	ret
;ds:si指向字符串首地址,dh为行,dl为列,cl为颜色
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
