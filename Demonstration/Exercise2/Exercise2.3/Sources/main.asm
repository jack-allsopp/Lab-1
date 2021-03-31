;*****************************************************************
;* This stationery serves as the framework for a                 *
;* user application (single file, absolute assembly application) *
;* For a more comprehensive program that                         *
;* demonstrates the more advanced functionality of this          *
;* processor, please see the demonstration applications          *
;* located in the examples subdirectory of the                   *
;* Freescale CodeWarrior for the HC12 Program directory      
;*  
;*           Displaying numbers triggered by push button         *
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
       ;staa DDRH

forever:
        ;ldaa ZERO
        ;staa PTH
        ldaa PTH
        cmpa #$FE         ;this will be true if we hold down PH0
        ;staa PTH
        ;ldaa PTH
        ;coma             ;a is one
        ;beq forever
        ;bne START
       ;beq START         ;uncomment this
        beq new_function
        ;staa PORTB       ; port B should turn on
        
        bra forever
      
;ldx #1000

new_function:
  ;ldx #41
  ;ldx #1
          ;loop1:
                ldy #2
                ;ldy #20000
                ;ldab #65535
                
                loop2:
                               
START: 
       bsr first_digit
       bsr second_digit
       bsr third_digit
       bsr fourth_digit 
       ;bsr delay      ; keep port B turned on
       clr PORTB      ; turn port B off
       ;bsr delay      ; keep port B turned off
       ;bra START      ; repeat
       
                  dbne y,loop2
                 
                  
                ;dbne x,loop1
                  
      ;rts		; return from subroutine
      bra forever

first_digit:
       ldaa #ZERO    ; load zero to a
       staa PORTB     ; turn port B on
       ldaa #DIG1ON
       staa PTP       ;disable
       ;bsr delay
       rts
       
second_digit:
       ldaa #ONE    ; load one to a
       staa PORTB     ; turn port B on
       ldaa #DIG2ON
       staa PTP       ;disable
       ;bsr delay
       rts
       
third_digit:
       ldaa #TWO    ; load two to a
       staa PORTB     ; turn port B on
       ldaa #DIG3ON
       staa PTP       ;disable
       ;bsr delay
       rts

fourth_digit:
       ldaa #THREE    ; load three to a
       staa PORTB     ; turn port B on
       ldaa #DIG4ON
       staa PTP       ;disable
       ;bsr delay
       rts

           
; Make the delay equal to 0.5ms     
delay:
          ;ldx #4000
          ldx #1
          delay_loop:
          
          
               dbne x, delay_loop
                
          ldx #1       
          rts		; return from subroutine

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
