PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

IFR = $600d
IER = $600e
PCR = $600c

value = $0200	; 2 bytes each
mod10 = $0202
message = $0204	; 6 bytes
counter = $020a	; 2 bytes


E = %10000000
RW = %01000000
RS = %00100000


 .org $8000

reset:
 ldx #$ff	; load x register with 0xff
 txs		; transfer 0xff from x register to stack pointer
 cli

 lda #$82	; set interrupt enable for CA1 pin 
 sta IER
 lda #$00	; set CA1 Pin to negative active edge
 sta PCR



 lda #%11111111 ; set all pins in port B to output mode
 sta DDRB

 lda #%11100000 ; set top 3 pins in port A to output
 sta DDRA


 lda #%00111000 ; 8-bit mode, 2-line display, 5x8 font
 jsr lcd_instruction

 lda #%00001100 ; set display ON, cursor ON, curosr blinking ON 
 jsr lcd_instruction
 
 lda #%00000110 ; set mode to increment and no shifting
 jsr lcd_instruction

 lda #%00000001 ; clear display
 jsr lcd_instruction

 lda #0
 sta counter
 sta counter + 1


loop:

 lda #%00000010 ; home
 jsr lcd_instruction

 lda #0
 sta message


 lda number	; store both parts of the number in RAM
 sta value
 lda number + 1
 sta value + 1

divide:
 lda #0		; initialize left part of algorithm to 0
 sta mod10
 sta mod10 + 1
 clc		; clear carry bit


 ldx #16
divloop:
 rol value 	; rotate everything right
 rol value + 1
 rol mod10
 rol mod10 + 1

 ; do subtraction...
 sec 
 lda mod10 	
 sbc #10	; ...for the low byte
 tay		; save low byte in y register
 lda mod10 + 1
 sbc #0 	; ...for the high byte
 ; now a,y = dividend

 bcc ignore_result	; branch if carry is clear, ie subtration had to borrow

 sty mod10		; else put the result in to the remainder section
 sta mod10 + 1		

ignore_result:
 dex
 bne divloop		; branch back if x is not zero
 rol value 		;shift in the last bit og the quotient
 rol value + 1


 lda mod10
 clc 
 adc #"0"
 jsr push_char

 ; if value != 0, continue
 lda value
 ora value + 1
 bne divide		; branch if value is not zero


 ldx #0

print:

 lda message,x

 beq loop

 jsr print_char

 inx
 jmp print 


number: .word 0

; Add the character in the A register to the beginning of the 
; null-terminated string 'message' in ram 
push_char:
 pha	; push new first char on to stack
 ldy #0

char_loop:
 lda message,y 	;get char on string and put into X
 tax
 pla
 sta message,y	; pull char off stack and add it to the string
 iny
 txa
 pha		; push char from string on to the stack
 bne char_loop

 pla
 sta message, y	; pull the null oof the stack and add it to the end of the string
 rts

lcd_wait:

 pha

 lda #%00000000	; set Port b to input
 sta DDRB

lcd_busy:
 lda #RW
 sta PORTA

 lda #(RW | E)
 sta PORTA

 lda PORTB 	 

 and #%10000000	; and to check if busy flag is checked
 bne lcd_busy

 lda #RW
 sta PORTA

 lda #%11111111	; set Port b to output
 sta DDRB

 pla

 rts

lcd_instruction:

 jsr lcd_wait

 sta PORTB
 lda #0		; Clear RS/RW/E to 0
 sta PORTA
 lda #E		; toogle enable bit to accept values entered previously
 sta PORTA
 lda #0		; Clear RS/RW/E to 0
 sta PORTA
 rts

print_char:
 jsr lcd_wait

 sta PORTB

 lda #RS	; Clear RS/RW/E to 0
 sta PORTA

 lda #(RS | E) 	; toogle enable bit to accept values entered previously
 sta PORTA

 lda #RS	; Clear RS/RW/E to 0
 sta PORTA
 rts

nmi:
irq:
 
 lda IFR
 and #%00000010	; flag for CA1
 bne button_1
 
 and #%00000001	; flag for CA2
 bne button_2

 and #%00010000	; flag for CB1
 bne button_3

 and #%00001000	; flag for CB2
 bne button_4

 ; error log

 lda #8
 sta number 
 jmp exit_irq


button_1:
 lda #1
 sta number
 jmp exit_irq

button_2:
 lda #2
 sta number 
 jmp exit_irq

button_3:
 lda #3
 sta number 
 jmp exit_irq

button_4:
 lda #4
 sta number 
 jmp exit_irq

exit_irq:
 bit PORTA
 rti 



 .org $fffa
 .word nmi
 .word reset
 .word irq
 


