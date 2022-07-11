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
    .word Tosser-1 ;Chooser
    .word Tosser-1 ;Spoiler
    .word Tosser-1 ;Cyborg
    .word Tosser-1 ;Unknown

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
	; defensives
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
EnoughEnergy
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
	tya
	; activate defensive weapon
	sta ActiveDefenceWeapon,x
    lda DefensiveEnergy,y
    sta ShieldEnergy,x
	; decrease in inventory
	clc
	sbc #1
	sta (temp),y  ; has address of TanksWeaponsTable
NoUseDefensive
DefensiveInUse
firstShoot
	;find nearest tank neighbour
	jsr MakeLowResDistances
	mva #$ff temp2 ; min possible distance

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
	; calculate index to shotangle table
	:3 lsr @
	and #%00000111
	clc
	adc #8
	sta AngleTablePointer	
	jmp lowestIsLower

EnemyOnTheLeft
	sec
	lda LowResDistances,x
	sbc LowResDistances,y
	cmp temp2 ; lowest
	bcs lowestIsLower
	sta temp2
	sty temp2+1 ; number of the closest tank
	; calculate index to shotangle table
	:3 lsr @
	and #%00000111
	eor #%00000111
	sta AngleTablePointer	
	
lowestIsLower
skipThisPlayer
	dey
	bpl loop01
	
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
.proc Tosser
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
	tya
	; activate defensive weapon
	sta ActiveDefenceWeapon,x
    lda DefensiveEnergy,y
    sta ShieldEnergy,x
	; decrease in inventory
	clc
	sbc #1
	sta (temp),y
DefensiveInUse
NoUseDefensive
	; Toosser is like Poolshark but allways uses defensives
	jmp Poolshark
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
