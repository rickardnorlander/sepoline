; Copyright 2024 Rickard Norlander
; License: MIT
        default rel

        section .note.GNU-stack noalloc noexec nowrite progbits

        section .text

        extern setjmp

        global init_sepoline_lib
        global prepare_sepoline
        global sepoline
        global get_setjmp_ret

init_sepoline_lib:
        ; Check for xsave
        mov eax, 1
        cpuid
        test ecx, 0x4000000
        jz .init_fail

        ; Check how much memory xsave needs
        mov eax, 0x0d
        xor ecx, ecx
        cpuid
        test ebx, ebx
        jz .init_fail
        cmp ebx, 4096
        ja .init_fail

        xor eax, eax
        ret

        .init_fail:
        mov eax, 1
        ret

prepare_sepoline:
        mov [fnptr], rdi
        mov [jmpbufptr], rsi
        ret

get_setjmp_ret:
        mov rax, [setjmp_ret]
        ret

sepoline:
        mov qword [setjmp_ret], 0
        pop qword [retaddr]

        ; Backup all registers that could have arguments as setjmp might clobber them.
        ; Might be excessive but better save than sorry
        mov [raxbackup], rax
        mov [rcxbackup], rcx
        mov [rdxbackup], rdx
        mov [rsibackup], rsi
        mov [rdibackup], rdi
        mov [r8backup], r8
        mov [r9backup], r9
        mov [r10backup], r10
        mov [r15backup], r15

        ; Request that xsave saves everything.
        mov eax, 0xFFFFFFFF
        mov edx, eax
        xsave [xsavearea]

        ; Call setjmp
        mov rdi, [jmpbufptr]
        call setjmp wrt ..plt
        test rax, rax
        jnz .bad

        mov eax, 0xFFFFFFFF
        mov edx, eax
        xrstor [xsavearea]

        mov rax, [raxbackup]
        mov rcx, [rcxbackup]
        mov rdx, [rdxbackup]
        mov rsi, [rsibackup]
        mov rdi, [rdibackup]
        mov r8, [r8backup]
        mov r9, [r9backup]
        mov r10, [r10backup]
        mov r15, [r15backup]

        call [fnptr]
        jmp .good

        .bad:
        mov [setjmp_ret], rax
        xor eax, eax

        .good:
	jmp [retaddr]



        section .bss

        align 64

xsavearea       resb 4096
myjumpbuf:      resb 1024            ; probably not optimal but probably big enough...
raxbackup:      resb 8
rcxbackup:      resb 8
rdxbackup:      resb 8
rsibackup:      resb 8
rdibackup:      resb 8
r8backup:       resb 8
r9backup:       resb 8
r10backup:      resb 8
r15backup:      resb 8
setjmp_ret:     resb 8
retaddr:        resb 8
fnptr:          resb 8
jmpbufptr:      resb 8

