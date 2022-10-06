%include "io.inc"

SIZE equ 3

section .bss
arr  resb SIZE*SIZE*SIZE*SIZE
arr2 resb SIZE*SIZE

section .text
global CMAIN
CMAIN:
    mov ebp, esp; for correct debugging

    ; read dudoku to solve: 
    mov    esi, arr
    push   esi
    call   read

    mov    esi, arr
    mov    edi, arr2
    push   esi
    mov    ebx, 0
    push   ebx
    push   edi
    call   solve_sudoku
    cmp    eax, 1
    jne    main_unsolveable

    ; print the sudoku:
    PRINT_STRING "The solution is:"
    NEWLINE
    mov    eax, arr
    push   eax
    call   print
    jmp    main_end

main_unsolveable:
    PRINT_STRING "Sorry, the sudoku is unsolvealbe..."
main_end:
    xor eax, eax
    ret
;   ##### ##### solve_sudoku ##### ##### ##### ##### ##### ##### ##### ##### #####  
;   ##### return 1 if the sudoku has been solved
;   ##### return 0 if it's unsolveable

solve_sudoku:
    enter  4,   0
    pusha
    
    mov    dword[ebp - 4], 1        ; return true as default
    mov    esi, [ebp + 16]
    mov    ebx, [ebp + 12]
    mov    edi, [ebp + 8]
    cmp    ebx, SIZE*SIZE*SIZE*SIZE
    jle    solve_sudoku_cont1
    mov    dword[ebp - 4], 1
    jmp    solve_sudoku_end
solve_sudoku_cont1:
    cmp    byte[esi + ebx], 0
    je     solve_sudoku_cont2
    inc    ebx
    push   esi
    push   ebx
    push   edi
    call   solve_sudoku
    mov    [ebp - 4], eax
    jmp    solve_sudoku_end
solve_sudoku_cont2:
    mov    ecx, SIZE*SIZE
solve_sudoku_lp:
    inc    byte[esi + ebx]
    push   esi
    push   edi
    call   check_sudoku
    cmp    eax, 1
    jne    solve_sudoku_cont3
    inc    ebx
    push   esi
    push   ebx
    push   edi
    call   solve_sudoku
    dec    ebx
    cmp    eax, 1
    jne    solve_sudoku_cont3
    mov    [ebp - 4], eax
    jmp    solve_sudoku_end
solve_sudoku_cont3:
    loop   solve_sudoku_lp
    
    mov    byte[ebp - 4], 0        ; we tried every option, return false...
    mov    byte[esi + ebx], 0
solve_sudoku_end:    
    popa
    mov    eax, [ebp - 4]
    leave
    ret    12
    
;   ##### ##### check_sudoku ##### ##### ##### ##### ##### ##### ##### ##### #####
;   ##### return 1 if the sudoku is fine
;   ##### return 0 if it's not

check_sudoku:
    enter  4,   0
    pusha
    mov    esi, [ebp + 12]
    mov    edi, [ebp + 8]
    push   esi
    call   check_rows
    cmp    eax, 0
    je     check_sudoku_return_false
    
    push   esi
    call   check_columns
    cmp    eax, 0
    je     check_sudoku_return_false
    
    push   esi
    push   edi
    call   check_boxes
    cmp    eax, 0
    je     check_sudoku_return_false
    jmp    check_sudoku_return_true
    
check_sudoku_return_false:
    mov    dword[ebp - 4], 0
    jmp    check_sudoku_end
    
check_sudoku_return_true:
    mov    dword[ebp - 4], 1
    
check_sudoku_end:
    popa
    mov    eax, [ebp - 4]
    leave
    ret    8
    
;   ##### ##### check_rows ##### ##### ##### ##### ##### ##### ##### ##### #####
;   ##### return 1 if rows are fine
;   ##### return 0 if not

check_rows:
    enter  4,   0
    pusha
    mov    esi, [ebp + 8]
    mov    ecx, SIZE*SIZE
check_rows_lp:    
    push   esi
    call   check_for_duplicates
    cmp    eax, 0
    je     check_rows_return_false
    add    esi, SIZE*SIZE        ; go to the next row
    loop   check_rows_lp
    jmp    check_rows_return_true
    
check_rows_return_false:
    mov    dword[ebp - 4], 0
    jmp    check_rows_end
    
check_rows_return_true:
    mov    dword[ebp - 4], 1    

check_rows_end:
    popa
    mov    eax, [ebp - 4]
    leave
    ret    4
    
;   ##### ##### check_columns ##### ##### ##### ##### ##### ##### ##### ##### #####
;   ##### return 1 if columns are fine
;   ##### return 0 if not

check_columns:
    enter  4,   0
    pusha
    mov    esi, [ebp + 8]
    mov    ecx, SIZE*SIZE
check_columns_lp1:
    mov    edi, arr2
    mov    ebx, 0
    push   ecx
    mov    ecx, SIZE*SIZE
check_columns_lp2:
    mov    eax, [esi + ebx]
    mov    [edi], eax
    inc    edi
    add    ebx, SIZE*SIZE
    loop   check_columns_lp2
    
    mov    eax, arr2
    push   eax
    call   check_for_duplicates
    cmp    eax, 0
    je     check_columns_return_false
    inc    esi
    pop    ecx
    loop   check_columns_lp1
    jmp    check_columns_return_true

check_columns_return_false:
    pop    ecx 
    mov    dword[ebp - 4], 0
    jmp    check_columns_end
    
check_columns_return_true:
    mov    dword[ebp - 4], 1

check_columns_end:   
    popa
    mov    eax, [ebp - 4]
    leave
    ret    4

;   ##### ##### check_boxes ##### ##### ##### ##### ##### ##### ##### ##### #####
;   ##### return 1 if boxes are fine
;   ##### return 0 if not

check_boxes:
    enter  4,   0
    pusha
    mov    dword[ebp - 4], 1        ; return true as default
    mov    esi, [ebp + 12]
    mov    ecx, SIZE
check_boxes_lp1:
    push   ecx
    mov    ecx, SIZE
    push   esi
check_boxes_lp2:
    mov    edi, [ebp + 8]
    push   ecx
    mov    ecx, SIZE
    push   esi
check_boxes_lp3:
    push   ecx
    mov    ecx, SIZE
    push   esi
check_boxes_lp4:
    mov    bl, [esi]
    mov    [edi], bl
    inc    edi
    inc    esi
    loop   check_boxes_lp4
    
    pop    esi
    add    esi, SIZE*SIZE
    pop    ecx
    loop   check_boxes_lp3
    
    push   edi
    call   check_for_duplicates
    cmp    eax, 1
    je     check_boxes_cont
    mov    dword[ebp - 4], 0        ; return false
check_boxes_cont:
    pop    esi
    add    esi, SIZE  
    pop    ecx
    loop   check_boxes_lp2
    
    pop    esi
    add    esi, SIZE*SIZE*SIZE
    pop    ecx
    loop   check_boxes_lp1
    
    popa
    mov    eax, [ebp - 4]
    leave
    ret    8
    
;   ##### ##### check_for_duplicates ##### ##### ##### ##### ##### ##### ##### #####
;   ##### Gets a string of length SIZE, in ESI
;   ##### Returns 0 if there are duplicates
;   ##### and 1 if there are duplicates
;   ##### Zeros do not count as doubles
    
check_for_duplicates:

    enter  4,   0
    pusha
    
    mov    esi, [ebp + 8]
    mov    ecx, SIZE*SIZE
    
check_for_duplicates_lp1:
    mov    ebx, 0         ; counter
    mov    al,  [esi]
    mov    edi, [ebp + 8]
    push   ecx
    mov    ecx, SIZE*SIZE
    
check_for_duplicates_lp2:
    cmp    al,  [edi]
    jne    check_for_duplicates_cont
    cmp    al,  0         ; Zero has no duplicates
    je     check_for_duplicates_cont
    inc    ebx
    
check_for_duplicates_cont: 
    inc    edi  
    loop   check_for_duplicates_lp2
    
    cmp    ebx, 1        ; check counter
    ja     check_for_duplicates_return_false
    pop    ecx
    inc    esi
    loop   check_for_duplicates_lp1
    jmp    check_for_duplicates_return_true
    
check_for_duplicates_return_false:
    pop    ecx
    mov    eax, 0
    jmp    check_for_duplicates_end

check_for_duplicates_return_true:
    mov    eax, 1
    
check_for_duplicates_end:
    mov    [ebp - 4], eax
    popa
    mov    eax, [ebp - 4]
    leave
    ret 4
   
;   ##### ##### read ##### ##### ##### ##### ##### ##### ##### ##### ##### #####
;   ##### read the sudoku to solve

read:
    enter  0,   0
    pusha
    mov    ebx, SIZE*SIZE
    PRINT_STRING "Please enter a sudoku in size of: "
    PRINT_DEC 4, ebx
    PRINT_STRING "X"
    PRINT_DEC 4, ebx
    NEWLINE
    mov    esi, arr
    mov    ecx, SIZE*SIZE
read_lp1:
    mov    edi, 0
    push   ecx
    mov    ecx, SIZE*SIZE
read_lp2:
    GET_DEC 1, [esi + edi]
    inc    al
    inc    edi
    loop   read_lp2

    add    esi, SIZE*SIZE
    pop    ecx
    loop   read_lp1
    popa
    leave
    ret    4
    
;   ##### ##### print ##### ##### ##### ##### ##### ##### ##### ##### ##### #####
;   ##### print the sudoku

print:
    enter  0,   0
    pusha
    mov    esi, [ebp + 8]
    mov    eax, 1            ; EAX is a counter for buty print (Unnecessary)
    mov    ecx, SIZE*SIZE
print_lp1:
    mov    edi, 0
    push   ecx
    mov    ecx, SIZE*SIZE
print_lp2:
    push   eax        ;;;
    mov    eax, edi   ;;;
    cdq               ;;;
    mov    ebx, SIZE  ;;;
    div    ebx        ;;;
    pop    eax        ;;;
    cmp    edx, 0
    jne    print_regular1
    cmp    edi, 0
    je     print_regular1
    PRINT_CHAR 9
print_regular1:
    PRINT_DEC 1, [esi + edi]
    PRINT_CHAR 9
    inc    edi
    dec    ecx
    cmp    ecx, 0
    jne    print_lp2
    
    push   eax                ;;;
    cdq                       ;;;
    mov    ebx, SIZE          ;;;
    div    ebx                ;;;
    cmp    edx, 0             ;;;
    pop    eax                ;;;
    jne    print_regular2
    
    cmp    eax, 0
    je     print_regular2
    PRINT_CHAR 10
print_regular2:
    PRINT_CHAR 10
    add    esi, SIZE*SIZE
    inc    eax        ; counter ++
    pop    ecx
    dec    ecx
    cmp    ecx, 0
    jne    print_lp1    
    
    popa
    leave
    ret    4
;   ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####