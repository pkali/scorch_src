;   @com.wudsn.ide.asm.mainsourcefile=scorch.asm


    .IF *>0
;----------------------------------------
; this module contains routines used in text mode
; like shop and start-up options
;----------------------------------------

;--------------------------------------------------
.proc Options
;--------------------------------------------------
; start-up screen - options, etc.
; this function returns:
; - number of players (NumberOfPlayers)
; - money each player has on the beginning of the game (moneyL i moneyH)
; - and I am sure maxwind, gravity, no_of_rounds in a game, speed of shell flight

    jsr clearscreen   ;let the screen be clean

    mwa #OptionsDL dlptrs
;    lda dmactls
;    and #$fc
;    ora #$02     ; normal screen width
;    lda #%00110010 ; normal screen width, DL on, P/M off
    lda #%00111110  ; normal screen width, DL on, P/M on
    sta dmactls
	jsr SetPMWidth
    mva #TextBackgroundColor COLOR2
    jsr ColorsOfSprites
	mva #$ca COLOR1
	mva #$00 COLBAKS	; set color of background
   
    VDLI DLIinterruptOptions  ; jsr SetDLI for Options text screen

; -------- setup bottom (tanks) line	
	lda NumberOfPlayers
	pha
    lda mountainsDeltaTableH
    sta mountainDeltaH
    lda mountainsDeltaTableL
    sta mountainDeltaL
	mva #6 NumberOfPlayers
    jsr PMoutofScreen ;let P/M disappear
    jsr clearscreen   ;let the screen be clean
	jsr ClearPMmemory
    jsr placetanks    ;let the tanks be evenly placed
    jsr calculatemountains ;let mountains be easy for the eye
    jsr drawmountains ;draw them
	ldx NumberOfPlayers
	dex
@	jsr RandomizeAngle
	sta AngleTable,x
	dex
	bpl @-
    jsr drawtanks     ;finally draw tanks
	pla
	sta NumberOfPlayers
; --------

    mva #0 OptionsY

OptionsMainLoop
    jsr OptionsInversion
    jsr getkey
    bit escFlag
    spl:rts
       
    cmp #$f  ;cursor down
    bne OptionsNoDown
    inc:lda OptionsY
    cmp #maxoptions
    bne OptionsMainLoop
    mva #maxoptions-1 OptionsY
    jmp OptionsMainLoop

OptionsNoDown
    cmp #$e ;cursor up
    bne OptionsNoUp
    dec OptionsY
    bpl OptionsMainLoop
    mva #0 OptionsY
    jmp OptionsMainLoop

OptionsNoUp
    cmp #$6 ;cursor left
    bne OptionsNoLeft
    ldx OptionsY
    dec OptionsTable,X
    lda OptionsTable,X
    bpl OptionsMainLoop
    inc OptionsTable,X
    jmp OptionsMainLoop

OptionsNoLeft
    cmp #$7 ;cursor right
    bne OptionsNoRight

    ldx OptionsY
    inc OptionsTable,X
    lda OptionsTable,X
    cmp #5
    bne OptionsMainLoop
    dec OptionsTable,X
    jmp OptionsMainLoop

OptionsNoRight
    cmp #$c ;Return key
    bne OptionsNoReturn
    jmp OptionsFinished
OptionsNoReturn
    jmp OptionsMainLoop

OptionsFinished
    ;first option
    ldy OptionsTable
    iny
    iny
    sty NumberOfPlayers ;1=1 player (but minimum is 2)

    ;second option (cash)


    ldy OptionsTable+1
    ldx #0
@
      lda CashOptionL,y
      sta moneyL,x
      lda CashOptionH,y
      sta moneyH,x
      inx
      cpx NumberOfPlayers
    bne @-

    ;third option (gravity)
    ldy OptionsTable+2
    lda GravityTable,y
    sta gravity

    ;fourth option (wind)
    ldy OptionsTable+3
    lda MaxWindTable,y
    sta MaxWind
    
    ;fifth option (no of rounds)
    ldy OptionsTable+4
    lda RoundsTable,y
    sta RoundsInTheGame
    
    ;6th option (shell speed)
    ldy OptionsTable+5
    lda flyDelayTable,y
    sta flyDelay
    
    ;7th option (Airstrike after how many missess)
    ldy OptionsTable+6
    lda seppukuTable,y
    sta seppukuVal
    
    ;8th option (how aggressive are mountains)
    ldy OptionsTable+7
    lda mountainsDeltaTableH,y
    sta mountainDeltaH
    lda mountainsDeltaTableL,y
    sta mountainDeltaL
    
    
    rts
;--------
; inversing selected option (cursor)
;--------
OptionsInversion
    ;clean options loop
    ;TODO: (optionally) - convert to single byte loop if no new options
    mwa #OptionsHere temp
    ldy #0
OptionsInversionLoop1
    lda (temp),y
    and #$7F
    sta (temp),y
    inw temp
    cpw temp #OptionsScreenEnd
    bne OptionsInversionLoop1
    ;here all past inversions are gone...

    mwa #OptionsHere temp
    mva #0 temp2  ;option number pointer
    adw temp  #11 ;offset of the first option=11
OptionsSetMainLoop
    ldx temp2
    lda OptionsTable,x
    asl
    asl
    adc OptionsTable,x  ;OptionsTable value * 5
    tay
    ldx #6-1  ; width of the highlight bar (6 chars)
OptionSetLoop
    lda (temp),y
    ora #$80
    sta (temp),y
    iny
    dex
    bpl OptionSetLoop ;here option is highlighted
;
; next option
    adw temp  #40 ;jump to next line
    inc:lda temp2
    cmp #maxOptions ;number of options
    bne OptionsSetMainLoop

;inversing the first few chars of the selected line (OptionsY)
    mva OptionsY temp
    mva #0 temp+1
    asl temp
    rol temp+1
    asl temp
    rol temp+1
    asl temp
    rol temp+1
    mwa temp temp2 ;here is OptionsY*8
    asl temp
    rol temp+1
    asl temp
    rol temp+1
    ;here is 32*OptionsY
    adw temp temp2
    ;in temp is 40*OptionsY
    adw temp #OptionsHere
    ;now in temp is adres of the line to be inversed
    ldy #8 ;9 letters to invers
OptionsYLoop
    lda (temp),y
    ora #$80
    sta (temp),y
    dey
    bpl OptionsYLoop


    rts
.endp

;-------------------------------------------
; call of the purchase (and activate) screens for each tank
.proc CallPurchaseForEveryTank

	mva #0 TankNr
	sta isInventory
@
	ldx TankNr
	lda SkillTable,x
	beq ManualPurchase
	jsr PurchaseAI	; remember to make ActivateAI :) !!!
	jmp AfterManualPurchase
ManualPurchase
	mva #0 isInventory
	jsr Purchase	; purchase weapons
	bit escFlag
	spl:rts
	jsr DefensivesActivate	; activate weapons
	bit escFlag
	spl:rts	
AfterManualPurchase
	inc:lda TankNr
	cmp NumberOfPlayers
	bne @-
	rts
.endp
;--------------------------------------------------
.proc DefensivesActivate
;--------------------------------------------------
; This proc call Inventory and set Defensives activation first
    
    mwa #ListOfDefensiveWeapons WeaponsListDL ;switch to the list of offensive weapons    
    mva #$ff IsInventory
    mva #$01 WhichList
    ; offensive weapon - 0, deffensive - 1
	jmp Purchase.GoToActivation
.endp
;--------------------------------------------------
.proc Purchase ;
;--------------------------------------------------
; In tanknr there is a number of the tank (player)
; that is buying weapons now (from 0).
; Rest of the data is taken from appropriate tables
; and during the purchase these tables are modified.

    mwa #ListOfWeapons WeaponsListDL ;switch to the list of offensive weapons
        
; we are clearing list of the weapons
    mva #$00 WhichList
    ; offensive weapon - 0, deffensive - 1
GoToActivation
    mva #$ff LastWeapon

;    mva #0 dmactl
    VDLI DLIinterruptText  ; jsr SetDLI for text (purchase) screen
    jsr PMoutofScreen
    mwa #PurchaseDL dlptrs
    lda #@dmactl(narrow|dma) ; narro screen width, DL on, P/M off
    sta dmactls

    lda #song_supermarket
	bit IsInventory
	bpl @+
	lda #song_inventory
@	jsr RmtSongSelect

    ldx tankNr
    lda TankStatusColoursTable,x
    sta COLOR2

    ; there is a tank (player) number in tanknr
    ; we are displaying name of the player
	ldy #0
	sty COLBAKS	; set color of background
    lda tanknr
    :3 asl  ; 8 chars per name
    tax
NextChar03
    lda tanksnames,x
    sta textbuffer2+8,y
    inx
    iny
    cpy #$08
    bne NextChar03
    ; and we display cash of the given player

; here we must jump in after each purchase
; to generate again list of available weapons
AfterPurchase

    ; current cash display
    mva #sfx_purchase sfx_effect
    ldx tanknr
    lda moneyL,x
    sta decimal
    lda moneyH,x
    sta decimal+1
    mwa #textbuffer2+26 displayposition
    jsr displaydec5

    ; in xbyte there is the address of the line that
    ; is being processed now
    mwa #ListOfWeapons xbyte
    ldx #$00  ; index of the checked weapon
    stx HowManyOnTheListOff ; amounts of weapons (shells, bullets) in both lists
    stx HowManyOnTheListDef

; Creating full list of the available weapons for displaying
; in X there is an index of the weapon to be checked,
; in 'Xbyte' address of the first char in filled screen line

CreateList
    stx temp ; index of a weapon will be necessary later
    ; checking if the weapon of the given index is present
    lda WeaponUnits,x
    jeq NoWeapon

    ldy tanknr    
    
    bit isInventory
    jmi itIsInventory
    
    ; put "Purchase" on the screen
	mwa #PurchaseDescription PurActDescAddr
	; and Title
	mwa #PurchaseTitle DLPurTitleAddr

    ; checking if we can afford buying this weapon
    ldx temp
    lda moneyH,y
    cmp WeaponPriceH,x
    bne @+
    lda moneyL,y
    cmp WeaponPriceL,x
@
    jcc TooLittleCash
    
    ; we have enough cash and the weapon can be
    ; added to the list

    ; first parentheses and other special chars
    ; (it's easier this way)
    ;ldy #22
    ;lda #08 ; "("
    ;STA (XBYTE),y
    ;ldy #32
    ;lda #09 ; ")"
    ;sta (xbyte),y
    ldy #24
    lda #15 ; "/"
    sta (xbyte),y
    ldy #30
    lda #16 ; "0"
    sta (xbyte),y

    ;now number of units (shells) to be purchased
    adw xbyte #22 displayposition  ; 23 chars from the beginning of the line
    lda WeaponUnits,x
    sta decimal
    jsr displaybyte
    ldx temp ;getting back index of the weapon

    ; and now price of the weapon
    adw xbyte #25 displayposition  ; 26 chars from the beginning of the line
    lda WeaponPriceL,x
    sta decimal
    lda WeaponPriceH,x
    sta decimal+1
    jsr displaydec5
    ldy #25		; overwrite first digit (allways space - no digit :) )
    lda #04 ; "$"
    sta (xbyte),y

    jmp notInventory

itIsInventory
    ; put "Activate" on the screen
	mwa #ActivateDescription PurActDescAddr
	; and Title
	mwa #InventoryTitle DLPurTitleAddr

    ldx temp
    lda TanksWeaponsTableL,y
    sta weaponPointer
    lda TanksWeaponsTableH,y
    sta weaponPointer+1
    ldy temp
    lda (weaponPointer),y
    jeq noWeapon

    ; clear price area
    ldy #21  ; beginning of the price area
    lda #0
@     sta (XBYTE),y
      iny
      cpy #32  ; end of price
    bne @-

notInventory

    ; number of posessed shells
    lda temp ; weapon index again
    jsr HowManyBullets
    sta decimal

    adw xbyte #1 displayposition 
    jsr displaybyte

    ldx temp ;weapon index
    ; now symbol of the weapon
    lda WeaponSymbols,x
    ldy #$4  ; 4 chars from the beginning of the line
    sta (xbyte),y

    ; and now name of the weapon and finisheeeedd !!!!
    mva #0 temp+1  ; this number is only in X
    ; times 16 (it's length of the names of weapons)
    ldy #3 ; Rotate 4 times
@
    asl temp
    rol temp+1
    dey
    bpl @-

    adw temp #NamesOfWeapons-6 weaponPointer

    ldy #6 ; from 6th char on screen

@
    lda (weaponPointer),y
    sta (xbyte),y
    iny
    cpy #(16+6)
    bne @-


    ; in X there is what we need (weapon index)

    ; If on screen after the purchase there is still
    ; present the weapon purchased recently,
    ; the pointer must point to it.
    bit lastWeapon
    bpl @+  ; if == $ff => first run, jump to top
    mva #0 PositionOnTheList
    beq NotTheSameAsLastTime
@
    cpx LastWeapon
    bne NotTheSameAsLastTime
    lda WhichList
    bne @+
    lda HowManyOnTheListOff
    sta PositionOnTheList
    jmp NotTheSameAsLastTime
@
    lda HowManyOnTheListDef
    sta PositionOnTheList
NotTheSameAsLastTime
    ; increase appropriate counter
    txa
    cpx #$30
    bcs DefenceList
    ldy HowManyOnTheListOff
    sta IndexesOfWeaponsL1,y
    inc HowManyOnTheListOff
    bne NextLineOfTheList
DefenceList
    ldy HowManyOnTheListDef
    sta IndexesOfWeaponsL2,y
    inc HowManyOnTheListDef
    ; If everything is copied then next line
NextLineOfTheList
    adw xbyte #32
TooLittleCash
NoWeapon

    ; next weapon. If no more weapons then finish!
    inx
    cpx #$30
    bne NoDefense

; if we got to the defense weapons,
; we switch address to the second table.
    mwa #ListOfDefensiveWeapons xbyte
NoDefense
    cpx #$40
    jne CreateList

    ; offset may be only too big
    ; (because after purchase list will never be longer)
    ; check it and modify if necessary.
    ; If offset is larger than position of the pointer,
    ; it must be equal.
    lda PositionOnTheList
    cmp OffsetDL1
    bcs WeHaveOffset ; do not modify offset
    sta OffsetDL1
WeHaveOffset

    ; now we have to erase empty position of both lists.

    ; Multiply number on list 1 by 32 and set address
    ; of the first erased char.
    ; (multiplying taken from book of Ruszczyc 'Assembler 6502'

    lda HowManyOnTheListOff
    sta xbyte ; multiplier (temporarily here, it will be erased anyway)
    lda #$00 ; 
    sta xbyte+1 ; higher byte of the Result
    ldx #$05 ; 2^5
@     asl xbyte
      rol xbyte+1
      dex
    bne @-
    
    ; add to the address of the list
    clc
    lda xbyte
    adc #<ListOfWeapons
    tay
    lda xbyte+1
    adc #>ListOfWeapons
    sta xbyte+1
    stx xbyte
    txa ; now there is zero here
ClearList1
    sta (xbyte),y
    iny
    bne DoNotIncHigher1
    inc xbyte+1
DoNotIncHigher1
    cpy #<ListOfWeapons1End
    bne ClearList1
    ldx xbyte+1
    cpx #>ListOfWeapons1End
    bne ClearList1

    ; And the same we do with the second list

    ; Multiply number on list 1 by 40 and set address
    ; of the first erased char.
    lda HowManyOnTheListDef
    sta xbyte ; multiplier (temporarily here, it will be erased anyway)
    lda #$00 ; 
    sta xbyte+1 ; higher byte of the Result
    ldx #$05 ; 2^5
@     asl xbyte
      rol xbyte+1
      dex
    bne @-

    ; add to the address of the list
    clc
    lda xbyte
    adc #<ListOfDefensiveWeapons
    tay
    lda xbyte+1
    adc #>ListOfDefensiveWeapons
    sta xbyte+1
    stx xbyte
    txa ; now there is zero here
ClearList2
    sta (xbyte),y
    iny
    bne DoNotIncHigher2
    inc xbyte+1
DoNotIncHigher2
    cpy #<ListOfDefensiveWeaponsEnd
    bne ClearList2
    ldx xbyte+1
    cpx #>ListOfDefensiveWeaponsEnd
    bne ClearList2

; here we have pretty cool lists and there is no brute force
; screen clearing at each list refresh
; (it was very ugly - I checked it :)

    bit isInventory  ; 
    bpl ChoosingItemForPurchase
    
    lda whichList
    bne PositionDefensive
     
; calculate positionOnTheList from the activeWeapon (offensives)
    ldx tankNr
    lda activeWeapon,x
    ldy #0
@
      cmp IndexesOfWeaponsL1,y
      beq ?weaponfound
      iny
      cpy #48  ; maxOffensiveWeapons
    bne @-
    ; not found apparently?
    ; TODO: check border case (the last weapon)
    ldy #0
    beq ?weaponFound  ; jmp
PositionDefensive
    jsr calcPosDefensive
    

?weaponFound
    ; weapon index in Y
    sty positionOnTheList

; Here we have all we need
; So choose the weapon for purchase ......
;--------------------------------------------------
ChoosingItemForPurchase
;--------------------------------------------------
    
    jsr PutLitteChar ; Places pointer at the right position
    jsr getkey
    bit escFlag
    spl:jmp WaitForKeyRelease  ; like jsr ... : rts
    cmp #$2c ; Tab
    jeq ListChange
    cmp #$06  ; cursor left
    jeq ListChange
    cmp #$0c ; Return
    sne:rts
    cmp #$e
    beq PurchaseKeyUp
    cmp #$f
    beq PurchaseKeyDown
    cmp #$21 ; Space
    jeq PurchaseWeaponNow
    cmp #$07 ; cursor right
    jeq PurchaseWeaponNow
    bne ChoosingItemForPurchase

PurchaseKeyUp
    lda WhichList
    beq GoUpOffensive
    dec PositionOnTheList
    bpl EndUpX
    ldy #0 ;HowManyOnTheListDef
    ;dey
    sty PositionOnTheList
    jmp ChoosingItemForPurchase
GoUpOffensive
    dec PositionOnTheList
    bpl MakeOffsetUp
    ldy #0 ;HowManyOnTheListOff
    ;dey
    sty PositionOnTheList

MakeOffsetUp
    ; If offset is larger than pointer position,
    ; it must be equal then.
    lda PositionOnTheList
    cmp OffsetDL1
    bcs EndUpX ; do not modify the offset
    sta OffsetDL1
EndUpX
    jmp ChoosingItemForPurchase
PurchaseKeyDown
    lda WhichList
    beq GoDownOffensive
    inc:lda PositionOnTheList
    cmp HowManyOnTheListDef
    bne EndGoDownX
    ldy HowManyOnTheListDef
    dey
    sty PositionOnTheList
    jmp ChoosingItemForPurchase
GoDownOffensive
    inc:lda PositionOnTheList
    cmp HowManyOnTheListOff
    bne MakeOffsetDown
    ldy HowManyOnTheListOff
    dey
    sty PositionOnTheList
MakeOffsetDown
    lda OffsetDL1
    clc
    adc #15
    ;if offset+16 is lower than the position then it must =16
    cmp PositionOnTheList
    bcs EndGoDownX
    sec
    lda PositionOnTheList
    sbc #15
    sta OffsetDL1
EndGoDownX
    jmp ChoosingItemForPurchase

; swapping the displayed list and setting pointer to position 0
ListChange
    mva #0 OffsetDL1

    lda WhichList
    eor #$01
    sta WhichList
    bne DeffensiveSelected

    mwa #ListOfWeapons WeaponsListDL
    lda isInventory
    beq @+
    ; inventory
    jsr calcPosOffensive
    jmp ChoosingItemForPurchase
@
    mva #0 PositionOnTheList
    jmp ChoosingItemForPurchase

DeffensiveSelected
    mwa #ListOfDefensiveWeapons WeaponsListDL
    lda isInventory
    beq @+
    jsr calcPosDefensive
    jmp ChoosingItemForPurchase
@
    mva #0 positionOnTheList
    jmp ChoosingItemForPurchase

.endp
; weapon purchase routne increases number of possessed bullets
; decreases cash and jumps to screen refresh
;--------------------------------------------------
.proc PurchaseWeaponNow
;--------------------------------------------------
    bit isInventory
    bmi inventorySelect

    lda WhichList
    bne PurchaseDeffensive

    ; here we purchase the offensive weapon
    ldy PositionOnTheList
    lda IndexesOfWeaponsL1,y
    jmp PurchaseAll
PurchaseDeffensive
    ldy PositionOnTheList
    lda IndexesOfWeaponsL2,y
PurchaseAll
    ; after getting weapon index the routine is common for all
    ldx tanknr
    tay  ; weapon index is in Y
    sec
    lda moneyL,x ; substracting from posessed money
    sbc WeaponPriceL,y ; of price of the given weapon
    sta moneyL,x
    lda moneyH,x
    sbc WeaponPriceH,y
    sta moneyH,x
    
positiveMoney    
    ; now we have to get address of
    ; the table of the weapon of the tank
    ; and add appropriate number of shells

    sty LastWeapon ; store last purchased weapon
    ; because we must put screen pointer next to it
    
	; but if we purchasing "Buy me!" then we must draw the winning weapon.
	
	cpy #ind_Buy_me_________
	bne NoSuprise
	
Suprise	; get a random weapon
	lda random
	cmp #51		; defensive weapons are less likely because they are more expensive - probability 255:51 (5:1)
	bcc GetRandomDefensive
GetRandomOffensive
	randomize ind_Missile________ ind_Laser__________
	cmp #ind_Buy_me_________
	beq GetRandomOffensive
	tay
    lda WeaponUnits,y	; check if weapon exist
	beq GetRandomOffensive	
	bne NoSuprise	; Y always <> 0
GetRandomDefensive
	randomize ind_Battery________ ind_Nuclear_Winter_
	tay
    lda WeaponUnits,y	; check if weapon exist
	beq GetRandomDefensive
	
NoSuprise
    lda TanksWeaponsTableL,x
    sta weaponPointer
    lda TanksWeaponsTableH,x
    sta weaponPointer+1

    clc
    lda (weaponPointer),y  ; and we have number of posessed bullets of the weapon
    adc WeaponUnits,y
    sta (weaponPointer),y ; and we added appropriate number of bullets
    cmp #100 ; but there should be no more than 99 bullets
    bcc LessThan100
      lda #99
      sta (weaponPointer),y
LessThan100

    mva #0 PositionOnTheList  ; to move the pointer to the top when no more monies
    jmp Purchase.AfterPurchase

inventorySelect
    lda whichList
    bne invSelectDef

    ldy PositionOnTheList
    lda IndexesOfWeaponsL1,y
    ldx tankNr
    sta activeWeapon,x
    jmp WaitForKeyRelease ; rts
    
invSelectDef
    ldy PositionOnTheList
    lda IndexesOfWeaponsL2,y
    tay
    ldx tankNr
    cmp #ind_Battery________
    bne NotBattery
    ; if activate battery, we do it differently
    mva #sfx_battery sfx_effect
	phy
    mva #99 Energy,x
	jsr MaxForceCalculate
	ply
    jmp DecreaseDefensive ; bypass activation
NotBattery
	cmp #ind_Long_Barrel____
	bne NotBarrel
	; if activate long barrel, we do it differently too
	mva #sfx_long_barrel sfx_effect
    mva #LongBarrel BarrelLength,x
    bne DecreaseDefensive ; bypass activation	
NotBarrel
    cmp #ind_White_Flag_____
    bne NotWhiteFlag
    cmp ActiveDefenceWeapon,x
    bne NoDeactivateWhiteFlag
    mva #sfx_white_flag sfx_effect
    lda #$00    ; if try to activate activated White Flag then deactivate Defence
    sta ActiveDefenceWeapon,x
    sta ShieldEnergy,x
    beq DefActivationEnd
NotWhiteFlag
NoDeactivateWhiteFlag
    ; activate new defensive
    sta ActiveDefenceWeapon,x
    ; set defensive energy
    lda DefensiveEnergy,y
    sta ShieldEnergy,x
DecreaseDefensive
    ; decrease number of defensives
    lda TanksWeaponsTableL,x
    sta weaponPointer
    lda TanksWeaponsTableH,x
    sta weaponPointer+1
    lda (weaponPointer),y
    sec
    sbc #1
    sta (weaponPointer),y
    
DefActivationEnd
    jmp WaitForKeyRelease ; rts

.endp
; -----------------------------------------------------
.proc calcPosDefensive
; calculate positionOnTheList from the activeWeapon (defensives)
    ldx tankNr
    lda ActiveDefenceWeapon,x
    beq ?noWeaponActive
    ldy #0  ; min defensive weapon
@
      cmp IndexesOfWeaponsL2,y
      beq ?weaponfound
      iny
      cpy #8*2  ; maxDefensiveWeapon
    bne @-
    ; not found apparently?
    ; TODO: check border case (the last weapon)
?noWeaponActive
    ldy #0
?weaponFound
    cpy howManyOnTheListDef
    bcs ?noWeaponActive
    sty positionOnTheList
    rts
.endp

.proc calcPosOffensive
; calculate positionOnTheList from the activeWeapon (defensives)
    ldx tankNr
    lda ActiveWeapon,x
    beq ?noWeaponActive
    ldy #0  ; min defensive weapon
@
      cmp IndexesOfWeaponsL1,y
      beq ?weaponfound
      iny
      cpy #8*5  ; maxOffensiveWeapon
    bne @-
    ; not found apparently?
    ; TODO: check border case (the last weapon)
?noWeaponActive
    ldy #0
?weaponFound
    cpy howManyOnTheListOff
    bcs ?noWeaponActive
    sty positionOnTheList
    rts
.endp
; -----------------------------------------------------
.proc PutLitteChar
    ; first let's clear both lists from little chars
    mwa #ListOfWeapons xbyte
    ldx #52 ; there are 52 lines total
    ldy #$00
EraseLoop
    tya  ; lda #$00
    sta (xbyte),y
    adw xbyte #32
    dex
    bpl EraseLoop

    ; now let's check which list is active now
    lda WhichList
    beq CharToList1
    ; we are on the second list (deffensive)
    ; so there is no problem with scrolling
    mwa #ListOfDefensiveWeapons xbyte
    ldx PositionOnTheList
    beq SelectList2 ; if there is 0 we add nothing
AddLoop2
    adw xbyte #32
    dex
    bne AddLoop2
SelectList2
    lda #$7f ; little char (tab) - this is the pointer
    sta (xbyte),y
    ; now we clear flags of presence of list "out of screen"
    ; unfortunately I am now sure what it means... :(
    ldx #<EmptyLine
    ldy #>EmptyLine
    stx MoreUpdl
    sty MoreUpdl+1
    stx MoreDowndl
    sty MoreDowndl+1
    rts
CharToList1
    ; we putchar on list 1
    ; and later set-up list itself
    mwa #ListOfWeapons xbyte
    ldx PositionOnTheList
    beq SelectList1 ; if there is 0 we add nothing
AddLoop1
    adw xbyte #32
    dex
    bne AddLoop1
SelectList1
    lda #$7f ; pointer = little char = (tab)
    sta (xbyte),y
    ; now moving the window basing on given offset
    mwa #ListOfWeapons xbyte
    ldx OffsetDL1
    beq SetWindowList1 ; if zero then add nothing
LoopWindow1
    adw xbyte #32
    dex
    bne LoopWindow1
SetWindowList1
    mwa xbyte WeaponsListDL  ; and we change Display List

    ; we show screen line with arrows meaning that
    ; you can scroll the list up
    ldx #<EmptyLine
    ldy #>EmptyLine
    lda OffsetDL1
    beq NoArrowUp
      ldx #<MoreUp
      ldy #>MoreUp
NoArrowUp
    stx MoreUpdl
    sty MoreUpdl+1
    ; the same, bu scrolling down
    lda HowManyOnTheListOff
    ldx #<EmptyLine
    ldy #>EmptyLine
    sec
    sbc #17
    bmi NoArrowDown
    cmp OffsetDL1
    bcc NoArrowDown
      ldx #<MoreDown
      ldy #>MoreDown
NoArrowDown
    stx MoreDowndl
    sty MoreDowndl+1
    rts
.endp
; -----------------------------------------------------
.proc EnterPlayerNames
    ;entering names of players
    mwa #NameDL dlptrs
;    lda dmactls
;    and #$fc
;    ora #$01     ; narrow screen (32 chars)
    lda #%00110001 ; narrow screen width, DL on, P/M off
    sta dmactls
    VDLI DLIinterruptText  ; jsr SetDLI for text (names) screen

    mva #0 TankNr
	sta COLBAKS	; set color of background
@     tax
      lda TankStatusColoursTable,x
      sta COLOR2  ; set color of player name line
      jsr EnterPlayerName
      bit escFlag
      spl:rts
      inc TankNr
      lda TankNr
      cmp NumberOfPlayers
    bne @-
    rts
.endp
; -----------------------------------------------------
.proc EnterPlayerName
; in: TankNr
; Out: TanksNames, SkillTable

; this little thing is for choosing Player's skill (if computer)
; and entering his name
; If no name entered, there should be name "1st Tank", etc.
; Default tanks names are in table TanksNamesDefault
; -----------------------------------------------------

    jsr PMoutofScreen
    ; display tank number
    ldx tanknr
    lda skillTable,x
    sta difficultyLevel
    inx
    stx decimal
    mwa #(NameScreen+41) displayposition
    jsr displaybyte
    jsr HighlightLevel ; setting choosen level of the opponent (Moron, etc)

    ; clear tank name editor field
    ldx #8
    lda #0
@     sta NameAdr,x
      dex
    bpl @-
    
    ; copy existing name and place cursor at end
    lda TankNr
    :3 asl
    tax
    
    ldy #0
@     lda TanksNames,x
;      beq endOfTankName
      sta NameAdr,y
      inx
      iny
      cpy #8
    bne @-
endOfTankName

@	lda NameAdr,y
	bne LastNameChar
	dey
	bpl @-
LastNameChar
	iny

    lda #$80 ; place cursor on the end
    sta NameAdr,y
	dey
	bpl @+
	iny	; if old name is empty or first time entering
@   sty PositionInName


CheckKeys
    jsr getkey
    bit escFlag
    spl:rts
    
    ; is the char to be recorded?
    ldx #keycodesEnd-keycodes ;table was 38 chars long
IsLetter
    cmp keycodes,x
    beq YesLetter
    dex
    bpl IsLetter
    bmi CheckFurtherX01 ; if not in the table
    ; we check cursors and (Return)
YesLetter
    lda scrcodes,x ; we have screen code of the char
    ldx PositionInName
    bne NotFirstLetter
    and #$3f ; First letter should be Capital letter
    ; (nice trick does not affect digits)
NotFirstLetter
    sta NameAdr,x
    inx
    lda #$80 ; cursor behind the char
    sta NameAdr,x
    cpx #$08 ; is there 8 characters?
    beq CheckKeys  ; if so, nothing increased
    stx PositionInName ; if not, we store
    ; position incremented by 1

    jmp CheckKeys
CheckFurtherX01 ; here we check Tab, Return and Del
    cmp #$0c ; Return
    jeq EndOfNick
    cmp #$2c ; Tab
    beq ChangeOfLevelUp
    cmp #$7 ;cursor right
    beq ChangeOfLevelUp
    cmp #$6 ;cursor left
    beq ChangeOfLevelDown
    cmp #$f ;cursor down
    beq ChangeOfLevel3Up
    cmp #$e ;cursor up
    beq ChangeOfLevel3Down

    cmp #$34 ; Backspace (del)
    bne CheckKeys
    ; handling backing one char
    ldx PositionInName
    beq FirstChar
    dex
FirstChar
    lda #$80
    sta NameAdr,x
    lda #$00
    sta NameAdr+1,x
    sta NameAdr+2,x
    stx PositionInName
    jmp CheckKeys
ChangeOfLevelUp ; change difficulty level of computer opponent
    inc:lda DifficultyLevel
    cmp #9  ; 9 levels are possible
    bne DoNotLoopLevelUp
    mva #$0 DifficultyLevel
DoNotLoopLevelUp
    jsr HighlightLevel
    jmp CheckKeys
;----
ChangeOfLevelDown
    dec:lda DifficultyLevel
    bpl DoNotLoopLevelDown
    mva #$8 DifficultyLevel
DoNotLoopLevelDown
    jsr HighlightLevel
    jmp CheckKeys
;----
ChangeOfLevel3Up
    adb DifficultyLevel #3

    cmp #9
    bcc DoNotLoopLevel3Up

    sbb DifficultyLevel #9

DoNotLoopLevel3Up
    jsr HighlightLevel
    jmp CheckKeys
;----
ChangeOfLevel3Down
    sbb DifficultyLevel #3
    bpl @+
      adb DifficultyLevel #9
@
    jsr HighlightLevel
    jmp CheckKeys
;----
EndOfNick
    ; storing name of the player and its level

    ; level of the computer opponent goes to
    ; the table of levels (difficulties)
    ldx tanknr
    lda DifficultyLevel
    sta skilltable,x
    ; storing name of the tank in the right space
    ; (without cursor!)
    ldy #$00
    txa    ; ldx TankNr
    asl
    asl
    asl ; 8 chars per name
    tax  ; in X where to put new name

    mva #sfx_next_player sfx_effect


    ; check if all chars are empty (" ")
    ldy #7
    lda #0
@     ora NameAdr,y 
      and #$7F  ; remove inverse (Cursor)
      dey
    bpl @-
    tay
    beq MakeDefaultName

    ldy #0
nextchar04
    lda NameAdr,y
    and #$7f ; remove inverse (Cursor)
    sta tanksnames,x
    inx
    iny
    cpy #$08
    bne nextchar04
    rts
MakeDefaultName
nextchar05
    lda tanksnamesDefault,x
    sta tanksnames,x
    inx
    iny
    cpy #$08
    bne nextchar05
    rts
.endp


.proc HighlightLevel
    ; this routine highlights the choosen
    ; level of the computer opponent
    ldx #8 ; 9 possible levels
CheckNextLevel01
    lda LevelNameBeginL,x ; address on the screen
    sta temp
    lda LevelNameBeginH,x
    sta temp+1
    ldy #9 ; flip 10 chars to inverse video
    cpx DifficultyLevel ; is it the choosen level?
    bne NotThisLevel
    ; change to inverse, because it is it!
InverseFurther
    lda (temp),y
    ora #$80
    sta (temp),y
    dey
    bpl InverseFurther
    bmi CheckNextLevel ; Check Next Level
NotThisLevel
    lda (temp),y
    and #$7f
    sta (temp),y
    dey
    bpl NotThisLevel
CheckNextLevel
    dex
    bpl CheckNextLevel01
    rts
.endp

;--------------------------------------------------
.proc displaydec5 ;decimal (word), displayposition  (word)
;--------------------------------------------------
; displays decimal number as in parameters (in text mode)
; leading zeroes are removed
; the range is (00000..65565 - two bytes)

    ldy #4  ; there will be 5 digits
NextDigit
    ldx #16 ; 16-bit dividee so Rotate 16 times
    lda #$00
Rotate000
    aslw decimal
    rol  ; scroll dividee
    ; (as highest byte - additional - byte is A)
    cmp #10  ; divider
    bcc TooLittle000 ; if A is smaller than divider
    ; there is nothing to substract
    sbc #10  ; divider
    inc decimal     ; lowest bit set to 1
    ; because it is 0 and this is the fastest way
TooLittle000 dex
    bne Rotate000 ; and Rotate 16 times, Result will be in decimal
    tax  ; and the rest in A
    ; (and it goes to X because
    ; it is our decimal digit)
    lda digits,x
    sta decimalresult,y
    dey
    bpl NextDigit ; Result again /10 and we have next digit

;rightnumber
    ; displaying without leading zeroes (if zeroes exist then display space at this position)
    ldy #0
	ldx #0	; digit flag (cut leading zeroes)
displayloop
    lda decimalresult,y
	cpx #0
	bne noleading0
	cpy #4
	beq noleading0	; if 00000 - last 0 must be
	cmp zero
	bne noleading0
	lda space
	beq displaychar	; space = 0 !
noleading0
	inx		; set flag (no leading zeroes to cut)
displaychar
    sta (displayposition),y
nexdigit
    iny
	cpy #5
    bne displayloop

    rts
.endp
;--------------------------------------------------
.proc displaybyte ;decimal (byte), displayposition  (word)
;--------------------------------------------------
; displays decimal number as in parameters (in text mode)
; leading zeores are removed
; the range is (00..99 - one byte)

    ldy #1 ; there will be 2 digits
NextDigit2
    ldx #8 ; 8-bit dividee so Rotate 8 times
    lda #$00
Rotate001
    asl decimal
    rol  ; scroll dividee
    ; (as highest byte - additional - byte is A)
    cmp #10  ; divider
    bcc TooLittle001 ; if A is smaller than divider
    ; there is nothing to substract
    sbc #10  ; divider
    inc decimal     ; because it is 0 and this is the fastest way
TooLittle001 dex
    bne Rotate001 ; and Rotate 8 times, Result will be in decimal
    tax  ; and the rest in A
    ; (and it goes to X because
    ; it is our decimal digit)
    lda digits,x
    sta decimalresult,y
    dey
    bpl NextDigit2 ; Result again /10 and we have next digit

; now cut leading zeroes (02 goes   2)
    lda decimalresult
    cmp zero
    bne decimalend1
    lda space
    sta decimalresult

decimalend1
    ; displaying
    ldy #1
displayloop1
    lda decimalresult,y
    sta (displayposition),y
    dey
    bpl displayloop1

    rts
.endp

;--------------------------------------------------------
.proc Display4x4AboveTank ;
    ; Displays texts using PutChar4x4 above tank and mountains.
    ; Pretty cool, eh!
    ;parameters are:
    ;Y - number of tank above which text is displayed
    ;fx - length of text
    ;textAddress - address of the text

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

    mwa temp TextPositionX

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
    sta TextPositionY

    mva #0 TextCounter
    mwa TextAddress temp
DOTNcharloop
    ldy TextCounter

    lda (temp),y
    and #$3f ;always CAPITAL letters

    sta CharCode4x4
    lda TextCounter
    asl
    asl
    clc
    adc TextPositionX
    sta dx
    lda #0
    adc TextPositionX+1
    sta dx+1
    lda TextPositionY
    sta dy
	mva #0 dy+1	; dy is 2 bytes value
    jsr PutChar4x4

    inc TextCounter
    lda fx
    cmp TextCounter
    bne DOTNcharloop

    rts
.endp

;--------------------------------------------------------
.proc DisplayOffensiveTextNr ;
    ldx TextNumberOff
    lda talk.OffensiveTextTableL,x
    sta TextAddress
    lda talk.OffensiveTextTableH,x
    sta TextAddress+1
    inx ; the next text
    lda talk.OffensiveTextTableH,x
    sta temp+1
    lda talk.OffensiveTextTableL,x
    sta temp  ; opty possible
    ; substract address of the next text from previous to get text length
    sbw temp TextAddress temp2
    mva temp2 fx 

    jsr Display4x4AboveTank
    rts
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
    mwa temp TextAddress

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
    ;this routine prints line ending with $ff
    ;address in LineAddress4x4 (it is the same as `temp`)
    ;starting from LineXdraw, LineYdraw

    lda #$ff

staplot4x4color
    sta plot4x4color


    ldy #0
    sty LineCharNr

TypeLine4x4Loop
    ldy LineCharNr

    ;mwa LineAddress4x4 temp  ; LineAddress4x4 === temp
    lda (temp),y
    cmp #$ff
    beq EndOfTypeLine4x4

    sta CharCode4x4
    mwa LineXdraw dx
    mva LineYdraw dy
	mva #0 dy+1  ;	dy is 2 bytes value
    jsr PutChar4x4 ;type empty pixels as well!
    adw LineXdraw #4
    inc LineCharNr
    jmp TypeLine4x4Loop

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
    
    ;seppuku
    mwa #areYouSureText LineAddress4x4
    mwa #((ScreenWidth/2)-(8*4)) LineXdraw  ; centering
    mva ResultY LineYdraw
    jsr TypeLine4x4
    adb ResultY  #4 ;next line
    
    ;bottom frame
    mva ResultY LineYdraw
    jsr TL4x4_bottom
    

    jsr GetKey
    cmp #$2b  ; "Y"
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
      mwa #((ScreenWidth/2)-(8*4)) LineXdraw  ; centering
      mva ResultY LineYdraw
      jsr TypeLine4x4
      adb ResultY  #4 ;next line
  
      dec di
      bne @-

quit_areyousure
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
      mwa #((ScreenWidth/2)-(8*4)) LineXdraw  ; centering
      mva ResultY LineYdraw
      jsr TypeLine4x4
      adb ResultY  #4 ;next line
      
      ;bottom frame
      mva ResultY LineYdraw
      jsr TL4x4_bottom  ; just go

    ;clean seppuku
    
    mva #3 di
    mva #4 ResultY
@
      mwa #lineClear LineAddress4x4
      mwa #((ScreenWidth/2)-(8*4)) LineXdraw  ; centering
      mva ResultY LineYdraw
      jsr TypeLine4x4
      adb ResultY  #4 ;next line
  
      dec di
      bne @-

     dec fs
    jne seppuku_loop

quit_seppuku
    rts
.endp
;--------------------------------
.proc DisplayResults ;
;displays results of the round
;using 4x4 font
    jsr RoundOverSprites

    
    mva #$ff plot4x4color
        
    ;centering the result screen
    mva #((ScreenHeight/2)-(8*4)) ResultY


    ;upper frame
    mva ResultY LineYdraw
    jsr TL4x4_top

    adb ResultY  #4 ;next line

    ;Header1
    ;Displays round number
    lda CurrentRoundNr
    cmp RoundsInTheGame
    beq GameOver4x4
    
    sta decimal
    mwa #RoundNrDisplay displayposition
    jsr displaybyte ;decimal (byte), displayposition  (word)

    mwa #LineHeader1 LineAddress4x4
    mwa #((ScreenWidth/2)-(8*4)) LineXdraw
    mva ResultY LineYdraw
    jsr TypeLine4x4
    beq @+ ;unconditional jump, because TypeLine4x4 ends with beq

GameOver4x4
    lda #song_round_over
    jsr RmtSongSelect
    mwa #LineGameOver LineAddress4x4
    mwa #((ScreenWidth/2)-(8*4)) LineXdraw
    mva ResultY LineYdraw
    jsr TypeLine4x4
    mva #1 GameIsOver
    
@
    adb ResultY  #4 ;next line

    ;Empty line
    mva ResultY LineYdraw
    jsr TL4x4_empty

    adb ResultY  #2 ;next line


    ;Header2
    mwa #LineHeader2 LineAddress4x4
    mwa #((ScreenWidth/2)-(8*4)) LineXdraw
    mva ResultY LineYdraw
    jsr TypeLine4x4

    adb ResultY  #4 ;next line

    ;Empty line
    mva ResultY LineYdraw
    jsr TL4x4_empty

    sbb ResultY  #2 ;next line (was empty)

    ldx NumberOfPlayers  ;we start from the highest (best) tank
    dex   ;and it is the last one
    stx ResultOfTankNr  ;in TankSequence table

    mwa #TanksNames tempXROLLER

ResultOfTheNextPlayer
    ldx ResultOfTankNr ;we are after a round, so we can use TankNr
    lda TankSequence,x ;and we keep here real number if the tank
    sta TankNr   ;for which we are displaying results




    adb ResultY  #4 ;next line

    ;there are at least 2 players, so we can safely
    ;start displaying the result

    lda #3 ;it means |
    sta ResultLineBuffer

    ldy TankNr
    lda ResultsTable,y
    sta decimal
    mva #0 decimal+1
    mwa #(ResultLineBuffer+8) displayposition
    jsr displaydec5 ;decimal (byte), displayposition  (word)

    ; overwrite the second digit of the points (max 255)
    ;it means ":"
    mva #26 ResultLineBuffer+9
	
    ldx #0
    lda TankNr
    asl
    asl ; times 8, because it is lengtgh
    asl ; of the names of the tanks
    tay

TankNameCopyLoop
    lda (tempXROLLER),y  ;XROLLER is not working now
    and #$3f ;always CAPITAL letters
    inx
    sta ResultLineBuffer,x
    iny
    cpx #8 ; end of name
    bne TankNameCopyLoop
	; last letter of tank name overwrites first digit of the points (max 255)


    ;just after the digits
    ;it means |
    mva #$3 ResultLineBuffer+13


    ;it means end of line
    mva #$ff ResultLineBuffer+14

    ;result line display
    mwa #ResultLineBuffer LineAddress4x4
    mwa #((ScreenWidth/2)-(8*4)) LineXdraw
    mva ResultY LineYdraw
    jsr TypeLine4x4

    adb ResultY  #4 ;next line

    ;Empty line
    mva ResultY LineYdraw
    jsr TL4x4_empty

    dec ResultOfTankNr
    bmi FinishResultDisplay

    sbb ResultY  #2 ;distance between lines is smaller

    jmp ResultOfTheNextPlayer

FinishResultDisplay
    mva ResultY LineYdraw
    ;jmp TL4x4_bottom  ; just go
.endp

.proc TL4x4_bottom
    ;bottom of the frame
    mwa #LineBottom LineAddress4x4
    mwa #((ScreenWidth/2)-(8*4)) LineXdraw
    jmp TypeLine4x4  ; jsr:rts
.endp

.proc TL4x4_top
    ;bottom of the frame
    mwa #LineTop LineAddress4x4
    mwa #((ScreenWidth/2)-(8*4)) LineXdraw
    jmp TypeLine4x4  ; jsr:rts
.endp

.proc TL4x4_empty
    ;empty frame
    mwa #LineEmpty LineAddress4x4
    mwa #((ScreenWidth/2)-(8*4)) LineXdraw
    jmp TypeLine4x4  ; jsr:rts
.endp

;--------------------------------------------------
.proc GameOverScreen
;--------------------------------------------------
    jsr WaitForKeyRelease
    jsr ClearScreen
    jsr ClearPMmemory
	jsr PrepareCredits
	jsr GameOverResultsClear
    mwa #GameOverDL dlptrs
    lda #%00111110  ; normal screen width, DL on, P/M on
    sta dmactls
    lda #%00100100  ; playfield before P/M
    sta GPRIOR
	jsr SetPMWidth	
    jsr ColorsOfSprites
    mva #0 COLOR1
	sta COLBAKS	; set color of background
	sta CreditsVScrol
    mva #TextForegroundColor COLOR2
    VDLI DLIinterruptGameOver  ; jsr SetDLI for Game Over screen
	; make text and color lines for each tank
    ldx NumberOfPlayers  ;we start from the highest (best) tank
    dex   ;and it is the last one
    stx ResultOfTankNr  ;in TankSequence table
	ldy #0 ;witch line we are coloring
FinalResultOfTheNextPlayer
    ldx ResultOfTankNr ;we are after a round, so we can use TankNr
    lda TankSequence,x ;and we keep here real number if the tank
	tax
    stx TankNr   ;for which we are displaying results
	lda TankStatusColoursTable,x
	sta GameOverColoursTable,y
	; Y - line number (from 0 to 5)
	; X - TanNr
	; let's make texts
	phy
	; first calculate adres first byte of line
	mwa #GameOverResults temp
@	dey
	bmi LineAdresReady
	adw temp #40
	jmp @-
LineAdresReady
	; put position of tank on the screen
	pla
	pha	; now we have line number in A register
	ldy #1
	tax
	lda zero+1,x
	sta (temp),y
; puts name of the tank on the screen
    ldy #$03
    lda TankNr
    :3 asl ; 8 chars per name
    tax
NextChar
    lda tanksnames,x
    sta (temp),y
    inx
    iny
    cpy #$08+3
    bne NextChar
	; put big points on the screen
    ldx TankNr
    lda ResultsTable,x
    sta decimal
    mva #0 decimal+1
    adw temp #12 displayposition
    jsr displaydec5
	mva #0 displayposition	; overwrite first digit
	; put hits points on the screen
    ldx TankNr
    lda DirectHitsL,x
    sta decimal
	lda DirectHitsH,x
    sta decimal+1
    adw temp #19 displayposition
    jsr displaydec5
	mva #0 displayposition	; overwrite first digit
	; put earned money on the screen
    ldx TankNr
    lda EarnedMoneyL,x
    sta decimal
	lda EarnedMoneyH,x
    sta decimal+1
    adw temp #30 displayposition
    jsr displaydec5
	ldy #35
	lda zero
	sta (temp),y ; and last zero
	ply
	iny
    dec ResultOfTankNr
    jpl FinalResultOfTheNextPlayer
MakeBlackLines
	cpy #$06
	beq AllLinesReady
	lda #0	; black line color for rest of tanks
	sta GameOverColoursTable,y
	iny
	bne MakeBlackLines
AllLinesReady
    ldx #(MaxPlayers-1)
MakeAllTanksVisible
    lda #99
    sta eXistenZ,x
	lda #0
	sta ActiveDefenceWeapon,x
    dex
    bpl MakeAllTanksVisible
	jsr SetStandardBarrels

	; start music and animations
    lda #song_ending_looped
    jsr RmtSongSelect
    ; initial tank positions randomization
    ldx #(MaxPlayers-1)   ;maxNumberOfPlayers-1
@
    jsr RandomizeTankPos
    dex
    bpl @-
MainTanksFloatingLoop   
    ; main tanks floating loop
    ldx #(MaxPlayers-1)   ;maxNumberOfPlayers-1
AllTanksFloatingDown    
    stx TankNr
    lda Ytankstable,x
	cmp #72		; tank under screen - no erase
	bcs NoEraseTank
	mva #1 Erase
    jsr DrawTankNr
	mva #0 Erase
	sta ATRACT	; reset atract mode
NoEraseTank
	ldx TankNr
    inc Ytankstable,x
	lda ActiveDefenceWeapon,x
	beq NotFastTank
    :3 inc Ytankstable,x
NotFastTank
    lda Ytankstable,x
;   cmp #32     ; tank over screen - not visible
    cmp #80     ; tank under screen - new tank randomize
    bcs TankUnderScreen
    cmp #72     ; tank under screen but.... parachute
    bcs DrawOnlyParachute
    bcc TankOnScreen
TankUnderScreen
    jsr RandomizeTankPos
TankOnScreen
    jsr DrawTankNr
DrawOnlyParachute
	lda ActiveDefenceWeapon,x
	bne FastTank
    jsr DrawTankParachute
FastTank
;    ldx TankNr
    dex
    bpl AllTanksFloatingDown
	jsr IsKeyPressed
    bne MainTanksFloatingLoop   ; neverending loop
	mva #0 dmactls		; dark screen
	jsr WaitOneFrame
	jsr GameOverResultsClear
    rts
RandomizeTankPos
    randomize 10 32	; 10 not 8 - barrel !! :)
    sta Ytankstable,x
    randomize 0 180
    sta AngleTable,x
    randomize 0 (49-8)
    and #%11111110  ; correction for PMG
    clc
    adc XtankOffsetGO_L,x
    sta XtankstableL,x
    lda XtankOffsetGO_H,x
    adc #0
    sta XtankstableH,x
	lda random
	cmp #32	; like 1:8
	bcc NowFastTank
	lda #0
	sta ActiveDefenceWeapon,x
    rts
NowFastTank
	lda #1
	sta ActiveDefenceWeapon,x
    rts
GameOverResultsClear
	lda #$00
	tax
@	sta GameOverResults,x
	inx
	cpx #(6*40)+1
	bne @-
	rts
PrepareCredits
	; Rewrites credits and places it in the middle of each line.
	mwa #CreditsStart temp	; from
	mwa #Credits temp2	; to
MainRewriteLoop
	ldy #0
	cpw temp #CreditsEnd
	beq EndOfCredits
	; count characters in this line
@	lda (temp),y
	bmi LastCharFound
	iny
	bne @-
LastCharFound
	; in Y number of characters reduced by 1
	; let's count how many spaces add before the text
	sec
	sty magic
	lda #40
	sbc magic
	lsr		; now in A we have number of spaces in front
	sta magic
	ldy #0
	tya
	tax
FirstSpaces
	sta (temp2),y	; fill the area in front of the text with spaces
	iny
	cpy magic
	bne FirstSpaces
MainText
	lda (temp,x)
	sta (temp2),y	; rewrite the text to a new place
	bmi LastCharWritten
	inw temp
	iny
	bne MainText
LastCharWritten
	inw temp
	and #%01111111	; remove inverse
	sta (temp2),y
	iny
	txa	; space to A (0)
LastSpaces
	sta (temp2),y	; fill the area behind the text with spaces
	iny
	cpy #40
	bne LastSpaces
NextLine
	adw temp2 #40
	jmp MainRewriteLoop
EndOfCredits
	mwa #Credits DLCreditsAddr	; set address in DL to first line
	rts
.endp
;-------------------------------------------------
.proc DisplayStatus
;-------------------------------------------------

    ;---------------------
    ;displaying symbol of the weapon
    ;---------------------
    ;display name and symbol of the weapon
    ;textbuffer+18  - symbol (1 char)
    ;textbuffer+20  - quantity left
    ;textbuffer+23  - name
    ldx TankNr
    ldy ActiveWeapon,x
    lda WeaponSymbols,y
    sta TextBuffer+18

    ;---------------------
    ;displaying quantity of the given weapon
    ;---------------------
    lda ActiveWeapon,x
    jsr HowManyBullets
    sta decimal
    mwa #textbuffer+20 displayposition
    jsr displaybyte

    ;---------------------
    ;displaying name of the weapon
    ;---------------------
    ldx TankNr
    lda ActiveWeapon,x
    sta temp ;get back number of the weapon
    mva #0 temp+1
    ; times 16 (because this is length of weapon name)
    ldy #3 ; shift left 4 times
@
      aslw temp
      dey
    bpl @-
 
    adw temp #NamesOfWeapons
    ldy #15
@
      lda (temp),y
      sta textbuffer+23,y
      dey
    bpl @-

    ;---------------------
    ;displaying name of the defence weapon (if active)
    ;---------------------
    lda #$08 ; (
    sta textbuffer+80+22
    lda #$09    ; )
    sta textbuffer+80+39
    lda ActiveDefenceWeapon,x
    bne ActiveDefence
    ; clear brackets
    lda #$00 ; space
    sta textbuffer+80+22
    sta textbuffer+80+39
    lda #47 ; no weapon name
ActiveDefence
    sta temp ;get back number of the weapon
    mva #0 temp+1
    ; times 16 (because this is length of weapon name)
    ldy #3 ; shift left 4 times
@
      aslw temp
      dey
    bpl @-
 
    adw temp #NamesOfWeapons

    ldy #15
@
      lda (temp),y
      sta textbuffer+40+40+23,y
      dey
    bpl @-

    ;---------------------
    ;displaying the energy of a tank
    ;---------------------

    lda Energy,x

    sta decimal
    mwa #textbuffer+48 displayposition
    jsr displaybyte

    ;---------------------
    ;displaying the energy of a tank shield (if exist)
    ;---------------------
    ; clear (if no shield)
    lda #$00    ; space
    sta textbuffer+40+10
    sta textbuffer+40+11
    sta textbuffer+40+12
    sta textbuffer+40+13
    ; check shield energy and display it
    ldx TankNr
    lda ActiveDefenceWeapon,x
    beq NoDefenceWeapon
    lda ShieldEnergy,x
    beq NoShieldEnergy
    sta decimal ; displayed value
    lda #$08 ; (
    sta textbuffer+40+10
    mwa #textbuffer+40+11 displayposition
    jsr displaybyte
    lda #$09    ; )
    sta textbuffer+40+13
NoDefenceWeapon 
NoShieldEnergy

    ;=========================
    ;display Wind
    ;=========================
    mwa Wind temp
    lda Wind+3 ; highest byte of 4 byte wind
    bmi DisplayLeftWind
    lda #$7f  ; (tab) char
    sta textbuffer+80+20
    lda #0  ;space
    sta textbuffer+80+17
    beq DisplayWindValue
DisplayLeftWind
      sec  ; Wind = -Wind
      lda #$00
      sbc temp
      sta temp
      lda #$00
      sbc temp+1
      sta temp+1
    lda #$7e  ;(del) char
    sta textbuffer+80+17
    lda #0 ;space
    sta textbuffer+80+20
DisplayWindValue
    :4 lsrw temp ;divide by 16 to have a nice value on a screen
    lda temp
    sta decimal
    mwa #textbuffer+80+18 displayposition
    jsr displaybyte
    
    ;=========================
    ;display round number
    ;=========================
    lda CurrentRoundNr
    sta decimal
    mwa #textbuffer+80+7 displayposition
    jsr displaybyte ;decimal (byte), displayposition  (word)

    ;=========================
    ;display Force
    ;=========================
    ldx TankNr
    lda ForceTableL,x
    sta decimal
    lda ForceTableH,x
    sta decimal+1
    mwa #textbuffer+40+35 displayposition
    jsr displaydec5

    ;=========================
    ;display Angle
    ;=========================
displayAngle
    ldx TankNr
    lda AngleTable,x
    cmp #90
    beq VerticallyUp
    bcs AngleToLeft
AngleToRight
    ; now we have values from 0 to 89 and right angle
    sta decimal
    lda #$7f  ; (tab) character
    sta textbuffer+40+25
    lda #0  ;space
    sta textbuffer+40+22
    beq AngleDisplay
AngleToLeft
    sec
    lda #180
    sbc AngleTable,x
    ; angles 180 - 91 converted to 0 - 89
    sta decimal
    lda #$7e  ;(del) char
    sta textbuffer+40+22
    lda #0 ;space
    sta textbuffer+40+25
    beq AngleDisplay    
VerticallyUp
    ; now we have value 90
    sta decimal
    lda #0  ;space
    sta textbuffer+40+25
    sta textbuffer+40+22

AngleDisplay
    mwa #textbuffer+40+23 displayposition
    jsr displaybyte
    ldx TankNr   
    rts
.endp
;-------------------------------------------------
.proc PutTankNameOnScreen
; puts name of the tank on the screen
    ldy #$00
    lda tanknr
    asl
    asl
    asl ; 8 chars per name
    tax
NextChar02
    lda tanksnames,x
    sta textbuffer+7,y
    inx
    iny
    cpy #$08
    bne NextChar02
    rts
.endp
;-------------------------------------------------
.proc RoundOverSprites
    ; fill sprites with bytes
    ldy numberOfPlayers
    dey
    lda gameOverSpritesTop,y
    sta temp
    
    ; clean the whole sprite
    lda #0
    tax
@     sta PMGraph+$400,x
      sta PMGraph+$500,x
      dex
    bne @-
    
    lda #$01
    sta sizep0 ; P0-P1 widths
    sta sizep0+1
    
    ; set background
    lda #$ff
    ldx #100 ; top of the sprites
@     sta PMGraph+$400,x
      sta PMGraph+$500,x
      inx
    cpx temp
    bne @-
    GOSbeg = 112
    mva #GOSbeg hposp0
    mva #GOSbeg+12 hposp0+1
    
    mva #15 PCOLR0
    sta PCOLR1
    
    rts
.endp
;-------------------------------------------------

.endif