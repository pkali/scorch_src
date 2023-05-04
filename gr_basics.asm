.IF *>0 ;this is a trick that prevents compiling this file alone

; Basic hardware-dependent graphics routines.

; -----------------------------------------
.proc unPlot
; plots a point and saves the plotted byte, reverts the previous plot.
; -----------------------------------------
    ldx #0 ; only one pixel
unPlotAfterX
    stx WhichUnPlot

    ; first remake the oldie
    lda oldplotL,x
    sta oldplot
    lda oldplotH,x
    sta oldplot+1

    lda oldply,x
    tay
    lda oldora,x
    sta (oldplot),y


    ; is it not out of the screen ????
    cpw ydraw #screenheight
    jcc CheckX
    mwa #0 ydraw
CheckX
    cpw xdraw #screenwidth
    jcs EndOfUnPlot
MakeUnPlot
    ; let's count coordinates taken from xdraw and ydraw
    ;xbyte = xbyte/8
    lda xdraw+1
    lsr
    lda xdraw
    ror ;just one bit over 256. Max screenwidth = 512!!!
    lsr
    lsr
;---
    tay
    ldx WhichUnPlot
	tya
    sta oldply,x

    ldx ydraw
    lda linetableL,x
    sta xbyte
    sta oldplot
    lda linetableH,x
    sta xbyte+1
    sta oldplot+1

    lda xdraw
    and #$7
    tax

    lda color
    bne ClearUnPlot

    ;plotting here
    lda (xbyte),y
    sta OldOraTemp
    ora bittable,x
    sta (xbyte),y
    bne ContinueUnPlot ; allways <>0
ClearUnPlot
    lda (xbyte),y
    sta OldOraTemp
    and bittable2,x
    sta (xbyte),y
ContinueUnPlot
    ldx WhichUnPlot
    lda OldOraTemp
    sta oldora,x
    lda oldplot
    sta oldplotL,x
    lda oldplot+1
    sta oldplotH,x
    ; and now we must solve the problem of several plots
    ; in one byte
    ldx #4
    ldy WhichUnPlot
LetsCheckOverlapping
    cpx WhichUnPlot
    beq SkipThisPlot
    lda oldplotL,x
    cmp oldplotL,y
    bne NotTheSamePlot
    lda oldplotH,x
    cmp oldplotH,y
    bne NotTheSamePlot
    lda oldply,x
    cmp oldply,y
    bne NotTheSamePlot
    ; the pixel is in the same byte so let's take correct contents
    lda oldora,x
    sta oldora,y
NotTheSamePlot
SkipThisPlot
    dex
    bpl LetsCheckOverlapping
EndOfUnPlot
    rts
.endp

; -----------------------------------------
.proc plot  ;plot (xdraw, ydraw, color)
; color == 1 --> put pixel
; color == 0 --> erase pixel
; this is one of the most important routines in the whole
; game. If you are going to speed up the game, start with
; plot - it is used by every single effect starting from explosions
; through line drawing and small text output!!!
; 
; Optimized by 0xF (Fox) THXXXX!!!

; -----------------------------------------
    ; is it not over the screen ???
    cpw ydraw #(screenheight+1); changed for one additional line. cpw ydraw #(screenheight-1)
    bcs unPlot.EndOfUnPlot ;nearest RTS
CheckX02
    cpw xdraw #screenwidth
    bcs EndOfPlot 
MakePlot
    ; let's calculate coordinates from xdraw and ydraw

    ;xbyte = xbyte/8
    lda xdraw+1
    lsr
    lda xdraw
    ror ;just one bit over 256. Max screenwidth = 512!!!
    lsr
    lsr
    sta xbyte
    ;---
    ldx ydraw
    ldy linetableL,x
    lda linetableH,x
    sta xbyte+1

    lda xdraw
    and #$7
    tax
    lda color
    bne ClearPlot

    lda (xbyte),y
    ora bittable,x
    sta (xbyte),y
EndOfPlot
    rts
ClearPlot
    lda (xbyte),y
    and bittable2,x
    sta (xbyte),y
    rts
.endp

; -----------------------------------------
.proc point_plot
; -----------------------------------------
    ; checks state of the pixel (coordinates in xdraw and ydraw)
    ; result is in A (zero or appropriate bit is set)

    ; let's calculate coordinates from xdraw and ydraw

    ;xbyte = xbyte/8
    lda xdraw+1
    lsr
    lda xdraw
    ror ;just one bit over 256. Max screenwidht = 512!!!
    lsr
    lsr
    sta xbyte
    ;---
    ldx ydraw
    ldy linetableL,x
    lda linetableH,x
    sta xbyte+1

    lda xdraw
    and #$7
    tax

    lda (xbyte),y
    eor #$ff
    and bittable,x
    rts
.endp

;--------------------------------------------------
.proc ClearScreen
;--------------------------------------------------
    mwa #display temp
    ldy #0
@     lda #$ff
      sta (temp),y
      inw temp
      cpw temp #display+screenheight*screenBytes+1
    bne @-
   rts 
.endp

;--------------------------------------------------
.proc GenerateLineTable

    mwa #display temp
    mwa #linetableL temp2
    mwa #linetableH modify
    ldy #0
@     lda temp
      sta (temp2),y
      lda temp+1
      sta (modify),y
      adw temp #40
      iny
      cpy #screenheight+1
    bne @-
	rts
.endp

.ENDIF