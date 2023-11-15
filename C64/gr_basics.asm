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

    ldy #0
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
    lda xdraw
    and #%11111000
    ;sta xbyte
    ;---
    ldx ydraw
    clc
    adc linetableL,x
    sta xbyte
    sta oldplot
    lda linetableH,x
    adc xdraw+1
    sta xbyte+1
    sta oldplot+1

;    lda xdraw
;    and #$7
;    tax
    ldx xdraw   ; optimization (256 bytes long bittable)
    
    ldy #0

    lda color
    bne ClearUnPlot

    ;plotting here
    lda (xbyte),y
    sta OldOraTemp
    ora bittable1_long,x
    sta (xbyte),y
    bne ContinueUnPlot ; allways <>0
ClearUnPlot
    lda (xbyte),y
    sta OldOraTemp
    and bittable2_long,x
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
; xdraw (word) - X coordinate
; ydraw (word) - Y coordinate
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

    lda xdraw
    and #%11111000
    ;sta xbyte
    ;---
    ldx ydraw
    clc
    adc linetableL,x
    sta xbyte
    lda linetableH,x
    adc xdraw+1
    sta xbyte+1

;    lda xdraw
;    and #$7
;    tax
    ldx xdraw   ; optimization (256 bytes long bittable)
    
    ldy #0
    lda color
    bne ClearPlot

    lda (xbyte),y
    ora bittable1_long,x
    sta (xbyte),y
EndOfPlot
    rts
ClearPlot
    lda (xbyte),y
    and bittable2_long,x
    sta (xbyte),y
    rts
.endp

; -----------------------------------------
.proc point_plot
; -----------------------------------------
; checks state of the pixel (coordinates in xdraw and ydraw)
; xdraw (word) - X coordinate
; ydraw (word) - Y coordinate
; result is in A (0 - point is set;  appropriate bit is set - point is clear) INVERTED!

    ; let's calculate coordinates from xdraw and ydraw

    lda xdraw
    and #%11111000
    ;sta xbyte
    ;---
    ldx ydraw
    clc
    adc linetableL,x
    sta xbyte
    lda linetableH,x
    adc xdraw+1
    sta xbyte+1

;    lda xdraw
;    and #$7
;    tax
    ldx xdraw   ; optimization (256 bytes long bittable)

    ldy #0
    lda (xbyte),y
    and bittable1_long,x
    rts
.endp
;--------------------------------------------------
.proc drawmountains
;--------------------------------------------------
; draw mountains from mountaintable
    mwa #0 xdraw
    mwa #mountaintable modify
    mva #1 color

drawmountainsloop
    jsr DrawMountainLine
    inw modify
    inw xdraw
    cpw xdraw #screenwidth
    jne drawmountainsloop
    rts
DrawMountainLine
.IF FASTER_GRAF_PROCS = 1
    ; calculate lower point in one screen byte
    lda xdraw
    and #%00000111	; only every 8th pixel
    bne MinCalculated
    ; A=0
    ldy #7
@   cmp (modify),y
    bcs NotLower
    lda (modify),y
NotLower
    dey
    bpl @-
    sta temp2
    inc temp2	; this is our minimum
MinCalculated
    ldy #0
    lda (modify),y
    cmp #screenheight
    beq NoMountain
    sta ydraw
    sty ydraw+1
;    there was Drawline proc
    lda #screenheight
    sec
    sbc ydraw
    jsr plot.MakePlot
    ;  X - index in bittable (number of bit) and nothing more (for use) in C64 :)
;    jmp IntoDraw    ; jumps inside Draw routine
                    ; because one pixel is already plotted (and who cares? :) )
    lda xdraw
    and #%11111000
    sta temp    ; store for a bit faster add
    clc     ; and faster
@
    lda (xbyte),y
    and bittable2_long,x
    sta (xbyte),y
;IntoDraw
    inc ydraw
    lda temp
;    lda xdraw
;    and #%11111000
    ;sta xbyte
    ;---
    ldy ydraw
;    clc    ; C allways clear ! ?
    adc linetableL,y
    sta xbyte
    lda linetableH,y
    adc xdraw+1
    sta xbyte+1
    tya
    ldy #0
    cmp temp2   ; this is our minimum 
    bne @-
;    end of Drawline proc
;   and now fill bytes!
    lda xdraw
    and #%00000111	; only every 8th pixel
    bne NotFillBytes
    lda temp2
    cmp #screenheight+1   ; only if minimum is not miniminimum :)
    beq NotFillBytes
    
    dec ydraw   ; protection if temp2=screenheight
@   lda #0
    tay
    sta (xbyte),y
    inc ydraw
    lda xdraw
;    lda xdraw
;    and #%11111000
    ;sta xbyte
    ;---
    ldy ydraw
    clc
    adc linetableL,y
    sta xbyte
    lda linetableH,y
    adc xdraw+1
    sta xbyte+1
    tya
    cmp #screenheight
    bne @-   
NotFillBytes
.ELSE
    ldy #0
    lda (modify),y
    cmp #screenheight
    beq NoMountain
    sta ydraw
    sty ydraw+1
;    there was Drawline proc
drawline
    jsr plot.MakePlot
    inc ydraw
    lda ydraw
    cmp #screenheight
    bne drawline
;    end of Drawline proc
.ENDIF
NoMountain
    rts
.endp
;--------------------------------------------------
.proc SoilDownTurbo
;--------------------------------------------------
; fast SoilDown proc
    jsr ClearTanks
NoClearTanks
;    jsr CalcAndDrawMountains - to do  (now Atari only)
    jmp DrawTanks
    ;rts
.endp
;--------------------------------------------------
.proc TypeChar
; puts char on the graphics screen
; in: CharCode
; in: left LOWER corner of the char coordinates (xdraw, ydraw)
;--------------------------------------------------
    ; check coordinates
    cpw xdraw #(screenwidth-7)
    bcs CharOffTheScreen
    lda ydraw
    cmp #7
    bcc CharOffTheScreen
    cmp #(screenHeight-1)
    bcc CharOnTheScreen
CharOffTheScreen
    rts
CharOnTheScreen
Fast    ; Put char without coordinates check!
    ; char to the table
    lda CharCode
    sta fontind
    lda #$00
    sta fontind+1
    ; char intex times 8
    aslw fontind
    rolw fontind
    rolw fontind

    adw fontind #TankFont

    ; and 8 bytes to the table
    ldy #7
    ldx #$ff ; otimization - thanks @Irgendwer
CopyChar
    txa ; $ff
    sta char2,y
    lda (fontind),y
    eor #$ff
    sta char1,y
    dey
    bpl CopyChar
    ; and 8 subsequent bytes as a mask
    adw fontind #8
    ldy #7
CopyMask
    txa ; $ff
    eor (fontind),y
    sta mask1,y
    lda #$00
    sta mask2,y
    dey
    bpl CopyMask

.IF FASTER_GRAF_PROCS = 1
    ; mask preparation and character shifting
    lda xdraw
    and #$7
    tax
    beq MaskOK00
MakeMask00
    .rept 8
      lsr mask1+#
      ror mask2+#
    .endr
      sec
    .rept 8
      ror char1+#    ; in second (and next) lines we have C=1 - one SEC enough
      ror char2+#
    .endr
    dex
    bne MakeMask00
MaskOK00
    lda ydraw
    sec
    sbc #7
    sta ydraw
    ; X = 0 !
    lda Erase
    beq CharLoopi  ; it works, because x=0
    lda #$ff
    ldx #7
EmptyChar
    sta char1,x
    sta char2,x
    dex
    bpl EmptyChar
    ldx #0
CharLoopi
    ; calculating coordinates from xdraw and ydraw
    ldy ydraw
    lda xdraw
    and #%11111000
    clc
    adc linetableL,y
    sta xbyte
    lda linetableH,y
    adc xdraw+1
    sta xbyte+1
;--
    ldy #0
    lda (xbyte),y
    ora mask1,x
    and char1,x
    sta (xbyte),y
    ldy #8
    lda (xbyte),y
    ora mask2,x
    and char2,x
    sta (xbyte),y
    inc ydraw
    inx
    cpx #8
    bne CharLoopi
.ELSE
    mvx #7 temp    ; line counter (Y)
CharLoop1
    mva #7 temp+1    ; pixel counter (X)
CharLoop2
    mva #0 color
    rol mask1,x
    bcc NoMaskNoPlot
    rol char1,x
    bcs NoPlot
MakeCharPlot
    lda Erase
    bne ErasingChar
    inc color
ErasingChar
NoPlot
    jsr plot.MakePlot
AfterCharPlot
    inw xdraw
    ldx temp
    dec temp+1
    bpl CharLoop2
    sec
    sbw xdraw #8
    dec ydraw
    ldx temp
    dex
    stx temp
    bpl CharLoop1
    clc
    lda ydraw
    adc #8
    sta ydraw
    bne EndPutChar
NoMaskNoPlot
    rol char1,x
    jmp AfterCharPlot
.ENDIF
EndPutChar
    rts
.endp

;--------------------------------------------------
.proc PutChar4x4
; puts 4x4 pixels char on the graphics screen
; in: dx, dy (LOWER left corner of the char)
; in: CharCode4x4 (.sbyte)
; in: plot4x4color (0/255)
; all pixels are being drawn
; (empty and not empty)
;--------------------------------------------------
    cpw dy #(screenheight-1)
    jcs TypeChar.EndPutChar ;nearest RTS
    cpw dy #(4)
    jcc TypeChar.EndPutChar ;nearest RTS
    cpw dx #(screenwidth-4)
    jcs TypeChar.EndPutChar ;nearest RTS
    ; checks ommited.
    ; char to the table
Fast    ; Put char without coordinates check!
    lda CharCode4x4
    and #%00000001
    beq Upper4bits  ; A=0
    lda #$ff         ; better option to check (nibbler4x4 = $00 or $ff)
Upper4bits
    sta nibbler4x4
    lda CharCode4x4
    and #$3f ;always CAPITAL letters, also ignore inverse
    lsr
    sta fontind
    lda #$00
    sta fontind+1

    adw fontind #font4x4

    ; and 4 bytes to the table
    ldy #0
    ldx #3
CopyChar
    lda (fontind),y    ; Y must be 0 !!!!
    bit nibbler4x4
    bpl GetUpper4bits
    :4 rol
GetUpper4bits
    ora #$0f
    sta char1,x
    lda #$ff
    sta char2,x
    ; and 4  bytes as a mask
    lda #$f0
    sta mask1,x
    lda #$00
    sta mask2,x
    adw fontind #32        ; next byte of 4x4 font
    dex
    bpl CopyChar

.IF FASTER_GRAF_PROCS = 1
    ; mask preparation and character shifting
    lda dx
    and #$7
    tax
    beq MaskOK01
MakeMask01
    .rept 4
      lsr mask1+#
      ror mask2+#
    .endr
      sec
    .rept 4
      ror char1+#    ; in second (and next) lines we have C=1 - one SEC enough
      ror char2+#
    .endr
    dex
    bne MakeMask01
MaskOK01
    lda dy
    sec
    sbc #3
    sta dy
    ldx #0
CharLoopi4x4
    ; calculating coordinates from xdraw and ydraw
    ldy dy
    lda dx
    and #%11111000
    clc
    adc linetableL,y
    sta xbyte
    lda linetableH,y
    adc dx+1
    sta xbyte+1
;--
    ldy #0
    lda (xbyte),y
    ora mask1,x
    bit plot4x4color
    bpl PutInColor0_1    ; only mask - no char
    and char1,x
PutInColor0_1
    sta (xbyte),y
    ldy #8
    lda (xbyte),y
    ora mask2,x
     bit plot4x4color
    bpl PutInColor0_2    ; only mask - no char
    and char2,x
PutInColor0_2
    sta (xbyte),y
    inc dy
    inx
    cpx #4
    bne CharLoopi4x4
.ELSE
    mwa xdraw char2
    mwa ydraw mask2
    mva color mask2+2
    mwa dx xdraw
    mwa dy ydraw
    mvx #3 temp    ; line counter (Y)
CharLoop1
    mva #3 temp+1    ; pixel counter (X)
CharLoop2
    mva #0 color
    rol mask1,x
    bcc NoMaskNoPlot
    rol char1,x
    bcs NoPlot
MakeCharPlot
    lda plot4x4color
    beq ErasingChar
    inc color
ErasingChar
NoPlot
    jsr plot.MakePlot
AfterCharPlot
    inw xdraw
    ldx temp
    dec temp+1
    bpl CharLoop2
    sec
    sbw xdraw #4
    dec ydraw
    ldx temp
    dex
    stx temp
    bpl CharLoop1
    mwa char2 xdraw
    mwa mask2 ydraw
    mva mask2+2 color
    bpl EndPut4x4
NoMaskNoPlot
    rol char1,x
    jmp AfterCharPlot
.ENDIF
EndPut4x4
    rts
.endp

;--------------------------------------------------
.proc ClearScreen
;--------------------------------------------------
    ldy #<displayC64
    lda #0
    sta temp
    lda #>displayC64
    sta temp+1
Go  lda #$ff
loop  sta (temp),y
      iny
      bne @+
      inc temp+1
@     cpy #<(displayC64+screenheight*screenBytes+1)
      bne loop
      ldx temp+1
      cpx #>(displayC64+screenheight*screenBytes+1)
      bne loop
   rts
.endp

;--------------------------------------------------
.proc GenerateLineTable

    mwa #displayC64 temp
    mwa #linetableL temp2
    mwa #linetableH modify
    ldy #0
    ldx #0
@     lda temp
      sta (temp2),y
      lda temp+1
      sta (modify),y
      cpx #7
      bne NotChar
      ldx #0
      adw temp #(320-7)
      jmp next8lines
NotChar
      inw temp
      inx
next8lines
      iny
      cpy #screenheight+1
    bne @-
    ; and bittables for fastest plot and point (thanks @jhusak)
    ldy #0
    lda #$40
@   asl
    adc #0
    sta bittable1_long,y
    tax
    eor #%11111111
    sta bittable2_long,y
    txa
    dey
    bne @-
    rts
.endp
;--------------------------------------------------
.proc SetMainScreen
    lda #$b          ; Grey background and border
    lda WallsType
    :4 rol
    sta $d020
    sta $d021

    lda $dd00       ; Set video bank to start at 0
    and #252
    ora #3
    sta $dd00
    lda #$18
    sta $d018

;    SwitchVICBank(0)
;    SetScreenMemory($2000)
    SetHiresBitmapMode    ; Hires mode on
    lda #$00
    sta 53281
    ; clear color RAM
    ldx #0
@    lda #1
    sta $d800,x
    sta $d900,x
    sta $da00,x
    sta $db00,x
    lda #$0f
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    inx
    bne @-
    rts
.endp
;--------------------------------------------------


; ******* This is weapon .... but ... *******
; -------------------------------------------------
.proc AtomicWinter
; -------------------------------------------------
; This routine is run from inside of the main loop
; and replaces Shoot and Flight routines
; X and TankNr - index of shooting tank
; -------------------------------------------------
    mva #sfx_sandhog sfx_effect
.IF FASTER_GRAF_PROCS = 1
    mvy #0 magic              ; byte counter (from 0 to 39)
NextColumn
    ; big loop - we repat internal loops for each column of bytes
    ldx #120            ; line counter (from 0 to 60 )
    ; first loop - inverse column of bytes for a while
NextLine1
    jsr InverseScreenByte
    dex
    dex
    bpl NextLine1
    ;
    jsr WaitOneFrame    ; wait uses A only
    ; second loop - inverse again and put random "snow" to column of bytes
    ldx #120
    mva #$55 magic+1
NextLine2
    jsr InverseScreenByte
    lda random
    ora magic+1
    and (temp),y
    sta (temp),y
    lda magic+1
    eor #$ff
    sta magic+1
    dex
    dex
    bpl NextLine2
    ; and go to next column
    inc magic
    ldy magic
    cpy #40
    bne NextColumn
.ELSE
    mva #1 color
    mwa #120 ydraw
NextLineSlow
    lda #0
    sta xdraw
    sta xdraw+1
NextPixelSlow
    bit random
    bpl NoPlot
    bvc NoPlot
    jsr plot.MakePlot
NoPlot
    inw xdraw
    cpw xdraw #screenwidth
    bne NextPixelSlow
    dec ydraw
    dec ydraw
    bpl NextLineSlow
.ENDIF
    ; and we have "snow" :)
    lda #0
    ldx TankNr
    sta ActiveDefenceWeapon,x    ; deactivate Nuclear Winter
    jsr SetFullScreenSoilRange
    jmp SoilDown.NoClearTanks
    ; rts

    ; in order to optimize the fragment repeated in both internal loops
    ; we save 15 bytes :)
InverseScreenByte
    ldy magic
    sty temp
    ldy #0
    sty temp+1
    aslw temp
    rolw temp
    rolw temp
    lda temp
    adc LineTableL,x
    sta temp
    lda LineTableH,x
    adc temp+1
    sta temp+1
    lda (temp),y
    eor #$ff
    sta (temp),y
    rts
.endp

.ENDIF