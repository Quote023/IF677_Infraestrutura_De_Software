org 0x7c00
jmp 0x0000:main

data:
	PALAVRA times 10 db 0
  NUMERO times 2 db 0

_putchar: ; imprime caracter que estiver na stack
  mov si, sp
  mov al, [si+2] ; pega valor passado como parametro pela stack
  mov ah, 0x0e ; AH == 0eh => imprime o caracter que tiver em al
  int 10h ; interrupção de vídeo.
  ret

%macro putchar 1
  pusha ; salva estado dos registradores antes da chamada da função
  push %1 ; passar parametro pra stack
  call _putchar
  add sp, 2 ; volta stack pra posição inicial
  popa ; retorna estado dos registradores antes da chamada da função
%endmacro

getchar: ; guarda o caracter digitado em AX (AL = valor da tabela ascii/AX = scancode)
  mov ah, 0x00 ; AH == 0 => Ler teclado
  int 16h ; interrupção de teclaod
  ret

%macro delchar 0; Substitui o ulltimo caracter na tela por um espaço em branco (apaga)
  putchar 0x08    ;Backspace                
  putchar ' '     ;Espaço em branco
  putchar 0x08    ;Backspace               
%endmacro
%macro endl 0 ; pula uma linha na tela             
  putchar 0x0d ;\r                  
  putchar 0x0a ;\n
%endmacro


gets:  ; guarda a string digitada em DI                          
  .loop1:
    call getchar

    cmp al, 0x08   ; ASCII 8 => backspace        
    je .backspace ; apaga último caracter lido
    cmp al, 0x0d  ; ASCII 15(0D) => \r (ENTER)          
    je .done
    cmp cl, 13 ; contador == 13
    je .loop1 ; if contador == 13: trava no loop até a pessoa apagar/confirmar;
    
    stosb ; guarda o char que está em AL no endereço de memória ES:DI
    inc cl ; cl++
    putchar ax 
    jmp .loop1

    .backspace:
      cmp cl, 0  ; Apagar no inicio da string = não fazer nada         
      je .loop1
      dec cl ;diminuior contador do loop
      dec di ;diminuir contador do DI (onde o stosb salva)
      mov byte[di], 0 ;apagar o último caracter salvo pelo stosb
      delchar ; apaga o caracter na tela visualmente
      jmp .loop1 ; volta pro inicio do loop
  .done:
    mov al, 0
    stosb ;indica que a string terminou com um 0
    endl
  ret

stoi:							; mov si, string
	xor cx, cx
	xor ax, ax
	.loop1:
		push ax
		lodsb
		mov cl, al
		pop ax
		cmp cl, 0	
		je .endloop1
		sub cl, 48				; '9'-'0' = 9
		mov bx, 10
		mul bx					; 999*10 = 9990
		add ax, cx				; 9990+9 = 9999
		jmp .loop1
	.endloop1:
	ret

main:
	xor ax, ax ; limpar registradores
	mov es, ax
  mov bx, ax
  mov dx, ax
  mov cx, ax

  putchar 'w'
  putchar 'o'
  putchar 'r'
  putchar 'd'
  putchar ':'
  putchar ' '
  mov di, PALAVRA ; carregar input do usuário
  call gets
  
  putchar 'p'
  putchar 'o'
  putchar 's'
  putchar ':'
  putchar ' '
  mov di, NUMERO ; carregar input do usuário
  call gets
  mov si,NUMERO
  call stoi ; transformar o input(SI) em numero e guarda em AX

  mov cl, al 
  xor ax, ax

  mov si, PALAVRA
  add si, cx
  mov al, [si]
  putchar ax
  ret
                
    
	
times 510-($-$$) db 0
dw 0xaa55
