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

    mwa #DisplayCopyRom temp
    mwa #display temp2
    mwa #DisplayCopyEnd+1 modify
    jsr CopyFromROM

    mwa #OptionsDL dlptrs

    lda #%00111110  ; normal screen width, DL on, P/M on
    sta dmactls
	jsr SetPMWidth
    mva #TextBackgroundColor COLOR2
    jsr ColorsOfSprites
	mva #$ca COLOR1
	mva #$00 COLBAKS	; set color of background
   
    SetDLI DLIinterruptOptions  ; jsr SetDLI for Options text screen

; -------- setup bottom (tanks) line	
	lda NumberOfPlayers
	pha
    lda mountainsDeltaTableH
    sta mountainDeltaH
    lda mountainsDeltaTableL
    sta mountainDeltaL
	mva #6 NumberOfPlayers
    jsr PMoutofScreen ;let P/M disappear
    ;jsr clearscreen   ;let the screen be clean (clean-ish already)
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

	lda WindChangeInRound
	sta OptionsHere+126

    jsr OptionsInversion
    jsr getkey
    bit escFlag
    spl:rts
       
    cmp #@kbcode._down  ; $f  ;cursor down
    bne OptionsNoDown
    inc:lda OptionsY
    cmp #maxoptions
    bne OptionsMainLoop
    mva #maxoptions-1 OptionsY
    jmp OptionsMainLoop

OptionsNoDown
    cmp #@kbcode._up  ; $e ;cursor up
    bne OptionsNoUp
    dec OptionsY
    bpl OptionsMainLoop
    mva #0 OptionsY
    jmp OptionsMainLoop

OptionsNoUp
    cmp #@kbcode._left  ; $6 ;cursor left
    bne OptionsNoLeft
    ldx OptionsY
    dec OptionsTable,X
    lda OptionsTable,X
    bpl OptionsMainLoop
    inc OptionsTable,X
    jmp OptionsMainLoop

OptionsNoLeft
    cmp #@kbcode._right  ; $7 ;cursor right
    bne OptionsNoRight

    ldx OptionsY
    inc OptionsTable,X
    lda OptionsTable,X
    cmp #5  ; number of columns in options
    bne OptionsMainLoop
    dec OptionsTable,X
    jmp OptionsMainLoop

OptionsNoRight
    cmp #@kbcode._ret  ; $c ;Return key
    bne OptionsNoReturn
    rts		; options selected
	
OptionsNoReturn
	cmp #@kbcode._tab	; Tab key
	bne OptionsNoTab
	jsr SelectNextGradient
OptionsNoTab
    jmp OptionsMainLoop
.endp
.proc SelectNextGradient
	lda OptionsY	; if "Wind" option selected
	cmp #$03
	bne NotWind
	lda WindChangeInRound	; wind change after each turn (not round only) flag
	eor #$1f	; '?' character
	sta WindChangeInRound
	rts
NotWind
	ldy GradientNr
	iny
	cpy #$03
	bne NoGradientLoop
	ldy #$00
NoGradientLoop
	sty GradientNr
	lda GradientAddrL,y
	sta GradientColors
	lda GradientAddrH,y
	sta GradientColors+1	
	rts
.endp
;--------
; inversing selected option (cursor)
;--------
.proc OptionsInversion
YPos = temp2
XPos = temp2+1
optionWidth = 6
nameWidth = 10
    mwa #OptionsHere temp  ; offset of the first option=11
    mva #0 YPos  ;option number pointer
    mva #0 Xpos  ;X position in the menu
    tay  ; Y is zero here...
OptionsSetMainLoop
    ldx YPos  ; Y position in the menu
;inversing the first few chars of the selected line (OptionsY)
    cpx OptionsY
    jsr _inverter
    cpy #nameWidth-1
    bne OptionsSetMainLoop
    adw temp #nameWidth
    ldy #0

OptionsLoop
    lda XPos
    cmp OptionsTable,x
    jsr _inverter
    cpy #optionWidth  ; width of the option highlight
    bne OptionsLoop
    ldy #0
    ; next X position of the 
    adw temp #optionWidth  ; width of the option highlight
    inc:lda XPos
    cmp #5  ; number of options in a row
    bne OptionsLoop
    ; next line
    ;adw temp #nameWidth  ; beginning of the next line
    mva #0 Xpos
    tay
    inc:lda Ypos
    cmp #maxOptions
    bne OptionsSetMainLoop
    rts

_inverter
    beq invertme
    ; clean inversion otherwise
    lda (temp),y 
    and #$7f  ; clear the top bit
    sta (temp),y
    bpl @+  ; JMP
invertme
    lda (temp),y 
    ora #$80  ; set the top bit
    sta (temp),y
@
    ; next character in an option
    iny
    rts
.endp

; --------------------------------------
; Sets the appropriate variables based on the options table
; 
.proc SetVariablesFromOptions
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
	lda JoyNumber,x
	sta JoystickNumber	; set joystick port for player
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
    mva #%10000000 WhichList
    ; offensive weapon - 0, defensive - %10000000
	jmp Purchase.GoToActivation
.endp

;--------------------------------------------------
.proc CopyFromPurchaseAndGameOver
    mwa #DisplayCopyPurchaseDlROM temp
    mwa #DisplayCopyPurchase temp2
    mwa #DisplayCopyPurchaseEnd+1 modify
    jmp CopyFromROM ; jsr:rts
.endp

;--------------------------------------------------
.proc Purchase ;
;--------------------------------------------------
; In tanknr there is a number of the tank (player)
; that is buying weapons now (from 0).
; Rest of the data is taken from appropriate tables
; and during the purchase these tables are modified.

    jsr CopyFromPurchaseAndGameOver

    mwa #ListOfWeapons WeaponsListDL ;switch to the list of offensive weapons
        
; we are clearing list of the weapons
    mva #$00 WhichList
    ; offensive weapon - 0, deffensive - %10000000
GoToActivation
    mva #$ff LastWeapon

    SetDLI DLIinterruptText  ; jsr SetDLI for text (purchase) screen
    jsr PMoutofScreen
    mwa #PurchaseDL dlptrs
    lda #@dmactl(narrow|dma) ; narrow screen width, DL on, P/M off
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
	lda #$ca
	sta COLOR1 ; set color of header text
	ldy #0
	sty COLBAKS	; set color of background
    lda tanknr
    :3 asl  ; 8 chars per name
    tax
NextChar03
    lda tanksnames,x
    sta purchaseTextBuffer+7,y
    inx
    iny
    cpy #$08
    bne NextChar03
	; displaying number of active controller port
	ldy JoystickNumber
	lda digits+1,y
	sta purchaseTextBuffer+17

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
    mwa #purchaseTextBuffer+26 displayposition
    jsr displaydec5

    ; in xbyte there is the address of the line that
    ; is being processed now
    mwa #ListOfWeapons xbyte
    ldx #$00  ; index of the checked weapon
    stx HowManyOnTheListOff ; amounts of weapons (shells, bullets) in both lists
    stx HowManyOnTheListDef
    
    jsr CreateList

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
      cpy #(last_offensive_____ - first_offensive____)+1  ; maxOffensiveWeapons
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
	jsr _MakeOffsetDown		; set list screen offset

; Here we have all we need
; So choose the weapon for purchase ......
;--------------------------------------------------
ChoosingItemForPurchase
;--------------------------------------------------
    
    jsr PutLitteChar ; Places pointer at the right position
    jsr getkey
    bit escFlag
    bpl @+
    mva #0 escFlag
    jmp WaitForKeyRelease  ; like jsr ... : rts
@
    cmp #@kbcode._tab  ; $2c ; Tab
    jeq ListChange
    cmp #@kbcode._left  ; $06  ; cursor left
    jeq ListChange
    cmp #@kbcode._ret  ; $0c ; Return
    sne:rts
    cmp #@kbcode._up  ; $e
    beq PurchaseKeyUp
    cmp #@kbcode._down  ;  $f
    beq PurchaseKeyDown
    cmp #@kbcode._space  ; $21 ; Space
    jeq PurchaseWeaponNow
    cmp #@kbcode._right  ; $07 ; cursor right
    jeq PurchaseWeaponNow
    bne ChoosingItemForPurchase

PurchaseKeyUp
    lda WhichList
    bpl GoUpOffensive
    dec PositionOnTheList
    bpl EndUpX
    ldy HowManyOnTheListDef
    dey
    sty PositionOnTheList
    jmp MakeOffsetDown
GoUpOffensive
    dec PositionOnTheList
    bpl MakeOffsetUp
    ldy HowManyOnTheListOff
    dey
    sty PositionOnTheList
	jmp MakeOffsetDown
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
    bpl GoDownOffensive
    inc:lda PositionOnTheList
    cmp HowManyOnTheListDef
    bne EndGoDownX
    ldy #0
    sty PositionOnTheList
	beq MakeOffsetUp
GoDownOffensive
    inc:lda PositionOnTheList
    cmp HowManyOnTheListOff
    bne MakeOffsetDown
    ldy #0
    sty PositionOnTheList
	beq MakeOffsetUp
MakeOffsetDown
	jsr _MakeOffsetDown
EndGoDownX
    jmp ChoosingItemForPurchase

_MakeOffsetDown
    lda OffsetDL1
    clc
    adc #15
    ;if offset+16 is lower than the position then it must =16
    cmp PositionOnTheList
    bcs _EndGoDownX
    sec
    lda PositionOnTheList
    sbc #15
    sta OffsetDL1
_EndGoDownX
	rts

; swapping the displayed list and setting pointer to position 0
ListChange
    mva #0 OffsetDL1

    lda WhichList
    eor #%10000000  ; flip WhichList
    sta WhichList
    bne DeffensiveSelected

    mwa #ListOfWeapons WeaponsListDL
    lda isInventory
    beq @+
    ; inventory
    jsr calcPosOffensive
	jsr _MakeOffsetDown		; set list screen offset
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
;
;--------------------------------------------------
.proc CreateList
;--------------------------------------------------
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
    ldy #25     ; overwrite first digit (allways space - no digit :) )
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
    bit WhichList
    bmi @+
    lda HowManyOnTheListOff
    sta PositionOnTheList
    jmp NotTheSameAsLastTime
@
    lda HowManyOnTheListDef
    sta PositionOnTheList
NotTheSameAsLastTime
    ; increase appropriate counter
    txa
    cpx #last_offensive_____+1
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
    cpx #last_offensive_____+1
    bne NoDefense

; if we got to the defense weapons,
; we switch address to the second table.
    mwa #ListOfDefensiveWeapons xbyte
NoDefense
    cpx #last_defensive_____+1
    
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
    adw xbyte #ListOfWeapons
    ldy #0
ClearList1
    cpw xbyte #ListOfWeapons1End
	beq ListCleared1
    tya ; now there is zero here
    sta (xbyte),y
    inw xbyte
    jmp ClearList1
ListCleared1
    ; And the same we do with the second list

    ; Multiply number on list 1 by 32 and set address
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
    adw xbyte #ListOfDefensiveWeapons
    ldy #0
ClearList2
    cpw xbyte #ListOfDefensiveWeaponsEnd
	beq ListCleared2
    tya ; now there is zero here
    sta (xbyte),y
    inw xbyte
    jmp ClearList2
ListCleared2

; here we have pretty cool lists and there is no brute force
; screen clearing at each list refresh
; (it was very ugly - I checked it :)
    rts
.endp

;--------------------------------------------------
.proc PurchaseWeaponNow
; weapon purchase routne increases number of possessed bullets
; decreases cash and jumps to screen refresh
;--------------------------------------------------
    bit isInventory
    bmi inventorySelect

    bit WhichList
    bmi PurchaseDeffensive

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
	randomize ind_Missile________ last_offensive_____
	;cmp #ind_Buy_me_________ ; buy me do not buy buy me :)
	;beq GetRandomOffensive
	tay
	bne NoSuprise	; Y always <> 0
GetRandomDefensive
	randomize ind_Battery________ last_defensive_____
	tay
;    lda WeaponUnits,y	; check if weapon exist
;	beq GetRandomDefensive
	
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
    bit whichList
    bmi invSelectDef

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
	cmp #ind_Auto_Defense___
	bne NoAutoDefense
    ; Auto Defense - do it like battery
    mva #sfx_auto_defense sfx_effect
    mva #$A1 AutoDefenseFlag,x	; this is "A" in inverse - for status line :)
    jmp DecreaseDefensive ; bypass activation
NoAutoDefense
	cmp #ind_Lazy_Boy_______
	bne NoLazyBoy
	; Lazy Boy - do it like battery
	mva #%01000000 LazyFlag
    jmp DecreaseDefensive ; bypass activation
NoLazyBoy
	cmp #ind_Lazy_Darwin____
	bne NoLazyDarwin
	; Lazy Darwin - do it like battery
	mva #%11000000 LazyFlag
    jmp DecreaseDefensive ; bypass activation
NoLazyDarwin
	cmp #ind_Spy_Hard_______
	bne NotSpy
	mva #$ff SpyHardFlag
    jmp DecreaseDefensive ; bypass activation	
NotSpy
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
      cpy #(last_defensive_____ - first_defensive____)+1  ; maxDefensiveWeapon
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
      cpy #(last_offensive_____ - first_offensive____)  ; maxOffensiveWeapon
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
    ldx #last_defensive_____ ; there are xx lines total
    ldy #$00
EraseLoop
    tya  ; lda #$00
    sta (xbyte),y
    adw xbyte #32  ; narrow screen
    dex
    bpl EraseLoop

    ; now let's check which list is active now
    bit WhichList
    bpl CharToList1
    ; we are on the second list (deffensive)
    ; so there is no problem with scrolling
    mwa #ListOfDefensiveWeapons xbyte
    ldx PositionOnTheList
    beq SelectList2 ; if there is 0 we add nothing
AddLoop2
    adw xbyte #32  ; narrow screen
    dex
    bne AddLoop2
SelectList2
    lda #$7f ; little char (tab) - this is the pointer
    sta (xbyte),y
    ; now we clear up and down arrows indicating more content below or above screen
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
    adw xbyte #32  ; narrow screen
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
    adw xbyte #32  ; narrow screen
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
    sbc #17  ; ????
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
    lda #%00110001 ; narrow screen width, DL on, P/M off
    sta dmactls
    SetDLI DLIinterruptText  ; jsr SetDLI for text (names) screen

    mva #0 TankNr
	sta COLBAKS	; set color of background
@     tax
      lda TankStatusColoursTable,x
      sta COLOR2  ; set color of player name line
      jsr EnterPlayerName
      bit escFlag
      spl:rts
	  jsr CheckTankCheat
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
	lda digits+1,x
    sta NameScreen2+7

    ; clear tank name editor field - not necessary
;    ldx #8
;    lda #0
;@     sta NameAdr,x
;      dex
;    bpl @-
    
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
	and #$7f
	bne LastNameChar
	dey
	bpl @-
LastNameChar
	cpy #7
	beq @+
	iny
@	sty PositionInName

CheckKeys
    jsr HighlightLevel ; setting choosen level of the opponent (Moron, etc)
	ldx TankNr
	lda JoyNumber,x
    tay
	lda digits+1,y
    sta NameScreen2+11	; display joystick port number
	lda TankShape,x
    tay
	lda digits+1,y
    sta NameScreen2+15	; display tank shape number	
	jsr CursorDisplay
    jsr getkey
    bit escFlag
    spl:rts
    
	.IF TARGET = 800	; only the A800 has a keyboard
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
    sta NameAdr,x
    inx
    cpx #$08 ; is there 8 characters?
	bne @+
	dex
@	stx PositionInName ; if not, we store
    jmp CheckKeys
	.ENDIF
CheckFurtherX01 ; here we check Tab, Return and Del
    cmp #@kbcode._ret  ; $0c ; Return
    jeq EndOfNick
    cmp #@kbcode._tab  ; $2c ; Tab
    beq ChangeOfJoyUp
    cmp #@kbcode._right  ; $7 ;cursor right
    beq ChangeOfLevelUp
    cmp #@kbcode._left  ; $6 ;cursor left
    beq ChangeOfLevelDown
    cmp #@kbcode._down  ; $f ;cursor down
    beq ChangeOfLevel3Up
    cmp #@kbcode._up  ; $e ;cursor up
    beq ChangeOfLevel3Down
	cmp #@kbcode._atari	; atari (inverse) key
	jeq ChangeOfShapeUp

    cmp #@kbcode._del  ; $34 ; Backspace (del)
    bne CheckKeys
    ; handling backing one char
    ldx PositionInName
    beq FirstChar	; ferst char - no go back
	cpx #7
	bne NotLastChar
    lda NameAdr,x
	and #$7f
	bne LastIsNotSpace	; last char not empty - first clear last char (no go back)
NotLastChar
    dex
LastIsNotSpace
FirstChar
    stx PositionInName
    lda #0
    sta NameAdr,x
    jmp CheckKeys
;----
ChangeOfJoyUp
	ldx TankNr
	inc JoyNumber,x
	lda JoyNumber,x
	and #%00000011	; max 4 joysticks
	sta JoyNumber,x
	.IF TARGET = 5200
		beq ChangeOfShapeUp	; change tank shape
	.ENDIF
    jmp CheckKeys
;----
ChangeOfLevelUp ; change difficulty level of computer opponent
    inc:lda DifficultyLevel
    cmp #9  ; 9 levels are possible
    bne DoNotLoopLevelUp
    mva #$0 DifficultyLevel
DoNotLoopLevelUp
    jmp CheckKeys
;----
ChangeOfLevelDown
    dec:lda DifficultyLevel
    bpl DoNotLoopLevelDown
    mva #$8 DifficultyLevel
DoNotLoopLevelDown
    jmp CheckKeys
;----
ChangeOfLevel3Up
    adb DifficultyLevel #3

    cmp #9
    bcc DoNotLoopLevel3Up

    sbb DifficultyLevel #9

DoNotLoopLevel3Up
    jmp CheckKeys
;----
ChangeOfLevel3Down
    sbb DifficultyLevel #3
    bpl @+
      adb DifficultyLevel #9
@
    jmp CheckKeys
;----
ChangeOfShapeUp
	ldx TankNr
	inc TankShape,x
	lda TankShape,x
	cmp #$03
	bne @+
	lda #$00
	sta TankShape,x
@	jmp CheckKeys
;----
EndOfNick
	; now check long press joy button (or Return...)
    mva #0 pressTimer ; reset
WaitForLongPress
    lda STRIG0	; wait only for joy long press
	bne ShortJoyPress
    lda pressTimer
    cmp #25  ; 1/2s
    bcc WaitForLongPress
    jsr EnterNameByJoy
    jmp CheckKeys
ShortJoyPress
    ; storing name of the player and its level

    ; level of the computer opponent goes to
    ; the table of levels (difficulties)
    ldx tanknr
    lda DifficultyLevel
    sta skilltable,x
	beq NotRobot
	lda #$03	; shape for robotanks
	sta TankShape,x
NotRobot
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
;--------------------------------------------------
.proc CursorDisplay
	ldy #7
CursorLoop
	lda NameAdr,y
	and #$7f
	cpy #0
	bne NotFirstLetter
	and #$3f ; First letter should be Capital letter
    ; (nice trick does not affect digits)
NotFirstLetter
	cpy PositionInName
	bne @+
    ora #$80 ; place cursor
@	sta NameAdr,y
	dey
	bpl CursorLoop
	rts
.endp
;--------------------------------------------------
.proc EnterNameByJoy
    mva #sfx_keyclick sfx_effect
	jsr CursorDisplay
	ldy PositionInName
	; now in Y we have PositionInName
	ldx #(keycodesEnd-keycodes)
SearchCharacter
	lda NameAdr,y
	and #$7f
	cmp #$20
	bcc CharOK	; digit or space
	cmp #$60
	bcs CharOK	; not capital letter
	ora #$40
CharOK
	cmp scrcodes,x
	beq CharacterFound
	dex
	bpl SearchCharacter
	inx
CharacterFound
	; now in X we have Character (index) on PositionInName
	; wait for centered joy
    mva #128-15 pressTimer ; reset (trick)
@	lda STICK0
	and #$0f
	cmp #$0f
	beq checkjoy
	bit pressTimer	; trick (no A change)
	bpl @-
checkjoy	
	lda STICK0
	and #$0f
	cmp #$0f
	bne JoyNotCentered

notpressedJoy
	;fire
	lda STRIG0
	beq checkjoy	; fire still pressed
	rts

JoyNotCentered
	; this is a place for code :)
	cmp #7
	bne NoRight
	; joy right
	cpy #7
	beq GoToMainLoop	; the last character
	iny
	bne GoToMainLoop
NoRight
	cmp #11
	bne NoLeft
	; joy left
	lda #0
	sta NameAdr,y
	dey
	bpl GoToMainLoop
	iny
	beq GoToMainLoop
NoLeft
	cmp #14
	bne NoUp
	; joy up
	cpx #(keycodesEnd-keycodes-1)
	bne @+
	ldx #$00 	; set to the first character index (loop)
	beq CharAndMainLoop
@	inx
	bne CharAndMainLoop
NoUp
	cmp #13
	bne EnterNameByJoy	; not down
	; joy down
	dex
	bpl CharAndMainLoop
	ldx #(keycodesEnd-keycodes-1) 	; set to the last character index (loop)
CharAndMainLoop
	lda scrcodes,x
	sta NameAdr,y
GoToMainLoop
	sty PositionInName
	jmp EnterNameByJoy

.endp
;--------------------------------------------------
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
	beq noleading0	; if 00000 - last 0 must stay
	cmp zero
	bne noleading0
	lda #space
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
    lda #space
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

;--------------------------------
.proc DisplayResults ;
;displays results of the round
;using 4x4 font

    
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
    RmtSong song_round_over
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

	rts
.endp
;-------------------------------------------------
.proc PutTankNameOnScreen
;-------------------------------------------------

.endp
;-------------------------------------------------
.proc DisplayStatus
;-------------------------------------------------

    ldx TankNr
    rts
.endp
;-------------------------------------------------


.endif