[BITS 32]                      ; Defines the program as 32-bit
global main                    ; The program entry point
global _SwapCase               ; Declares _SwapCase as the global entry point for the case swap function

section .bss
    user_input resb 256        ; Reserves 256 bytes of memory to store the user's input string

section .data
    prompt db "Enter a string: ", 0                  ; The prompt message to ask the user for input
    before_msg db "Your string before SwapCase:", 0  ; String to display before case conversion
    after_msg db "Your string after SwapCase:", 0    ; String to display after case conversion

section .text
main:
    ; Print the prompt asking the user to enter a string
    mov eax, 4                 ; System call number for sys_write, to print output to the terminal
    mov ebx, 1                 ; File descriptor: STDOUT (1 is standard output, which is the terminal)
    mov ecx, prompt            ; Pointer to the "Enter a string: " message
    mov edx, 16                ; Length of the message to be printed
    int 0x80                   ; System call to display the message

    ; Get user input from the keyboard
    mov eax, 3                 ; System call number for sys_read, to read input from the user
    mov ebx, 0                 ; File descriptor: STDIN (0 is standard input, i.e., the keyboard)
    mov ecx, user_input        ; Pointer to the buffer where the input will be stored
    mov edx, 256               ; Maximum number of bytes to read (256 characters)
    int 0x80                   ; System call to read the input from the user

    ; Calculate the length of the user input string
    mov ecx, user_input        ; Pointer to the user input string
    xor edx, edx               ; Clear edx (used as a counter for length calculation)

    .loop_len:
        mov al, byte [ecx + edx]   ; Load the character at the current position
        test al, al                ; Test if the character is null (0)
        jz .len_done               ; If null terminator is found, we're done
        inc edx                    ; Otherwise, increment the counter
        jmp .loop_len              ; Repeat the loop

    .len_done:
        ; Now, edx contains the length of the input string

        ; Print the "before" message
        mov eax, 4                 ; System call number for sys_write (to print)
        mov ebx, 1                 ; File descriptor: STDOUT (output to terminal)
        mov ecx, before_msg        ; Pointer to the "Your string before SwapCase:" message
        mov edx, 26                ; Length of the "before" message
        int 0x80                   ; System call to display the message

        ; Print the user input string (before case conversion)
        mov eax, 4                 ; System call number for sys_write
        mov ebx, 1                 ; File descriptor: STDOUT
        mov ecx, user_input        ; Pointer to the user input string
        mov edx, edx               ; Set edx to the length of the string (from edx register)
        int 0x80                   ; System call to print the string

        ; Call the SwapCase function to change the case of the string
        mov eax, user_input        ; Pass the address of the user input string to the SwapCase function
        call SwapCase              ; Call the SwapCase function to modify the string in place

        ; Print the "after" message
        mov eax, 4                 ; System call number for sys_write (to print)
        mov ebx, 1                 ; File descriptor: STDOUT
        mov ecx, after_msg         ; Pointer to the "Your string after SwapCase:" message
        mov edx, 26                ; Length of the "after" message
        int 0x80                   ; System call to display the message

        ; Print the modified string (after case conversion)
        mov eax, 4                 ; System call number for sys_write
        mov ebx, 1                 ; File descriptor: STDOUT
        mov ecx, user_input        ; Pointer to the modified string
        mov edx, edx               ; Set edx to the length of the string (from edx register)
        int 0x80                   ; System call to print the string

        ; Exit the program
        mov eax, 1                 ; System call number for sys_exit (to exit the program)
        xor ebx, ebx               ; Exit status 0 (no error)
        int 0x80                   ; System call to exit the program

; SwapCase function to change the case of each character in the string
SwapCase:
    ; The address of the user input string is in the EAX register
    .loop:
        mov al, byte [eax]         ; Load the current character from the string into the AL register
        test al, al                ; Test if the character is the null terminator (0) which marks the end of the string
        jz .done                   ; If it's the null terminator (0), the loop is complete, so jump to .done

        ; Check if the character is a lowercase letter (a-z)
        cmp al, 'a'                ; Compare the current character with the ASCII value of 'a' (97)
        jl .next_char              ; If the character is less than 'a', it's not a lowercase letter, move to the next character
        cmp al, 'z'                ; Compare the current character with the ASCII value of 'z' (122)
        jg .next_char              ; If the character is greater than 'z', it's not a lowercase letter, move to the next character
        sub al, 32                 ; Convert the character from lowercase to uppercase by subtracting 32 ('a' - 'A' = 32)
        mov byte [eax], al         ; Store the converted uppercase character back in the string

    .next_char:
        ; Check if the character is an uppercase letter (A-Z)
        cmp al, 'A'                ; Compare the current character with the ASCII value of 'A' (65)
        jl .next_char_2            ; If the character is less than 'A', it's not an uppercase letter, move to the next character
        cmp al, 'Z'                ; Compare the current character with the ASCII value of 'Z' (90)
        jg .next_char_2            ; If the character is greater than 'Z', it's not an uppercase letter, move to the next character
        add al, 32                 ; Convert the character from uppercase to lowercase by adding 32 ('A' - 'a' = -32)
        mov byte [eax], al         ; Store the converted lowercase character back in the string

    .next_char_2:
        ; Move to the next character in the string
        inc eax                    ; Increment the pointer (EAX) to point to the next character in the string
        jmp .loop                  ; Repeat the loop for the next character

    .done:
        ret                        ; Return from the function when all characters have been processed