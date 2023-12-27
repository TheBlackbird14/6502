PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

IFR = $600d
IER = $600e
PCR = $600c

E = %10000000
RW = %01000000
RS = %00100000


 .org $8000

reset:
 ldx #$ff	; load x register with 0xff
 txs		; transfer 0xff from x register to stack pointer
 cli

 lda #%10011011	; set interrupt enable for CA1-CB2 pin 
 sta IER
 lda #$00	; set CA1-CB2 Pin to negative active edge
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

loop:
 jmp loop

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

 lda #%00000001 ; clear display
 jsr lcd_instruction

; lda #$39
; jsr print_char

 lda IFR
 and #%01000000	; flag for CA1
 bne button_1
 
 and #%10000000	; flag for CA2
 bne button_2

 and #%00001000	; flag for CB1
 bne button_3

 and #%00010000	; flag for CB2
 bne button_4

 ; error log

 lda #$38
 jsr print_char
 jmp exit_irq


button_1:
 lda #$31 
 jsr print_char
 jmp exit_irq

button_2:
 lda #$32
 jsr print_char
 jmp exit_irq

button_3:
 lda #$33
 jsr print_char
 jmp exit_irq

button_4:
 lda #$34
 jsr print_char
 jmp exit_irq

exit_irq:


 bit PORTA
 rti 






 .org $fffa
 .word nmi
 .word reset
 .word irq
