;*****************************************************************
;* This stationery serves as the framework for a                 *
;* user application (single file, absolute assembly application) *
;* For a more comprehensive program that                         *
;* demonstrates the more advanced functionality of this          *
;* processor, please see the demonstration applications          *
;* located in the examples subdirectory of the                   *
;* Freescale CodeWarrior for the HC12 Program directory          *
;*****************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		INCLUDE 'derivative.inc'
		

ROMStart    EQU  $4000  ; absolute address to place my code/constant data
LEDON equ $01
ZERO equ $3F
ONE equ $06
TWO equ $5B
THREE equ $4F
DIG1ON equ $0E
DIG2ON equ $0D
DIG3ON equ $0B
DIG4ON equ $07
;repetition equ $32
repetitions equ 25
more_repetitions  equ 20


; variable/data section

 ifdef _HCS12_SERIALMON
            ORG $3FFF - (RAMEnd - RAMStart)
 else
            ORG RAMStart
 endif
 ; Insert here your data definition.
Counter     DS.W 1
FiboRes     DS.W 1


; code section
            ORG   ROMStart


Entry:
_Startup:

       LDS   #RAMEnd+1       ; initialize the stack pointer
       
       ldaa #$FF
       staa DDRB
       staa DDRJ
       ldaa #00
       staa PTJ
       staa DDRH
       staa DDRA
       ldaa #$0F
       staa DDRP

       
       ldab repetitions           ;load b with number of overall repetitions

repeat_loop_1:

                ldy more_repetitions          ;load y with 

                repeat_loop_2:
                               
START: 
       
       bsr first_digit
       bsr second_digit
       bsr third_digit
       bsr fourth_digit 
       clr PORTB      ; turn port B off
       
                  dbne y, repeat_loop_2
                  
                  dbne b, repeat_loop_1
                  
        bra finish
                 

first_digit:
       ldaa #ZERO    ; load zero to a
       staa PORTB     ; turn port B on
       ldaa #DIG1ON
       staa PTP       ;disable
       bsr delay
       rts
       
second_digit:
       ldaa #ONE    ; load one to a
       staa PORTB     ; turn port B on
       ldaa #DIG2ON
       staa PTP       ;disable
       bsr delay
       rts
       
third_digit:
       ldaa #TWO    ; load two to a
       staa PORTB     ; turn port B on
       ldaa #DIG3ON
       staa PTP       ;disable
       bsr delay
       rts

fourth_digit:
       ldaa #THREE    ; load three to a
       staa PORTB     ; turn port B on
       ldaa #DIG4ON
       staa PTP       ;disable
       bsr delay
       rts

           
; Make the delay equal to 0.5ms     
delay:
          ldx #4000
          delay_loop:
          
          
               dbne x, delay_loop
                
          rts		; return from subroutine
          
finish:

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
