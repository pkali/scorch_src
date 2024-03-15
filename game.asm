;   @com.wudsn.ide.asm.mainsourcefile=scorch.asm

.IF *>0 ;this is a trick that prevents compiling this file alone

; All main procedures of the game not dependent on hardware (I hope) :)

START
    jsr MakeDarkScreen
    ; Startup sequence
    jsr Initialize

    ;jsr GameOverScreen    ; only for test !!!

    RMTSong song_main_menu

    jsr Options  ;startup screen
    jsr SetVariablesFromOptions
    jsr MakeDarkScreen
    bit escFlag
    bpl @+
    jsr CheckStartKey ; START KEY
    bne START
    jmp StartAfterSplash    ; reset all game option if Start key pressed (and Esc)
@
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
    jsr MakeDarkScreen
    bit escFlag
    bmi START

    jsr GetRandomWind

    jsr RoundInit

    jsr MainRoundLoop
    mva #$ff MeteorsFlag
    bit escFlag
    jvs GoGameOver
    bmi START

    jsr CalculateGains

    jsr SortSequence

    mva #0 TankNr  ;
    sta COLBAKS        ; set background color to black
    jsr SetJoystickPort    ; set joystick port for player

    ; Hide all (easier than hide last ;) ) tanks
    jsr cleartanks    ; A=0

    ; here gains and losses should be displayed (dollars)
    ; finally we have changed our minds and money of players
    ; is displayed only in weapons shop

    ; Results are number of other deaths
    ; before the player dies itself

    RmtSong song_round_over
    jsr DisplayResults

    jsr DemoModeOrKey
    jsr MakeDarkScreen

    lda GameIsOver
    beq NoGameOverYet
GoGameOver
    jsr GameOverScreen
    jmp START
NoGameOverYet
    inc CurrentRoundNr
    mva #sfx_silencer sfx_effect

    jmp MainGameLoop

;--------------------------------------------------
.proc CalculateGains
;--------------------------------------------------
    ; add gains and substract losses
    ; gain is what player gets for lost energy of opponents
    ; energy lost by opponents is added during Round and
    ; little below in source, multiplied by 2 to get "dollars".
    ; By analogy, loss is energy that given player losses during
    ; each Round.
    ; Important! If player has 10 energy and gets a central hit
    ; from nuke that would take 90 energy points, his loss
    ; is 90, not 10
    ldx NumberOfPlayers
    dex
CalculateGainsLoop

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
    bne @+
    lda moneyL,x
    cmp loseL,x
@   bcs substractlose
zeromoney
    lda #0
    sta moneyL,x
    sta moneyH,x
    beq skipzeroing
substractlose
;    sec    ; C is allways set at this point
    lda moneyL,x
    sbc loseL,x
    sta moneyL,x
    lda moneyH,x
    sbc loseH,x
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
    bne @+
    lda EarnedMoneyL,x
    cmp loseL,x
@   bcs esubstractlose
ezeromoney
    lda #0
    sta EarnedMoneyL,x
    sta EarnedMoneyH,x
    beq eskipzeroing
esubstractlose
;    sec    ; C is allways set at this point
    lda EarnedMoneyL,x
    sbc loseL,x
    sta EarnedMoneyL,x
    lda EarnedMoneyH,x
    sbc loseH,x
    sta EarnedMoneyH,x
eskipzeroing

    dex
    jpl CalculateGainsLoop
    rts
.endp
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

    jsr SetPMWidthAndColors    ; A=0
    lda #0
    sta AfterBFGflag    ; reset BFG flag
    sta COLOR2    ; status line "off"
    sta COLOR1

    tax
@      sta singleRoundVars,x
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
      jsr MaxForceCalculate
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

; set mountain type if ...
    lda RandomMountains
    beq noRandomMountains
@   ldy RANDOM
    cpy #5
    bcs @-
    jsr SetVariablesFromOptions.setMountainsType
noRandomMountains

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

    jsr drawmountains ;draw them
    jsr drawtanks     ;finally draw tanks

    mva #$00 TankSequencePointer
    
    lda random
    ;lda #$00    ; allways
    sta MeteorsRound    ; Turns meteors on or off during the next round.

;---------round screen is ready---------
    mva #TextForegroundColor COLOR1    ; status line "on"
    rts
.endp

;--------------------------------------------------
.proc MainRoundLoop
; here we must check if by a chance there is only one
; tank with energy greater than 0 left
;--------------------------------------------------

    ldy #0  ; in Y - number of tanks with energy greater than zero
    sty ATRACT    ; reset atract mode
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
    lda Energy,x    ; only active players
    beq @+
    lda AutoDefenseFlag,x    ; with Auto Defence activated
    beq @+
    ; run auto defense for tank in X
    jsr AutoDefense
@   dex
    bpl CheckNextTankAD
    jsr DrawTanks    ; redraw tanks with new defences
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
    jsr RandomizeForce.LimitForce
    jsr PutTankNameOnScreen
;    jsr DisplayStatus    ; There is no need anymore, it is always after PutTankNameOnScreen
   
    lda MeteorsRound
    bmi @+
    ; A = 0
    sta MeteorsFlag
@    
    lda SkillTable,x
    beq ManualShooting

RoboTanks
    ; robotanks shoot here
    ; TankNr still in X
    jsr ArtificialIntelligence
    ; after calliing AI we allways have TankNr in X
    ;ldx TankNr
    jsr DisplayStatus    ; to make visible AI selected defensive (and offensive :) )
    jsr MoveBarrelToNewPosition
    jsr CheckExitKeys
    spl:rts        ; keys Esc or O


    jmp AfterManualShooting

ManualShooting
    lda JoyNumber,x
    jsr SetJoystickPort    ; set joystick port for player
    jsr WaitForKeyRelease
    lda #%00000000
    sta TestFlightFlag    ; set "Test Fight" off
    jsr BeforeFire
    bit escFlag
    spl:rts        ; keys Esc or O

AfterManualShooting
    ldy #$00
    sty plot4x4color
    dey
    sty MeteorsFlag ; $ff
    jsr DisplayTankNameAbove
    ; defensive weapons without flight handling
    ldx TankNr
    lda ActiveDefenceWeapon,x
    cmp #ind_Hovercraft
    beq GoFloat
    cmp #ind_White_Flag      ; White Flag
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
    jsr TankFlying.SoilDownAfterLanding  ; Soildown like after Hovercraf landing :)
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

;    ldx TankNr
    dec Energy,x   ; lower energy to eventually let tanks commit suicide

ShootNow
    lda ActiveWeapon,x
    cmp #ind_Buy_me ; BFG
    beq WeponNoFlight   ; but with explosion 
    cmp #ind_Punch   ; Punch
    beq WeponNoFlight   ; but with explosion 
    
    lda MeteorsRound
    bmi @+
    ; A = 0
    sta MeteorsFlag
@    
    jsr Shoot   ; bullet flight
    mva #$ff MeteorsFlag

    bit escFlag
    spl:rts        ; keys Esc or O

    lda HitFlag ;0 if missed
    beq missed
    bne GoExplosion
WeponNoFlight
    jsr NoShoot ; no bullet flight
GoExplosion
    jsr Explosion

continueMainRoundLoopAfterSeppuku
    mva #sfx_silencer sfx_effect

AfterExplode
    jsr SoilDown    ; allways
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

    ;here we clear offensive text (after a shoot) - is cleared !! :)
   ; ldy TankNr
   ; jsr DisplayOffensiveTextNr

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
    bne NotLastPlayerInRound
    mva #0 TankSequencePointer

    lda WindChangeInRound
    beq NoWindChangeNow
    jsr GetRandomWind    ; wind change after each turn (not round only)
NoWindChangeNow
NotLastPlayerInRound
    jmp MainRoundLoop
.endp

;---------------------------------
.proc PlayerXdeath
; this tank should not explode anymore:
; there is 0 in A, and Tank Number in X, so...
;---------------------------------

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

    lda #talk.VeryFunnyText    ; mumber of defensive text after BFG! ("VERY FUNNY.")
    bit AfterBFGflag    ; check BFG flag
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
    inc CurrentResult    ; ... but increase result of winner (BFG)
    ldy TankTempY
    lda #$ff
    jsr DisplayOffensiveTextNr.notZero
    ; tank flash
    ldy TankTempY
    mva TankNr temp2 ; not elegant, and probably unnecessary
    sty TankNr
    jsr FlashTank ; blinking and pausing (like PAUSE 72 - 18x(2+2) )
    mva temp2 TankNr

    ;Deffensive text cleanup
    ;here we clear Deffensive text (after a shoot)
    ldy TankTempY
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
    jsr ClearScreenSoilRange

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
@    lda skillTable,x
    cmp #2        ; clear variables only if Shooter
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
    scc
    inc loseH,x
    ; Energy now, not less than 0
    sec
    lda Energy,x
    sbc EnergyDecrease
    bcs NotNegativeEnergy
    ; if less than 0 then 0
    lda #0
NotNegativeEnergy
    sta Energy,x
    ;now increase the gain of the shooting tank
    ldy TankNr
    clc
    lda gainL,y
    adc EnergyDecrease
    sta gainL,y
    lda gainH,y
    adc #0
    sta gainH,y
    rts
.endp

;--------------------------------------------------
.proc DecreaseShieldEnergyX
; Decreases energy of shield player nr X by the value Y
; if shield energy is 0 after decrease then in Y we have
; rest of the energy - to decrease tank energy
;--------------------------------------------------
    sty EnergyDecrease
    ldy #0    ; if Shield survive then no decrease tank anergy
    ; Energy cannot be less than 0
    sec
    lda ShieldEnergy,x
    sbc EnergyDecrease
    bcs NotNegativeShieldEnergy
    ; now calculate rest of energy for future tank energy decrease
    sec
    lda EnergyDecrease
    sbc ShieldEnergy,x
    tay
    ; ShieldEnargy less than 0 then .. 0
    lda #0
NotNegativeShieldEnergy
    sta ShieldEnergy,x
    rts
.endp

;---------------------------------
.proc Seppuku
;---------------------------------
    lda #0
    ; get position of the tank
    ldx TankNr
;    lda #0  ; turn off defense weapons when hara-kiring
    sta ActiveDefenceWeapon,x
    sta ShieldEnergy,x
    jsr SetupXYdraw
    lda #ind_Missile  ; Missile
    jsr ExplosionDirect
    jmp MainRoundLoop.continueMainRoundLoopAfterSeppuku
.endp

;--------------------------------------------------
.proc GetRandomWind
;in: MaxWind (byte)
;out: Wind (word)
;uses: _
;--------------------------------------------------
    mva #$00 Wind+1
    sta Wind+2
    sta Wind+3
@   lda random
    sta Wind
    beq noWind    ; if 0 then nothing to do
    cmp MaxWind
    bcs @- ; if more than MaxWind then randomize again
    ; multiply Wind by 16
    ; two bytes of Wind are treated as a decimal part of vx variable
    :4 aslw Wind
    ; decide the direction
    lda random
    bmi noWindDirectionChange
      sec  ; Wind = -Wind
      .rept 2
        lda #$00
        sbc Wind+#
        sta Wind+#
      .endr
        lda #$ff
        sta Wind+2
        sta Wind+3
noWind
noWindDirectionChange
    rts
.endp
;--------------------------------------------------
.proc MaxForceCalculate
; calculates max force for tank (tanknr in X)
; Energy of tank X in A
;--------------------------------------------------
    sta L1
    lda #0
    ldy #9
    clc
CYK ror
    ror L1
    bcc NIE
    clc
    adc #10 ; multiplication by 10
NIE dey
    bne CYK
    sta MaxForceTableH,x
    lda L1
    sta MaxForceTableL,x
    rts
.endp

;--------------------------------------------------
.proc WeaponCleanup
; cleaning of the weapon possesion tables
; 99 of Baby Missles and White Flags, all other weapons=0)
;--------------------------------------------------
    ldx #(number_of_weapons - 1)
@    lda #$0
      cpx #ind_White_Flag       ; White Flag
      bne no99
set99 lda #99
no99
    .REPT MaxPlayers, #+1
      sta TanksWeapon:1,x
    .ENDR
      dex
      beq set99    ; Baby Missile (index=0)
    bpl @-
    rts
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
    tay
    mwa #variablesStart deletePtr
@     tya
      sta (deletePtr),y
      inw deletePtr
      cpw deletePtr #ClearedvariablesEnd
    bne @-
    tya
    jsr SetJoystickPort

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
    jsr SetPMWidthAndColors
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
; set standart barrel length and deactivate Auto Defense
; for all tanks
;--------------------------------------------------
    ldx #maxPlayers-1
@    lda #StandardBarrel    ; standard barrel length
    sta BarrelLength,x
    lda #$00    ; deactivate Auto Defense
    sta AutoDefenseFlag,x
    dex
    bpl @-
    rts
.endp
;----------------------------------------------
/* .proc RandomizeSequence0
    ldx #0
@     txa
      sta TankSequence,x
      inx
      cpx #MaxPlayers
    bne @-
    rts
.endp */
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

GetRandomAgainX
    txy ; destroy A!
    dey
    lda RANDOM
    cmp NumberOfPlayers
    bcs GetRandomAgainX
    cpx #0
    bne NotFirstSlot
    sta TankSequence,x ;now first slot is ready
    inx
    bne GetRandomAgainX
NotFirstSlot
    ;now we have to check if the value was not used
    ;in previous slots
UsageLoop
      cmp TankSequence,y
      beq GetRandomAgainX ;apparently we have already used this value
      dey
    bpl UsageLoop

    ;well, looks like this value is new!
    sta TankSequence,x
    inx

    cpx NumberOfPlayers
    bcc GetRandomAgainX
    rts
.endp
;----------------------------------------------
.proc RandomizeAngle
; routine returns in A
; a valid angle for the tank's barrel.
; X is not changed
;----------------------------------------------

    ; lets randomize someting between 0 and 180
    randomize 0 180
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
.proc Table2Force
;----------------------------------------------
    lda ForceTableL,x
    sta Force
    lda ForceTableH,x
    sta Force+1
    rts
.endp
;----------------------------------------------
.proc MoveBarrelToNewPosition
;----------------------------------------------
    mva #1 Erase
    jsr DrawTankNr.BarrelChange
MoveBarrel
    mva #sfx_set_power_2 sfx_effect
    jsr PutTankNr   ; and Erase = 0
    jsr DisplayStatus.displayAngle
    ;
    jsr CheckExitKeys
    spl:rts ;---Exit key pressed-quit game---
    ldx TankNr
    ;
    mva #1 Erase
    bit TestFlightFlag
    bmi AIaim
    jsr WaitOneFrame
AIaim
    jsr DrawTankNr.BarrelChange
    lda NewAngle
    cmp AngleTable,x
    beq BarrelPositionIsFine
    bcc rotateLeft
rotateRight            ; older is lower
    inc angleTable,x
    jmp MoveBarrel
rotateLeft            ; older is bigger
    dec angleTable,x
    jmp MoveBarrel
BarrelPositionIsFine
    jmp PutTankNr   ; and Erase = 0
    ; rts

.endp

;--------------------------------------------------
.proc DemoModeOrKey
; Waits for the key pressed if at least one human is playing.
; Otherwise, waits 3 seconds (demo mode).
;--------------------------------------------------
    ;check demo mode
    ldx numberOfPlayers
    dex
checkForHuman                  ; if all in skillTable other than 0 then switch to DEMO MODE
    lda skillTable,x
    beq peopleAreHere
    dex
    bpl checkForHuman
    ; no people, just wait a bit
    ldy #75
    jmp PauseYFrames
    ; rts
peopleAreHere
    jmp getkey  ; jsr:rts
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
; Results are in ResultsTable, in TankSequence (Sorted Table) we want to
; have numbers of tanks from the worst to the best.
; in other words, if ResultsTable=(5,4,65,23,3,6)
; the TankSequence=(4,1,0,5,3,2)
; let's assume initially the TankSequence=(0,1,2,3,4,5)

    ldx #0
SequenceStart
    txa
    sta TankSequence,x
    inx
    cpx #MaxPlayers
    bne SequenceStart

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

Bubble
    ldx #0 ;i=x
    stx temp2 ; sortflag=temp2
    inx ; because NumberOfPlayers start from 1 (not 0)

BubbleBobble
    ldy TankSequence-1,x    ; x count from 1 to NumberOfPlayers (we need cout from 0 to NumberOfPlayers-1)
    lda ResultsTable,y
    ldy TankSequence,x
    cmp ResultsTable,y
    bcc nextishigher
    bne swapvalues
nextisequal
    ; if results are equal, check Direct Hits
    ldy TankSequence-1,x
    lda DirectHits,y
    ldy TankSequence,x
    cmp DirectHits,y
    bcc nextishigher
    bne swapvalues
nextisequal2
    ; if results are equal, check money (H)
    ldy TankSequence-1,x
    lda EarnedMoneyH,y
    ldy TankSequence,x
    cmp EarnedMoneyH,y
    bcc nextishigher
    bne swapvalues
nextisequal2b
    ; if results are equal, check money (L)
    ldy TankSequence-1,x
    lda EarnedMoneyL,y
    ldy TankSequence,x
    cmp EarnedMoneyL,y
    ;
    beq nextishigher ; this is to block hangs when 2 equal values meet
    bcc nextishigher
    ;here we must swap values
    ;because next is smaller than previous
swapvalues
    lda TankSequence-1,x
    sta temp
    lda TankSequence,x
    sta TankSequence-1,x
    lda temp
    sta TankSequence,x
    inc temp2
nextishigher
    inx
    cpx NumberOfPlayers
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
; --------------------------------------
; Sets the appropriate variables based on the 'OptionsTable'
;
; this function returns:
; - 'NumberOfPlayers'
; - 'moneyL' and 'moneyH' (in arrays) for each player
; - 'gravity'
; - 'MaxWind'
; - 'RoundsInTheGame'
; - 'flyDelay'
; - 'seppukuVal'
; - 'mountainDeltaL' and 'mountainDeltaH'

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
setMountainsType
    lda mountainsDeltaTableH,y
    sta mountainDeltaH
    lda mountainsDeltaTableL,y
    sta mountainDeltaL

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

    ;sta decimal
    mwx #RoundNrDisplay displayposition
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

.IF VU_METER = 1
.proc VUMeter
    ; No VUMeter if key pressed
    jsr GetKeyFast
    cmp #@kbcode._none
    bne EndMeter
    ; check timer
    ; Atari 800 has 3 bytes clock, but 5200 only 2 bytes
    .IF TARGET = 800
    LDA RTCLOK+1
    .ELIF TARGET = 5200
    lda RTCLOK
    .ENDIF
    cmp #VuMeterTime
    bcc EndMeter
    ; Let's go!
    jsr ClearTanks
    ; store all angles
    ldx NumberOfPlayers
    dex
@   lda AngleTable,x
    sta previousAngle,x
    lda #0
    sta AngleTable,x
    dex
    bpl @-
    jsr DrawTanks
    ; let's go!
Meter
    mva #1 Erase
    jsr drawbarrels     ; clear barrels
    ldx NumberOfPlayers
@   txa
    and #%00000001
    tay
    lda trackn_audc+2,y
    :4 asl
    sta AngleTable,x
    dex
    bpl @-
    mva #0 Erase
    jsr drawbarrels     ; draw barrels
    jsr WaitOneFrame
    jsr GetKeyFast
    cmp #@kbcode._none
    beq Meter
    ; restore all angles
    jsr ClearTanks
    ldx NumberOfPlayers
    dex
@   lda previousAngle,x
    sta AngleTable,x
    dex
    bpl @-
    jsr drawtanks
    jsr drawtanknr
EndMeterAndReset
    lda #0
    ; only older byte
    .IF TARGET = 800
    sta RTCLOK+1
    .ELIF TARGET = 5200
    sta RTCLOK
    .ENDIF
EndMeter
    rts
;-----------
drawbarrels
    lda TankNr
    pha
    ldx NumberOfPlayers
    dex
    stx TankNr
DrawNextTank
    lda eXistenZ,x
    beq nobarrel ; if energy=0 then no tank
    jsr drawtanknr.BarrelChange
nobarrel
    dec TankNr
    ldx TankNr
    bpl DrawNextTank
    pla
    sta TankNr
    rts
.endp
.ENDIF


.ENDIF