    icl '../Atari/lib/ATARISYS.ASM'
    icl '../Atari/lib/MACRO.ASM'

screen_height = 26
screen_width = 40
screen = $1000 ; start - 40*screen_height

    org screen+screen_height*40  ; after the screen

    .zpvar src .word = $80
    .zpvar dest .word
    .zpvar top_src .word
    .zpvar next_line_begin .byte
    .zpvar end_address .word
    .zpvar start_address .word
    .zpvar temp .word

start
    mwa #dl dlptrs
    mva #>WeaponFont chbas
    
    mwa #man_text_en top_src
    
main_loop
    bit escflag
    spl:rts  ; EXIT THIS WAY --->
    mva #0 shiftflag
    mwa top_src src
    mwa #screen dest

    ldx #screen_height-1
screen_copy
    mwa top_src start_address
    ldy #0
@
      lda (src),y
      cmp #$ff  ; end of line marker
      bne not_eol
        sty next_line_begin
        lda #$00
@         sta (dest),y
          iny
          cpy #screen_width
        bne @-
        jmp next_line

not_eol
      sta (dest),y
      iny
      cpy #screen_width
    bne @-1
    mva #screen_width-1 next_line_begin
next_line
    adw dest #screen_width
    ; adw src #screen_width
    inc next_line_begin
    clc
    lda src
    adc next_line_begin
    sta src
    scc:inc src+1
    
    dex
    bpl screen_copy
    ; save the current end of the printed text source
    mwa src end_address
    
    jsr GetKey
    cmp #@kbcode._down
    beq scroll_down
    cmp #@kbcode._up
    beq scroll_up
    jmp main_loop
  
scroll_down
    lda #1  ; repeat_counter
    ; make it repeat 10 times if SHIFT is pressed
    bit shiftflag
    spl:lda #screen_height
    sta repeat_counter
    
scroll_repeat_loop
    ; find first $ff after top_src and move it there
    ldy #-1
@     iny
      lda (top_src),y
      cmp #$ff
    bne @-
    iny
    tya
    clc
    adc top_src
    sta top_src
    scc:inc top_src+1
    
    ;adw top_src #screen_width
    cpw end_address #man_text_en_end
    scc:mwa start_address top_src
    dec repeat_counter
    bne scroll_repeat_loop
    jmp main_loop

scroll_up
    ; find second $ff before top_src
    sbw top_src #$00ff temp
    ldy #$ff-1
@     dey
      lda (temp),y
      cmp #$ff
    bne @-
    iny
    tya
    clc
    adc temp
    sta top_src
    lda temp+1
    adc #0
    sta top_src+1
    
    ;sbw top_src #screen_width
    cpw top_src #man_text_en
    scs:mwa #man_text_en top_src
    jmp main_loop
    

;--------------------------------------------------
.proc GetKey
; returns pressed value in A
; when [ESC] is pressed, escFlag is set
; result: A=keycode
;--------------------------------------------------
getKeyAfterWait
      lda SKSTAT
      cmp #$ff
      beq checkJoyGetKey ; key not pressed, check Joy
      cmp #$f7  ; SHIFT
      bne @+
      mva #$80 shiftflag
      bne checkJoyGetKey
      
@
    lda kbcode
    cmp #@kbcode._none
    beq checkJoyGetKey
    and #$3f ;CTRL and SHIFT ellimination
    cmp #@kbcode._esc  ; 28  ; ESC
    bne getkeyend
      mvy #$80 escFlag
    bne getkeyend

checkJoyGetKey
      ;------------JOY-------------
      ;happy happy joy joy
      ;check for joystick now
      lda STICK0
      and #$0f
      cmp #$0f
      beq notpressedJoyGetKey
      tay
      lda joyToKeyTable,y
      bne getkeyend

notpressedJoyGetKey
    ;fire
    lda STRIG0
    beq JoyButton
      jsr Check2button
      bcc SecondButton
      bne checkSelectKey
checkSelectKey
      lda CONSOL
      and #%00000010    ; Select
      beq SelectPressed
      lda CONSOL
      and #%00000100    ; Option
    bne getKeyAfterWait
OptionPressed
    lda #@kbcode._atari    ; Option key
    bne getkeyend
SecondButton
SelectPressed
    lda #@kbcode._tab    ; Select key
    bne getkeyend
JoyButton
    lda #@kbcode._ret ;Return key
    mva #$80 shiftflag
getkeyend
    ldy #0
    sty ATRACT    ; reset atract mode
    rts
Check2button
    lda PADDL0
    and #$c0
    eor #$C0
    cmp PaddleState
    sta PaddleState
    rts
.endp


dl
    :2 .byte SKIP8
    .byte LMS+MODE2
    .word screen
    :(screen_height-1) .byte MODE2
    .byte JVB
    .word dl

joyToKeyTable
    .by $ff             ;00
    .by $ff             ;01
    .by $ff             ;02
    .by $ff             ;03
    .by $ff             ;04
    .by $ff             ;05
    .by $ff             ;06
    .by @kbcode._right  ;07
    .by $ff             ;08
    .by $ff             ;09
    .by $ff             ;0a
    .by @kbcode._left   ;0b
    .by $ff             ;0c
    .by @kbcode._down   ;0d
    .by @kbcode._up     ;0e
    .by $ff             ;0f

escflag .byte 0
shiftflag .byte 0
repeat_counter .byte 0
paddlestate .byte 0
man_text_en
    ins 'manual.bin'  ;icl 'man_cart_txt_EN.asm'
man_text_en_end
    .by $ff, $ff

    .align $400
WeaponFont
    ins 'manual_font_pl.fnt'  ; 'artwork/weapons.fnt'

    run start