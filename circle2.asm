
.IF *>0 ;this is a trick that prevents compiling this file alone

;--------------------------------------------------
.proc circle ;fxxxing good circle drawing :)
; xdraw,ydraw (word) - coordinates of circle center
; radius (byte) - radius of circle
;--------------------------------------------------
;Turbo Basic source
;XC=0
;YC=R
;PC=R (FS)
;
;WHILE XC<=YC
;
;    SPLOT(XC,YC)
;    IF PC>YC THEN
;        YC=YC-1
;        PC=PC-YC
;    ENDIF
;    XC=XC+1
;    PC=PC+XC
;
;WEND

    mwa xdraw xcircle
    mwa ydraw ycircle

; XC=0:YC=R:FS=R
    mwa #0 xc
    mva radius yc
    sta FS

circleloop
;WHILE XC<=YC
    lda XC
    cmp YC
    bcc not_endcircleloop
endcircleloop
    mwa xcircle xdraw
    mwa ycircle ydraw
    rts
not_endcircleloop
;    jsr splot8
;----
; splot8
; plot xcircle+XC,ycircle+YC
; plot xcircle+XC,ycircle-YC
; plot xcircle-XC,ycircle-YC
; plot xcircle-XC,ycircle+YC

; plot xcircle+YC,ycircle+XC
; plot xcircle+YC,ycircle-XC
; plot xcircle-YC,ycircle-XC
; plot xcircle-YC,ycircle+XC

    ;clc - allways after BCC
    lda xcircle
    adc XC
    sta xdraw
    lda xcircle+1
    adc #0
    sta xdraw+1
    ;clc
    lda ycircle
    adc YC
    sta ydraw
    sta ytempDRAW
    lda ycircle+1
    adc #$00
    sta ydraw+1
    sta ytempDRAW+1
    ; plot xcircle+XC,ycircle+YC
    jsr plot

    sec
    lda ycircle
    sbc YC
    sta ydraw
    lda ycircle+1
    sbc #$00
    sta ydraw+1
    ; plot xcircle+XC,ycircle-YC
    jsr plot

    sec
    lda xcircle
    sbc XC
    sta xdraw
    lda xcircle+1
    sbc #0
    sta xdraw+1
    ; plot xcircle-XC,ycircle-YC
    jsr plot

    lda ytempDRAW
    sta ydraw
    lda ytempDRAW+1
    sta ydraw+1
    ; plot xcircle-XC,ycircle+YC
    jsr plot
;---
    clc
    lda xcircle
    adc YC
    sta xdraw
    lda xcircle+1
    adc #0
    sta xdraw+1
    ;clc
    lda ycircle
    adc XC
    sta ydraw
    sta ytempDRAW
    lda ycircle+1
    adc #$00
    sta ydraw+1
    sta ytempDRAW+1
    ; plot xcircle+YC,ycircle+XC
    jsr plot

    sec
    lda ycircle
    sbc XC
    sta ydraw
    lda ycircle+1
    sbc #$00
    sta ydraw+1
    ; plot xcircle+YC,ycircle-XC
    jsr plot

    sec
    lda xcircle
    sbc YC
    sta xdraw
    lda xcircle+1
    sbc #0
    sta xdraw+1
    ; plot xcircle-YC,ycircle-XC
    jsr plot

    lda ytempDRAW
    sta ydraw
    lda ytempDRAW+1
    sta ydraw+1
    ; plot xcircle-YC,ycircle+XC
    jsr plot
;-----

;    IF FS>YC THEN
    lda YC
    cmp FS
    bcc endif01
;        YC=YC-1
    dec YC
;        FS=FS-YC
    sec
    lda FS
    sbc YC
    sta FS
endif01
;    ENDIF
;    XC=XC+1
    inc XC
;    FS=FS+XC
    clc
    lda FS
    adc XC
    sta FS
    jmp circleloop
; WEND
.endp

.endif