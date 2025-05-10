.data
    msg_prompt: .asciz "Cual es el archivo que desea abrir: "
    msg_promt_len = . - msg_prompt
    msg_count: .asciz "Numero de palabras: "
    msg_count_len = . - msg_count_len
    msg_lenght_error: .asciz "La longitud de caracteres supera el limite."
    msg_lenght_error_len . -msg_lenght_error

.bss
    .lcomm filename, 256
    .lcomm filecontent, 1024
    .lcomm fd, 4
    .lcomm word_count, 4
    .lcomm num_buffer, 20
    .lcomm temp_buffer, 1       @ Buffer adicional para verificacion de longitud

.text
.global _start

_start:
    @ Imprimir mensaje inicial
    mov r0, #1          @ stdout
    ldr r1, =msg_prompt
    ldr r2, =msg_promt_len
    mov r7, #4          @ sys_write
    swi #0

    @ Leer nombre del archivo
    mov r0, #0          @ stdin
    ldr r1, =filename
    mov r2, #256
    mov r7, #3          @ sys_read
    swi #0

    @ Procesar nombre del archivo
    cmp r0, #0
    ble _exit_error
    sub r0, r0, #1
    ldr r1, =filename
    mov r2, #0
    strb r2, [r1, r0]

    @ Abrir archivo
    ldr r0, =filename
    mov r1, #0          @ 0_RDONLY
    mov r7, #5          @ sys_open
    swi #0

    cmp r0, #0
    blt _exit_error
    ldr r1, =fd
    str r0, [r1]

    @ Leer contenido del archivo
    ldr r0, [r1]
    ldr r1, =filecontent
    mov r2, #1024
    mov r7, #3          @ sys_read
    swi #0

    @ Verificar longitud máxima
    mov r4, r0          @ Guardar bytes leídos
    cmp r4, #1024
    blt valid_length    @ Si es menor, continúa

    @ Verificar si hay contenido adicional
    ldr r0, =fd         @ Cargar la dirección de fd
    ldr r0, [r0]        @ Cargar el valor almacenado en r0
    ldr r1, =temp_buffer
    mov r2, #1
    mov r7, #3          @ sys_read
    swi #0

    cmp r0, #0
    bgt _length_error   @ Si hay más datos, error
