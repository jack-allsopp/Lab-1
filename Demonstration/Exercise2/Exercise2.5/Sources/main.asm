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
segment_counter equ  12
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

      ldaa array_length      ;Finding the length of the number array
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

      ldaa #$0F
      staa DDRP
      
      LDX #$ABCD
      LDAA #$BA

      MOVB number_of_elements, 1, -SP
      MOVW #number_array, 2, -SP
      
      MOVB number_of_elements_2, 1, -SP
      MOVW #segment_array, 2, -SP
      
      jsr print          ;return address
      
      leas 6, SP
      
      bra mainloop
      
print:

      PSHX               ;X
      PSHA               ;A
      PSHB               ;B
          
      MOVB #0, 1, -SP     ;memory for previous value
      
      
      ldx number_array_pointer, SP     ;firstly, its 10 ;its pointing to the no. array
      ldy segment_array_pointer, SP
      ldaa segment_counter, SP    ;firstly, its 12    reseting to 4 ;its pointing to the no. of els, can only print 4 on 7-Seg

;Each time, we need to repeat the process
number_of_repetition_loop:
       ldx original_number_of_repetitions
repetition_loop:  ;reseting segment_array pointer, number_array pointer,
       stx number_of_repetitions
       ;If this is the very first repetition, then we need to ldx with the number_array_pointer
       
       ;We are just going to reset y by decreasing it by 4 or by reloading the stack pointer to the start of the segment array
       ldy segment_array_pointer, SP
       ;We are going to update where the pointer is pointing
       
       ldx number_array_pointer, SP 
       bsr update_with_buffer                ;update buffer if final number is reached
       ;We need to reset the element counter
       ldaa segment_counter, SP     ;keep it = 4
       ;Reset position monitor
       ldab #0
       stab position_monitor
               
 
send_digit:
       ldab 1,x+      ;load b with the current val in number array
       stab PORTB     ;store port B with this value
       bsr reset_routine     ;check if the stack pointer needs to be reset to point to 0
       ldab position_monitor
       incb
       stab position_monitor
       ldab 1,y+      ;load b with current val in segment array
       stab PTP        ;store port P with this value
       bsr delay      
       deca           ;decrement 4 times in total, when segcounter is 0, reset to 4
       bne send_digit       ;repeat this process unless element counter is zero i.e once the display is full
       
                            
                            ;At this point, we are going to load the number of repetitions back into x
                            ldx  number_of_repetitions
                            ;Decrement number_of_repetitions and return to the top of the loop
                            dbne x, repetition_loop
                       
       
       ldx number_array_pointer, SP                     
       bsr stack_pointer_start_position       ;if it is, then increment to where we need to start for the next display
       bra number_of_repetition_loop   ;test
       bra send_digit       ;repeat this process for the next display pattern
       
reset_routine: ; if it is the last number, reset stack pointer to the beginning of the nuber array
                                     ;check if the seg display value is 4
       cmpb end_number_array_value
       beq reset_stack_pointer       ;if it is, we need to reset the stack pointer to the beginning
       rts
      
       
reset_stack_pointer:   ;
       bsr updating_stack_pointer 
       ldab #0
       stab position_monitor    ; position of the numbers, 0-0,2-2
       rts
       
updating_stack_pointer:   ;pointer points back to the first number 
       staa current_element_counter
       ldaa  array_length
       updating_stack_pointer_loop:
          ldab 1, -x               
          dbne a, updating_stack_pointer_loop
       ldaa  current_element_counter
       rts
       

update_with_buffer:        ;buffer is pointing to which number we're pointing to, 0 -> 1 ->
        ldaa buffer
        cmpa #0             ;
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
       bsr check_buffer_size      ;here, we are checking if the buffer is  too big
       
       
       stab buffer     ;increment buffer by 1
       ldab 4, -y      ;reset the segment display array
       bsr check_number_array_position            ;
       ldaa buffer
       loop_increment:      ;increment pointer start position according to the buffer
           ldab 1, +x
           dbne a, loop_increment 
       ldaa number_of_elements  
       rts
       
check_buffer_size:
        cmpb array_length
        beq reset_buffer
        rts

reset_buffer:                     ;reset buffer to zero
        ldab #0
        stab buffer
        rts
        
       
check_number_array_position:
       ;here we have to load the current number array position
       bsr update_number_array_position
       decrement_loop:        ;reseting number array back to position 0
          cmpb #$3F ;choose first number in the array           
          beq return_to_check_number_array_position
          ldab 1, -x          ;restart position in x array
          bra decrement_loop
          
          
update_number_array_position:                     ;This is making the stack pointer point to the fourth digit
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
