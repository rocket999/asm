assume cs:codesg,ds:datasg
datasg segment
	db 'BaSiC'
	db 'iNfOrMaTiOn'
datasg ends

codesg segment
start: mov ax,datasg
	   mov ds,ax
	   mov bx,0
	   mov cx,5
	s1:mov al,ds:[bx]
	   and al,11011111b
	   mov ds:[bx],al
	   inc bx
	   loop s1
	   mov bx,5   ;第二个字符串开始
	   mov cx,11
	s2:mov al,ds:[bx]
	   or al,00100000b
	   mov ds:[bx],al
	   inc bx
	   loop s2
	   mov ax,4c00h
	   int 21h
codesg ends
end start
