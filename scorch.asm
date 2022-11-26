;	@com.wudsn.ide.asm.mainsourcefile=scorch.asm
;Atari 8-bit Scorched Earth source code
;---------------------------------------------------
;by Tomasz 'pecus' Pecko and Pawel 'pirx' Kalinowski
;Warsaw 2000, 2001, 2002, 2003, 2009, 2012, 2013
;Miami & Warsaw 2022

;---------------------------------------------------
.def TARGET = 800 ;5200  ; or 800
;atari800  -5200 -cart ${outputFilePath} -cart-type 4
;atari800  -run ${outputFilePath}
;---------------------------------------------------

   ;OPT r+  ; saves 12 bytes :O

;---------------------------------------------------
.macro build
	dta d"1.20" ; number of this build (4 bytes)
.endm

.macro RMTSong
      lda #:1
      jsr RMTSongSelect
.endm

;---------------------------------------------------
    icl 'definitions.asm'
;---------------------------------------------------
FirstZpageVariable = $61
    .zpvar DliColorBack		.byte = FirstZpageVariable
	.zpvar JoystickNumber	.byte
    .zpvar xdraw            .word ;= $64 ;variable X for plot
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
    .zpvar tempor2          .word
	.zpvar CreditsVScrol	.byte
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
	.zpvar UnderTank1		.byte
	.zpvar UnderTank2		.byte	
    ;----------------------------
	.zpvar TestFlightFlag	.byte ; For AI test flights ($ff - test, $00 - standard shoot flight)
    .zpvar weaponPointer    .word
	.zpvar dliCounter       .byte
	.zpvar pressTimer       .byte
	.zpvar NTSCcounter      .byte
	.zpvar IsEndOfTheFallFlag .byte ; for small speedup ground falling
	.zpvar sfx_effect .byte
	.zpvar RMT_blocked	.byte
	.zpvar ScrollFlag .byte
	.zpvar SkStatSimulator	.byte

    ; --------------OPTIMIZATION VARIABLES--------------
    .zpvar Force .word
    .zpvar Force_ .byte ; Force is 3 bytes long
    .zpvar Angle .byte
    .zpvar Parachute .byte ; are you insured with parachute?
    .zpvar color .byte
    .zpvar Erase .byte  ; if 1 only mask of the character is printed
                        ; on the graphics screen. if 0 character is printed normally
    .zpvar radius .byte
    .zpvar decimal .word
    .zpvar NumberOfPlayers .byte ;current number of players (counted from 1)
    .zpvar Counter .byte ;temporary Counter for outside loops
    .zpvar ExplosionRadius .byte
    .zpvar ResultY .byte
    .zpvar xcircle .word
    .zpvar ycircle .word
    .zpvar vy .word
    .zpvar vy_ .word ; 4 bytes
    .zpvar vx .word
    .zpvar vx_ .word ; 4 bytes
    .zpvar HitFlag .byte ;$ff when missile hit ground, $00 when no hit, $01-$06 tank index+1 when hit tank
    .zpvar PositionOnTheList .byte ; pointer position on the list being displayed
    .zpvar XHit .word
    .zpvar delta .word
    .zpvar HowMuchToFall .byte
    .zpvar magic .word
    .zpvar xtraj .word
    .zpvar xtraj_ .byte  ; 3 bytes
    .zpvar ytraj .word
    .zpvar ytraj_ .byte  ; 3 bytes
    .zpvar Wind .word
    .zpvar Wind_ .word  ; 4 bytes
    .zpvar RangeLeft .word
    .zpvar RangeRight .word
    .zpvar NewAngle .byte
    .zpvar escFlag .byte
    .zpvar LineYdraw .byte
    .zpvar LineXdraw .word
    .zpvar plot4x4color .byte	; $00 / $ff 
    .zpvar Multiplier .word
    .zpvar Multiplier_ .byte  ; 3 bytes
    .zpvar HowToDraw .byte
    .zpvar gravity .byte
    .zpvar LineLength .word
    .zpvar tracerflag .byte
    .zpvar isInventory .byte
    .zpvar DifficultyLevel .byte
    .zpvar goleft .byte
    .zpvar OffsetDL1 .byte
    .zpvar L1 .byte
	
    ;* RMT ZeroPage addresses in artwork/sfx/rmtplayr.a65

    displayposition = modify
    LineAddress4x4 = xcircle

;-----------------------------------------------
; libraries
;-----------------------------------------------
    .IF TARGET = 5200
      OPT h-f+  ; no headers, single block --> cart bin file
      icl 'lib/5200SYS.ASM'
      icl 'lib/5200MACRO.ASM'
      .enum @kbcode 
        /*
        _0
        _1
        _2
        _3
        _4
        _5
        _6
        _7
        _8
        _9
        _asterisk = $0a
        _hash = $0b
        _start = $0c
        _pause = $0d
        _reset = $0e
        */
        _space = $00
        _Y     = $01
        _up    = $02
        _O     = $03
        _left  = $04
        _tab   = $05
        _right = $06
        _A     = $07
        _down  = $08
        _I     = $09
        _esc   = $0a
        _ret   = $fb  ;$0b ;not used in 5200
        _del   = $fc  ;$0c ;not used in 5200
        _M     = $0d
        _S     = $0e
		_atari = $fd  ; not used in 5200
        _none = $0f

      .ende */
    .ELSE
      icl 'lib/ATARISYS.ASM'
      icl 'lib/MACRO.ASM'
      icl 'artwork/Scorch50.asm'  ; splash screen and musix
    .ENDIF
    
;-----------------------------------------------
; variable declarations in RAM (no code)
;-----------------------------------------------
    ORG PMGraph + $0300 - (variablesEnd - OneTimeZeroVariables + 1)
    icl 'variables.asm'
        
    ; Game loading address
    ORG $4000
    
WeaponFont
    ins 'artwork/weapons_AW6_mod.fnt'  ; 'artwork/weapons.fnt'

;-----------------------------------------------
;Screen displays go here to avoid crossing 4kb barrier
;-----------------------------------------------
    DisplayCopyRom = *
    org display, DisplayCopyRom
DisplayCopyStart
    icl 'display_main_menu.asm'
DisplayCopyEnd
    org DisplayCopyRom + (DisplayCopyEnd - DisplayCopyStart)
    
    DisplayCopyPurchaseDlROM = *
    org DisplayCopyPurchase, DisplayCopyPurchaseDlROM
DisplayCopyPurchaseStart
    icl 'display_purchasedl.asm'
DisplayCopyPurchaseEnd
    org DisplayCopyPurchaseDlROM + (DisplayCopyPurchaseEnd - DisplayCopyPurchaseStart)
    
    StatusBufferROM = *
    org StatusBufferCopy, StatusBufferROM
StatusBufferCopyStart
    icl 'display_status.asm'
StatusBufferCopyEnd
    org StatusBufferROM + (StatusBufferCopyEnd - StatusBufferCopyStart)
    

    icl 'display_static.asm'
;----------------------------------------------
    
;--------------------------------------------------
; Game Code
;--------------------------------------------------
FirstSTART
	jsr MakeDarkScreen

	; one time zero variables in RAM (non zero page)
	lda #0
	ldy #OneTimeZeroVariablesCount-1
@	  sta OneTimeZeroVariables,y
	  dey
	bpl @-
	
	; one time zero variables in RAM (zero page)
	ldy #FirstZpageVariable
@	sta $0000,y
	iny
	bne @-
	
	; initialize variables in RAM (non zero page)
	ldy #initialvaluesCount-1
@	  lda initialvaluesStart,y
	  sta variablesToInitialize,y
	  dey
	bpl @-


    ; generate linetables
    mwa #display temp
    mwa #linetableL temp2
    mwa #linetableH modify
    ldy #0
@     lda temp
      sta (temp2),y
      lda temp+1
      sta (modify),y
      adw temp #40
      iny
      cpy #screenheight+1
    bne @-

    .IF TARGET = 800
	lda PAL
	and #%00001110
	bne NoRMT_PALchange
	;it is PAL here
	; Change RMT to PAL version
	; 5 values in RMT file
	; not elegant :(
	mva #$06 MODUL-6+$967	; $07 > $06
	;mva #$06 MODUL-6+$bc3	; $07 > $06
	;mva #$06 MODUL-6+$e69	; $08 > $06
	;mva #$06 MODUL-6+$ebc	; $08 > $06
	sta MODUL-6+$bc3	; $07 > $06
	sta MODUL-6+$e69	; $08 > $06
	sta MODUL-6+$ebc	; $08 > $06
	mva #$10 MODUL-6+$a69	; $12 > $10
	mva #$04 MODUL-6+$bf8	; $05 > $04
	mva #$08 MODUL-6+$e3d	; $0a > $08
NoRMT_PALchange
	.ELSE
	mva #$7f SkStatSimulator
    .ENDIF


    ; RMT INIT
    lda #$f0                    ;initial value
    sta RMTSFXVOLUME            ;sfx note volume * 16 (0,16,32,...,240)

    lda #$ff                    ;initial value
    sta sfx_effect

    RMTSong 0

    .IF TARGET = 5200
        mva #$0f STICK0
        mva #$04 CONSOL5200          ;Speaker off, Pots enabled, port #1 selected
        mwa #kb_continue VKEYCNT     ;Keyboard handler
    .ENDIF
    VMAIN VBLinterrupt,7  		;jsr SetVBL
	
	mva #2 chactl  ; necessary for 5200
	
START
    ; Startup sequence
    jsr Initialize

	;jsr GameOverScreen	; only for test !!!
    
    RMTSong song_main_menu

    jsr Options  ;startup screen
	jsr MakeDarkScreen
    bit escFlag
    bmi START

    jsr EnterPlayerNames
	jsr MakeDarkScreen
    bit escFlag
    bmi START

    jsr RandomizeSequence
    ; for the round #1 shooting sequence is random
	
MainGameLoop
	jsr SetWallsType
	; first set default barrel lengths (fix for Long Schlong activation :) )
	; we must do it before purchase/activate
	; and set Auto Defense to off
    jsr SetStandardBarrels

	jsr CallPurchaseForEveryTank
	mva #0 SpyHardFlag

    ; issue #72 (glitches when switches)
	jsr MakeDarkScreen

    bit escFlag
    bmi START

    jsr GetRandomWind

    jsr RoundInit
    
    jsr MainRoundLoop
    bit escFlag
    bmi START
	jvs GoGameOver
    
    mva #0 TankNr  ; 
    
    jsr SortSequence
    
    ; Hide all (easier than hide last ;) ) tanks
    jsr cleartanks	; A=0
	sta COLBAKS		; set background color to black
	sta JoystickNumber	; set joystick port for player

    ; here gains and losses should be displayed (dollars)
    ; finally we have changed our minds and money of players
    ; is displayed only in weapons shop

    ; Results are number of other deaths
    ; before the player dies itself

    RmtSong song_round_over
    jsr DisplayResults

	jsr DemoModeOrKey

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
	
	; adding the remaining energy of the tank to gain
	; winner gets more ! :)
	lda Energy,x
	adc gainL,x
	sta gainL,x
	bcc @+
	inc gainH,x
@	
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
    ; substract lose
    ; if lose is greater than money then zero money
    lda moneyH,x
    cmp loseH,x
    bcc zeromoney
    bne substractlose
    lda moneyL,x
    cmp loseL,x
    bcc zeromoney
substractlose
    sec
    lda moneyL,x
    sbc loseL,x
    sta moneyL,x
    lda moneyH,x
    sbc loseH,x
    sta moneyH,x
    jmp skipzeroing
zeromoney
    lda #0
    sta moneyL,x
    sta moneyH,x
skipzeroing
; and earned money for summary
    clc
    lda EarnedMoneyL,x
    adc gainL,x
    sta EarnedMoneyL,x
    lda EarnedMoneyH,x
    adc gainH,x
    sta EarnedMoneyH,x
    ; substract lose
    ; if lose is greater than money then zero money
    lda EarnedMoneyH,x
    cmp loseH,x
    bcc ezeromoney
    bne esubstractlose
    lda EarnedMoneyL,x
    cmp loseL,x
    bcc ezeromoney
esubstractlose
    sec
    lda EarnedMoneyL,x
    sbc loseL,x
    sta EarnedMoneyL,x
    lda EarnedMoneyH,x
    sbc loseH,x
    sta EarnedMoneyH,x
    jmp eskipzeroing
ezeromoney
    lda #0
    sta EarnedMoneyL,x
    sta EarnedMoneyH,x
eskipzeroing

    dex
    jpl CalculateGains

    lda GameIsOver
	beq NoGameOverYet
GoGameOver
	jsr MakeDarkScreen
	jsr GameOverScreen
    jmp START
NoGameOverYet
    inc CurrentRoundNr
    jsr MakeDarkScreen   ; issue #72
    ; jsr RmtSongSelect  ; ?????
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
; of course gains an loses are zeroed

    RmtSong song_ingame

	jsr SetPMWidth
	lda #0
	sta AfterBFGflag	; reset BFG flag
	sta COLOR2	; status line "off"
	sta COLOR1
	
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
      sta loseL,x
      sta loseH,x
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
	jsr ClearPMmemory
    jsr placetanks    ;let the tanks be evenly placed
    jsr calculatemountains ;let mountains be easy for the eye
    ;jsr calculatemountains0 ;only for tests - makes mountains flat and 0 height


    mwa #StatusBufferROM temp
    mwa #StatusBufferCopy temp2
    mwa #StatusBufferCopyEnd+1 modify
    jsr CopyFromROM

    jsr SetMainScreen
    jsr ColorsOfSprites

    jsr drawmountains ;draw them
    jsr drawtanks     ;finally draw tanks

	mva #$00 TankSequencePointer

;---------round screen is ready---------
	mva #TextForegroundColor COLOR1	; status line "on"
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
	; Auto Defense - activates defensives
    ldx NumberOfPlayers
    dex
CheckNextTankAD
    lda Energy,x	; only active players
    beq @+
	lda AutoDefenseFlag,x	; with Auto Defence activated
	beq @+
	; run auto defense for tank in X
	jsr AutoDefense
@   dex
    bpl CheckNextTankAD
	jsr DrawTanks	; redraw tanks with new defences
;
    ldx TankSequencePointer
    lda TankSequence,x
    sta TankNr
    tax
    lda Energy,x ;skip if no energy
    jeq NextPlayerShoots


    
    mva #$ff plot4x4color
    jsr DisplayTankNameAbove
    
    mva #1 color ;to display flying point

    ldx tankNr
    lda TankStatusColoursTable,x
    sta COLOR2  ; set color of status line
    jsr PutTankNameOnScreen
    jsr DisplayStatus

    lda SkillTable,x
    beq ManualShooting

RoboTanks
	; robotanks shoot here	
	; TankNr still in X
    jsr ArtificialIntelligence
    ;pause 30
	ldx TankNr
	jsr DisplayStatus	; to make visible AI selected defensive (and offensive :) )
    jsr MoveBarrelToNewPosition
    lda kbcode
    cmp #@kbcode._esc ; 28  ; ESC
    bne @+
    jsr AreYouSure
@	lda escFlag
    seq:rts		; keys Esc or O


    jmp AfterManualShooting

ManualShooting
	lda JoyNumber,x
	sta JoystickNumber	; set joystick port for player
    jsr WaitForKeyRelease
    jsr BeforeFire
    lda escFlag
    seq:rts		; keys Esc or O

AfterManualShooting
    mva #$00 plot4x4color
    jsr DisplayTankNameAbove
	; defensive weapons without flight handling
	ldx TankNr
	lda ActiveDefenceWeapon,x
	cmp #ind_Hovercraft_____
	beq GoFloat
	cmp #ind_White_Flag_____ ; White Flag
	beq ShootWhiteFlag
	cmp #ind_Nuclear_Winter_
	bne StandardShoot
ShootAtomicWinter
	; --- atomic winter ---
	jsr AtomicWinter
	jmp NextPlayerShoots ; and we skip shoot
ShootWhiteFlag
	; --- white flag ---
	jsr WhiteFlag
	jmp NextPlayerShoots ; and we skip shoot
GoFloat
	jsr TankFlying
	lda #0
	sta ActiveDefenceWeapon,x ; deactivate after use
	bit escFlag
	bpl ManualShooting ; after floating tank can shoot
	rts
StandardShoot
    inc noDeathCounter

    jsr DecreaseWeaponBeforeShoot
    jsr DisplayStatus

;	ldx TankNr
	dec Energy,x   ; lower energy to eventually let tanks commit suicide

ShootNow
    jsr Shoot
    ;here we clear offensive text (after a shoot)
    ldy TankNr
    mva #$00 plot4x4color
    jsr DisplayOffensiveTextNr
    
    lda HitFlag ;0 if missed
    beq missed
    
    jsr Explosion

continueMainRoundLoopAfterSeppuku

AfterExplode
    jsr SoilDown2	; allways
NoFallDown2
    ;here tanks are falling down
    mva tankNr tempor2
	ldx NumberOfPlayers
	dex
TanksFallDown
    stx TankNr
	lda eXistenZ,x
	beq NoExistNoFall
    jsr TankFalls
NoExistNoFall
    dex
    bpl TanksFallDown
    mvx tempor2 TankNr

missed
    ldy WeaponDepleted
    bne @+
      ldx TankNr
      tya
      sta ActiveWeapon,x 
@

    ;here we clear offensive text (after a shoot)
    ldy TankNr
    mva #$00 plot4x4color
    jsr DisplayOffensiveTextNr

NextPlayerShoots
    ;before it shoots, the eXistenZ table must be updated
    ;accordingly to actual energy (was forgotten, sorry to ourselves)

    ldx #(MaxPlayers-1)
SeteXistenZ
    lda Energy,x
    sta eXistenZ,x
	
	jsr MaxForceCalculate

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

    mva #sfx_death_begin sfx_effect

    ; display defensive text here (well, defensive
    ; is not the real meaning, it should be pre-death,
    ; but I am too lazy to change names of variables)

    ; in X there is a number of tank that died

	lda #77	; mumber of defensive text after BFG!
	bit AfterBFGflag	; check BFG flag
	bmi TextAfterBFG
	; if BFG then no points for dead tanks ...
    lda CurrentResult
    clc
    adc ResultsTable,x
    sta ResultsTable,x
    ;inc CurrentResult
	
    ; RandomizeDeffensiveText
    randomize talk.NumberOfOffensiveTexts (talk.NumberOfDeffensiveTexts+talk.NumberOfOffensiveTexts-1) 
TextAfterBFG
    sta TextNumberOff
    inc CurrentResult	; ... but increase result of winner (BFG)
    ldy TankTempY
    mva #$ff plot4x4color
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
    mva #$00 plot4x4color
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

	; Clear current Shooter settings. After that, Shooter will "search" for the target again
	ldx NumberOfPlayers
	dex
@	lda skillTable,x
	cmp #2		; clear variables only if Shooter
	bne NotShooter
	lda #0
	sta PreviousAngle,x
	sta PreviousEnergyL,x
	sta PreviousEnergyH,x
NotShooter
	dex
	bpl @-

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
    ; Lose increase
    lda loseL,x
    clc
    adc EnergyDecrease
    sta loseL,x
    lda loseH,x
    adc #$00
    sta loseH,x
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
 ;   phx
    ldy TankNr
    clc
    lda gainL,y
    adc EnergyDecrease
    sta gainL,y
    lda gainH,y
    adc #$00
    sta gainH,y
 ;   plx
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
    sta ydraw+1
    ; get position of the tank
    ldx TankNr
;    lda #0  ; turn off defense weapons when hara-kiring
    sta ActiveDefenceWeapon,x
    sta ShieldEnergy,x
    jsr SetupXYdraw
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
.proc MaxForceCalculate
; calculates max force for tank (tanknr in X)
; Energy of tank X in A
;--------------------------------------------------
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
	rts
.endp

;--------------------------------------------------
.proc WeaponCleanup;
; cleaning of the weapon possesion tables
; 99 of Baby Missles(index==0), all other weapons=0)
;--------------------------------------------------
    ldx #$3f  ; TODO: maxweapons
@    lda #$0
      cpx #ind_White_Flag_____  ; White Flag
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
    sta escFlag
	sta JoystickNumber
    tay
    mwa #variablesStart deletePtr
@     tya
      sta (deletePtr),y
      inw deletePtr
      cpw deletePtr #variablesEnd
    bne @-

		; ser initial shapes for each tank (tanks 0-5 has shape 0 now)
	ldy #1
	sty TankShape+1
	sty TankShape+4
	iny
	sty TankShape+2
	sty TankShape+5
	

    mwa #1024 RandBoundaryHigh
    mva #$ff LastWeapon
    sta HowMuchToFall
    mva #1 color
    
	jsr SetStandardBarrels
    jsr WeaponCleanup        
    
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
    lda #$03    ; P/M on
    sta GRACTL
	jsr SetPMWidth
    lda #%00100001 ; P/M priorities (multicolor players on) - prior=1
    sta GPRIOR
    jsr PMoutofScreen

    ;let the tanks be visible!
    ldx #(maxPlayers-1)
    lda #99 ; tank is visible
MakeTanksVisible
    sta eXistenZ,x
    dex
    bpl MakeTanksVisible

    mva #1 CurrentRoundNr ;we start from round 1
    mva #6 NTSCcounter
    
    rts
.endp
;--------------------------------------------------
.proc SetStandardBarrels
    ldx #maxPlayers-1
@	lda #StandardBarrel	; standard barrel length
	sta BarrelLength,x
	lda #$00	; deactivate Auto Defense
	sta AutoDefenseFlag,x
	dex
	bpl @-
	rts
.endp
;--------------------------------------------------
/* .proc DLIinterruptGraph
    ;sta dliA
	;sty dliY
	pha
	phy
	ldy dliCounter
	lda dliColorsBack,y
	ldy dliColorsFore
    .IF TARGET = 800
	    nop  ; necessary on 800 because DLIs take less time, jitter visible without it
        nop
    .ENDIF
    sta COLPF1
	sty COLPF2
	inc dliCounter
	;ldy dliY
    ;lda dliA
    ply
    pla
    rti
.endp */

.proc DLIinterruptGraph
	pha
	lda dliColorsFore
	nop
	nop
    nop
    .IF TARGET = 800
	    nop  ; necessary on 800 because DLIs take less time, jitter visible without it
        nop

    .ENDIF
	sta COLPF2
	lda DliColorBack
    sta COLPF1
	eor #$02
	sta DliColorBack
    pla
    rti
.endp
;--------------------------------------------------
.proc DLIinterruptOptions
    ;sta dliA
	;sty dliY
	pha
;	lda dliColorsBack
	lda #0
    sta COLPF1
	lda dliColorsFore
	sta COLPF2
    pla
    rti
.endp
;--------------------------------------------------
.proc DLIinterruptGameOver
    ;sta dliA
	;sty dliY
	pha
	phy
	lda dliCounter
	bne EndofPMG
    lda #%00100001	; playfield after P/M - prior=1
	;STA WSYNC
    sta PRIOR
	bne EndOfDLI_GO
EndofPMG
	cmp #1
	bne ColoredLines
    lda #%00100100	; playfield before P/M
	;STA WSYNC
    sta PRIOR
	bne EndOfDLI_GO
ColoredLines
	cmp #9
	beq CreditsScroll
	tay
	lda GameOverColoursTable-3,y	; -2 because this is DLI nr 2 and -1 (labels line)
	ldy #$0a	; text colour (brightnes)
	;STA WSYNC
	sta COLPF2
	sty COLPF1
	bne EndOfDLI_GO
CreditsScroll
	lda #$00
	sta COLPF2
EndOfDLI_GO
	inc dliCounter
	ply
	pla
	rti
.endp
;--------------------------------------------------
.proc DLIinterruptText
	;sta dliA
    pha
	lda dliCounter
	bne MoreBarsColorChange
    lda #TextBackgroundColor
	;sta WSYNC
    sta COLPF2
    mva #TextForegroundColor COLPF3
	bne EndOfDLI_Text
MoreBarsColorChange
	and #%00000001
	rol
	sta COLPF2
EndOfDLI_Text
	inc dliCounter
    pla
DLIinterruptNone
	rti
	
.endp
;--------------------------------------------------
.proc VBLinterrupt
	mva #0 dliCounter
	mva #$02 DliColorBack
	
	lda PAL
	and #%00001110
	beq itsPAL
	;it is NTSC here
    dec NTSCcounter
    bne itsPAL
    mva #6 NTSCcounter
    bne SkippedIfNTSC ; skip doing VBL things each 6 frames in Amerika, Amerika
                ; We're all living in Amerika, Coca Cola, Wonderbra

itsPAL
    ; pressTimer is trigger tick counter. always 50 ticks / s
    bit:smi:inc pressTimer ; timer halted if >127. max time measured 2.5 s
	
SkippedIfNTSC

	bit RMT_blocked
	bmi SkipRMTVBL
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
SkipRMTVBL	   
	bit ScrollFlag
	bpl EndOfCreditsVBI
CreditsVBI
	inc CreditsVScrol
	lda CreditsVScrol
	cmp #32		;not too fast
	beq nextlinedisplay
	:2 lsr		;not too fast
	sta VSCROL
	jmp EndOfCreditsVBI
nextlinedisplay
	lda #0
	sta CreditsVScrol
	sta VSCROL
	clc
	lda DLCreditsAddr
	adc #40
	sta DLCreditsAddr
	bcc @+
	inc DLCreditsAddr+1
@
	cmp #<CreditsLastLine
	bne EndOfCreditsVBI
	lda DLCreditsAddr+1
	cmp #>CreditsLastLine
	bne EndOfCreditsVBI
;	adw DLCreditsAddr #40
;	cpw DLCreditsAddr #CreditsLastLine
;	bne EndOfCreditsVBI
	mwa #Credits DLCreditsAddr
EndOfCreditsVBI
	.IF TARGET = 5200
		lda SkStatSimulator
		bmi @+
		inc SkStatSimulator
@
		lda JoystickNumber		; select port
		ora #%00000100          ; Speaker off, Pots enabled
        sta CONSOL5200

        center = 114            ;Read analog stick and make it look like a digital stick
        threshold = 60
		
		lda JoystickNumber
		asl
		tax
        lda paddl0,x            ;Read POT0 value (horizontal position)
        cmp #center+threshold       ;Compare with right threshold
        rol stick0          ;Feed carry into digital stick value
        cmp #center-threshold       ;Compare with left threshold
        rol stick0          ;Feed carry into digital stick value
    
        lda paddl1,x            ;Read POT1 value (vertical position)
        cmp #center+threshold       ;Compare with down threshold
        rol stick0          ;Feed carry into digital stick value
        cmp #center-threshold       ;Compare with down threshold
        rol stick0          ;Feed carry into digital stick value
    
        lda stick0          ;0 indicates a press so the right/down values need to be inverted
        eor #2+8
        and #$0f
        sta stick0
		
		ldx JoystickNumber
		lda trig0,x
		sta strig0        ;Move hardware to shadow
        
        mva chbas chbase
    
        lda skstat          ;Reset consol key shadow is no key is pressed anymore
        and #4
        beq @+
          mva #consol_reset consol
          mva #@kbcode._none kbcode
@

        pla
        tay
        pla
        tax
        pla
		rti
    .ELSE	
		; support for joysticks :)
		ldx JoystickNumber
		lda STICK0,x
		sta STICK0
		lda STRIG0,x
		sta STRIG0
		jmp XITVBV
	.ENDIF
.endp
    .IF TARGET = 5200
.proc kb_continue
    sta kbcode          ;Store key code in shadow.
	mva #0 SkStatSimulator
exit    pla
    tay
    pla
    tax
    pla
    rti
.endp    
    .ENDIF
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


    ;sta temp
    ;lda #90 ; CARRY=0 here
    ;sbc temp

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
    seq:bcs RandomizeForce

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
	mva #1 Erase
	jsr DrawTankNr.BarrelChange
	mva #0 Erase
MoveBarrel
    mva #sfx_set_power_2 sfx_effect
	jsr DrawTankNr
	jsr DisplayStatus.displayAngle
;	ldx TankNr
	mva #1 Erase
	jsr WaitOneFrame
	jsr DrawTankNr.BarrelChange
	mva #0 Erase
	lda NewAngle
	cmp AngleTable,x
	beq BarrelPositionIsFine
	bcc rotateLeft ; older is bigger
rotateRight;older is lower
	inc angleTable,x
	jmp MoveBarrel
rotateLeft
	dec angleTable,x
	jmp MoveBarrel
BarrelPositionIsFine
	jsr DrawTankNr
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
    beq nextishigher ; this is to block hangs when 2 equal values meet
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
.proc SetWallsType
;--------------------------------------------------
	mva #0 WallsType
	lda OptionsTable+8
	cmp #4
	beq SetRandomWalls
	lsr
	ror WallsType
	lsr
	ror WallsType
	rts
SetRandomWalls
	lda random
	and #%11000000
	sta WallsType
	rts
.endp
;--------------------------------------------------
.proc GetKey  ; waits for pressing a key and returns pressed value in A
; when [ESC] is pressed, escFlag is set to 1
;--------------------------------------------------
    jsr WaitForKeyRelease
@
      .IF TARGET = 800
          lda SKSTAT
          cmp #$ff
          beq checkJoyGetKey ; key not pressed, check Joy
          cmp #$f7  ; SHIFT
          beq checkJoyGetKey
	  .ELSE
		  lda SkStatSimulator
		  and #%11111110
		  bne checkJoyGetKey ; key not pressed, check Joy
      .ENDIF            
          lda kbcode
          cmp #@kbcode._none
          beq checkJoyGetKey
          and #$3f ;CTRL and SHIFT ellimination
          cmp #@kbcode._esc  ; 28  ; ESC
          bne getkeyend
            mvy #$80 escFlag
          bne getkeyend

checkJoyGetKey
      ;------------JOY-------------
      ;happy happy joy joy
      ;check for joystick now
      lda STICK0
      and #$0f
      cmp #$0f
      beq notpressedJoyGetKey
      tay 
      lda joyToKeyTable,y
      bne getkeyend

notpressedJoyGetKey
	;fire
	lda STRIG0
 	beq JoyButton
	.IF TARGET = 800	; Select and Option key only on A800
	bne checkSelectKey
checkSelectKey
	lda CONSOL
	and #%00000010	; Select
	beq SelectPressed
	lda CONSOL
	and #%00000100	; Option	
	.ENDIF
    bne @-
OptionPressed
	lda #@kbcode._atari	; Option key
	bne getkeyend	
SelectPressed
	lda #@kbcode._tab	; Select key
	bne getkeyend
JoyButton
    lda #@kbcode._ret ;Return key    
getkeyend
	ldy #0
    sty ATRACT	; reset atract mode	
    mvy #sfx_keyclick sfx_effect
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
	mva #128-KeyRepeatSpeed pressTimer	; tricky
StillWait	
	bit pressTimer
	bmi KeyReleased
      lda STICK0
      and #$0f
      cmp #$0f
      bne StillWait
      lda STRIG0
      beq StillWait
    .IF TARGET = 800
      lda SKSTAT
      cmp #$ff
      bne StillWait
      lda CONSOL
      and #%00000110	; Select and Option only
      cmp #%00000110
      bne StillWait
	.ELSE
	lda SkStatSimulator
	and #%11111110
	beq StillWait
    .ENDIF
KeyReleased
      rts
.endp
;--------------------------------------------------
.proc IsKeyPressed	; A=0 - yes , A>0 - no
;--------------------------------------------------
	lda SKSTAT
	and #%00000100
	beq @+
	lda #1
@	and STRIG0
	rts
.endp
;--------------------------------------------------
.proc DemoModeOrKey
;--------------------------------------------------
    ;check demo mode
    ldx numberOfPlayers
    dex
checkForHuman ; if all in skillTable other than 0 then switch to DEMO MODE
    lda skillTable,x
    beq peopleAreHere
    dex
    bpl checkForHuman
    ; no people, just wait a bit
    ;pause 150
    ldy #75
    jsr PauseYFrames
    rts

peopleAreHere
    jmp getkey  ; jsr:rts
.endp

MakeDarkScreen
	jsr PMoutofScreen
	mva #0 dmactls		; dark screen
    sta dmactl
	; and wait one frame :)
.proc WaitOneFrame
	lda CONSOL
	and #%00000101	; Start + Option
	sne:mva #$40 escFlag	
	and #%00000001 ; START KEY
	seq:wait
    rts
.endp

.proc PauseYFrames
; Y - number of frames to wait (divided by 2)
; pauses for maximally 510 frames (255 * 2)
@     jsr WaitOneFrame
      jsr WaitOneFrame
      dey
    bne @-
    rts
.endp

;--------------------------------------------------
.proc RmtSongSelect
;--------------------------------------------------
;  starting song line 0-255 to A reg
	cmp #song_ingame
	bne noingame	; noMusic blocks only ingame song
    bit noMusic
    spl:lda #song_silencio
noingame
	mvx #$ff RMT_blocked
    ldx #<MODUL                 ;low byte of RMT module to X reg
    ldy #>MODUL                 ;hi byte of RMT module to Y reg
    jsr RASTERMUSICTRACKER      ;Init
	mva #0 RMT_blocked
	rts
.endp
;-------------------------------------------------
.proc CopyFromROM
;-------------------------------------------------
;copy from CART to RAM
; trashes: Y
; temp: source
; temp2: destination
; modify: destination-end
;usage:
;    mwa #DisplayCopyRom temp
;    mwa #display temp2
;    mwa #DisplayCopyEnd+1 modify
;    jsr CopyFromROM

    ldy #0
@     lda (temp),y
      sta (temp2),y
      inw temp
      inw temp2
      cpw temp2 modify
    bne @-
    rts
.endp
;--------------------------------------------------
.macro SetDLI
;	SetDLI #WORD
;	Initialises Display List Interrupts
         LDY # <:1
         LDX # >:1
		 jsr _SetDLIproc
.endm
.proc _SetDLIproc
	LDA #$C0
	STY VDSLST
	STX VDSLST+1
	STA NMIEN
	rts
.endp
;--------------------------------------------------
/* ;--------------------------------------------------
.macro randomize floor ceiling
;--------------------------------------------------
    ;usage: randomize floor ceiling
    ;returns (in A) a random .byte between "floor" and "ceiling"
        jsr _randomizator
        .byte :floor
        .byte :ceiling
.endm

.proc _randomizator
; private function that accompanies `randomize` macro
; trashes: magic, temp, Y
    pla
    sta magic
    pla
    sta magic+1
    ldy #1  ; add 1 to the value got from the stack to point to the input parameters
    lda (magic),y
    sta temp
    iny
    lda (magic),y
    sta temp+1

?rand
      lda random
      cmp temp ;floor
      bcc ?rand
      cmp temp+1 ;ceiling
      bcs ?rand
      tay  ; save the result
      
    ; point the PC to a byte after the parameters
    clc
    lda magic
    adc #2 ; length of the parameters in bytes
    sta magic
    lda magic+1
    adc #0
    pha
    lda magic
    pha
    tya ; retrieve the result
    rts
.endp */
;----------------------------------------------
    icl 'constants.asm'
;----------------------------------------------
    icl 'textproc.asm'
;----------------------------------------------
    icl 'grafproc.asm'
;----------------------------------------------
    icl 'weapons.asm'
;----------------------------------------------
    icl 'ai.asm'
;----------------------------------------------
    icl 'artwork/talk.asm'
;----------------------------------------------
TankFont
    ins 'artwork/tanksv3.fnt',+0,352	; 44 characters only
;----------------------------------------------
font4x4
    ins 'artwork/font4x4s.bmp',+62
;----------------------------------------------
;RMT PLAYER loading shenaningans
    icl 'artwork/sfx/rmtplayr_modified.asm'
;-------------------------------------------------
.proc CheckTankCheat
    ldy #$07
    lda TankNr
    asl
    asl
    asl ; 8 chars per name
    tax
@
    lda CheatName,y
	sec
    sbc tanksnames,x
	cmp #$27
	bne NoCheat
    inx
    dey
    bpl @-
YesCheat
	ldx TankNr
	lda TanksWeaponsTableL,x
	sta temp
	lda TanksWeaponsTableH,x
	sta temp+1
	lda #99
@	iny
	sta (temp),y
	cpy #(last_defensive_____ - first_offensive____)
	bne @-
NoCheat
    rts
.endp
CheatName
	dta d"   008.T"+$27
;----------------------------------------------
.proc DLIinterruptBFG
	pha
	lda dliCounter
	bne EndofBFGDLI
	lda dliColorsFore
	bit random
	bmi @+
	lda DliColorBack
@	sta COLPF2
	lda dliColorsFore
	bit random
	bmi @+
	lda DliColorBack
@	sta COLPF1
EndofBFGDLI
	inc dliCounter
    pla
    rti
.endp
; ------------------------
.proc BFGblink
	SetDLI DLIinterruptBFG	; blinking on
	ldy #50
	jsr PauseYFrames
	SetDLI DLIinterruptGraph	; blinking off
	rts
.endp
;--------------------------------------------------
    .IF * > MODUL-1
	  .ECHO *
      .ERROR 'Code and data too long'
    .ENDIF
    .ECHO "Bytes left: ",$b000-*
    
    
    org $b000                                    ;address of RMT module
MODUL                                            
                                                 ;RMT module is standard Atari binary file already
      ins "artwork/sfx/scorch_str9-NTSC.rmt",+6  ;include music RMT module
MODULEND
;----------------------------------------------
    icl 'constants_top.asm'
;----------------------------------------------
  
  .ECHO "Bytes on top left: ",$bfe8-* ;ROM_SETTINGS-*
  .IF target = 5200
    .IF * > ROM_SETTINGS-1
      .ERROR 'Code and RMT song too long to fit in 5200'
    .ENDIF
    org ROM_SETTINGS  ; 5200 ROM settings address $bfe8
    ;     "01234567890123456789"
    .byte " scorch 5200  v"    ;20 characters title
    build ;              "    "
    .byte                    " "
    .byte "7A"          ;2 characters year .. 1900 + $7A = 2020
    .word FirstSTART
  .ELSE
     run FirstSTART
  .ENDIF