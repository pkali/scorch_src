    icl '../Atari/lib/ATARISYS.ASM'
    icl '../Atari/lib/MACRO.ASM'
    icl '../Atari/lib/cartloader_vectors.inc'

.IFNDEF LANG
    .def LANG = "PL"
.ENDIF

screen_height = 26
screen_width = 40
screen = $1000 ; start - 40*screen_height
KeyRepeatSpeed = 15 ; (max 127 !!!)


STEREOMODE  equ 0

    org screen+screen_height*40  ; after the screen

    .zpvar src .word = $80
    .zpvar dest .word
    .zpvar top_src .word
    .zpvar next_line_begin .byte
    .zpvar end_address .word
    .zpvar start_address .word
    .zpvar temp .word

start
    lda #0
    sta dmactls ; screen off
    ldx #3
@   sta COLOR0-1,x
    dex
    bpl @-
    jsr WaitOneFrame    
    jsr CheckPALorNTSC
    ldx #<MODUL                  ;low byte of RMT module to X reg
    ldy #>MODUL                 ;hi byte of RMT module to Y reg
    lda #0                      ;starting song line 0-255 to A reg
    jsr RASTERMUSICTRACKER      ;Init
    ;second POKEY init
    lda #0
    sta AUDCTL+$10
    ldy #3
    sty SKCTL+$10
    ldy #8
@   
      sta POKEY+$10,y
      dey
    bpl @-
    
    
    mwa #dl dlptrs
    mva #>WeaponFont chbas
    
    mwa #man_text top_src
    
    vmain VBLANK,7

    jsr MakeScreenCopy
    
    lda #@dmactl(standard|dma) ; standard screen width, DL on, P/M off
    sta dmactls
    jsr WaitOneFrame
    jsr FadeIn
    
main_loop
    bit escflag
    bpl NoEscape
      ; EXIT THIS WAY --->
    jsr FadeOut
    VMAIN XITVBV,7          ; jsr SetVBL (off user proc)
    lda #0  ; stereo silence
    sta AUDCTL
    sta AUDCTL+$10
    ldy #3
    sty SKCTL
    sty SKCTL+$10
    ldy #8
@   
      sta POKEY,y
      sta POKEY+$10,y
      dey
    bpl @-
    LDA #%01000000          ; DLI off
    STA NMIEN
    lda #0  ; screen off
    sta dmactls
    sta escflag
    jsr WaitOneFrame
    ; exit to cart loader
    
    mva #0 X_BANK
    mwa #$a000 X_SRC
    mva #$10 X_CLRSTART
    jmp X_LOADER_START
NoEscape    
    jsr MakeScreenCopy
    ; save the current end of the printed text source
    mwa src end_address
    
    jsr GetKey
    cmp #@kbcode._down
    beq scroll_down
    cmp #@kbcode._up
    beq scroll_up
    cmp #@kbcode._left
    beq prev_chapter
    cmp #@kbcode._del
    beq prev_chapter
    cmp #@kbcode._right
    jeq next_chapter
    cmp #@kbcode._space
    jeq next_chapter
    jmp main_loop
  
scroll_down
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
    cpw end_address #man_text_end
    scc:mwa start_address top_src
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
    cpw top_src #man_text
    scs:mwa #man_text top_src
    jmp main_loop
    
prev_chapter
    ; find first $fe above the screen
    sbw top_src #screen_width temp  ; start a bit above the current screen
    ldy #0
prev_letter
    lda (temp),y
    cmp #$fe  ; $fe - chapter marker
    beq prev_chapter_found
    dew temp
    cpw temp #man_text
    bcs @+
      mwa #man_text top_src
      jmp main_loop
@
    jmp prev_letter
prev_chapter_found
    mwa temp top_src
    jsr WaitForKeyRelease
    jmp main_loop
    
next_chapter
    ; find first $fe below the top of the screen
    adw top_src #screen_width temp  ; start ~1 line below the current screen top
    ldy #0
next_letter
    lda (temp),y
    cmp #$fe
    beq next_chapter_found
    inw temp
    cpw temp #man_text_end-screen_width*4
    bcc @+
      mwa start_address top_src
      jmp main_loop
@
    jmp next_letter
next_chapter_found
    mwa temp top_src
    jsr WaitForKeyRelease
    jmp main_loop
;--------------------------------------------------
.proc MakeScreenCopy
    mwa top_src src
    mwa #screen dest

    ldx #screen_height-1
screen_copy
    mwa top_src start_address
    ldy #0
@
      lda (src),y
      cmp #$fe  ; chapter marker
      bne not_chapter
      lda #0
      beq not_eol
not_chapter
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
    rts
.endp    
;--------------------------------------------------
.proc FadeIn
    ldy #15
FirstLoop
    lda COLOR1
    cmp #13
    beq ColorOK
    inc COLOR1
ColorOK
    jsr WaitOneFrame
    dey
    bpl FirstLoop
    rts
.endp
;--------------------------------------------------
.proc FadeOut
    ldy #15
FirstLoop
    lda COLOR1
    beq ColorOK
    dec COLOR1
ColorOK
    jsr WaitOneFrame
    dey
    bpl FirstLoop
    rts
.endp

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

;--------------------------------------------------
.proc WaitForKeyRelease
;--------------------------------------------------
    mva #128-KeyRepeatSpeed pressTimer    ; tricky
StillWait
    bit pressTimer
    bmi KeyReleased
      lda STICK0
      and #$0f
      cmp #$0f
      bne StillWait
      lda STRIG0
      beq StillWait
      lda SKSTAT
      cmp #$ff
      bne StillWait
      lda CONSOL
      and #%00000110    ; Select and Option only
      cmp #%00000110
      bne StillWait
KeyReleased
      rts
.endp
;--------------------------------------------------
.proc VBLANK  ;vertical blank interrupt
;--------------------------------------------------
    
    lda ticksPerSecond
    cmp #60
    bne PALMusic
    ; it is NTSC HERE -- slow down the sound
    lda ticks
    and #%00000111
    beq skipSoundFrame
PALMusic
    bit:smi:inc pressTimer ; timer halted if >127. max time measured 2.5 s
    ;lda ticks
    ;and #%00000011
    ;beq skipSoundFrame
playNow
    jsr RASTERMUSICTRACKER+3
    ; fake POKEY reverb
    ldy #8
@     lda fake_pokey,y
      sta $d210,y
      dey
    bpl @-
skipSoundFrame

    ;time update
    inc:lda ticks
    cmp ticksPerSecond
    sne:mva #0 ticks

VBLANKEND   
    jmp XITVBV
.endp
;--------------------------------------------------
.proc WaitOneFrame
;--------------------------------------------------
    waitRTC    ; or wait ?
    rts
.endp
;--------------------------------------------------
.proc CheckPALorNTSC
;--------------------------------------------------
    lda $d014 ;http://www.myatari.com/nirdary.html
    and #%00001110
    bne NTSC
    lda #50
    sta ticksPerSecond
    rts
NTSC
    lda #60
    sta ticksPerSecond
    rts
.endp

    icl "music/rmtplayr.a65"  


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


escflag     .byte 0
paddlestate .byte 0
ticks       .byte 0
ticksPerSecond .byte 0
fake_pokey  :9 .byte 0
pressTimer  .byte 0


man_text
    .if LANG = "PL"
      ins 'MANUAL_PL_A800.bin' ; 'manual.bin'  ;icl 'man_cart_txt_EN.asm'
    .else
      ins 'MANUAL_EN.bin'
    .endif
man_text_end
    .by $ff, $ff

       opt h-                       ;RMT module is standard Atari binary file already
    ins "music/czytaczu1_stripped.rmt"             ;include music RMT module
    opt h+
MODUL   equ $B000
    org $BC00
WeaponFont
    ins 'manual_font_pl.fnt'  ; 'artwork/weapons.fnt'

    run start