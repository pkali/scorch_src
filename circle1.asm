
.IF *>0 ;this is a trick that prevents compiling this file alone

;--------------------------------------------------
.proc circle ;fxxxing good circle drawing :)
; xdraw,ydraw (word) - coordinates of circle center
; radius (byte) - radius of circle
;--------------------------------------------------
;Turbo Basic source
; R=30
; XC=0:YC=R
; FX=0:FY=8*R:FS=4*R+3
; WHILE FX<FY
;   splot8    //splot8 are eight plotz around the circle
;   XC=XC+1
;   FX=FX+8
;   IF FS>0
;     FS=FS-FX-4
;   ELSE
;     YC=YC-1
;     FY=FY-8
;     FS=FS-FX-4+FY
;   ENDIF
; WEND
; splot8

    mwa xdraw xcircle
    mwa ydraw ycircle

; XC=0:YC=R
    mwa #0 xc
    mva radius yc
; FX=0:FY=8*R:FS=4*R+3
    mva #0 fx
    mva radius fy
    asl FY
    asl FY
    mva FY FS
    asl FY
    ; A = FS and C = 0
    ;clc
    ;lda FS
    adc #3
    sta FS

circleloop
; WHILE FX<FY
    lda FX
    cmp FY
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

;   XC=XC+1
    inc XC

;   FX=FX+8
    clc
    lda FX
    adc #8
    sta FX

;   IF FS>0
;     FS=FS-FX-4
    lda FS
    beq else01
    bmi else01
    sec
    sbc FX
    sbc #4
    sta FS
    jmp circleloop ; endif01
else01
;   ELSE
;     YC=YC-1
    dec YC
;     FY=FY-8
    sec
    lda FY
    sbc #8
    sta FY
;     FS=FS-FX-4+FY
    lda FS
    sec
    sbc FX
    sbc #4
    clc
    adc FY
    sta FS
endif01
;   ENDIF
    jmp circleloop
; WEND
.endp

.endif