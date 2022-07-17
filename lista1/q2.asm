
org 0x7c00
jmp 0x0000:main

; Funções auxiliares
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
  xor cx, cx  ; Limpar contador            
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
    putchar ax; imprime na tela o que acabou de ser lido.
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
    stosb ;indica que a string terminou com um o
    endl
  ret


main:
  PALAVRA: times 100 db 0
  mov di, PALAVRA
  call gets
  mov si, PALAVRA
  
  push 0
  .pushLoop: ; pega toda a string salva em "palavra" e coloca na stack
    lodsb
    cmp al, 0 ; quando chegar no final da string
    je .popLoop 
    push ax ; guarda o valor que tiver em ax no topo da stack  
    jmp .pushLoop  
  .popLoop:
    pop ax ; tira o valor do topo da stack e guarda de volta em ax
    cmp al, 0
    je .endloop 
    putchar ax 
    jmp .popLoop     
  .endloop:
    endl    
    ret




jmp $
times 510-($-$$) db 0       
dw 0xaa55  