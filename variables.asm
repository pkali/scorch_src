;	@com.wudsn.ide.asm.mainsourcefile=scorch.asm

    .IF *>0 ;this is a trick that prevents compiling this file alone

;=====================================================
; most important non-zero page variables
; zero page variables are declared in program.s65 module
;=====================================================
NumberOfPlayers .byte 0  ;current number of players (counted from 1)
TankSequence :MaxPlayers .by 0 ;sequence of shooting during the Round
GameIsOver .byte 0 ; 1 - it was the last round in the game
;-----------------------------------
skilltable   ; computer controlled players' skills (1-8), 0 - human
    :MaxPlayers .by 0
;-----------------------------------
moneyH ;we place zero at the end of prices and money
    ;and have range from 0 to 99990 (not too much)
    ;money players have (maybe one more byte is needed?)
    :MaxPlayers .by 0
moneyL 
    :MaxPlayers .by 0
;-----------------------------------
gainH ;how much money player gets after the round
    ;it is gathered during the round basing on energy
    ;opponents loose after player's shoots
    :MaxPlayers .by 0
gainL
    :MaxPlayers .by 0
;-----------------------------------
looseH ;how much player looses after the round
    ;calculated from REAL energy loss
    ;(not only to zero energy)
    :MaxPlayers .by 0
looseL
    :MaxPlayers .by 0
;-----------------------------------
Energy
    :MaxPlayers .by 0
EnergyDecrease  .by 0
eXistenZ
    :MaxPlayers .by 0
LASTeXistenZ ; eXistenZ before shoot
    :MaxPlayers .by 0

ResultsTable ;the results in the gameeeeee
    :MaxPlayers .by 0
TempResults
    :MaxPlayers .by 0
CurrentResult
    .byte 0
;-----------------------------------
EnergyTableL ;shooting Force of the tank during the round
    :MaxPlayers .by 0
EnergyTableH
    :MaxPlayers .by 0  ;maxplayers=6
MaxEnergyTableL ;Energy of the tank during the round
    ;(limes superior force of the Shoot)
    :MaxPlayers .by 0 ;1000 is the default
MaxEnergyTableH
    :MaxPlayers .by 0
;-----------------------------------

AngleTable ;Angle of the barrel of each tank during the round
    :MaxPlayers .by (255-90)
NewAngle
    .by 0
;-----------------------------------

ActiveWeapon ;number of the selected weapon
    :MaxPlayers .by 0
;-----------------------------------

;format of the static point number used in the game
;  20203.5 = 128 : <20203 : >20203
;-----------------------------------

L1       .by 0 ; variable used in multiplications (by 10:)
gravity  .by 25 ;only the decimal part (1/10 = 25)
;-----------------------------------

Wind  .wo $0080 ;walue displayed on the screen
    ;multiplied by 16 (decimal part only)
;-----------------------------------
MaxWind   .byte $40 ;
WindOrientation  .byte 0 ;(0-right,1-left)
;-----------------------------------
Counter  .byte 0  ;temporary Counter for outside loops
HitFlag  .byte 0 ;1 when missile hit anything
;-----------------------------------
xtankstableL ;X positions of tanks (lower left point)
    :MaxPlayers .by 0
xtankstableH
    :MaxPlayers .by 0
ytankstable ;Y positions of tanks (lower left point)
    :MaxPlayers .by 0
LowResDistances ; coarse stank positions divided by 4 (to be in just one byte)
    :MaxPlayers .by 0
;-----------------------------------
keycodes ;tables for calculating KeyCode to Screen Code (38 -1  characters)
    .byte $3f,$15,$12,$3a,$2a,$38,$3d,$39
    .byte $0d,$01,$05,$00,$25,$23,$08,$0a
    .byte $2f,$28,$3e,$2d,$0b,$10,$2e,$16
    .byte $2b,$17,$1f,$1e,$1a,$18,$1d,$1b
    .byte $33,$35,$30,$32,$22 ;,$0e <-- hyphen removed from the table, sorry hyphen lovers
keycodesEnd
scrcodes
    dta d"abcdefgh"
    dta d"ijklmnop"
    dta d"qrstuvwx"
    dta d"yz123456"
    dta d"7890." ; "-"
;-----------------------------------
Erase    .byte 0 ; if 1 only mask of the character is printed
                 ; on the graphics screen. if 0 character is printed normally

;-----------------------------------
RangeLeft  .wo 0 ;range of the soil to be fallen down
RangeRight .wo 0 ;it is being set by all Explosions
;-----------------------------------
WeaponRangeLeft  .wo 0 ;Range of the Explosion of the given weapon
WeaponRangeRight .wo 0
;--------------------------------------------------
;--------------------------------------------------
;Variables used by the given subroutines
;moved to one place for easier
;compilation to e.g. cartridge
;--------------------------------------------------
;xroller
HowMuchToFall   .byte $FF
HeightRol .byte 0
;digger
digstartx .word 0
digstarty .word 0
diggery  .byte 0
DigLong  .byte 0
digtabxL :8 .by 0
digtabxH :8 .by 0
digtabyL :8 .by 0
digtabyH :8 .by 0
;sandhog
sandhogflag .byte 0 ; (0 digger, 8 sandhog)
;ofdirt
magic  .word 0 ; was tempor2, but it was not compiling!!! (bug in OMC65)
;draw
DrawJumpAddr .word 0
HowToDraw .byte 0
    ; bits here mean
    ; 0 - negative X (go up)
    ; 1 - negative Y (left)
    ; 2 - directional value > 1 (more than 45 degrees)
    ; if all 0 then standart routine
XHit  .word 0
YHit  .word 0
LineLength .word 0
;circle
radius .byte 0
xcircle .word 0
ycircle .byte 0
tempcir .word 0
;TankFalls
IfFallDown  .byte 0
PreviousFall  .byte 0
EndOfTheFallFlag  .byte 0   ; in case of the infinite fall
Parachute .byte 0 ; are you insured with parachute?
; -------------------------------------------------
;Flight
;variables for 5 missiles (used for mirv)
xtraj00   :5 .by 0
xtraj01   :5 .by 0
xtraj02   :5 .by 0
vx00   :5 .by 0
vx01   :5 .by 0
vx02   :5 .by 0
vx03   :5 .by 0
MirvDown :5 .by 0 ; is given missile down?
MirvMissileCounter .byte 0 ; missile Counter (mainly for X)
SmokeTracerFlag .byte 0 ; if Smoketracer
; -------------------------------------------------
;CheckCollisionWithTank
vx  .byte 0,0,0,0 ;two decimal bytes, two whole bytes (DC.BA)
vy  .byte 0,0,0,0
xtraj  .byte 0,0,0
ytraj  .byte 0,0,0
xtrajold .byte 0,0,0
ytrajold .byte 0,0,0
Angle  .byte 0
Force  .byte 0,0,0
Multiplier .byte 0,0,0
Multiplee .byte 0,0
Result  .byte 0,0,0
goleft  .byte 0 ;if 1 then flights left
;--------------------------------------------------
;SoilDown2
IsEndOfTheFallFlag .byte 0
; -------------------------------------------------
;unPlot
WhichUnPlot .byte 0
    ; max 5 concurrent unPlots
oldplotH :5 .by 0
oldplotL :5 .by 0
oldora  :5 .by 0
oldply  :5 .by 0
OldOraTemp .byte 0
FunkyBombCounter .byte 0
xtrajfb  .word 0
ytrajfb  .word 0
;
tracerflag .byte 0
; -------------------------------------------------
;TypeChar
mask1  :8 .by 0
mask2  :8 .by 0

char1  :8 .by 0
char2  :8 .by 0
color  .byte 1
ybit  .byte 0
tempbyte01 .byte 0
delta  .word 0
yfloat  .word 0
deltaX  .byte 0
UpNdown  .byte 0


temptankX .word 0
temptankNr .byte 0

; -------------------------------------------------
;Variables from textproc.s65
    ; tables with numbers of weapons on the right lists
    ; to be honest - I do not know at the moment what the above
    ; comment was supposed to mean...
NubersOfWeaponsL1
    :(8*5) .by $ff
NubersOfWeaponsL2
    :(8*2) .by $ff
; -------------------------------------------------

; variables storing amount of weapons on the first and second
; list and pointer position

HowManyOnTheList1
    .byte 0
HowManyOnTheList2
    .byte 0
PositionOnTheList ; pointer position on the list being displayed
    .byte 0
LastWeapon ; number of the last previously purchased weapon
    ; it is necessary when after purchase some weapon
    ; is removed from the list (because too expensive)
    ; and the cursor must be placed elsewhere

    .byte $ff
WhichList ; list currently on the screen
    ; (0-offensive, 1-defensive)
    .byte 0
OffsetDL1 ; offset of the list screen (how many lines)....
    .byte 0

; -------------------------------------------------
;Options
OptionsTable  .byte 0,0,2,2,0
OptionsY  .byte 0 ;vertical position of cursor on Options screen
maxoptions = 5  ;number of all options (4 in 0.01)
CashOptionH   ;(one zero less than on the screen)
    .byte 0,>200,>500,>800,>1000
CashOptionL
    .byte 0,<200,<500,<800,<1000
GravityTable   .byte 10,20,25,30,40
MaxWindTable   .byte 5,20,40,60,80
RoundsTable    .byte 10,20,30,40,50
RoundsInTheGame .byte 10 ;how many rounds in the current game
;------------------------------------------------

;mark the level
PositionInName ; cursor position in name of the player when name input
    .byte 0
DifficultyLevel ; Difficulty Level (human/cpu)
    .byte 0
LevelNameBeginL ; begins of level names
    .byte <NamesOfLevels,<(NamesOfLevels+10),<(NamesOfLevels+20)
    .byte <(NamesOfLevels+32),<(NamesOfLevels+42),<(NamesOfLevels+52)
    .byte <(NamesOfLevels+64),<(NamesOfLevels+74),<(NamesOfLevels+84)
LevelNameBeginH
    .byte >NamesOfLevels,>(NamesOfLevels+10),>(NamesOfLevels+20)
    .byte >(NamesOfLevels+32),>(NamesOfLevels+42),>(NamesOfLevels+52)
    .byte >(NamesOfLevels+64),>(NamesOfLevels+74),>(NamesOfLevels+84)
;-------------------------------------------------
;displaydecimal
decimal  .word 0
displayposition .word 0
decimalresult  dta d"0000"

;xmissile
ExplosionRadius .word 0  ;because when adding in xdraw it is double byte
;round
CurrentRoundNr .byte 0
FallDown1  .byte 0
FallDown2  .byte 0
;leapfrog
LeapFrogAngle  .byte 0
;laser
LaserCoordinate .word 0,0,0,0
TanksNames
    dta d"1st Tank"
    dta d"2nd Tank"
    dta d"3rd Tank"
    dta d"4th Tank"
    dta d"5th Tank"
    dta d"6th Tank"
; -------------------------------------------------
; Here go tables with weapons possesed by a given tank
; Index in the table means weapon type
; number entered means ammo for given weapon possessed (max 99)
; Let 0 be "baby missile"
; from $30 the defensive weapons begin
TanksWeapons
TanksWeapon1
    .by 99
    :63 .by 0
TanksWeapon2
    .by 99
    :63 .by 0
TanksWeapon3
    .by 99
    :63 .by 0
TanksWeapon4
    .by 99
    :63 .by 0
TanksWeapon5
    .by 99
    :63 .by 0
TanksWeapon6
    .by 99
    :63 .by 0
TanksWeaponsTableL
	.by <TanksWeapon1,<TanksWeapon2,<TanksWeapon3,<TanksWeapon4,<TanksWeapon5,<TanksWeapon6
TanksWeaponsTableH
	.by >TanksWeapon1,>TanksWeapon2,>TanksWeapon3,>TanksWeapon4,>TanksWeapon5,>TanksWeapon6

mountaintable ;table of mountains (size=screenwidth)
    :screenwidth .by 0
    .by 0 ; additional byte for fallout (sometimes 1 pixel)
mountaintable2 ;table of mountains (size=screenwidth)
    :screenwidth .by 0
    .by 0 ; additional byte for fallout (sometimes 1 pixel)
mountaintable3
    :screenwidth .by 0
    .by 0 ; additional byte for fallout (sometimes 1 pixel)
MountaintableEnd ;good for table clearing
;----------------------------------------------
TextPositionX .word 0
TextPositionY .byte 0
TextAddress .word 0
TextCounter .byte 0
TextNumberOff .byte 0
;--------------
TankTempY
    .byte 0
;----------------------------------------------
; 4x4 texts
;----------------------------------------------
LineAddress4x4
    .word 0
LineCharNr
    .byte 0
LineXdraw
    .word 0
LineYdraw
    .byte 0
LineTop
    dta d"(%%%%%%%%%%%)"
    .byte $ff
;# - vertical, () * +, % - horizontal
LineBottom
    dta d"*%%%%%%%%%%%+"
    .byte $ff
LineEmpty
    dta d"#           #"
    .byte $ff
LineHeader1
    dta d"# ROUND: "
RoundNrDisplay
    dta d"   #"
    .byte $ff
LineHeader2
    dta d"#  RESULTS  #"
    .byte $ff
LineGameOver
    dta d"# GAME OVER #"
    .byte $ff


;-----------
ResultLineBuffer
    dta d"                  "
    .byte $ff
ResultX
    .word 0
ResultY
    .byte 0
ResultOfTankNr
    .byte 0

;-----------
pmtableL ; addressess of the P/M memory for 5 tanks (6th is without P/M background)
    .byte <(pmgraph+$400)
    .byte <(pmgraph+$500)
    .byte <(pmgraph+$600)
    .byte <(pmgraph+$700)
    .byte <(pmgraph+$300)  ; this is a missile background
pmtableH
    .byte >(pmgraph+$400)
    .byte >(pmgraph+$500)
    .byte >(pmgraph+$600)
    .byte >(pmgraph+$700)
    .byte >(pmgraph+$300)
;-----------
; this table changes Angle to the appropriate tank character
BarrelTableL
    .byte $02,$02,$02,$02,$02,$02,$02,$02
    .byte $04,$04,$04,$04,$04,$04,$04,$04
    .byte $06,$06,$06,$06,$06,$06,$06,$06,$06
    .byte $08,$08,$08,$08,$08,$08,$08,$08
    .byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a
    .byte $0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c
    .byte $0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e
    .byte $10,$10,$10,$10,$10,$10,$10,$10
    .byte $12,$12,$12,$12,$12,$12,$12,$12,$12
    .byte $14,$14,$14,$14,$14,$14,$14,$14
    .byte $16,$16,$16,$16,$16,$16,$16,$16
BarrelTableR
    .byte $2c,$2c,$2c,$2c,$2c,$2c,$2c,$2c
    .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a
    .byte $28,$28,$28,$28,$28,$28,$28,$28,$28
    .byte $26,$26,$26,$26,$26,$26,$26,$26
    .byte $24,$24,$24,$24,$24,$24,$24,$24
    .byte $22,$22,$22,$22,$22,$22,$22,$22,$22
    .byte $20,$20,$20,$20,$20,$20,$20,$20
    .byte $1e,$1e,$1e,$1e,$1e,$1e,$1e,$1e
    .byte $1c,$1c,$1c,$1c,$1c,$1c,$1c,$1c,$1c
    .byte $1a,$1a,$1a,$1a,$1a,$1a,$1a,$1a
    .byte $18,$18,$18,$18,$18,$18,$18,$18

sintable
    .byte 0
    .byte 4
    .byte 8
    .byte 13
    .byte 17
    .byte 22
    .byte 26
    .byte 31
    .byte 35
    .byte 40
    .byte 44
    .byte 48
    .byte 53
    .byte 57
    .byte 61
    .byte 66
    .byte 70
    .byte 74
    .byte 79
    .byte 83
    .byte 87
    .byte 91
    .byte 95
    .byte 100
    .byte 104
    .byte 108
    .byte 112
    .byte 116
    .byte 120
    .byte 124
    .byte 128
    .byte 131
    .byte 135
    .byte 139
    .byte 143
    .byte 146
    .byte 150
    .byte 154
    .byte 157
    .byte 161
    .byte 164
    .byte 167
    .byte 171
    .byte 174
    .byte 177
    .byte 181
    .byte 184
    .byte 187
    .byte 190
    .byte 193
    .byte 196
    .byte 198
    .byte 201
    .byte 204
    .byte 207
    .byte 209
    .byte 212
    .byte 214
    .byte 217
    .byte 219
    .byte 221
    .byte 223
    .byte 226
    .byte 228
    .byte 230
    .byte 232
    .byte 233
    .byte 235
    .byte 237
    .byte 238
    .byte 240
    .byte 242
    .byte 243
    .byte 244
    .byte 246
    .byte 247
    .byte 248
    .byte 249
    .byte 250
    .byte 251
    .byte 252
    .byte 252
    .byte 253
    .byte 254
    .byte 254
    .byte 255
    .byte 255
    .byte 255
    .byte 255
    .byte 255
    .byte 255 ;anti self destruction byte

costable
    .byte 255 ;anti self destruction byte
    .byte 255
    .byte 255
    .byte 255
    .byte 255
    .byte 255
    .byte 254
    .byte 254
    .byte 253
    .byte 252
    .byte 252
    .byte 251
    .byte 250
    .byte 249
    .byte 248
    .byte 247
    .byte 246
    .byte 244
    .byte 243
    .byte 242
    .byte 240
    .byte 238
    .byte 237
    .byte 235
    .byte 233
    .byte 232
    .byte 230
    .byte 228
    .byte 226
    .byte 223
    .byte 221
    .byte 219
    .byte 217
    .byte 214
    .byte 212
    .byte 209
    .byte 207
    .byte 204
    .byte 201
    .byte 198
    .byte 196
    .byte 193
    .byte 190
    .byte 187
    .byte 184
    .byte 181
    .byte 177
    .byte 174
    .byte 171
    .byte 167
    .byte 164
    .byte 161
    .byte 157
    .byte 154
    .byte 150
    .byte 146
    .byte 143
    .byte 139
    .byte 135
    .byte 131
    .byte 128
    .byte 124
    .byte 120
    .byte 116
    .byte 112
    .byte 108
    .byte 104
    .byte 100
    .byte 95
    .byte 91
    .byte 87
    .byte 83
    .byte 79
    .byte 74
    .byte 70
    .byte 66
    .byte 61
    .byte 57
    .byte 53
    .byte 48
    .byte 44
    .byte 40
    .byte 35
    .byte 31
    .byte 26
    .byte 22
    .byte 17
    .byte 13
    .byte 8
    .byte 4
    .byte 0

linetableL
	:screenheight .by <(display+screenBytes*#)
	;:20 .by <(display+screenBytes*#)
	.by <PlotLine
linetableH
	:screenheight .by >(display+screenBytes*#)
	;:20 .by >(display+screenBytes*#)
	.by >PlotLine
;----------------------------
oldPlotPointerX
	.wo 0
;----------------------------
;PutChar4x4
LoopCounter4x4 .byte 0
y4x4 .byte 0
StoreA4x4 .byte 0
Xcounter4x4 .byte 0
nibbler4x4  .byte 0
CharCode4x4 .byte 0
plot4x4color .byte 0 ;1-white, 0-background

bittable
    .byte $80,$40,$20,$10,$08,$04,$02,$01
bittable2
    .byte $7f,$bf,$df,$ef,$f7,$fb,$fd,$fe
;----------------------------
disktance ;tanks distance
    .byte 0,0
    .byte screenwidth/3
    .byte screenwidth/4
    .byte screenwidth/5
    .byte screenwidth/6
    .byte screenwidth/7
    ;max number of players=6

; this table is for deciding where a tank should slide
; accordingly to what is below the tank
; there are 3 bits used here
; bit 0 - go down
; bit 1 - go left
; bit 2 - go right
; position in the table equals to bit pattern of soil below tank

WhereToSlideTable
    ; we have 3 bits: 0 - go down, 1 - go right, 2 - go left
    ;original table
    ;.BYTE 1,5,4,4,4,4,4,4,0,0,0,0,0,0,0,0
    ;.BYTE 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    ;.BYTE 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    ;.BYTE 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    ;.BYTE 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    ;.BYTE 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    ;.BYTE 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    ;.BYTE 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    ;.BYTE 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    ;.BYTE 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    ;.BYTE 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    ;.BYTE 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    ;.BYTE 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    ;.BYTE 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    ;.BYTE 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    ;.BYTE 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

    .BYTE 1,5,4,4,4,4,4,4,0,0,0,0,0,0,0,0 ;16
    .BYTE 4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;32
    .BYTE 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;48
    .BYTE 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;64
    .BYTE 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;80
    .BYTE 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;96
    .BYTE 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;112
    .BYTE 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;128
    .BYTE 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .BYTE 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .BYTE 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .BYTE 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .BYTE 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .BYTE 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .BYTE 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .BYTE 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

EndOfTheBarrelX
    .byte 4,4,4,4,4,4,4,4,4,4,4
    .byte 5,5,5,5,5,5,5,5,5,5
    .byte 6,6,6,6,6,6,6,6,6
    .byte 7,7,7,7,7,7,7,7,7,7,7,7,7,7,7
    .byte 7,7,7,7,7,7,7,7,7
    .byte 7,7,7,7,7,7,7,7,7,7
    .byte 7,7,7,7,7,7,7,7,7,7,7,7,7
    .byte 7,7,7,7,7,7,7,7,7,7,7,7,7,7

    .byte 0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0

    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 1,1,1,1,1,1,1,1,1
    .byte 2,2,2,2,2,2,2,2,2,2
    .byte 3,3,3,3,3,3,3,3,3,3,3

EndOfTheBarrelY
    .byte 7,7,7,7,7,7,7,7,7,7,7
    .byte 7,7,7,7,7,7,7,7,7,7
    .byte 7,7,7,7,7,7,7,7,7
    .byte 7,7,7,7,7,7,7,7,7,7,7,7,7,7,7
    .byte 6,6,6,6,6,6,6,6,6
    .byte 5,5,5,5,5,5,5,5,5,5
    .byte 4,4,4,4,4,4,4,4,4,4,4,4,4
    .byte 3,3,3,3,3,3,3,3,3,3,3,3,3,3

    .byte 0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0

    .byte 3,3,3,3,3,3,3,3,3,3,3,3,3,3
    .byte 4,4,4,4,4,4,4,4,4,4,4,4,4
    .byte 5,5,5,5,5,5,5,5,5,5
    .byte 6,6,6,6,6,6,6,6,6
    .byte 7,7,7,7,7,7,7,7,7,7,7,7,7,7,7
    .byte 7,7,7,7,7,7,7,7,7
    .byte 7,7,7,7,7,7,7,7,7,7
    .byte 7,7,7,7,7,7,7,7,7,7,7
;-------------------------------------------------

TanksNamesDefault
    dta d"1st Tank"
    dta d"2nd Tank"
    dta d"3rd Tank"
    dta d"4th Tank"
    dta d"5th Tank"
    dta d"6th Tank"

WeaponPriceH ; weapons prices (tables with prices of weapons)
    .byte $00,$00,$00,$00,$00,$01,$01,$01
    .byte $01,$01,$00,$01,$02,$02,$02,$01
    .byte $01,$01,$01,$01,$01,$00,$00,$00
    .byte $01,$00,$00,$00,$02,$02,$01,$01
    .byte $02,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,$04,0,0,0,0,0,0,0,0,0,0
WeaponPriceL
    .byte $00,$60,$6F,$90,$c0,$25,$c8,$51
    .byte $f0,$ff,$66,$23,$b1,$58,$50,$4A
    .byte $55,$71,$42,$50,$14,$fd,$da,$bf
    .byte $31,$68,$82,$ab,$12,$45,$ae,$12
    .byte $41,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,$4c,0,0,0,0,0,0,0,0,0,0
;-------------------------------------------------
; how many units (bulletd) of a given weapon we get for a given price
; This is a table of constans.
; If on a given position is 0 it means that this weapon
; is not present in the game.
; This is the slot for adding new weapons.
WeaponUnits
    .byte 10,5,3,1,2,2,3,1,10,2,20,10,10,5,2,10
    .byte 5,5,2,10,5,2,10,5,2,10,5,2,2,10,10,5
    .byte 5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 6,2,5,5,2,8,10,2,3,3,2,2,1,10,25,0

;-------------------------------------------------
; Screen codes of icons (chars) representing a given weapon
WeaponSymbols
    .byte $40,$41,$42,$43,$44,$45,$46,$47
    .byte $48,$49,$4a,$4b,$4c,$4d,$4e,$4f
    .byte $50,$51,$52,$53,$54,$55,$56,$57
    .byte $58,$59,$5a,$5b,$60,$7b,$7c,$7d
    .byte $20,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $02,$03,$06,$1d,$0a,$1b,$1c,$1e
    .byte $3b,$3c,$3d,$3e,$3f,$5e,$5f,$00

; Names of weapons (16 chars long)
NamesOfWeapons ;the comment is an index in the tables
    dta d"Baby Missile    " ; 0
    dta d"Missile         " ; 1
    dta d"Baby Nuke       " ; 2
    dta d"Nuke            " ; 3
    dta d"LeapFrog        " ; 4
    dta d"Funky Bomb      " ; 5
    dta d"MIRV            " ; 6
    dta d"Death's Head    " ; 7
    dta d"Napalm          " ; 8
    dta d"Hot Napalm      " ; 9
    dta d"Tracer          " ; 10
    dta d"Smoke Tracer    " ; 11
    dta d"Baby Roller     " ; 12
    dta d"Roller          " ; 13
    dta d"Heavy Roller    " ; 14
    dta d"Riot Charge     " ; 15
    dta d"Riot Blast      " ; 16
    dta d"Riot Bomb       " ; 17
    dta d"Heavy Riot Bomb " ; 18
    dta d"Baby Digger     " ; 19
    dta d"Digger          " ; 20
    dta d"Heavy Digger    " ; 21
    dta d"Baby Sandhog    " ; 22
    dta d"Sandhog         " ; 23
    dta d"Heavy Sandhog   " ; 24
    dta d"Dirt Clod       " ; 25
    dta d"Dirt Ball       " ; 26
    dta d"Ton of Dirt     " ; 27
    dta d"Liquid Dirt     " ; 28
    dta d"Dirt Charge     " ; 29
    dta d"Earth Disrupter " ; 30
    dta d"Plasma Blast    " ; 31
    dta d"Laser           " ; 32
    dta d"----------------" ; 33
    dta d"----------------" ; 34
    dta d"----------------" ; 35
    dta d"----------------" ; 36
    dta d"----------------" ; 37
    dta d"----------------" ; 38
    dta d"----------------" ; 39
    dta d"----------------" ; 40
    dta d"----------------" ; 41
    dta d"----------------" ; 42
    dta d"----------------" ; 43
    dta d"----------------" ; 44
    dta d"----------------" ; 45
    dta d"----------------" ; 46
    dta d"----------------" ; 47

    dta d"Heat Guidance   " ; 48 ($30)
    dta d"Bal Guidance    " ; 49
    dta d"Horz Guidance   " ; 50
    dta d"Vert Guidance   " ; 51
    dta d"Lazy Boy        " ; 52
    dta d"Parachute       " ; 53
    dta d"Battery         " ; 54
    dta d"Mag Deflector   " ; 55
    dta d"Shield          " ; 56
    dta d"Force Shield    " ; 57
    dta d"Heavy Shield    " ; 58
    dta d"Super Mag       " ; 59
    dta d"Auto Defense    " ; 60
    dta d"Fuel Tank       " ; 61
    dta d"Contact Trigger " ; 62
    dta d"----------------" ; 63
joyToKeyTable
  ; .by  00, 01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15
    .by $ff,$ff,$ff,$ff,$ff,$ff,$ff,$07,$ff,$ff,$ff,$06,$ff,$0f,$0e,$ff
previousAngle
	:MaxPlayers .by 0
previousEnergyL
	:MaxPlayers .by 0
previousLeftRange
	:MaxPlayers .by 0
previousEnergyH
	:MaxPlayers .by 0
previousRightAngle
	:MaxPlayers .by 0
RandBoundaryLow
	.wo 0
RandBoundaryHigh
	.wo 1024
AngleTablePointer
	.by 0


clearEnd

.endif

