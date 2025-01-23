global main
extern printf
extern scanf
extern exit

section .bss
char1 resb 1  ; Reserve space for the first character
char2 resb 1  ; Reserve space for the second character

section .data
prompt1 db "Enter the first alphabetical character: ", 0  ; Prompt the user for the first character
prompt2 db "Enter the second alphabetical character: ", 0  ; Prompt the user for the second character
result  db "The characters in alphabetical order are %c and %c", 10, 0  ; Result message format
format  db " %c", 0  ; Format for character printing

section .text
main:
    ; Create a clean stack frame for local variables
    push    ebp             ; Save the base pointer (sets up the stack frame)
    mov     ebp, esp        ; Set up the new base pointer for the function

    ; Prompt user for the first character
    push    prompt1         ; Push the address of prompt1 onto the stack
    call    printf          ; Print the prompt
    add     esp, 4          ; Clean up the stack (removes the prompt string)

    push    char1           ; Push the address of char1 onto the stack to store input
    push    format          ; Push the format string onto the stack for the scanf function
    call    scanf           ; Read the character from user input into char1
    add     esp, 8          ; Clean up the stack (remove scanf parameters)

    ; Prompt user for the second character (same as above)
    push    prompt2
    call    printf
    add     esp, 4          ; Clean up the stack

    push    char2
    push    format
    call    scanf
    add     esp, 8          ; Clean up the stack

    ; Load the characters into registers
    mov     al, [char1]     ; Copy char1 into register al
    mov     dl, [char2]     ; Copy char2 into register dl

    ; Store the original characters for later use (in case we need to swap them)
    mov     ah, al          ; Store original char1 in ah
    mov     dh, dl          ; Store original char2 in dh

    ; Convert char1 to lowercase if it's uppercase
    cmp     al, 'A'         ; Compare char1 (al) with ASCII value of 'A'
    jb      next            ; If char1 is less than 'A', skip conversion
    cmp     al, 'Z'         ; Compare char1 (al) with ASCII value of 'Z'
    ja      next            ; If char1 is greater than 'Z', skip conversion
    add     al, 32          ; Convert char1 to lowercase by adding 32 (ASCII difference)
    mov     [char1], al     ; Store the lowercase character back into char1

next:
    ; Convert char2 to lowercase (same process as char1)
    cmp     dl, 'A'         ; Compare char2 (dl) with 'A'
    jb      check         ; If char2 is less than 'A', skip conversion
    cmp     dl, 'Z'         ; Compare char2 (dl) with 'Z'
    ja      check         ; If char2 is greater than 'Z', skip conversion
    add     dl, 32          ; Convert char2 to lowercase by adding 32 (ASCII difference)
    mov     [char2], dl     ; Store the lowercase character back into char2

check:
    ; Compare the lowercase characters to see if they are in order
    cmp     al, dl          ; Compare char1 (al) with char2 (dl)
    jle     output         ; If char1 is less than or equal to char2, no swap needed

    ; If char1 is greater, swap the characters
    mov     bl, ah          ; Temporarily store the original char1 in bl
    mov     ah, dh          ; Copy the original char2 into ah (char1)
    mov     dh, bl          ; Copy the original char1 into dh (char2)

output:
    ; Display the result, showing the characters in alphabetical order
    mov     al, ah          ; Copy the (possibly swapped) original char1 to al
    mov     dl, dh          ; Copy the (possibly swapped) original char2 to dl
    push    edx             ; Push the second character onto the stack
    push    eax             ; Push the first character onto the stack
    push    result          ; Push the result string onto the stack
    call    printf          ; Print the result
    add     esp, 12         ; Clean up the stack (remove 3 pushed values by adding 4 x the amount of pushes)

    ; Restore the stack pointer and exit
    mov     esp, ebp        ; Restore the stack pointer
    pop     ebp             ; Restore the base pointer
    push    0               ; Push the exit code (0 means success)
    call    exit            ; Exit the program