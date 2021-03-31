;*****************************************************************
;* This stationery serves as the framework for a                 *
;* user application (single file, absolute assembly application) *
;* For a more comprehensive program that                         *
;* demonstrates the more advanced functionality of this          *
;* processor, please see the demonstration applications          *
;* located in the examples subdirectory of the                   *
;* Freescale CodeWarrior for the HC12 Program directory          *
;* Scrolling a tring of ASCII nubers larger than 4 characters    *
;*****************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

ROMStart    EQU  $4000  ; absolute address to place my code/constant data

; variable/data section

  ORG RAMStart
  
ZERO equ $3F
ONE equ $06
TWO equ $5B
THREE equ $4F
FOUR equ $66
FIVE equ $6D
DIG1ON equ $0E
DIG2ON equ $0D
DIG3ON equ $0B
DIG4ON equ $07

number_array DC.B ZERO,ONE,TWO,THREE,FOUR,FIVE
number_of_elements DC.B 4
array_length DC.B 0
segment_array DC.B DIG1ON,DIG2ON,DIG3ON,DIG4ON
number_of_elements_2 DC.B 4

number_of_repetitions DC.W 2
original_number_of_repetitions DC.W 1000
;original_number_of_repetitions DC.W 1

;number_of_repetitions equ 2
position_monitor DC.B 0

buffer DC.B 0
reset_flag DC.B $66
final_digit_flag DC.B 1
first_number_array_position DC.W $1001
current_element_counter DC.B 0
end_number_array_value DC.B 0
  
  ;stack frame
  ;define position of each component
element_counter equ  12
number_array_pointer equ  10
element_counter_2 equ 9
segment_array_pointer equ 7
; return_address equ 5
; temp_x equ 3
; temp_a equ 2
; temp_b equ 1
prev_value equ  0
  

   ORG ROMStart


Entry:
_Startup:
            
      LDS #RAMEnd+1
      
      CLI
      
mainloop:

      ldaa array_length
      ldx #$1000             ;load the memory address of the first number in number array
      array_length_loop:
                  inca                ;increment array length
                  ldab 1, x+          
                  cmpb #4             ;check if value of memory address is 4
                  bne array_length_loop
                  ldab 2, -x
                  stab end_number_array_value
              deca                    
              staa array_length

      
      ldaa #$FF
      staa DDRB
      ;staa DDRJ
      ;ldaa #00
      ;staa PTJ
      ldaa #$0F
      staa DDRP
      
      LDX #$ABCD
      LDAA #$BA
      ;LDAB #$BC

      MOVB number_of_elements, 1, -SP
      MOVW #number_array, 2, -SP
      
      MOVB number_of_elements_2, 1, -SP
      MOVW #segment_array, 2, -SP
      
      jsr print          ;return address
      
      leas 6, SP
      
      ;MOVB number_of_elements_2, 1, -SP
      ;MOVW #segment_array, 2, -SP
      
      ;jsr send_digit
      
      ;leas 3, SP
      
      bra mainloop
      
print:

      PSHX               ;X
      PSHA               ;A
      PSHB               ;B
          
      MOVB #0, 1, -SP     ;memory for previous value
      
      ;Lets create a variable with a large value
      ;Lets give it one for now
      ;ldx number_of_repetitions
      
      
      ldx number_array_pointer, SP     ;firstly, its 10 ;its pointing to the no. array
      ldy segment_array_pointer, SP
      ldaa element_counter, SP    ;firstly, its 12    ;its pointing to the no. of els

;How do we repeat the process in send_digit from the start until 'bne send_digit'?
;Each time, we need to reset
number_of_repetition_loop:
       ldx original_number_of_repetitions
repetition_loop:
       stx number_of_repetitions
       ;If this is the very first repetition, then we need to ldx with the number_array_pointer
       
       ;We are just going to reset y by decreasing it by 4 or by reloading the stack pointer to the start of the segment array
       ldy segment_array_pointer, SP
       ;We are going to update where the pointer is pointing
          ;We will do this by decreasing the stack pointer by 5, and then increase it by the buffer
                ;Or we can just reload the stack pointer to point at the start of the number array and then increase it by the buffer
       ldx number_array_pointer, SP 
       bsr update_with_buffer
       ;We need to reset the element counter
       ldaa element_counter, SP
       ;Reset position monitor
       ldab #0
       stab position_monitor
               
 
send_digit:
       ;ldx  number_array_pointer, SP
       ldab 1,x+      ;load b with the current val in number array
       stab PORTB     ;store port B with this value
       bsr reset_routine     ;check if the stack pointer needs to be reset to point to 0
       ldab position_monitor
       incb
       stab position_monitor
       ldab 1,y+      ;load b with current val in segment array
       stab PTP        ;store port P with this value
       bsr delay      
       deca           ;decrement 4 times in total
       bne send_digit       ;repeat this process unless element counter is zero i.e once the display is full
       
                            
                            ;At this point, we are going to load the number of repetitions back into x
                            ldx  number_of_repetitions
                            ;Decrement number_of_repetitions and return to the top of the loop
                            dbne x, repetition_loop
                       
       
       ldx number_array_pointer, SP                     
       bsr stack_pointer_start_position       ;if it is, then increment to where we need to start for the next display
       bra number_of_repetition_loop   ;test
       bra send_digit       ;repeat this process for the next display pattern
       
reset_routine:
       ;cmpb reset_flag               ;check if the seg display value is 4
       cmpb end_number_array_value
       beq reset_stack_pointer       ;if it is, we need to reset the stack pointer to the beginning
       rts
      
       
reset_stack_pointer:
       ;ldab 4, -x
       bsr updating_stack_pointer 
       ;ldab 5, -x
       ;ldx number_array_pointer, SP
       ;ldab array_length, -x
       ldab #0
       stab position_monitor
       rts
       
updating_stack_pointer:
       staa current_element_counter
       ldaa  array_length
       updating_stack_pointer_loop:
          ldab 1, -x
          dbne a, updating_stack_pointer_loop
       ldaa  current_element_counter
       rts
       

update_with_buffer:
        ldaa buffer
        cmpa #0
        bne update_with_buffer_action
        rts
        
                      
update_with_buffer_action:
        update_with_buffer_loop:
            ldab 1, +x              ;increment x by 1
            dbne a, update_with_buffer_loop
        rts

       
stack_pointer_start_position:     ;here, we are updating the buffer
       ldab buffer
       incb
       bsr check_buffer_size      ;here, we are checking if the buffer is 5 (i.e too big)
       
       
       stab buffer     ;increment buffer by 1
       ldab 4, -y      ;reset the segment display array
       ;ldx number_array_pointer, SP 
       bsr check_number_array_position            ;
       ;ldab 4, -x          ;restart position in x array
       ldaa buffer
       loop_increment:      ;increment pointer start position according to the buffer
           ldab 1, +x
           dbne a, loop_increment 
       ldaa number_of_elements  
       rts
       
check_buffer_size:
        ;cmpb #5                   ;if it is 5, reset it to zero
        cmpb array_length
        beq reset_buffer
        rts

reset_buffer:                     ;reset buffer to zero
        ldab #0
        stab buffer
        rts
        
       
check_number_array_position:
       ;here we have to load the current number array position
       ;ldx number_array_pointer, SP
       bsr update_number_array_position
       ;ldab x
       decrement_loop:
          ;cmpb first_number_array_position
          ;cmpb ZERO
          cmpb #$3F           
          beq return_to_check_number_array_position
          ldab 1, -x          ;restart position in x array
          bra decrement_loop
          
          
update_number_array_position:
        ;ldx number_array_pointer, SP              ;loading start of number array
        ldaa position_monitor                     ;loading position monitor i.e where we are currently in the array
        increment_number_array_position:          ;increment position in number array to update it
                ldab 1, +x
                dbne a, increment_number_array_position
        rts
                    
          
return_to_check_number_array_position:
       rts 
       
finish:
       leas 1,SP
       PULB
       PULA
       PULX
       rts      
       
delay:
       staa current_element_counter
       ldab #255
       ;ldab #1
       delay_loop:
            ldaa #15
            delay_loop_2:
            
                dbne a, delay_loop_2
       
            dbne b, delay_loop
        ldaa current_element_counter    
        rts 

;**************************************************************
;*                 Interrupt Vectors                          *
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
