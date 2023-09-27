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

    ldy oldply,x
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
    ;tya
    sta oldply,x

    ldx ydraw
    lda linetableL,x
    sta xbyte
    sta oldplot
    lda linetableH,x
    sta xbyte+1
    sta oldplot+1

;    lda xdraw
;    and #$7
;    tax
    ldx xdraw   ; optimization (256 bytes long bittable)
    
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

;    lda xdraw
;    and #$7
;    tax
    ldx xdraw   ; optimization (256 bytes long bittable)
    
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

.IF METEORS = 1
; -----------------------------------------
.proc ExPlot  ;ExPlot (EplotX, EplotY)
; EOR plot:
; Inverts color of a pixel
; Note: No coordinate control!!!
;       With off-screen coordinates, it can damage main program.
; only for ingame meteors
; -----------------------------------------
    ; let's calculate coordinates from xdraw and ydraw
    ;xbyte = xbyte/8
    lda EplotX+1
    lsr
    lda EplotX
    ror ;just one bit over 256. Max screenwidth = 512!!!
    lsr
    lsr
    sta EplotByte
    ;---
    ldx EplotY
    ldy linetableL,x
    lda linetableH,x
    sta EplotByte+1

    ldx EplotX   ; optimization (256 bytes long bittable)

    lda (EplotByte),y
    eor bittable1_long,x
    sta (EplotByte),y
    rts
.endp
.ENDIF
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

;    lda xdraw
;    and #$7
;    tax
    ldx xdraw   ; optimization (256 bytes long bittable)

    lda (xbyte),y
    eor #$ff
    and bittable1_long,x
    rts
.endp
;--------------------------------------------------
.proc drawmountains
;--------------------------------------------------
    mwa #0 xdraw
    mwa #mountaintable modify   ; mountaintable pointer
    mva #1 color

drawmountainsloop
    jsr DrawMountainLine    ; draws column of mountains (one pixel wide)
    inw modify
    inw xdraw   ; naxt column
    cpw xdraw #screenwidth
    bne drawmountainsloop
    rts
DrawMountainLine
.IF FASTER_GRAF_PROCS = 1
    ; calculate lower point in one screen byte
    lda xdraw
    and #%00000111	; only every 8th pixel
    bne MinCalculated
    ldy #7
@   cmp (modify),y
    bcs NotLower
    lda (modify),y
NotLower
    dey
    bpl @-
    sta temp2
    inc temp2	; this is our minimum (in one byte wide - 8 columns)
    bit ClearSky
    bpl NoClearSky
    ; Clear Sky
    mwa #0 ydraw
    jsr plot.MakePlot  ; after plot we have: (xbyte),y - addres of screen byte  
@   lda #$ff
    sta (xbyte),y
    adw xbyte #screenBytes  ; next line
    inc ydraw
    lda ydraw
    cmp #screenheight
    beq NoClearSky
    cmp temp2   ; our minimum height od sky 
    bne @-   
NoClearSky
MinCalculated
    ldy #0
    lda (modify),y
    cmp #screenheight
    beq NoMountain
    sta ydraw
    sty ydraw+1
;    there was Drawline proc
    jsr plot.MakePlot
    ; after plot we have: (xbyte),y - addres of screen byte; X - index in bittable (number of bit)
;    jmp IntoDraw    ; jumps inside Draw routine
                    ; because one pixel is already plotted (and who cares? :) )
@
    lda (xbyte),y
    and bittable2_long,x
    sta (xbyte),y
;IntoDraw
    adw xbyte #screenBytes
    inc ydraw
    lda ydraw
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
    sta (xbyte),y
    adw xbyte #screenBytes
    inc ydraw
    lda ydraw
    cmp #screenheight
    bne @-   
NotFillBytes
.ELSE
    bit ClearSky
    bpl NoClearSky
    ; Clear Sky
    ldy #0
    lda (modify),y
    sta ydraw
    sty ydraw+1
    sty color
clearline
    jsr plot.MakePlot
    dec ydraw
    lda ydraw
    cmp #$ff
    bne clearline
    mva #1 color
NoClearSky
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
.proc CalcAndDrawMountains
;--------------------------------------------------
; Calculate mountaintable from screen data
; for speedup SoilDown, etc.
    mva #$ff ClearSky
; Range alignment to full bytes.
    lda RangeLeft
    and #%11111000
    sta RangeLeft
    adw RangeRight #7
    lda RangeRight
    and #%11111000
    sta RangeRight
    cpw RangeLeft RangeRight
    jcs NothingToFall
    ; convert range to bytes
    lda RangeLeft
    sta temp
    sta xdraw
    lda RangeLeft+1
    sta xdraw+1
    lsr @        ; temp / 8
    ror temp
    lsr temp     ; max range is 511 ! (9 bits)
    lsr temp     ; temp+1 = 0
    
    ; mwa #0 temp+1 ; byte in screen line
    adw RangeLeft #mountaintable modify
HorizontalByteLoop
    lda #0
    ldy #7
@   sta (modify),y
    dey
    bpl @-
    tax
    ;stx ydraw
ColumnLoop
    lda LineTableL,x    ; X=ydraw
    sta xbyte   ; address of first byte in line X
    lda LineTableH,x
    sta xbyte+1
    ldy temp
    lda (xbyte),y
    sta temp2   ; byte from screen (8 pixels)
    ldy #7
ByteLoop
    lsr temp2
    bcc NoPixel
    ;clc
    ; C = 0
    lda #0  ; becouse C=1
    adc (modify),y
    sta (modify),y
NoPixel
    dey
    bpl ByteLoop    ; next bit in byte

    inx     ;  ydraw
    ;inc ydraw
    ;ldy ydraw
    cpx #screenheight
    bne ColumnLoop  ; next byte in colum
    ; redrawing a column (byte) of mountains uses the drawmountains fragment
    mva #7 temp+1   ; draw 8 mountain columns
@   jsr drawmountains.DrawMountainLine
    mva #sfx_silencer sfx_effect
    inw modify
    inw xdraw
    dec temp+1
    bpl @-
    inc temp
    cpw xdraw RangeRight
    bne HorizontalByteLoop  ; next column of bytes
NothingToFall
    mva #$00 ClearSky
    rts
.endp
;--------------------------------------------------
.proc SoilDownTurbo
;--------------------------------------------------
; fast SoilDown froc - test
    jsr ClearTanks
NoClearTanks
    jsr CalcAndDrawMountains
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
CopyChar
    lda (fontind),y
    eor #$ff
    sta char1,y
    lda #$ff
    sta char2,y
    dey
    bpl CopyChar
    ; and 8 subsequent bytes as a mask
    adw fontind #8
    ldy #7
CopyMask
    lda (fontind),y
    eor #$ff
    sta mask1,y
    lda #$00
    sta mask2,y
    dey
    bpl CopyMask

.IF FASTER_GRAF_PROCS = 1
    ; calculating coordinates from xdraw and ydraw
    mwa xdraw xbyte

    lda xbyte
    and #$7
    sta ybit

    lsrw xbyte ; div 8
    rorw xbyte
    rorw xbyte
;---
    ldy xbyte

    lda ydraw ; y = y - 7 because left lower. shouldn't it be 8?
    sec
    sbc #7
    tax

    lda linetableL,x
    sta xbyte
    lda linetableH,x
    sta xbyte+1
    ; mask preparation and character shifting
    ldx ybit
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
    ; here x=0
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
    lda (xbyte),y
    ora mask1,x
    and char1,x
    sta (xbyte),y
    iny
    lda (xbyte),y
    ora mask2,x
    and char2,x
    sta (xbyte),y
    dey
    adw xbyte #screenBytes
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
    ; calculating coordinates from xdraw and ydraw
    mwa dx xbyte

    lda xbyte
    and #$7
    sta ybit

    :3 lsrw xbyte ; div 8
;    rorw xbyte
;    rorw xbyte
;---
    ldy xbyte    ; horizontal byte offet stored in Y
    lda dy ; y = y - 3 because left lower.
    sec
    sbc #3
    tax

    lda linetableL,x
    sta xbyte
    lda linetableH,x
    sta xbyte+1
    ; mask preparation and character shifting
    ldx ybit
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
    ldx #0
CharLoopi4x4
    lda (xbyte),y
    ora mask1,x
    bit plot4x4color
    bpl PutInColor0_1    ; only mask - no char
    and char1,x
PutInColor0_1
    sta (xbyte),y
    iny
    lda (xbyte),y
    ora mask2,x
     bit plot4x4color
    bpl PutInColor0_2    ; only mask - no char
    and char2,x
PutInColor0_2
    sta (xbyte),y
    dey
    adw xbyte #screenBytes
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
    ldy #<display
    lda #0
    sta temp
    lda #>display
    sta temp+1
Go  lda #$ff
loop  sta (temp),y
      iny
      bne @+
      inc temp+1
@     cpy #<(display+screenheight*screenBytes+1)
      bne loop
      ldx temp+1
      cpx #>(display+screenheight*screenBytes+1)
      bne loop
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
;    mva #0 dmactls
    SetDLI DLIinterruptGraph  ; jsr SetDLI for graphics (game) screen
    mwa #dl dlptrs  ; issue #72 (glitches when switches)
    lda #%00111110
;    and #$fc
;    ora #$02     ; 2=normal, 3 = wide screen width
    sta dmactls
    mva WallsType COLBAKS    ; set color of background
    jmp WaitOneFrame
    ; rts
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
    ldy #0              ; byte counter (from 0 to 39)
NextColumn
    ; big loop - we repat internal loops for each column of bytes
    sty magic
    ldx #120            ; line counter (from 0 to 60 )
    ; first loop - inverse column of bytes for a while
    ldy magic
NextLine1
    jsr InverseScreenByte
    dex
    dex
    bpl NextLine1
    ;
    jsr WaitOneFrame    ; wait uses A only
    ; second loop - inverse again and put random "snow" to column of bytes
    ldx #120
    ldy magic
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
    iny
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
    lda LineTableL,x
    sta temp
    lda LineTableH,x
    sta temp+1
    lda (temp),y
    eor #$ff
    sta (temp),y
    rts
.endp

.ENDIF