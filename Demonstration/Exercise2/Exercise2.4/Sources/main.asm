;*****************************************************************
;* This stationery serves as the framework for a                 *
;* user application (single file, absolute assembly application) *
;* For a more comprehensive program that                         *
;* demonstrates the more advanced functionality of this          *
;* processor, please see the demonstration applications          *
;* located in the examples subdirectory of the                   *
;* Freescale CodeWarrior for the HC12 Program directory          *
;*  
;*          4 ASCII number display using pointer                 *
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
DIG1ON equ $0E
DIG2ON equ $0D
DIG3ON equ $0B
DIG4ON equ $07

number_array DC.B ZERO,ONE,TWO,THREE
number_of_elements DC.B 4
segment_array DC.B DIG1ON,DIG2ON,DIG3ON,DIG4ON
number_of_elements_2 DC.B 4
  
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
      
      bra mainloop
      
print:

      PSHX               ;X
      PSHA               ;A
      PSHB               ;B
          
      MOVB #0, 1, -SP     ;memory for previous value
      
      ldx number_array_pointer, SP     ;firstly, its 10 ;its pointing to the no. array
      ldy segment_array_pointer, SP
      ldaa element_counter, SP    ;firstly, its 12    ;its pointing to the no. of els

 
send_digit:


       ldab 1,x+      ;load b with the current val that x is pointing to
       stab PORTB     ;store port B with 0
       ldab 1,y+
       stab PTP
       bsr delay      
       deca           ;decrement 4 times in total
       bne send_digit
       
       
finish:
       leas 1,SP
       PULB
       PULA
       PULX
       rts      
       
delay:
       ldab #5000
       delay_loop:
       
            dbne b, delay_loop
            
        rts 

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
