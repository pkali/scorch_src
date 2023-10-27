;--------------------------------------------------
.proc GetKey
; waits for pressing a key and returns pressed value in A
; when [ESC] is pressed, escFlag is set
; result: A=keycode
;--------------------------------------------------
    jsr WaitForKeyRelease
getKeyAfterWait
    jsr GetKeyFast
    cmp #@kbcode._none
    beq getKeyAfterWait
    ldy #0
    sty ATRACT                 ; reset atract mode
    mvy #sfx_keyclick sfx_effect
    rts
.endp

;--------------------------------------------------
.proc GetKeyFast
; returns pressed value in A - no waits for press
; when [ESC] is pressed, escFlag is set
; result: A=keycode ($ff - no key pressed)
;--------------------------------------------------
    .IF TARGET = 800
      lda SKSTAT
      cmp #$ff
      beq checkJoyGetKey       ; key not pressed, check Joy
      cmp #$f7                 ; SHIFT
      beq checkJoyGetKey
    .ELIF TARGET = 5200
      lda SkStatSimulator
      and #%11111110
      bne checkJoyGetKey       ; key not pressed, check Joy
    .ENDIF
    lda kbcode
    cmp #@kbcode._none
    beq checkJoyGetKey
    pha
    and #$3f                   ; CTRL and SHIFT ellimination
    cmp #@kbcode._esc          ; 28  ; ESC
    beq EscPressed
    pla
    jmp getkeyend
EscPressed
    pla
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
    .IF TARGET = 800           ; Second joy button , Select and Option key only on A800
      jsr Check2button
      bcc SecondButton
      bne checkSelectKey
checkSelectKey
      lda CONSOL
      and #%00000010           ; Select
      beq SelectPressed
      lda CONSOL
      and #%00000100           ; Option
      beq OptionPressed
    .ENDIF
    lda #@kbcode._none
    bne getkeyend
OptionPressed
    lda #@kbcode._atari        ; Option key
    bne getkeyend
SecondButton
SelectPressed
    lda #@kbcode._tab          ; Select key
    bne getkeyend
JoyButton
    lda #@kbcode._ret          ; Return key
getkeyend
    rts
; ----
    .IF TARGET = 800           ; Second joy button only on A800
Check2button
    lda PADDL0
    and #$c0
    eor #$C0
    cmp PaddleState
    sta PaddleState
    rts
    .ENDIF
.endp

;--------------------------------------------------
.proc getkeynowait
;--------------------------------------------------
    jsr WaitForKeyRelease
    lda kbcode
    and #$3f                   ; CTRL and SHIFT ellimination
    rts
.endp

;--------------------------------------------------
.proc WaitForKeyRelease
;--------------------------------------------------
    lda #128-KeyRepeatSpeed    ; tricky
    sec
    sbc FirstKeypressDelay     ; tricky 2 :)
    sta pressTimer
StillWait
    bit pressTimer
    bmi KeyAutoReleased
      lda STICK0
      and #$0f
      cmp #$0f
      bne StillWait
      lda STRIG0
      beq StillWait
    .IF TARGET = 800
      lda SKSTAT
      cmp #$ff
      bne StillWait
      lda CONSOL
      and #%00000110           ; Select and Option only
      cmp #%00000110
      bne StillWait
    .ELIF TARGET = 5200
      lda SkStatSimulator
      and #%11111110
      beq StillWait
    .ENDIF
KeyReleased
      mva #FirstKeySpeed FirstKeypressDelay
      rts
KeyAutoReleased                ; autorepeat
      mva #0 FirstKeypressDelay
      rts
.endp
;--------------------------------------------------
.proc IsKeyPressed
; result: A=0 - yes , A>0 - no
;--------------------------------------------------
    lda SKSTAT
    and #%00000100
    beq @+
    lda #1
@   and STRIG0
    rts
.endp
;--------------------------------------------------
.proc CheckStartKey
;--------------------------------------------------
    lda CONSOL  ; turbo mode
    and #%00000001 ; START KEY
    rts
.endp
;--------------------------------------------------
.proc CheckExitKeys
;--------------------------------------------------
; Checks keyboard and sets appropriate flags for exit procedures
; If START+OPTION is pressed - exit to GameOver screen
; If 'O' key is pressed - displays "Are you sure?" and - exit to GameOver screen
; If 'Esc' key is pressed - displays "Are you sure?" and - exit to Menu screen
; Just setting the right flags!!!

    ; Select and Option
    lda CONSOL
    and #%00000101             ; Start + Option
    beq QuitToGameover
    lda SKSTAT
    cmp #$ff
    jeq nokeys
    cmp #$f7                   ; SHIFT
    jeq nokeys

    lda kbcode
    and #%10111111             ; SHIFT elimination

    cmp #@kbcode._O            ; $08  ; O
    bne CheckEsc
    jsr AreYouSure
    bit escFlag
    bpl nokeys
    ;---O pressed-quit game to game over screen---
QuitToGameover
    mva #$C0 escFlag           ; bits 7 and 6 set
    rts
CheckEsc
    cmp #@kbcode._esc          ; 28  ; ESC
    bne nokeys
DisplayAreYouSure
    jsr AreYouSure
    ;---esc pressed-quit game---
nokeys
    bit escFlag
    rts
;
.endp
