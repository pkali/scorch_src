;    @com.wudsn.ide.asm.mainsourcefile=scorch.asm

    .IF *>0 ;this is a trick that prevents compiling this file alone
;--------------------------------------------------
.proc Explosion
; xdraw,ydraw (word) - coordinates of explosion center
; TankNr - number of shooting tank
; ActiveWeapon(TankNr) - weapon that tank fires
;--------------------------------------------------
    ;cleanup of the soil fall down ranges (left and right)
    jsr ClearScreenSoilRange

    ldx TankNr
    lda ActiveWeapon,x
.endp
.proc ExplosionDirect
    asl
    tay
    lda ExplosionRoutines+1,y
    pha
    lda ExplosionRoutines,y
    pha
    rts
ExplosionRoutines
    .word babymissile-1              ;Baby_Missile   ;_00
    .word missile-1                  ;Missile        ;_01
    .word babynuke-1                 ;Baby_Nuke      ;_02
    .word nuke-1                     ;Nuke           ;_03
    .word leapfrog-1                 ;LeapFrog       ;_04
    .word funkybomb-1                ;Funky_Bomb     ;_05
    .word BFG.mirv-1                 ;MIRV           ;_06
    .word deathshead-1               ;Death_s_Head   ;_07
    .word napalm-1                   ;Napalm         ;_08
    .word hotnapalm-1                ;Hot_Napalm     ;_09
    .word BFG.tracer-1               ;Tracer         ;_10
    .word BFG.tracer-1               ;Smoke_Tracer   ;_11
    .word babyroller-1               ;Baby_Roller    ;_12
    .word roller-1                   ;Roller         ;_13
    .word heavyroller-1              ;Heavy_Roller   ;_14
    .word riotcharge-1               ;Riot_Charge    ;_15
    .word riotblast-1                ;Riot_Blast     ;_16
    .word riotbomb-1                 ;Riot_Bomb      ;_17
    .word heavyriotbomb-1            ;Heavy_Riot_Bomb;_18
    .word propaganda-1               ;Baby_Digger    ;_19
    .word digger-1                   ;Digger         ;_20
    .word heavydigger-1              ;Heavy_Digger   ;_21
    .word sandhog-1                  ;Sandhog        ;_22
    .word heavysandhog-1             ;Heavy_Sandhog  ;_23
    .word dirtclod-1                 ;Dirt_Clod      ;_24
    .word dirtball-1                 ;Dirt_Ball      ;_25
    .word tonofdirt-1                ;Ton_of_Dirt    ;_26
    .word liquiddirt-1               ;Liquid_Dirt    ;_27
    .word dirtcharge-1               ;Dirt_Charge    ;_28
    .word punch-1                    ;Baby_Sandhog   ;_29
    .word BFG-1                      ;Buy_me         ;_30
    .word laser-1                    ;Laser          ;_31
.endp

.proc BFG
    mva #sfx_plasma_2_2 sfx_effect
    jsr BFGblink
    ; Kill all :)
    ldx NumberOfPlayers
    dex
    lda #$00
CheckNextTankBFG
    cpx TankNr    ; not me!
    beq @+
    sta Energy,x
@   dex
    bpl CheckNextTankBFG
    stx AfterBFGflag ; $ff
VOID
tracer
mirv
    rts
.endp
; ------------------------
.proc babymissile
    lda #11 ; ExplosionRadius
GoBabyMissileSFX
    sta ExplosionRadius
    mva #sfx_baby_missile sfx_effect
GoXmissile
    jmp xmissile
.endp
; ------------------------
.proc missile ;
    lda #17 ; ExplosionRadius
    bne babymissile.GoBabyMissileSFX
;    jmp xmissile
.endp
; ------------------------
.proc babynuke
    lda #25 ; ExplosionRadius
GoBabyNukeSFX
    sta ExplosionRadius
    mva #sfx_nuke sfx_effect     ; allways <>0
    bne babymissile.GoXmissile
;    jmp xmissile
.endp
; ------------------------
.proc nuke
    lda #30 ; ExplosionRadius
    bne babynuke.GoBabyNukeSFX
;    jmp xmissile
.endp
; ------------------------
.proc leapfrog
    lda #17 ; ExplosionRadius
;    mva #sfx_baby_missile sfx_effect
;    jsr xmissile
    jsr babymissile.GoBabyMissileSFX

    jsr SecondRepeat

SecondRepeat
    ; soil must fall down now! there is no other way...
    ; hide tanks or they fall down with soil
    jsr SoilDown

    ; it looks like force is divided by 4 here BUT"
    ; in Flight routine force is multiplied by 2 and left
    ; so, we have Force divided by 2 here (not accurately)
    ;lsr Force+1
    ;ror Force
    lsr Force+1
    ror Force
    mva LeapFrogAngle Angle
    mva #sfx_funky_hit sfx_effect
    sbw ytraj+1 #$05    ; next missiles start point goes 5 pixel UP to prevent multiple explosion at one point if tank is hit (4 pixels tank height + 1)
    jsr Flight
    lda HitFlag
    beq EndOfLeapping
    mva #14 ExplosionRadius
    jsr CalculateExplosionRange0
    mva #sfx_baby_missile sfx_effect
    jmp xmissile.NoRangeCalc
EndOfLeapping
    rts
.endp
; ------------------------
;.proc mirv ;  the whole mirv is performed by Flight routine
;    rts
;.endp
; ------------------------
.proc funkybomb ;
    mva #sfx_baby_missile sfx_effect
    mwa xtraj+1 xtrajfb
    sbw ytraj+1 #$05 ytrajfb    ; funky missiles start point goes 5 pixel UP to prevent multiple explosion at one point if tank is hit (4 pixels tank height + 1)
    ;central Explosion
    mva #21 ExplosionRadius
    jsr CalculateExplosionRange0
    jsr xmissile.NoRangeCalc

    jsr SoilDown
    ;
    jsr cleartanks    ; maybe not?
    mva #1 color
    mva #0 FunkyWallFlag
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
    mva #0 ExplosionRadius    ; if no explosion (off screen)
    ; if xdraw if over range then fix it
    lda xdraw+1
    bpl NoOnLeftEdge
    lda #0
    sta xdraw
    sta xdraw+1
NoOnLeftEdge
    cpw xdraw #screenwidth
    bcc NoOnRightEdge
    mwa #screenwidth xdraw
NoOnRightEdge
    jsr CalculateExplosionRange    ; add end of flight coordinates to soildown range
    lda HitFlag
    beq NoExplosionInFunkyBomb
      mva #sfx_baby_missile sfx_effect
      mva #11 ExplosionRadius
      jsr xmissile
NoExplosionInFunkyBomb
    dec FunkyBombCounter
    bne FunkyBombLoop
    mva #0 tracerflag
    lda FunkyWallFlag
    beq NoWallsInFunky
    jsr SetFullScreenSoilRange
NoWallsInFunky
    rts
.endp
; ------------------------
.proc deathshead
    mva #30 ExplosionRadius
    jsr GoXmissileWithSaveXYdraw
    sbw xdraw #34
    jsr GoXmissileWithSaveXYdraw
    adw xdraw #68
    jsr GoXmissileWithSaveXYdraw
    sbw xdraw #34
    ;
    sbw ydraw #34
    ;jsr CalculateExplosionRange
    cpw ydraw #screenHeight
    bcs NoUpperCircle
    jsr GoXmissileWithSaveXYdraw
NoUpperCircle
    adw ydraw #68
    ;jsr CalculateExplosionRange
    cpw ydraw #screenHeight
    bcs NoLowerCircle
    jsr GoXmissileWithSaveXYdraw
NoLowerCircle
    rts

GoXmissileWithSaveXYdraw
    mva #sfx_nuke sfx_effect
    mwa xdraw tempXROLLER
    mwa ydraw modify
    jsr xmissile
    mwa tempXROLLER xdraw
    mwa modify ydraw
    rts
.endp
; ------------------------
.proc napalm
    lda #0      ; in this weapon - flag: 0 - napalm, 1 - hotnapalm
    beq xnapalm
.endp
; ------------------------
.proc hotnapalm
    lda #1   ; in this weapon - flag: 0 - napalm, 1 - hotnapalm
;    jmp xnapalm
.endp
; ------------------------
.proc xnapalm
    sta HotNapalmFlag
    mva #sfx_napalm sfx_effect
    mva #(napalmRadius+4) ExplosionRadius     ; real radius + 4 pixels (half characrer width)
    jsr CalculateExplosionRange
    ;
    mwa xdraw xcircle    ; store hitpoint for future repeats
    ldy #30        ; repeat 30 times
    sty magic
RepeatNapalm    ; external loop (for fire animation)
    mwa xcircle xdraw
    sbw xdraw #(napalmRadius)  ; 10 pixels on left side hit point
    ldy #0
    sty magic+1
RepeatFlame        ; internal loop (draw flames)
    ldy #0
    adw xdraw #mountaintable temp
    sty ydraw+1
    lda (temp),y
    sec
    sbc #1    ; over ground
    sta ydraw
    lda xdraw
    and HotNapalmFlag    ; if hotnapalm and x is odd:
    :2 asl    ; modify y position 4 pixels up
    ldy ydraw
    sta ydraw
    tya
    sec
    sbc ydraw
    sta ydraw
    sbw xdraw #4    ; half character correction
    ; draw flame symbol
    lda magic    ; if last repeat - clear flames
    beq LastNapalmRepeat
    lda random
    and #%00000110
    clc
    adc #char_flame
    bne PutFlameChar
LastNapalmRepeat
    lda #char_clear_flame         ; clear flame symbol
PutFlameChar
    sta CharCode
    jsr TypeChar
    adw xdraw #5    ; reverse half character correction (4 px - we need positon of character center) and next char 1 pixels to righ
    inc magic+1
    lda magic+1
    cmp #(2*napalmRadius+1)    ; 10 pixels on left, 10 pixels on right and 1 in center
    jne RepeatFlame
    dec magic
    jpl RepeatNapalm
    ; after napalm
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
    sbw xcircle #(napalmRadius+TankWidth+4-4) xdraw    ; 10 pixels on left + character width (tank) + half character - correction
    bpl @+
    mwa #0 xdraw    ; left screen edge
@
    ; now we compare tank position with left edge of the fire (napalm)
    lda XtankstableH,x
    cmp xdraw+1
    bne @+
    lda XtankstableL,x
    cmp xdraw
@
    bcc TankOutOfFire

    ldy #40        ; energy decrease (napalm) - but if hotnapalm:
    lda HotNapalmFlag
    beq NotHot
    ldy #80        ; energy decrease (hotnapalm)
NotHot
    ; check shields ( joke :) )
    jsr DecreaseEnergyX
TankOutOfFire
EndNurnedCheckLoop
    dex
    bpl BurnedCheckLoop
    rts
.endp
; ------------------------
.proc babyroller
    lda #11 ; ExplosionRadius
GoRoller
    sta ExplosionRadius
    jmp xroller
.endp
; ------------------------
.proc roller ;
    lda #21 ; ExplosionRadius
    bne babyroller.GoRoller    ; 1 byte saved
;    jmp xroller
.endp
; ------------------------
.proc heavyroller
    lda #30 ; ExplosionRadius
    bne babyroller.GoRoller    ; 1 byte saved
;    jmp xroller
.endp
; ------------------------
.proc riotbomb
    lda #17 ; ExplosionRadius
GoRiotBomb
    sta ExplosionRadius
    jsr CalculateExplosionRange
    jmp xriotbomb
.endp
; ------------------------
.proc heavyriotbomb
    lda #29 ; ExplosionRadius
    bne riotbomb.GoRiotBomb ; 4 bytes saved - optimization :)
;    jsr CalculateExplosionRange
;    jmp xriotbomb
.endp
; ------------------------
.proc propaganda
    ; propaganda
    jsr SetFullScreenSoilRange  ; to change
    mwa xdraw tempXROLLER ; save X coordinate of texts
    ; all text start from `talk` and end with an inverse.
    ; we go through the `talk`, count number of inverses.
    ; if equal to TextNumberOff, it is our text, printit

    mva #5 TempXfill ; number of text to display
nexttext
@   lda random
    cmp #talk.NumberOfOffensiveTexts
    bcs @-

    sta TextNumberOff
    lda #$ff
    sta plot4x4color
    mwa #talk LineAddress4x4
    jsr _calc_inverse_display   
    ; now find length of the text
@   iny
    lda (LineAddress4x4),y
    bpl @-
    iny
    sty fx
    mwa tempXROLLER temp

    jsr Display4x4AboveTank.AboveTemp
    
    dec TempXfill
    bne nexttext
    rts
.endp
; ------------------------
.proc digger ;
    lda #3  ;   diggery  ; how many branches (-1)
GoDiggerSFX
    sta diggery
    mva #sfx_digger sfx_effect
    mva #0 sandhogflag
    mva #13 DigLong
    bne xdigger
.endp
; ------------------------
.proc heavydigger
    lda #7  ; diggery  ; how many branches  (-1)
    bne digger.GoDiggerSFX
.endp
; ------------------------
.proc babysandhog
    lda #1  ; diggery  ; how many branches (-1)
    bne heavysandhog.GoHeavysandhogSFX
.endp
; ------------------------
.proc sandhog
    lda #3  ; diggery  ; how many branches (-1)
    bne heavysandhog.GoHeavysandhogSFX
.endp
; ------------------------
.proc heavysandhog
    lda #5  ; diggery  ; how many branches (-1)
GoHeavysandhogSFX
    sta diggery
    mva #sfx_sandhog sfx_effect
    mva #char_sandhog_offset sandhogflag
    mva #13 DigLong
;    jmp xdigger
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
    scs
    dec digtabxH,x
    jmp DigRandomize
DigRight ; odd go right (everytime 4 pixels)
    clc
    lda digtabxL,x
    adc #$04
    sta digtabxL,x
    scc
    inc digtabxH,x
DigRandomize
    lda random
    ;and #$87
    bmi DigUp
DigDown
    and #$07
    clc
    adc digtabyL,x
    sta digtabyL,x
    scc
    inc digtabyH,x
    jmp DigCalculateNext
DigUp
    and #$07
    sta temp
    sec
    lda digtabyL,x
    sbc temp
    sta digtabyL,x
    scs
    dec digtabyH,x
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
    rts
DiggerCharacter
    lda random
    and #$06
    clc
    adc #char_digger
    adc sandhogflag
    sta CharCode
    cpw xdraw #(screenwidth-6)
    bcs DoNotPutDig
    jmp TypeChar
.endp
; ------------------------
.proc dirtclod
    lda #12 ; ExplosionRadius
    bne xdirt
.endp
; ------------------------
.proc dirtball
    lda #22 ; ExplosionRadius
    bne xdirt
.endp
; ------------------------
.proc tonofdirt
    lda #31 ; ExplosionRadius
;    jmp xdirt
.endp
; -----------------
.proc xdirt ;
; -----------------
    sta ExplosionRadius
    jsr CalculateExplosionRange
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
; ------------------------
.proc dirtcharge
    mva #61 ExplosionRadius
    jsr CalculateExplosionRange
    jmp ofdirt
.endp
; ------------------------
.proc riotcharge
    mva #sfx_riot_blast sfx_effect
    mva #31 ExplosionRadius
    bne cleanDirt
.endp
; ------------------------
.proc riotblast
    mva #sfx_riot_blast sfx_effect
    mva #61 ExplosionRadius
;    jmp cleanDirt
.endp
; -----------------
.proc cleanDirt
; -----------------
    jsr CalculateExplosionRange
    mva #0 color
    jmp ofdirt.NoColor
.endp
; ------------------------
.proc liquiddirt
    mva #sfx_liquid_dirt sfx_effect
    mwa #510 FillCounter
; -----
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
    ;ora xdraw+1 ; like cpw xdraw #$0000
    jne RollinContinuesLiquid
    beq FillNow
HowMuchToFallRight3
    inw xdraw
    cpw xdraw #screenwidth
    jne RollinContinuesLiquid
FillNow
     ; finally one pixel more
    ldy #0
    lda HowMuchToFall
    bmi FillHole
    cmp #1
    beq FillLeft
    inw xdraw
    inw xdraw    ; tricky but we must rollback xdraw in proper direction
FillLeft
.nowarn    dew xdraw
FillHole
    adw xdraw #mountaintable tempXROLLER
    lda (tempXROLLER),y
    sta ydraw
    beq ToHighFill    ; if we filled all playfield (very rare but possible)
    dec ydraw    ; one pixel up
    lda ydraw
    sta (tempXROLLER),y    ;mountaintable update
    mva #1 color
    jsr plot.MakePlot
ToHighFill
.nowarn dew FillCounter
    lda FillCounter
    ora FillCounter+1
    jne RepeatFill
    rts
.endp
; ------------------------
.proc laser
; in xdraw and ydraw we have hit point coordinates
; from Shoot/Flight procedures (invisible flight)
; ------------------------
;    ldx TankNr
    lda AngleTable,x
    tay

    mwa EndOfTheBarrelX xbyte
    mva EndOfTheBarrelY ybyte
    mva #0 ybyte+1
    sta LaserFlag    ; turn on gravity and wind after shot :)

    mwa xdraw LaserCoordinate
    mwa ydraw LaserCoordinate+2
    mwa xbyte LaserCoordinate+4
    mwa ybyte LaserCoordinate+6

    mva #sfx_lightning sfx_effect

    mva #%10000000 drawFunction
    ;the above switches Draw to measuring length
    jsr draw
    mva #0 drawFunction
    lsr LineLength+1    ; LineLength / 8
    ror LineLength
    lsr LineLength     ; max line lenght is about 380 (9 bits)
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
    jsr CalculateExplosionRange
NoRangeCalc
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
;    clc    ; ops :)
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
    cmp #ind_Shield                 ; one hit shield
    beq UseShield
    cmp #ind_Force_Shield           ; shield with energy and parachute
    beq UseShieldWithEnergy
    cmp #ind_Heavy_Shield           ; shield with energy
    beq UseShieldWithEnergy
    cmp #ind_Bouncy_Castle          ; Auto Defence (it works only if hit ground next to tank. Tank hit is handled in Flight proc)
    beq UseShieldWithEnergy
    cmp #ind_Mag_Deflector          ; Mag deflector  (it works only if hit ground next to tank. Tank hit is handled in Flight proc)
    beq UseShieldWithEnergy
    jsr DecreaseEnergyX
    jmp EndOfDistanceCheckLoop
UseShieldWithEnergy
    jsr DecreaseShieldEnergyX
    cpy #0    ; is necessary to reduce tenk energy ?
    beq ShieldCoveredTank
    jsr DecreaseEnergyX
ShieldCoveredTank
    lda ShieldEnergy,x
    jne EndOfDistanceCheckLoop
ShieldEnergy0    ; deactivate if no energy. it's like use one hit shield :)
UseShield
    lda TankNr
    pha            ; store TankNr
    stx TankNr    ; store X in TankNr :)
    jsr ClearTankNr    ; now erase tank with shield (to erase shield)
    lda #0
    sta ActiveDefenceWeapon,x    ; deactivate defense weapons
    jsr PutTankNr    ; draw tank without shield
    ldx TankNr    ; restore X value :)
    pla
    sta TankNr    ; restore TankNr value :)
TankIsNotWithinTheRange
EndOfDistanceCheckLoop
    dex
    jpl DistanceCheckLoop
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
    sty HitFlag        ; set to 0

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
    jne RollinContinues        ; like cpw xdraw #0
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
    mva #sfx_baby_missile sfx_effect
    jmp xmissile
    ; rts
.endp
; --------------------------------------------------
.proc checkRollDirection
; check rolling direction (for roller and other rolling weapons)
; xdraw (word) - X coordinate
; Y coordinate is taken from mountaintable and go to ydraw (word)
; shoot direction is taken from VX+3
; result:
; HowMuchToFall - direction
; $FF - we are in a hole (flying in missile direction)
; 1 - right, 2 - left
; --------------------------------------------------
    ldy #0
    adw xdraw #mountaintable tempXROLLER
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
SeekLeft
    cpw tempXROLLER #mountaintable
    beq GoRightNow        ; "bounce" if we have on left end
.nowarn    dew tempXROLLER
    lda (tempXROLLER),y    ;fukk! beware of Y value
    cmp HeightRol
HowMuchToFallLeft
    bcs GoRightNow
    mva #1 HowMuchToFall
GoRightNow
    adw xdraw #mountaintable tempXROLLER
SeekRight
    cpw tempXROLLER #(mountaintable+screenwidth)
    beq HowMuchToFallKnown    ; "stop" if we have on left end
    inw tempXROLLER
    lda (tempXROLLER),y
    cmp HeightRol
HowMuchToFallRight
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
; --------------------------------------------------
.proc punch ;
; --------------------------------------------------
; 

    ; calculate radius from Force
     lda ForceTableL,x
    sta temp
    lda ForceTableH,x
    sta temp+1
    ldy #3  ; ExplosionRadius = Force/16
@   lsr temp+1
    ror temp
    dey
    bpl @-
    
    clc
    lda temp
    pha     ; store radius
    adc #4  ; add margins for SoliDown
    sta ExplosionRadius 

    ; fixed radius
;    mva #36 ExplosionRadius

    jsr CalculateExplosionRange
    
    mva #sfx_baby_missile sfx_effect
        
    lda ytankstable,x
    cmp #13+15     ; Check if tank is too high (13 - tank with shield, 15 - Jump)
    bcc TooHighNoJump
    ; Jump
    ; 15 pixels up
    mva #15 ExplosionRadius
@   jsr ClearTankNr
    dec ytankstable,x
    jsr PutTankNr
    lda ExplosionRadius
    cmp #5
    bcs Physics
    jsr WaitOneFrame
Physics
    dec ExplosionRadius
    bne @-
    ; and down
    mva #15 ExplosionRadius
@   jsr ClearTankNr
    inc ytankstable,x
    jsr PutTankNr
    dec ExplosionRadius
    bne @-

TooHighNoJump
    mva #sfx_dirt_chrg_s sfx_effect

    ; calculate radius from Force
    pla     ; restore radius
    sta ExplosionRadius  

    ; fixed radius
;    mva #32 ExplosionRadius

CheckRange
    ; punch all (not dead :) tanks in range
    ldx TankNr
    ldy NumberOfPlayers
    dey
CheckingNextTank
    lda eXistenZ,y
    beq DeadTank
    cpy TankNr
    beq Myself
    ; it's not dead tank - check range
    mva #0 temp2    ; tank direction (0 - on right side, $ff - on left side)
    sec
    lda xtankstableL,y
    sbc xtankstableL,x
    sta temp
    lda xtankstableH,y
    sbc xtankstableH,x
    sta temp+1
    bpl RightSide
    dec temp2   ; on left side flag
    lda temp
    eor #$ff
    sta temp
    lda temp+1
    eor #$ff
    sta temp+1
RightSide
    bne TooFar
    lda temp
    cmp ExplosionRadius
    bcs TooFar
    ; tank in range!
    phy
    phx
    sty TankNr
    bit temp2
    bmi PunchLeft
PunchRight
    jsr ClearTankNr
    lda XtanksTableH,x
    cmp #>(screenwidth-TankWidth-2) ; 2 pixels correction due to a barrel wider than tank
    bne @+
    lda XtanksTableL,x
    cmp #<(screenwidth-TankWidth-2) ; 2 pixels correction due to a barrel wider than tank
@   bcs RightEdge
    inc xtankstableL,x
    bne @+
    inc xtankstableH,x
RightEdge
@   jsr PutTankNr
    jmp TankPunched
PunchLeft
    jsr ClearTankNr
    lda XtanksTableH,x
    bne NotLeftEdge
    lda XtanksTableL,x
    cmp #3    ; 2 pixels correction due to a barrel wider than tank
    bcc LeftEdge
NotLeftEdge
    lda xtankstableL,x
    bne @+
    dec xtankstableH,x
@   dec xtankstableL,x
LeftEdge
    jsr PutTankNr
TankPunched
    plx
    ply
    stx TankNr
TooFar    
Myself    
DeadTank
    dey
    jpl CheckingNextTank
    dec ExplosionRadius
    jne CheckRange
    ldy #10
    jsr PauseYFrames
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
    jsr PutTankNameOnScreen
;    jsr DisplayStatus    ; There is no need anymore, it is always after PutTankNameOnScreen

    jsr PutTankNr

    jsr WaitOneFrame ; best after drawing a tank

    bit TestFlightFlag
    bpl @+
    jsr Shoot.AfterOffensiveText    ; Lazy Darwin - aiming visualisation
@
;keyboard reading
; KBCODE keeps code of last keybi
; SKSTAT  $ff - nothing pressed
;  $FB - any key
;  $f7 - shift
;  $f3 - shift+key

notpressed
    jsr CheckExitKeys    ; Check for O, Esc or Start+Option keys
    spl:rts ; exit if pressed 'Exit keys'

    ldx TankNr    ; for optimize
    jsr GetKeyFast
    and #%10111111 ; SHIFT elimination
    
    cmp #@kbcode._atari        ; Option key
    beq callActivation
    cmp #@kbcode._A  ; $3f  ; A
    bne @+
callActivation
    ; Hide all tanks - after inventory they may have other shapes
    jsr ClearTanks
    jsr DefensivesActivate
    jmp afterInventory

@
    cmp #@kbcode._I  ; $0d  ; I
    bne @+
callInventory
    ; Hide all tanks - after inventory they may have other shapes
    jsr ClearTanks
    ;
    mva #$ff isInventory
    jsr Purchase
afterInventory
    jsr MakeDarkScreen
    jsr DisplayStatus
    jsr SetMainScreen
    jsr DrawTanks
    ;jsr WaitOneFrame    ; not necessary
    bit LazyFlag
    bvc NoLazy
    jsr LazyBoys
NoLazy
    bit SpyHardFlag
    bpl NoSpyHard
    jsr SpyHard
NoSpyHard
    RmtSong song_ingame
    mva #0 escFlag
    jmp ReleaseAndLoop
@
/*o     cmp #$80|@kbcode._up
    jeq CTRLPressedUp
    cmp #$80|@kbcode._down
    jeq CTRLPressedDown
    cmp #$80|@kbcode._tab
    jeq CTRLPressedTAB */

jumpFromStick
    .IF TARGET = 800
      cmp #$80|@kbcode._help    ; Ctrl+Help
      bne NoVdebugSwitch
    .ELSE
      cmp #@kbcode._help    ; Help (# in A5200)
      bne NoVdebugSwitch
      sta pressTimer ; reset 0+@kbcode._help (tricky)
      jsr WaitForKeyRelease.StillWait
      lda pressTimer
      cmp #(25+@kbcode._help)  ; 1/2s - long press only
      bcc NoVdebugSwitch
    .ENDIF
      lda Vdebug
      eor #$ff
      sta Vdebug
      mva #sfx_long_barrel sfx_effect
      jmp ReleaseAndLoop
NoVdebugSwitch

    mvy #1 Erase    ; optimization
    and #$3f ;CTRL and SHIFT ellimination
    cmp #@kbcode._up  ; $e
    jeq pressedUp
    cmp #@kbcode._down  ; $f
    jeq pressedDown
    cmp #@kbcode._left  ; $6
    jeq pressedLeft
    cmp #@kbcode._right  ; $7
    jeq pressedRight
    cmp #@kbcode._space  ; $21
    jeq pressedSpace
    cmp #@kbcode._ret  ; Fire (Joy)
    jeq pressedSpace
    cmp #@kbcode._tab  ; $2c
    jeq pressedTAB
    cmp #@kbcode._M  ; $25  ; M
    jeq pressedM
    cmp #@kbcode._S  ; $3e  ; S
    jeq pressedS
    .IF TARGET = 800
      cmp #61    ; G
      bne EndKeys
      jsr SelectNextGradient.NotWind
      jmp ReleaseAndLoop
    .ENDIF
EndKeys
    mva #$80 pressTimer
    jmp notpressed

;
pressedUp
    lda pressTimer
    spl:mva #0 pressTimer  ; if >128 then reset to 0
    cmp #25  ; 1/2s
    bcs CTRLPressedUp


    ;force increaseeee!
    ;ldx TankNr        ; optimized
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
    ;ldx TankNr        ; optimized
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

    ;ldx TankNr        ; optimized
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
    mva #sfx_set_power_1 sfx_effect
    jmp BeforeFire

CTRLPressedDown
    mva #sfx_set_power_1 sfx_effect

    ;ldx TankNr        ; optimized
    sec
    lda ForceTableL,x
    sbc #10
    sta ForceTableL,x
    jcs BeforeFire
    dec ForceTableH,x
    bmi ForceGoesZero
    bpl @-

pressedRight
    ;ldx TankNr        ; optimized
    lda pressTimer
    spl:mva #0 pressTimer  ; if >128 then reset to 0
    cmp #25  ; 1/2s
    bcs CTRLPressedRight

;    mva #1 Erase
    jsr DrawTankNr.BarrelChange
    dec:lda AngleTable,x
    cmp #255  ; -1
    bne @+
    lda #180
    sta AngleTable,x
@
    mva #sfx_set_power_2 sfx_effect
    jmp BeforeFire

CTRLPressedRight
    ;ldx TankNr        ; optimized
;    mva #1 Erase
    jsr DrawTankNr.BarrelChange
    lda AngleTable,x
    sec
    sbc #4
    sta AngleTable,x
    cmp #4  ; smallest angle for speed rotating
    bcs @-
    lda #180
    sta AngleTable,x
    bne @-


pressedLeft
    ;ldx TankNr        ; optimized
    lda pressTimer
    spl:mva #0 pressTimer  ; if >128 then reset to 0
    cmp #25  ; 1/2s
    bcs CTRLPressedLeft

;    mva #1 Erase
    jsr DrawTankNr.BarrelChange
    INC AngleTable,x
    lda AngleTable,x
    cmp #180
    bcc @+
    lda #0
    sta AngleTable,x
@
    mva #sfx_set_power_2 sfx_effect
    jmp BeforeFire

CTRLPressedLeft
    ;ldx TankNr        ; optimized
;    mva #1 Erase
    jsr DrawTankNr.BarrelChange
    lda AngleTable,x
    clc
    adc #4
    sta AngleTable,x
    cmp #180-4
    bcc @-
    lda #0
    sta AngleTable,x
    beq @-

pressedTAB
    mva #sfx_purchase sfx_effect
    ;ldx TankNr        ; optimized
    lda ActiveWeapon,x
    cmp #last_offensive      ; the last possible offensive weapon
    bne ?notlasttofirst
      lda #first_offensive        ; #0
      sta ActiveWeapon,x
      beq @+    ; allways = 0
?notlasttofirst
    inc ActiveWeapon,x
@
    lda ActiveWeapon,x
    jsr HowManyBullets ; and we have qty of owned shells. Ufff....
    beq pressedTAB
    bne ReleaseAndLoop

CTRLpressedTAB
    mva #sfx_purchase sfx_effect
    ;ldx TankNr        ; optimized
    lda ActiveWeapon,x
    cmp #first_offensive        ; #0
    bne ?notfirsttolast
      lda #last_offensive      ; the last possible offensive weapon
      sta ActiveWeapon,x
      bne @+    ; allways <> 0
?notfirsttolast
    dec ActiveWeapon,x
@
    lda ActiveWeapon,x
    jsr HowManyBullets ; and we have qty of owned shells. Ufff....
    beq CTRLpressedTAB
    bne ReleaseAndLoop

pressedM
    ; have you tried turning the music off and on again?
    lda #$ff
    eor:sta noMusic
    RmtSong song_ingame
    jmp ReleaseAndLoop

pressedS
    ; have you tried turning sfx off and on again?
    lda #$ff
    eor:sta noSfx
ReleaseAndLoop
    jsr WaitForKeyRelease
    mva #$80 pressTimer
    jmp BeforeFire

pressedSpace
    ;=================================
    ;we shoot here!!!
    lda #0
    sta ATRACT    ; reset atract mode
    jsr WaitForLongPress
    bcc fire    ; short press
    jmp callInventory   ; long press
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

    mva #0 TestFlightFlag

;the latest addition to this routine is
;displaying offensive texts!

RandomizeOffensiveText
    lda random
    cmp #talk.NumberOfOffensiveTexts
    bcs RandomizeOffensiveText

    sta TextNumberOff
    ldy TankNr
    lda #$ff
    jsr DisplayOffensiveTextNr.notZero

AfterOffensiveText
    mva #0 LaserFlag    ; $ff - Laser
    ldx TankNr
    lda ActiveWeapon,x
    cmp #ind_Laser           ; laser
    bne NotStrongShoot
    ; Laser: (not)very strong - invisible - shot for laser beam end coordinates
    bit TestFlightFlag
    bmi @+ ; visible if Lazy Darwin
    bit Vdebug
    bmi @+
    mva #0 color
@    lda #1
    sta Force
    sta Force+1
    mva #$ff LaserFlag    ; $ff - Laser
    bne AfterStrongShoot
NotStrongShoot
    jsr Table2Force
    bit TestFlightFlag
    bmi AfterStrongShoot
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

    ; checking if the shot is underground (no Flight but Hit :) )
    tay    ; A=0 !
    adw xtraj+1 #mountaintable temp
    lda ytraj+1
    cmp (temp),y    ; check collision with mountains
    bcs ShotUnderGround
    jsr Flight
    mva #1 color
    bne ClearOffensiveText
ShotUnderGround
    mwa xtraj+1 xdraw    ; but why not XHit and YHit !!!???
    mwa ytraj+1 ydraw
    mva #$ff HitFlag
    ;here we clear offensive text (after a shoot) - clear only if no test flight (Lazy Darvin)
ClearOffensiveText
    bit TestFlightFlag
    bmi @+
    ldy TankNr
    jmp DisplayOffensiveTextNr
@
;    rts
.endp

;--------------------------------------------------
.proc NoShoot  ;TankNr (byte)
;--------------------------------------------------
; This is "Shoot" procedure for weapons that do not require a flying bullet.
    ; Shoots tank nr X !!! :)
    ; set the ending coordinates of bullet with correction
    ldy #0
    clc
    lda xtankstableL,x
    adc #4  ; tank "center" :)
    sta xdraw    ; but why not XHit and YHit !!!???
    tya ;0
    adc xtankstableH,x
    sta xdraw+1
    lda ytankstable,x
    sta ydraw
    sty ydraw+1 ;0
    dey ; $ff
    sty HitFlag
    rts
.endp
;--------------------------------------------------
.proc Flight  ; Force(byte.byte), Wind(0.word)
; Angle(byte) 128=0, 255=maxright, 0=maxleft
; if 7bit and 6bit of TestFlightFlag is set no real flight - hit test only (for AI)
; 7bit - fast, test flight
; 6bit - invisible bullet
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
;goto begin-


; smoke tracer :)
    ldy #0
    bit TestFlightFlag    ; if test flight for AI or Lazy Darwin
    bmi noSmokeTracer    ; no Smoke Tracer display
    ldx TankNr
    lda ActiveWeapon,x
    cmp #ind_Smoke_Tracer    ; Smoke tracer
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

    bit LaserFlag    ; no gravity if Laser
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
    bit TestFlightFlag
    bmi NoTestForMIRV
    ldx TankNr
    lda ActiveWeapon,x
    cmp #ind_MIRV            ; MIRV
    jeq MIRVdownLoop
NoTestForMIRV
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

    bit LaserFlag    ; no wind if Laser
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
    bit LaserFlag
    bmi LaserNoWalls
    ; Check for walls
    jsr MakeWalls
    ;
LaserNoWalls
    mwa xtraj+1 XtrajOld+1
    mwa ytraj+1 YtrajOld+1

    bit TestFlightFlag
    bmi nowait
    bit LaserFlag    ; faster laser prepare
    bpl nolaserwait
    bit Vdebug
    bpl nowait
nolaserwait
    lda color
    beq nonowait    ; smoke tracer erases slowly
    lda tracerflag
    bne nowait        ; funky bomb explotes fast ( tracerflag in real is funkyflag :) )
nonowait
    jsr shellDelay
    ;
    jsr CheckExitKeys    ; Check for O, Esc or Start+Option keys
    spl:rts        ; exit if pressed 'Exit keys'
    ldx TankNr
    ;
nowait
    lda HitFlag
    bne Hit
    ; --- only for Laser
    bit LaserFlag
    bpl NoCheckEdgesForLaser
    ; If laser fires, edges of the screen finish "flying" and laser hits.
    lda ytraj+2
    bmi LaserHitEdge
    cpw xtraj+1 #screenwidth ;+1
    bcc LaserNoHitEdge
LaserHitEdge
    mwa xdraw XHit
    mwa ydraw YHit
    mva #$ff HitFlag    ; screen edgs like ground (only for Laser)
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
    bvc NoTestFlight
    bit Vdebug
    bpl NoUnplot
    ldy #20    ; delay for visualize AI targeting
    jsr ShellDelay.Y
    jmp YesUnPlot
NoTestFlight
    lda tracerflag
    bne NoUnPlot

YesUnPlot
    jsr UnPlot

NoUnPlot

    jmp Loopi

Hit
    mwa XHit xdraw
    mwa YHit ydraw
    bit TestFlightFlag
    bvs EndOfFlight
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
    jmi NoHitAtEndOfFight        ; RTS only !!! - no defendsives check
    ; and now check for defensive-aggressive weapon
    lda HitFlag
    jeq NoHitAtEndOfFight        ; RTS only !!!
    jmi NoTankHitAtEndOfFight
    ; tank hit - increase direct hits points
    ldx TankNr
    inx
    cpx HitFlag    ; we don't count suicides :)
    beq @+
    dex
    inc DirectHits,x
;    bne @+        ; one byte enough
;    inc DirectHitsH,x
@
    ; tank hit - check defensive weapon of this tank
    tax
    dex        ; index of hitted tank in X
    ldy TankNr
    lda ActiveWeapon,y
    cmp #ind_Tracer             ; defence not fire by tracers
    beq JNoDefence
    cmp #ind_Smoke_Tracer
    beq JNoDefence
    cmp #ind_Laser              ; Bouncy and Mag not fire by Laser
    beq JNoDefence
    lda ActiveDefenceWeapon,x
    cmp #ind_Bouncy_Castle          ; Auto Defence
    jeq BouncyCastle
    cmp #ind_Mag_Deflector          ; Mag Deflector
    beq MagDeflector
JNoDefence
    jmp NoDefence
MagDeflector
    ; now run defensive-aggressive weapon - Mag Deflector!
    ; get tank position
    clc
    lda xtankstableL,x
    adc #$04    ; almost in tak center :)
    sta XHit
    lda xtankstableH,x
    adc #$00
    sta XHit+1
    lda #$ff    ; change to ground hit (we hope)
    sta HitFlag
    bit random    ; left or right deflection ?
    bpl RightDeflection
LeftDeflection
    sbw XHit #18    ; 18 pixels to left and explode...
    bit XHit+1    ; if off-screen ...
    bpl EndOfMagDeflector    ; hit of course but we need RTS
    adw XHit #36    ; change to right :)
    jmp EndOfMagDeflector
RightDeflection
    adw XHit #18    ; 18 pixels to right and explode...
    cpw XHit screenwidth    ; if off-screen ...
    bcs EndOfMagDeflector    ; hit of course but we need RTS
    sbw XHit #36    ; change to left
EndOfMagDeflector
    lda TankNr
    pha            ; store TankNr
    stx TankNr    ; store X in TankNr :)
    jsr ClearTankNr    ; now erase tank with shield (to erase shield)
    lda #0
    sta ActiveDefenceWeapon,x    ; deactivate used mag deflector weapon
    sta ShieldEnergy,x
    jsr PutTankNr    ; draw tank without shield
    ldx TankNr    ; restore X value :)
    pla
    sta TankNr    ; restore TankNr value :)
    mwa XHit xdraw    ; why? !!!
NoTankHitAtEndOfFight
NoHitAtEndOfFight
NoDefence
    lsrw Force    ; Force = Force / 2 - because earlier we multiplied by 2
    rts        ; END !!!
BouncyCastle
    ; now in Y we have number of of the attacking player (TankNr) !
    lda ActiveWeapon,y
    ; if Bouncy Castle bounced Funky Bomb - whole screen in range of soil down
    cmp #ind_Funky_Bomb
    bne @+
    jsr SetFullScreenSoilRange
@
    mva #sfx_shield_on sfx_effect
    ; now run defensive-aggressive weapon - Bouncy Castle (previously known as Auto Defence)!
    lda TankNr
    pha            ; store TankNr
    stx TankNr    ; store X in TankNr :)
    jsr ClearTankNr    ; now erase tank with shield (to erase shield)
    lda #0
    sta ActiveDefenceWeapon,x    ; deactivate used auto defense weapon
    sta ShieldEnergy,x
    sta xtraj        ; prepare coordinates
    sta ytraj
;    sta xtraj+2
;    sta ytraj+2
    jsr PutTankNr    ; draw tank without shield
;    ldx TankNr    ; restore X value :) ... but we don't need X now ..
    pla
    sta TankNr    ; restore TankNr value :)
    sec
    lda #180
    sbc LeapFrogAngle
    sta Angle    ; swap angle (LeapFrogAngle - because we have strored angle in this variable)
    lsrw Force    ; Force = Force / 2 - because earlier we multiplied by 2
    mwa XHit xtraj+1
    sbw YHit #5 ytraj+1
    mva #1 color
    jmp RepeatFlight        ; and repeat Fight
.endp

.proc SecondFlight
; ---------------- copied code fragment from before firing. not too elegant.
; ---------------- get fire parameters again

    ldx TankNr
    jsr Table2Force
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
    jsr ClearScreenSoilRange

    ldx #$FF ; it will turn 0 in a moment anyway
    stx MirvMissileCounter
mrLoopi
    ldx MirvMissileCounter
    inx
    cpx #5
    bne @+
    ldx #0
@    stx MirvMissileCounter

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
    ;
    jsr CheckExitKeys    ; Check for O, Esc or Start+Option keys
    bpl ExitnotPressed
    rts        ; exit if pressed 'Exit keys'
ExitnotPressed
    ;

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
    lda ytraj+2        ; Y high byte
    bpl @+
    mva #%10000000 YposFlag    ; bullet over the screen (Y)
    bmi MIRVsetXflag
@
    lda ytraj+1        ; Y low byte
    cmp #screenheight
    bcc MIRVsetXflag    ; bullet on screen (Y)
    mva #%01000000 YposFlag    ; bullet under the screen (Y)
MIRVsetXflag
    lda xtraj02,x    ; X high byte
    cmp #>screenwidth
    bne @+
    lda xtraj01,x    ; X low byte
    cmp #<screenwidth
@
    bcc MIRVXonscreen
    mva #%10000000 XposFlag    ; bullet off-screen (X)
MIRVXonscreen

    ; X and Y position flags sets
    ; then realize rules

    lda YposFlag
    jmi MIRVcontinueFly        ; Y over the screen
    bne MIRVYunderscreen    ; Y under the screen
    ; Y on screen
    bit XposFlag
    jmi MIRVcontinueFly        ; Y on screen and X off-screen
    jpl MIRVcheckCollision    ; X and Y on screen
MIRVYunderscreen
    bit XposFlag
    jpl MIRVcheckCollision    ; X on screen and Y under screen
    ; Y under screen and X off-screen
    ; stop flying
    jmi mrEndOfFlight

MIRVcontinueFly
    mwa #0 xdraw
    mwa #screenheight-1 ydraw
    bit XposFlag
    bmi @+    ; no pixels to plot
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
    cmp (temp),y    ; check collision with mountains
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
    jsr DisplayOffensiveTextNr

    ; temporary removing tanks from the screen (otherwise they will fall down with soil)
    jsr SoilDown
    mva #$ff HitFlag        ; but why ??
    rts
.endp
; -------------------------------------------------
.proc MakeWalls
; -------------------------------------------------
    bit WallsType ; ; bits 6 and 7: 00 - none, 01 - bump, 10 - wrap, 11 - boxy
    bpl WrapAndNone
    bvc MakeBump
    ; top bounce
    bit ytraj+2
    bpl NoOnTop
    bit vy+3
    bmi FlyingDown
    sec
    .rept 4
        lda #$00
        sbc vy+#
        sta vy+#
    .endr
FlyingDown
NoOnTop
MakeBump
    cpw xtraj+1 #screenwidth
    bcc OnScreen
    ; inverse vx (bouncing wall)
    sec
    .rept 4
        lda #$00
        sbc vx+#
        sta vx+#
    .endr
    ; and bouce feapfrog :)
    sec
    lda #180
    sbc LeapFrogAngle
    sta LeapFrogAngle    ; swap angle (LeapFrogAngle)
    inc FunkyWallFlag
    rts
WrapAndNone
    bvc NoWall
    cpw xtraj+1 #screenwidth
    bcc OnScreen
    ; (wrapping wall)
    inc FunkyWallFlag
    bit xtraj+2
    bmi LeftWrap
RightWrap
    sbw xtraj+1 #screenwidth
    rts
LeftWrap
    adw xtraj+1 #screenwidth
OnScreen
NoWall
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
    jsr FlashTank    ; first we flash tank
    jsr ClearTankNr    ; and erase tank
    lda #0
    sta Erase
    ldx TankNr
    sta Energy,x    ; clear tank energy
    sta eXistenZ,x    ; erase from existence
    sta LASTeXistenZ,x    ; to prevent explosion
    sta ActiveDefenceWeapon,x    ; deactivate White Flag
    jsr PMoutofScreen
    jsr drawtanks    ; for restore PM
    mva #sfx_silencer sfx_effect
    rts
.endp

; -------------------------------------------------
.proc AutoDefense
; -------------------------------------------------
; This routine is run from inside of the main loop
; X - index of  tank
; -------------------------------------------------
    jsr PrepareAIShoot.WepTableToTemp
    jsr UseBattery
    jmp GetBestDefensive
    ; rts
.endp
; -------------------------------------------------
.proc SpyHard
; -------------------------------------------------
    mvx TankNr TargetTankNr    ; save
RepeatSpy
    mvx #0 TankNr
    stx SpyHardFlag    ; 0 - optimization
CheckNextTankSH
    cpx TargetTankNr
    beq ThisTankItsMe
    lda Energy,x    ; only active players
    beq ThisTankIsDead
    ; run SpyHard for tank in X
    jsr DisplaySpyInfo
    jsr FlashTank
@    jsr GetKey
    bit escFlag
    bmi SpyHardEnd
    cmp #@kbcode._space  ; $21 ; Space
    beq SpyHardEnd
    cmp #@kbcode._ret ; Return key (5200 - fire)
    beq SpyHardEnd
    cmp #@kbcode._left  ; $6
    beq SelectNextTank
    cmp #@kbcode._right  ; $07 ; cursor right
    bne @-
ThisTankIsDead
ThisTankItsMe
SelectNextTank
    inc TankNr
    ldx TankNr
    cpx NumberOfPlayers
    bne CheckNextTankSH
    beq RepeatSpy
SpyHardEnd
    mvx TargetTankNr TankNr ; restore
    jmp DisplaySpyInfo
    ; rts
.endp
.proc DisplaySpyInfo
    lda TankStatusColoursTable,x
    sta COLOR2  ; set color of status line
    jmp PutTankNameOnScreen
    ; jsr DisplayStatus    ; There is no need anymore, it is always after PutTankNameOnScreen
    ; rts
.endp
; -------------------------------------------------
.proc LazyBoys
; -------------------------------------------------
    mva #sfx_lazy_boys sfx_effect
    jsr PrepareAIShoot
    ldx TankNr
    bit LazyFlag
    bmi GoDarwin
    jsr FindBestTarget2 ; find nearest tank neighbour
    jsr LazyAim
    lda #%00000000    ; set "visual aiming" off
    beq EndLazy
GoDarwin
    jsr FindBestTarget3 ; find target with lowest energy
    jsr LazyAim
    lda #%10000000
EndLazy
    sta TestFlightFlag    ; set "visual aiming" on
    mva #0 LazyFlag
    rts
.endp
.proc LazyAim
    ; aiming proc for Lazy ... weapons
    ; as proc for memory optimisation
    ; Y - target tank nr
    ; A - target direction
    sty TargetTankNr
    ; aiming
    jsr TakeAimExtra        ; direction still in A (0 - left, >0 - right)
    lda Force
    sta ForceTableL,x
    lda Force+1
    sta ForceTableH,x
    jmp MoveBarrelToNewPosition
    ; rts
.endp
; -------------------------------------------------
.proc TankFlying
; -------------------------------------------------
; This routine is run from inside of the main loop
; and replaces Shoot and Flight routines
; X and TankNr - index of flying tank
; -------------------------------------------------
    ; Let's designate the flight altitude.
    jsr CheckMaxMountain
    cmp #(12+18) ; tank with shield (12) and max alt (18) check
    bcc IsToHigh
    sbc #12    ; tank with shield high correction
    bne StoreMaxAlt
IsToHigh
    lda #18
StoreMaxAlt
    sta FloatingAlt
;    mva #18 FloatingAlt    ; for testing
    mva #sfx_plasma_2_2 sfx_effect

    ; display text 4x4 - fuel full
    jsr SetFuelFullText
    jsr TypeLine4x4.variableLength

    ldx TankNr

    ; TankNr in X reg.
    ; now animate Up
    mva #0 modify    ;  it's a counter
TankGoUp
    lda ytankstable,x
    cmp FloatingAlt        ; Floating altitude
    bcc ReachSky
    ; first erase old tank position
    jsr ClearTankNr
    lda modify
    cmp #5
    bcc NoEngineClear
    mva #0 color
    jsr DrawTankRocketEngine
NoEngineClear
    dec ytankstable,x
    inc modify
    ; then draw tank on new position
    jsr PutTankNr
    lda modify
    cmp #5
    bcc NoEngine
    lda random
    and #%00000001
    sta color
    jsr DrawTankRocketEngine
NoEngine
;    jsr WaitOneFrame
    jmp TankGoUp

ReachSky
    ; engine symbol erase
    mva #0 color
    jsr DrawTankRocketEngine

    ; display text 4x4 - fuel full (clear text)
    jsr SetFuelFullText
    lda #$00
    jsr TypeLine4x4.staplot4x4color
    ; and Soildown at the start (for correct mountaintable if tank was buried)
    ; calculate range
    ldx TankNr
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
    jsr SoilDown
    jsr ClearScreenSoilRange
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
    bne LotOfFuel

    ; display text 4x4 - low fuel
    jsr SetLowFuelText
    jsr TypeLine4x4.variableLength

LotOfFuel
notpressed
    jsr CheckExitKeys
    spl:rts ;---Exit key pressed-quit game---
    ldx TankNr

    ; let's animate "engine"
    jsr DrawTankEngine
    ; enimation ends

    jsr GetKeyFast
    cmp #@kbcode._left  ; $6
    jeq pressedLeft
    cmp #@kbcode._right  ; $7
    jeq pressedRight
    cmp #@kbcode._space  ; $21
    jeq pressedSpace
    cmp #@kbcode._ret  ; Fire (Joy)
    jeq pressedSpace
    jmp notpressed

pressedRight
    lda ShieldEnergy,x
    jeq pressedSpace
    ldy #1
    jsr DecreaseShieldEnergyX
    ; first erase old tank position
    jsr ClearTankNr
    mva #0 Erase
    lda XtankstableH,x
    cmp #>(screenwidth-TankWidth-4)    ; tank width correction +4
    bne @+
    lda XtankstableL,x
    cmp #<(screenwidth-TankWidth-4)    ; tank width correction +4 pixels
@    bcs RightScreenEdge
    inc XtankstableL,x
    sne:inc XtankstableH,x
    jmp NoREdge
RightScreenEdge
    mva #sfx_dunno sfx_effect
NoREdge
    mva #18 AngleTable,x
    bne DrawFloatingTank    ; then draw tank on new position

pressedLeft
    lda ShieldEnergy,x
    beq pressedSpace
    ldy #1
    jsr DecreaseShieldEnergyX
    ; first erase old tank position
    jsr ClearTankNr
    lda XtankstableH,x
    cmp #0
    bne @+
    lda XtankstableL,x
    cmp #5    ; 4 pixles from left edge
@    bcc LeftScreenEdge
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
DrawFloatingTank
    jsr PutTankNr
    jsr DisplayStatus
    jsr WaitOneFrame
    jsr CalculateSoildown
    jmp KeyboardAndJoyCheck

pressedSpace
    ; display text 4x4 - low fuel (clear text)
    jsr SetLowFuelText
    lda #$00
    jsr TypeLine4x4.staplot4x4color
    ldx TankNr
    ;=================================
    ; left or right from center of screen ?
    ldy #0
    lda XtankstableH,x
    cmp #>((screenwidth/2)-TankWidth)
    bne @+
    lda XtankstableL,x
    cmp #<((screenwidth/2)-TankWidth)
@    bcc TankOnLeftSide
TankOnRightSide
    dey
TankOnLeftSide
    sty OverTankDir ;  (0 go right, $ff go left)
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
    sbc #9        ; 2 pixels more on left side + tank width
    tay
    lda xtankstableH,x
    sbc #0
    bpl GreaterThanZero
    ; bmi ShieldOverLeftEdge    ; I do not know whether to check it. Probably not :) !!!
    ldy #0
    tya
GreaterThanZero
    cmp xdraw+1
    bne @+
    cpy xdraw
@
    bcs LeftFromTheTank
    tya    ;add 20 (tank size*2 +2 and +2)
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
    jsr ClearTankNr
    bit OverTankDir
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
    jsr PutTankNr
    jmp CheckForTanksBelow
RightFromTheTank
LeftFromTheTank
DeadTank
ItIsMe
    dex
    bpl CheckCollisionWithTankLoop
    ldx TankNr
    mva #sfx_shield_off sfx_effect
    jsr ClearTankNr
    ; x correction for P/M
    ; --
    .IF XCORRECTION_FOR_PM = 1
    lda XtankstableL,x
    and #%11111110        ; correction for PM
    sta XtankstableL,x
    .ENDIF
    ; --
GoDown
    mvy #0 Erase    ; Y=0
;    mwa #mountaintable temp
    clc
    lda #<mountaintable
    adc XtankstableL,x
    sta temp
    lda #>mountaintable
    adc XtankstableH,x
    sta temp+1
    adw temp #4     ;    center of the tank
    ;ldy #0
    lda (temp),y
    tay
    dey ; 1 pixel up!
    sty OverTankDir    ; not elegant!!! Reuse as height of tank flight
FloatDown
    lda ytankstable,x
    cmp OverTankDir
    bcs OnGround
    ; first erase old tank position
    jsr ClearTankNr
    jsr DrawTankParachute
    inc ytankstable,x
    ; then draw tank on new position
    jsr PutTankNr
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
    ; If tank did not fly at maximum altitude there is no need to soildown to much
    lda FloatingAlt
    cmp #18
    beq NotHighest
SoilDownAfterLanding
    jsr ClearScreenSoilRange
NotHighest
    ; calculate range
    jsr CalculateSoildown
    ; hide tanks and ...
    jsr SoilDown
    ldx TankNr
    rts

CalculateSoildown
    ldx TankNr
    clc
    lda XtankstableL,x
    adc #4
    sta xdraw
    lda XtankstableH,x
    adc #0
    sta xdraw+1
    mva #$04 ExplosionRadius
    jmp CalculateExplosionRange
    ; rts

SetFuelFullText
    mwa #hoverFull LineAddress4x4
    mwa #((ScreenWidth/2)-((hoverFullEnd-hoverFull)*2)) LineXdraw  ; centering
    mva #hoverFullEnd-hoverFull fx ; length
    bne SetTextLevel    ; !! length<>0
SetLowFuelText
    mwa #hoverEmpty LineAddress4x4
    mwa #((ScreenWidth/2)-((hoverEmptyEnd-hoverEmpty)*2)) LineXdraw  ; centering
    mva #hoverEmptyEnd-hoverEmpty fx ; length
SetTextLevel
    sec
    lda FloatingAlt
    sbc #12
    sta LineYdraw
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
    sbc #3 ; hitbox height
    cmp ydraw
    bcs OverTheTank
    ; with or without shield ?

    lda ActiveDefenceWeapon,x
    cmp #ind_Mag_Deflector      ; first shielded weapon
    bcc CheckCollisionWithNotShieldedTank
    cmp #ind_Bouncy_Castle+1    ; last shielded weapon
    bcc CheckCollisionWithShieldedTank    ; tank with shield is bigger :)

    ;lda ShieldEnergy,x        ; there is wrong method to check shield :)
    ;bne CheckCollisionWithShieldedTank    ; tank with shield is bigger :)

CheckCollisionWithNotShieldedTank
    lda xtankstableH,x
    cmp xdraw+1
    bne @+
    lda xtankstableL,x
    cmp xdraw
@
    bcs LeftFromTheTank
    ; add 8 double byte
    ; now we use Y as low byte and A as high byte of checked position (right edge of tank)
    ; it is tricky but fast and much shorter
    clc
    lda xtankstableL,x
    adc #TankWidth
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
    stx HitFlag        ; index of hit tank+1
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
    sbc #4        ; 5 pixels more on left side
    tay
    lda xtankstableH,x
    sbc #0
    ; bmi ShieldOverLeftEdge    ; I do not know whether to check it. Probably not :) !!!
    cmp xdraw+1
    bne @+
    cpy xdraw
@
    bcs LeftFromTheTank
    tya    ;add 16 double byte
    clc
    adc #TankWidth+4+4
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
    jsr ClearScreenSoilRange
;--------------------------------------------------
.proc CalculateExplosionRange
;--------------------------------------------------
;calculates total horizontal range of explosion by
;"summing up" ranges of all separate explosions

    ; WeaponRangeRight = xdraw + ExplosionRadius
    clc
    lda xdraw
    adc ExplosionRadius
    sta WeaponRangeRight
    lda xdraw+1
    adc #$00
    sta WeaponRangeRight+1
    ; adw xdraw ExplosionRadius WeaponRangeRight  ; Pozor! ExplosionRadius is one byte now
    ; cpw WeaponRangeRight #screenwidth-1
    cmp #>(screenwidth-1)
    bne @+
    lda WeaponRangeRight
    cmp #<(screenwidth-1)
@    bcc NotOutOfTheScreenRight
    mwa #screenwidth-1 WeaponRangeRight

NotOutOfTheScreenRight
    ; WeaponRangeLeft = xdraw - ExplosionRadius
    sec
    lda xdraw
    sbc ExplosionRadius
    sta WeaponRangeLeft
    lda xdraw+1
    sbc #$00
    sta WeaponRangeLeft+1
    ; sbw xdraw ExplosionRadius WeaponRangeLeft  ; Pozor! ExplosionRadius is one byte now
    ; lda WeaponRangeLeft+1
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
.proc SetFullScreenSoilRange
; whole screen in range of soil down
;--------------------------------------------------
    lda #0
    sta RangeLeft
    sta RangeLeft+1
    mwa #screenwidth RangeRight
    rts
.endp
;--------------------------------------------------
.proc ClearScreenSoilRange
; cleanup of the soil fall down ranges (left and right)
;--------------------------------------------------
    mwa #screenwidth RangeLeft
    lda #0
    sta RangeRight
    sta RangeRight+1
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
    rts
.endp

;--------------------------------------------------
.proc DecreaseWeapon
; in: A: Weapon number, TankNr
; out: A: number of shells left, Y: weapon number
; decreases 1 bullet from a weapon(A) of tank(TankNr)
;--------------------------------------------------
    jsr HowManyBullets
    beq noBullets     ; no bullets - no decreasing (additional check)
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


    .ENDIF
