PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
E = %10000000
RW = %01000000
RS = %00100000


 .org $8000

reset:
 ldx #$ff	; load x register with 0xff
 txs		; transfer 0xff from x register to stack pointer


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


 ldx #0

print:

 lda message,x

 beq loop

 jsr print_char

 inx
 jmp print 
 

loop:

 jmp loop


message: .asciiz "     Frohe                                Weihnachten!"


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


 .org $fffc
 .word reset
 .word $0000 
