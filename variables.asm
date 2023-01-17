;	@com.wudsn.ide.asm.mainsourcefile=scorch.asm

    .IF *>0 ;this is a trick that prevents compiling this file alone
;=====================================================
; most important non-zero page variables
; used by the given subroutines
; moved to one place for easier
; compilation to e.g. cartridge
; zero page variables are declared in program.s65 module
;=====================================================
OneTimeZeroVariables
OneTimeZeroVariablesCount = variablesToInitialize-OneTimeZeroVariables  ; MAX 128 bytes !
    .if OneTimeZeroVariablesCount > 127
        .error "OneTimeZeroVariablesCount too large, ",OneTimeZeroVariablesCount
    .endif

noMusic .ds 1 ;.by 0  ; 0 - play music, $ff - do not play music
noSfx   .ds 1 ;.by 0  ; 0 - play SFX, $ff - do not play SFX
;----------------------------------------------------
; Color table for Game Over Screen (created in a gameover routine)
	.ds 1 ;.by $00		; labels line color
GameOverColoursTable  .ds MaxPlayers; .BYTE $80,$40,$c4,$20,$c0,$e4
;----------------------------------------------------
TanksNames  ; DO NOT ZERO ON GAME RESTART - ticket #24
    ;:6 dta d"        "
    .ds 6*8
;----------------------------------------------------
skilltable   ; computer controlled players' skills (1-8), 0 - human (no cleaning, ticket #30)
    .DS MaxPlayers
;----------------------------------------------------
variablesToInitialize
;Options DO NOT ZERO ON RESTART GAME - ticket #27
OptionsTable .ds maxOptions ;.by 0,1,2,2,0,1,3,2,0
RoundsInTheGame .ds 1 ;.by 10 ;how many rounds in the current game
seppukuVal .ds 1 ;.by 75
mountainDeltaH .ds 1 ;.by 3
mountainDeltaL .ds 1 ;.by $ff
;----------------------------------------------------
LineHeader1
    .ds 9 ;dta d"# ROUND: "
RoundNrDisplay
    .ds 5 ;dta d"    #", $ff
; 4x4 text buffer
ResultLineBuffer
    .ds 14 ;dta d"                  ", $ff
linetableL  ; = PMGraph + $0300 - (screenHeight+1)*2
    .ds (screenHeight+1)
linetableH  ; = PMGraph + $0300 - (screenHeight+1)
    .ds (screenHeight+1)
DisplayCopyPurchase
    .ds (DisplayCopyPurchaseEnd - DisplayCopyPurchaseStart +1)
StatusBufferCopy
    .ds screenBytes*3
;=====================================================
variablesStart  ; zeroing starts here
;=====================================================
;isInventory .ds 1  ; 0 - purchase, $ff - inventory
;-------------- 
drawFunction .ds 1  ; 0 - plot, %10000000 - LineLength (N), %01000000 - DrawCheck (V)
;-------------- 
noDeathCounter .ds 1
;--------------
OptionsY  .ds 1 ;vertical position of cursor on Options screen
flyDelay .ds 1
;--------------
;NumberOfPlayers .DS 1  ;current number of players (counted from 1)
TankSequence .DS MaxPlayers ;sequence of shooting during the Round
GameIsOver .DS 1 ; 1 means it was the last round in the game
;----------------------------------------------------
moneyH ;we place zero at the end of prices and money
    ;and have range from 0 to 99990 (not too much)
    ;money players have (maybe one more byte is needed?)
    .DS MaxPlayers
moneyL
    .DS MaxPlayers
;----------------------------------------------------
gainH ;how much money player gets after the round
    ;it is gathered during the round basing on energy
    ;opponents lose after player's shoots
    .DS MaxPlayers
gainL
    .DS MaxPlayers
;----------------------------------------------------
loseH ;how much player looses after the round
    ;calculated from REAL energy loss
    ;(not only to zero energy)
    .DS MaxPlayers
loseL
    .DS MaxPlayers
;----------------------------------------------------
Energy
    .DS MaxPlayers
ShieldEnergy
    .DS MaxPlayers
EnergyDecrease  .DS 1
eXistenZ
    .DS MaxPlayers
LASTeXistenZ ; eXistenZ before shoot
    .DS MaxPlayers

ResultsTable ;the results in the gameeeeee
    .DS MaxPlayers
TempResults
    .DS MaxPlayers
DirectHitsH
    .DS MaxPlayers
DirectHitsL
    .DS MaxPlayers
EarnedMoneyH
    .DS MaxPlayers
EarnedMoneyL
    .DS MaxPlayers
;----------------------------------------------------
ForceTableL ;shooting Force of the tank during the round
    .DS MaxPlayers
ForceTableH
    .DS MaxPlayers  ;maxplayers=6
MaxForceTableL ;Energy of the tank during the round
    ;(limes superior force of the Shoot)
    .DS MaxPlayers ;1000 is the default
MaxForceTableH
    .DS MaxPlayers
;----------------------------------------------------
BarrelLength ;length of the tank barrel - dont forget to set it to 6 at round start!
    .DS MaxPlayers
ActiveWeapon ;number of the selected weapon
    .DS MaxPlayers
ActiveDefenceWeapon ;number of the activated defence weapon - 0 
    .DS MaxPlayers
AutoDefenseFlag ; 0 - not activated, >$7f - activated 
    .DS MaxPlayers
WeaponDepleted .DS 1  ; if 0 deactivate the weapon and switch to Baby Missile
;----------------------------------------------------

;format of the 3-byte static point number used in the game
;  20203.5 => 128 : <20203 : >20203
;----------------------------------------------------

;L1       .DS 1 ; variable used in multiplications (by 10:)
;gravity  .DS 1 ;only the decimal part (1/10 = 25)
;----------------------------------------------------

;Wind  .ds 4 ;format: 0000.hhll
            ;walue displayed on the screen is
            ;decimal portion divided by 16 (>>4)
;----------------------------------------------------
MaxWind   .ds 1 ;
WindOrientation  .DS 1 ;(0-right,1-left)
;----------------------------------------------------
;Counter  .DS 1  ;temporary Counter for outside loops
;HitFlag  .DS 1 ;$ff when missile hit ground, $00 when no hit, $01-$06 tank index+1 when hit tank
WallsType	.ds 1	; bits 6 and 7: 00 - none, 01 - bump, 10 - wrap, 11 - boxy
;----------------------------------------------------
xtankstableL ;X positions of tanks (lower left point)
    .DS MaxPlayers
xtankstableH
    .DS MaxPlayers
ytankstable ;Y positions of tanks (lower left point)
    .DS MaxPlayers
LowResDistances ; coarse tank positions divided by 4 (to be in just one byte)
    .DS MaxPlayers
JoyNumber	; Joystick port number (from 0 to 3)
	.DS MaxPlayers
TankShape	; Tank shape number (from 0 to 2)
	.DS MaxPlayers
;----------------------------------------------------
TargetTankNr	; Target tank index (for AI routines)
	.DS 1
SecondTryFlag	; For precise AI aiming
	.DS 1
SpyHardFlag	; >$7f - run SpyHard after inventory
	.DS 1
;----------------------------------------------------
;Erase    .DS 1 ; if 1 only mask of the character is printed
               ; on the graphics screen. if 0 character is printed normally

;----------------------------------------------------
;RangeLeft  .DS 2 ;range of the soil to be fallen down
;RangeRight .DS 2 ;it is being set by all Explosions
;----------------------------------------------------
WeaponRangeLeft  .DS 2 ;Range of the Explosion of the given weapon
WeaponRangeRight .DS 2
;----------------------------------------------------
;xroller
;HowMuchToFall   .ds 1
HeightRol .DS 1
;digger
;digstartx .DS 2
;digstarty .DS 2
diggery  .DS 1
DigLong  .DS 1
digtabxL .DS [8]
digtabxH .DS [8]
digtabyL .DS [8]
digtabyH .DS [8]
; liquiddirt
TempXfill .ds 2
FillCounter .ds 2
;sandhog
sandhogflag .DS 1 ; (0 digger, 8 sandhog)
;ofdirt
;magic  .DS 2 ; was tempor2, but it was not compiling!!! (bug in OMC65)
;draw
;HowToDraw .DS 1
    ; bits here mean
    ; 0 - negative X (go up)
    ; 1 - negative Y (left)
    ; 2 - directional value > 1 (more than 45 degrees)
    ; if all 0 then standart routine
;XHit  .DS 2
YHit  .DS 2
;LineLength .DS 2
;circle
;radius .DS 1
;xcircle .DS 2
;ycircle .DS 2
tempcir .DS 2
;TankFalls
FallingSoundBit .DS 1
PreviousFall  .DS 1
EndOfTheFallFlag  .DS 1   ; in case of the infinite fall
;Parachute .DS 1 ; are you insured with parachute?
;FloatingAlt	.DS 1	; floating tank altitude
FunkyWallFlag = FloatingAlt	; reuse this variable in different weapon (Funky Bomb)!
PreferHumansFlag = FloatingAlt ; second reuse in AI Aim proc
;----------------------------------------------------
;Flight
;variables for 5 missiles (used for mirv)
xtraj00   .DS [5]  ; 3 bytes of xtraj times 5. Lowest byte
xtraj01   .DS [5]  ; middle byte
xtraj02   .DS [5]  ; high byte
;vx00   .DS [5]  ; looks like it is not really used anywhere
vx01   .DS [5]
vx02   .DS [5]
vx03   .DS [5]
MirvDown .DS [5] ; is given missile down?
MirvMissileCounter .DS 1 ; missile Counter (mainly for X)
SmokeTracerFlag .DS 1 ; if Smoketracer
LaserFlag .DS 1 ; $ff if Laser
XposFlag .DS 1	; bullet positon X (0 - on screen , %1000000 - off-screen)
YposFlag .DS 1  ; bullet positon Y (0 - on screen , %1000000 - over the screen , %0100000 - under the screen)
;----------------------------------------------------
;CheckCollisionWithTank
;vx  .ds 4 ; 0,0,0,0 ;two decimal bytes, two whole bytes (DC.BA)
;vy  .ds 4 ;0,0,0,0
;xtraj  .ds 3 ; 0,0,0
;ytraj  .ds 3 ; 0,0,0
xtrajold .ds 3 ; 0,0,0
ytrajold .ds 3 ; 0,0,0
;Angle  .DS 1
;Force  .ds 3 ; 0,0,0
;Multiplier .ds 3 ; 0,0,0
Multiplee .ds 2 ; 0,0
;goleft  .DS 1 ;if 1 then flights left
;----------------------------------------------------
;unPlot
WhichUnPlot .DS 1
    ; max 5 concurrent unPlots
oldplotH .DS [5]
oldplotL .DS [5]
oldora  .DS [5]
oldply  .DS [5]
OldOraTemp .DS 1
xtrajfb  .DS 2
ytrajfb  .DS 2
;
;tracerflag .DS 1
;----------------------------------------------------
;TypeChar
mask1  .DS [8]
mask2  .DS [8]

char1  .DS [8]
char2  .DS [8]
;color  .DS 1
ybit  .DS 1
tempbyte01 .DS 1
;delta  .DS 2
yfloat  .DS 2
deltaX  .DS 1
UpNdown  .DS 1

temptankX .DS 2
temptankNr .DS 1
AfterBFGflag .DS 1

;----------------------------------------------------
;Variables from textproc.s65
    ; tables with indexes of weapons on the right lists
    ; OK (2022) so, L1 is list of offensive weapons, L2 - defensive
IndexesOfWeaponsL1
    .ds (last_offensive_____ - first_offensive____+1)
IndexesOfWeaponsL2
    .ds (last_defensive_____ - first_defensive____+1)
;----------------------------------------------------

; variables storing amount of weapons on the first and second
; list and pointer position

HowManyOnTheListOff
    .DS 1
HowManyOnTheListDef
    .DS 1
;PositionOnTheList ; pointer position on the list being displayed
;    .DS 1
LastWeapon 
    ; number of the last previously purchased weapon
    ; it is necessary when after purchase some weapon
    ; is removed from the list (because too expensive)
    ; and the cursor must be placed elsewhere
    .DS 1
WhichList ; list currently on the screen
    ; (0-offensive, %10000000 - defensive (check with bit:bmi for defensives)
    .DS 1
;OffsetDL1   .DS 1 ; offset of the list screen (how many lines)....


;----------------------------------------------------

;mark the level
PositionInName ; cursor position in name of the player when name input
    .DS 1
;DifficultyLevel .DS 1  ; Difficulty Level (human/cpu)

;----------------------------------------------------
;displaydecimal
;decimal  .DS 2
decimalresult  .DS 5

;xmissile
;ExplosionRadius .DS 2  ;because when adding in xdraw it is double byte
;round
CurrentRoundNr .DS 1
;FallDown2  .DS 1
;leapfrog
LeapFrogAngle  .DS 1
;laser
LaserCoordinate .DS 8 ; 2,2,2,2
;----------------------------------------------------
; Here go tables with weapons possesed by a given tank
; Index in the table means weapon type
; number entered means ammo for given weapon possessed (max 99)
; Let 0 be "baby missile"
; from $30 the defensive weapons begin
TanksWeapons
TanksWeapon1
    .DS [last_defensive_____ - first_offensive____ +1]
TanksWeapon2
    .DS [last_defensive_____ - first_offensive____ +1]
TanksWeapon3
    .DS [last_defensive_____ - first_offensive____ +1]
TanksWeapon4
    .DS [last_defensive_____ - first_offensive____ +1]
TanksWeapon5
    .DS [last_defensive_____ - first_offensive____ +1]
TanksWeapon6
    .DS [last_defensive_____ - first_offensive____ +1]

mountaintable ;table of mountains (size=screenwidth)
    .DS [screenwidth]
    .DS 1 ; additional byte for fallout (sometimes 1 pixel)
mountaintable2 ;table of mountains (size=screenwidth)
    .DS [screenwidth]
    .DS 1 ; additional byte for fallout (sometimes 1 pixel)
MountaintableEnd ;good for table clearing
;----------------------------------------------------
TextNumberOff .DS 1
;--------------
TankTempY
    .DS 1
;----------------------------------------------------
;-------------- single round variables --------------
;----------------------------------------------------
singleRoundVars
;-------------- 
;escFlag .ds 1   ; 0 - Esc or O not pressed, $80 - Esc pressed, $40 - O pressed
;-------------- 
CurrentResult
    .DS 1
;--------------
AngleTable ;Angle of the barrel of each tank during the round
    .DS MaxPlayers
EndOfTheBarrelX
    .ds 2
EndOfTheBarrelY
    .ds 1
;----------------------------------------------------
previousAngle
    .DS MaxPlayers
previousEnergyL
    .DS MaxPlayers
previousLeftRange
    .DS MaxPlayers
previousEnergyH
    .DS MaxPlayers
RandBoundaryLow
    .ds 2
RandBoundaryHigh
    .ds 2
AngleTablePointer
    .DS 1
singleRoundVarsEnd
;----------------------------------------------------
; 4x4 texts
;----------------------------------------------------
;LineAddress4x4  .DS 2
LineCharNr  .DS 1
;LineXdraw   .DS 2
;LineYdraw   .DS 1

;-----------
ResultOfTankNr
    .DS 1

;----------------------------------------------------
;PutChar4x4
;----------------------------------------------------
nibbler4x4  .DS 1
CharCode4x4 .DS 1
;plot4x4color .DS 1 ;1-white, 0-background
; This is moved from display.asm to be easier to relocate
ListOfWeapons
                       ;     0123456789012345678901234567890123456789
; :number_of_offensives dta d"                                "
  ;:32 dta d"                                "
    .ds 32*32
ListOfWeapons1End
ListOfDefensiveWeapons
; :number_of_defensives dta d"                                "
  ;:16 dta d"                                "
    .ds 16*32
ListOfDefensiveWeaponsEnd ;constant useful when clearing
track_variables
trackn_db   .ds TRACKS
trackn_hb   .ds TRACKS
trackn_idx  .ds TRACKS
trackn_pause    .ds TRACKS
trackn_note .ds TRACKS
trackn_volume   .ds TRACKS
trackn_distor   .ds TRACKS
trackn_shiftfrq .ds TRACKS
trackn_instrx2  .ds TRACKS
trackn_instrdb  .ds TRACKS
trackn_instrhb  .ds TRACKS
trackn_instridx .ds TRACKS
trackn_instrlen .ds TRACKS
trackn_instrlop .ds TRACKS
trackn_instrreachend    .ds TRACKS
trackn_volumeslidedepth .ds TRACKS
trackn_volumeslidevalue .ds TRACKS
trackn_effdelay         .ds TRACKS
trackn_effvibratoa      .ds TRACKS
trackn_effshift     .ds TRACKS
trackn_tabletypespeed .ds TRACKS
trackn_tablenote    .ds TRACKS
trackn_tablea       .ds TRACKS
trackn_tableend     .ds TRACKS
trackn_tablelop     .ds TRACKS
trackn_tablespeeda  .ds TRACKS
trackn_command      .ds TRACKS
trackn_filter       .ds TRACKS
trackn_audf .ds TRACKS
trackn_audc .ds TRACKS
trackn_audctl   .ds TRACKS
v_aspeed        .ds 1
track_endvariables

variablesEnd
;----------------------------------------------------

.endif
