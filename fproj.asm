%include "simple_io.inc"

global asm_main
extern rperm

section .data
        swapQ db "if you want to swap, type a,b",0
        swapEnd db "if you want to end, type 0: ",0
        badInput db "incorrect input, redo", 0
        progDone db "program done",0
        length db 8

        ; Definitions of different display blocks
        head8: db "  +------+"
        head7: db "  +-----+ "
        head6: db "   +----+ "
        head5: db "   +---+  "
        head4: db "    +--+  "
        head3: db "    +-+   "
        head2: db "     ++   "
        head1: db "      +   "

        body8: db "  +      +"
        body7: db "  +     + "
        body6: db "   +    + "
        body5: db "   +   +  "
        body4: db "    +  +  "
        body3: db "    + +   "
        body2: db "     ++   "
        body1: db "      +   "

        tail8: db "..+------+"
        tail7: db "..+-----+."
        tail6: db "...+----+."
        tail5: db "...+---+.."
        tail4: db "....+--+.."
        tail3: db "....+-+..."
        tail2: db ".....++..."
        tail1: db ".....+...."

section .bss
        array: resq 8
section .text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
asm_main:
        enter   0,0
        saveregs
        mov     rdi, array     ;1st param for rperm
        mov     rsi, qword 8   ;2nd param for rperm
        call rperm

        ;; now the array 'array' is randomly initialzed
             ; Push array length to stack
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        loopMain:
                push array      ; Push array to stack
                push length
                call display
                call _askSwitch
                ;askSwitch will call display
                add rsp, 8
                mov rax, 1
                cmp rax, 1
                je loopMain
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        call _endProg
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Subroutine to ask the user if they want to switch any numbers
; Recall that this is an infinite loop until 0
_askSwitch:
        mov rax, swapQ
        call print_string
        call print_nl
        _goodInput:
        mov rax, swapEnd
        call print_string
        call read_char
        ; Tests if program done
        cmp al, '0'
        je _progDone
        ; Tests invalid inputs for first entry
        cmp al, '1'
        jl _badInput
        cmp al, '8'
        jg _badInput
        sub al, 48
        movzx r12, al ;digit version of al stored in r12
        ; Clears comma
        call read_char
        ; Tests invalid inputs for second entry
        call read_char
        cmp al, '1'
        jl _badInput
        cmp al, '8'
        jg _badInput
        sub al, 48
        movzx r13, al ;digit version of al stored in r13

        ; Testing for equality in integers
        cmp r12, r13
        je _badInput
        ;No bad inputs! time to swap!
        call read_char
        ; Swap entries within the array
        _swapFinder:
                mov rcx, qword 7
                mov rbx, qword 0
                loopStart: ; Compare both r12, r13 with current value
                        cmp rcx, 0
                        jl _swapVals
                        cmp r12, [array + rbx]
                        je _storeA
                        cmp r13, [array + rbx]
                        je _storeB
                        add rbx, 8
                        dec rcx
                        jmp loopStart
                _storeA:
                        mov rsi, rbx ;index for val 1 stored in rsi
                        add rbx, 8
                        dec rcx
                        jmp loopStart
                _storeB:
                        mov rdi, rbx ;index for val 2 stored in rdi
                        add rbx, 8
                        dec rcx
                        jmp loopStart
                _swapVals:
                        mov [array + rdi], r12
                        mov [array + rsi], r13
                        jmp loopMain ; go back to initial loop
                        ; move a into array at c
                        ; move b into array at d

; Display subroutine, passed the values from before
display:
        ;commence subroutine
        enter 0,0
        saveregs
        mov rsi, qword[rbp+16] ;rsi holds array size
        mov rdi, qword[rbp+24] ;rdi holds array ptr
        ;setup concluded, time to write to display
        displayLoop: 
        ;        cmp rsi, 0
        ;        jl loopMain
        ;        mov rax, 7
        ;        createLoop:
                ; TODO work on the create line function
                ; TODO create a way to hold value for line and append 

                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;Demonstrating while i couldn't get display working, I can indeed pass variables to subroutines.
                mov rax, [rdi]
                call print_int
                mov rax, [rdi+8]
                call print_int
                mov rax, [rdi+16]
                call print_int
                mov rax, [rdi+24]
                call print_int
                mov rax, [rdi+32]
                call print_int
                mov rax, [rdi+40]
                call print_int
                mov rax, [rdi+48]
                call print_int
                mov rax, [rdi+56]
                call print_int
                call print_nl
        ;        dec rsi
        ;        jmp displayLoop

        ;conclude subroutine
        restoregs
        leave
        ret

; End Program different ways
_progDone:
        mov rax, progDone
        call print_string
        call print_nl
        call _endProg
_badInput: ;TODO why am I getting incorrect input and how do i clear buffer?
        mov rax, badInput
        call print_string
        call print_nl
        jmp _goodInput
_endProg:
        restoregs
        leave
        ret
