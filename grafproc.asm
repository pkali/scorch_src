;	@com.wudsn.ide.asm.mainsourcefile=scorch.asm

    .IF *>0 ;this is a trick that prevents compiling this file alone


;--------------------------------------------------
.proc draw ;;fuxxing good draw :) 
;--------------------------------------------------
;creditz to Dr Jankowski / MIM U.W.
; (xi,yi)-----(xk,yk)
;20 DX=XK-XI
;30 DY=YK-YI
;40 DP=2*DY
;50 DD=2*(DY-DX)
;60 DI=2*DY-DX
;70 REPEAT
;80   IF DI>=0
;90     DI=DI+DD
;100     YI=YI+1
;110   ELSE
;120     DI=DI+DP
;130   ENDIF
;140   plot XI,YI
;150   XI=XI+1
;160 UNTIL XI=XK


    ; begin: xdraw,ydraw - end: xbyte,ybyte
    ; let's store starting coordinates
    ; will be needed, because everything is calculated relatively
    mwa #0 LineLength
    mwa xdraw xtempDRAW
    mwa ydraw ytempDRAW

    ; if line goes our of the screen we are not drawing it, but...

    cpw xdraw #screenwidth
    bcs DrawOutOfTheScreen
    cpw xbyte #screenwidth
    bcs DrawOutOfTheScreen
    ;cpw ydraw #screenheight
    ;bcs DrawOutOfTheScreen
    ;cpw ybyte #screenheight
    ;bcc DrawOnTheScreen
    lda ydraw+1
    bmi DrawOutOfTheScreen
    lda ybyte+1
    bpl DrawOnTheScreen
DrawOutOfTheScreen
    ;jsr DrawJumpPad
    rts
DrawOnTheScreen
    ; constant parameters
    ; XI=0 ,YI=0
    lda #0
    sta XI
    sta XI+1
    sta YI
    sta YI+1

    ; setting the direction controll bits
    cpw ydraw ybyte
    bcc LineDown
    ; here one line up
    ; we are setting bit 0
    mva #1 HowToDraw  ;here we can because it's first operation
    ; we are subctracting Yend from Ybegin (reverse order)
    ; DY=YI-YK
    sbw ydraw ybyte DY
    jmp CheckDirectionX
LineDown
    ; one line down here
    ; we are setting bit 0
    mva #0 HowToDraw  ;here we can because it's first operation
    ; substract Ybegin from Yend (normal order)
    ; DY=YK-YI
    sbw ybyte ydraw DY
CheckDirectionX
    cpw xdraw xbyte
    bcc LineRight
    ; here goes line to the left
    ; we set bit 1

    lda HowToDraw
    ora #$02
    sta HowToDraw
    ; substract Xend from Xbegin (reverse)
    ; DX=XI-XK
    sbw xdraw xbyte DX
    jmp CheckDirectionFactor
LineRight
    ; here goes one line to the right
    ; we clear bit 0
    ; we can do nothing because the bit is cleared!

    ;lda HowToDraw
    ;and #$FD
    ;sta HowToDraw

    ; substracting Xbegin from Xend (normal way)
    ; DX=XK-XI
    sbw xbyte xdraw DX
CheckDirectionFactor
    ; here we check Direction Factor
    ; I do not know if we are using proper English word
    ; but the meaning is 'a' in y=ax+b

    ; lda DX
    ; we already have DX in A
    cpw DX DY

    bcc SwapXY
    ; 'a' factor is fire, so we copy parameters
    ; XK=DX
    mwa DX XK
    ; and clearing bit 2
    ; and bit 2 clear
    ; (is not needed because already cleared)
    ;lda HowToDraw
    ;and #$FB
    ;sta HowToDraw
    jmp LineParametersReady
SwapXY
    ; not this half of a quarter! - parameters must be swapped
    ; XK=DY
    ; DY=DX
    ; DX=XK  - because DY is there so DY and DX are swapped
    ; YK ... not used
    mwa DY XK
    mwa DX DY
    mwa XK DX

    ; and let's set bit 2
    lda HowToDraw
    ora #$04
    sta HowToDraw
LineParametersReady
    ; let's check if length is not zero
    lda DX
    ora DX+1
    ora DY
    ora DY+1
    jeq EndOfDraw

    ; here we have DX,DY,XK and we know which operations
    ; are to be performed with these factors when doing PLOT
    ; (accordingly to given bits of 'HowToDraw')
    ; Now we must calculate DP, DD and DI
    ; DP=2*DY
    ; DD=2*(DY-DX)
    ; DI=2*DY-DX

    mwa DY DP
    aslw DP

    sbw DY DX DD
    aslw DD

    mwa DY DI
    aslw DI
    sbw DI DX

DrawLoop
    ; REPEAT
    ;   IF DI>=0
    lda DI+1
    bmi DINegative
    ;     DI=DI+DD
    ;     YI=YI+1
    adw DI DD
    inw YI
    jmp drplot
DINegative
    ;   ELSE
    ;     DI=DI+DP
    adw DI DP

drplot ; Our plot that checks how to calculate pixels.
    ; In xtempDRAW and ycircle there are begin coordinates
    ; of our line
    ; First we check the 'a' factor (like in y=ax+b)
    ; If necessary we swap XI and YI
    ; (as we can not change XI and YI we move XI to temp2
    ;  and YI to temp)


    lda HowToDraw
    and #$04
    bne SwappedXY
    mwa XI temp
    mwa YI temp2
    jmp CheckPlotY
SwappedXY
    mwa XI temp2
    mwa YI temp
CheckPlotY
    lda HowToDraw
    and #01
    bne LineGoesUp
    ; here we know that line goes down and we are not changing Y
    adw temp2 ytempDRAW ydraw ; YI
    jmp CheckPlotX
LineGoesUp
    ; line goes up here - we are reversing Y
    sbw ytempDRAW temp2 ydraw ; YI
CheckPlotX
    lda HowToDraw
    and #02
    bne LineGoesLeft
    ; here we know that line goes right and we are not changing X
    adw temp xtempDRAW xdraw ; XI
    jmp PutPixelinDraw
LineGoesLeft
    ; line goes left - we are reversing X
    sbw xtempDRAW temp xdraw ; XI
PutPixelinDraw
    
    ; 0 - plot, %10000000 - LineLength (N), %01000000 - DrawCheck (V)
    bit drawFunction
    bpl @+
    inw LineLength
    bne ContinueDraw  ; ==jmp
@
    bvc @+
DrawCheck
    lda tracerflag
    ora SmokeTracerFlag
yestrace
    beq notrace
    jsr plot
notrace
;aftertrace
	;key
    lda HitFlag
    bne StopHitChecking

CheckCollisionDraw
    ; checking collision!
    lda ydraw+1
    bmi StopHitChecking

    jsr CheckCollisionWithTank
    lda HitFlag
    bne StopHitChecking

	clc
	lda xdraw
	adc #<mountaintable
	sta temp
	lda xdraw+1
	adc #>mountaintable
	sta temp+1

    ldy #0
    lda ydraw
    cmp (temp),y
    bcc StopHitChecking

    mwa xdraw XHit
	lda (temp),y
	sec
	sbc #1
	sta YHit
	sty YHit+1
    mva #$ff HitFlag
StopHitChecking
    jmp ContinueDraw
@
    jsr plot   

ContinueDraw
    ; XI=XI+1
    ; UNTIL XI=XK
    inw XI
    cpw XI XK
    jne DrawLoop

EndOfDraw
    mwa xtempDRAW xdraw
    mwa ytempDRAW ydraw
    rts
.endp

;--------------------------------------------------
.proc circle ;fxxxing good circle drawing :) 
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

    mwa #0 xc
    mva radius yc
    mva #0 fx
    mva radius fy
    asl FY
    asl FY
    mva FY FS
    asl FY
    clc
    lda FS
    adc #3
    sta FS

circleloop
    lda FX
    cmp FY
    bcs endcircleloop
    jsr splot8
    inc XC

    clc
    lda FX
    adc #8
    sta FX

    lda FS
    beq else01
    bmi else01
    sec
    sbc FX
    sbc #4
    sta FS
    jmp endif01
else01
    dec YC
    sec
    lda FY
    sbc #8
    sta FY

    lda FS
    sec
    sbc FX
    sbc #4
    clc
    adc FY
    sta FS
endif01
    jmp circleloop
endcircleloop

    jsr splot8

    mwa xcircle xdraw
    mwa ycircle ydraw
    rts
.endp
;----
splot8 .proc
; plot xcircle+XC,ycircle+YC
; plot xcircle+XC,ycircle-YC
; plot xcircle-XC,ycircle-YC
; plot xcircle-XC,ycircle+YC

; plot xcircle+YC,ycircle+XC
; plot xcircle+YC,ycircle-XC
; plot xcircle-YC,ycircle-XC
; plot xcircle-YC,ycircle+XC

    clc
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
    sta tempcir
	lda ycircle+1
	adc #$00
	sta ydraw+1
	sta tempcir+1
    jsr plot

    sec
    lda ycircle
    sbc YC
    sta ydraw
	lda ycircle+1
	sbc #$00
	sta ydraw+1
    jsr plot

    sec
    lda xcircle
    sbc XC
    sta xdraw
    lda xcircle+1
    sbc #0
    sta xdraw+1
    jsr plot

    lda tempcir
    sta ydraw
	lda tempcir+1
	sta ydraw+1
    jsr plot
;---
    clc
    lda xcircle
    adc yC
    sta xdraw
    lda xcircle+1
    adc #0
    sta xdraw+1
    ;clc
    lda ycircle
    adc xC
    sta ydraw
    sta tempcir
	lda ycircle+1
	adc #$00
	sta ydraw+1
	sta tempcir+1
    jsr plot

    sec
    lda ycircle
    sbc xC
    sta ydraw
	lda ycircle+1
	sbc #$00
	sta ydraw+1
    jsr plot

    sec
    lda xcircle
    sbc yC
    sta xdraw
    lda xcircle+1
    sbc #0
    sta xdraw+1
    jsr plot

    lda tempcir
    sta ydraw
	lda tempcir+1
	sta ydraw+1
    jsr plot

    RTS
.endp

;--------------------------------------------------
clearscreen .proc
;--------------------------------------------------

    lda #$ff
    ldx #0
@
    :31 sta display+($100*#),x
    sta display+$1e50,x  ; this is so no space outside of the screen is cleared
                         ; of course we are clearing $100 instead of $50, but who cares :]
    inx
    bne @-
    rts
.endp
;-------------------------------*------------------
placetanks .proc
;--------------------------------------------------
    ldx #(MaxPlayers-1)   ;maxNumberOfPlayers-1
    lda #0
@
      ; clearing the tables with coordinates of the tank
      ; it is necessary, because randomizing checks
      ; if the given tank is already placed
      ; after check if its position is not (0,0)
  
      ; I will be honest with you - I have no idea
      ; what the above comment was intending to mean :)
  
      sta XtankstableL,x
      sta XtankstableH,x
      sta Ytankstable,x
      dex
    bpl @-


    mwa #0 temptankX
    mva #0 temptankNr ;player number
StillRandomize
    ldx NumberOfPlayers
    lda random
    and #$07
    tay
    cpy NumberOfPlayers
    bcs StillRandomize
    lda xtankstableL,y
    bne StillRandomize
    lda xtankstableH,y
    bne StillRandomize
    ; here we know that we got a random number
    ; of the tank that is not in use
    ; this number is in Y

    clc
    lda temptankX
    adc disktance,x
    sta temptankX
    sta xtankstableL,y
    bcc NotHigherByte03
    inc temptankX+1
NotHigherByte03
    lda temptankX+1
    sta xtankstableH,y
    INC temptankNr
    ldx temptankNr
    Cpx NumberOfPlayers
    bne StillRandomize

; getting random displacements relative to even positions
    ldx #$00
StillRandomize02
    lda random
    and #$1f ; maximal displacement is 31 pixels

    clc
    adc xtankstableL,x
    sta xtankstableL,x
    bcc NotHigherByte02
    inc xtankstableH,x
NotHigherByte02
; and we deduct 15 to make the displacement work two ways
    sec
    lda xtankstableL,x
    sbc #$0f
    sta xtankstableL,x
    bcs NotHigherByte01
    dec xtankstableH,x
NotHigherByte01

; and clear lowest bit to be sure that the X coordinate is even
; (this is to have P/M background look nice)
    lda xtankstableL,x
    and #$fe
    sta xtankstableL,x
    inx
    Cpx NumberOfPlayers
    bne StillRandomize02
    rts

; during calculating heights of thw mountains
; check if the tank is not somewhere around
; if so, make horizontal line 8 pixels long
CheckTank
    ldx NumberOfPlayers
    dex
CheckNextTank
    lda xtankstableL,x
    cmp xdraw
    bne UnequalTanks
    lda xtankstableH,x
    cmp xdraw+1
    bne UnequalTanks
    lda ydraw
    ;sec
    ;sbc #$01 ; minus 1, because it was 1 pixel too high
    sta ytankstable,x     ; what's the heck is that????!!!!
    mva #7 deltaX
    mwa #0 delta
UnequalTanks
    dex
    bpl CheckNextTank
    rts
.endp

;-------------------------------------------------
.proc drawtanks
;-------------------------------------------------
    lda tanknr
    pha
    ldx #$00
    stx tanknr

DrawNextTank
    jsr drawtanknr
    inc tanknr
    ldx tanknr
    Cpx NumberOfPlayers
    bne DrawNextTank

    pla
    sta tankNr

    rts
.endp
;---------
.proc DrawTankNr
    ldx tankNr
    ; let's check the energy
    lda eXistenZ,x
    bne SkipRemovigPM ; if energy=0 then no tank

      ; hide P/M
      lda #0
      sta hposp0,x
      jmp DoNotDrawTankNr
SkipRemovigPM


    lda AngleTable,x
    bmi AngleToLeft01
    lda #90
    sec
    sbc AngleTable,x
    tay
    lda BarrelTableR,y
    jmp CharacterAlreadyKnown
AngleToLeft01
    sec
    sbc #(255-90)
    tay
    lda BarrelTableL,y
CharacterAlreadyKnown
    sta CharCode
DrawTankNrX
    ldx tanknr
    lda xtankstableL,x
    sta xdraw
    lda xtankstableH,x
    sta xdraw+1
    lda ytankstable,x
    sta ydraw
	mva #0 ydraw+1

    jsr TypeChar

    ; now P/M graphics on the screen (only for 5 tanks)
    ; horizontal position
    mwa xdraw xbyte
    ldx tanknr
    cpx #$5
    bcs NoPlayerMissile
    rorw xbyte ; divide by 2 (carry does not matter)
    lda xbyte
    clc
    adc #$24 ; P/M to graphics offset
    cpx #$4 ; 5th tank are joined missiles and offset is defferent
    bne NoMissile
    clc
    adc #$0C
NoMissile
    sta hposp0,x
    ; vertical position
    lda pmtableL,x
    sta xbyte
    lda pmtableH,x
    sta xbyte+1

    ; calculate start position of the tank
    lda ydraw
    clc
    adc #PMOffset
    sta temp
    ; clear sprite and put 3 lines on the tank at the same time
    ldy #$00
    tya
ClearPM     
    cpy temp
    bne ZeroesToGo
    lda #$03 ; (2 bits set) we set on two pixels in three lines
    sta (xbyte),y
    dey
    sta (xbyte),y
    dey
    sta (xbyte),y
    dey
    lda #$00
ZeroesToGo
    sta (xbyte),y
    dey
    bne ClearPM
NoPlayerMissile
	; draw defensive weapons like shield ( tank number in X )
	; in xdraw, ydraw we have coordinates left LOWER corner of Tank char
	lda ActiveDefenceWeapon,x
	cmp #57		; one shot shield activation
	beq ShieldDraw
	cmp #58		; shield with energy and parachute activation
	beq ShieldDraw
	cmp #59		; shield with energy activation
	beq ShieldDraw
	cmp #61		; Auto Defence
	beq DrawTankShieldWihHorns
	cmp #56		; Mag Deflector
	beq DrawTankShieldWihHorns	
	bne NoShieldDraw
ShieldDraw
	jsr DrawTankShield.DrawInPosition
NoShieldDraw
DoNotDrawTankNr
    rts
DrawTankShieldWihHorns
	jsr DrawTankShield.DrawInPosition
	jsr DrawTankShieldHorns
	rts
.endp

; -------------------------------------
.proc FlashTank
; -------------------------------------
; number of blinking tank in TankNr
	mva #18 fs  ; temp, how many times flash the tank
tankflash_loop
    lda CONSOL  ; turbo mode
    cmp #6  ; START
    sne:mva #1 fs  ; finish it     
    mva #1 Erase
	ldx TankNr
    jsr DrawTankNr.SkipRemovigPM	; it's necessary becouse DrawTankNr skips tanks with no energy !
	PAUSE 2
    mva #0 Erase
	ldx TankNr
    jsr DrawTankNr.SkipRemovigPM
	PAUSE 2
    dec fs
    jne tankflash_loop
	rts
.endp

;--------------------------------------------------
.proc DrawTankShield
; X - tank number
; if use DrawInPosition entry point then:
; xdraw, ydraw - coordinates left LOWER corner of Tank char
; values remain there after a DrawTankNr proc.
; 
; this proc change xdraw, ydraw  and temp!
;--------------------------------------------------
    lda xtankstableL,x
    sta xdraw
    lda xtankstableH,x
    sta xdraw+1
    lda ytankstable,x
    sta ydraw
	mva #0 ydraw+1
DrawInPosition
	mva #1 color
	lda erase
	beq ShieldVisible
	dec color
ShieldVisible
	sbw xdraw #$03		; 3 pixels to left
	; draw left vertical line of shield ( | )
	mva #6 temp			; strange !!!
@
	jsr plot
.nowarn	dew ydraw
	dec temp
	bne @-
	; draw left oblique line of shield ( / )
	mva #4 temp
@
	jsr plot
.nowarn	dew ydraw
	inw xdraw
	dec temp
	bne @-
	; draw top horizontal line of shield ( _ )
	mva #5 temp
@
	jsr plot
	inw xdraw
	dec temp
	bne @-
	; draw right oblique line of shield ( \ )
	mva #4 temp
@
	jsr plot
	inw ydraw
	inw xdraw
	dec temp
	bne @-
	; draw right vertical line of shield ( | )
	mva #7 temp
@
	jsr plot
	inw ydraw
	dec temp
	bne @-
	rts
.endp
;--------------------------------------------------
.proc DrawTankShieldHorns
; use only directly after DrawTankShield
; this proc draws a little "horns" on shield.
; Symbol of defensive but aggressive :) weapon
;--------------------------------------------------
.nowarn	dew xdraw			; 1 pixel left
	sbw ydraw #$0a		; 10 pixels up
	jsr plot
.nowarn	dew ydraw
	inw xdraw
	jsr plot
	sbw xdraw #$0d		; 13 pixels left
	jsr plot
	inw xdraw
	inw ydraw
	jsr plot
	rts
.endp

;--------------------------------------------------
.proc drawmountains 
;--------------------------------------------------
    mwa #0 xdraw
    mwa #mountaintable modify
	mva #1 color

drawmountainsloop
    ldy #0
    lda (modify),y
	cmp #screenheight
	beq NoMountain
    sta ydraw
	sty ydraw+1
    jsr DrawLine
NoMountain
    inw modify
    inw xdraw
    cpw xdraw #screenwidth
    bne drawmountainsloop
    rts
;--------------------------------------------------
drawmountainspixel
;--------------------------------------------------
    mwa #0 xdraw
    mwa #mountaintable modify


drawmountainspixelloop
    ldy #0
    lda (modify),y
    sta ydraw
	sty ydraw+1
    jsr plot
    inw modify
    inw xdraw
    cpw xdraw #screenwidth
    bne drawmountainspixelloop

    rts
.endp
;--------------------------------------------------
.proc SoilDown2
;--------------------------------------------------

; how it is supposed to work:
; first loop is looking for the highest pixels
; and fills with their Y coordinates both temporary tables
;
; second (main) loop works this way:
; sets end-of-soil-fall-down-flag to 1 ( IsEndOfTheFallFlag=1 )
;  goes through the horizontal line checking if
;  Y coordinate from the first table equals to height of the peak
;    if so, it goes further
;  if not:
;    sets end-of-soil-fall-down-flag to 0
;    increases Y from the first table
;       if there is no pixel there it plots here and
; zeroes pixel from the second table and after that
;              increases Y of the second table
;       repeats with next pixels au to the end of the line
;  if the flag is 0 then repeat the main loop
; and that's it :)
;
; I am sorry but after these 4 years I have no idea
; how it works. I have just translated Polish comment
; but I do not understand a word of it :)
; If you know how it works, please write here :))))

    jsr PMoutofscreen

; First we look for highest pixels and fill with their coordinates
; both tables

    mwa RangeLeft xdraw
    adw RangeLeft #mountaintable temp
    adw RangeLeft #mountaintable2 tempor2

NextColumn1
    mwa #0 ydraw
NextPoint1
    jsr point
    beq StillNothing
    ldy #0
    lda ydraw
    sta (tempor2),y
    sta (temp),y
    jmp FoundPeek1
StillNothing
    inc ydraw
    lda ydraw
    cmp #screenheight
	bne NextPoint1
	; no pixels on whole column !!!
	ldy #0
    lda ydraw
    sta (tempor2),y
    sta (temp),y
    jmp FoundPeek1
FoundPeek1
    inw tempor2
    inw temp
    inw xdraw
    ;vcmp xdraw,screenwidth,NextColumn1
    cpw xdraw RangeRight
    bcc NextColumn1
    beq NextColumn1
; we have both tables filled with starting values

; main loop starts here
MainFallout2
    mwa RangeLeft xdraw
    adw RangeLeft #mountaintable temp
    adw RangeLeft #mountaintable2 tempor2

    mva #1 IsEndOfTheFallFlag
FalloutOfLine
    ldy #0

    ; is Y coordinate from the first table
    ; equal to peak height, if so, go ahead
    lda (tempor2),y
    cmp #screenheight-1 ;cmp (temp),y
    bcs ColumnIsReady
    ; in the other case there are things to be done
    sty IsEndOfTheFallFlag   ; flag to 0
    ; we are increasing Y in the first table
    ;lda (tempor2),y
    clc
    adc #1
    sta (tempor2),y
    ; and checking if there is a pixel there
    sta ydraw
    jsr point
    bne ThereIsPixelHere
    ; if no pixel we plot it
    mva #1 color
    jsr plot.MakePlot
    ; zeroing pixel from the second table
    ; and increase Y in second table
    ldy #0
    lda (temp),y
    sta ydraw
    lda (temp),y
    clc
    adc #1
    sta (temp),y
    sty color
    jsr plot.MakePlot
    mva #sfx_silencer sfx_effect

ThereIsPixelHere
ColumnIsReady
    inw temp
    inw tempor2
    inw xdraw
    ;vcmp xdraw,screenwidth,FalloutOfLine
    cpw xdraw RangeRight
    bcc FalloutOfLine
    beq FalloutOfLine

    lda IsEndOfTheFallFlag
; we repeat untill at some point first table reaches
; level of the mountains
    jeq MainFallout2
; now correct heights are in the mountaintable
    mva #1 color
    mva #sfx_silencer sfx_effect
    rts
.endp

;--------------------------------------------------
.proc calculatemountains
;--------------------------------------------------
    mwa #0 xdraw

; starting point
getrandomY   ;getting random Y coordinate
    sec
    lda random
    cmp #screenheight-(margin*4) ;it means that max line=199
    bcs getrandomY
    clc
    adc #(margin*2)
    sta ydraw
    sta yfloat+1
    mva #0 yfloat ;yfloat equals to e.g. 140.0

; how to make nice looking mountains?
; randomize points and join them with lines
; Here we do it simpler way - we randomize X (or deltaX)
; and "delta" (change of Y coordinate)

NextPart
    lda random
    sta delta ; it is after the dot (xxx.delta)
    lda random
    and #$03 ;(max delta)
    sta delta+1 ; before the dot (delta+1.delta)

    lda random
    and #$01 ;random sign (+/- or up/down)
    sta UpNdown

    ; theoretically we have here ready
    ; fixed-point delta value
    ; (-1*(UpNdown))*(delta+1.delta)

    ;loop drawing one line

ChangingDirection
    lda random ;length of the line
    and #$0f   ;max line length
    tax
    inx
    inx
    inx
    stx deltaX

OnePart
    jsr placeTanks.CheckTank
    ; checks if at a given X coordinate
    ; is any tank and if so
    ; changes parameters of drawing
    ; to generate flat 8 pixels
    ; (it will be the place for the tank)
    ; it also stores Y position of the tank
    adw xdraw #mountaintable modify

    lda ydraw
    ldy #0
    sta (modify),y

    ; Up or Down
    lda UpNdown
    beq ToBottom

ToTop  ;it means substracting

    sbw yfloat delta
    lda yfloat+1
    cmp #margin
    bcs @+
      ; if smaller than 10
      ldx #$00
      stx UpNdown
      jmp @+

ToBottom
      adw yfloat delta
      lda yfloat+1
      cmp #screenheight-margin
      bcc @+
        ; if higher than screen
        ldx #$01
        stx UpNdown
@
    sta ydraw

    inw xdraw

    cpw xdraw #screenwidth
    beq EndDrawing

    dec deltaX
    bne OnePart

    jmp NextPart
EndDrawing

    rts
.endp
; ****************************************************
;--------------------------------------------------
.proc calculatemountains0
; Only for testing - makes ground flat (0 pixels)
; and places tanks on it
; remember to remove in final compilation :)
;--------------------------------------------------
    mwa #0 xdraw
nextPointDrawing
	adw xdraw #mountaintable modify
    lda #screenheight
    ldy #0
    sta (modify),y
    inw xdraw
    cpw xdraw #screenwidth
    bne nextPointDrawing
	ldx NumberOfPlayers
    dex
SetYofNextTank
    lda #screenheight-1
    sta ytankstable,x
    dex
    bpl SetYofNextTank
   rts
.endp
; ****************************************************

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
    mwa xdraw xbyte

    lda xbyte
    and #$7
    sta ybit

    lsrw xbyte
    rorw xbyte
    rorw xbyte
;---
    ldy xbyte

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
    ldx ybit


    lda color
    bne ClearUnPlot

    ;plotting here
    lda (xbyte),y
    sta OldOraTemp
    ora bittable,x
    sta (xbyte),y
    jmp ContinueUnPlot
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
; We tried to keep it clear and therefore it is far from
; optimal speed.

; -----------------------------------------
    ; is it not over the screen ???
    cpw ydraw #(screenheight+1); changed for one additional line. cpw ydraw #(screenheight-1)
    bcs unPlot.EndOfUnPlot
CheckX02
    cpw xdraw #screenwidth
    bcs EndOfPlot ;nearest RTS
MakePlot
    ; let's calculate coordinates from xdraw and ydraw
    mwa xdraw xbyte


    lda xbyte
    and #$7
    sta ybit

    ;xbyte = xbyte/8
    lda xbyte
    lsr xbyte+1
    ror ;just one bit over 256. Max screenwidth = 512!!!
    lsr  
    lsr
    tay ;save
    ;---
    ldx ydraw
    lda linetableL,x
    sta xbyte
    lda linetableH,x
    sta xbyte+1

    ldx ybit
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
.proc point
; -----------------------------------------
    ; checks state of the pixel (coordinates in xdraw and ydraw)
    ; result is in A (zero or appropriate bit is set)

    ; let's calculate coordinates from xdraw and ydraw
    mwa xdraw xbyte

    lda xbyte
    and #$7
    sta ybit

    ;xbyte = xbyte/8
    lda xbyte
    lsr xbyte+1
    ror ;just one bit over 256. Max screenwidht = 512!!!
    lsr  
    lsr
    tay ;save
    ;---
    ldx ydraw
    lda linetableL,x
    sta xbyte
    lda linetableH,x
    sta xbyte+1

    ldx ybit

    lda (xbyte),y
    and bittable,x
	eor bittable,x
    rts
.endp

;--------------------------------------------------
.proc DrawLine
;--------------------------------------------------
    mva #0 ydraw+1
    lda #screenheight
    sec
    sbc ydraw
    sta tempbyte01
    jsr plot.MakePlot
    ;rts
    jmp IntoDraw    ; jumps inside Draw routine
                    ; because one pixel is already plotted

@
      lda (xbyte),y
	  and bittable2,x
      sta (xbyte),y
IntoDraw
	  adw xbyte #screenBytes
      dec tempbyte01
      bne @-
    rts
.endp

; ------------------------------------------
.proc TypeChar
; puts char on the graphics screen
; in: CharCode
; in: left LOWER corner of the char coordinates (xdraw, ydraw)
;--------------------------------------------------
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
      ror char1+#	; in second (and next) lines we have C=1 - one SEC enough
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
EndPutChar
    rts
.endp

; ------------------------------------------
.proc PutChar4x4
; puts 4x4 pixels char on the graphics screen
; in: xdraw, ydraw (LOWER left corner of the char)
; in: CharCode4x4 (.sbyte)
; in: plot4x4color (0/1)
; all pixels are being drawn
; (empty and not empty)
;--------------------------------------------------
    ; cpw ydraw #(screenheight-4)
    ; jcs TypeChar.EndPutChar ;nearest RTS
    ; cpw xdraw #(screenwidth-4)
    ; jcs TypeChar.EndPutChar ;nearest RTS
	; checks ommited.
	lda plot4x4color
	beq FontColor0
	lda #$ff		; better option to check (plot4x4color = $00 or $ff)
	sta plot4x4color
FontColor0
    ; char to the table
    lda CharCode4x4
    and #1
	beq Upper4bits
	lda #$ff 		; better option to check (nibbler4x4 = $00 or $ff)
Upper4bits
    sta nibbler4x4
    lda CharCode4x4
    lsr
    sta fontind
    lda #$00
    sta fontind+1
	
    adw fontind #font4x4

    ; and 4 bytes to the table
	ldy #0
    ldx #3
CopyChar
    lda (fontind),y	; Y must be 0 !!!!
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
	adw fontind #32		; next byte of 4x4 font
    dex
    bpl CopyChar

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
    lda ydraw ; y = y - 3 because left lower.
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
      ror char1+#	; in second (and next) lines we have C=1 - one SEC enough
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
	bpl PutInColor0_1	; only mask - no char
    and char1,x
PutInColor0_1
    sta (xbyte),y
    iny
    lda (xbyte),y
    ora mask2,x	
 	bit plot4x4color
	bpl PutInColor0_2	; only mask - no char
    and char2,x
PutInColor0_2
    sta (xbyte),y
    dey
    adw xbyte #screenBytes
    inx
	cpx #4
    bne CharLoopi4x4
EndPut4x4
    rts
.endp

.proc SetMainScreen 
    VDLI DLIinterruptGraph  ; jsr SetDLI for graphics (game) screen
    mwa #dl dlptrs  ; issue #72 (glitches when switches)
    lda dmactls
    and #$fc
    ora #$02     ; 2=normal, 3 = wide screen width
    sta dmactls
    rts
.endp

.endif