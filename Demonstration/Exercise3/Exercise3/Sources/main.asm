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

; variable/data section

      ORG RAMStart
 ; Insert here your data definition.


string          DS.B 50
string_end        equ $0D
string_length     equ $13

new_string DS.B  50
;old_string FCC "This is an old String"

CarRet equ $0D


; code section
     ORG   ROMStart

 Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts

            MOVB #%10011101,SCI1BDL     ;Baud Rate   
           
            LDY #$00
            CLR new_string
            CLRA
            CLRB
            BRA readStringStart


;Main Write


writeStringStart:
            
             
              CLRA
              LDX #$00
              LDX #new_string
                 
             
              MOVB #%00100000,SCI1CR1
              
              MOVB #%00000000,SCI1CR2
               
              

writeString:
      
              LDAB SCI1SR1
              ANDB #%10000000 
              BEQ writeString
            
              
              
              LDAA 1,x+                   ;load next value
              
                            
              

              
              CMPA #$5A                    ;check Z
              BEQ finishWrite
              
              CMPA #$0D                    ;check carriage
              BEQ finishWrite
              
              STAA SCI1DRL 
              MOVB #%00001100,SCI1CR2      ;push to serial
            
 transmit:    
              LDAB SCI1SR1
              ANDB #%01000000 
              BEQ transmit
                          
              
                          
              BRA writeString




finishWrite:
            
    
              MOVB #CarRet,SCI1DRL

              MOVB #%00001100, SCI1CR2
             
              LDY #$01
transmitagain:    
              LDAB SCI1SR1
              ANDB #%01000000 
              BEQ transmitagain
              BRA readStringStart               
             
;------------------------------------------------------------------





;------------------------------------------------------------------

readStringStart:
            
           
         
            LDX #new_string    ;load new string to write to
            LDAB #$00 
            
            MOVB #%00100000, SCI1CR1    ;reciever bit
             
            MOVB #%00001100, SCI1CR2    ;reciever bit
             
            BRA readStringPoll

readStringPoll:
           
           LDAB SCI1SR1
           ANDB #%00100000 
           BEQ readStringPoll
              

readString:               
           LDAA SCI1DRL         ;get letter
           CMPA #$0D             ;check carriage
           BEQ writeStringStart  ;leave if carriage
           STAA 0,x              ;store
           INX                   ;increment
           BRA readStringPoll


            
;------------------------------------------------------------------


            
finish:


                   
            

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************


            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
