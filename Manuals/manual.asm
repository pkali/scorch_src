    icl '../Atari/lib/ATARISYS.ASM'
    icl '../Atari/lib/MACRO.ASM'

screen_height = 26
screen_width = 40
screen = $1000 ; start - 40*screen_height

    org screen+screen_height*40  ; after the screen

src = $80
dest = $82
top_src = $84

start
    mwa #dl dlptrs
    mva #>WeaponFont chbas
    
    mwa #man_text_en top_src
    
main_loop
    mwa top_src src
    mwa #screen dest

    ldx #screen_height-1
screen_copy    
    ldy #0
@
      lda (src),y
      cmp #$ff  ; end of line marker
      bne not_eol

not_eol
      sta (dest),y
      iny
      cpy #screen_width
    bne @-
    adw src #screen_width
    adw dest #screen_width
    dex
    bpl screen_copy
    
    jsr GetKey
    cmp #@kbcode._down
    beq scroll_down
    cmp #@kbcode._up
    beq scroll_up
    jmp main_loop
  
scroll_down
    adw top_src #screen_width
    cpw top_src #(man_text_en_end-screen_height*screen_width)
    scc:mwa #(man_text_en_end-screen_height*screen_width) top_src
    jmp main_loop

scroll_up
    sbw top_src #screen_width
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
      beq checkJoyGetKey
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
paddlestate .byte 0
man_text_en
    ins 'manual.bin'  ;icl 'man_cart_txt_EN.asm'
man_text_en_end

    .align $400
WeaponFont
    ins 'manual_font_pl.fnt'  ; 'artwork/weapons.fnt'

    run start