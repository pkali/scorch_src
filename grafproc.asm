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
    mwa #$ffff LineLength
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
	bne NotOnePoint
	; length=0
	sta LineLength
	sta LineLength+1
    jmp EndOfDraw

NotOnePoint
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
	bit Vdebug
	bmi MeasureVisualisation
    jmp ContinueDraw  ; was `bne` - not good, because LineLength starts from $ffff
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
MeasureVisualisation
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
.proc splot8
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

;-------------------------------*------------------
.proc placetanks
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
	; and clear lowest bit to be sure that the X coordinate is even
	; (this is to have P/M background look nice)
	; "AND" does not change "Carry" bit.
	; x correction for P/M
	; --
	.IF XCORRECTION_FOR_PM = 1
	and #$fe
	.ENDIF
	; --
    sta xtankstableL,x
    bcs NotHigherByte01
    dec xtankstableH,x
NotHigherByte01

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
.proc ClearTanks
	jsr PMoutofScreen
    mva #1 Erase	; erase tanks flag
.endp
;--
.proc drawtanks
;-------------------------------------------------
    lda TankNr
    pha
    ldx #$00
    stx TankNr

DrawNextTank
    jsr drawtanknr
    inc TankNr
    ldx TankNr
    Cpx NumberOfPlayers
    bne DrawNextTank

    pla
    sta TankNr

    mva #0 Erase	; no erase tanks flag
    rts
.endp
;---------
.proc DrawTankNr
    ldx tankNr
    ; let's check the energy
    lda eXistenZ,x
    bne SkipHidingPM ; if energy=0 then no tank

    ; hide P/M
	lda TanksPMOrder,x
	tax
    lda #0
    cpx #$4 ; 5th tank is defferent
    bne No5thTankHide
	sta hposp0+4
	sta hposp0+5
	beq @+
No5thTankHide
	cpx #$5 ; 6th tank is defferent
	bne No6thTankHide
	sta hposp0+6
	sta hposp0+7
	beq @+
No6thTankHide
    sta hposp0,x
@
	ldx TankNr
    jmp DoNotDrawTankNr
SkipHidingPM

	lda TankShape,x
	tax
	ldy TankShapesTable,x
	ldx TankNr
    lda AngleTable,x
	cmp #91		; left or right tank shape
	bcs LeftTank
	:2 iny	; right tank
LeftTank
    sty CharCode
DrawTankNrX
    ldx tanknr
    jsr SetupXYdraw

    jsr TypeChar
	lda Erase
	jne noTankNoPM
    ; now P/M graphics on the screen (only for 5 tanks)
    ; horizontal position
    ldx TankNr
	lda TanksPMOrder,x
	tax
    mwa xdraw xbyte
    rorw xbyte ; divide by 2 (carry does not matter)
    lda xbyte
    clc
    adc #PMOffsetX ; P/M to graphics offset
    cpx #$4 ; 5th tank are joined missiles and offset is defferent
    bne No5thTank
    clc
    adc #$04  ; missile offset offset
	sta hposp0+4
	sta hposp0+5
	bne NoMissile
No5thTank
	cpx #$5 ; 6th tank are joined missiles and offset is defferent
	bne Tanks1to4
    clc
    adc #$04  ; missile offset offset
	sta hposp0+6
	sta hposp0+7
	bne NoMissile
Tanks1to4
    sta hposp0,x

NoMissile
    ; vertical position
    lda pmtableL,x
    sta xbyte
    lda pmtableH,x
    sta xbyte+1

    ; calculate start position of the tank
    lda ydraw
    clc
    adc #PMOffsetY
    sta temp
    ldy #$00
    cpx #$5
    bcs PMForTank6
    ; clear sprite and put 3 lines on the tank at the same time
	ldx #3	; three lines of PM
ClearPM     
    cpy temp
    bne ZeroesToGo
@	lda (xbyte),y
	and #%11110000
    ora #%00001111 ; (2 bits set) we set on two pixels in three lines
    sta (xbyte),y
    dey
	dex
	bne @-
ZeroesToGo
    lda (xbyte),y
	and #%11110000
    sta (xbyte),y
    dey
    bne ClearPM
	beq NoPlayerMissile
PMForTank6
    ; clear sprite and put 3 lines on the tank at the same time
	ldx #3	; three lines of PM
ClearPM6     
    cpy temp
    bne ZeroesToGo6
@	lda (xbyte),y
	and #%00001111
    ora #%11110000 ; (2 bits set) we set on two pixels in three lines
    sta (xbyte),y
    dey
	dex
	bne @-
ZeroesToGo6
    lda (xbyte),y
	and #%00001111
    sta (xbyte),y
    dey
    bne ClearPM6

NoPlayerMissile
noTankNoPM
	ldy #$01
	lda Erase
	beq @+
	dey
@	sty color
	; draw defensive weapons like shield ( tank number in X )
	; in xdraw, ydraw we have coordinates left LOWER corner of Tank char
    ldx TankNr
	lda ActiveDefenceWeapon,x
	cmp #ind_Shield_________		; one shot shield 
	beq DrawTankSh
	cmp #ind_Force_Shield___		; shield with energy and parachute
	beq DrawTankShieldBold
	cmp #ind_Heavy_Shield___		; shield with energy
	beq DrawTankShieldBold
	cmp #ind_Bouncy_Castle__		; Auto Defence
	beq DrawTankShieldWihHorns
	cmp #ind_Mag_Deflector__		; Mag Deflector
	beq DrawTankShieldWihHorns
	cmp #ind_White_Flag_____		; White Flag
	beq DrawTankFlag
	bne NoShieldDraw
DrawTankSh
	jsr DrawTankShield
	jmp NoShieldDraw
DrawTankShieldWihHorns
	jsr DrawTankShield
	jsr DrawTankShieldHorns
	jmp NoShieldDraw
DrawTankShieldBold
	jsr DrawTankShield
	jsr DrawTankShieldBoldLine
	jmp NoShieldDraw
DrawTankFlag
    lda #char_flag____________	; flag symbol
    sta CharCode
    lda Ytankstable,x
    sec
    sbc #8
    sta ydraw
    jsr TypeChar
NoShieldDraw
BarrelChange
	ldy #$01
	lda Erase
	beq @+
	dey
@	sty color
	jsr DrawBarrel
	ldx TankNr
DoNotDrawTankNr
	rts
.endp

; -------------------------------------
.proc FlashTank
; -------------------------------------
; number of blinking tank in TankNr
	mva #18 fs  ; temp, how many times flash the tank
tankflash_loop
    lda CONSOL  ; turbo mode
	and #%00000001 ; START KEY
    sne:mva #1 fs  ; finish it     
    mva #1 Erase
	ldx TankNr
    jsr DrawTankNr.SkipHidingPM	; it's necessary becouse DrawTankNr skips tanks with no energy !
	;PAUSE 2
    ldy #1
    jsr PauseYFrames
    mva #0 Erase
	ldx TankNr
    jsr DrawTankNr.SkipHidingPM
    ;PAUSE 2
    ldy #1
    jsr PauseYFrames
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
	sbw xdraw #$03		; 3 pixels to left
	; draw left vertical line of shield ( | )
	mva #7 temp			; strange !!!
@
	jsr plot
.nowarn	dew ydraw
	dec temp
	bne @-
	; draw left oblique line of shield ( / )
	mva #3 temp
@
	jsr plot
.nowarn	dew ydraw
	inw xdraw
	dec temp
	bne @-
	; draw top horizontal line of shield ( _ )
	mva #7 temp
@
	jsr plot
	inw xdraw
	dec temp
	bne @-
	; draw right oblique line of shield ( \ )
	mva #3 temp
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
.proc DrawTankShieldBoldLine
; use only directly after DrawTankShield
; this proc draws bold top on shield.
; Symbol of ablative shield ? :)
;--------------------------------------------------
	sbw xdraw #$04			; 5 pixels left
	sbw ydraw #$0b		; 11 pixels up
	; draw additional top horizontal line of shield ( _ )
	mva #6 temp
@
	jsr plot
.nowarn	dew xdraw
	dec temp
	bne @-
	rts
.endp
;--------------------------------------------------
.proc DrawTankParachute
;Tank number in X
;--------------------------------------------------
    lda #char_parachute_______	; parachute symbol
    sta CharCode
    lda Ytankstable,x
	cmp #16
	bcc ToHighToParachute
    ;sec
    sbc #8
    sta ydraw
    jsr SetupXYdraw.X
    jsr TypeChar
ToHighToParachute
	ldx TankNr
	rts
.endp

;--------------------------------------------------
.proc DrawTankRocketEngine
; X - tank number
; 
; this proc change xdraw, ydraw  and temp!
;--------------------------------------------------
	clc
	lda Ytankstable,x
	adc #2	; 1 pixel down
	sta ydraw
	mva #0 ydraw+1
	
	clc
	lda XtanksTableL,x
	adc #2	; 2 pixels to right
	sta xdraw
	lda XtanksTableH,x
	adc #0
	sta xdraw+1

	; draw first horizontal line 
	mva #5 temp
@
	jsr plot
	inw xdraw
	dec temp
	bne @-
	
	sbw xdraw #2	; 2 pixels left	
	inw ydraw	; 1 pixel down
	
	; draw second horizontal line 
	mva #3 temp
@
	jsr plot
.nowarn	dew xdraw
	dec temp
	bne @-

	adw xdraw #2	; 2 pixels right	
	inw ydraw	; 1 pixel down

	; and last pixel
	jsr plot

	ldx TankNr
	rts
.endp
;--------------------------------------------------
.proc DrawTankEngine
; X - tank number
; 
; this proc change xdraw, ydraw  and temp!
;--------------------------------------------------
	; one pixel under tank
	clc
	lda Ytankstable,x
	adc #1
	sta ydraw
	mva #0 ydraw+1
	lda XtankstableL,x
	sta xdraw
	lda XtankstableH,x
	sta xdraw+1
	; clear first pixel under tank
	mva #0 color
	jsr plot
	inw xdraw
	; plot 6 random color pixels
	mva #6 temp
@	lda Erase
	eor #%00000001
	and random
	and #%00000001
	sta color
	jsr plot
	inw xdraw
	dec temp
	bne @-
	; clear last pixel under tank
	mva #0 color
	jsr plot
	ldx TankNr
	rts
.endp
;--------------------------------------------------
.proc TankFalls;
;--------------------------------------------------
    lda #0
    sta PreviousFall	; bit 7 - left, bit 6 - right
    sta EndOfTheFallFlag
    sta Parachute
	mva #2 FallingSoundBit	; another trick for only one sfx initialization in loop

    ; let's check if the given tank has got the parachute
	ldx TankNr
	lda ActiveDefenceWeapon,x
    cmp #ind_Parachute______ ; parachute
	beq ParachuteActive
	cmp #ind_StrongParachute ; strong parachute
	beq ParachuteActive
	cmp #ind_Force_Shield___ ; shield witch energy and parachute
    bne TankFallsX
ParachuteActive
    inc Parachute
TankFallsX
	; sound only if really falls
	lda Parachute
	and FallingSoundBit		; bit 1
	beq NoFallingSound
	mva #0 FallingSoundBit
    mva #sfx_shield_off sfx_effect
NoFallingSound
    ; clear previous position
    mva #1 Erase
    jsr DrawTankNr
    ; and the parachute (if present)
    lda Parachute
    and #01
    beq DoNotClearParachute
    ; here we clear the parachute
;    ldx TankNr
    jsr DrawTankParachute
DoNotClearParachute
    mva #0 Erase
;    ldx TankNr
	lda EndOfTheFallFlag	; We only get byte below the tank if still falling
	bne NoGroundCheck
    ; coordinates of the first pixel under the tank
    ldx TankNr
    jsr SetupXYdraw.X
    lda Ytankstable,x
    clc
    adc #1 ; in this point the comment helped us! For the very first
    ; time in our lives! Tada! It opens a new chapter!!!
    sta ydraw
    ;
;	UnderTank1	; byte under tank
;	UnderTank2	; byte under tank reversed (for simple check right direction)
    lda #08
    sta temp  ; Loop Counter
ByteBelowTank
    jsr point_plot
    beq EmptyPoint2
    sec
	ror UnderTank2
	sec
    bcs ROLPoint2
EmptyPoint2
    clc
	ror UnderTank2
	clc
ROLPoint2
    rol UnderTank1
    inw xdraw
    dec temp
    bne ByteBelowTank	
NoGroundCheck
    ldx TankNr
	lda Ytankstable,x
	cmp #screenheight-1	; tank on lowest position (no falling down)
	jcs EndOfFall
	lda UnderTank1
	bne NoFallingDown
	; Tank falling down ----
	lda Parachute
    and #1
    bne ParachutePresent
    ; decreasing energy 
    ldy #2 ; how much energy to substract if no parachute
    jsr DecreaseEnergyX
ParachutePresent
	; check parachute type
	lda ActiveDefenceWeapon,x
    cmp #ind_StrongParachute ; strong parachute
	bne OneTimeParachute
    ; decreasing energy of parachute
    ldy #1 ; how much parachute energy to substract
	jsr DecreaseShieldEnergyX
	cpy #0	; is necessary to reduce tenk energy ?
	beq @+
    jsr DecreaseEnergyX
@
	; check energy of parachute	
	lda ShieldEnergy,x
	bne OneTimeParachute
	lda #$00
	sta Parachute
	sta ActiveDefenceWeapon,x ; deactivate defence
OneTimeParachute
    lda Parachute
    ora #2 ; we set bit nr 1 (nr 0 means that parachute is present)
    sta Parachute
    ; tank is falling down - modify coorinates
    lda Ytankstable,x
    clc
    adc #1
    sta Ytankstable,x
	jmp EndOfFCycle
NoFallingDown
	; check direction (left or right)
	ldy #SlideLeftTableLen-1		; SlideLeftTable length -1 (from 0 to 7)
@	lda SlideLeftTable,y
	cmp UnderTank1
	beq FallingLeft
	cmp UnderTank2
	beq FallingRight
	dey
	bpl @-
	bmi NoLeftOrRight
FallingRight
	; tank is falling right
	bit PreviousFall	; bit 6 - left
	bvs EndRightFall
    ; we finish falling right if the tank reached the edge of the screen
    lda XtanksTableH,x
	cmp #>(screenwidth-TankWidth-2) ; 2 pixels correction due to a barrel wider than tank
	bne @+
    lda XtanksTableL,x
	cmp #<(screenwidth-TankWidth-2) ; 2 pixels correction due to a barrel wider than tank
@   bcs EndRightFall
NotRightEdge
    ; tank is falling right - modify coorinates
    clc
    lda XtankstableL,x
    adc #1
    sta XtankstableL,x
    lda XtankstableH,x
    adc #0
    sta XtankstableH,x
	mva #%10000000 PreviousFall	; set bit 7 - right
	bne EndOfFCycle
FallingLeft
	; tank is falling left
	bit PreviousFall	; bit 7 - right
	bmi EndLeftFall
    ; we finish falling left if the tank reached the edge of the screen
    lda XtanksTableH,x
    bne NotLeftEdge
    lda XtanksTableL,x
	cmp #3	; 2 pixels correction due to a barrel wider than tank
    bcc EndLeftFall
NotLeftEdge
    ; tank is falling left - modify coorinates
    sec
    lda XtankstableL,x
    sbc #1
    sta XtankstableL,x
    lda XtankstableH,x
    sbc #0
    sta XtankstableH,x
	mva #%01000000 PreviousFall	; set bit 6 - left
	bne EndOfFCycle
EndLeftFall
EndRightFall
NoLeftOrRight
    inc EndOfTheFallFlag ; after this is shouldn't fall 
EndOfFCycle
	; draw tank on new position
    jsr DrawTankNr	; ew have TankNr in X (I hope :) )
    ; checking is parachute present and if so, draw it
    lda Parachute
	cmp #3	; parachute and falling
	bne DoNotDrawParachute
    ; here we draw parachute
;    ldx TankNr
    jsr DrawTankParachute
    jsr WaitOneFrame	; only if tank with parachute
RapidFalling
DoNotDrawParachute
	lda EndOfTheFallFlag
	jeq TankFallsX
    ; Tank falling down already finished, but it is not sure that
    ; the horizontal coordinate is even.
    ; If it is odd then it must be corrected because otherwise
    ; P/M graphics background would not look OK
;    ldx TankNr
	; x correction for P/M
	; --
	.IF XCORRECTION_FOR_PM = 1
     lda XtanksTableL,x
    and #$01
    beq EndOfFall ; if it is even then it is the end
    ; and if not, we push it one pixel the way it was falling before
    lda #%10000000	 ; set "virtual ground" for right falling
	ldy #%00000001
	bit PreviousFall
	bmi ForceFallLeft
	tay		; tricky - replaces ldy #%10000000
	lda #%00000001	 ; set "virtual ground" for left falling
ForceFallLeft
	sta UnderTank1
	sty UnderTank2
	jmp TankFallsX
	.ENDIF
	; --
EndOfFall
    mva #1 Erase
;    ldx TankNr
    ; if tank was falling down having parachute,
    ; we must deduct one parachute
    lda Parachute
    cmp #$03 ; was falling down and the parachute
    bne NoParachuteWeapon
	; first we check type of parachute
	lda ActiveDefenceWeapon,x
	cmp #ind_Parachute______		; deactivate weapon only if parachute (54)
	bne NoParachuteWeapon
	mva #0 ActiveDefenceWeapon,x ; deactivate defence weapon (parachute)
NoParachuteWeapon
    ; now we clear parachute on the screen if present
    lda Parachute
    and #01
    beq ThereWasNoParachute
    jsr DrawTankParachute
ThereWasNoParachute
    mva #0 Erase
;    ldx TankNr	
    jsr DrawTankNr	; redraw tank after erase parachute (exactly for redraw leaky schield :) )
    mva #sfx_silencer sfx_effect
    rts

.endp

;--------------------------------------------------
.proc ClearPMmemory
;--------------------------------------------------

	lda #$00
	tay
@	sta pmgraph+$300,y
	sta pmgraph+$400,y
	sta pmgraph+$500,y
	sta pmgraph+$600,y
	sta pmgraph+$700,y
	iny
	bne @-
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
;    jsr DrawLine
;	there was Drawline proc 
    lda #screenheight
    sec
    sbc ydraw
    sta tempbyte01
    jsr plot.MakePlot
	; after plot we have: (xbyte),y - addres of screen byte; X - index in bittable (number of bit)
;    jmp IntoDraw    ; jumps inside Draw routine
                    ; because one pixel is already plotted (and who cares? :) )
@
	lda (xbyte),y
	and bittable2,x
	sta (xbyte),y
;IntoDraw
	adw xbyte #screenBytes
	dec tempbyte01
	bne @-
;	end of Drawline proc
NoMountain
    inw modify
    inw xdraw
    cpw xdraw #screenwidth
    bne drawmountainsloop
    rts
/*
;--------------------------------------------------
drawmountainspixel		; never used ?
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
 */
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
	jsr ClearTanks
NoClearTanks

; Fix for lonely pixel after nuclear winter :) #103
	lda #0
	sta xdraw
	sta xdraw+1
	sta ydraw
	sta ydraw+1
	sta color
	jsr plot

; First we look for highest pixels and fill with their coordinates
; both tables

    mwa RangeLeft xdraw
    adw RangeLeft #mountaintable temp
    adw RangeLeft #mountaintable2 tempor2

    cpw xdraw RangeRight
	jcs NothingToFall

NextColumn1
    mwa #0 ydraw
NextPoint1
    jsr point_plot
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
    jsr point_plot
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
    sta color	; Pozor! :)  we know - now A=1
NothingToFall
    mva #sfx_silencer sfx_effect
	jsr DrawTanks
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
    mva #screenheight-margin-5 yfloat+1
    sta ydraw

; how to make nice looking mountains?
; randomize points and join them with lines
; Here we do it simpler way - we randomize X (or deltaX)
; and "delta" (change of Y coordinate)

NextPart
    lda random
    and mountainDeltaL
    sta delta ; it is after the dot (xxx.delta)
    lda random
    and mountainDeltaH ;(max delta)
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

/* 
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
 */

;--------------------------------------------------
.proc CheckMaxMountain
; in A return y coordinate of highest mountain
;--------------------------------------------------
    mwa #mountaintable modify
    ldy #0
    ldx #screenheight-1
nextPointChecking
	txa
    cmp (modify),y
	bcc NotHigher
    lda (modify),y
	tax
NotHigher
    inw modify
    cpw modify #(mountaintable+screenwidth)
    bne nextPointChecking
	txa
	rts
.endp

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
    lda CharCode4x4
    and #%00000001
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
    mwa dx xbyte

    lda xbyte
    and #$7
    sta ybit

    :3 lsrw xbyte ; div 8
;    rorw xbyte
;    rorw xbyte
;---
    ldy xbyte	; horizontal byte offet stored in Y
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

;--------------------------------------------------------
.proc DisplayOffensiveTextNr ;
    ldx TextNumberOff
    lda talk.OffensiveTextTableL,x
    sta LineAddress4x4
    lda talk.OffensiveTextTableH,x
    sta LineAddress4x4+1
    inx ; the next text
    lda talk.OffensiveTextTableH,x
    sta temp+1
    lda talk.OffensiveTextTableL,x
    sta temp  ; opty possible
    ; substract address of the next text from previous to get text length
    sbw temp LineAddress4x4 temp2
    mva temp2 fx 

    ;jsr Display4x4AboveTank
    ;rts
	; POZOR !!!
.endp

;--------------------------------------------------------
.proc Display4x4AboveTank ;
    ; Displays texts using PutChar4x4 above tank and mountains.
    ; Pretty cool, eh!
    ;parameters are:
    ;Y - number of tank above which text is displayed
    ;fx - length of text
    ;LineAddress4x4 - address of the text

    ;lets calculate position of the text first!
    ;that's easy because we have number of tank
    ;and xtankstableL and H keep X position of a given tank

    lda xtankstableL,y
    sta temp
    lda xtankstableH,y
    sta temp+1
    ;now we should substract length of the text-1
    ;temp2 = (fx-1)*2
    ldy fx
    dey
    tya
    asl
    sta temp2
    mva #0 temp2+1
    ;now we have HALF length in pixels
    ;stored in temp2

    ;here we assume max length of text
    ;to display is 127 chars, but later it turns out it must be max 63!

    sbw temp temp2 ; here begin of the text is in TEMP !!!!
    ;now we should check overflows
    ;lda temp+1  ; opty
    bpl DOTNnotLessThanZero
      ;less than zero, so should be zero
      mwa #0 temp
    beq DOTNnoOverflow

DOTNnotLessThanZero
    ;so check if end larger than screenwidth


    lda fx
    asl
    asl
    ;length in pixels -
    ;text length max 63 chars !!!!!!!!


    clc
    adc temp
    sta temp2
    lda #0
    adc temp+1
    sta temp2+1
    ;now in temp2 is end of the text in pixels
    ;so check if not greater than screenwitdth
    cpw temp2 #screenwidth
    bcc DOTNnoOverflow

    ;if end is greater than screenwidth
    ;then screenwidth - length is fine
    lda fx
    asl
    asl
    sta temp
    mva #0 temp+1

    sec
    lda #<(screenwidth-1)
    sbc temp
    sta temp
    lda #>(screenwidth-1)
    sbc temp+1
    sta temp+1
DOTNnoOverflow
    ;here in temp we have really good x position of text

    mwa temp LineXdraw

    ;now let's get y position
    ;we will try to put text as low as possible
    ;just above mountains (so mountaintable will be checked)
    lda fx
    asl
    asl
    tay
    ;in temp there still is X position of text
    ;if we add temp and Y we will get end of the text
    ;so, lets go through mountaintable and look for
    ;the lowest value within
    ;Mountaitable+temp and Mountaitable+temp+Y

    adw temp #MountainTable

    mva #screenheight temp2 ;initialisation of the lowest value

DOTLowestMountainValueLoop
    lda (temp),y
    cmp temp2
    bcs DOTOldLowestValue  ;old lowest value
    ;new lowest value
    sta temp2
DOTOldLowestValue
    dey
    cpy #$ff
    bne DOTLowestMountainValueLoop

    sec
    lda temp2
    sbc #(4+9) ;9 pixels above ground (and tanks...)
    sta LineYdraw

    jmp TypeLine4x4.noLengthNoColor  ; rts

.endp

;--------------------------------------------------------
.proc DisplayTankNameAbove ;
    lda tankNr
    :3 asl  ; *8
    clc
    adc #<TanksNames
    sta temp  ; TextAddress
    lda #0
    adc #>Tanksnames
    sta temp+1  ; TextAddress+1
    mwa temp LineAddress4x4

    ;find length of the tank's name
    ldy #7
@
      lda (temp),y
      bne end_found
      dey
    bne @-
   
end_found
    iny
    sty fx
    ldy tankNr
    jsr Display4x4AboveTank
    rts
.endp

;-------------------------------
.proc TypeLine4x4 ;
;-------------------------------
    ;this routine prints line of length `fx`
    ;address in LineAddress4x4
    ;starting from LineXdraw, LineYdraw

    lda #14 ; default length of 4x4 texts
    sta fx

variableLength
    lda #$ff  ; $ff - visible characters, $00 - clearing

staplot4x4color
    sta plot4x4color
noLengthNoColor

    ldy #0
    sty LineCharNr

TypeLine4x4Loop
    ldy LineCharNr

    lda (LineAddress4x4),y
    and #$3f ;always CAPITAL letters
    sta CharCode4x4
    mwa LineXdraw dx
    mva LineYdraw dy
	mva #0 dy+1  ;	dy is 2 bytes value
    jsr PutChar4x4 ;type empty pixels as well!
    adw LineXdraw #4
    inc:lda LineCharNr
    cmp fx
    bne TypeLine4x4Loop

EndOfTypeLine4x4
    rts
.endp


;--------------------------------
.proc AreYouSure
;using 4x4 font
    
    mva #4 ResultY  ; where seppuku text starts Y-wise on the screen
    
    ;top frame
    mva ResultY LineYdraw
    jsr TL4x4_top
    adb ResultY  #4 ;next line
    
    ;sure?
    mwa #areYouSureText LineAddress4x4
    jsr _sep_opty    
    ;bottom frame
    mva ResultY LineYdraw
    jsr TL4x4_bottom
    

    jsr GetKey
    cmp #@kbcode._Y  ; $2b  ; "Y"
    bne @+
    mva #$80 escFlag
    bne skip01
@    mva #0 escFlag
skip01
    jsr WaitForKeyRelease
    
    ;clean
    mva #3 di
    mva #4 ResultY
@
      mva #$ff plot4x4color
      mwa #lineClear LineAddress4x4
      jsr _sep_opty  
      dec di
      bne @-

quit_areyousure
    rts
.endp

.proc _sep_opty
      mwa #((ScreenWidth/2)-(8*4)) LineXdraw  ; centering
      mva ResultY LineYdraw
      jsr TypeLine4x4
      adb ResultY  #4 ;next line
    rts
.endp

;--------------------------------
.proc DisplaySeppuku
;using 4x4 font
    

    mva #20 fs  ; temp, how many times blink the billboard
seppuku_loop
      lda CONSOL  ; turbo mode
	  and #%00000001 ; START KEY
      sne:mva #1 fs  ; finish it     

      mva #4 ResultY  ; where seppuku text starts Y-wise on the screen
      
      ;top frame
      mva ResultY LineYdraw
      jsr TL4x4_top
      adb ResultY  #4 ;next line
      
      ;seppuku
      mwa #seppukuText LineAddress4x4
      jsr _sep_opty
            
      ;bottom frame
      mva ResultY LineYdraw
      jsr TL4x4_bottom  ; just go

    ;clean seppuku
    
    mva #3 di
    ;mva #4 ResultY
    lda #4
    sta ResultY
loplop ;@
      mwa #lineClear LineAddress4x4
      jsr _sep_opty
  
      dec di
      bne loplop ;@-

     dec fs
    jne seppuku_loop

quit_seppuku
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
	mva WallsType COLBAKS	; set color of background 
    jsr WaitOneFrame
    rts
.endp
; -------------------------------------
.proc SetupXYdraw
    lda ytankstable,x
    sta ydraw
    mva #0 ydraw+1
X    lda XtanksTableL,x
    sta xdraw
    lda XtanksTableH,x
    sta xdraw+1
    rts
.endp
;--------------------------------------------------
.proc DrawBarrel
; X - tankNr
; changes xdraw, ydraw, fx, fy
;--------------------------------------------------
    ;vx calculation
    ;vx = sin(90-Angle) for Angle <=90
    ;vx = -sin(Angle-90) for 90 < Angle <= 180 

    ; erase previous barrel

    ;cos(Angle) (but we use sin table only so some shenanigans happen)
  ;  mva #0 color
  ;  lda previousBarrelAngle,x
  ;  sta Angle
  ;  jsr DrawBarrelTech
  ;  
  ;  mva #1 color
    ldx TankNr
    jsr SetupXYdraw
	lda BarrelLength,x
	sta yc	; current tank barrel length
    lda angleTable,x
    sta Angle
    jsr DrawBarrelTech
    rts
.endp

.proc DrawBarrelTech
    ; angle in Angle and A
 
    mvx #0 goleft
    cmp #91
    bcc angleUnder90
    
    ;over 90
    sec
    sbc #90
    tax
    ; barrel start offset over 90deg
    adw xdraw #4 xdraw
    mva #1 goleft
    bpl @+  ; jmp @+

angleUnder90
    sec             ; X = 90-Angle
    lda #90
    sbc Angle
    tax
    ; barrel start offset under 90deg
    adw xdraw #3 xdraw
    
@    
    sbw ydraw #3 ydraw
    lda sintable,x  ; cos(X)
    sta vx

;======vy
    ;vy = sin(Angle) for Angle <=90
    ;vy = sin(180-Angle) for 90 < Angle <= 180

;--
    lda Angle
    cmp #91
    bcc YangleUnder90
    
    lda #180
    sec
    sbc Angle
YangleUnder90
    tax
    lda sintable,x
    sta vy

    lda #0  ; all arithmetic to zero
    sta vx+1
    sta vy+1
	lda #128 	; ; add 0.5 to fx and fy (not vx and vx) for better rounding - it's my opinion (Pecus)
    sta fx
    sta fy

    ; draw by vx vy
    ; in each step 
    ; 1. plot(xdraw, ydraw)
    ; 2. add vx and vy to 3 byte variables xdraw.fx, ydraw.fy
    ; 3 check length, if shorter, go to 1.
    
 ;   mva #6 yc  ; barrel length
barrelLoop
    
    lda goleft
    bne goright
    clc
    lda fx
    adc vx
    sta fx
    bcc @+
    lda xdraw
    adc vx+1
    sta xdraw
    bcc @+
    inc xdraw+1
@
    jmp ybarrel
goright
    sec
    lda fx
    sbc vx
    sta fx
    bcs @+
    lda xdraw
    sbc vx+1
    sta xdraw
    bcs @+
    dec xdraw+1
@
ybarrel
    sec
    lda fy
    sbc vy
    sta fy
    bcs @+
    lda ydraw
    sbc vy+1
    sta ydraw
    bcs @+
    dec ydraw+1
@    
    jsr plot ;.MakePlot

    dec yc
    bne barrelLoop
    
    mwa xdraw EndOfTheBarrelX
    mva ydraw EndOfTheBarrelY
    
    rts
.endp
;--------------------------------------------------
.proc PMoutofScreen
;--------------------------------------------------
    lda #$00 ; let all P/M disappear
	ldy #7
@	sta hposp0,y
	dey
	bpl @-
    ;:8 sta hposp0+#	; optimized... but Y!
    rts
.endp
;--------------------------------------------------
.proc ColorsOfSprites
	ldy #3
@	lda TankColoursTable,y ; colours of sprites under tanks
	sta PCOLR0,y
	dey
	bpl @-
    LDA TankColoursTable+4
    STA COLOR3     ; joined missiles (5th tank)
    rts
.endp
;--------------------------------------------------
.proc SetPMWidth
    lda #%01010101
    sta sizem ; all missiles, double width
    lda #$00
    sta sizep0 ; P0-P3 widths
    sta sizep0+1
    sta sizep0+2
    sta sizep0+3
    rts
.endp

.endif