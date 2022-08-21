;	@com.wudsn.ide.asm.mainsourcefile=scorch.asm

    .IF *>0 ;this is a trick that prevents compiling this file alone
;--------------------------------------------------
.proc Explosion
;--------------------------------------------------
    ;cleanup of the soil fall down ranges (left and right)
    mwa #screenwidth RangeLeft
    lda #0
    sta RangeRight
    sta RangeRight+1

    ldx TankNr
    lda ActiveWeapon,x
.endp
.proc ExplosionDirect
    asl
    tax
    lda ExplosionRoutines+1,x
    pha
    lda ExplosionRoutines,x
    pha
    rts
ExplosionRoutines
    .word babymissile-1
    .word missile-1
    .word babynuke-1
    .word nuke-1
    .word leapfrog-1
    .word funkybomb-1
    .word mirv-1
    .word deathshead-1
    .word napalm-1 ;napalm
    .word hotnapalm-1 ;hotnapalm
    .word tracer-1
    .word tracer-1 ;smoketracer
    .word babyroller-1
    .word roller-1
    .word heavyroller-1
    .word riotcharge-1
    .word riotblast-1
    .word riotbomb-1
    .word heavyriotbomb-1
    .word babydigger-1
    .word digger-1
    .word heavydigger-1
    .word babysandhog-1
    .word sandhog-1
    .word heavysandhog-1
    .word dirtclod-1
    .word dirtball-1
    .word tonofdirt-1
    .word liquiddirt-1
    .word dirtcharge-1
    .word VOID-1 ;earthdisrupter
    .word VOID-1 ;plasmablast
    .word laser-1

VOID
tracer
    rts
.endp
; ------------------------

; ------------------------
.proc babymissile
    mva #sfx_baby_missile sfx_effect 
    inc FallDown2
    mva #11 ExplosionRadius
    jsr CalculateExplosionRange
    jmp xmissile
.endp
; ------------------------
.proc missile ;
    mva #sfx_baby_missile sfx_effect
    inc FallDown2
    mva #17 ExplosionRadius
    jsr CalculateExplosionRange
    jmp xmissile
.endp
; ------------------------
.proc babynuke
    mva #sfx_nuke sfx_effect 
    inc FallDown2
    mva #25 ExplosionRadius
    jsr CalculateExplosionRange
    jmp xmissile
.endp
; ------------------------
.proc nuke
    mva #sfx_nuke sfx_effect 
    inc FallDown2
    mva #30 ExplosionRadius
    jsr CalculateExplosionRange
    jmp xmissile
.endp
; ------------------------
.proc leapfrog
    mva #sfx_baby_missile sfx_effect
    inc FallDown2
    mva #17 ExplosionRadius
    jsr CalculateExplosionRange
    jsr xmissile

    ; soil must fall down now! there is no other way...
    ; hide tanks or they fall down with soil
    lda TankNr
    pha
    mva #1 Erase
    jsr drawtanks
    mva #0 Erase
    jsr SoilDown2
    jsr drawtanks
    pla
    sta TankNr

    ; it looks like force is divided by 4 here BUT"
    ; in Flight routine force is multiplied by 2 and left
    ; so, we have Force divided by 2 here (not accurately)
    lsr Force+1
    ror Force
    ;lsr Force+1
    ;ror Force
    mva LeapFrogAngle Angle
    
    mva #sfx_funky_hit sfx_effect
    sbw ytraj+1 #$05	; next missiles start point goes 5 pixel UP to prevent multiple explosion at one point if tank is hit (4 pixels tank height + 1)
    jsr Flight
    lda HitFlag
    beq EndOfLeapping
    mva #15 ExplosionRadius
    jsr CalculateExplosionRange0
    mva #sfx_baby_missile sfx_effect
    jsr xmissile

    ; soil must fall down now! there is no other way...
    ; hide tanks or they fall down with soil
    lda TankNr
    pha
    mva #1 Erase
    jsr drawtanks
    mva #0 Erase
    jsr SoilDown2
    jsr drawtanks
    pla
    sta TankNr

    ; it looks like force is divided by 4 here BUT"
    ; in Flight routine force is multiplied by 2 and left
    ; so, we have Force divided by 2 here (not accurately)
    ;lsr Force+1
    ;ror Force
    lsr Force+1
    ror Force
    mva LeapFrogAngle Angle
    mva #sfx_funky_hit sfx_effect
    sbw ytraj+1 #$05	; next missiles start point goes 5 pixel UP to prevent multiple explosion at one point if tank is hit (4 pixels tank height + 1)
    jsr Flight
    lda HitFlag
    beq EndOfLeapping
    mva #13 ExplosionRadius
    jsr CalculateExplosionRange0
    mva #sfx_baby_missile sfx_effect
    jmp xmissile
EndOfLeapping
    rts
.endp
; ------------------------
.proc mirv ;  the whole mirv is performed by Flight routine
    inc FallDown2
    rts
.endp
; ------------------------
.proc funkybomb ;
    mva #sfx_baby_missile sfx_effect
    mwa xtraj+1 xtrajfb
    sbw ytraj+1 #$05 ytrajfb	; funky missiles start point goes 5 pixel UP to prevent multiple explosion at one point if tank is hit (4 pixels tank height + 1)
    inc FallDown2
    ;central Explosion
    mva #21 ExplosionRadius
    jsr CalculateExplosionRange0
    jsr xmissile
    
    lda TankNr
    pha
    mva #1 Erase
    jsr drawtanks
    mva #0 Erase
    
    jsr SoilDown2
    ;
    mva #1 Erase
    jsr drawtanks
    mva #0 Erase
    pla
    sta TankNr
	mva #1 color
    mva #5 FunkyBombCounter
FunkyBombLoop
    mva #1 tracerflag
    ;force randomization (range: 256-511)
    lda random
    sta Force
    mva #1 Force+1
    ;Angle randomization Range: (70-110 degrees)
    randomize 70 110
    sta Angle

    lda #0
    sta xtraj
    sta ytraj
    mwa xtrajfb xtraj+1
    mwa ytrajfb ytraj+1
    mva #sfx_funky_hit sfx_effect
    jsr Flight

    jsr CalculateExplosionRange
    lda HitFlag
    beq NoExplosionInFunkyBomb
      mva #sfx_baby_missile sfx_effect
      mva #11 ExplosionRadius
      jsr xmissile
NoExplosionInFunkyBomb
    dec FunkyBombCounter
    bne FunkyBombLoop
    mva #0 tracerflag
    rts
.endp
; ------------------------
.proc deathshead
    inc FallDown2
    mva #30 ExplosionRadius
    jsr CalculateExplosionRange

    mva #sfx_nuke sfx_effect
    SaveDrawXY 
    jsr xmissile
    UnSaveDrawXY
    sbw xdraw #34
    jsr CalculateExplosionRange
    mva #sfx_nuke sfx_effect 
    SaveDrawXY 
    jsr xmissile
    UnSaveDrawXY
    adw xdraw #68
    jsr CalculateExplosionRange
    mva #sfx_nuke sfx_effect 
    SaveDrawXY 
    jsr xmissile
    UnSaveDrawXY
    sbw xdraw #34
    ;
    sbw ydraw #34
    ;jsr CalculateExplosionRange
    cpw ydraw #screenHeight
    bcs NoUpperCircle
    mva #sfx_nuke sfx_effect 
    SaveDrawXY 
    jsr xmissile
    UnSaveDrawXY
NoUpperCircle
    adw ydraw #68
    ;jsr CalculateExplosionRange
    cpw ydraw #screenHeight
    bcs NoLowerCircle
    mva #sfx_nuke sfx_effect 
    SaveDrawXY 
    jsr xmissile
    UnSaveDrawXY
NoLowerCircle
    mva #sfx_silencer sfx_effect
    rts
.endp
.proc SaveDrawXY
    mwa xdraw tempXROLLER
    mwa ydraw modify
    rts
.endp
.proc UnSaveDrawXY
    mwa tempXROLLER xdraw
    mwa modify ydraw
    rts
.endp
; ------------------------
.proc napalm
    mva #sfx_napalm sfx_effect
    inc FallDown2
    mva #(napalmRadius+4) ExplosionRadius 	; real radius + 4 pixels (half characrer width)
    jsr CalculateExplosionRange
	mva #0 ExplosionRadius	; in this weapon - flag: 0 - napalm, 1 - hotnapalm
	jmp xnapalm
.endp
; ------------------------
.proc hotnapalm
    mva #sfx_napalm sfx_effect
    inc FallDown2
    mva #(napalmRadius+4) ExplosionRadius 	; real radius + 4 pixels (half characrer width)
    jsr CalculateExplosionRange
	mva #1 ExplosionRadius	; in this weapon - flag: 0 - napalm, 1 - hotnapalm
	jmp xnapalm
.endp
; ------------------------
.proc xnapalm
	mwa xdraw xcircle	; store hitpoint for future repeats
	ldy #30		; repeat 30 times
	sty magic	
RepeatNapalm	; external loop (for fire animation)
	mwa xcircle xdraw
	sbw xdraw #(napalmRadius)  ; 10 pixels on left side hit point
	ldy #0
	sty magic+1
RepeatFlame		; internal loop (draw flames)
	ldy #0
	adw xdraw #mountaintable temp
	sty ydraw+1
	lda (temp),y
	sec
	sbc #1	; over ground
	sta ydraw
	lda xdraw
	and ExplosionRadius	; if hotnapalm and x is odd:
	:2 asl	; modify y position 4 pixels up
	ldy ydraw
	sta ydraw
	tya
	sec
	sbc ydraw
	sta ydraw	
	sbw xdraw #4	; half character correction
	; draw flame symbol
	lda magic	; if last repeat - clear flames
	beq LastNapalmRepeat
	lda random
	and #%00000110
	clc
	adc #char_flame___________
	bne PutFlameChar
LastNapalmRepeat
	lda #char_clear_flame_____	; clear flame symbol
PutFlameChar
	sta CharCode
	; check coordinates
	cpw xdraw #(screenwidth-7)
	bcs CharOffTheScreen
	lda ydraw
	cmp #7
	bcc CharOffTheScreen
	cmp #(screenHeight-1)
	bcs CharOffTheScreen
	jsr TypeChar
CharOffTheScreen
	adw xdraw #4	; reverse half character correction (we need positon of character center)
	adw xdraw #1	; next char 1 pixels to right
	inc magic+1
	lda magic+1
	cmp #(2*napalmRadius+1)	; 10 pixels on left, 10 pixels on right and 1 in center
	jne RepeatFlame
	dec magic
	jpl RepeatNapalm
	; after napalm 
	inc FallDown2
;now we must check tanks in range
    ldx NumberOfPlayers
	dex
BurnedCheckLoop
    lda eXistenZ,x
    beq EndNurnedCheckLoop
    ;here the tank exist
	; calculate right edge of the fire
	adw xcircle #(napalmRadius+4+4) xdraw ; 10 pixels on right side hit point + half character width + correction
	; now we compare tank position with right edge of the fire (napalm)
    lda XtankstableH,x
	cmp xdraw+1
	bne @+
    lda XtankstableL,x
	cmp xdraw
@
	bcs TankOutOfFire
	; let's calculate left edge of the fire
	sbw xcircle #(napalmRadius+8+4-4) xdraw	; 10 pixels on left + character width (tank) + half character - correction
	bpl @+
	mwa #0 xdraw	; left screen edge
@
	; now we compare tank position with left edge of the fire (napalm)
    lda XtankstableH,x
	cmp xdraw+1
	bne @+
    lda XtankstableL,x
	cmp xdraw
@
	bcc TankOutOfFire

    ldy #40		; energy decrease (napalm) - but if hotnapalm:
	lda ExplosionRadius
	beq NotHot
	ldy #80		; energy decrease (hotnapalm)
NotHot
	; check shields ( joke :) )
    jsr DecreaseEnergyX
TankOutOfFire
EndNurnedCheckLoop
    dex
    bpl BurnedCheckLoop
    mva #sfx_silencer sfx_effect
	rts
.endp
; ------------------------
.proc babyroller
    inc FallDown2
    mva #11 ExplosionRadius
    jmp xroller
.endp
; ------------------------
.proc roller ;
    inc FallDown2
    mva #21 ExplosionRadius
    jmp xroller
.endp
; ------------------------
.proc heavyroller
    inc FallDown2
    mva #30 ExplosionRadius
    jmp xroller
.endp
; ------------------------
.proc riotbomb
    inc FallDown2
    mva #17 ExplosionRadius
    jsr CalculateExplosionRange
    jmp xriotbomb
.endp
; ------------------------
.proc heavyriotbomb
    inc FallDown2
    mva #29 ExplosionRadius
    jsr CalculateExplosionRange
    jmp xriotbomb
.endp
; ------------------------
.proc babydigger
    mva #sfx_digger sfx_effect
    mva #0 sandhogflag
    inc FallDown2
    mva #13 DigLong
    mva #1 diggery  ; how many branches (-1)
    jmp xdigger
.endp
; ------------------------
.proc digger ;
    mva #sfx_digger sfx_effect
    mva #0 sandhogflag
    inc FallDown2
    mva #13 DigLong
    mva #3 diggery  ; how many branches (-1)
    jmp xdigger
.endp
; ------------------------
.proc heavydigger
    mva #sfx_digger sfx_effect
    mva #0 sandhogflag
    inc FallDown2
    mva #13 DigLong
    mva #7 diggery  ; how many branches  (-1)
    jmp xdigger
.endp
; ------------------------
.proc xdigger
    ;mwa xdraw digstartx
    ;mwa ydraw digstarty
    ldx diggery
WriteToBranches
    lda xdraw
    sta digtabxL,x
    lda xdraw+1
    sta digtabxH,x
    lda ydraw
    sta digtabyL,x
    lda ydraw+1
    sta digtabyH,x
    dex
    bpl WriteToBranches
    jsr DiggerCharacter ; start character

    adw xdraw #4
    lda DigLong
    ; looks strange, but it is (DigLong+2)*4
    clc
    adc #$2
    asl
    asl
    sta ExplosionRadius
    jsr CalculateExplosionRange
BranchNotFinished
    ldx diggery
CalculateBranches
    txa
    and #$01
    bne DigRight
diglewy ; even branches go left
    sec
    lda digtabxL,x
    sbc #$04
    sta digtabxL,x
    lda digtabxH,x
    sbc #$00
    sta digtabxH,x
    jmp DigRandomize
DigRight ; odd go right (everytime 4 pixels)
    clc
    lda digtabxL,x
    adc #$04
    sta digtabxL,x
    lda digtabxH,x
    adc #$00
    sta digtabxH,x
DigRandomize
    lda random
    and #$87
    bmi DigUp
DigDown
    and #$07
    clc
    adc digtabyL,x
    sta digtabyL,x
    lda digtabyH,x
    adc #$00
    sta digtabyH,x
    ;crashing bug here - if too much added to digtaby, it gets over screenheight and starts writing over random areas
    ;WARNING! fix for 1 byte screenheight. TODO
    lda digtabyL,x
    cmp #screenheight
    bcc @+ ; branch if less
      lda #screenheight-1
      sta digtabyL,x
@   jmp DigCalculateNext
DigUp
    and #$07
    sta temp
    sec
    lda digtabyL,x
    sbc temp
    sta digtabyL,x
    lda digtabyH,x
    sbc #$00
    sta digtabyH,x
DigCalculateNext
    dex
    bpl CalculateBranches
    ; here we draw...
    ldx diggery
DigDrawing
    lda digtabxL,x
    sta xdraw
    lda digtabxH,x
    sta xdraw+1
    lda digtabyL,x
    sta ydraw
    lda digtabyH,x
    sta ydraw+1
    phx
    jsr DiggerCharacter
    plx
    dex
    bpl DigDrawing
    dec:lda DigLong
    jpl BranchNotFinished
DoNotPutDig
    mva #sfx_silencer sfx_effect
    rts
DiggerCharacter
    lda random
    and #$06
    clc
    adc #char_digger__________
    adc sandhogflag
    sta CharCode
    cpw xdraw #(screenwidth-6)
    bcs DoNotPutDig
    jmp TypeChar
.endp
; ------------------------
.proc babysandhog
    mva #sfx_sandhog sfx_effect
    mva #char_sandhog_offset sandhogflag
    inc FallDown2
    mva #13 DigLong
    mva #1 diggery  ; how many branches (-1)
    jmp xdigger
.endp
; ------------------------
.proc sandhog
    mva #sfx_sandhog sfx_effect
    mva #char_sandhog_offset sandhogflag
    inc FallDown2
    mva #13 DigLong
    mva #3 diggery  ; how many branches (-1)
    jmp xdigger
.endp
; ------------------------
.proc heavysandhog
    mva #sfx_sandhog sfx_effect
    mva #char_sandhog_offset sandhogflag
    inc FallDown2
    mva #13 DigLong
    mva #5 diggery  ; how many branches (-1)
    jmp xdigger
.endp
; ------------------------
.proc dirtclod
    inc FallDown2
    mva #12 ExplosionRadius
    jsr CalculateExplosionRange
    jmp xdirt
.endp
; ------------------------
.proc dirtball
    inc FallDown2
    mva #22 ExplosionRadius
    jsr CalculateExplosionRange
    jmp xdirt
.endp
; ------------------------
.proc tonofdirt
    inc FallDown2
    mva #31 ExplosionRadius
    jsr CalculateExplosionRange
    jmp xdirt
.endp
; ------------------------
.proc dirtcharge
    inc FallDown2
    mva #61 ExplosionRadius
    jsr CalculateExplosionRange
    jmp ofdirt
.endp
; ------------------------
.proc riotcharge
    mva #sfx_riot_blast sfx_effect
    inc FallDown2
    mva #31 ExplosionRadius
    jsr CalculateExplosionRange
    jmp cleanDirt
.endp
; ------------------------
.proc riotblast
    mva #sfx_riot_blast sfx_effect
    inc FallDown2
    mva #61 ExplosionRadius
    jsr CalculateExplosionRange
    jmp cleanDirt
.endp
; ------------------------
.proc liquiddirt
    mva #sfx_liquid_dirt sfx_effect
	mwa #254 FillCounter
	jmp xliquiddirt
.endp
; ------------------------
.proc laser
; in xdraw and ydraw we have hit point coordinates
; from Shoot/Flight procedures (invisible flight)
; ------------------------
    ldx TankNr
    lda AngleTable,x
    tay
    
    mwa EndOfTheBarrelX xbyte
    mva EndOfTheBarrelY ybyte
    mva #0 ybyte+1
    
    ;clc
    ;lda xtankstableL,x
    ;adc EndOfTheBarrelX,y ; correction of the end of the barrel point (X)
    ;sta xbyte
    ;lda xtankstableH,x
    ;adc #0
    ;sta xbyte+1
    ;sec
    ;lda ytankstable,x
    ;sbc EndOfTheBarrelY,y ; correction of the end of the barrel point (Y)
    ;sta ybyte
	;lda #$00
	;sbc #$00
    ;sta ybyte+1

    mwa xdraw LaserCoordinate
    mwa ydraw LaserCoordinate+2
    mwa xbyte LaserCoordinate+4
    mwa ybyte LaserCoordinate+6

    mva #sfx_lightning sfx_effect
	
    mva #%10000000 drawFunction
    ;the above switches Draw to measuring length
    jsr draw
    mva #0 drawFunction
	lsr LineLength+1	; LineLength / 8
	ror LineLength
	lsr LineLength 	; max line lenght is about 380 (9 bits)
	lsr LineLength
	sec
	lda #60
	sbc LineLength
	sta yc  ; laser blink counter 60-(LineLength/8)
@
      lda yc
	  and #$01
	  eor #$01
      sta color
        mwa LaserCoordinate xdraw
        mwa LaserCoordinate+2 ydraw
        mwa LaserCoordinate+4 xbyte
        mwa LaserCoordinate+6 ybyte
		mva #sfx_lightning sfx_effect
      jsr draw

    dec yc
    bne @-
        
    mva #1 color
    mwa LaserCoordinate xdraw
    mwa LaserCoordinate+2 ydraw
    mva #0 HitFlag
    jsr CheckCollisionWithTank
    lda HitFlag
    beq LaserMisses
    ; here we hit a tank (X)
    ldy #100
    jsr DecreaseEnergyX
LaserMisses
    rts
.endp
; -----------------
.proc xmissile ;
; -----------------
    lda #1
    sta radius
    sta color
ExplosionLoop
    jsr circle
    :2 inc radius
    lda radius
    cmp ExplosionRadius
    bcc ExplosionLoop

    ldx #0
    stx color
    inx
    stx radius
ExplosionLoop2
    jsr circle
    inc radius
    lda radius
    cmp ExplosionRadius
    bcc ExplosionLoop2

    mva #1 color
        
;check tanks' distance from the centre of the explosion

    mva #%10000000 drawFunction
    ;the above switches Draw to measuring length
    ;trick is easy - how many pixels does it take to draw
    ;a line from one point to another
    ;it must be somehow easier than regular Pitagoras
    ;calculation

    ldx NumberOfPlayers
	dex
DistanceCheckLoop
    lda eXistenZ,x
    jeq EndOfDistanceCheckLoop
    ;here the tank exist
    lda XtankstableL,x
    clc
    adc #3  ;measure from middle of the tank
    sta xbyte
    lda XtankstableH,x
    clc
    adc #0  ;measure from middle of the tank
    sta xbyte+1
    lda Ytankstable,x
    sec
    sbc #2  ;measure from middle of the tank
    sta ybyte
    lda #0
    sta ybyte+1
    phx
    jsr draw
    plx
    ;if tank within range of the explosion?
    lda LineLength+1
    bne TankIsNotWithinTheRange
    lda LineLength
    cmp ExplosionRadius
    bcs TankIsNotWithinTheRange
    lda ExplosionRadius
    sec
    sbc LineLength
    ;multiply difference by 8
    clc
    adc #1
    :3 asl
    tay
	; check shields
	lda ActiveDefenceWeapon,x
	cmp #ind_Shield_________		; one hit shield
	beq UseShield
	cmp #ind_Force_Shield___		; shield with energy and parachute
	beq UseShieldWithEnergy
	cmp #ind_Heavy_Shield___		; shield with energy
	beq UseShieldWithEnergy
	cmp #ind_Bouncy_Castle__		; Auto Defence (it works only if hit ground next to tank. Tank hit is handled in Flight proc)
	beq UseShieldWithEnergy
	cmp #ind_Mag_Deflector__		; Mag deflector  (it works only if hit ground next to tank. Tank hit is handled in Flight proc)
	beq UseShieldWithEnergy
    jsr DecreaseEnergyX
	jmp EndOfDistanceCheckLoop
UseShieldWithEnergy
	jsr DecreaseShieldEnergyX
	cpy #0	; is necessary to reduce tenk energy ?
	beq ShieldCoveredTank
    jsr DecreaseEnergyX
ShieldCoveredTank	
	lda ShieldEnergy,x
	jne EndOfDistanceCheckLoop
ShieldEnergy0	; deactivate if no energy. it's like use one hit shield :) 
UseShield
	mva #1 Erase
	lda TankNr
	pha			; store TankNr
	stx TankNr	; store X in TankNr :)
	jsr DrawTankNr	; now erase tank with shield (to erase shield)
	lda #0
	sta ActiveDefenceWeapon,x	; deactivate defense weapons
	sta Erase
	jsr DrawTankNr	; draw tank without shield
	ldx TankNr	; restore X value :)
	pla
	sta TankNr	; restore TankNr value :)
TankIsNotWithinTheRange
EndOfDistanceCheckLoop
    dex
    jpl DistanceCheckLoop
    mva #sfx_silencer sfx_effect
    rts
.endp
; -----------------
.proc xdirt ;
; -----------------
    mva #sfx_dirt_charge sfx_effect
    lda #1
    sta radius
    sta color
dirtLoop
    jsr circle
    inw ydraw
    jsr circle
.nowarn    dew ydraw
    inc radius
    lda radius
    cmp ExplosionRadius
    bne dirtLoop
    rts
.endp
; -----------------
.proc xriotbomb ;
; -----------------
    mva #sfx_riot_blast sfx_effect
    lda #0
    sta radius
    sta color
rbombLoop
    jsr circle
    inc radius
    lda radius
    cmp ExplosionRadius
    bne rbombLoop
    mva #1 color
    rts
.endp
; ----------------
.proc xroller ;
    ; now collisions are detected with modified draw routine
    ; therefore YDRAW value must be taken from mountaintable
	jsr checkRollDirection
	; HowMuchToFall - direction
    ; $FF - we are in a hole (flying in missile direction)
    ; 1 - right, 2 - left
Rollin
    mva #sfx_shield_off sfx_effect
    adw xdraw #mountaintable tempXROLLER
    ldy #0
    lda (tempXROLLER),y
    sta HeightRol ; relative point

RollinContinues
    jsr WaitOneFrame
    jsr WaitOneFrame
    ; new point is set
    adw xdraw #mountaintable tempXROLLER
    ldy #0
    lda (tempXROLLER),y
    sta ydraw
	sty ydraw+1
    beq ExplodeNow
    cmp HeightRol
    beq UpNotYet
    bcc ExplodeNow
UpNotYet
    sec ;clc
    sta HeightRol
    sbc #1
    sta ydraw
    ;check tank collision prior to PLOT
    sty HitFlag		; set to 0

    jsr CheckCollisionWithTank

    lda HitFlag
    bne ExplodeNow
    jsr unPlot
    ; let's go the right direction
    lda HowMuchToFall
    cmp #1
    beq HowMuchToFallRight2
.nowarn    dew xdraw
    lda xdraw
	ora xdraw+1
    jne RollinContinues		; like cpw xdraw #0
    beq ExplodeNow
HowMuchToFallRight2
    inw xdraw
    cpw xdraw #screenwidth
    jne RollinContinues
ExplodeNow
    mwa xdraw xcircle  ; we must store somewhere (BAD)
    mwa ydraw ycircle  ; xdraw and ydraw (BAD)
    mwa #0 xdraw
    mwa #screenheight-1 ydraw
    jsr unPlot
    mwa xcircle xdraw ;(bad)
    mwa ycircle ydraw ;(bad)

    ; finally a little explosion
    jsr CalculateExplosionRange
    mva #sfx_baby_missile sfx_effect
    jmp xmissile
    rts
.endp
; --------------------------------------------------
.proc checkRollDirection
; check rolling direction (for roller and other rolling weapons)
    ldy #0
    mwa #mountaintable tempXROLLER

    adw tempXROLLER xdraw
    lda (tempXROLLER),y
    sta ydraw
	sty ydraw+1

    lda vx+3
    ; if horizontal velocity is negative then change the direction
    bpl PositiveVelocity
    lda goleft
    ora #$01
    sta goleft
PositiveVelocity
    ; first we look for the left slope
    ; then righ slope and set the flag
    ; $FF - we are in a hole (flying in missile direction)
    ; 1 - right, 2 - left
    mva #$ff HowMuchToFall
    mva ydraw HeightRol
    ;mwa #mountaintable tempXROLLER - It's already done  !!!
    ;adw tempXROLLER xdraw
SeekLeft
	cpw tempXROLLER #mountaintable
    beq GoRightNow		; "bounce" if we have on left end
.nowarn    dew tempXROLLER
    lda (tempXROLLER),y    ;fukk! beware of Y value
    cmp HeightRol
    bne HowMuchToFallLeft
HowMuchToFallLeft
    bcs GoRightNow
    mva #1 HowMuchToFall
GoRightNow
    mwa #mountaintable tempXROLLER
    adw tempXROLLER xdraw
SeekRight
	cpw tempXROLLER #(mountaintable+screenwidth)
    beq HowMuchToFallKnown	; "stop" if we have on left end
    inw tempXROLLER
    lda (tempXROLLER),y
    cmp HeightRol
    bne HowMuchToFallRight
HowMuchToFallRight
    ; check if up or down
    bcs HowMuchToFallKnown
    lda HowMuchToFall
    bpl ItIsLeftAlready
    mva #2 HowMuchToFall
    bne HowMuchToFallKnown
ItIsLeftAlready
    mva #$ff HowMuchToFall
HowMuchToFallKnown
    lda HowMuchToFall
    bpl DirectionChecked
    lda #1
    clc
    adc goleft
    sta HowMuchToFall
DirectionChecked
	rts
.endp

; --------------------------------------------------
.proc cleanDirt
    mva #0 color
    jmp ofdirt.NoColor
.endp
; --------------------------------------------------
.proc ofdirt ;
; --------------------------------------------------
; makes dirt on xdraw,ydraw position and of ExplosionRadius height
    mva #sfx_dirt_chrg_s sfx_effect
    
    mva #1 color
NoColor ; jump here with color=0 to clean dirt
    mwa xdraw xcircle
    mwa ydraw ycircle
    lda #1
; current dirt width
    sta magic
NextRow
    jsr WaitOneFrame
    ldy magic
NextLine
    lda random
    and #$01
    beq DoNotPlot
    sty magic+1
    jsr plot
    ldy magic+1
DoNotPlot
    inw xdraw
    dey
    bne NextLine
    dec ydraw     ; 1 line up
    lda ydraw
    cmp #$ff
    beq EndOfTheDirt ;if horizontal Counter wraps
    inc magic  ; width+2
    inc magic
    lda magic
    sta magic+1   ; just for a second
    lsr magic+1
    sec
    lda xcircle
    sbc magic+1
    sta xdraw
    lda xcircle+1
    sbc #0
    sta xdraw+1   ; new starting coordinate in a given row
    dec ExplosionRadius
    bne NextRow
EndOfTheDirt
    mwa xcircle xdraw
    mwa ycircle ydraw
    rts
.endp
; ----------------
.proc xliquiddirt ;
	mwa xdraw TempXfill
RepeatFill
	mwa TempXfill xdraw
	jsr checkRollDirection
	; HowMuchToFall - direction
    ; $FF - we are in a hole (flying in missile direction)
    ; 1 - right, 2 - left
    adw xdraw #mountaintable tempXROLLER
    ldy #0
    lda (tempXROLLER),y
    sta HeightRol ; relative point
 
RollinContinuesLiquid
    ; new point is set
    adw xdraw #mountaintable tempXROLLER
    ldy #0
    lda (tempXROLLER),y
    sta ydraw
    cmp HeightRol
    beq UpNotYet2
    bcc FillNow
UpNotYet2
    sec ;clc
    sta HeightRol
    sbc #1
    sta ydraw
    lda HowMuchToFall
    cmp #1
    beq HowMuchToFallRight3
.NOWARN    dew xdraw
	lda xdraw
	and xdraw+1
	cmp #$ff ; like cpw xdraw #$ffff
    jne RollinContinuesLiquid
    beq FillNow
HowMuchToFallRight3
    inw xdraw
    cpw xdraw #(screenwidth+1)
    jne RollinContinuesLiquid
FillNow
     ; finally one pixel more
    ldy #0
	lda HowMuchToFall
	bmi FillHole
	cmp#1
	beq FillLeft
	inw xdraw
	inw xdraw	; tricky but we must rollback xdraw in proper direction
FillLeft
.nowarn	dew xdraw
FillHole
    adw xdraw #mountaintable tempXROLLER
	lda (tempXROLLER),y
	sta ydraw
	beq ToHighFill	; if we filled all playfield (very rare but possible)
	dec ydraw	; one pixel up
ToHighFill
	lda ydraw
    sta (tempXROLLER),y	;mountaintable update
	mva #1 color
	jsr plot.MakePlot
.nowarn dew FillCounter
	cpw FillCounter #0
	jne RepeatFill
    rts
.endp
;--------------------------------------------------
.proc BeforeFire ;TankNr (byte)
;--------------------------------------------------
;this nice routine makes the whole shooting
;preparation: aiming and displaying
;angle and shooting force values
;

;first, get current parameters (angle+force)
;for an active tank and display them
;(these values are taken from the previous round)
	mva #0 Erase

    ldx TankNr

    ;Checking the maximal force
    lda MaxForceTableH,x
    cmp ForceTableH,x
    bne ContinueToCheckMaxForce2
    lda MaxForceTableL,x
    cmp ForceTableL,x
ContinueToCheckMaxForce2
    bcs @+
      lda MaxForceTableH,x
      sta ForceTableH,x
      lda MaxForceTableL,x
      sta ForceTableL,x
@
    jsr DisplayStatus ;all digital values like force, angle, wind, etc.
    jsr PutTankNameOnScreen

    jsr DrawTankNr

    jsr WaitOneFrame ; best after drawing a tank

    

;keyboard reading
; KBCODE keeps code of last keybi
; SKSTAT  $ff - nothing pressed
;  $FB - any key
;  $f7 - shift
;  $f3 - shift+key

notpressed
    lda SKSTAT
    cmp #$ff
    jeq checkJoy
    cmp #$f7  ; SHIFT
    jeq checkJoy

    lda kbcode
    and #%10111111 ; SHIFT elimination

    cmp #$08  ; O
    bne @+
    jsr AreYouSure
    bit escFlag
    bpl notpressed
    ;---O pressed-quit game to game over screen---
	mva #$40 escFlag
    rts
@
    cmp #28  ; ESC
    bne @+
    jsr AreYouSure
    bit escFlag
    bpl notpressed
    ;---esc pressed-quit game---
    rts

@
    cmp #$0d  ; I
    bne @+
callInventory
    ; Hide all tanks - after inventory they may have other shapes
    mva #1 Erase
    jsr DrawTanks
    mva #0 Erase
	;
    mva #$ff isInventory
    jsr Purchase
	mva #0 dmactls		; dark screen
	jsr WaitOneFrame	
    lda #song_ingame
    jsr RmtSongSelect
    mva #0 escFlag
    jsr DisplayStatus
    jsr SetMainScreen   
    jsr WaitOneFrame
    jsr DrawTanks
    jsr WaitForKeyRelease
    jmp BeforeFire   
@
    cmp #$8e
    jeq CTRLPressedUp
    cmp #$8f
    jeq CTRLPressedDown
    cmp #$ac
    jeq CTRLPressedTAB

    and #$3f ;CTRL and SHIFT ellimination
jumpFromStick
    cmp #$e
    jeq pressedUp
    cmp #$f
    jeq pressedDown
    cmp #$6
    jeq pressedLeft
    cmp #$7
    jeq pressedRight
    cmp #$21
    jeq pressedSpace
    cmp #$2c
    jeq pressedTAB
    cmp #$25  ; M
    jeq pressedM
    cmp #$3e  ; S
    jeq pressedS
    jmp notpressed
checkJoy
    ;------------JOY-------------
    ;happy happy joy joy
    ;check for joystick now
    lda STICK0
    and #$0f
    cmp #$0f
    beq notpressedJoy
    tay 
    lda joyToKeyTable,y
    jmp jumpFromStick
notpressedJoy
    ;fire
    lda STRIG0
    jeq pressedSpace
    mva #$ff pressTimer  ; stop counting frames
   jmp notpressed

;
pressedUp
    lda pressTimer
    spl:mva #0 pressTimer  ; if >128 then reset to 0
    cmp #25  ; 1/2s
    bcs CTRLPressedUp
    
    
    ;force increaseeee!
    ldx TankNr
    inc ForceTableL,x
    bne CheckingMaxForce
    inc ForceTableH,x
CheckingMaxForce

    mva #sfx_set_power_1 sfx_effect

    lda MaxForceTableH,x
    cmp ForceTableH,x
    bne FurtherCheckMaxForce
    lda MaxForceTableL,x
    cmp ForceTableL,x
FurtherCheckMaxForce
    jcs BeforeFire

    lda MaxForceTableH,x
    sta ForceTableH,x
    lda MaxForceTableL,x
    sta ForceTableL,x

    jmp BeforeFire

CTRLPressedUp
    ldx TankNr
    lda ForceTableL,x
    clc
    adc #10
    sta ForceTableL,x
    bcc CheckingMaxForce
    inc ForceTableH,x
    jmp CheckingMaxForce


pressedDown
    lda pressTimer
    spl:mva #0 pressTimer  ; if >128 then reset to 0
    cmp #25  ; 1/2s
    bcs CTRLPressedDown

    mva #sfx_set_power_1 sfx_effect

    ldx TankNr
    dec ForceTableL,x
    lda ForceTableL,x
    cmp #$ff
    bne @+
      dec ForceTableH,x
      bpl @+
ForceGoesZero
      lda #0
      sta ForceTableH,x
      sta ForceTableL,x
@
    jmp BeforeFire

CTRLPressedDown
    mva #sfx_set_power_1 sfx_effect

    ldx TankNr
    sec
    lda ForceTableL,x
    sbc #10
    sta ForceTableL,x
    jcs BeforeFire
    dec ForceTableH,x
    bmi ForceGoesZero
    jmp BeforeFire

pressedRight
    ldx TankNr
    lda pressTimer
    spl:mva #0 pressTimer  ; if >128 then reset to 0
    cmp #25  ; 1/2s
    bcs CTRLPressedRight

    mva #sfx_set_power_2 sfx_effect
	mva #1 Erase
	jsr DrawTankNr.BarrelChange
    dec AngleTable,x
    lda AngleTable,x
    cmp #255 ; -1
    jne BeforeFire
    lda #179
    sta AngleTable,x
    jmp BeforeFire

CTRLPressedRight
    ldx TankNr
    mva #sfx_set_power_2 sfx_effect
	mva #1 Erase
	jsr DrawTankNr.BarrelChange
    lda AngleTable,x
    sec
    sbc #4
    sta AngleTable,x
    cmp #4  ; smallest angle for speed rotating
    jcs BeforeFire
    lda #179
    sta AngleTable,x
    jmp BeforeFire
        

pressedLeft
    ldx TankNr
    lda pressTimer
    spl:mva #0 pressTimer  ; if >128 then reset to 0
    cmp #25  ; 1/2s
    bcs CTRLPressedLeft

    mva #sfx_set_power_2 sfx_effect
	mva #1 Erase
	jsr DrawTankNr.BarrelChange
    INC AngleTable,x
    lda AngleTable,x
    cmp #180
    jne BeforeFire
    lda #1
    sta AngleTable,x
    jmp BeforeFire

CTRLPressedLeft
    ldx TankNr
    mva #sfx_set_power_2 sfx_effect
	mva #1 Erase
	jsr DrawTankNr.BarrelChange
    lda AngleTable,x
    clc
    adc #4
    sta AngleTable,x
    cmp #180-4
    jcc BeforeFire
    lda #1
    sta AngleTable,x
    jmp BeforeFire

pressedTAB
    mva #sfx_purchase sfx_effect
    ldx TankNr
    inc ActiveWeapon,x
    lda ActiveWeapon,x
    cmp #$30 ; number of offensive weapons
    bne @+
      lda #0
      sta ActiveWeapon,x
@
    lda ActiveWeapon,x
    jsr HowManyBullets ; and we have qty of owned shells. Ufff....
    beq pressedTAB
    jsr WaitForKeyRelease
    jmp BeforeFire

CTRLpressedTAB
    ldx TankNr
    dec ActiveWeapon,x
    bpl @+
      lda #$2f ; the last possible offensive weapon
      sta ActiveWeapon,x
@
    lda ActiveWeapon,x
    jsr HowManyBullets ; and we have qty of owned shells. Ufff....
    beq CTRLpressedTAB
    jsr WaitForKeyRelease
    jmp BeforeFire

pressedM
    ; have you tried turning the music off and on again?
    lda #$ff
    eor:sta noMusic
    lda #song_ingame
    jsr RmtSongSelect
    jsr WaitForKeyRelease
    jmp BeforeFire

pressedS
    ; have you tried turning sfx off and on again?
    lda #$ff
    eor:sta noSfx
    jsr WaitForKeyRelease
    jmp BeforeFire


pressedSpace
    ;=================================
    ;we shoot here!!!

    mva #0 pressTimer ; reset
    jsr WaitForKeyRelease
    lda pressTimer
    cmp #25  ; 1/2s
    bcc fire
    jmp callInventory
fire
    RTS
.endp

;--------------------------------------------------
.proc Shoot  ;TankNr (byte)
;--------------------------------------------------
;it looks like this routine is too big -
;- more and more functions were being added...
;good idea would be to rewrite it completely
;with much more separate blocks, but you know -
;- do not touch it if it works...

;the latest addition to this routine is
;displaying offensive texts!

RandomizeOffensiveText
    lda random
    cmp #talk.NumberOfOffensiveTexts
    bcs RandomizeOffensiveText

    sta TextNumberOff
    ldy TankNr
    mva #1 plot4x4color
    jsr DisplayOffensiveTextNr

	mva #0 LaserFlag	; $ff - Laser
	ldx TankNr
	lda ActiveWeapon,x
	cmp #ind_Laser__________ ; laser
	bne NotStrongShoot
	; Laser: (not)very strong - invisible - shot for laser beam end coordinates
	mva #0 color
	lda #1
	sta Force
	sta Force+1
	mva #$ff LaserFlag	; $ff - Laser
	bne AfterStrongShoot
NotStrongShoot
    lda ForceTableL,x
    sta Force
    lda ForceTableH,x
    sta Force+1
    mva #sfx_shoot sfx_effect
AfterStrongShoot
    lda AngleTable,x
    sta Angle

    ; Shoots tank nr X !!! :)
    ; set the starting coordinates of bullet with correction
    ; to start where the tank's barrel ends
    ; (without it bullet would go from the left lower corner of the tank)
    ;ldx TankNr
	
	mwa EndOfTheBarrelX xtraj+1
	mva EndOfTheBarrely ytraj+1
    lda #0
    sta Force+2
	sta ytraj+2
    sta xtraj
    sta ytraj
	sta TestFlightFlag

	; checking if the shot is underground (no Flight but Hit :) )
	tay	; A=0 !
	adw xtraj+1 #mountaintable temp
    lda ytraj+1
    cmp (temp),y	; check collision witch mountains
    bcs ShotUnderGround
    jsr Flight
    mva #1 color
    rts
ShotUnderGround
	mwa xtraj+1 xdraw	; but why not XHit and YHit !!!???
	mwa ytraj+1 ydraw
	mva #$ff HitFlag
	rts
.endp

;--------------------------------------------------
.proc Flight  ; Force(byte.byte), Wind(0.word)
; Angle(byte) 128=0, 255=maxright, 0=maxleft
; if TestFlightFlag is set ($ff) ne real flight - hit test only (for AI)
;--------------------------------------------------
;g=-0.1
;vx=Force*cos(Angle)
;vy=Force*sin(Angle)
;
;:begin
;ytraj=ytray-vy
;vy=vy-g
;xtraj=xtraj+vx - without Wind
;vx=vx+Wind (Wind is a small fraction)
;plot xtraj,ytraj - there is clearing in plot
;goto begin




; smoke tracer :)
    ldy #0
    ldx TankNr
    lda ActiveWeapon,x
    cmp #ind_Smoke_Tracer___ ; Smoke tracer
	bne noSmokeTracer
	iny
noSmokeTracer
	sty SmokeTracerFlag

RepeatIfSmokeTracer
RepeatFlight	
    mwa ytraj+1 Ytrajold+1
    mwa xtraj+1 Xtrajold+1
    mva #%01000000 drawFunction

    lda #0  
    sta vx
    sta vx+1
    sta vx+2
    sta HitFlag
    sta xdraw
    sta xdraw+1
    sta ydraw
    sta ydraw+1

    ;vx calculation
    ;vx = sin(90-Angle) for Angle <=90
    ;vx = -sin(Angle-90) for 90 < Angle <= 180 
    aslw Force ;Force = Force * 2

    ;cos(Angle) (but we use sin table only so some shenanigans happen)
    ldx Angle
    stx LeapFrogAngle ; we will need it later

    ;Angle works like this:
    ;0 'degrees' is horizontally right
    ;90 'degrees' is straight up
    ;180 horizontally left

    ; (we have to set goleft used in rolling weapons)
   
    cpx #91
    bcc angleUnder90
    
    ;over 90
    mva #1 goleft
    sec
    txa  ; lda # Angle
    sbc #90
    tax
    jmp @+

angleUnder90
    mva #0 goleft
    sec             ; X = 90-Angle
    lda #90
    sbc Angle
    tax
@    
    lda sintable,x  ; cos(X)
    sta Multiplee   ; *Force
    mwa Force Multiplier
    lda #$0
    sta Multiplier+2
    ldx #8
MultiplyLoop
    ror Multiplee
    bcc DoNotAdd
    clc
    lda Multiplier
    adc vx
    sta vx
    lda Multiplier+1
    adc vx+1
    sta vx+1
    lda Multiplier+2
    adc vx+2
    sta vx+2
DoNotAdd
    ;clc ;carry always cleared here (anyway we hope so :)
    rol Multiplier
    rol Multiplier+1
    rol Multiplier+2
    dex
    bne MultiplyLoop
    
    mva #0 vx+3
    ; here in vx there is a number 
    ; xxxx.xx00 = sin(Angle)*Force
    ; negate it if going left
    lda goleft
    beq @+
      .rept 4
        lda #$00
        sbc vx+#
        sta vx+#
      .endr
@
;======vy
    ;vy = sin(Angle) for Angle <=90
    ;vy = sin(180-Angle) for 90 < Angle <= 180

    lda #0  
    sta vy
    sta vy+1
    sta vy+2
;--
    ldx Angle
    cpx #91
    bcc YangleUnder90
    
    lda #180
    sec
    sbc Angle
    tax

YangleUnder90
    lda sintable,x

    sta Multiplee ;sin(Angle)*Force
    mwa Force Multiplier
    lda #$0
    sta Multiplier+2
    ldx #8
MultiplyLoopY
    ror Multiplee
    bcc DoNotAddY
    clc
    lda Multiplier
    adc vy
    sta vy
    lda Multiplier+1
    adc vy+1
    sta vy+1
    lda Multiplier+2
    adc vy+2
    sta vy+2
DoNotAddY
    ;clc ;carry always cleared here (anyway we hope so :)
    rol Multiplier
    rol Multiplier+1
    rol Multiplier+2
    dex
    bne MultiplyLoopY
    ; here in vy there is a number 
    ; yyyy.yy=cos(Angle)*Force

    mva #0 vy+3 ;vy=cos(Angle)*Force

Loopi
    ;ytraj=ytraj-vy (skipping least significant byte of vy)
    sec
    lda ytraj
    sbc vy+1
    sta ytraj
    lda ytraj+1
    sbc vy+2
    sta ytraj+1
    lda ytraj+2
    sbc vy+3
    sta ytraj+2

	bit LaserFlag	; no gravity if Laser
	bmi NoGravity
    ;vy=vy-g (again without least significant byte of vy)
    sec
    lda vy+1
    sbc gravity
    sta vy+1
    lda vy+2
    sbc #0
    sta vy+2
    lda vy+3
    sbc #0
    sta vy+3
    bpl StillUp
    ; where we know that the bullet starts to fall down
    ; we check if it is MIRV and if so, jump to MIRV routine
    ldx TankNr
    lda ActiveWeapon,x
    cmp #ind_MIRV___________ ; MIRV
    jeq MIRVdownLoop
NoGravity
StillUp

    clc ;xtraj=xtraj+vx (skipping least significant byte of vx)
    lda xtraj ;here of course Fight to right
    adc vx+1
    sta xtraj
    lda xtraj+1
    adc vx+2
    sta xtraj+1
    lda xtraj+2
    adc vx+3
    sta xtraj+2

	bit LaserFlag	; no wind if Laser
	bmi NoWind
    clc
    .rept 4
      lda vx+#
      adc Wind+#
      sta vx+#
    .endr
NoWind
    mwa xtrajold+1 xdraw
    mwa ytrajold+1 ydraw
    mwa xtraj+1 xbyte
    mwa ytraj+1 ybyte
    jsr draw
    ;key
    mwa xtraj+1 XtrajOld+1
    mwa ytraj+1 YtrajOld+1

	bit TestFlightFlag
	bmi nowait
    lda color
    beq nonowait	; smoke tracer erases slowly
    lda tracerflag	
    bne nowait		; funky bomb explotes fast ( tracerflag in real is funkyflag :) )
nonowait 
    jsr shellDelay
    
nowait
    lda HitFlag
    bne Hit
	; --- only for Laser
	bit LaserFlag
    bpl NoCheckEdgesForLaser
	; If laser fires, edges of the screen finish "flying" and laser hits.
	lda ytraj+2
	bmi LaserHitEdge
	cpw xtraj+1 #screenwidth+1
	bcc LaserNoHitEdge
LaserHitEdge
    mwa xdraw XHit
    mwa ydraw YHit
	mva #$ff HitFlag	; screen edgs like ground (only for Laser)
	jmp EndOfFlight
LaserNoHitEdge
	; ------------------
NoCheckEdgesForLaser

    cpw ytraj+1 #screenheight+1
    bcc YTrayLowerThanScreenHeight
    lda ytraj+2
    bpl EndOfFlight

YTrayLowerThanScreenHeight ; it means it is still on screen and not above

SkipCollisionCheck

    mwa xtraj+1 xdraw
    mwa ytraj+1 ydraw
	
	bit TestFlightFlag
	bmi NoUnPlot
    lda tracerflag
    bne NoUnPlot

    jsr UnPlot

NoUnPlot

    jmp Loopi

Hit
    mwa XHit xdraw
    mwa YHit ydraw
	bit TestFlightFlag
	bmi EndOfFlight
    jsr unPlot
EndOfFlight
    mwa xdraw xcircle  ; we must store for a little while
    mwa ydraw ycircle  ; xdraw and ydraw .... but this values are in YHit and XHit !!!
    mwa #0 xdraw
    mwa #screenheight-1 ydraw
    jsr unPlot
    mwa xcircle xdraw
    mwa ycircle ydraw

	ldy SmokeTracerFlag
	beq EndOfFlight2
	dey
	sty SmokeTracerFlag
	jmp SecondFlight
EndOfFlight2
	mva #0 tracerflag ;  don't know why
	
	bit TestFlightFlag
	jmi NoHitAtEndOfFight		; RTS only !!! - no defendsives check
	; and now check for defensive-aggressive weapon
	lda HitFlag
	jeq NoHitAtEndOfFight		; RTS only !!!
	jmi NoTankHitAtEndOfFight
	; tank hit - increase direct hits points
	ldx TankNr
	inx
	cpx HitFlag	; we don't count suicides :)
	beq @+
	dex
	inc DirectHitsL,x
	bne @+
	inc DirectHitsH,x
@
	; tank hit - check defensive weapon of this tank
	tax
	dex		; index of tank in X
	lda ActiveDefenceWeapon,x
	cmp #ind_Bouncy_Castle__		; Auto Defence
	jeq BouncyCastle
	cmp #ind_Mag_Deflector__		; Mag Deflector
	beq MagDeflector
	jmp NoDefence
MagDeflector
	; now run defensive-aggressive weapon - Mag Deflector!
	; get tank position
	clc
	lda xtankstableL,x
	adc #$04	; almost in tak center :)
	sta XHit
	lda xtankstableH,x
	adc #$00
	sta XHit+1
	lda #$ff	; change to ground hit (we hope)
	sta HitFlag
	bit random	; left or right deflection ?
	bpl RightDeflection
LeftDeflection
	sbw XHit #18	; 18 pixels to right and explode...
	bit XHit+1	; if off-screen ...
	bpl EndOfMagDeflector	; hit of course but we need RTS
	adw XHit #36	; change to right :)
	jmp EndOfMagDeflector
RightDeflection
	adw XHit #18	; 18 pixels to right and explode...
	cpw XHit screenwidth	; if off-screen ...
	bcs EndOfMagDeflector	; hit of course but we need RTS
	sbw XHit #36	; change to left
EndOfMagDeflector
	mva #1 Erase
	lda TankNr
	pha			; store TankNr
	stx TankNr	; store X in TankNr :)
	jsr DrawTankNr	; now erase tank with shield (to erase shield)
	lda #0
	sta ActiveDefenceWeapon,x	; deactivate used mag deflector weapon
	sta ShieldEnergy,x
	sta Erase
	jsr DrawTankNr	; draw tank without shield
	ldx TankNr	; restore X value :)
	pla
	sta TankNr	; restore TankNr value :)
	mwa XHit xdraw	; why? !!!
NoTankHitAtEndOfFight
NoHitAtEndOfFight
NoDefence
	lsrw Force	; Force = Force / 2 - because earlier we multiplied by 2
    rts		; END !!!	
BouncyCastle
    mva #sfx_shield_on sfx_effect
	; now run defensive-aggressive weapon - Bouncy Castle (previously known as Auto Defence)!
	sbb #180 LeapFrogAngle Angle	; swap angle (LeapFrogAngle - because we have strored angle in this variable)
	lsrw Force	; Force = Force / 2 - because earlier we multiplied by 2
	mva #1 Erase
	lda TankNr
	pha			; store TankNr
	stx TankNr	; store X in TankNr :)
	jsr DrawTankNr	; now erase tank with shield (to erase shield)
	lda #0
	sta ActiveDefenceWeapon,x	; deactivate used auto defense weapon
	sta ShieldEnergy,x
    sta xtraj		; prepare coordinates
    sta ytraj
	sta xtraj+2
	sta ytraj+2
	sta Erase
	jsr DrawTankNr	; draw tank without shield
	ldx TankNr	; restore X value :)
	pla
	sta TankNr	; restore TankNr value :)
	mwa XHit xtraj+1
	sbw YHit #5 ytraj+1
	mva #1 color
	jmp RepeatFlight		; and repeat Fight
.endp

.proc SecondFlight
; ---------------- copied code fragment from before firing. not too elegant.
; ---------------- get fire parameters again

	ldx TankNr
	lda ActiveWeapon,x
    lda ForceTableL,x
    sta Force
    lda ForceTableH,x
    sta Force+1
    lda AngleTable,x
    sta Angle

    ; Shoots tank nr X !!! :)
    ; set the starting coordinates of bullet with correction
    ; to start where the tank's barrel ends
    ; (without it bullet would go from the left lower corner of the tank)
    ;ldx TankNr
	
	mwa EndOfTheBarrelX xtraj+1
	mva EndOfTheBarrely ytraj+1
    lda #0
    sta Force+2
	sta ytraj+2
    sta xtraj
    sta ytraj
	sta color

	
    ldy #100           ; ???
	mva #1 tracerflag  ; I do not know (I mean I think I know ;) )
	                   ; 10 years later - I do not know!!!
                       ; 20 years later - still do not know :]
	jmp Flight.RepeatIfSmokeTracer
.endp

; -------------------------------------------------
.proc MIRVdownLoop
; MIRV loop - here mirv bullets fall down
; -------------------------------------------------
; copy Flight parameters to the table
    ldx #4
MIRVcopyParameters
    lda xtraj
    sta xtraj00,x
    lda xtraj+1
    sta xtraj01,x
    lda xtraj+2
    sta xtraj02,x
    ;lda vx
    ;sta vx00,x
    lda vx+1
    sta vx01,x
    lda vx+2
    sta vx02,x
    lda vx+3
    sta vx03,x
    lda #0
    sta MirvDown,x
    dex
    bpl MIRVcopyParameters
; modification (to make bullets "split away" and go different directions)
; bullet indexed 0 is in the middle

; bullet 1
    clc
    lda vx+1
    adc #100
    sta vx01+1
    lda vx+2
    adc #0
    sta vx02+1
    lda vx+3
    adc #0
    sta vx03+1
; bullet 2
    sec
    lda vx+1
    sbc #100
    sta vx01+2
    lda vx+2
    sbc #0
    sta vx02+2
    lda vx+3
    sbc #0
    sta vx03+2
; bullet 3
    clc
    lda vx+1
    adc #200
    sta vx01+3
    lda vx+2
    adc #0
    sta vx02+3
    lda vx+3
    adc #0
    sta vx03+3
; bullet 4
    sec
    lda vx+1
    sbc #200
    sta vx01+4
    lda vx+2
    sbc #0
    sta vx02+4
    lda vx+3
    sbc #0
    sta vx03+4

    ; clearing ranges of soil down registers
    mwa #screenwidth RangeLeft
    lda #0
    sta RangeRight
    sta RangeRight+1

    ldx #$FF ; it will turn 0 in a moment anyway
    stx MirvMissileCounter
mrLoopi
    inc:lda MirvMissileCounter
    cmp #5
    sne:mva #0 MirvMissileCounter

    ldx MirvMissileCounter
    ; Y changes only for bullet number 0
    ; because rest of the bullets have the same Y (height)

    bne MIRVdoNotChangeY
    ; Y is the same for all falling bullets
    ;ytraj=ytraj-vy (skipping least significant byte of vy)
    sec
    lda ytraj
    sbc vy+1
    sta ytraj
    lda ytraj+1
    sbc vy+2
    sta ytraj+1
    lda ytraj+2
    sbc vy+3
    sta ytraj+2

    ;vy=vy-g (also without least significant byte of vy)
    sec
    lda vy+1
    sbc gravity
    sta vy+1
    lda vy+2
    sbc #0
    sta vy+2
    lda vy+3
    sbc #0
    sta vy+3

    jsr ShellDelay
    
MIRVdoNotChangeY

    lda MirvDown,x ; if bullet is already down we go with the next one
    jne MIRVnextBullet

    clc ;xtraj=xtraj+vx (skipping the least significant byte of vx)
    lda xtraj00,x ;and here of course Flight to the right
    adc vx01,x
    sta xtraj00,x
    lda xtraj01,x
    adc vx02,x
    sta xtraj01,x
    lda xtraj02,x
    adc vx03,x
    sta xtraj02,x

    ;vx=vx+Wind

    clc
    .rept 4
      lda vx+#
      adc Wind+#
      sta vx+#
    .endr

	; rules for a falling MIRV bulets.
	; if Y is negative and any X (bullet over the screen) - continue flying
	; if (Y>=0 and Y<=screenhight) and X>screenwidth (bullet off-screen on the left or right side) - continue flying
	; if (Y>=0 and Y<=screenhight) and X<=screenwidth (bullet on the screen) - check collision
	; if Y>screenhight and X>screenwidth (bullet under the screen on the left or right side) - stop flying without hit
	; if Y>screenhight and X<=screenwidth (bullet under the screen) - check collision (allways hit)
	
	; check bullet position and set flags: 
	; XposFlag - bullet positon X (0 - on screen , %1000000 - off-screen)
	; YposFlag - bullet positon Y (0 - on screen , %1000000 - over the screen , %0100000 - under the screen)
	lda #$00
	sta XposFlag
	sta YposFlag
	lda ytraj+2		; Y high byte 
	bpl @+
	mva #%10000000 YposFlag	; bullet over the screen (Y)
	bmi MIRVsetXflag
@
	lda ytraj+1		; Y low byte
	cmp #screenheight
	bcc MIRVsetXflag	; bullet on screen (Y)
	mva #%01000000 YposFlag	; bullet under the screen (Y)
MIRVsetXflag
	lda xtraj02,x	; X high byte
    cmp #>screenwidth
	bne @+
    lda xtraj01,x	; X low byte
    cmp #<screenwidth
@
	bcc MIRVXonscreen
	mva #%10000000 XposFlag	; bullet off-screen (X)
MIRVXonscreen

	; X and Y position flags sets
	; then realize rules

	lda YposFlag
	jmi MIRVcontinueFly		; Y over the screen
	bne MIRVYunderscreen	; Y under the screen
	; Y on screen
	bit XposFlag
	jmi MIRVcontinueFly		; Y on screen and X off-screen
	jpl MIRVcheckCollision	; X and Y on screen
MIRVYunderscreen
	bit XposFlag
	jpl MIRVcheckCollision	; X on screen and Y under screen
	; Y under screen and X off-screen
	; stop flying
	jmi mrEndOfFlight

MIRVcontinueFly
    mwa #0 xdraw
    mwa #screenheight-1 ydraw
	bit XposFlag
	bmi @+	; no pixels to plot
	; plot bullets over the screen
	mwa #0 ydraw
    ;mwa xtraj01 xdraw
    lda xtraj01,x
    sta xdraw
    lda xtraj02,x
    sta xdraw+1
@
    jsr unPlot.unPlotAfterX
    jmp mrLoopi

MIRVcheckCollision

    ; checking works only with xdraw and ydraw so copy there all we need
    lda xtraj01,x
    sta xdraw
    lda xtraj02,x
    sta xdraw+1
    mwa ytraj+1 ydraw
    mva #0 HitFlag
    jsr CheckCollisionWithTank
    ldx MirvMissileCounter
    lda HitFlag
    bne mrHit

    ;mwa xtraj01 temp
    clc
    lda xtraj01,x
    adc #<mountaintable
    sta temp
    lda xtraj02,x
    adc #>mountaintable
    sta temp+1

    ldy #0
    lda ytraj+1
    cmp (temp),y	; check collision witch mountains
    bcs mrHit

mrSkipCollisionCheck
    ;mwa xtraj01 xdraw
    lda xtraj01,x
    sta xdraw
    lda xtraj02,x
    sta xdraw+1
    mwa ytraj+1 ydraw

    jsr unPlot.unPlotAfterX
    ldx MirvMissileCounter
    jne mrLoopi

    jmp mrLoopi

mrHit
    ; we have to make unPlot over the screen (to initialise it)
    ; before actual explosion
    mwa #0 xdraw
    mwa #screenheight-1 ydraw
    jsr unPlot.unPlotAfterX
    ldx MirvMissileCounter
    ldy #0
    ; concurrent moving xtraj+1 -> xdraw and calculating temp
    clc
    lda xtraj01,x
    sta xdraw
    adc #<mountaintable
    sta temp
    lda xtraj02,x
    sta xdraw+1
    adc #>mountaintable
    sta temp+1
    lda (temp),y
	sec
	sbc #1
    sta ydraw
    sty ydraw+1  ;we know that y=0
    jsr missile ; explode ....

mrEndOfFlight
    ldx MirvMissileCounter
    mwa #0 xdraw
    mwa #screenheight-1 ydraw
    jsr unPlot.unPlotAfterX
    ldx MirvMissileCounter
    lda #1
    sta MirvDown,x
MIRVnextBullet
    ; checking if all bullets already fallen down
    ldx #4
MIRVcheckIfEnd
    lda MirvDown,x
    beq MIRVstillNotAll
    dex
    bpl MIRVcheckIfEnd
    bmi MIRValreadyAll
MIRVstillNotAll
    jmp mrLoopi
MIRValreadyAll
    mwa xdraw xcircle  ; we must store them (for a while)
    mwa ydraw ycircle  ; xdraw and ydraw
    mwa #0 xdraw
    mwa #screenheight-1 ydraw
    ldx MirvMissileCounter
    jsr unPlot.unPlotAfterX
    mwa xcircle xdraw
    mwa ycircle ydraw

    ; we must do it manually because of the VOID pointer

    ;first clean the offensive text...
    ldy TankNr
    mva #0 plot4x4color
    jsr DisplayOffensiveTextNr

    ; temporary removing tanks from the screen (otherwise they will fall down with soil)
    mva TankNr tempor2
    mva #1 Erase
    jsr drawtanks
    mva tempor2 TankNr
    mva #0 Erase
    jsr SoilDown2
    mva #$ff HitFlag		; but why ??
    ;jsr drawtanks
    rts
.endp

; -------------------------------------------------
.proc WhiteFlag
; -------------------------------------------------
; This routine is run from inside of the main loop
; and replaces Shoot and Flight routines
; X and TankNr - index of shooting tank
; -------------------------------------------------
	mva #sfx_death_begin sfx_effect
	jsr FlashTank	; first we flash tank
	mva #1 Erase
	jsr DrawTankNr	; and erase tank
	lda #0
	sta Erase
	ldx TankNr
	sta Energy,x	; clear tank energy
	sta eXistenZ,x	; erase from existence
	sta LASTeXistenZ,x	; to prevent explosion
	sta ActiveDefenceWeapon,x	; deactivate White Flag
	jsr PMoutofScreen
	jsr drawtanks	; for restore PM
    mva #sfx_silencer sfx_effect
	rts
.endp

; -------------------------------------------------
.proc AtomicWinter
; -------------------------------------------------
; This routine is run from inside of the main loop
; and replaces Shoot and Flight routines
; X and TankNr - index of shooting tank
; -------------------------------------------------
    mva #sfx_sandhog sfx_effect
	ldy #0 		 	; byte counter (from 0 to 39)
NextColumn
	; big loop - we repat internal loops for each column of bytes
	sty magic
	ldx #120			; line counter (from 0 to 60 )
	; first loop - inverse column of bytes for a while
	ldy magic
NextLine1
	jsr InverseScreenByte
	dex
	dex
	bpl NextLine1
	;
	jsr WaitOneFrame	; wait uses A only
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
	; and we have "snow" :)
	lda #0
	ldx TankNr
	sta ActiveDefenceWeapon,x	; deactivate Nuclear Winter
	
	sta RangeLeft			; whole screen in range of soil down
	sta RangeLeft+1
	mwa #screenwidth RangeRight
    jsr SoilDown2
	jsr drawtanks	; for restore PM
	rts

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

; -------------------------------------------------
.proc TankFlying
; -------------------------------------------------
; This routine is run from inside of the main loop
; and replaces Shoot and Flight routines
; X and TankNr - index of flying tank
; -------------------------------------------------
	; Let's designate the flight altitude.
	mva #17 FloatingAlt	; for testing
;	mwa #mountaintable temp
    mva #sfx_plasma_2_2 sfx_effect

	; display text 4x4 - fuel full
    
    mwa #hoverFull LineAddress4x4
    mwa #((ScreenWidth/2)-((hoverFullEnd-hoverFull)*2)) LineXdraw  ; centering
    mva #4 LineYdraw
    jsr TypeLine4x4
	ldx TankNr
	
	; TankNr in X reg.
	; now animate Up
	mva #0 FloatingAlt	; now it's a counter 
TankGoUp
	lda ytankstable,x
	cmp #18		; Floating altitude
	bcc ReachSky
	; first erase old tank position
	mva #1 Erase
    jsr DrawTankNr
	lda FloatingAlt
	cmp #5
	bcc NoEngineClear
	mva #0 color
	jsr DrawTankRocketEngine
NoEngineClear
	mva #0 Erase
	dec ytankstable,x
	inc FloatingAlt
	; then draw tank on new position
    jsr DrawTankNr
	lda FloatingAlt
	cmp #5
	bcc NoEngine
	lda random
	and #%00000001
	sta color
	jsr DrawTankRocketEngine
NoEngine
;	jsr WaitOneFrame
	jmp TankGoUp
ReachSky
	; engine symbol erase
	mva #0 color
	jsr DrawTankRocketEngine

	; display text 4x4 - fuel full (clear text)
    mwa #hoverFull LineAddress4x4
    mwa #((ScreenWidth/2)-((hoverFullEnd-hoverFull)*2)) LineXdraw  ; centering
    mva #4 LineYdraw
    lda #0
    jsr TypeLine4x4.staplot4x4color
	ldx TankNr

	; check keyboard/joy and move tank left/right - code copied from BeforeFire
;keyboard reading
; KBCODE keeps code of last keybi
; SKSTAT  $ff - nothing pressed
;  $FB - any key
;  $f7 - shift
;  $f3 - shift+key
KeyboardAndJoyCheck
    mva #sfx_tank_move sfx_effect
	lda ShieldEnergy,x
	cmp #20
	bne notpressed
	nop
	
	; display text 4x4 - low fuel
    mwa #hoverEmpty LineAddress4x4
    mwa #((ScreenWidth/2)-((hoverEmptyEnd-hoverEmpty)*2)) LineXdraw  ; centering
    mva #4 LineYdraw
    ;lda #0
    jsr TypeLine4x4 ;.staplot4x4color
	ldx TankNr

	
notpressed
	; let's animate "engine"
	jsr DrawTankEngine
	; enimation ends
	
    lda SKSTAT
    cmp #$ff
    jeq checkJoy
    cmp #$f7  ; SHIFT
    jeq checkJoy

    lda kbcode
    and #%00111111 ; CTRL and SHIFT elimination

    cmp #28  ; ESC
    bne @+
    jsr AreYouSure
    bit escFlag
    bpl notpressed
    ;---esc pressed-quit game---
    rts
@
jumpFromStick
    cmp #$6
    jeq pressedLeft
    cmp #$7
    jeq pressedRight
    cmp #$21
    jeq pressedSpace
    jmp notpressed
checkJoy
    ;------------JOY-------------
    ;happy happy joy joy
    ;check for joystick now
    lda STICK0
    and #$0f
    cmp #$0f
    beq notpressedJoy
    tay 
    lda joyToKeyTable,y
    jmp jumpFromStick
notpressedJoy
    ;fire
    lda STRIG0
    jeq pressedSpace
    jmp notpressed


pressedRight
	lda ShieldEnergy,x
	jeq pressedSpace
	ldy #1
	jsr DecreaseShieldEnergyX
	; first erase old tank position
	mva #1 Erase
    jsr DrawTankNr
	mva #0 Erase
	lda XtankstableH,x
	cmp #>(screenwidth-12)	; tank width correction +4 
	bne @+
	lda XtankstableL,x
	cmp #<(screenwidth-12)	; tank width correction +4 pixels 
@	bcs RightScreenEdge	
	inc XtankstableL,x
	sne:inc XtankstableH,x
	jmp NoREdge
RightScreenEdge
    mva #sfx_dunno sfx_effect
NoREdge
	mva #18 AngleTable,x
	; then draw tank on new position
    jsr DrawTankNr
	jsr DisplayStatus
	jsr WaitOneFrame
    jmp KeyboardAndJoyCheck

pressedLeft
	lda ShieldEnergy,x
	beq pressedSpace
	ldy #1
	jsr DecreaseShieldEnergyX
	; first erase old tank position
	mva #1 Erase
    jsr DrawTankNr
	mva #0 Erase
	lda XtankstableH,x
	cmp #0
	bne @+
	lda XtankstableL,x
	cmp #5	; 4 pixles from left edge
@	bcc LeftScreenEdge
	dec XtankstableL,x
	lda XtankstableL,x
	cmp #$ff
	sne:dec XtankstableH,x
	jmp NoLEdge
LeftScreenEdge
    mva #sfx_dunno sfx_effect
NoLEdge
	mva #162 AngleTable,x
	; then draw tank on new position
    jsr DrawTankNr
	jsr DisplayStatus
	jsr WaitOneFrame
    jmp KeyboardAndJoyCheck

pressedSpace
    ;=================================
	; left or right from center of screen ?
	ldy #0
    lda XtankstableH,x
	cmp #>((screenwidth/2)-8)
	bne @+
    lda XtankstableL,x
	cmp #<((screenwidth/2)-8)
@	bcc TankOnLeftSide
TankOnRightSide
	dey
TankOnLeftSide
	sty FloatingAlt ; I know, not elegant byt this variable it's free now (0 go right, $ff go left)
	; now we have direction of bypassing tanks on screen

	; clear "engine pixels" under tank
    mva #1 erase
	jsr DrawTankEngine

CheckForTanksBelow
	lda XtankstableL,x
	sta xdraw
	lda XtankstableH,x
	sta xdraw+1
	ldx NumberOfPlayers
	dex
CheckCollisionWithTankLoop
	cpx TankNr
	beq ItIsMe
	lda eXistenZ,x
	beq DeadTank
	; now we use Y as low byte and A as high byte of checked position (left right edgs of shield)
	; it is tricky but fast and much shorter
    lda xtankstableL,x
	sec
	sbc #9		; 2 pixels more on left side + tan width
	tay
	lda xtankstableH,x
	sbc #0
	; bmi ShieldOverLeftEdge	; I do not know whether to check it. Probably not :) !!!
    cmp xdraw+1
    bne @+
    cpy xdraw
@
    bcs LeftFromTheTank 
	tya	;add 20 (tank size*2 +2 and +2)
    clc
    adc #20	
    tay
    lda xtankstableH,x
    adc #0
    cmp xdraw+1
    bne @+
    cpy xdraw
@
    bcc RightFromTheTank
TankBelow
	; tank below - we must move our tank
	ldx TankNr
	; first erase old tank position
	mva #1 Erase
    jsr DrawTankNr
	mva #0 Erase
	bit FloatingAlt
	bmi PassLeft
PassRight
	inc XtankstableL,x
	sne:inc XtankstableH,x
	mva #18 AngleTable,x
	bne Bypassing
PassLeft
	dec XtankstableL,x
	lda XtankstableL,x
	cmp #$ff
	sne:dec XtankstableH,x
	mva #162 AngleTable,x
Bypassing
	; then draw tank on new position
    jsr DrawTankNr
	jmp CheckForTanksBelow
RightFromTheTank
LeftFromTheTank
DeadTank
ItIsMe
    dex
    bpl CheckCollisionWithTankLoop
	ldx TankNr
    mva #sfx_shield_off sfx_effect
	mva #1 Erase
    jsr DrawTankNr
	mva #0 Erase
	lda XtankstableL,x
	and #%11111110		; correction for PM
	sta XtankstableL,x
GoDown

	; display text 4x4 - low fuel (clear text)
    mwa #hoverEmpty LineAddress4x4
    mwa #((ScreenWidth/2)-((hoverEmptyEnd-hoverEmpty)*2)) LineXdraw  ; centering
    mva #4 LineYdraw
    lda #0
    jsr TypeLine4x4.staplot4x4color
	ldx TankNr

	mwa #mountaintable temp
	clc
	lda temp
	adc XtankstableL,x
	sta temp
	lda temp+1
	adc XtankstableH,x
	sta temp+1
	adw temp #4 	;	center of the tank
	ldy #0
	lda (temp),y
	sta FloatingAlt
FloatDown
	lda ytankstable,x
	cmp FloatingAlt
	beq OnGround
	; first erase old tank position
	mva #1 Erase
    jsr DrawTankNr
    jsr DrawTankParachute
	mva #0 Erase
	inc ytankstable,x
	; then draw tank on new position
    jsr DrawTankNr
    jsr DrawTankParachute
	jsr WaitOneFrame
	jmp FloatDown
OnGround
	; clear parachute
	mva #1 Erase
    jsr DrawTankParachute
	mva #0 Erase
    jsr WaitForKeyRelease
	; and Soildown at the end (for correct mountaintable)
	; calculate range
	sec
	lda XtankstableL,x
	sbc #2
	sta RangeLeft
	lda XtankstableH,x
	sbc #0
	sta RangeLeft+1
	clc
	lda XtankstableL,x
	adc #10
	sta RangeRight
	lda XtankstableH,x
	adc #0
	sta RangeRight+1
	; hide tanks and ...
	mva #1 Erase
    jsr DrawTanks
	jsr SoilDown2
	mva #0 Erase
    jsr DrawTanks
	ldx TankNr
	rts
.endp

; -------------------------------------------------
.proc CheckCollisionWithTank
; -------------------------------------------------
; Check collision with Tank :)
; xdraw , ydraw - coordinates of the checked point
; results:
; HitFlag - $ff - hit ground, 0 - no hit, 1-6 - hit tank (index+1)
; XHit , YHit - coordinates of hit
; X - index of the hit tank

    ldx NumberOfPlayers
	dex
CheckCollisionWithTankLoop
	lda eXistenZ,x
	beq DeadTank
	; first we test top and bottom (same with and without shield!)
    lda ytankstable,x
    cmp ydraw  ; check range
    bcc BelowTheTank ;(ytankstable,ytankstable+3)
    sbc #4 ; we must rewrite EndOfTheBarrelY table or remove Y correction completely to "bold" tank !!!
    cmp ydraw
    bcs OverTheTank
	; with or without shield ?
	lda ShieldEnergy,x
	bne CheckCollisionWithShieldedTank	; tank with shield is bigger :)

    lda xtankstableH,x
    cmp xdraw+1
    bne @+
    lda xtankstableL,x
    cmp xdraw
@
    bcs LeftFromTheTank ;add 8 double byte
	; now we use Y as low byte and A as high byte of checked position (right edge of tank)
	; it is tricky but fast and much shorter
    clc
    adc #8
    tay
    lda xtankstableH,x
    adc #0
    cmp xdraw+1
    bne @+
    cpy xdraw
@
    bcc RightFromTheTank
TankHit
	inx
    stx HitFlag		; index of hit tank+1
	dex
    mwa xdraw XHit
    mwa ydraw YHit
    rts ; in X there is an index of the hit tank
RightFromTheTank
LeftFromTheTank
OverTheTank
BelowTheTank
DeadTank
    dex
    bpl CheckCollisionWithTankLoop
    rts
CheckCollisionWithShieldedTank
	; now we use Y as low byte and A as high byte of checked position (left right edgs of shield)
	; it is tricky but fast and much shorter
    lda xtankstableL,x
	sec
	sbc #4		; 5 pixels more on left side
	tay
	lda xtankstableH,x
	sbc #0
	; bmi ShieldOverLeftEdge	; I do not know whether to check it. Probably not :) !!!
    cmp xdraw+1
    bne @+
    cpy xdraw
@
    bcs LeftFromTheTank 
	tya	;add 16 double byte
    clc
    adc #16	
    tay
    lda xtankstableH,x
    adc #0
    cmp xdraw+1
    bne @+
    cpy xdraw
@
    bcc RightFromTheTank
	bcs TankHit
.endp
;--------------------------------------------------
CalculateExplosionRange0
;--------------------------------------------------

    ;the same as below, but without summing up
    ;(for the first or single explosion)

    ;zero soil fall out ranges
    mwa #screenwidth RangeLeft
    lda #0
    sta RangeRight
    sta RangeRight+1
;--------------------------------------------------
.proc CalculateExplosionRange
;--------------------------------------------------
;calculates total horizontal range of explosion by
;"summing up" ranges of all separate explosions

    adw xdraw ExplosionRadius WeaponRangeRight
    cpw WeaponRangeRight #screenwidth-1
    bcc NotOutOfTheScreenRight
    mwa #screenwidth-1 WeaponRangeRight

NotOutOfTheScreenRight
    sbw xdraw ExplosionRadius WeaponRangeLeft
    lda WeaponRangeLeft+1
    bpl NotOutOfTheScreenLeft
    lda #0
    sta WeaponRangeLeft
    sta WeaponRangeLeft+1
NotOutOfTheScreenLeft

    cpw RangeLeft WeaponRangeLeft
    bcc CheckRangeRight
    mwa WeaponRangeLeft RangeLeft
CheckRangeRight
    cpw RangeRight WeaponRangeRight
    bcs RangesChecked
    mwa WeaponRangeRight RangeRight
RangesChecked

    rts
.endp    
    
;--------------------------------------------------
.proc DecreaseWeaponBeforeShoot
;--------------------------------------------------
    ldx TankNr
    lda ActiveWeapon,x
    jsr DecreaseWeapon
    ; and here we have amount of possessed ammo for given weapon
    sta WeaponDepleted
;    ;cmp #0
;    bne AmmunitionDecreased
;      ;lda #0   ;if ammo for given weapon ends
;      sta ActiveWeapon,x ;then set to default weapon (baby missile)
;AmmunitionDecreased
;    lda #99
;    ldy #0
;    sta (weaponPointer),y  ;baby missile - always 99 pieces
;
;    ;there is a good value in weaponPointer after jsr DecreaseWeapon
;
    rts
.endp

;--------------------------------------------------
.proc DecreaseWeapon
; in: A: Weapon number, TankNr
; out: A: number of shells left, Y: weapon number
; decreases 1 bullet from a weapon(A) of tank(TankNr)
;--------------------------------------------------
    jsr HowManyBullets
	beq noBullets	 ; no bullets - no decreasing (additional check)
    cpy #0
    beq defaultWeapon  ; no decreasing Baby Missile
      sec
      sbc #1
      sta (weaponPointer),y ; we have good values after HowManyBullets
defaultWeapon
noBullets
    rts
.endp

;--------------------------------------------------
.proc HowManyBullets
; in: A <-- Weapon number, TankNr
; out: A <-- How many bullets in the weapon, Y: weapon number
; how many bullets weapon of tank(TankNr) has, Result in A 
;--------------------------------------------------
    tay
    ldx TankNr
    lda TanksWeaponsTableL,x
    sta weaponPointer
    lda TanksWeaponsTableH,x
    sta weaponPointer+1
    
    lda (weaponPointer),y  ; and we have number of bullets in A
    rts
.endp

;--------------------------------------------------
.proc ShellDelay
    lda CONSOL
    cmp #6
    beq noShellDelay
    ldx flyDelay
DelayLoop
      lda VCOUNT
@       cmp VCOUNT
      beq @-
      dex
    bne DelayLoop
noShellDelay
    rts
.endp
    
    .ENDIF
    