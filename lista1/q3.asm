org 0x7c00
jmp 0x0000:main

vars:
  PALAVRA times 15 db 0
constantes:
  AZUL db 'AZUL', 0
  AMARELO db 'AMARELO', 0
  VERDE db 'VERDE', 0
  VERMELHO db 'VERMELHO', 0
  INVALIDO db 'NAO EXISTE', 0

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


prints: ;Imprime uma string
  .loop:
    lodsb                   ;Carrega caracter em al              
    cmp al, 0
    je .endloop
    putchar ax
    jmp .loop
  .endloop:
  ret

upperc:
  cmp al, 'a'
  jl .end
  cmp al, 'z'
  jg .end
  sub al, 32
  .end: ; caso não esteja entre 'a' < al < 'z'
  ret

lowerc:
  cmp al, 'A'
  jl .end
  cmp al, 'Z'
  jg .end 
  add al, 32
  .end: ; caso não esteja entre 'A' < al < 'Z'
  ret

gets:  ; guarda a string digitada em DI                          
  xor cx, cx  ; Limpar contador  
  mov  bh, 0  ;
  mov  bl, 15 ; cor branca
  .loop1:
    call getchar

    cmp al, 0x08   ; ASCII 8 => backspace        
    je .backspace ; apaga último caracter lido
    cmp al, 0x0d  ; ASCII 15(0D) => \r (ENTER)          
    je .done
    cmp cl, 13 ; contador == 13
    je .loop1 ; if contador == 13: trava no loop até a pessoa apagar/confirmar;
    call upperc
    stosb ; guarda o char que está em AL no endereço de memória ES:DI
    inc cl ; cl++
    call lowerc
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


compara_aux: ;cx -> aponta p/ palavra digitada pelo usuário 
  .loopi:  ; dx -> aponta p/ palavra certa à ser comparada.
    xor ax, ax ; limpa registradores
    mov bx, ax ; limpa registradores
    mov si, dx
    lodsb ; carrega 1 caracter da palavra certa em ax
    mov bx, ax ; move pra bx pra liberar o registrador
    inc dx ; proximo caracter
    xor ax, ax ; limpa ax
    mov si, cx ; aponta si -> cx (palavra do usuário)
    lodsb ; carrega 1 caracter da palavra do usuário em ax
    inc cx ; proximo caracter
    cmp ax, bx ;compara se o caracter do usuário é igual ao caracter esperado
    jne .diff ; caso seja diferente
    cmp ax, 0 ; caso contrário verifica se tá no final da string
    je .done ; se tiver no final da string -> termina
    jmp .loopi ;se não tiver passa pro próximo caracter
    .diff:
      mov dx, 0 ; dx sendo usado como "retorno", se for diferente dx volta como 0
      jmp .end  
  .done:
    mov dx, 1 ; se forem iguais dx volta como 1
  .end:
  ret

compara:
  xor dx, dx ;Limpa o dx
  ;Compara com a string "amarelo"
  mov si, PALAVRA
  mov cx, si
  mov si, AMARELO ;Salvamos o início de 'amarelo' em dx
  mov dx, si
  call compara_aux
  cmp dx, 1
  je .amarelo
  ;Compara com a string "azul"
  mov si, PALAVRA
  mov cx, si
  mov si, AZUL
  mov dx, si
  call compara_aux
  cmp dx, 1
  je .azul
  ;Compara com a string "verde"
  mov si, PALAVRA
  mov cx, si
  mov si, VERDE
  mov dx, si
  call compara_aux
  cmp dx, 1
  je .verde
  ;Compara com a string "vermelho"
  mov si, PALAVRA
  mov cx, si
  mov si, VERMELHO
  mov dx, si
  call compara_aux
  cmp dx, 1
  je .vermelho
  ;Caso contrário
  .outro:
    mov si, INVALIDO
    mov bl,  5 ; magenta
    jmp .done
  .amarelo:
    mov si, AMARELO
    mov bl, 14
    jmp .done
  .azul:
    mov si, AZUL
    mov bl, 1
    jmp .done
  .verde:
    mov si, VERDE
    mov bl, 10
    jmp .done
  .vermelho:
    mov si, VERMELHO
    mov bl, 4
    jmp .done
  .done:
    mov  dl, 0
    mov  dh, 0
    mov  bh, 0
    mov  ah, 02h
    int  10h
    call prints
  ret

;Desenha em toda janela com a cor em al (320x200px)
cls:
  mov al, 0 ; preto
  push dx ;guarda estado dos registradores
  push cx 
  mov dx, 0
  ;Percorre toda a janela printando pixels da cor preta
  .loopLine:
      cmp dx, 200
      je .endLoopLine
      mov cx, 0
      .loopColumn:
          cmp cx, 320
          je .endLoopColumn
          mov ah, 0Ch ; imprime um pixel na tela na cor (al) na posiçao (dx,cx)
          int 10h ; interrupção de video
          inc cx
          jmp .loopColumn
      .endLoopColumn:
          inc dx
          jmp .loopLine
  .endLoopLine:
      pop cx
      pop dx
  ret

initVideo: ;Inicia modo de vídeo
  mov al, 13h
  mov ah, 0
  int 10h
  ret

main:
  call initVideo
  mov di, PALAVRA
  call gets ; pega palavra do usuário
  call cls ; limpa tela
  call compara ; imprime o resultado
  jmp $    
    
times 510-($-$$) db 0
dw 0xaa55