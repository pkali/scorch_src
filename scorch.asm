;	@com.wudsn.ide.asm.mainsourcefile=scorch.asm
;Atari 8-bit Scorched Earth source code
;---------------------------------------------------
;by Tomasz 'pecus' Pecko and Pawel 'pirx' Kalinowski
;Warsaw 2000,2001,2002,2003,2009,2012,2013
;Miami 2022
;you can contact us at pecus@poczta.fm or pirx@5oft.pl
;home page of this project is https://github.com/pkali/scorch_src

;this source code was compiled under OMC65 crossassembler 
;(https://github.com/pkali/omc65)
;and on 2012-06-21 translated to mads
;
;game source code is split into 5+2 parts:
;scorch.asm is the main game code (with many assorted routines)
;grafproc.asm - graphics routines like line or circle
;textproc.asm - text routines like list of weapons and shop
;variables.asm - all non-zero page variables and constans
;display.asm - display lists and text screen definitions
;ai.asm - artificial stupidity of computer opponents
;weapons.asm - general arsenal of tankies

;we were trying to use as much macros and pseudoops as possible
;they are defined in atari.hea and macro.hea files together with many
;atari constans. This way it shoud be relatively easy to
;port this code to e.g. C64
;
;After those N years of working on this piece of code
;we are sure it would be much wiser to write it in C, Action!
;or MadPascal but on the other hand it is so much fun to type 150 chars
;where you want to have y=ax+b :)
;
;originally most variables were in Polish, comments were sparse
;but we wanted to release this piece of code to public
;and due to being always short of time/energy (to finish the game)
;we decided it must go in 'English' to let other people work on it

    .zpvar xdraw .word = $80 ;variable X for plot
    .zpvar ydraw   .word ;variable Y for plot (like in Atari Basic - Y=0 in upper right corner of the screen)
    .zpvar xbyte   .word

    .zpvar ybyte   .word
    .zpvar CharCode .byte
    .zpvar fontind .word
    .zpvar tanknr  .byte
    .zpvar TankSequencePointer .byte
    .zpvar oldplot .word
    .zpvar xc .word
    .zpvar temp .word ;temporary word for the most embeded loops only
    .zpvar temp2  .word ;same as above
    .zpvar tempXROLLER .word ;same as above for XROLLER routine
    ;(used also in result display routine)
    .zpvar xtempDRAW .word ;same as above for XDRAW routine
    .zpvar ytempDRAW .word ;same as above for XDRAW routine
    ;--------------temps used in circle routine
    .zpvar xi .word ;X (word) in draw routine
    .zpvar fx .byte ;circle drawing variables
    .zpvar yi .word ;Y (word) in draw routine
    .zpvar fy .byte
    .zpvar xk .word
    .zpvar fs .byte
    .zpvar yc .byte ;ycircle - temporary for circle
    .zpvar dx .word
    .zpvar tempor2 .byte
    .zpvar dy .word
    .zpvar tempor3 .word
    .zpvar dd .word
    .zpvar di .word
    .zpvar dp .word
    .zpvar modify .word
    .zpvar weaponPointer .word

displayposition = modify
;-------------------------------
;constants
screenheight = 200
screenBytes = 40
screenwidth = screenBytes*8 ; Max screenwidth = 512!!!
margin = 48 ;mountain drawing Y variable margin
display = $1010 ;screen takes $2K due to clearing routine
MaxPlayers = 6
maxOptions = 6  ;number of all options
PMOffset = $23 ; P/M to graphics offset

    icl 'lib/atari.hea'
    icl 'lib/macro.hea'

	icl 'artwork/HIMARS14.asm'
    ;Game loading address
    ORG  $3010 ;must be $2K after screen, because screen cleaning erases $2K
;-----------------------------------------------
;Screen displays go first to avoid crossing 4kb barrier
;-----------------------------------------------
    icl 'display.asm'
;--------------------------------------------------
; Game Code
;--------------------------------------------------
START

    ; Startup sequence
    jsr Initialize

    mwa #OptionsDL dlptrs
    lda dmactls
    and #$fc
    ora #$02     ; normal screen width
    sta dmactls

    jsr Options  ;startup screen

    ;entering names of players
    mwa #NameDL dlptrs
    lda dmactls
    and #$fc
    ora #$01     ; narrow screen (32 chars)
    sta dmactls

    mva #0 TankNr

@     jsr EnterPlayerName
      inc TankNr
      lda TankNr
      cmp NumberOfPlayers
    bne @-

    mwa #dl dlptrs
    lda dmactls
    and #$fc
    ora #$02     ; normal screen width
    sta dmactls

    jsr RandomizeSequence
    ; for the round #1 shooting sequence is random

MainGameLoop
	
    VDLI DLIinterrupt  ; jsr SetDLI

	jsr CallPurchaseForEveryTank
	
    mwa #dl dlptrs
    lda dmactls
    and #$fc
    ora #$02     ; 2=normal, 3 = wide screen width
    sta dmactls

    jsr GetRandomWind

    jsr Round
    
    jsr SortSequence
    
    ; Hide all (easier than hide last ;) ) tanks
    mva #1 Erase
    jsr drawtanks
    mva #0 Erase
    jsr PMoutofScreen ;let P/M disappear

    ; here gains and losses should be displayed (dollars)
    ; finally we have changed our minds and money of players
    ; is displayed only in weapons shop

    ; Results are number of other deaths
    ; before the player dies itself

    ; add gains and substract losses
    ; gain is what player gets for lost energy of opponents
    ; energy lost by opponents is added during Round and
    ; little below in source, multiplied by 2 to get "dollars".
    ; By analogy, loss is energy that given player losses during
    ; each Round.
    ; Important! If player has 10 energy and gets a central hit
    ; from nuke that would take 90 energy points, his loss
    ; is 90, not 10
    jsr DisplayResults

    ;check demo mode
    ldx numberOfPlayers
    dex
checkForHuman ; if all in skillTable other than 0 then switch to DEMO MODE
    lda skillTable,x
    beq peopleAreHere
    dex
    bpl checkForHuman
    ; no people, just wait a bit
    pause 150
    jmp noKey

peopleAreHere
    jsr getkey
noKey
    ldx NumberOfPlayers
    dex
CalculateGains
    ; add gain * 2
    asl gainL,x
    rol gainH,x
    clc
    lda moneyL,x
    adc gainL,x
    sta moneyL,x
    lda moneyH,x
    adc gainH,x
    sta moneyH,x
    ; substract loose
    ; if loose is greater than money then zero money
    lda moneyH,x
    cmp looseH,x
    bcc zeromoney
    bne substractloose
    lda moneyL,x
    cmp looseL,x
    bcc zeromoney
substractloose
    sec
    lda moneyL,x
    sbc looseL,x
    sta moneyL,x
    lda moneyH,x
    sbc looseH,x
    sta moneyH,x
    jmp skipzeroing
zeromoney
    lda #0
    sta moneyL,x
    sta moneyH,x

skipzeroing
    dex
    bpl CalculateGains

    lda GameIsOver
    jne START


    inc CurrentRoundNr
    jmp MainGameLoop
 

;--------------------------------------------------
Round .proc ; 
;--------------------------------------------------
; at the beginning of each Round we set energy
; of all players to 100
; the maximum shooting energy to 1000 (it is 10*energy)
; the default shooting energy to 350
; the default shooting angle to 45 degrees
; of course gains an looses are zeroed

	jsr DisplayingSymbols
	lda #0
	tax
@
	sta previousAngle,x
	inx
	cpx #(singleRoundVarsEnd-PreviousAngle)
	bne @-

    ldx #5
SettingEnergies
    lda #$00
    sta gainL,x
    sta gainH,x
    sta looseL,x
    sta looseH,x
    lda #99
    sta Energy,x
    sta eXistenZ,x
    sta LASTeXistenZ,x
    ; anything in eXistenZ table means that this tank exist
    ; in the given round
    lda #232
    sta MaxEnergyTableL,x
    lda #3
    sta MaxEnergyTableH,x
    lda #94
    sta EnergyTableL,x
    lda #1
    sta EnergyTableH,x
    ;lda #(255-45)
    ;it does not look good when all tanks have
    ;barrels pointing the same direction
    ;so it would be nice to have more or less random
    ;angles

    jsr RandomizeAngle
    sta AngleTable,x


    dex
    bpl SettingEnergies

    mva #0 CurrentResult

;generating the new landscape
    jsr PMoutofScreen ;let P/M disappear
    jsr clearscreen   ;let the screen be clean
    jsr placetanks    ;let the tanks be evenly placed
    jsr calculatemountains ;let mountains be nice for the eye
    jsr drawmountains ;draw them
    jsr drawtanks     ;finally draw tanks

.endp  ; not really end of the procedure, but just for now. TODO: revisit.

;--------------------round screen is ready---------

    mva #0 TankSequencePointer

MainRoundLoop
    ; here we must check if by a chance there is only one
    ; tank with energy greater than 0 left

    ldy #0  ; number of tanks with energy greater than zero
    ldx NumberOfPlayers
    dex
CheckingIfRoundIsFinished
    lda eXistenZ,x
    beq NoEnergy
    iny
NoEnergy
    dex
    bpl CheckingIfRoundIsFinished

    cpy #2 ; is it less than 2 tanks have energy >0 ?
    bcs DoNotFinishTheRound

;points for the last living tank
    ldx NumberOfPlayers
    dex
WhichTankWonLoop
    lda eXistenZ,x
    bne ThisOneWon
    dex
    bpl WhichTankWonLoop
    ;error here!!!
    ;stop
    ; somehow I believed program will be never here
    ; but it was a bad assumption
    ; god knows when there is such a situation
    ; (we've got a SITUATION here, it you know what I mean)
    ; there are two tanks left.
    ; one of them is killed by the second tank
    ; second tank explodes and kills the first one.
    ; and code lands here...
    ; looks like no one won!

    rts

ThisOneWon
    lda CurrentResult
    clc
    adc ResultsTable,x
    sta ResultsTable,x

    rts  ; this Round is finished

DoNotFinishTheRound
    ;ldx TankNr

    ldx TankSequencePointer
    lda TankSequence,x
    sta TankNr
    tax
    lda Energy,x ;skip if no energy
    jeq NextPlayerShoots


    mva #1 color ;to display flying point

    lda TankColoursTable,x
    sta colpf2s  ; set color of status line

    lda SkillTable,x
    beq ManualShooting

	; robotanks shoot here
    jsr ArtificialIntelligence
    jsr MoveBarrelToNewPosition
    jsr DisplayingSymbols ;all digital values like force, angle, wind, etc.
    jsr PutTankNameOnScreen
    ; let's move the tank's barrel so it points the right
    ; direction
    jmp AfterManualShooting

ManualShooting

    jsr WaitForKeyRelease
    jsr BeforeFire

AfterManualShooting
    jsr DecreaseWeaponBeforeShoot
    jsr DisplayingSymbols

	ldx TankNr
	dec Energy,x   ; lower energy to eventually let tanks commit suicide
    lda ActiveWeapon,x

    jsr Shoot
    
    lda HitFlag ;0 if missed
    beq missed
    lda #0
    sta FallDown1
    sta FallDown2
    jsr Explosion

    ;here we clear offensive text (after a shoot)
    ldy TankNr
    mva #0 plot4x4color
    jsr DisplayOffensiveTextNr


AfterExplode
    ldy WeaponDepleted
    bne @+
      ldx TankNr
      tya
      sta ActiveWeapon,x 
@

    ;temporary tanks removal (would fall down with soil)
    mva TankNr tempor2
    mva #1 Erase
    jsr drawtanks
    mva tempor2 TankNr
    mva #0 Erase
    lda FallDown2
    beq NoFallDown2
    jsr SoilDown2;

NoFallDown2
    ;here tanks are falling down
    mva tankNr tempor2
    mva #0 TankNr

TanksFallDown
    jsr TankFalls
    inc:lda TankNr
    cmp NumberOfPlayers
    bne TanksFallDown
    mva tempor2 TankNr
missed

    ;here we clear offensive text (after a shoot)
    ;shit -- it's second time, but it must be like this
    ldy TankNr
    mva #0 plot4x4color
    jsr DisplayOffensiveTextNr

NextPlayerShoots
    mva #1 Erase
    jsr drawtanks

    ;before it shoots, the eXistenZ table must be
    ;updated accordingly to actual energy (was forgotten, sorry to ourselves)

    ldx #5
SeteXistenZ
    lda Energy,x
    sta eXistenZ,x
    sta L1

    ;DATA L1,L2
    ;RESULT WH*256+L1
    ;Multiplication 8bit*8bit,
    ;result 16bit
    ;this algiorithm is a little longer than in Ruszczyc 6502 book
    ;but it is faster

    LDy #8
    LDA #0
    CLC
LP0
    ror
    ROR L1
    BCC B0
    CLC
    ADC #10 ; multiplication by 10
B0  DEY
    BNE LP0
    ror
    ROR L1
    STA MaxEnergyTableH,x
    lda L1
    sta MaxEnergyTableL,x

    dex
    bpl SeteXistenZ

    ;was setup of maximum energy for players

    mva #0 Erase
    jsr drawtanks

    ;inc TankNr
    ;lda TankNr
    inc:lda TankSequencePointer
    cmp NumberOfPlayers
    bne PlayersAgain
    ;mva 0 TankNr
    mva #0 TankSequencePointer

PlayersAgain .proc

; In LASTeXistenZ there are values of eXistenZ before shoot
; from the next tank.
; Now it must be checked if by a chance something that had
; LASTeXistenZ>0 is not equal to 0 right now,
; because it means this tank died during this round.
; Most important thing is:
; after each explosion of the tank these operations must be
; performed from the beginning!
; (it is made by another jump into the after explosion routines)
; It is because exploding tank can destroy their neighbours,
; additionally this tank just have had LASTeXistenZ set to 0,
; otherwise it would explode again and again.
; OK, text how to do it is ready, now comes coding .
; Aaaah! - in the main loop we have to set eXistenZ and LASTeXistenZ

    ldx NumberOfPlayers
    dex
CheckingPlayersDeath
    lda LASTeXistenZ,x
    beq NoPlayerNoDeath
    lda eXistenZ,x
    beq PlayerXdeath
NoPlayerNoDeath
    dex
    bpl CheckingPlayersDeath
    ; if processor is here it means there are no more explosions
    jmp MainRoundLoop
	.endp
;---------------------------------
PlayerXdeath .proc
    ; first we inform that this tank should not explode anymore:
    ; there is 0 in A, and Tank Number in X, so...

    sta LASTeXistenZ,x
    ; save x somewhere
    stx TankTempY

    ; display defensive text here (well, defensive
    ; is not the real meaning, it should be pre-death,
    ; but I am too lazy to change names of variables)

    ; in X there is a number of tank that died

    lda CurrentResult
    clc
    adc ResultsTable,x
    sta ResultsTable,x
    inc CurrentResult
    .endp

;RandomizeDeffensiveText
    randomize talk.NumberOfOffensiveTexts (talk.NumberOfDeffensiveTexts+talk.NumberOfOffensiveTexts-1) 
    sta TextNumberOff
    ldy TankTempY
    mva #1 plot4x4color
    jsr DisplayOffensiveTextNr

    PAUSE 75
    ;Deffensive text cleanup
    ;here we clear Deffensive text (after a shoot)
    ldy TankTempY
    mva #0 plot4x4color
    jsr DisplayOffensiveTextNr


    ; calculate position of the explosion (the post-death one?)
    ldx TankTempY
    clc
    lda xtankstableL,x
    adc #4 ; more or less in the middle of the tank
    sta xdraw
    lda xtankstableH,x
    adc #0
    sta xdraw+1
    sec
    lda ytankstable,x
    sbc #4
    sta ydraw
    lda #0
    sta ydraw+1   ; there is 0 left in A, so...

    ;cleanup of the soil fall down ranges (left and right)
    sta RangeRight
    sta RangeRight+1
    sta FallDown1
    sta FallDown2
    mwa #screenwidth RangeLeft



    ; We are randomizing the weapon now.
    ; As we are jumping into the middle of the weapon
    ; routine we are preparing the number *2 -
    ; - to make it easier and because we are using only
    ; first 32 weapons we are doing this with just one AND

    lda random
    and #$3e  ;  range (0-31 number multiplied by 2)
    jsr Explosion2

    ; jump to after explosion routines (soil fallout, etc.)
    ; After going through these routines we are back
    ; to checking if a tank exploded and maybe we have
    ; a deadly shot here again.


    jmp AfterExplode

;--------------------------------------------------
DecreaseEnergyX .proc
;Decreases energy of player nr X
;increases his financial loss
;increases gain of tank TankNr
;--------------------------------------------------
    sty EnergyDecrease
    ; Loose increase
    lda looseL,x
    clc
    adc EnergyDecrease
    sta looseL,x
    lda looseH,x
    adc #$00
    sta looseH,x
    ; Energy now, not less than 0
    lda Energy,x
    cmp EnergyDecrease
    bcc ldahashzero
    ;sec
    sbc EnergyDecrease
    bpl NotNegativeEnergy
ldahashzero
    lda #0
NotNegativeEnergy
    sta Energy,x
    ;now increase the gain of the shooting tank
    phx
    ldx TankNr
    clc
    lda gainL,x
    adc EnergyDecrease
    sta gainL,x
    lda gainH,x
    adc #$00
    sta gainH,x
    plx
    rts
.endp

;--------------------------------------------------
GetRandomWind .proc
;--------------------------------------------------
    lda random
    cmp MaxWind
    bcs GetRandomWind ; if more than MaxWind then randomize again
    sta Wind
    mva #$00 Wind+1
    ; multiply Wind by 16 and take it as a decimal part (0.Wind)
    aslw Wind
    aslw Wind
    aslw Wind
    aslw Wind
    lda random
    and #$01
    sta WindOrientation
    rts
.endp

;--------------------------------------------------
PMoutofScreen .proc
;--------------------------------------------------
    lda #$00 ; let all P/M disappear
    sta hposp0
    sta hposp0+1
    sta hposp0+2
    sta hposp0+3
    sta hposp0+4
    sta hposp0+5
    sta hposp0+6
    sta hposp0+7
    rts
.endp

;--------------------------------------------------
.proc WeaponCleanup;
; cleaning of the weapon possesion tables
; (99 of Baby Missles, all other weapons=0)
;--------------------------------------------------
    ldx #$3f
    lda #$0
loop05
    sta TanksWeapon1,x
    sta TanksWeapon2,x
    sta TanksWeapon3,x
    sta TanksWeapon4,x
    sta TanksWeapon5,x
    sta TanksWeapon6,x
    dex
    bne @+
      lda #99
      bne loop05
@ bpl loop05
    rts
.endp

;--------------------------------------------------
Initialize .proc
;Initialization sequence
;--------------------------------------------------
deletePtr = temp

    lda #0 
    sta Erase
    sta tracerflag
    sta GameIsOver


    ; clean variables
    tay
    mwa #variablesStart deletePtr
@     tya
      sta (deletePtr),y
      inw deletePtr
      cpw deletePtr #variablesEnd
    bne @-
    
    mwa #1024 RandBoundaryHigh
    mva #$ff LastWeapon
    sta HowMuchToFall
    mva #1 color
    
    jsr WeaponCleanup    
    
    
    mva #$2 colpf2s
    mva #12 colpf3s
    mva #>WeaponFont chbas

    ;parameter for old plot (unPlot) max 5 points
    ldx #4
SetunPlots
    lda #<display
    sta oldplotL,x
    lda #>display
    sta oldplotH,x
    lda #0
    sta oldply,x
    sta oldora,x
    dex
    bpl SetunPlots

    ;setting up P/M graphics
    lda #>pmgraph
    sta pmbase
    lda dmactls
    ora #$38     ; Players and Missiles single lined
    sta dmactls
    lda #$03    ; P/M on
    sta pmcntl
    lda #$01
    sta sizem ; there will be only M0, double width
    sta sizep0 ; P0-P3 widths
    sta sizep0+1
    sta sizep0+2
    sta sizep0+3
    lda #$10 ; P/M priorities (bit 4 joins missiles)
    sta gtictls
    jsr PMoutofScreen
    lda #$50 ; temporary colours of sprites under tanks
    sta $2c0
    lda #$30
    sta $2c1
    lda #$70
    sta $2c2
    lda #$90
    sta $2c3
    LDA #$B0
    STA COLPF3S
    mva #0 hscrol


    ;let the tanks be visible!
    ldx #5
    lda #1 ; tank is visible
MakeTanksVisible
    sta eXistenZ,x
    dex
    bpl MakeTanksVisible


    ldx #0
    txa
ClearResults
    sta ResultsTable,x
    inx
    cpx #MaxPlayers
    bne ClearResults

    mva #1 CurrentRoundNr ;we start from round 1

    rts
.endp
    
DLIinterrupt .proc
    pha
    lda #$02 ; color of playground
    sta WSYNC
    sta COLPF2
    pla
    rti
.endp
;----------------------------------------------
RandomizeSequence .proc
; in: NumberOfPlayers
; out: TankSequence
; how: get random number lower than NumberOfPlayers
;      put it in the first slot.
;      get another random number lower than NumberOfPlayers
;      check if was previously saved in first slot
;      if not then save it in second slot
;      repeat untill NumberOfPlayers

    ldx #0
GetRandomAgain0
    lda RANDOM
    and #$07 ;NumberOfPlayers < 7
    cmp NumberOfPlayers
    bcs GetRandomAgain0
    sta TankSequence,x
    ;now first slot is ready, nexts slots are handled
    ;in a more complicated way

GetRandomAgainX
    lda RANDOM
    and #$07 ;NumberOfPlayers < 7
    cmp NumberOfPlayers
    bcs GetRandomAgainX

    ;now we have to check if the value was not used
    ;in previous slots

    stx temp
    ldy temp
UsageLoop
      cmp TankSequence,y
      beq GetRandomAgainX ;apparently we have already used this value
      dey
    bpl UsageLoop

    ;well, looks like this value is new!
    inx
    sta TankSequence,x

    stx temp
    inc:lda temp ;x+1

    cmp NumberOfPlayers
    bne GetRandomAgainX
    rts
.endp
;----------------------------------------------
RandomizeAngle .proc ;
; routine returns in A
; a valid angle for the tank's barrel.
; X is not changed
;----------------------------------------------

    ;valid angle values are ((256-90)..255) and (0..90)
    ;it means that values 91..165 must be elliminated...
    ;so, lets randomize someting between 0 and 180
    ;and substract this value from 90
    lda RANDOM

    cmp #180
    bcs RandomizeAngle


    sta temp
    lda #90 ; CARRY=0 here
    sbc temp

    rts
.endp
;----------------------------------------------
RandomizeForce  .proc
; routine returns in EnergyTable/L/H
; valid force of shooting for TankNr
; in X must be TankNr
; low and high randomize boundary passed as word value
; RandBoundaryLow
; RandBoundaryHigh
;----------------------------------------------

    lda MaxEnergyTableL,x
    sta temp
    lda MaxEnergyTableH,x
    sta temp+1
GetRandomAgain
    lda RANDOM
    ; gets values in range(256,765)
    sta temp2
    lda RANDOM   ; :)
    and #%00000011 ;(0..1023)
    sta temp2+1
	
    cpw RandBoundaryLow temp2
    bcs GetRandomAgain

    cpw RandBoundaryHigh temp2
    bcc GetRandomAgain

    cpw temp temp2
    bcs EnergyInRange
   
    mwa temp temp2 
    
EnergyInRange
    lda temp2
    sta EnergyTableL,x
    lda temp2+1
    sta EnergyTableH,x

    rts
.endp

;----------------------------------------------
MoveBarrelToNewPosition .proc
	jsr DrawTankNr
	ldx TankNr
	lda AngleTable,x
	clc
	adc #90 ;shift angle to the positive values
	sta temp
	lda NewAngle
	clc 
	adc #90
	cmp temp
	beq BarrelPositionIsFine
	bcc rotateLeft ; older is bigger
rotateRight;older is lower
	inc angleTable,x
	bne MoveBarrelToNewPosition

    mva #$30 CharCode ; if angle goes through 0 we clear the barrel
    jsr drawtankNrX
	
	jmp MoveBarrelToNewPosition
rotateLeft
	dec angleTable,x
	bpl MoveBarrelToNewPosition
    	mva #$2e CharCode
   	jsr drawtankNrX	

	jmp MoveBarrelToNewPosition
	
BarrelPositionIsFine
	rts
	
	.endp

;----------------------------------------------
SortSequence .proc ;
;----------------------------------------------
; here we try to get a sequence of tanks for two
; purposes:
; 1. to make up shooting sequence for the next round (from down to top)
; 2. to display game results more nicely (from top to down)
;
; I think I will go for a stupid bubble sort...
; it is easy to test :)
;
; Results are in ResultsTable, in SortedTable we want to
; have numbers of tanks from the worst to the best.
; in other words, if ResultsTable=(5,4,65,23,3,6)
; the SortedTable=(4,1,0,5,3,2)
; let's assume initially the TankSequence=(0,1,2,3,4,5)

    ldx #0
SequenceStart
    txa
    sta TankSequence,x
    inx
    cpx #MaxPlayers
    bne SequenceStart

; we will need a TempResults (TR) table to fiddle with
    ldx #0
movetotemp
    lda ResultsTable,x
    sta TempResults,x
    inx
    cpx NumberOfPlayers
    bne movetotemp

; i=0:sortflag=0
;loop:
; if TR(i) < TX(i+1) then i=i+1: here quit if i=numberofplayers
;        or goto loop:
;  else
;    temp=TR(i):  tempo=TankSequence(i)
;    TR(i)=TR(i+1): TankSequence(i)=TankSequence(i+1)
;    TR(i+1)=temp: TankSequence(i+1)=tempo
;    i=i+1
;    sortflag=sortflag+1
;   go loop:
; if sortflag=0 then finished, else repeat...
;
; or something like this :)
    ldx NumberOfPlayers
    dex
    stx temp+1 ; for checking end of the loop only

Bubble
    ldx #0 ;i=x
    stx temp2 ; sortflag=temp2

BubbleBobble
    lda TempResults,x
    cmp TempResults+1,x
    beq nextishigher ; this is to block hangs when 2 same values meet
    bcc nextishigher
    ;here we must swap values
    ;because next is smaller than previous
    sta temp
    lda TempResults+1,x
    sta TempResults,x
    lda temp
    sta TempResults+1,x
    ;
    lda TankSequence,x
    sta temp
    lda TankSequence+1,x
    sta TankSequence,x
    lda temp
    sta TankSequence+1,x
    inc temp2
nextishigher
    inx
    cpx temp+1 ;cpx ^NumberOfPlayers-1
    bne BubbleBobble

    lda temp2

    bne Bubble

    rts
.endp

;--------------------------------------------------
getkey .proc; waits for pressing a key and returns pressed value in A
;--------------------------------------------------
    jsr WaitForKeyRelease
@
      lda SKSTAT
      cmp #$ff
      beq checkJoyGetKey ; key not pressed, check Joy
  
      lda kbcode
      and #$3f ;CTRL and SHIFT ellimination
    rts
checkJoyGetKey
      ;------------JOY-------------
      ;happy happy joy joy
      ;check for joystick now
      lda JSTICK0
      and #$0f
      cmp #$0f
      beq notpressedJoyGetKey
      tay 
      lda joyToKeyTable,y
    rts
notpressedJoyGetKey
      ;fire
      lda TRIG0
    bne @-
    lda #$0c ;Return key
    rts
.endp
;--------------------------------------------------
getkeynowait .proc;
;--------------------------------------------------
    jsr WaitForKeyRelease 
    lda kbcode
    and #$3f ;CTRL and SHIFT ellimination
    rts
.endp
;--------------------------------------------------
WaitForKeyRelease .proc
;--------------------------------------------------
    lda JSTICK0
    and #$0f
    cmp #$0f
    bne WaitForKeyRelease
    lda TRIG0
    beq WaitForKeyRelease
    lda SKSTAT
    cmp #$ff
    bne WaitForKeyRelease
    rts
.endp

;----------------------------------------------
OffensiveTexts
    icl 'artwork/talk.asm'
;----------------------------------------------
    icl 'weapons.asm'
;----------------------------------------------
    icl 'textproc.asm'
;----------------------------------------------
    icl 'grafproc.asm'
;----------------------------------------------
    icl 'ai.asm'
;----------------------------------------------
    icl 'constants.asm'
;----------------------------------------------
    icl 'variables.asm'
    

font4x4
    ins 'artwork/font4x4s.bmp',+62
;----------------------------------------------
TankFont
    ins 'artwork/tanks.fnt'
TankFontend
    .if TankFontEnd>$9800
        .error memory conflict
        ;this is to warn if code and P/M graphics
        ;overlap!
    .endif
;----------------------------------------------
; Player/missile memory
    ORG $9800
pmgraph

;----------------------------------------------
    ORG $a400
WeaponFont
    ins 'artwork/weapons.fnt'
;----------------------------------------------
TheEnd
    .if TheEnd>$c000
        .error memory conflict

    .endif


    run START
