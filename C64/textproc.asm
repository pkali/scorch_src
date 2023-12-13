;   @com.wudsn.ide.asm.mainsourcefile=scorch.asm


    .IF *>0

WeaponsListDL = 0

NamesOfLevels
 dta  d" HUMAN     Moron     Shooter   "
 dta d"  Poolshark Tosser    Chooser   "
 dta d"  Spoiler   Cyborg    Unknown   "

;----------------------------------------
; this module contains routines used in text mode
; like shop and start-up options
;----------------------------------------

;--------------------------------------------------
.proc Options
;--------------------------------------------------
; start-up screen - options, etc.
; this function returns:
; - 9 values in 'OptionTable' denoting options selected in menu.
; According to contents of this table, corresponding variables are then set.
; Setting of these variables is handled by procedure 'SetVariablesFromOptions'.
; This function also returns additional options by setting variables:
; - 'RandomMountains' -  mountains type change after each (0 - round only, >0 - each turn)
; - 'WindChangeInRound' - wind change after each turn (0 - round only, >0 - each turn)
; - 'GradientNr'
; - 'BlackHole' -  0 - standard, >0 - fast
; - 'FastSoilDown' - 0 - no, >0 - yes
; -----------------------------------------------------

    ldx #$08
@    lda Autoplay_OptionsTable,x
    sta OptionsTable,x
    dex
    bpl @-

    lda  #$1f    ; '?' character
    sta RandomMountains

    rts

Autoplay_OptionsTable .by 4,4,2,2,4,1,3,2,4

.endp

.proc SelectNextGradient
    lda OptionsY    ; if "Wind" option selected
    cmp #$03
    bne NotWind
    lda WindChangeInRound    ; wind change after each turn (not round only) flag
    eor #$1f    ; '?' character
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

;-------------------------------------------
; call of the purchase (and activate) screens for each tank
.proc CallPurchaseForEveryTank

    mva #0 TankNr
    sta isInventory
@
    ldx TankNr
    lda SkillTable,x
    beq ManualPurchase
    jsr PurchaseAI    ; remember to make ActivateAI :) !!!
    jmp AfterManualPurchase
ManualPurchase
    lda JoyNumber,x
    sta JoystickNumber    ; set joystick port for player
    mva #0 isInventory
    jsr Purchase    ; purchase weapons
    bit escFlag
    spl:rts
    jsr DefensivesActivate    ; activate weapons
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
.proc Purchase ;
;--------------------------------------------------
; In tanknr there is a number of the tank (player)
; that is buying weapons now (from 0).
; Rest of the data is taken from appropriate tables
; and during the purchase these tables are modified.


; we are clearing list of the weapons
    mva #$00 WhichList
    ; offensive weapon - 0, deffensive - %10000000
GoToActivation
    rts

.endp

; -----------------------------------------------------
.proc EnterPlayerNames
    ;entering names of players

    mva #0 TankNr
    sta COLBAKS    ; set color of background
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
; this little thing is for choosing Player's skill (if computer)
; and entering his name
; If no name entered, there should be default.
; Default tank names are taken from difficulty level names on the screen.
;
; in: TankNr
; this function returns:
; - 'skilltable' (in array) for this tank
; - 'TankShape' (in array) for this tank
; - 'TanksNames' (in array) for this tank
; -----------------------------------------------------

EndOfNick
    ; storing name of the player and its level

    ; level of the computer opponent goes to
    ; the table of levels (difficulties)
    ldx tanknr
    txa
    clc
    adc #2
;    lda #6    ; Spoiler
    sta DifficultyLevel
    sta skilltable,x
    beq NotRobot
    lda #$03    ; shape for robotanks
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

    ldy #0
    stx temp+1  ; remember start position in tanksnames
    sty temp    ; 0 if name is empty
@
      lda #0 ; NameAdr,y
      and #$7f ; remove inverse (Cursor)
      sta tanksnames,x
      ora temp
      sta temp
      inx
      iny
      cpy #$08
    bne @-
    lda temp    ; check if all chars are empty (" ")
    beq MakeDefaultName    
    rts
MakeDefaultName
    ldy difficultyLevel
    lda LevelNameBeginL,y ; address on the screen
    sta temp2
    lda LevelNameBeginH,y
    sta temp2+1
    ldx temp+1
    ldy #1  ; after first char (space)
@   lda (temp2),y
    and #$7f    ; remove inverse
    sta tanksnames,x
    beq MakeNumber  ; first space found :)
    inx
    iny
    cpy #8
    bne @-
MakeNumber
    ldy tanknr
    lda digits+1,y
    sta tanksnames,x
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
    ldx #0    ; digit flag (cut leading zeroes)
displayloop
    lda decimalresult,y
    cpx #0
    bne noleading0
    cpy #4
    beq noleading0    ; if 00000 - last 0 must stay
    cmp zero
    bne noleading0
    lda #space
    beq displaychar    ; space = 0 !
noleading0
    inx        ; set flag (no leading zeroes to cut)
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

    sta decimal
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
;-------------------------------------------------
.proc RoundOverSprites
    ; fill sprites with bytes
    rts
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
DisplayEnergy
DisplayAngle
    ldx TankNr
    rts
.endp
;-------------------------------------------------
.proc _calc_inverse_display
; optymalization station. not a real function
; or is it?
@weapon_index = TextNumberOff
@inverse_counter = temp+1
    
    mwa #0 @inverse_counter
    tay  ; ldy #0
@   
    inw LineAddress4x4
    lda (LineAddress4x4),y
    spl:inc @inverse_counter
    lda @weapon_index
    beq zeroth_talk  ; special treatment of talk #0
    cmp @inverse_counter
    bne @-
    
    inw LineAddress4x4  ; we were pointing at the char with inverse, must go 1 further
zeroth_talk
    rts
.endp
;-------------------------------------------------


.endif