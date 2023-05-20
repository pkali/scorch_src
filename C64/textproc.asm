;   @com.wudsn.ide.asm.mainsourcefile=scorch.asm


    .IF *>0
    
WeaponsListDL = 0
NamesOfLevels = 0
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


    ldx #$08
@    lda Autoplay_OptionsTable,x
    sta OptionsTable,x
    dex
    bpl @-

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
; in: TankNr
; Out: TanksNames, SkillTable

; this little thing is for choosing Player's skill (if computer)
; and entering his name
; If no name entered, there should be name "1st Tank", etc.
; Default tanks names are in table TanksNamesDefault
; -----------------------------------------------------

;

EndOfNick
    ; storing name of the player and its level

    ; level of the computer opponent goes to
    ; the table of levels (difficulties)
    ldx tanknr
    lda #6    ; Spoiler
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


    ; check if all chars are empty (" ")
    ldy #7
    lda #0
@     ora #0 ; NameAdr,y 
      and #$7F  ; remove inverse (Cursor)
      dey
    bpl @-
    tay
    beq MakeDefaultName

    ldy #0
nextchar04
    lda #0 ; NameAdr,y
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
DisplayAngle
    ldx TankNr
    rts
.endp
;-------------------------------------------------


.endif