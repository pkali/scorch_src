;	@com.wudsn.ide.asm.mainsourcefile=program.asm

; artificial intelligence of tanks goes here!
; in A there is a level of tank's intelligence
; 1-moron, ..., 7-cyborg, 8-UNKNOWN (the best of all)
; at the moment (2003-08-15) I have no idea how
; to program better opponents, but moron is easy -
; - shoots random direction and force
; greeeting to myself 10 years older in 2013-11-09... still no idea

;----------------------------------------------
MakeLowResDistances .proc
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
ArtificialIntelligence .proc ;
; A - skill of the TankNr
; returns shoot energy and angle in
; EnergyTable/L/H and AngleTable
;----------------------------------------------
    asl
    tax
    :2 dex  ;credit KK
    lda AIRoutines+1,x
    pha
    lda AIRoutines,x
    pha
	rts
.endp
;----------------
AIRoutines
    .word Moron-1
    .word Shooter-1 ;Shooter
    .word Poolshark-1 ;Poolshark
    .word Poolshark-1 ;Toosser
    .word Poolshark-1 ;Chooser
    .word Poolshark-1 ;Spoiler
    .word Poolshark-1 ;Cyborg
    .word Poolshark-1 ;Unknown

;----------------------------------------------
Moron .proc
    ldx TankNr
    jsr RandomizeAngle
    sta NewAngle
    mwa #80 RandBoundaryLow
    mwa #800 RandBoundaryHigh 
    jsr RandomizeForce
    rts
.endp
;----------------------------------------------
Shooter .proc

    ldx TankNr
    lda PreviousAngle,x
    ora PreviousEnergyL,x
    ora PreviousEnergyH,x
    beq firstShoot
    
	lda PreviousAngle,x
	clc
	adc #5
	bmi leftQuadrant
	cmp #90
	bcc continue
	lda #(-90)
	bne continue
leftQuadrant
	


continue
	sta NewAngle
	
	lda PreviousEnergyL,x 
	sta EnergyTableL,x
	lda PreviousEnergyH,x 
	sta EnergyTableH,x
	
	jmp endo
firstShoot
	; compare the x position with the middle of the screen
	lda xTanksTableL,x
	sta temp
	lda xTanksTableH,x
	sta temp+1
	cpw temp #(screenwidth/2)
	bcs tankIsOnTheRight

	lda RANDOM
	and #$1F
	clc
	adc #5
	;lda #45	

	sta NewAngle
	jmp forceNow
tankIsOnTheRight
	lda RANDOM
	and #$1F
	clc
	adc #(-85)
	;lda #-45
	sta NewAngle
	
forceNow
    mwa #100 RandBoundaryLow
    mwa #800 RandBoundaryHigh 
    jsr RandomizeForce

endo
	ldx TankNr ;this is possibly not necessary
	lda NewAngle
	sta PreviousAngle,x
	lda EnergyTableL,x
	sta PreviousEnergyL,x 
	lda EnergyTableH,x
	sta PreviousEnergyH,x
	
	; choose the best weapon
	
	lda TanksWeaponsTableL,x
	sta temp
	lda TanksWeaponsTableH,x
	sta temp+1
	ldy #32 ;the last  weapon	
loop
	dey
	lda (temp),y
	beq loop 
	tya
	sta ActiveWeapon,x
    rts
    .endp
;----------------------------------------------
Poolshark .proc

firstShoot
	;find nearest tank neighbour
	jsr MakeLowResDistances
	mva #$ff temp2 ; min possible distance

	ldx TankNr
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
    jsr RandomizeForce

endo
	ldx TankNr ;this is possibly not necessary
	
	; choose the best weapon
	
	lda TanksWeaponsTableL,x
	sta temp
	lda TanksWeaponsTableH,x
	sta temp+1
	ldy #32 ;the last  weapon	
loop
	dey
	lda (temp),y
	beq loop 
	tya
	sta ActiveWeapon,x
    rts
    
;----------------------------------------------
AngleTable	; 16 bytes ;ba w $348b L$3350
	.by 178,186,194,202,210,218,226,234
	.by 16,24,32,40,48,56,64,72
	.endp
;----------------------------------------------
PurchaseAI .proc ; 
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
    .word PoolsharkPurchase-1 ;ToosserPurchase
    .word PoolsharkPurchase-1 ;ChooserPurchase
    .word PoolsharkPurchase-1 ;SpoilerPurchase
    .word PoolsharkPurchase-1 ;CyborgPurchase
    .word PoolsharkPurchase-1 ;UnknownPurchase

;----------------------------------------------
MoronPurchase
;Moron buys nothing
    rts
    
;-------
TryToPurchaseOnePiece .proc
	; A - weapon number, better it will be in range(1,32)
	; TankNr in X
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
ShooterPurchase .proc
	mva #4 tempXroller; number of purchases to perform

	ldx TankNr
loop
	randomize 1 14
	jsr TryToPurchaseOnePiece
	dec tempXroller
	bne loop

	rts 
	.endp
;----------------------------------------------
PoolsharkPurchase .proc
	mva #8 tempXroller; number of purchases to perform

	ldx TankNr
loop
	randomize 1 30
	jsr TryToPurchaseOnePiece
	dec tempXroller
	bne loop

	rts 
.endp


PurchaseMeTable .proc ;weapons good to be purchased by the robot 
				;the comment is an index in the tables
    dta 1 ;"Baby Missile    " ; 0
    dta 1 ;"Missile         " ; 1
    dta 1 ;"Baby Nuke       " ; 2
    dta 1 ;"Nuke            " ; 3
    dta 1 ;"LeapFrog        " ; 4
    dta 1 ;"Funky Bomb      " ; 5
    dta 1 ;"MIRV            " ; 6
    dta 1 ;"Death's Head    " ; 7
    dta 0 ;"Napalm          " ; 8
    dta 0 ;"Hot Napalm      " ; 9
    dta 0 ;"Tracer          " ; 10
    dta 0 ;"Smoke Tracer    " ; 11
    dta 1 ;"Baby Roller     " ; 12
    dta 1 ;"Roller          " ; 13
    dta 1 ;"Heavy Roller    " ; 14
    dta 0 ;"Riot Charge     " ; 15
    dta 0 ;"Riot Blast      " ; 16
    dta 0 ;"Riot Bomb       " ; 17
    dta 0 ;"Heavy Riot Bomb " ; 18
    dta 0 ;"Baby Digger     " ; 19
    dta 0 ;"Digger          " ; 20
    dta 0 ;"Heavy Digger    " ; 21
    dta 0 ;"Baby Sandhog    " ; 22
    dta 0 ;"Sandhog         " ; 23
    dta 0 ;"Heavy Sandhog   " ; 24
    dta 0 ;"Dirt Clod       " ; 25
    dta 0 ;"Dirt Ball       " ; 26
    dta 0 ;"Ton of Dirt     " ; 27
    dta 1 ;"Liquid Dirt     " ; 28
    dta 0 ;"Dirt Charge     " ; 29
    dta 0 ;"Earth Disrupter " ; 30
    dta 1 ;"Plasma Blast    " ; 31
    dta 1 ;"Laser           " ; 32
    dta 0 ;"----------------" ; 33
    dta 0 ;"----------------" ; 34
    dta 0 ;"----------------" ; 35
    dta 0 ;"----------------" ; 36
    dta 0 ;"----------------" ; 37
    dta 0 ;"----------------" ; 38
    dta 0 ;"----------------" ; 39
    dta 0 ;"----------------" ; 40
    dta 0 ;"----------------" ; 41
    dta 0 ;"----------------" ; 42
    dta 0 ;"----------------" ; 43
    dta 0 ;"----------------" ; 44
    dta 0 ;"----------------" ; 45
    dta 0 ;"----------------" ; 46
    dta 0 ;"----------------" ; 47

.endp
 