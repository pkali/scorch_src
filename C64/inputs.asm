;--------------------------------------------------
.proc GetKey
; waits for pressing a key and returns pressed value in A
; when [ESC] is pressed, escFlag is set
; result: A=keycode
;--------------------------------------------------
    jsr WaitForKeyRelease
    jsr GetKeyFast
    ldy #0
    sty escFlag
    rts
.endp

;--------------------------------------------------
.proc GetKeyFast
; returns pressed value in A - no wait for press
; when [ESC] is pressed, escFlag is set
; result: A=keycode 
;--------------------------------------------------
    lda #$ff
    rts
.endp

;--------------------------------------------------
.proc getkeynowait
;--------------------------------------------------
    jsr WaitForKeyRelease
    lda kbcode
    and #$3f ;CTRL and SHIFT ellimination
    rts
.endp

;--------------------------------------------------
.proc WaitForKeyRelease
;--------------------------------------------------
StillWait
      rts
.endp
;--------------------------------------------------
.proc IsKeyPressed
; result: A=0 - yes , A>0 - no
;--------------------------------------------------
    lda #1
    rts
.endp
;--------------------------------------------------
.proc CheckStartKey
;--------------------------------------------------
    lda #%00000001 ; START KEY not pressed
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

    rts
;
.endp
