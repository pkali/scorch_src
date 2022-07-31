;	@com.wudsn.ide.asm.mainsourcefile=scorch.asm

    .IF *>0 ;this is a trick that prevents compiling this file alone
;=====================================================
; most important non-zero page variables
; used by the given subroutines
; moved to one place for easier
; compilation to e.g. cartridge
; zero page variables are declared in program.s65 module
;=====================================================
TanksNames  ; DO NOT ZERO - ticket #24
    :6 dta d"        "
;----------------------------------------------------
;Options DO NOT ZERO - ticket #27
OptionsTable .by 0,1,2,2,0,1,3,2
RoundsInTheGame .by 10 ;how many rounds in the current game
seppukuVal .by 75
mountainDeltaH .by 3
mountainDeltaL .by $ff
;----------------------------------------------------
; Color table for Game Over Screen
	.by $00		; labels line color
GameOverColoursTable  .BYTE $80,$40,$c4,$20,$c0,$e4
;----------------------------------------------------
skilltable   ; computer controlled players' skills (1-8), 0 - human (no cleaning, ticket #30)
    .DS [MaxPlayers]
;----------------------------------------------------
noMusic .by 0  ; 0 - play music, $ff - do not play music
noSfx   .by 0  ; 0 - play SFX, $ff - do not play SFX
; 4x4 text buffer
ResultLineBuffer
    dta d"                  ", $ff
LineHeader1
    dta d"# ROUND: "
RoundNrDisplay
    dta d"    #", $ff

;=====================================================
variablesStart  ; zeroing starts here
;=====================================================
isInventory .ds 1  ; 0 - purchase, $ff - inventory
;-------------- 
drawFunction .ds 1  ; 0 - plot, %10000000 - LineLength (N), %01000000 - DrawCheck (V)
;-------------- 
sfx_effect .ds 1
;-------------- 
noDeathCounter .ds 1
;--------------
OptionsY  .ds 1 ;vertical position of cursor on Options screen
flyDelay .ds 1
;--------------
NumberOfPlayers .DS 1  ;current number of players (counted from 1)
TankSequence .DS [MaxPlayers] ;sequence of shooting during the Round
GameIsOver .DS 1 ; 1 means it was the last round in the game
;----------------------------------------------------
moneyH ;we place zero at the end of prices and money
    ;and have range from 0 to 99990 (not too much)
    ;money players have (maybe one more byte is needed?)
    .DS [MaxPlayers]
moneyL
    .DS [MaxPlayers]
;----------------------------------------------------
gainH ;how much money player gets after the round
    ;it is gathered during the round basing on energy
    ;opponents lose after player's shoots
    .DS [MaxPlayers]
gainL
    .DS [MaxPlayers]
;----------------------------------------------------
loseH ;how much player looses after the round
    ;calculated from REAL energy loss
    ;(not only to zero energy)
    .DS [MaxPlayers]
loseL
    .DS [MaxPlayers]
;----------------------------------------------------
Energy
    .DS [MaxPlayers]
ShieldEnergy
    .DS [MaxPlayers]
EnergyDecrease  .DS 1
eXistenZ
    .DS [MaxPlayers]
LASTeXistenZ ; eXistenZ before shoot
    .DS [MaxPlayers]

ResultsTable ;the results in the gameeeeee
    .DS [MaxPlayers]
TempResults
    .DS [MaxPlayers]
;----------------------------------------------------
ForceTableL ;shooting Force of the tank during the round
    .DS [MaxPlayers]
ForceTableH
    .DS [MaxPlayers]  ;maxplayers=6
MaxForceTableL ;Energy of the tank during the round
    ;(limes superior force of the Shoot)
    .DS [MaxPlayers] ;1000 is the default
MaxForceTableH
    .DS [MaxPlayers]
;----------------------------------------------------


ActiveWeapon ;number of the selected weapon
    .DS [MaxPlayers]
ActiveDefenceWeapon ;number of the activated defence weapon - 0 
    .DS [MaxPlayers]	
WeaponDepleted .DS 1  ; if 0 deactivate the weapon and switch to Baby Missile
;----------------------------------------------------

;format of the 3-byte static point number used in the game
;  20203.5 => 128 : <20203 : >20203
;----------------------------------------------------

L1       .DS 1 ; variable used in multiplications (by 10:)
gravity  .DS 1 ;only the decimal part (1/10 = 25)
;----------------------------------------------------

Wind  .ds 4 ;format: 0000.hhll
            ;walue displayed on the screen is
            ;decimal portion divided by 16 (>>4)
;----------------------------------------------------
MaxWind   .ds 1 ;
WindOrientation  .DS 1 ;(0-right,1-left)
;----------------------------------------------------
Counter  .DS 1  ;temporary Counter for outside loops
HitFlag  .DS 1 ;$ff when missile hit ground, $00 when no hit, $01-$06 tank index+1 when hit tank 
;----------------------------------------------------
xtankstableL ;X positions of tanks (lower left point)
    .DS [MaxPlayers]
xtankstableH
    .DS [MaxPlayers]
ytankstable ;Y positions of tanks (lower left point)
    .DS [MaxPlayers]
LowResDistances ; coarse tank positions divided by 4 (to be in just one byte)
    .DS [MaxPlayers]
;----------------------------------------------------
TargetTankNr	; Target tank index (for AI routines)
	.DS 1	
;----------------------------------------------------
Erase    .DS 1 ; if 1 only mask of the character is printed
               ; on the graphics screen. if 0 character is printed normally

;----------------------------------------------------
RangeLeft  .DS 2 ;range of the soil to be fallen down
RangeRight .DS 2 ;it is being set by all Explosions
;----------------------------------------------------
WeaponRangeLeft  .DS 2 ;Range of the Explosion of the given weapon
WeaponRangeRight .DS 2
;----------------------------------------------------
;xroller
HowMuchToFall   .ds 1
HeightRol .DS 1
;digger
digstartx .DS 2
digstarty .DS 2
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
magic  .DS 2 ; was tempor2, but it was not compiling!!! (bug in OMC65)
;draw
HowToDraw .DS 1
    ; bits here mean
    ; 0 - negative X (go up)
    ; 1 - negative Y (left)
    ; 2 - directional value > 1 (more than 45 degrees)
    ; if all 0 then standart routine
XHit  .DS 2
YHit  .DS 2
LineLength .DS 2
;circle
radius .DS 1
xcircle .DS 2
ycircle .DS 2
tempcir .DS 2
;TankFalls
FallingSoundBit .DS 1
PreviousFall  .DS 1
EndOfTheFallFlag  .DS 1   ; in case of the infinite fall
Parachute .DS 1 ; are you insured with parachute?
;----------------------------------------------------
;Flight
;variables for 5 missiles (used for mirv)
xtraj00   .DS [5]  ; 3 bytes of xtraj times 5. Lowest byte
xtraj01   .DS [5]  ; middle byte
xtraj02   .DS [5]  ; high byte
vx00   .DS [5]
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
vx  .ds 4 ; 0,0,0,0 ;two decimal bytes, two whole bytes (DC.BA)
vy  .ds 4 ;0,0,0,0
xtraj  .ds 3 ; 0,0,0
ytraj  .ds 3 ; 0,0,0
xtrajold .ds 3 ; 0,0,0
ytrajold .ds 3 ; 0,0,0
Angle  .DS 1
Force  .ds 3 ; 0,0,0
Multiplier .ds 3 ; 0,0,0
Multiplee .ds 2 ; 0,0
goleft  .DS 1 ;if 1 then flights left
;----------------------------------------------------
;unPlot
WhichUnPlot .DS 1
    ; max 5 concurrent unPlots
oldplotH .DS [5]
oldplotL .DS [5]
oldora  .DS [5]
oldply  .DS [5]
OldOraTemp .DS 1
FunkyBombCounter .DS 1
xtrajfb  .DS 2
ytrajfb  .DS 2
;
tracerflag .DS 1
;----------------------------------------------------
;TypeChar
mask1  .DS [8]
mask2  .DS [8]

char1  .DS [8]
char2  .DS [8]
color  .DS 1
ybit  .DS 1
tempbyte01 .DS 1
delta  .DS 2
yfloat  .DS 2
deltaX  .DS 1
UpNdown  .DS 1

temptankX .DS 2
temptankNr .DS 1

;----------------------------------------------------
;Variables from textproc.s65
    ; tables with indexes of weapons on the right lists
    ; OK (2022) so, L1 is list of offensive weapons, L2 - defensive
IndexesOfWeaponsL1
    .ds 8*5 ;  max 40 offensive weapons. this is wrong, should be 48, still only 32 defined.
IndexesOfWeaponsL2
    .ds 8*2 ;  max 16 defensive weapons. 
;----------------------------------------------------

; variables storing amount of weapons on the first and second
; list and pointer position

HowManyOnTheListOff
    .DS 1
HowManyOnTheListDef
    .DS 1
PositionOnTheList ; pointer position on the list being displayed
    .DS 1
LastWeapon 
    ; number of the last previously purchased weapon
    ; it is necessary when after purchase some weapon
    ; is removed from the list (because too expensive)
    ; and the cursor must be placed elsewhere
    .DS 1
WhichList ; list currently on the screen
    ; (0-offensive, 1-defensive)
    .DS 1
OffsetDL1 ; offset of the list screen (how many lines)....
    .DS 1

;----------------------------------------------------

;mark the level
PositionInName ; cursor position in name of the player when name input
    .DS 1
DifficultyLevel ; Difficulty Level (human/cpu)
    .DS 1
;----------------------------------------------------
;displaydecimal
decimal  .DS 2
decimalresult  .DS 4

;xmissile
ExplosionRadius .DS 2  ;because when adding in xdraw it is double byte
;round
CurrentRoundNr .DS 1
FallDown1  .DS 1
FallDown2  .DS 1
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
    .DS [64]
TanksWeapon2
    .DS [64]
TanksWeapon3
    .DS [64]
TanksWeapon4
    .DS [64]
TanksWeapon5
    .DS [64]
TanksWeapon6
    .DS [64]

mountaintable ;table of mountains (size=screenwidth)
    .DS [screenwidth]
    .DS 1 ; additional byte for fallout (sometimes 1 pixel)
mountaintable2 ;table of mountains (size=screenwidth)
    .DS [screenwidth]
    .DS 1 ; additional byte for fallout (sometimes 1 pixel)
MountaintableEnd ;good for table clearing
;----------------------------------------------------
TextPositionX .DS 2
TextPositionY .DS 1
TextAddress .DS 2
TextCounter .DS 1
TextNumberOff .DS 1
;--------------
TankTempY
    .DS 1
;----------------------------------------------------
;-------------- single round variables --------------
;----------------------------------------------------
singleRoundVars
;-------------- 
escFlag .ds 1
;-------------- 
CurrentResult
    .DS 1
;--------------
AngleTable ;Angle of the barrel of each tank during the round
    .DS [MaxPlayers]
NewAngle  ; used in AI
    .DS 1
;previousBarrelAngle
;    .DS [MaxPlayers]
EndOfTheBarrelX
    .ds 2
EndOfTheBarrelY
    .ds 1
;----------------------------------------------------
previousAngle
    .DS [MaxPlayers]
previousEnergyL
    .DS [MaxPlayers]
previousLeftRange
    .DS [MaxPlayers]
previousEnergyH
    .DS [MaxPlayers]
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
LineAddress4x4
    .DS 2
LineCharNr
    .DS 1
LineXdraw
    .DS 2
LineYdraw
    .DS 1

;-----------
ResultX
    .DS 2
ResultY
    .DS 1
ResultOfTankNr
    .DS 1

;----------------------------------------------------
;PutChar4x4
;----------------------------------------------------
LoopCounter4x4 .DS 1
y4x4 .DS 1
StoreA4x4 .DS 1
Xcounter4x4 .DS 1
nibbler4x4  .DS 1
CharCode4x4 .DS 1
plot4x4color .DS 1 ;1-white, 0-background



variablesEnd
;----------------------------------------------------

.endif
