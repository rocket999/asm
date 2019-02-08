assume cs:code,ds:data
data segment
	db 'welcome to masm!'
	db 02h,24h,71h
data ends
code segment
start:mov ax,0b872h
	  mov es,ax
	  mov si,0
	  mov di,0
	  mov bx,0
	  mov ax,data
	  mov ds,ax
	  mov cx,16
   s0:
	  mov al,ds:[si]
	  mov es:[bx],al
	  mov al,ds:10h[di]
	  mov byte ptr es:[bx+1],al
	  add bx,2
	  inc si
	  loop s0
     
	  inc di
	  mov ax,es
	  add ax,0ah   ;段地址加0ah相当于偏移地址加160
	  mov es,ax
	  mov si,0
	  mov bx,0
	  mov cx,16
   s1:
	  mov al,ds:[si]
	  mov es:[bx],al
	  mov al,ds:10h[di]
	  mov byte ptr es:[bx+1],al
	  add bx,2
	  inc si
	  loop s1
      
	  inc di
	  mov ax,es
	  add ax,0ah
	  mov es,ax
	  mov si,0
	  mov bx,0
	  mov cx,16
   s2:  
	  mov al,ds:[si]
	  mov es:[bx],al
	  mov al,ds:10h[di]
	  mov byte ptr es:[bx+1],al
	  add bx,2
	  inc si
	  loop s2
	  mov ax,4c00h
	  int 21h
code ends
end start
