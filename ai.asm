.IF *>0 ;this is a trick that prevents compiling this file alone

;    @com.wudsn.ide.asm.mainsourcefile=scorch.asm

; artificial intelligence of tanks goes here!
; in A there is a level of tank's intelligence
; 1-moron, ..., 7-cyborg, 8-UNKNOWN (the best of all)
; at the moment (2003-08-15) I have no idea how
; to program better opponents, but moron is easy -
; - shoots random direction and force
; greeeting to myself 10 years older in 2013-11-09... still no idea

;----------------
AIRoutines
    .word Moron-1
    .word Shooter-1 ;Shooter
    .word Poolshark-1 ;Poolshark
    .word Tosser-1 ;Tosser
    .word Chooser-1 ;Chooser
    .word Spoiler-1 ;Spoiler
    .word Cyborg-1 ;Cyborg
    .word Unknown-1 ;Unknown
;----------------
PurchaseAIRoutines
    .word MoronPurchase-1
    .word ShooterPurchase-1 ;ShooterPurchase
    .word PoolsharkPurchase-1 ;PoolsharkPurchase
    .word TosserPurchase-1 ;TosserPurchase
    .word TosserPurchase-1 ;ChooserPurchase
    .word CyborgPurchase-1 ;SpoilerPurchase
    .word CyborgPurchase-1 ;CyborgPurchase
    .word TosserPurchase-1 ;UnknownPurchase

;----------------------------------------------
.proc ArtificialIntelligence ;
; A - skill of the TankNr (in X)
; returns shoot energy and angle in
; ForceTable/L/H and AngleTable
;----------------------------------------------
    asl
    tay
    lda AIRoutines-1,y  ; -1 and -2 because AI players are numbered from 1 not from 0 (Human)
    pha
    lda AIRoutines-2,y
    pha
;    it's no necessary - PrepareAIShoot is next proc :)
;    jsr PrepareAIShoot
;    rts
.endp
;----------------------------------------------
.proc PrepareAIShoot
    ; create low precision table of positions
    ; by dividing positions by 4
    ldy #MaxPlayers-1
loop
    ;= /4
    lda xtankstableH,y
    lsr
    lda xtankstableL,y
    ror ;just one bit over 256. Max screenwidth = 512!!!
    lsr
    sta LowResDistances,y
    dey
    bpl loop

    ; common values used in AI routines
    ; address of weapons table (for future use)
WepTableToTemp
    lda TanksWeaponsTableL,x
    sta temp
    lda TanksWeaponsTableH,x
    sta temp+1
    rts
.endp
;----------------------------------------------
.proc Unknown
    ; random robotank (from Poolshark to Cyborg)
    randomize 3 7
    bne ArtificialIntelligence  ; We know that PrepareAIShoot is already done, but.... who cares :)
.endp
;----------------------------------------------
.proc Moron
    jsr RandomizeAngle
    sta NewAngle
    mwa #180 RandBoundaryLow
    mwa #800 RandBoundaryHigh
    jsr RandomizeForce
    ; choose the best weapon
    ldy #ind_Buy_me         +1    ; if the cheat is active it will fire the BFG :)
    jmp ChooseBestOffensive.NotFromAll
    ;rts
.endp
;----------------------------------------------
.proc Shooter

    lda PreviousAngle,x
    ora PreviousEnergyL,x
    ora PreviousEnergyH,x
    beq firstShoot

    lda PreviousAngle,x
    cmp #90
    bcs shootingLeftAtThisMomentOfTime
    ; shooting right at this moment of time
    sec
    sbc #5
    cmp #10
    bcs @+ ;not smaller than 10
    bcc firstShoot ; GET THE aim againg

shootingLeftAtThisMomentOfTime

    clc
    adc #5
    cmp #170  ; maximum shooter angle
    bcs firstShoot
@
    sta NewAngle

    sec
    lda PreviousEnergyL,x
    sbc #5
    sta ForceTableL,x
    lda PreviousEnergyH,x
    sbc #0
    sta ForceTableH,x
    jmp endo

firstShoot
    ; compare the x position with the middle of the screen
    lda LowResDistances,x
    cmp #(screenwidth/8) ; screenwidth/2 but LowResDistances are already /4
    bcc tankIsOnTheRight

    ; enemy tank is on the left
    ;randomize 95 125
    lda RANDOM  ; Shorter an faster randomize
    and #%00011111  ; 0 - 31
    adc #95     ; Carry doesn't matter :)
    sta NewAngle
    bne forceNow

tankIsOnTheRight
    ;randomize 55 85
    lda RANDOM  ; Shorter an faster randomize
    and #%00011111  ; 0 - 31
    adc #54     ; Carry doesn't matter :)
    sta NewAngle

forceNow
    mwa #200 RandBoundaryLow
    mwa #800 RandBoundaryHigh
    ;ldx TankNr ;this is possibly not necessary
    jsr RandomizeForce

endo
    ;ldx TankNr ;this is possibly not necessary
    jsr RandomizeForce.LimitForce
    lda NewAngle
    sta PreviousAngle,x
    lda ForceTableL,x
    sta PreviousEnergyL,x
    lda ForceTableH,x
    sta PreviousEnergyH,x

    ; choose the best weapon

    jmp ChooseBestOffensive
    ;rts
    .endp
;----------------------------------------------
.proc Poolshark
    jsr UseBatteryOrFlag
    ; defensives
    jsr PoolsharkDefensives
firstShoot
    ;find nearest tank neighbour
    jsr FindBestTarget2
    beq EnemyOnLeft
    ; calculate index to shotangle table
    ; in temp2 we have x distance divided by 8
    lda temp2
    :3 lsr @
    and #%00000111
    clc
    adc #8
    sta AngleTablePointer
    bne AngleIsSet
EnemyOnLeft
    lda temp2
    :3 lsr @
    and #%00000111
    eor #%00000111
    sta AngleTablePointer
AngleIsSet

    ;randomize 0 8
    lda RANDOM
    and #%00000111
    ldy AngleTablePointer
    clc
    adc AngleTable,y
    sta NewAngle

    mwa #300 RandBoundaryLow
    mwa #700 RandBoundaryHigh
    ; ldx TankNr  ; looks like not necessary
    jsr RandomizeForce

    ; choose the best weapon

    jmp ChooseBestOffensive
    ; rts

;----------------------------------------------
AngleTable    ; 16 bytes ;ba w $348b L$3350
    .by 91,99,107,115,123,131,139,147
    .by 25,33,41,49,57,65,73,81
.endp
;----------------------------------------------
.proc CyborgBattery
    ; cyborg is smarter :)
    ; if have more than 2 batteries and less than 60 of energy
    ; then uses battery
    lda Energy,x
    cmp #60
    bcs EnoughEnergy
    ; lower than 60 units - check battery
    ldy #ind_Battery
    lda (temp),y  ; has address of TanksWeaponsTable
    cmp #2
    ; we have more than 2 batteries - use one
    bcs UseBattery.UseIt
EnoughEnergy
LowBatteries
    ; if low energy ten use battery (no RTS :) )
.endp
;
.proc UseBatteryOrFlag
    jsr UseBattery    ; as subroutine for reuse in AutoDefense
    ; if very low energy and no battery then use White Flag
    lda Energy,x
    cmp #5
    bcs EnoughEnergy
    ; lower than 5 units - white flag
    jsr ClearTankNr    ; we must hide tank to erase shields (issue #138)
    lda #ind_White_Flag
    sta ActiveDefenceWeapon,x
    jsr PutTankNr    ; and draw tank witch Flag
EnoughEnergy
;    jsr DisplayStatus.DisplayEnergy ; not necessary - status update after othher defensives
    rts
.endp
;
.proc UseBattery
    ; if low energy ten use battery
    lda Energy,x
    cmp #30
    bcs EnoughEnergy
    ; lower than 30 units - check battery
    ldy #ind_Battery
    lda (temp),y  ; has address of TanksWeaponsTable
    beq NoBatteries
    ; we have batteries - use one
UseIt
    sec
    sbc #1
    sta (temp),y
    lda #99
    sta Energy,x
    jsr MaxForceCalculate
    ; and SFX
    mva #sfx_battery sfx_effect
    ldy #7
    jsr PauseYFrames    ; wait 14 frames (Battery SFX)
EnoughEnergy
NoBatteries
    rts
.endp
;----------------------------------------------
.proc PoolsharkDefensives
    ; use best defensive :)
    ; but not allways
    randomize 1 3
    cmp #1
    bne UseBattery.NoBatteries  ; nearest RTS
    ; now use defensive like Tosser
    ;jmp TosserDefensives
.endp
;----------------------------------------------
.proc TosserDefensives
    ; use best defensive :)
    ; allways
    jsr GetBestDefensive
    ; update status line
    jmp DisplayStatus   ; jsr/rts
;    rts
.endp
;----------------------------------------------
.proc GetBestDefensive
    ; first check check if any is in use
    lda ActiveDefenceWeapon,x
    bne DefensiveInUse
    ldy #last_real_defensive+1 ;the last defensive weapon
@
    dey
    cpy #ind_Hovercraft      ;first defensive weapon    (White Flag, Battery and Hovercraft - never use)
    beq NoUseDefensive
    lda (temp),y  ; has address of TanksWeaponsTable
    beq @-
    ; decrease in inventory
    sec
    sbc #1
    sta (temp),y  ; has address of TanksWeaponsTable
    ; activate defensive weapon
    tya        ; number of selectet defensive weapon
    sta ActiveDefenceWeapon,x
    lda DefensiveEnergy,y
    sta ShieldEnergy,x
    ; and SFX
    mva #sfx_auto_defense sfx_effect
    ldy #7
    jsr PauseYFrames    ; wait 14 frames (Defense SFX)
DefensiveInUse
NoUseDefensive
    rts
.endp
;----------------------------------------------
.proc Tosser
    jsr UseBatteryOrFlag
    ; use best defensive :)
    jsr TosserDefensives
    ; Toosser is like Poolshark but allways uses defensives
    jmp Poolshark.firstShoot
.endp
;----------------------------------------------
.proc Chooser
    ; like cyborg but more randomizing force
    jsr UseBatteryOrFlag
    ; use defensives like Tosser
    jsr TosserDefensives
    ; now select best target
    lda #$00 ; no prefer humans
    jsr FindBestTarget3
    sty TargetTankNr
    ; aiming
    jsr TakeAim        ; direction still in A (0 - left, >0 - right)

    ; choose the best weapon
    jsr ChooseBestOffensive

    ; randomizing force +-100
    sbw Force #100 RandBoundaryLow
    bpl NotNegativeEnergy
    mwa #1 RandBoundaryLow
NotNegativeEnergy
    adw Force #100 RandBoundaryHigh
    jsr RandomizeForce
    ; if target distance lower than 24 - set weapon to Baby Missile (for security :)
    jmp GetDistance
    ;rts
.endp
;----------------------------------------------
.proc Spoiler
    ; like cyborg but little randomizing force
    jsr UseBatteryOrFlag
    ; use defensives like Tosser
    jsr TosserDefensives
    ; now select best target
    lda #$00 ; no prefer humans
    jsr FindBestTarget3
    sty TargetTankNr
    ; aiming
    jsr TakeAimExtra        ; direction still in A (0 - left, >0 - right)

    ; choose the best weapon
    jsr ChooseBestOffensive

    ; randomizing force +-50
    sbw Force #50 RandBoundaryLow
    bpl NotNegativeEnergy
    mwa #1 RandBoundaryLow
NotNegativeEnergy
    adw Force #50 RandBoundaryHigh
    jsr RandomizeForce
    ; if target distance lower than 24 - set weapon to Baby Missile (for security :)
    jmp GetDistance
    ;rts
.endp
;----------------------------------------------
.proc Cyborg
    ; if low energy ten use battery
    jsr CyborgBattery
    ; use defensives like Tosser
    jsr TosserDefensives
    ; now select best target
    lda #100    ; prefer humans
    jsr FindBestTarget3
    sty TargetTankNr
    ; aiming
    jsr TakeAimExtra        ; direction still in A (0 - left, >0 - right)
    ; choose the best weapon
    ldy #ind_Nuke           +1
    jsr ChooseBestOffensive.NotFromAll

    lda Force
    sta ForceTableL,x
    lda Force+1
    sta ForceTableH,x
    ; if target distance lower than 24 - set weapon to Baby Missile (for security :)
    jmp GetDistance
    ;rts
.endp

;----------------------------------------------
.proc FindBestTarget3
; find target with lowest energy
; X - shooting tank number
; A - 100 - prefer humans , 0 - equality :)
; returns target tank number in Y and
; direcion of shoot in A (0 - left, >0 - right)
;----------------------------------------------
    sta PreferHumansFlag
;    jsr MakeLowResDistances
    lda #202
    sta temp2 ; max possible energy
    stx temp2+1 ; set target tank to himself (if it doesn't find targets - Long Shlong :) )
    lda #0
    sta tempor2    ; direction of shoot
    ;ldx TankNr
    ldy NumberOfPlayers
    dey

loop01
    cpy TankNr
    beq skipThisPlayer
    lda eXistenZ,y
    beq skipThisPlayer
    lda BarrelLength,y
    cmp #LongBarrel     ; if target has Long Schlong do not aim
    beq skipThisPlayer
    lda skilltable,y
    beq ItIsHuman
    lda PreferHumansFlag
ItIsHuman
    clc
    adc Energy,y    ; if robotank energy=energy+100 (100 or 0 from PreferHumansFlag)
    cmp temp2 ; lowest
    beq lowestIsEqual
    bcc lowestIsHigher
    ; if lower
lowestIsEqual
    ; if equal then select random (of two tanks)
    bit RANDOM
    bmi lowestIsLower
lowestIsHigher
    sta temp2
    sty temp2+1 ; number of the closest tank
    mva #0 tempor2
    lda LowResDistances,x
    cmp LowResDistances,y
    bcs EnemyOnTheLeft
    ; enemy on right
    inc tempor2    ; set direction to right

EnemyOnTheLeft
lowestIsLower
skipThisPlayer
    dey
    bpl loop01
    ; now we have number of the farthest tank in temp2+1
    ; and direction (0 - left, >0 - right) in tempor2
    ; let's move them to registers
    ; in temp2 we have energy of target
    ldy temp2+1
    lda tempor2
    rts
.endp
;----------------------------------------------
.proc FindBestTarget2
; find nearest tank neighbour
; X - shooting tank number
; returns target tank number in Y and
; direcion of shoot in A (0 - left, >0 - right)
;----------------------------------------------
;    jsr MakeLowResDistances
    mva #$ff temp2 ; min possible distance
    stx temp2+1 ; set target tank to himself (if it doesn't find targets - Long Shlong :) )
    mva #0 tempor2    ; direction of shoot

    ;ldx TankNr
    ldy NumberOfPlayers
    dey

loop01
    cpy TankNr
    beq skipThisPlayer
    lda eXistenZ,y
    beq skipThisPlayer
    lda BarrelLength,y
    cmp #LongBarrel     ; if target has Long Schlong do not aim
    beq skipThisPlayer

    lda LowResDistances,x
    cmp LowResDistances,y
    bcs EnemyOnTheLeft
    ;enemy on the right
    sec
    lda LowResDistances,y
    sbc LowResDistances,x
    cmp temp2 ; lowest
    bcs lowestIsLower
    sta temp2
    sty temp2+1 ; number of the closest tank
    inc tempor2    ; set direction to right
    bne lowestIsLower

EnemyOnTheLeft
    sec
    lda LowResDistances,x
    sbc LowResDistances,y
    cmp temp2 ; lowest
    bcs lowestIsLower
    sta temp2
    sty temp2+1 ; number of the closest tank

lowestIsLower
skipThisPlayer
    dey
    bpl loop01
    ; now we have number of the closest tank in temp2+1
    ; and direction (0 - left, >0 - right) in tempor2
    ; let's move them to registers
    ; in temp2 we have x distance divided by 8
    ldy temp2+1
    lda tempor2
End rts
.endp

;----------------------------------------------
.proc TakeAim
; targeting the tank number TargetTankNr (and Y)
; A (and tempor2) - direction from shooting tank (0 - left, >0 - right)
; returns angle and power of shoot tank X (TankNr)
; in the appropriate variables (Angle and Force)
;----------------------------------------------
    lda ActiveDefenceWeapon,x 
    cmp #ind_White_Flag     ; if a white flag, targeting makes no sense
    beq FindBestTarget2.End ; nearest RTS
;
    mva #$ff SecondTryFlag
NoSecondTry
    lda ActiveWeapon,x
    pha                    ; store active weapon
    ; set initial Angle and Force values
    lda OptionsTable+2    ; selected gravity
    asl
    tay
    ; force correction - lower tank Y position - higher possible force
    sec
    lda #screenheight
    sbc Ytankstable,x
    sta temp2
    clc
    lda AIForceTable,y
    sta RandBoundaryLow
    adc temp2
    sta RandBoundaryHigh
    lda AIForceTable+1,y
    sta RandBoundaryLow+1
    adc #0
    sta RandBoundaryHigh+1
    jsr RandomizeForce
RepeatAim
    jsr Table2Force
    ; wind correction 90+(wind/8)
    mwa Wind temp2
    :7 lsrw temp2
    clc
    lda #90
    adc temp2
    sta NewAngle
    ; set virtual weapon :)
    lda #ind_Baby_Missile
    sta ActiveWeapon,x
    ; now we have initial valuses
    mva #%11000000 TestFlightFlag
    ; check targeting direction
    lda tempor2
    jne AimingLeft
AimingRight
    ; make test Shoot (Flight)
    jsr SetStartAndFlight
    bit escFlag
    bmi EndOfAim
    lda HitFlag
    beq NoHitInFirstLoopR    ; impossible :)
    bmi GroundHitInFirstLoopR
TankHitInFirstLoopR
    ; tank hit, but which tank?
    ; it's our target or not?
    ldy HitFlag
    dey
    cpy TargetTankNr
    beq EndOfFirstLoopR    ; it's our target!
    ; if it's another tank then check position like ground hit
GroundHitInFirstLoopR
    ; checking only x position of hit
    ldy TargetTankNr
    lda xTanksTableH,y
    cmp XHit+1
    bne @+
    lda xTanksTableL,y
    cmp XHit
@
    bcs HitOnRightSideOfTargetR
    ; continue targeting
    clc
    lda NewAngle
    adc #5    ; 5 deg to right
    cmp #(180-20)
;    bcs EndOfFirstLoopR    ; if angle 180-20 or higher
    bcs AimSecondTry
    sta NewAngle
    jmp AimingRight
NoHitInFirstLoopR
    ; Angle 5 deg to left and end loop
    sec
    lda NewAngle
    sbc #5
    sta NewAngle
HitOnRightSideOfTargetR
    dec NewAngle
EndOfFirstLoopR
    mva #5 modify    ; set counter (5 turns)
SecondLoopR
    ; make test Shoot (Flight)
    jsr SetStartAndFlight
    bit escFlag
    bmi EndOfAim
    lda HitFlag
    beq NoHitInSecondLoopR    ; impossible :)
    bmi GroundHitInSecondLoopR
TankHitInSecondLoopR
    ; tank hit, but which tank?
    ; it's our target or not?
    ldy HitFlag
    dey
    cpy TargetTankNr
    beq EndOfSecondLoopR    ; it's our target!
    ; if it's another tank then check position like ground hit
GroundHitInSecondLoopR
    ; checking only x position of hit
    ldy TargetTankNr
    lda xTanksTableH,y
    cmp XHit+1
    bne @+
    lda xTanksTableL,y
    cmp XHit
@
    bcc HitOnLeftSideOfTargetR
    ; continue targeting
    dec NewAngle    ; 1 deg to left
    dec modify    ; max 5 turns
    beq EndOfSecondLoopR
    jmp SecondLoopR
HitOnLeftSideOfTargetR
    ; decrease energy (a little)
    sbw Force #5
NoHitInSecondLoopR
    ; Angle 1 deg to right and end loop
    inc NewAngle
EndOfSecondLoopR
EndOfAim
    pla                    ; and restore active weapon
    sta ActiveWeapon,x
    rts

AimSecondTry
    bit SecondTryFlag
    bpl EndOfAim    ; closest RTS
    inc SecondTryFlag
    lda #<1000
    sta ForceTableL,x
    lda #>1000
    sta ForceTableH,x
    jsr RandomizeForce.LimitForce
    jmp RepeatAim

AimingLeft
    ; make test Shoot (Flight)
    jsr SetStartAndFlight
    bit escFlag
    bmi EndOfAim
    lda HitFlag
    beq NoHitInFirstLoopL    ; impossible :)
    bmi GroundHitInFirstLoopL
TankHitInFirstLoopL
    ; tank hit, but which tank?
    ; it's our target or not?
    ldy HitFlag
    dey
    cpy TargetTankNr
    beq EndOfFirstLoopL    ; it's our target!
    ; if it's another tank then check position like ground hit
GroundHitInFirstLoopL
    ; checking only x position of hit
    ldy TargetTankNr
    lda xTanksTableH,y
    cmp XHit+1
    bne @+
    lda xTanksTableL,y
    cmp XHit
@
    bcc HitOnLeftSideOfTargetL
    ; continue targeting
    sec
    lda NewAngle
    sbc #5    ; 5 deg to left
    cmp #21
;    bcc EndOfFirstLoopL    ; if angle 20 or lower
    bcc AimSecondTry
    sta NewAngle
    jmp AimingLeft
NoHitInFirstLoopL
    ; Angle 5 deg to right and end loop
    clc
    lda NewAngle
    adc #5
    sta NewAngle
HitOnLeftSideOfTargetL
    inc NewAngle
EndOfFirstLoopL
    mva #5 modify    ; set counter (5 turns)
SecondLoopL
    ; make test Shoot (Flight)
    jsr SetStartAndFlight
    bit escFlag
    bmi EndOfAim
    lda HitFlag
    beq NoHitInSecondLoopL    ; impossible :)
    bmi GroundHitInSecondLoopL
TankHitInSecondLoopL
    ; tank hit, but which tank?
    ; it's our target or not?
    ldy HitFlag
    dey
    cpy TargetTankNr
    beq EndOfSecondLoopL    ; it's our target!
    ; if it's another tank then check position like ground hit
GroundHitInSecondLoopL
    ; checking only x position of hit
    ldy TargetTankNr
    lda xTanksTableH,y
    cmp XHit+1
    bne @+
    lda xTanksTableL,y
    cmp XHit
@
    bcs HitOnRightSideOfTargetL
    ; continue targeting
    inc NewAngle    ; 1 deg to right
    dec modify    ; max 5 turns
    beq EndOfSecondLoopL
    jmp SecondLoopL
HitOnRightSideOfTargetL
    ; decrease energy (a little)
    sbw Force #5
NoHitInSecondLoopL
    ; Angle 1 deg to left and end loop
    dec NewAngle
EndOfSecondLoopL
    jmp EndOfAim

SetStartAndFlight    ; set start point (virtual barrel end :) ) and make test flight
    ; xtraj+1 and ytraj+1 set
    clc
    lda xTanksTableL,x
    adc #4
    sta xtraj+1
    lda xTanksTableH,x
    adc #0
    sta xtraj+2
    sec
    lda yTanksTable,x
    sbc #4
    sta ytraj+1
    mva #0 ytraj+2
    mva NewAngle Angle
    jsr CheckStartKey ; START KEY
    beq @speedup
    jsr MoveBarrelToNewPosition
    bit escFlag
    bmi exit
@speedup
    jsr Flight
exit
    ldx TankNr
    rts
.endp
;----------------------------------------------
.proc TakeAimExtra
; It triggers aiming and if it misses the target, 
; repeats the targeting by aiming at other tanks.
;----------------------------------------------
    jsr TakeAim ; standard aiming first
    ldy HitFlag
    bpl TankHit
    ; Target missed - repeat aiming
    mva TargetTankNr FirstTargetTankNr
    ldy NumberOfPlayers
    dey
SetNextTarget
    cpy TankNr  ; Don't aim at yourself
    beq skipThisPlayer
    cpy FirstTargetTankNr   ; Don't aim at the original target
    beq skipThisPlayer
    lda eXistenZ,y
    beq skipThisPlayer
    lda BarrelLength,y
    cmp #LongBarrel     ; if target has Long Schlong do not aim
    beq skipThisPlayer
    ; check target direction
    mva #0 tempor2  ; check target direction
    lda LowResDistances,x
    cmp LowResDistances,y
    bcs EnemyOnTheLeft
    ; enemy on right
    inc tempor2    ; set direction to right
EnemyOnTheLeft
    sty TargetTankNr    ; new target for aiming
    ; Go Aiming!
    jsr TakeAim.NoSecondTry ; standard aiming first (only first try)
    ldy TargetTankNr
    lda HitFlag
    bpl TankHit
skipThisPlayer
    dey
    bpl SetNextTarget
TankHit
    rts
.endp

;----------------------------------------------
.proc PurchaseAI ;
; A - skill of the TankNr, TankNr in X
; makes purchase for AI opponents
; results of this routine are not visible on the screen
;----------------------------------------------
    asl
    tay
    lda PurchaseAIRoutines-1,y  ; -1 and -2 because AI players are numbered from 1 not from 0 (Human)
    pha
    lda PurchaseAIRoutines-2,y
    pha
 ;   rts    ; MoronPurchase has rts :)
    .endp

;----------------------------------------------
.proc MoronPurchase
;Moron buys nothing
    rts
.endp
;-------
.proc TryToPurchaseOnePiece2    ; for Cyborg
    ; A - weapon number, better it will be in range(1,32)
    ; TankNr in X
    ; DOES NOT CHANGE X
    tay
    sta temp+1
    :3 lsr    ; A=A/8
    sta temp
;    tya    ; optimization (256 bytes long bittable)
;    and #%00000111
;    tay
    lda bittable1_long,y
    ldy temp
    and PurchaseMeTable2,y
    beq TryToPurchaseOnePiece.SorryNoPurchase
    jmp TryToPurchaseOnePiece.PurchaseIt
.endp
;-------
.proc TryToPurchaseOnePiece
    ; A - weapon number, better it will be in range(1,32)
    ; TankNr in X
    ; DOES NOT CHANGE X
    tay
    sta temp+1
    :3 lsr    ; A=A/8
    sta temp
;    tya    ; optimization (256 bytes long bittable)
;    and #%00000111
;    tay
    lda bittable1_long,y
    ldy temp
    and PurchaseMeTable,y
    beq SorryNoPurchase
PurchaseIt
    ldy temp+1
    lda WeaponPriceL,y
    sta temp
    lda WeaponPriceH,y
    sta temp+1
    ;price of the weapon in temp
    lda MoneyL,x
    sta temp2
    lda MoneyH,x
    sta temp2+1
    ;current monies in temp2
    cpw temp2 temp
    bcc SorryNoPurchase
    ; deduct monies from the bank account
    sec
    lda temp2
    sbc temp
    sta MoneyL,x
    lda temp2+1
    sbc temp+1
    sta MoneyH,x

    lda TanksWeaponsTableL,x
    sta temp
    lda TanksWeaponsTableH,x
    sta temp+1

    lda WeaponUnits,y
    clc
    adc (temp),y
    cmp #99 ;max number of weapon units
    bcc NotExceeded
    lda #99
NotExceeded
    sta (temp),y


SorryNoPurchase
    rts
    .endp


;----------------------------------------------
.proc ShooterPurchase
    ; first try to buy defensives
    randomize ind_Battery         ind_StrongParachute
    jsr TryToPurchaseOnePiece
    ; and now offensives
    mva #4 tempXroller; number of offensive purchases to perform
@
    randomize ind_Missile         ind_Heavy_Roller
    jsr TryToPurchaseOnePiece
    dec tempXroller
    bne @-

    rts
.endp
;----------------------------------------------
.proc PoolsharkPurchase
    ; first try to buy defensives
    randomize ind_Battery         ind_Bouncy_Castle
    jsr TryToPurchaseOnePiece
    dec tempXroller

    ; and now offensives
    mva #6 tempXroller; number of purchases to perform
    ;ldx TankNr
@
    randomize ind_Missile         ind_Dirt_Charge
    jsr TryToPurchaseOnePiece
    dec tempXroller
    bne @-

    rts
.endp
;----------------------------------------------
.proc TosserPurchase
    ; what is my money level
    lda MoneyH,x ; money / 256
    lsr        ; /2
    sta tempXroller ; perform this many purchase attempts
    ; first try to buy defensives
@
    randomize ind_Battery         ind_Bouncy_Castle
    jsr TryToPurchaseOnePiece
    dec tempXroller
    bpl @-

    ; and now offensives
    lda MoneyH,x ; money / 256
    asl  ;*2
    sta tempXroller ; perform this many purchase attempts
@
    randomize ind_Missile         ind_Dirt_Charge
    jsr TryToPurchaseOnePiece
    dec tempXroller
    bpl @-

    rts
.endp
;----------------------------------------------
.proc CyborgPurchase
    ; what is my money level
    lda MoneyH,x ; money / 256
    lsr        ; /2
    sta tempXroller ; perform this many purchase attempts
    ; first try to buy defensives
@
    randomize ind_Battery         ind_Bouncy_Castle
    jsr TryToPurchaseOnePiece2
    dec tempXroller
    bpl @-

    ; and now offensives
    lda MoneyH,x ; money / 256
    :3 asl  ;*8
    sta tempXroller ; perform this many purchase attempts
@
    randomize first_offensive     last_offensive
    jsr TryToPurchaseOnePiece2
    dec tempXroller
    bpl @-

    rts
.endp
;----------------------------------------------
.proc ChooseBestOffensive
; choose the best weapon
; X - TankNr
;----------------------------------------------
    ldy #ind_Dirt_Charge    +1 ;the last weapon to choose +1    (not BFG or Laser :) )
NotFromAll
; Y - the last offensive weapon to use + 1
    lda TanksWeaponsTableL,x
    sta temp
    lda TanksWeaponsTableH,x
    sta temp+1
loop
    dey
    lda (temp),y
    beq loop
    tya
    sta ActiveWeapon,x
    rts
.endp
;----------------------------------------------
.proc GetDistance
; calculates lores ( /4 ) distance from tank X to last plot
; (explosion position after Flight proc)
; This procedure must be called immediately after targeting.
; xdraw value should remain unchanged from the end of the Flight procedure.
;
; if target distance lower than 24 - set weapon to Baby Missile
;----------------------------------------------
    ;xdraw/4
    lda xdraw+1
    lsr
    lda xdraw
    ror ;just one bit over 256. Max screenwidth = 512!!!
    lsr
    ;
    sec
    sbc LowResDistances,x
    bcs XisLower
YisLower
    eor #$ff
    adc #1
XisLower
    ;rts
    cpx TargetTankNr    ; If tank is aiming at itself don't change weapon,
    beq NoChangeToBM    ; he is the only one without a Long Shlong :)
    ; if target distance lower than 24 - set weapon to Baby Missile (for security :)
    cmp #6    ; 24/4
    bcs HighDistance
    lda #ind_Baby_Missile
    sta ActiveWeapon,x
HighDistance
NoChangeToBM
    rts
.endp

.ENDIF