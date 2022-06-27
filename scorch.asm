;	@com.wudsn.ide.asm.mainsourcefile=scorch.asm
;Atari 8-bit Scorched Earth source code
;---------------------------------------------------
;by Tomasz 'pecus' Pecko and Pawel 'pirx' Kalinowski
;Warsaw 2000,2001,2002,2003,2009,2012,2013
;Miami&Warsaw 2022
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

.macro build
	dta d"145" ; number of this build (3 bytes)
.endm

    icl 'definitions.asm'
    icl 'artwork/sfx/rmt_feat.asm'
    
    
    .zpvar xdraw            .word = $80 ;variable X for plot
    .zpvar ydraw            .word ;variable Y for plot (like in Atari Basic - Y=0 in upper right corner of the screen)
    .zpvar xbyte            .word
    .zpvar ybyte            .word
    .zpvar CharCode         .byte
    .zpvar fontind          .word
    .zpvar tanknr           .byte
    .zpvar TankSequencePointer .byte
    .zpvar oldplot          .word
    .zpvar xc               .word
    .zpvar temp             .word ;temporary word for the most embeded loops only
    .zpvar temp2            .word ;same as above
    .zpvar modify           .word ;origially used to replace self-modyfying code
    .zpvar tempXROLLER      .word ;same as above for XROLLER routine (used also in result display routine)
    .zpvar xtempDRAW        .word ;same as above for XDRAW routine
    .zpvar ytempDRAW        .word ;same as above for XDRAW routine
    .zpvar tempor2          .byte
    ;--------------temps used in circle routine
    .zpvar xi               .word ;X (word) in draw routine
    .zpvar fx               .byte 
    .zpvar yi               .word ;Y (word) in draw routine
    .zpvar fy               .byte
    .zpvar xk               .word
    .zpvar fs               .byte
    .zpvar yc               .byte ;ycircle - temporary for circle
    .zpvar dx               .word
    .zpvar dy               .word
    .zpvar dd               .word
    .zpvar di               .word
    .zpvar dp               .word
    ;----------------------------
    .zpvar weaponPointer    .word
	.zpvar dliCounter       .byte
	.zpvar pressTimer       .byte
	.zpvar NTSCcounter      .byte
    ;.zpvar dliA             .byte
    ;.zpvar dliX             .byte
    ;.zpvar dliY             .byte

    ;* RMT ZeroPage addresses
    .zpvar p_tis            .word
    .zpvar p_trackslbstable .word
    .zpvar p_trackshbstable .word
    .zpvar p_song           .word
    .zpvar ns               .word
    .zpvar nr               .word
    .zpvar nt               .word
    .zpvar reg1             .byte
    .zpvar reg2             .byte
    .zpvar reg3             .byte
    .zpvar tmp              .byte
    IFT FEAT_COMMAND2
      .zpvar frqaddcmd2     .byte
    EIF
    p_instrstable = p_tis

    displayposition = modify
;-------------------------------

    icl 'lib/atari.hea'
    icl 'lib/macro.hea'

    ;splash screen and musix
	icl 'artwork/HIMARS14.asm'
    ;Game loading address
    ORG  $3000
WeaponFont
    ins 'artwork/weapons_AW5_mod.fnt'  ; 'artwork/weapons.fnt'
;-----------------------------------------------
;Screen displays go here to avoid crossing 4kb barrier
;-----------------------------------------------
    icl 'display.asm'
;----------------------------------------------
    
;--------------------------------------------------
; Game Code
;--------------------------------------------------
START

    ; Startup sequence
    jsr Initialize

    jsr Options  ;startup screen
    lda escFlag
    bne START

    jsr EnterPlayerNames
    lda escFlag
    bne START

    jsr RandomizeSequence
    ; for the round #1 shooting sequence is random
	
MainGameLoop
	jsr CallPurchaseForEveryTank

    ; issue #72 (glitches when switches)
    mva #0 dmactl

    jsr GetRandomWind

    jsr RoundInit
    
    jsr MainRoundLoop
    lda escFlag
    bne START
    
    mva #0 TankNr  ; 
    
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

    lda #song_end_round
    jsr RmtSongSelect
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
    ; add gains and substract losses
    ; gain is what player gets for lost energy of opponents
    ; energy lost by opponents is added during Round and
    ; little below in source, multiplied by 2 to get "dollars".
    ; By analogy, loss is energy that given player losses during
    ; each Round.
    ; Important! If player has 10 energy and gets a central hit
    ; from nuke that would take 90 energy points, his loss
    ; is 90, not 10

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
    mva #0 dmactl  ; issue #72
    jsr RmtSongSelect
    mva #sfx_silencer sfx_effect
    jmp MainGameLoop
 

;--------------------------------------------------
.proc RoundInit 
;--------------------------------------------------
; at the beginning of each Round we set energy
; of all players to 99
; the maximum shooting energy to 990 (it is 10*energy)
; the default shooting energy to 350
; the shooting angle is randomized
; of course gains an looses are zeroed

    lda #song_ingame
    jsr RmtSongSelect

	lda #0
	tax
@	  sta singleRoundVars,x
	  inx
	  cpx #(singleRoundVarsEnd-singleRoundVars)
	bne @-

    ldx #(MaxPlayers-1)
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
      lda #<1000
      sta MaxForceTableL,x
      lda #>1000
      sta MaxForceTableH,x
      lda #<350
      sta ForceTableL,x
      lda #>350
      sta ForceTableH,x
  
      ;lda #(255-45)
      ;it does not look good when all tanks have
      ;barrels pointing the same direction
      ;so it would be nice to have more or less random
      ;angles
      jsr RandomizeAngle
      sta AngleTable,x
  
      dex
    bpl SettingEnergies

;generating the new landscape
    jsr PMoutofScreen ;let P/M disappear
    jsr clearscreen   ;let the screen be clean
    jsr placetanks    ;let the tanks be evenly placed
    jsr calculatemountains ;let mountains be easy for the eye
    ;jsr calculatemountains0 ;only for tests - makes mountains flat and 0 height

    jsr SetMainScreen
    jsr ColorsOfSprites

    jsr drawmountains ;draw them
    jsr drawtanks     ;finally draw tanks

    mva #0 TankSequencePointer
;---------round screen is ready---------
    rts
.endp

;--------------------------------------------------
.proc MainRoundLoop
    ; here we must check if by a chance there is only one
    ; tank with energy greater than 0 left

    ldy #0  ; in Y - number of tanks with energy greater than zero
	sty ATRACT	; reset atract mode
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
    ;error was here!!!
    ; somehow I believed program will be never here
    ; but it was a bad assumption
    ; god knows when there is such a situation
    ; (we've got a SITUATION here, if you know what I mean)
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
    ; Seppuku here
    lda noDeathCounter
    cmp seppukuVal
    bcc @+
    
    mva #0 noDeathCounter
    mva #sfx_seppuku sfx_effect
    jsr DisplaySeppuku
    jmp Seppuku

@
    ldx TankSequencePointer
    lda TankSequence,x
    sta TankNr
    tax
    lda Energy,x ;skip if no energy
    jeq NextPlayerShoots


    mva #1 color ;to display flying point

    lda TankStatusColoursTable,x
    sta colpf2s  ; set color of status line

    lda SkillTable,x
    beq ManualShooting

RoboTanks
	; robotanks shoot here
    jsr ArtificialIntelligence
    jsr MoveBarrelToNewPosition
    jsr DisplayStatus ;all digital values like force, angle, wind, etc.
    jsr PutTankNameOnScreen
    lda kbcode
    cmp #28  ; ESC
    bne @+
      jsr AreYouSure
      lda escFlag
      seq:rts
@

    ; let's move the tank's barrel so it points the right
    ; direction
    jmp AfterManualShooting

ManualShooting

    jsr WaitForKeyRelease
    jsr BeforeFire
    lda escFlag
    seq:rts

AfterManualShooting
	; defensive weapons without flight handling
	ldx TankNr
	lda ActiveDefenceWeapon,x
	cmp #ind_White_Flag_____ ; White Flag
	beq ShootWhiteFlag
	cmp #ind_Nuclear_Winter_
	bne StandardShoot
ShootAtomicWinter
	; --- nuclear winter ---
	jsr NuclearWinter
	jmp NextPlayerShoots ; and we skip shoot
ShootWhiteFlag
	; --- white flag ---
	jsr WhiteFlag
	jmp NextPlayerShoots ; and we skip shoot
StandardShoot
    inc noDeathCounter

    jsr DecreaseWeaponBeforeShoot
    jsr DisplayStatus

	ldx TankNr
	dec Energy,x   ; lower energy to eventually let tanks commit suicide

ShootNow
    jsr Shoot
    ;here we clear offensive text (after a shoot)
    ldy TankNr
    mva #0 plot4x4color
    jsr DisplayOffensiveTextNr
    
    lda HitFlag ;0 if missed
    beq missed
    
    lda #0
    sta FallDown1
    sta FallDown2
    jsr Explosion

continueMainRoundLoopAfterSeppuku
    ;here we clear offensive text (after a shoot)
    ;ldy TankNr
    ;mva #0 plot4x4color
    ;jsr DisplayOffensiveTextNr


AfterExplode
    ; TODO: IS IT OK??? possibly a fix here needed for #56
    ldy WeaponDepleted
    bne @+
      ldx TankNr
      tya
      sta ActiveWeapon,x 
@

    ;temporary tanks removal (would fall down with soil)
    mva #1 Erase
    jsr drawtanks
    mva #0 Erase
    lda FallDown2
    beq NoFallDown2
    jsr SoilDown2

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
    ;before it shoots, the eXistenZ table must be updated
    ;accordingly to actual energy (was forgotten, sorry to ourselves)

    ldx #(MaxPlayers-1)
SeteXistenZ
    lda Energy,x
    sta eXistenZ,x
    sta L1

    ;DATA L1,L2
    ;Multiplication 8bit*8bit,
    ;result 16bit
    ;this algiorithm is a little longer than one in Ruszczyc 6502 book
    ;but it is faster

    LDy #8
    LDA #0
    CLC
LP0
    ror
    ROR L1
    BCC B0
    CLC
    ADC #10 ; (L2) multiplication by 10
B0  DEY
    BNE LP0
    ror
    ROR L1
    STA MaxForceTableH,x
    lda L1
    sta MaxForceTableL,x

    dex
    bpl SeteXistenZ

    ;was setup of maximum energy for players


PlayersAgain

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

    mva #sfx_next_player sfx_effect
    
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

    inc:lda TankSequencePointer
    cmp NumberOfPlayers
    sne:mva #0 TankSequencePointer

    jmp MainRoundLoop
.endp
	
;---------------------------------
.proc PlayerXdeath

    ; this tank should not explode anymore:
    ; there is 0 in A, and Tank Number in X, so...
    sta LASTeXistenZ,x
    ; save x somewhere
    stx TankTempY

    ;clear NoDeathCounter here
    sta noDeathCounter


    ; display defensive text here (well, defensive
    ; is not the real meaning, it should be pre-death,
    ; but I am too lazy to change names of variables)

    ; in X there is a number of tank that died

    lda CurrentResult
    clc
    adc ResultsTable,x
    sta ResultsTable,x
    inc CurrentResult

    mva #sfx_death_begin sfx_effect
;RandomizeDeffensiveText
    randomize talk.NumberOfOffensiveTexts (talk.NumberOfDeffensiveTexts+talk.NumberOfOffensiveTexts-1) 
    sta TextNumberOff
    ldy TankTempY
    mva #1 plot4x4color
    jsr DisplayOffensiveTextNr
	; tank flash
    ldy TankTempY
	mva TankNr temp2 ; not elegant, and probably unnecessary
	sty TankNr
	jsr FlashTank ; blinking and pausing (like PAUSE 72 - 18x(2+2) )
	mva temp2 TankNr 

    ;Deffensive text cleanup
    ;here we clear Deffensive text (after a shoot)
    ldy TankTempY
    mva #0 plot4x4color
    jsr DisplayOffensiveTextNr

    ; calculate position of the explosion (the post-death one)
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
    sta ydraw+1   ; there is 0 left in A, so... TODO: bad code above. revisit

    ;cleanup of the soil fall down ranges (left and right)
    sta RangeRight
    sta RangeRight+1
    sta FallDown1
    sta FallDown2
    mwa #screenwidth RangeLeft

    ; We are randomizing the weapon now.
    ; jumping into the middle of the explosion
    ; routine
MetodOfDeath
    lda random
    and #%00011111  ;  range 0-31
	cmp #(weaponsOfDeathEnd-weaponsOfDeath) ; we have 20 weapons in table (from 0 to 19)
	bcs MetodOfDeath
	tay
	lda weaponsOfDeath,y
    jsr ExplosionDirect
    mva #sfx_silencer sfx_effect

    ; jump to after explosion routines (soil fallout, etc.)
    ; After going through these routines we are back
    ; to checking if a tank exploded and maybe we have
    ; a deadly shot here again.
    jmp MainRoundLoop.AfterExplode
.endp

;--------------------------------------------------
.proc DecreaseEnergyX
;Decreases energy of player nr X by the value Y
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
.proc DecreaseShieldEnergyX
; Decreases energy of shield player nr X by the value Y
; if shield energy is 0 after decrease then in Y we have
; rest of the energy - to decrease tank energy
;--------------------------------------------------
    sty EnergyDecrease
	ldy #0	; if Shield survive then no decrease tank anergy
    ; Energy cannot be less than 0
    lda ShieldEnergy,x
    cmp EnergyDecrease
    bcc UseAllShieldEnergy
    ;sec
    sbc EnergyDecrease
    bpl NotNegativeShieldEnergy	; jump allways
UseAllShieldEnergy
	; now calculate rest of energy for future tank energy decrease
	sec
	lda EnergyDecrease
	sbc ShieldEnergy,x
	tay
    lda #0
NotNegativeShieldEnergy
    sta ShieldEnergy,x
    rts
.endp

;---------------------------------
.proc Seppuku
    lda #0
    sta FallDown1
    sta FallDown2
    sta ydraw+1
    ; get position of the tank
    ldx TankNr
    lda xtankstableL,x
    sta xdraw
    lda xtankstableH,x
    sta xdraw+1
    lda yTanksTable,x
    sta ydraw
    lda #1  ; Missile
    jsr ExplosionDirect
    jmp MainRoundLoop.continueMainRoundLoopAfterSeppuku
.endp

;--------------------------------------------------
.proc GetRandomWind
;in: MaxWind (byte)
;out: Wind (word)
;uses: _
;--------------------------------------------------
    lda random
    cmp MaxWind
    bcs GetRandomWind ; if more than MaxWind then randomize again
    sta Wind
    mva #$00 Wind+1
    sta Wind+2
    sta Wind+3
    ; multiply Wind by 16
    ; two bytes of Wind are treated as a decimal part of vx variable
    :4 aslw Wind
    ; decide the direction
    lda random
    and #$01
    beq @+
      sec  ; Wind = -Wind
      .rept 4
        lda #$00
        sbc Wind+#
        sta Wind+#
      .endr
@   rts
.endp

;--------------------------------------------------
.proc PMoutofScreen
;--------------------------------------------------
    lda #$00 ; let all P/M disappear
    :8 sta hposp0+#
    rts
.endp
;--------------------------------------------------
.proc ColorsOfSprites     
    lda TankColoursTable ; colours of sprites under tanks
    sta COLPM0S
    lda TankColoursTable+1
    sta COLPM1S
    lda TankColoursTable+2
    sta COLPM2S
    lda TankColoursTable+3
    sta COLPM3S
    LDA TankColoursTable+4
    STA COLPF3S     ; joined missiles (5th tank)
    rts
.endp

;--------------------------------------------------
.proc WeaponCleanup;
; cleaning of the weapon possesion tables
; 99 of Baby Missles(index==0), all other weapons=0)
;--------------------------------------------------
    ldx #$3f  ; TODO: maxweapons
@    lda #$0
      cpx #48  ; White Flag
      bne @+
       lda #99     
@     sta TanksWeapon1,x
      sta TanksWeapon2,x
      sta TanksWeapon3,x
      sta TanksWeapon4,x
      sta TanksWeapon5,x
      sta TanksWeapon6,x
      dex
      beq setBmissile
    bpl @-1
    rts
setBmissile
    lda #99
    bne @-
.endp

;--------------------------------------------------
.proc Initialize
;Initialization sequence
;uses: temp, ...
;--------------------------------------------------
deletePtr = temp

    ; clean variables
    lda #0 
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
    
    
    mva #TextBackgroundColor colpf2s
    mva #TextForegroundColor colpf3s
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
	lda #$ff
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

    ;let the tanks be visible!
    ldx #(maxPlayers-1)
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
    mva #6 NTSCcounter
    
    ; RMT INIT
    lda #$f0                    ;initial value
    sta RMTSFXVOLUME            ;sfx note volume * 16 (0,16,32,...,240)
;
    lda #$ff                    ;initial value
    sta sfx_effect
;
    lda #0
    jsr RmtSongSelect
;
    VMAIN VBLinterrupt,6  		;jsr SetVBL

    rts
.endp
;--------------------------------------------------
.proc DLIinterruptGraph
    ;sta dliA
	;sty dliY
	pha
	phy
	ldy dliCounter
	lda dliColorsBack,y
	ldy dliColorsFore
	nop
	nop
	nop
    sta COLPF1
	sty COLPF2
	inc dliCounter
	;ldy dliY
    ;lda dliA
    ply
    pla
    rti
.endp
;--------------------------------------------------
.proc DLIinterruptText
	;sta dliA
    pha
	sta WSYNC
    mva #TextBackgroundColor colpf2
    mva #TextForegroundColor colpf3
	;lda dliA
    pla
DLIinterruptNone
	rti
.endp
;--------------------------------------------------
.proc VBLinterrupt
	pha
	phx
	phy
	mva #0 dliCounter
	
	lda PAL
	and #%00001110
	beq itsPAL
	;it is NTSC here
    dec NTSCcounter
    bne itsPAL
    mva #6 NTSCcounter
    bne exitVBL ; skip doing VBL things each 6 frames in Amerika, Amerika
                ; We're all living in Amerika, Coca Cola, Wonderbra

itsPAL
    ; pressTimer is trigger tick counter. always 50 ticks / s
    bit:smi:inc pressTimer ; timer halted if >127. max time measured 2.5 s

    
    ; ------- RMT -------
	lda sfx_effect
    bmi lab2
    asl @                       ; * 2
    tay                         ;Y = 2,4,..,16  instrument number * 2 (0,2,4,..,126)
    ldx #0                      ;X = 0          channel (0..3 or 0..7 for stereo module)
    lda #0                      ;A = 0          note (0..60)
    bit noSfx
    smi:jsr RASTERMUSICTRACKER+15   ;RMT_SFX start tone (It works only if FEAT_SFX is enabled !!!)

    lda #$ff
    sta sfx_effect              ;reinit value
lab2
    jsr RASTERMUSICTRACKER+3    ;1 play
    ; ------- RMT -------
	   
exitVBL
    ply
    plx
	pla
	jmp SYSVBV
.endp
;----------------------------------------------
.proc RandomizeSequence0
    ldx #0
@     txa
      sta TankSequence,x
      inx
      cpx #MaxPlayers
    bne @-
    rts
.endp
;--------------------------------------------------
.proc RandomizeSequence
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
.proc RandomizeAngle
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
.proc RandomizeForce
; routine returns in ForceTable/L/H
; valid force of shooting for TankNr
; in X must be TankNr
; low and high randomize boundary passed as word value
; RandBoundaryLow
; RandBoundaryHigh
;----------------------------------------------

    lda RANDOM
    sta temp2
    lda RANDOM
    and #%00000011 ;(0..1023)
    sta temp2+1
	
    cpw RandBoundaryLow temp2
    bcs RandomizeForce

    cpw RandBoundaryHigh temp2
    bcc RandomizeForce

    lda temp2
    sta ForceTableL,x
    lda temp2+1
    sta ForceTableH,x
    
;---------
LimitForce 
; in X must be TankNr
; cuts force to MaxForceTable
    lda MaxForceTableH,x
    cmp ForceTableH,x
    bne @+
    lda MaxForceTableL,x
    cmp ForceTableL,x
@   bcs @+
   
    lda MaxForceTableL,x
    sta ForceTableL,x
    lda MaxForceTableH,x
    sta ForceTableH,x
@
    rts

.endp
;----------------------------------------------
.proc MoveBarrelToNewPosition
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
    jsr DrawTankNr.drawtankNrX
	
	jmp MoveBarrelToNewPosition
rotateLeft
	dec angleTable,x
	bpl MoveBarrelToNewPosition
    	mva #$2e CharCode
   	jsr DrawTankNr.drawtankNrX	

	jmp MoveBarrelToNewPosition
	
BarrelPositionIsFine
	rts
	
.endp

;----------------------------------------------
.proc SortSequence ;
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
.proc GetKey  ; waits for pressing a key and returns pressed value in A
; when [ESC] is pressed, escFlag is set to 1
;--------------------------------------------------
    jsr WaitForKeyRelease
@
      lda SKSTAT
      cmp #$ff
      beq checkJoyGetKey ; key not pressed, check Joy
      cmp #$f7  ; SHIFT
      beq checkJoyGetKey
        
      lda kbcode
      and #$3f ;CTRL and SHIFT ellimination
      cmp #28  ; ESC
      bne getkeyend
        mvx #1 escFlag
      bne getkeyend

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
      bne getkeyend

notpressedJoyGetKey
      ;fire
      lda TRIG0S
    bne @-
    lda #$0c ;Return key
    
getkeyend
    mvx #sfx_keyclick sfx_effect
    rts
.endp

;--------------------------------------------------
.proc getkeynowait
;--------------------------------------------------
    jsr WaitForKeyRelease 
    lda kbcode
    and #$3f ;CTRL and SHIFT ellimination
    rts
.endp

;--------------------------------------------------
.proc WaitForKeyRelease
;--------------------------------------------------
    lda JSTICK0
    and #$0f
    cmp #$0f
    bne WaitForKeyRelease
    lda TRIG0S
    beq WaitForKeyRelease
    lda SKSTAT
    cmp #$ff
    bne WaitForKeyRelease
    rts
.endp

;--------------------------------------------------
.proc RmtSongSelect
;--------------------------------------------------
;  starting song line 0-255 to A reg
    bit noMusic
    spl:lda #song_silencio
    ldx #<MODUL                 ;low byte of RMT module to X reg
    ldy #>MODUL                 ;hi byte of RMT module to Y reg
    jmp RASTERMUSICTRACKER      ;Init, :RTS
.endp
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
    icl 'artwork/talk.asm'
;----------------------------------------------
font4x4
    ins 'artwork/font4x4s.bmp',+62
;----------------------------------------------
TankFont
    ins 'artwork/tanks.fnt'
;----------------------------------------------
    icl 'variables.asm'
;----------------------------------------------

; reserved space for RMT player
    .ds $0320
    .align $100
    .ECHO 'PLAYER: ',*
    icl 'artwork/sfx/rmtplayr_game.asm'

MODUL    equ $b000                                 ;address of RMT module
    opt h-                                         ;RMT module is standard Atari binary file already
    ins "artwork/sfx/scorch_trial0f_stripped.rmt"  ;include music RMT module
    opt h+
;
;
TheEnd
    .ECHO 'TheEnd: ',TheEnd
    .if TheEnd > PMGraph + $300
        .error memory conflict

    .endif
;----------------------------------------------
; Player/missile memory
    org $b800
PMGraph



    run START
