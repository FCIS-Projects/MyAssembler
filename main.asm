TITLE MASM _main						(_main.asm)

INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib
INCLUDELIB C:\Irvine\User32.lib
INCLUDELIB C:\Irvine\Kernel32.lib

.data
    inputArr byte 100 dup(?),0
    outputArr byte 100 dup(?)
              byte 100 dup(?)
              byte 100 dup(?)
              byte 100 dup(?),0
    counterarr byte 5 dup(?)
    counter byte 0
    tmp dword  0
    noOfWords byte 0
    _EAX_ byte "eax",0
    
    regs DWORD 5 DUP(?)
    _reg DWORD ?
    _reg_size DWORD ?

    caption byte "ERROR!", 0
    error_msg_regs byte "This register is not found ...", 0
    error_msg_inst byte "This instruction is not valid", 0
    
    _eax DWORD 0
    _ebx DWORD 0
    _ecx DWORD 0
    _edx DWORD 0
    _ebp DWORD 0
    _esp DWORD 0
    _esi DWORD 0
    _edi DWORD 0
    
    _eax_str byte "eax: ", 0
    _ebx_str byte "ebx: ", 0
    _ecx_str byte "ecx: ", 0
    _edx_str byte "edx: ", 0
    _ebp_str byte "ebp: ", 0
    _esp_str byte "esp: ", 0
    _esi_str byte "esi: ", 0
    _edi_str byte "edi: ", 0

.code
main PROC

    mov ecx, 1
    while_true:
        call tokenize
        call handle_inst
        call _dumpregs
        
        call clear
        inc ecx
    LOOP while_true
    
    call WaitMsg
    exit
main ENDP

tokenize PROC
mov edx, offset inputArr 
mov ecx, lengthof inputarr-1 
call readString 
mov ecx, eax 

mov esi , offset inputArr
mov edi , offset outputArr
mov  tmp , edi
mov edx, offset counterarr

L1:

mov bl, ';'
cmp [esi], bl
je done 
mov al , ' '
mov ah , ','
cmp [esi] , al
je worddone
cmp [esi],ah
je worddone
push edx
mov dl , [esi]
mov byte ptr [edi], dl
pop edx 
inc esi
inc edi
inc counter

jmp endLoop

wordDone:
inc esi
cmp [esi], ah
je endLoop
cmp [esi], al
je endLoop
mov edi, tmp 
add edi , 100
mov tmp, edi
mov al, counter
mov [edx], eax
inc edx 
mov counter, 0
inc noOfWords
endLoop:
loop L1

done:
inc noOfWords
mov al, counter
mov [edx], eax
mov edx, offset outputArr
mov ecx, 0
mov cl, noOfWords

outLoop:
;call writeString 
call crlf 
add edx, 100
loop outLoop

mov edx, offset counterarr
mov eax, 0
mov ecx, 0
mov cl, noOfWords
counterLoop:
mov al, [edx]
;call writedec
;call crlf 
inc edx 
mov eax, 0
loop counterLoop
ret
tokenize ENDP

handle_inst PROC
    mov esi, OFFSET outputArr
    mov edi, OFFSET counterarr
    mov al, [edi]
    sub al, 1
    movzx eax, al
    add esi, eax
    mov al, [esi]
    cmp al, ':'
    je _lable
    
    mov eax, 0
    mov esi, OFFSET outputArr
    mov al, [esi]
    and al, 11011111b
    
    cmp al, 'A'
    je _add
   
    cmp al, 'C'
    je _call
    
    cmp al, 'D'
    je _dec_div
    
    cmp al, 'I'
    je _inc
    
    cmp al, 'M'
    je _mov_mul
    
    cmp al, 'S'
    je _sub
    
    
    _add:
       mov ecx, OFFSET counterarr
       mov al, [ecx]
       cmp al, 3
       jne _error_
       inc esi
       mov al, [esi]
       and al, 11011111b
       cmp al, 'D'
       jne _exit
       inc esi
       mov al, [esi]
       and al, 11011111b
       cmp al, 'D'
       jne _exit
       mov esi, OFFSET outputArr
       add esi, 100
       mov bl, 0
       mov ecx, OFFSET counterarr
       add ecx, 1
       call registers
       cmp dl, 1
       je _add_read_al
       cmp dl, 2
       je _add_read_ah
       cmp dl, 3
       je _add_read_ax
       cmp dl, 4
       je _add_read_eax
       
       _add_read_al:
           mov cl, al
           jmp _add_here
           
       _add_read_ah:
           mov ch, ah
           jmp _add_here
           
       _add_read_ax:
           mov cx, ax
           jmp _add_here
       
       _add_read_eax:
           mov ecx, eax
           jmp _add_here
           
       _add_here:
       add esi, 100
       mov edi, OFFSET counterarr
       add edi, 2
       push ecx
       mov ecx, [edi]
       mov al, [esi]
       call isdigit
       jz _add_numeric
       mov bl, 0
       push ecx
       mov ecx, edi
       call registers
       pop ecx
       jmp _add_con
       _add_numeric:
           mov edx, esi
           mov ecx, [edi]
           call ParseDecimal32
           
       _add_con:
       pop ecx
       cmp dl, 1
       je _add_al
       cmp dl, 2
       je _add_ah
       cmp dl, 3
       je _add_ax
       cmp dl, 4
       je _add_eax
           
       _add_al:
           add al, cl
           jmp _add_continue
       _add_ah:
           add ah, ch
           jmp _add_continue
       _add_ax:
           add ax, cx
           jmp _add_continue
       _add_eax:
           add eax, ecx
           jmp _add_continue
                                 
       _add_continue:
           mov esi, OFFSET outputArr
           add esi, 100
           mov bl, 1
           mov ecx, OFFSET counterarr
           add ecx, 1
           call registers
                                     
       jmp  _exit
        
    _call:
       mov ecx, OFFSET counterarr 
       mov al, [ecx]
       ;call writechar
       cmp al, 4
       jne _error_
       inc esi
       mov al, [esi]
       and al, 11011111b
       cmp al, 'A'
       jne _exit
       inc esi
       mov al, [esi]
       and al, 11011111b
       cmp al, 'L'
       jne _exit
       inc esi
       mov al, [esi]
       and al, 11011111b
       cmp al, 'L'
       jne _exit
       mov esi, OFFSET outputArr
       add esi, 100
       mov bl, 1
       mov ecx, OFFSET counterarr
       add ecx, 1
       call registers      
       jmp  _exit
    
    _dec_div:
       mov ecx, OFFSET counterarr
       mov al, [ecx]
       cmp al, 3
       jne _error_
       inc esi
       mov al, [esi]
       and al, 11011111b
       cmp al, 'E'
       je _dec
       cmp al, 'I'
       je _div
       jne _exit
              
       _dec:
           mov ecx, OFFSET counterarr
           add ecx, 2
           mov al, [ecx]
           cmp al, 0
           jne _error_
           inc esi
           mov al, [esi]
           and al, 11011111b
           cmp al, 'C'
           jne _exit
           mov esi, OFFSET outputArr
           add esi, 100
           mov bl, 0
           mov ecx, OFFSET counterarr
           add ecx, 1
           call registers
           
           cmp dl, 1
           je _dec_read_al
           cmp dl, 2
           je _dec_read_ah
           cmp dl, 3
           je _dec_read_ax
           cmp dl, 4
           je _dec_read_eax
           
           _dec_read_al:
               sub al, 1
               jmp _dec_here
               
           _dec_read_ah:
               sub ah, 1
               jmp _dec_here
               
           _dec_read_ax:
               sub ax, 1
               jmp _dec_here
           
           _dec_read_eax:
               sub eax, 1
               jmp _dec_here
               
           _dec_here:
           mov bl, 1
           mov ecx, OFFSET counterarr
           add ecx, 1
           call registers   
           jmp _exit
           
       _div:
           inc esi
           mov al, [esi]
           and al, 11011111b
           cmp al, 'V'
           jne _exit
           mov esi, OFFSET outputArr
           add esi, 100
           mov bl, 0
           mov ecx, OFFSET counterarr
           add ecx, 1
           call registers
           
           cmp dl, 1
           je _div_read_al
           cmp dl, 2
           je _div_read_ah
           cmp dl, 3
           je _div_read_ax
           cmp dl, 4
           je _div_read_eax
           
           _div_read_al:
               mov cl, al
               div cl
               mov al, cl
               jmp _div_here
               
           _div_read_ah:
               mov ch, ah
               div ch
               mov ah, ch
               jmp _div_here
               
           _div_read_ax:
               mov cx, ax
               div cx
               mov ax, cx
               jmp _div_here
           
           _div_read_eax:
               mov ecx, eax
               div ecx
               mov eax, ecx
               jmp _div_here
               
           _div_here:
               mov esi, OFFSET _EAX_
               mov bl, 1
               mov ecx, 3 
               call registers
           
        jmp _exit
    
    _inc:
       mov ecx, OFFSET counterarr
       mov al, [ecx]
       cmp al, 3
       jne _error_
       inc esi
       mov al, [esi]
       and al, 11011111b
       cmp al, 'N'
       jne _exit
       inc esi
       mov al, [esi]
       and al, 11011111b
       cmp al, 'C'
       jne _exit
       mov esi, OFFSET outputArr
       add esi, 100
       mov bl, 0
       mov ecx, OFFSET counterarr
       add ecx, 1
       call registers
       
       cmp dl, 1
       je _inc_read_al
       cmp dl, 2
       je _inc_read_ah
       cmp dl, 3
       je _inc_read_ax
       cmp dl, 4
       je _inc_read_eax
       
       _inc_read_al:
           add al, 1
           jmp _inc_here
           
       _inc_read_ah:
           add ah, 1
           jmp _inc_here
           
       _inc_read_ax:
           add ax, 1
           jmp _inc_here
       
       _inc_read_eax:
           add eax, 1
           jmp _inc_here
           
       _inc_here:
       mov bl, 1
       mov ecx, OFFSET counterarr
       add ecx, 1
       call registers
       jmp  _exit
       
   _mov_mul:
       mov ecx, OFFSET counterarr
       mov al, [ecx]
       cmp al, 3
       jne _error_
       inc esi
       mov al, [esi]
       and al, 11011111b
       cmp al, 'O'
       je _mov
       cmp al, 'U'
       je _mul
       jne _exit
       
                   
       _mov:
           inc esi
           mov al, [esi]
           and al, 11011111b
           cmp al, 'V'
           jne _exit
           mov esi, OFFSET outputArr
           add esi, 200
           mov edi, OFFSET counterarr
           add edi, 2
           mov ecx, [edi]
           mov al, [esi]
           call isdigit
           jz _mov_numeric
           mov bl, 0
           mov ecx, OFFSET counterarr
           add ecx, 2
           call registers
           jmp _mov_con
           _mov_numeric:
               mov edx, esi
               mov ecx, [edi]
               call ParseDecimal32
           _mov_con:
           cmp dl, 1
           je _mov_read_al
           cmp dl, 2
           je _mov_read_ah
           cmp dl, 3
           je _mov_read_ax
           cmp dl, 4
           je _mov_read_eax
           
           _mov_read_al:
               mov cl, al
               jmp _mov_here
               
           _mov_read_ah:
               mov ch, ah
               jmp _mov_here
               
           _mov_read_ax:
               mov cx, ax
               jmp _mov_here
           
           _mov_read_eax:
               mov ecx, eax
               jmp _mov_here
               
           _mov_here:
           sub esi, 100
           mov bl, 1
           mov ecx, OFFSET counterarr
           add ecx, 1
           call registers
           jmp _exit
           
       _mul:
           inc esi
           mov al, [esi]
           and al, 11011111b
           cmp al, 'L'
           jne _exit
           mov esi, OFFSET outputArr
           add esi, 100
           mov bl, 0
           mov ecx, OFFSET counterarr
           add ecx, 1
           call registers
           
           cmp dl, 1
           je _mul_read_al
           cmp dl, 2
           je _mul_read_ah
           cmp dl, 3
           je _mul_read_ax
           cmp dl, 4
           je _mul_read_eax
           
           _mul_read_al:
               mov cl, al
               mul cl
               mov al, cl
               jmp _mul_here
               
           _mul_read_ah:
               mov ch, ah
               mul ch
               mov ah, ch
               jmp _mul_here
               
           _mul_read_ax:
               mov cx, ax
               mul cx
               mov ax, cx
               jmp _mul_here
           
           _mul_read_eax:
               mov ecx, eax
               mul ecx
               mov eax, ecx
               jmp _mul_here
               
           _mul_here:
               mov esi, OFFSET _EAX_
               mov bl, 1
               mov ecx,3
               call registers
           
        
       jmp _exit
       
   _sub:
       mov ecx, OFFSET counterarr
       mov al, [ecx]
       cmp al, 3
       jne _error_
       inc esi
       mov al, [esi]
       and al, 11011111b
       cmp al, 'U'
       jne _exit
       inc esi
       mov al, [esi]
       and al, 11011111b
       cmp al, 'B'
       jne _exit
       mov esi, OFFSET outputArr
       add esi, 100
       mov bl, 0
       mov ecx, OFFSET counterarr
       add ecx, 1
       call registers
       
       cmp dl, 1
       je _sub_read_al
       cmp dl, 2
       je _sub_read_ah
       cmp dl, 3
       je _sub_read_ax
       cmp dl, 4
       je _sub_read_eax
       
       _sub_read_al:
           mov cl, al
           jmp _sub_here
           
       _sub_read_ah:
           mov ch, ah
           jmp _sub_here
           
       _sub_read_ax:
           mov cx, ax
           jmp _sub_here
       
       _sub_read_eax:
           mov ecx, eax
           jmp _sub_here
           
       _sub_here:
       add esi, 100
       mov edi, OFFSET counterarr
       add edi, 2
       push ecx
       mov ecx, [edi]
       mov al, [esi]
       call isdigit
       jz _sub_numeric
       mov bl, 0
       push ecx
       mov ecx, OFFSET counterarr
       add ecx, 2
       call registers
       pop ecx
       jmp _sub_con
       _sub_numeric:
           mov edx, esi
           mov ecx, [edi]
           call ParseDecimal32
       _sub_con:
       pop ecx
       cmp dl, 1
       je sub_al
       cmp dl, 2
       je sub_ah
       cmp dl, 3
       je sub_ax
       cmp dl, 4
       je sub_eax
           
       _sub_al:
           sub cl, al
           mov al, cl
           jmp _sub_continue
       _sub_ah:
           sub ch, ah
           mov ah, ch
           jmp _sub_continue
       _sub_ax:
           sub cx, ax
           mov ax, cx
           jmp _sub_continue
       _sub_eax:
           sub ecx, eax
           mov eax, ecx
           jmp _sub_continue
                                 
       _sub_continue:
           mov esi, OFFSET outputArr
           add esi, 100
           mov bl, 1
           mov ecx, OFFSET counterarr
           add ecx, 1
           call registers
       jmp _exit
    
    _lable:
        mov eax, 0
        mov esi, OFFSET outputArr
        add esi, 100
        mov al, [esi]
        and al, 11011111b
        
        cmp al, 'A'
        je _add_
       
        cmp al, 'C'
        je _call_
        
        cmp al, 'D'
        je _dec_div_
        
        cmp al, 'I'
        je _inc_
        
        cmp al, 'M'
        je _mov_mul_
        
        cmp al, 'S'
        je _sub_
        
        
        _add_:
           mov ecx, OFFSET counterarr
           add ecx, 1
           mov al, [ecx]
           cmp al, 3
           jne _error_
           inc esi
           mov al, [esi]
           and al, 11011111b
           cmp al, 'D'
           jne _exit
           inc esi
           mov al, [esi]
           and al, 11011111b
           cmp al, 'D'
           jne _exit
           mov esi, OFFSET outputArr
           add esi, 200
           mov bl, 0
           mov ecx, OFFSET counterarr
           add ecx, 2
           call registers
           
           cmp dl, 1
           je add_read_al
           cmp dl, 2
           je add_read_ah
           cmp dl, 3
           je add_read_ax
           cmp dl, 4
           je add_read_eax
           
           add_read_al:
               mov cl, al
               jmp add_here
               
           add_read_ah:
               mov ch, ah
               jmp add_here
               
           add_read_ax:
               mov cx, ax
               jmp add_here
           
           add_read_eax:
               mov ecx, eax
               jmp add_here
               
           add_here:
           add esi, 100
           mov edi, OFFSET counterarr
           add edi, 3
           push ecx
           mov ecx, [edi]
           mov al, [esi]
           call isdigit
           jz add_numeric
           mov bl, 0
           push ecx
           mov ecx, OFFSET counterarr
           add ecx, 3
           call registers
           pop ecx
           jmp add_con
           add_numeric:
               mov edx, esi
               mov ecx, [edi]
               call ParseDecimal32
              
           add_con:
           pop ecx
           cmp dl, 1
           je add_al
           cmp dl, 2
           je add_ah
           cmp dl, 3
           je add_ax
           cmp dl, 4
           je add_eax
               
           add_al:
               add al, cl
               jmp add_continue
           add_ah:
               add ah, ch
               jmp add_continue
           add_ax:
               add ax, cx
               jmp add_continue
           add_eax:
               add eax, ecx
               jmp add_continue
                                     
           add_continue:
               mov esi, OFFSET outputArr
               add esi, 200
               mov bl, 1
               mov ecx, OFFSET counterarr
               add ecx, 2
               call registers
                                         
           jmp  _exit
            
        _call_:
           mov ecx, OFFSET counterarr
           add ecx, 1
           mov al, [ecx]
           cmp al, 4
           jne _error_
           inc esi
           mov al, [esi]
           and al, 11011111b
           cmp al, 'A'
           jne _exit
           inc esi
           mov al, [esi]
           and al, 11011111b
           cmp al, 'L'
           jne _exit
           inc esi
           mov al, [esi]
           and al, 11011111b
           cmp al, 'L'
           jne _exit
           mov esi, OFFSET outputArr
           add esi, 200
           mov bl, 1
           mov ecx, OFFSET counterarr
           add ecx, 2
           call registers      
           jmp  _exit
        
        _dec_div_:
           mov ecx, OFFSET counterarr
           add ecx, 1
           mov al, [ecx]
           cmp al, 3
           jne _error_
           inc esi
           mov al, [esi]
           and al, 11011111b
           cmp al, 'E'
           je _dec_
           cmp al, 'I'
           je _div_
           jne _exit
                  
           _dec_:
               inc esi
               mov al, [esi]
               and al, 11011111b
               cmp al, 'C'
               jne _exit
               mov esi, OFFSET outputArr
               add esi, 200
               mov bl, 0
               mov ecx, OFFSET counterarr
               add ecx, 2
               call registers
               
               cmp dl, 1
               je dec_read_al
               cmp dl, 2
               je dec_read_ah
               cmp dl, 3
               je dec_read_ax
               cmp dl, 4
               je dec_read_eax
               
               dec_read_al:
                   sub al, 1
                   jmp dec_here
                   
               dec_read_ah:
                   sub ah, 1
                   jmp dec_here
                   
               dec_read_ax:
                   sub ax, 1
                   jmp dec_here
               
               dec_read_eax:
                   sub eax, 1
                   jmp dec_here
                   
               dec_here:
               mov bl, 1
               mov ecx, OFFSET counterarr
               add ecx, 2
               call registers   
               jmp _exit
               
           _div_:
               inc esi
               mov al, [esi]
               and al, 11011111b
               cmp al, 'V'
               jne _exit
               mov esi, OFFSET outputArr
               add esi, 200
               mov bl, 0
               mov ecx, OFFSET counterarr
               add ecx, 2
               call registers
               
               cmp dl, 1
               je div_read_al
               cmp dl, 2
               je div_read_ah
               cmp dl, 3
               je div_read_ax
               cmp dl, 4
               je div_read_eax
               
               div_read_al:
                   mov cl, al
                   div cl
                   mov al, cl
                   jmp div_here
                   
               div_read_ah:
                   mov ch, ah
                   div ch
                   mov ah, ch
                   jmp div_here
                   
               div_read_ax:
                   mov cx, ax
                   div cx
                   mov ax, cx
                   jmp div_here
               
               div_read_eax:
                   mov ecx, eax
                   div ecx
                   mov eax, ecx
                   jmp div_here
                   
               div_here:
                   mov esi, OFFSET _EAX_
                   mov bl, 1
                   mov ecx, 3
                   call registers
               
            jmp _exit
        
        _inc_:
           mov ecx, OFFSET counterarr
           add ecx, 1
           mov al, [ecx]
           cmp al, 3
           jne _error_
           inc esi
           mov al, [esi]
           and al, 11011111b
           cmp al, 'N'
           jne _exit
           inc esi
           mov al, [esi]
           and al, 11011111b
           cmp al, 'C'
           jne _exit
           mov esi, OFFSET outputArr
           add esi, 200
           mov bl, 0
           mov ecx, OFFSET counterarr
           add ecx, 2
           call registers
           
           cmp dl, 1
           je inc_read_al
           cmp dl, 2
           je inc_read_ah
           cmp dl, 3
           je inc_read_ax
           cmp dl, 4
           je inc_read_eax
           
           inc_read_al:
               add al, 1
               jmp inc_here
               
           inc_read_ah:
               add ah, 1
               jmp inc_here
               
           inc_read_ax:
               add ax, 1
               jmp inc_here
           
           inc_read_eax:
               add eax, 1
               jmp inc_here
               
           inc_here:
           mov bl, 1
           mov ecx, OFFSET counterarr
           add ecx, 2
           call registers 
           jmp  _exit
           
       _mov_mul_:
           mov ecx, OFFSET counterarr
           add ecx, 1
           mov al, [ecx]
           cmp al, 3
           jne _error_
           inc esi
           mov al, [esi]
           and al, 11011111b
           cmp al, 'O'
           je _mov_
           cmp al, 'U'
           je _mul_
           jne _exit
           
                       
           _mov_:
               inc esi
               mov al, [esi]
               and al, 11011111b
               cmp al, 'V'
               jne _exit
               mov esi, OFFSET outputArr
               add esi, 300
               mov al, [esi]
               call isdigit
               jz _mov_numeric
               mov bl, 0
               mov ecx, OFFSET counterarr
               add ecx, 3
               call registers
               jmp _mov_con
               mov_numeric:
                   mov edx, esi
                   mov ecx, [edi]
                   call ParseDecimal32
               mov_con:
               cmp dl, 1
               je mov_read_al
               cmp dl, 2
               je mov_read_ah
               cmp dl, 3
               je mov_read_ax
               cmp dl, 4
               je mov_read_eax
               
               mov_read_al:
                   mov cl, al
                   jmp mov_here
                   
               mov_read_ah:
                   mov ch, ah
                   jmp mov_here
                   
               mov_read_ax:
                   mov cx, ax
                   jmp mov_here
               
               mov_read_eax:
                   mov ecx, eax
                   jmp mov_here
                   
               mov_here:
               sub esi, 100
               mov bl, 1
               mov ecx, OFFSET counterarr
               add ecx, 2
               call registers         
               jmp _exit
               
           _mul_:
               inc esi
               mov al, [esi]
               and al, 11011111b
               cmp al, 'L'
               jne _exit
               mov esi, OFFSET outputArr
               add esi, 300
               mov bl, 0
               mov ecx, OFFSET counterarr
               add ecx, 3
               call registers
               
               cmp dl, 1
               je mul_read_al
               cmp dl, 2
               je mul_read_ah
               cmp dl, 3
               je mul_read_ax
               cmp dl, 4
               je mul_read_eax
               
               mul_read_al:
                   mov cl, al
                   mul cl
                   mov al, cl
                   jmp mul_here
                   
               mul_read_ah:
                   mov ch, ah
                   mul ch
                   mov ah, ch
                   jmp mul_here
                   
               mul_read_ax:
                   mov cx, ax
                   mul cx
                   mov ax, cx
                   jmp mul_here
               
               mul_read_eax:
                   mov ecx, eax
                   mul ecx
                   mov eax, ecx
                   jmp mul_here
                   
               mul_here:
               mov esi, OFFSET _EAX_
               mov bl, 1
               mov ecx, 3
               call registers
               
             
           jmp _exit
           
       _sub_:
           mov ecx, OFFSET counterarr
           add ecx, 1
           mov al, [ecx]
           cmp al, 3
           jne _error_
           inc esi
           mov al, [esi]
           and al, 11011111b
           cmp al, 'U'
           jne _exit
           inc esi
           mov al, [esi]
           and al, 11011111b
           cmp al, 'B'
           jne _exit
           mov esi, OFFSET outputArr
           add esi, 200
           mov bl, 0
           mov ecx, OFFSET counterarr
           add ecx, 2
           call registers
           
           cmp dl, 1
           je sub_read_al
           cmp dl, 2
           je sub_read_ah
           cmp dl, 3
           je sub_read_ax
           cmp dl, 4
           je sub_read_eax
           
           sub_read_al:
               mov cl, al
               jmp sub_here
               
           sub_read_ah:
               mov ch, ah
               jmp sub_here
               
           sub_read_ax:
               mov cx, ax
               jmp sub_here
           
           sub_read_eax:
               mov ecx, eax
               jmp sub_here
               
           sub_here:
           add esi, 100
           mov edi, OFFSET counterarr
           push ecx
           add edi, 3
           mov ecx, [edi]
           mov al, [esi]
           call isdigit
           jz sub_numeric
           mov bl, 0
           push ecx
           mov ecx, OFFSET counterarr
           add ecx, 3
           call registers
           pop ecx
           jmp sub_con
           sub_numeric:
               mov edx, esi
               mov ecx, [edi]
               call ParseDecimal32
           sub_con:
           pop ecx
           cmp dl, 1
           je sub_al
           cmp dl, 2
           je sub_ah
           cmp dl, 3
           je sub_ax
           cmp dl, 4
           je sub_eax
               
           sub_al:
               sub cl, al
               mov al, cl
               jmp sub_continue
           sub_ah:
               sub ch, ah
               mov ah, ch
               jmp sub_continue
           sub_ax:
               sub cx, ax
               mov ax, cx
               jmp sub_continue
           sub_eax:
               sub ecx, eax
               mov eax, ecx
               jmp sub_continue
                                     
           sub_continue:
               mov esi, OFFSET outputArr
               add esi, 200
               mov bl, 1
               mov ecx, OFFSET counterarr
               add ecx, 2
               call registers
           jmp _exit
    _error_:
        mov ebx, OFFSET caption
        mov edx, OFFSET error_msg_inst
        call MsgBox
           
    _exit:

    ret
handle_inst ENDP

registers PROC USES esi
    ; identifiy the required register
    call identify_reg

    ; 0 = read from the register, 1 = write from the register
    cmp bl, 1
    je write_reg
    
    read_reg:
        ; put the value in eax
        ; dl will also returned
        mov eax, [esi]
        jmp _exit_regisers
    
    write_reg:
        cmp dl, 1
        je write_LSB
        cmp dl, 2
        je write_HSB
        cmp dl, 3
        je write_WORD

        ; ELSE
        write_DWORD:
            mov [esi], eax
            jmp _exit_regisers
        write_LSB:
            mov ebx, [esi]
            mov bl, al
            mov [esi], ebx
            jmp _exit_regisers
        write_HSB:
            mov ebx, [esi]
            mov bh, al
            mov [esi], ebx
            call dumpregs
            jmp _exit_regisers
        write_WORD:
            mov ebx, [esi]
            mov bx, ax
            mov [esi], ebx
            
    _exit_regisers:
    ret
registers ENDP

identify_reg PROC USES edi ebx eax

    ; Least significant Byte   = 1
    ; Highest significant Byte = 2
    ; word                     = 3
    ; Double Word              = 4
    
    ; Save esi
    mov [_reg], esi
    push esi

    save_labels_addresses:
        ; get a pointer to regs
        mov esi, OFFSET regs

        ; Save addresses of labels
        mov [esi], _A
        add esi, SIZEOF DWord
        mov [esi], _B
        add esi, SIZEOF DWord
        mov [esi], _C_S
        add esi, SIZEOF DWord
        mov [esi], _D

    handle_registers:
        ; to load the before last character
        ; ( may be the middle or the first character)
        ; by taking the length from [ecx]
        mov edi, [_reg]
        mov al, [ecx]
        movzx eax, al

        add edi, eax
        sub edi, 2
        mov al, [edi]

        ; use only the first 4 bits from the character
        and eax, 00001111b
    
        ; decrease it by one to use it as index
        dec al
        ; check for errors
        cmp al, 5
        jae _error
        ; because of the size of regs
        imul eax, TYPE regs

        ; load the address of a label specified for
        ; that character
        mov esi, OFFSET regs
        add esi ,eax
        mov eax, [esi]
        
        load_last_char:
            ; load last char
            mov ebx, edi
            add ebx, 1
            mov bl, [ebx]
            ; convert it to capital
            and bl, 11011111b
            
        ; load esi
        pop esi

        jmp eax

        _A:
            ; check errors
                    mov cl, [edi]
                    ; convert it to capital
                    and cl, 11011111b
                    cmp cl, 'A'
                    jne _error
                mov cl, [esi]
                ; convert it to capital
                and cl, 11011111b
                cmp cl, 'E'
                je _A__G_A_has_e
                cmp bl, 'X'
                je _A__G_A_has_x_but_not_e
                
                cmp bl, 'L'
                je _A__G_A_is_low_reg
                cmp bl, 'H'
                jne _error
                    ; ah
                    mov esi, OFFSET _eax
                    mov dl, 2
                    jmp _identify_exit
                _A__G_A_is_low_reg:
                    ; al
                    mov esi, OFFSET _eax
                    mov dl, 1
                    jmp _identify_exit
                _A__G_A_has_e:
                    ; eax
                    mov esi, OFFSET _eax
                    mov dl, 4
                    jmp _identify_exit
                _A__G_A_has_x_but_not_e:
                    ; ax
                    mov esi, OFFSET _eax
                    mov dl, 3
                    jmp _identify_exit
        _B:
            ; check errors
                    mov cl, [edi]
                    ; convert it to capital
                    and cl, 11011111b
                    cmp cl, 'B'
                    jne _error
            cmp bl, 'P'
            je _B__groupB
            
            _B__groupA:
                mov cl, [esi]
                ; convert it to capital
                and cl, 11011111b
                cmp cl, 'E'
                je _B__G_A_has_e
                
                cmp bl, 'X'
                je _B__G_A_has_x_but_not_e
                
                cmp bl, 'L'
                je _B__G_A_is_low_reg
                cmp bl, 'H'
                jne _error
                    ; bh
                    mov esi, OFFSET _ebx
                    mov dl, 2
                    jmp _identify_exit
                _B__G_A_is_low_reg:
                    ; bl
                    mov esi, OFFSET _ebx
                    mov dl, 1
                    jmp _identify_exit
                _B__G_A_has_e:
                    ; ebx
                    mov esi, OFFSET _ebx
                    mov dl, 4
                    jmp _identify_exit
                _B__G_A_has_x_but_not_e:
                    ; bx
                    mov esi, OFFSET _ebx
                    mov dl, 3
                    jmp _identify_exit
            _B__groupB:
                mov cl, [esi]
                ; convert it to capital
                and cl, 11011111b
                cmp cl, 'E'
                je _B__G_B_has_e
                    ; bp
                    mov esi, OFFSET _ebp
                    mov dl, 3
                    jmp _identify_exit
                _B__G_B_has_e:
                    ; ebp
                    mov esi, OFFSET _ebp
                    mov dl, 4
                    jmp _identify_exit
        _C_S:
            ; characters 'S' and 'C' lower or upper cases
            ; are different in their 4th bit
            mov al, [edi]
            TEST al, 00010000b
            jz _C
            jnz _S

            _C:
                ; check errors
                    mov cl, [edi]
                    ; convert it to capital
                    and cl, 11011111b
                    cmp cl, 'C'
                    jne _error
                mov cl, [esi]
                ; convert it to capital
                and cl, 11011111b
                cmp cl, 'E'
                je _C__G_A_has_e
                
                cmp bl, 'X'
                je _C__G_A_has_x_but_not_e
                
                cmp bl, 'L'
                je _C__G_A_is_low_reg
                cmp bl, 'H'
                jne _error
                    ; ch
                    mov esi, OFFSET _ecx
                    mov dl, 2
                    jmp _identify_exit
                _C__G_A_is_low_reg:
                    ; cl
                    mov esi, OFFSET _ecx
                    mov dl, 1
                    jmp _identify_exit
                _C__G_A_has_e:
                    ; ecx
                    mov esi, OFFSET _ecx
                    mov dl, 4
                    jmp _identify_exit
                _C__G_A_has_x_but_not_e:
                    ; cx
                    mov esi, OFFSET _ecx
                    mov dl, 3
                    jmp _identify_exit
            _S:
                ; check errors
                    mov cl, [edi]
                    ; convert it to capital
                    and cl, 11011111b
                    cmp cl, 'S'
                    jne _error
                mov cl, [esi]
                ; convert it to capital
                and cl, 11011111b
                cmp cl, 'E'
                je _S__G_B_has_e
                cmp bl, 'P'
                je _SP__G_B
                    ; si
                    mov esi, OFFSET _esi
                    mov dl, 3
                    jmp _identify_exit
                _SP__G_B:
                    ;sp
                    mov esi, OFFSET _esp
                    mov dl, 3
                    jmp _identify_exit

                _S__G_B_has_e:
                    cmp bl, 'P'
                    je _ESP__G_B
                        ; ESI
                        mov esi, OFFSET _esi
                        mov dl, 4
                        jmp _identify_exit
                    _ESP__G_B:
                        ;ESP
                        mov esi, OFFSET _esp
                        mov dl, 4
                        jmp _identify_exit
    
        _D:
            ; check errors
                    mov cl, [edi]
                    ; convert it to capital
                    and cl, 11011111b
                    cmp cl, 'D'
                    jne _error
            cmp bl, 'I'
            je _D__groupB
            
            _D__groupA:
                mov cl, [esi]
                ; convert it to capital
                and cl, 11011111b
                cmp cl, 'E'
                je _D__G_A_has_e
                
                cmp bl, 'X'
                je _D__G_A_has_x_but_not_e
                
                cmp bl, 'L'
                je _D__G_A_is_low_reg
                    ; dh
                    cmp bl, 'H'
                    jne _error
                    mov esi, OFFSET _edx
                    mov dl, 2
                    jmp _identify_exit
                _D__G_A_is_low_reg:
                    ; dl
                    mov esi, OFFSET _edx
                    mov dl, 1
                    jmp _identify_exit
                _D__G_A_has_e:
                    ; edx
                    mov esi, OFFSET _edx
                    mov dl, 4
                    jmp _identify_exit
                _D__G_A_has_x_but_not_e:
                    ; dx
                    mov esi, OFFSET _edx
                    mov dl, 3
                    jmp _identify_exit
                    
            _D__groupB:
                mov cl, [esi]
                ; convert it to capital
                and cl, 11011111b
                cmp cl, 'E'
                je _D__G_B_has_e
                    ; di
                    mov esi, OFFSET _edi
                    mov dl, 3
                    jmp _identify_exit
                _D__G_B_has_e:
                    ; edi
                    mov esi, OFFSET _edi
                    mov dl, 4
                    jmp _identify_exit

        _error:
            mov ebx, OFFSET caption
            mov edx, OFFSET error_msg_regs
            call MsgBox
            exit
            
        _identify_exit:

    ret
identify_reg ENDP

_dumpregs PROC
    ; EAX
        mov edx, OFFSET _eax_str
        call writestring
        mov eax, [_eax]
        call writehex
        call crlf
    ; EBX
        mov edx, OFFSET _ebx_str
        call writestring
        mov eax, [_ebx]
        call writehex
        call crlf
    ; ECX
        mov edx, OFFSET _ecx_str
        call writestring
        mov eax, [_ecx]
        call writehex
        call crlf
    ; EDX
        mov edx, OFFSET _edx_str
        call writestring
        mov eax, [_edx]
        call writehex
        call crlf
    ; EBP
        mov edx, OFFSET _ebp_str
        call writestring
        mov eax, [_ebp]
        call writehex
        call crlf
    ; ESP
        mov edx, OFFSET _esp_str
        call writestring
        mov eax, [_esp]
        call writehex
        call crlf
    ; ESI
        mov edx, OFFSET _esi_str
        call writestring
        mov eax, [_esi]
        call writehex
        call crlf
    ; EDI
        mov edx, OFFSET _edi_str
        call writestring
        mov eax, [_edi]
        call writehex
        call crlf
        
    ret
_dumpregs ENDP

clear PROC USES eax edi ecx
    
    ; clear counter arr
    mov al, 0
    mov edi, OFFSET counterArr
    mov ecx, LENGTHOF counterArr
    rep stosb
    
    ; clear input arr
    mov al, 0
    mov edi, OFFSET inputArr
    mov ecx, LENGTHOF inputArr
    rep stosb
    
    ; clear output arr
    mov al, 0
    mov edi, OFFSET outputArr
    mov ecx, LENGTHOF outputArr
    rep stosb
    
    mov [counter], 0

    mov [tmp], 0
    mov [noOfWords], 0
    
    mov [_reg], 0
    mov [_reg_size], 0
    
    ret
clear ENDP

END main