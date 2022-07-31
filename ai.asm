;	@com.wudsn.ide.asm.mainsourcefile=scorch.asm

; artificial intelligence of tanks goes here!
; in A there is a level of tank's intelligence
; 1-moron, ..., 7-cyborg, 8-UNKNOWN (the best of all)
; at the moment (2003-08-15) I have no idea how
; to program better opponents, but moron is easy -
; - shoots random direction and force
; greeeting to myself 10 years older in 2013-11-09... still no idea

;----------------------------------------------
.proc MakeLowResDistances 
	; create low precision table of positions
	; by dividing positions by 4

	ldy #MaxPlayers-1
loop
	lda xtankstableL,y
	sta temp
	lda xtankstableH,y
	sta temp+1
	
	;= /4
	:2 lsrw temp
	lda temp
	sta LowResDistances,y
	dey
	bpl loop
	rts
.endp

;----------------------------------------------
.proc ArtificialIntelligence ;
; A - skill of the TankNr (in X)
; returns shoot energy and angle in
; ForceTable/L/H and AngleTable
;----------------------------------------------
    asl
    tay
    :2 dey  ;credit KK
    lda AIRoutines+1,y
    pha
    lda AIRoutines,y
    pha

    ; common values used in AI routines
    ; address of weapons table (for future use)
    lda TanksWeaponsTableL,x
    sta temp
    lda TanksWeaponsTableH,x
    sta temp+1
	rts
.endp
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

;----------------------------------------------
.proc Unknown
	; random robotank (from Poolshark to Cyborg)
	randomize 4 13
	and #%11111110
	tay
    lda AIRoutines+1,y
    pha
    lda AIRoutines,y
    pha
	rts
.endp
;----------------------------------------------
.proc Moron 
    jsr RandomizeAngle
    sta NewAngle
    mwa #80 RandBoundaryLow
    mwa #800 RandBoundaryHigh 
    jsr RandomizeForce
    rts
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
    lda xTanksTableH,x
    cmp #>(screenwidth/2)
    bne @+
	lda xTanksTableL,x
	cmp #<(screenwidth/2)
@	bcc tankIsOnTheRight

    ; enemy tank is on the left
	randomize 95 125
	sta NewAngle
	bne forceNow

tankIsOnTheRight
    randomize 55 85
    sta NewAngle
	
forceNow
    mwa #100 RandBoundaryLow
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
	
	ldy #32 ;the last  weapon	
loop
	dey
	lda (temp),y  ; this is set up before calling the routine, has address of TanksWeaponsTable
	beq loop 
	tya
	sta ActiveWeapon,x
    rts
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
	
	randomize 0 8
	ldy AngleTablePointer
	clc
	adc AngleTable,y
	sta NewAngle
	
forceNow
    mwa #300 RandBoundaryLow
    mwa #700 RandBoundaryHigh 
    ldx TankNr
    jsr RandomizeForce

endo
	;ldx TankNr ;this is possibly not necessary
	
	; choose the best weapon
	
	lda TanksWeaponsTableL,x
	sta temp
	lda TanksWeaponsTableH,x
	sta temp+1
	ldy #ind_Laser__________ ;the last offensive weapon	
loop
	dey
	lda (temp),y
	beq loop 
	tya
	sta ActiveWeapon,x
    rts
    
;----------------------------------------------
AngleTable	; 16 bytes ;ba w $348b L$3350
	.by 106,114,122,130,138,146,154,162
	.by 18,26,34,43,50,58,66,74
.endp
;----------------------------------------------
.proc UseBatteryOrFlag
	; if low energy ten use battery
	lda Energy,x
	cmp #30
	bcs EnoughEnergy
	; lower than 30 units - check battery
	ldy #ind_Battery________
	lda (temp),y  ; has address of TanksWeaponsTable
	beq NoBatteries
	; we have batteries - use one
	clc
	sbc #1
	sta (temp),y
	lda #99
	sta Energy,x
NoBatteries
	; if very low energy and no battery then use White Flag
	lda Energy,x
	cmp #5
	bcs EnoughEnergy
	; lower than 5 units - white flag
	lda #ind_White_Flag_____
	sta ActiveDefenceWeapon,x
EnoughEnergy
	rts
.endp
;----------------------------------------------
.proc PoolsharkDefensives
	; use best defensive :)
	; but not allways
	randomize 1 3
	cmp #1
	bne NoUseDefensive
	; first check check if any is in use
	lda ActiveDefenceWeapon,x
	bne DefensiveInUse
	ldy #ind_Nuclear_Winter_+1 ;the last defensive weapon
@
	dey
	cpy #ind_Battery________ ;first defensive weapon	(White Flag nad Battery - never use)
	beq NoUseDefensive
	lda (temp),y  ; has address of TanksWeaponsTable
	beq @- 
	; decrease in inventory
	clc
	sbc #1
	sta (temp),y  ; has address of TanksWeaponsTable
	; activate defensive weapon
	tya		; number of selectet defensive weapon
	sta ActiveDefenceWeapon,x
    lda DefensiveEnergy,y
    sta ShieldEnergy,x
NoUseDefensive
DefensiveInUse
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
.proc TosserDefensives
	; use best defensive :)
	; allways
	; first check check if any is in use
	lda ActiveDefenceWeapon,x
	bne DefensiveInUse
	ldy #ind_Nuclear_Winter_+1 ;the last defensive weapon	
@
	dey
	cpy #ind_Battery________ ;first defensive weapon	(White Flag nad Battery - never use)
	beq NoUseDefensive
	lda (temp),y  ; has address of TanksWeaponsTable
	beq @- 
	; decrease in inventory
	clc
	sbc #1
	sta (temp),y  ; has address of TanksWeaponsTable
	; activate defensive weapon
	tya		; number of selectet defensive weapon
	sta ActiveDefenceWeapon,x
    lda DefensiveEnergy,y
    sta ShieldEnergy,x
DefensiveInUse
NoUseDefensive
	rts
.endp
;----------------------------------------------
.proc Chooser
	; like cyborg but more randomizing force
	jsr UseBatteryOrFlag
	; use defensives like Tosser
	jsr TosserDefensives
	; now select best target
	jsr FindBestTarget3
	sty TargetTankNr
	; aiming
	jsr TakeAim		; direction still in A (0 - left, >0 - right)
	
	; choose the best weapon
	lda TanksWeaponsTableL,x
	sta temp
	lda TanksWeaponsTableH,x
	sta temp+1
	ldy #ind_LeapFrog_______ ;the last offensive weapon	to use
loop
	dey
	lda (temp),y
	beq loop 
	tya
	sta ActiveWeapon,x

	; randomizing force +-100
	sbw Force #100 RandBoundaryLow
	bpl NotNegativeEnergy
	mwa #1 RandBoundaryLow
NotNegativeEnergy
	adw Force #100 RandBoundaryHigh
    jsr RandomizeForce
	lda ForceTableH,x
	bne HighForce
	; if Force lower than 256 - set weapon to Baby Missile (for security :) )
	lda #ind_Baby_Missile___
	sta ActiveWeapon,x
HighForce
	rts
.endp
;----------------------------------------------
.proc Spoiler
	; like cyborg but little randomizing force
	jsr UseBatteryOrFlag
	; use defensives like Tosser
	jsr TosserDefensives
	; now select best target
	jsr FindBestTarget3
	sty TargetTankNr
	; aiming
	jsr TakeAim		; direction still in A (0 - left, >0 - right)
	
	; choose the best weapon
	lda TanksWeaponsTableL,x
	sta temp
	lda TanksWeaponsTableH,x
	sta temp+1
	ldy #ind_LeapFrog_______ ;the last offensive weapon	to use
loop
	dey
	lda (temp),y
	beq loop 
	tya
	sta ActiveWeapon,x

	; randomizing force +-50
	sbw Force #50 RandBoundaryLow
	bpl NotNegativeEnergy
	mwa #1 RandBoundaryLow
NotNegativeEnergy
	adw Force #50 RandBoundaryHigh
    jsr RandomizeForce
	lda ForceTableH,x
	bne HighForce
	; if Force lower than 256 - set weapon to Baby Missile (for security :) )
	lda #ind_Baby_Missile___
	sta ActiveWeapon,x
HighForce
	rts
.endp
;----------------------------------------------
.proc Cyborg
	jsr UseBatteryOrFlag
	; use defensives like Tosser
	jsr TosserDefensives
	; now select best target
	jsr FindBestTarget3
	sty TargetTankNr
	; aiming
	jsr TakeAim		; direction still in A (0 - left, >0 - right)
	
	; choose the best weapon
	lda TanksWeaponsTableL,x
	sta temp
	lda TanksWeaponsTableH,x
	sta temp+1
	ldy #ind_LeapFrog_______ ;the last offensive weapon	to use
loop
	dey
	lda (temp),y
	beq loop 
	tya
	sta ActiveWeapon,x

	lda Force
	sta ForceTableL,x
	lda Force+1
	sta ForceTableH,x
	bne HighForce
	; if Force lower than 256 - set weapon to Baby Missile (for security :) )
	lda #ind_Baby_Missile___
	sta ActiveWeapon,x
HighForce
	rts
.endp

;----------------------------------------------
.proc FindBestTarget3
; find target with lowest energy
; X - shooting tank number
; returns target tank number in Y and
; direcion of shoot in A (0 - left, >0 - right)
;----------------------------------------------
	jsr MakeLowResDistances
	lda #$ff
	sta temp2 ; max possible energy
	sta tempor2	; direction of shoot
	;ldx TankNr
	ldy NumberOfPlayers
	dey
	
loop01
	cpy TankNr
	beq skipThisPlayer
	lda eXistenZ,y
	beq skipThisPlayer
	
	lda LowResDistances,x
	cmp LowResDistances,y
	bcs EnemyOnTheLeft
	;enemy on the right
	lda Energy,y
	cmp temp2 ; lowest
	bcs lowestIsLower
	sta temp2
	sty temp2+1 ; number of the closest tank
	inc tempor2	; set direction to right
	bne lowestIsLower

EnemyOnTheLeft
	lda Energy,y
	cmp temp2 ; lowest
	bcs lowestIsLower
	sta temp2
	sty temp2+1 ; number of the closest tank
	
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
; find farthest tank neighbour
; X - shooting tank number
; returns target tank number in Y and
; direcion of shoot in A (0 - left, >0 - right)
;----------------------------------------------
	jsr MakeLowResDistances
	mva #$ff temp2 ; min possible distance
	mva #0 tempor2	; direction of shoot

	;ldx TankNr
	ldy NumberOfPlayers
	dey
	
loop01
	cpy TankNr
	beq skipThisPlayer
	lda eXistenZ,y
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
	inc tempor2	; set direction to right
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
	rts
.endp
;----------------------------------------------
.proc FindBestTarget1
; find farthest tank neighbour
; X - shooting tank number
; returns target tank number in Y and
; direcion of shoot in A (0 - left, >0 - right)
;----------------------------------------------
	jsr MakeLowResDistances
	lda #$00
	sta temp2 ; max possible distance
	sta tempor2	; direction of shoot
	;ldx TankNr
	ldy NumberOfPlayers
	dey
	
loop01
	cpy TankNr
	beq skipThisPlayer
	lda eXistenZ,y
	beq skipThisPlayer
	
	lda LowResDistances,x
	cmp LowResDistances,y
	bcs EnemyOnTheLeft
	;enemy on the right
	sec
	lda LowResDistances,y
	sbc LowResDistances,x
	cmp temp2 ; bigest
	bcc bigestIsBigger
	sta temp2
	sty temp2+1 ; number of the farthest tank
	inc tempor2	; set direction to right
	bne bigestIsBigger

EnemyOnTheLeft
	sec
	lda LowResDistances,x
	sbc LowResDistances,y
	cmp temp2 ; lowest
	bcc bigestIsBigger
	sta temp2
	sty temp2+1 ; number of the farthest tank
	
bigestIsBigger
skipThisPlayer
	dey
	bpl loop01
	; now we have number of the farthest tank in temp2+1
	; and direction (0 - left, >0 - right) in tempor2
	; let's move them to registers
	; in temp2 we have x distance divided by 8 
	ldy temp2+1
	lda tempor2
	rts
.endp
;----------------------------------------------
.proc TakeAim
; targeting the tank number TargetTankNr (and Y)
; A (and tempor2) - direction from shooting tank (0 - left, >0 - right)
; returns angle and power of shoot tank X (TankNr)
; in the appropriate variables (Angle and Force)
;----------------------------------------------
	; set initial Angle and Force values
	mva #90 NewAngle
	lda OptionsTable+2	; selected gravity
	asl 
	tay
	lda AIForceTable,y
	sta ForceTableL,x
	lda AIForceTable+1,y
	sta ForceTableH,x
    jsr RandomizeForce.LimitForce
	lda ForceTableL,x
	sta Force
	lda ForceTableH,x
	sta Force+1
	; now we have initial valuses
	mva #$ff TestFlightFlag
	; check targeting direction
	lda tempor2
	jeq AimingLeft
AimingRight
	; make test Shoot (Flight)
	jsr SetStartAndFlight
	lda HitFlag
	beq NoHitInFirstLoopR	; impossible :)
	bmi GroundHitInFirstLoopR
TankHitInFirstLoopR
	; tank hit, but which tank?
	; it's our target or not?
	ldy HitFlag
	dey
	cpy TargetTankNr
	beq EndOfFirstLoopR	; it's our target!
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
	bcc HitOnRightSideOfTargetR
	; continue targeting
	sec
	lda NewAngle
	sbc #5	; 5 deg to right
	cmp #15
	beq EndOfFirstLoopR
	sta NewAngle
	jmp AimingRight
NoHitInFirstLoopR
	; Angle 5 deg to left and end loop 
	clc
	lda NewAngle
	adc #5
	sta NewAngle	
HitOnRightSideOfTargetR
EndOfFirstLoopR
	mva #5 temp2	; set counter (5 turns)
SecondLoopR
	; make test Shoot (Flight)
	jsr SetStartAndFlight
	lda HitFlag
	beq NoHitInSecondLoopR	; impossible :)
	bmi GroundHitInSecondLoopR
TankHitInSecondLoopR
	; tank hit, but which tank?
	; it's our target or not?
	ldy HitFlag
	dey
	cpy TargetTankNr
	beq EndOfSecondLoopR	; it's our target!
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
	bcs HitOnLeftSideOfTargetR
	; continue targeting
	inc NewAngle	; 1 deg to left
	dec temp2	; max 5 turns
	beq EndOfSecondLoopR
	jmp SecondLoopR
HitOnLeftSideOfTargetR
	; decrease energy (a little)
	sbw Energy #5
NoHitInSecondLoopR
	; Angle 1 deg to right and end loop 
	dec NewAngle
EndOfSecondLoopR
	rts

AimingLeft
	; make test Shoot (Flight)
	jsr SetStartAndFlight
	lda HitFlag
	beq NoHitInFirstLoopL	; impossible :)
	bmi GroundHitInFirstLoopL
TankHitInFirstLoopL
	; tank hit, but which tank?
	; it's our target or not?
	ldy HitFlag
	dey
	cpy TargetTankNr
	beq EndOfFirstLoopL	; it's our target!
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
	bcs HitOnLeftSideOfTargetL
	; continue targeting
	clc
	lda NewAngle
	adc #5	; 5 deg to left
	cmp #(180-15)
	beq EndOfFirstLoopL
	sta NewAngle
	jmp AimingLeft
NoHitInFirstLoopL
	; Angle 5 deg to right and end loop 
	sec
	lda NewAngle
	sbc #5
	sta NewAngle	
HitOnLeftSideOfTargetL
EndOfFirstLoopL
	mva #5 temp2	; set counter (5 turns)
SecondLoopL
	; make test Shoot (Flight)
	jsr SetStartAndFlight
	lda HitFlag
	beq NoHitInSecondLoopL	; impossible :)
	bmi GroundHitInSecondLoopL
TankHitInSecondLoopL
	; tank hit, but which tank?
	; it's our target or not?
	ldy HitFlag
	dey
	cpy TargetTankNr
	beq EndOfSecondLoopL	; it's our target!
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
	bcc HitOnRightSideOfTargetL
	; continue targeting
	dec NewAngle	; 1 deg to right
	dec temp2	; max 5 turns
	beq EndOfSecondLoopL
	jmp SecondLoopL
HitOnRightSideOfTargetL
	; decrease energy (a little)
	sbw Energy #5
NoHitInSecondLoopL
	; Angle 1 deg to left and end loop 
	inc NewAngle
EndOfSecondLoopL

	rts
	
SetStartAndFlight	; set start point (virtual barrel end :) ) and make test flight
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
	jsr Flight
	ldx TankNr
	rts
.endp
;----------------------------------------------
.proc PurchaseAI ; 
; A - skill of the TankNr
; makes purchase for AI opponents
; results of this routine are not visible on the screen
;----------------------------------------------
    asl
    tax
    :2 dex  ;credit KK
    lda PurchaseAIRoutines+1,x
    pha
    lda PurchaseAIRoutines,x
    pha
	rts
	.endp

;----------------
PurchaseAIRoutines
    .word MoronPurchase-1
    .word ShooterPurchase-1 ;ShooterPurchase
    .word PoolsharkPurchase-1 ;PoolsharkPurchase
    .word TosserPurchase-1 ;TosserPurchase
    .word TosserPurchase-1 ;ChooserPurchase
    .word TosserPurchase-1 ;SpoilerPurchase
    .word TosserPurchase-1 ;CyborgPurchase
    .word TosserPurchase-1 ;UnknownPurchase

;----------------------------------------------
.proc MoronPurchase
;Moron buys nothing
    rts
.endp
;-------
.proc TryToPurchaseOnePiece
	; A - weapon number, better it will be in range(1,32)
	; TankNr in X
    ; DOES NOT CHANGE X
	tay
	lda PurchaseMeTable,y
	beq SorryNoPurchase
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
	mva #2 tempXroller; number of offensive purchases to perform
	ldx TankNr
@
	randomize ind_Battery________ ind_StrongParachute
	jsr TryToPurchaseOnePiece
	dec tempXroller
	bne @-
	
	; and now offensives
	mva #4 tempXroller; number of offensive purchases to perform
	;ldx TankNr
@
	randomize ind_Missile________ ind_Heavy_Roller___
	jsr TryToPurchaseOnePiece
	dec tempXroller
	bne @-

	rts 
.endp
;----------------------------------------------
.proc PoolsharkPurchase
	; first try to buy defensives
	mva #3 tempXroller; number of offensive purchases to perform
	ldx TankNr
@
	randomize ind_Battery________ ind_Auto_Defense___
	jsr TryToPurchaseOnePiece
	dec tempXroller
	bne @-
	
	; and now offensives
	mva #8 tempXroller; number of purchases to perform
	;ldx TankNr
@
	randomize ind_Missile________ ind_Dirt_Charge____
	jsr TryToPurchaseOnePiece
	dec tempXroller
	bne @-

	rts 
.endp
;----------------------------------------------
.proc TosserPurchase

    ; what is my money level
    ldx TankNr
    lda MoneyH,x ; money / 256
    sta tempXroller ; perform this many purchase attempts
    ; first try to buy defensives
    mva #3 tempXroller; number of defensive purchases to perform
@
    randomize ind_Battery________ ind_Auto_Defense___
    jsr TryToPurchaseOnePiece
    dec tempXroller
    bne @-
    
    ; and now offensives
    lda MoneyH,x ; money / 256
    asl  ;*2
    sta tempXroller ; perform this many purchase attempts
@
    randomize ind_Missile________ ind_Dirt_Charge____
    jsr TryToPurchaseOnePiece
    dec tempXroller
    bne @-

    rts 
.endp
