;   @com.wudsn.ide.asm.mainsourcefile=scorch.asm

    .IF *>0 ;this is a trick that prevents compiling this file alone

; initial values for some variables
initialvaluesStart
I_OptionsTable .by 0,1,2,2,0,1,3,2
I_RoundsInTheGame .by 10 ;how many rounds in the current game
I_seppukuVal .by 75
I_mountainDeltaH .by 3
I_mountainDeltaL .by $ff
;----------------------------------------------------
; 4x4 text buffer
I_ResultLineBuffer
    dta d"                  ", $ff
I_LineHeader1
    dta d"# ROUND: "
I_RoundNrDisplay
    dta d"    #", $ff
initialvaluesCount = *-initialvaluesstart  ; MAX 128 bytes !
;===================================================================================
;==========================CONSTANT TABLES, do not erase!===========================
;===================================================================================
TankColoursTable        .BYTE $58,$2a,$96,$ca,$7a,$ed
;TankStatusColoursTable  .BYTE $54,$24,$92,$c4,$74,$e4	; standard order
;TanksPMOrder	.BYTE 4,3,1,5,0,2 ; 0-3 = P0-P3 , 4 = M0+M1 , 5 = M2+M3
TankStatusColoursTable  .BYTE $74,$c4,$24,$e4,$54,$94	; Adam's order
TanksPMOrder	.BYTE 4,3,1,5,0,2 ; 0-3 = P0-P3 , 4 = M0+M1 , 5 = M2+M3
TankShapesTable			.BYTE char_tank1___________,char_tank2___________,char_tank3___________
						.BYTE char_tank1___________,char_tank2___________,char_tank3___________
dliColorsBack
    :10 .by $02,$00
dliColorsFore
    .by $0a
CashOptionL ;(one zero less than on the screen)
    .by 0,<200,<800,<1200,<2000
CashOptionH   
    .by 0,>200,>800,>1200,>2000
GravityTable   .by 10,20,25,30,40
MaxWindTable   .by 5,20,40,70,99
RoundsTable    .by 10,20,30,40,50
AIForceTable	.wo 375,470,630,720,820	; starting shoot forces for different gravity
flyDelayTable  .by 255,150,75,35,1
seppukuTable   .by 255, 45,25,15,9
mountainsDeltaTableH .by 0,1,3,5,7
mountainsDeltaTableL .by $1f, $7f, $ff, $7f, $ff
;------------------------------------------------
LevelNameBeginL ; begins of level names
    .by <NamesOfLevels,<(NamesOfLevels+10),<(NamesOfLevels+20)
    .by <(NamesOfLevels+32),<(NamesOfLevels+42),<(NamesOfLevels+52)
    .by <(NamesOfLevels+64),<(NamesOfLevels+74),<(NamesOfLevels+84)
LevelNameBeginH
    .by >NamesOfLevels,>(NamesOfLevels+10),>(NamesOfLevels+20)
    .by >(NamesOfLevels+32),>(NamesOfLevels+42),>(NamesOfLevels+52)
    .by >(NamesOfLevels+64),>(NamesOfLevels+74),>(NamesOfLevels+84)
;--------------
TanksWeaponsTableL
    .by <TanksWeapon1,<TanksWeapon2,<TanksWeapon3,<TanksWeapon4,<TanksWeapon5,<TanksWeapon6
TanksWeaponsTableH
    .by >TanksWeapon1,>TanksWeapon2,>TanksWeapon3,>TanksWeapon4,>TanksWeapon5,>TanksWeapon6
;--------------
XtankOffsetGO_L
	.by 6,56,106,156,206,0
XtankOffsetGO_H
	.by 0,0,0,0,0,1
;-----4x4 texts-----
LineTop
    dta d"(%%%%%%%%%%%%)", $ff
;# - vertical, () * +, % - horizontal
LineBottom
    dta d"*%%%%%%%%%%%%+", $ff
LineEmpty
    dta d"#            #", $ff
LineHeader2
    dta d"#  RESULTS   #", $ff
LineGameOver
    dta d"# GAME  OVER #", $ff
seppukuText
    dta d"#  SEPPUKU!  #", $ff
areYouSureText
    dta d"# SURE?  Y/N #", $ff
lineClear
    dta d"              ", $ff

;-----------
pmtableL ; addressess of the P/M memory for 6 tanks
    .by <(pmgraph+$400)
    .by <(pmgraph+$500)
    .by <(pmgraph+$600)
    .by <(pmgraph+$700)
    .by <(pmgraph+$300)  ; this is a missile background
    .by <(pmgraph+$300)  ; this is a missile background
pmtableH
    .by >(pmgraph+$400)
    .by >(pmgraph+$500)
    .by >(pmgraph+$600)
    .by >(pmgraph+$700)
    .by >(pmgraph+$300)
    .by >(pmgraph+$300)
;-----------
sintable
    .by 0
    .by 4
    .by 8
    .by 13
    .by 17
    .by 22
    .by 26
    .by 31
    .by 35
    .by 40
    .by 44
    .by 48
    .by 53
    .by 57
    .by 61
    .by 66
    .by 70
    .by 74
    .by 79
    .by 83
    .by 87
    .by 91
    .by 95
    .by 100
    .by 104
    .by 108
    .by 112
    .by 116
    .by 120
    .by 124
    .by 128
    .by 131
    .by 135
    .by 139
    .by 143
    .by 146
    .by 150
    .by 154
    .by 157
    .by 161
    .by 164
    .by 167
    .by 171
    .by 174
    .by 177
    .by 181
    .by 184
    .by 187
    .by 190
    .by 193
    .by 196
    .by 198
    .by 201
    .by 204
    .by 207
    .by 209
    .by 212
    .by 214
    .by 217
    .by 219
    .by 221
    .by 223
    .by 226
    .by 228
    .by 230
    .by 232
    .by 233
    .by 235
    .by 237
    .by 238
    .by 240
    .by 242
    .by 243
    .by 244
    .by 246
    .by 247
    .by 248
    .by 249
    .by 250
    .by 251
    .by 252
    .by 252
    .by 253
    .by 254
    .by 254
    .by 255
    .by 255
    .by 255
    .by 255
    .by 255
    .by 255 ;anti self destruction byte

linetableL
    :screenheight+1 .by <(display+screenBytes*#)
linetableH
    :screenheight+1 .by >(display+screenBytes*#)
;----------------------------
bittable
    .by $80,$40,$20,$10,$08,$04,$02,$01
bittable2
    .by $7f,$bf,$df,$ef,$f7,$fb,$fd,$fe
;----------------------------
disktance ;tanks distance
    .by 0,0
    .by screenwidth/3
    .by screenwidth/4
    .by screenwidth/5
    .by screenwidth/6
    .by screenwidth/7
    ;max number of players=6

; this table is for deciding where a tank should slide
; accordingly to what is below the tank
; values in table mean that tank is moving to the left
SlideLeftTable
    .BY %00000001
    .BY %00000010
    .BY %00000011
    .BY %00000100
    .BY %00000101
    .BY %00000110
    .BY %00000111
    .BY %00001100

;-------------------------------------------------
TanksNamesDefault
    dta d"1st.Tank"
    dta d"2nd.Tank"
    dta d"3rd.Tank"
    dta d"4th.Tank"
    dta d"5th.Tank"
    dta d"6th.Tank"

WeaponPriceH ; weapons prices (tables with prices of weapons)
  .by >price_Baby_Missile___
  .by >price_Missile________
  .by >price_Baby_Nuke______
  .by >price_Nuke___________
  .by >price_LeapFrog_______
  .by >price_Funky_Bomb_____
  .by >price_MIRV___________
  .by >price_Death_s_Head___
  .by >price_Napalm_________
  .by >price_Hot_Napalm_____
  .by >price_Tracer_________
  .by >price_Smoke_Tracer___
  .by >price_Baby_Roller____
  .by >price_Roller_________
  .by >price_Heavy_Roller___
  .by >price_Riot_Charge____
  .by >price_Riot_Blast_____
  .by >price_Riot_Bomb______
  .by >price_Heavy_Riot_Bomb
  .by >price_Baby_Digger____
  .by >price_Digger_________
  .by >price_Heavy_Digger___
  .by >price_Baby_Sandhog___
  .by >price_Sandhog________
  .by >price_Heavy_Sandhog__
  .by >price_Dirt_Clod______
  .by >price_Dirt_Ball______
  .by >price_Ton_of_Dirt____
  .by >price_Liquid_Dirt____
  .by >price_Dirt_Charge____
  .by >price_Buy_me_________  
  .by >price_Plasma_Blast___
  .by >price_Laser__________
  .by >price______________33
  .by >price______________34
  .by >price______________35
  .by >price______________36
  .by >price______________37
  .by >price______________38
  .by >price______________39
  .by >price______________40
  .by >price______________41
  .by >price______________42
  .by >price______________43
  .by >price______________44
  .by >price______________45
  .by >price______________46
  .by >price______________47
  .by >price_White_Flag_____
  .by >price_Battery________
  .by >price_Bal_Guidance___
  .by >price_Horz_Guidance__
  .by >price_Floating_Tank__
  .by >price_Lazy_Boy_______
  .by >price_Parachute______
  .by >price_StrongParachute
  .by >price_Mag_Deflector__
  .by >price_Shield_________
  .by >price_Heavy_Shield___
  .by >price_Force_Shield___
  .by >price_Super_Mag______
  .by >price_Bouncy_Castle__
  .by >price_Long_Barrel____
  .by >price_Nuclear_Winter_

WeaponPriceL
  .by <price_Baby_Missile___
  .by <price_Missile________
  .by <price_Baby_Nuke______
  .by <price_Nuke___________
  .by <price_LeapFrog_______
  .by <price_Funky_Bomb_____
  .by <price_MIRV___________
  .by <price_Death_s_Head___
  .by <price_Napalm_________
  .by <price_Hot_Napalm_____
  .by <price_Tracer_________
  .by <price_Smoke_Tracer___
  .by <price_Baby_Roller____
  .by <price_Roller_________
  .by <price_Heavy_Roller___
  .by <price_Riot_Charge____
  .by <price_Riot_Blast_____
  .by <price_Riot_Bomb______
  .by <price_Heavy_Riot_Bomb
  .by <price_Baby_Digger____
  .by <price_Digger_________
  .by <price_Heavy_Digger___
  .by <price_Baby_Sandhog___
  .by <price_Sandhog________
  .by <price_Heavy_Sandhog__
  .by <price_Dirt_Clod______
  .by <price_Dirt_Ball______
  .by <price_Ton_of_Dirt____
  .by <price_Liquid_Dirt____
  .by <price_Dirt_Charge____
  .by <price_Buy_me_________
  .by <price_Plasma_Blast___
  .by <price_Laser__________
  .by <price______________33
  .by <price______________34
  .by <price______________35
  .by <price______________36
  .by <price______________37
  .by <price______________38
  .by <price______________39
  .by <price______________40
  .by <price______________41
  .by <price______________42
  .by <price______________43
  .by <price______________44
  .by <price______________45
  .by <price______________46
  .by <price______________47
  .by <price_White_Flag_____
  .by <price_Battery________
  .by <price_Bal_Guidance___
  .by <price_Horz_Guidance__
  .by <price_Floating_Tank__
  .by <price_Lazy_Boy_______
  .by <price_Parachute______
  .by <price_StrongParachute
  .by <price_Mag_Deflector__
  .by <price_Shield_________
  .by <price_Heavy_Shield___
  .by <price_Force_Shield___
  .by <price_Super_Mag______
  .by <price_Bouncy_Castle__
  .by <price_Long_Barrel____
  .by <price_Nuclear_Winter_

;-------------------------------------------------
; how many units (bulletd) of a given weapon we get for a given price
; This is a table of constans.
; If on a given position is 0 it means that this weapon
; is not present in the game.
; This is the slot for adding new weapons.
WeaponUnits
  .by 10 ;Baby_Missile___
  .by 5  ;Missile________
  .by 2  ;Baby_Nuke______
  .by 1  ;Nuke___________
  .by 2  ;LeapFrog_______
  .by 3  ;Funky_Bomb_____
  .by 2  ;MIRV___________
  .by 1  ;Death_s_Head___
  .by 4  ;Napalm_________
  .by 2  ;Hot_Napalm_____
  .by 20 ;Tracer_________
  .by 10 ;Smoke_Tracer___
  .by 5  ;Baby_Roller____
  .by 3  ;Roller_________
  .by 2  ;Heavy_Roller___
  .by 5  ;Riot_Charge____
  .by 2  ;Riot_Blast_____
  .by 5  ;Riot_Bomb______
  .by 2  ;Heavy_Riot_Bomb
  .by 10 ;Baby_Digger____
  .by 5  ;Digger_________
  .by 2  ;Heavy_Digger___
  .by 10 ;Baby_Sandhog___
  .by 5  ;Sandhog________
  .by 2  ;Heavy_Sandhog__
  .by 5 ;Dirt_Clod______
  .by 3  ;Dirt_Ball______
  .by 1  ;Ton_of_Dirt____
  .by 4  ;Liquid_Dirt____
  .by 2  ;Dirt_Charge____
  .by 1  ;Buy_me_________
  .by 0  ;Plasma_Blast___
  .by 5  ;Laser__________
  .by 0  ;_____________33
  .by 0  ;_____________34
  .by 0  ;_____________35
  .by 0  ;_____________36
  .by 0  ;_____________37
  .by 0  ;_____________38
  .by 0  ;_____________39
  .by 0  ;_____________40
  .by 0  ;_____________41
  .by 0  ;_____________42
  .by 0  ;_____________43
  .by 0  ;_____________44
  .by 0  ;_____________45
  .by 0  ;_____________46
  .by 0  ;_____________47
  .by 1  ;White_Flag___48
  .by 3  ;Battery________
  .by 0  ;Bal_Guidance___
  .by 0  ;Horz_Guidance__
  .by 5  ;Floating_Tank__
  .by 0  ;Lazy_Boy_______
  .by 3  ;Parachute______
  .by 2  ;StrongParachute
  .by 2  ;Mag_Deflector__
  .by 3  ;Shield_________
  .by 2  ;Heavy_Shield___
  .by 3  ;Force_Shield___
  .by 0  ;Super_Mag______
  .by 1  ;Auto_Defense___
  .by 2  ;Long_Barrel____
  .by 1  ;Nuclear_Winter_

PurchaseMeTable ;weapons good to be purchased by the robot 
                ;the comment is an index in the tables
	; "Baby Missile    ","Missile         ","Baby Nuke       ","Nuke            "
	; "LeapFrog        ","Funky Bomb      ","MIRV            ","Death's Head    "
	.by %01111111
	; "Napalm          ","Hot Napalm      ","Tracer          ","Smoke Tracer    "
	; "Baby Roller     ","Roller          ","Heavy Roller    ","Riot Charge     "
	.by %11001110
	; "Riot Blast      ","Riot Bomb       ","Heavy Riot Bomb ","Baby Digger     "
	; "Digger          ","Heavy Digger    ","Baby Sandhog    ","Sandhog         "
	.by %00000000
	; "Heavy Sandhog   ","Dirt Clod       ","Dirt Ball       ","Ton of Dirt     "
	; "Liquid Dirt     ","Dirt Charge     ","Buy me!         ","Plasma Blast    "
	.by %00000000
	; "Laser           "
	.by %00000000
	.by 0 ; offset to defensives
	; "White Flag      ","Battery         ","Bal Guidance    ","Horz Guidance   "
	; "Let's go!       ","Lazy Boy        ","Parachute       ","Strong Parachute"
	.by %01000011
	; "Mag Deflector   ","Shield          ","Heavy Shield    ","Force Shield    "
	; "Super Mag       ","Bouncy Castle   ","Long Barrel     ","Nuclear Winter  "
	.by %11110100
 
PurchaseMeTable2 ;weapons good to be purchased by the robot (Cyborg)
                ;the comment is an index in the tables
	; "Baby Missile    ","Missile         ","Baby Nuke       ","Nuke            "
	; "LeapFrog        ","Funky Bomb      ","MIRV            ","Death's Head    "
	.by %00110001
	; "Napalm          ","Hot Napalm      ","Tracer          ","Smoke Tracer    "
	; "Baby Roller     ","Roller          ","Heavy Roller    ","Riot Charge     "
	.by %01000000
	; "Riot Blast      ","Riot Bomb       ","Heavy Riot Bomb ","Baby Digger     "
	; "Digger          ","Heavy Digger    ","Baby Sandhog    ","Sandhog         "
	.by %00000000
	; "Heavy Sandhog   ","Dirt Clod       ","Dirt Ball       ","Ton of Dirt     "
	; "Liquid Dirt     ","Dirt Charge     ","Buy me!         ","Plasma Blast    "
	.by %00000000
	; "Laser           "
	.by %00000000
	.by 0 ; offset to defensives
	; "White Flag      ","Battery         ","Bal Guidance    ","Horz Guidance   "
	; "Let's go!       ","Lazy Boy        ","Parachute       ","Strong Parachute"
	.by %01000001
	; "Mag Deflector   ","Shield          ","Heavy Shield    ","Force Shield    "
	; "Super Mag       ","Bouncy Castle   ","Long Barrel     ","Nuclear Winter  "
	.by %10110100

;-------------------------------------------------
; Screen codes of icons (chars) representing a given weapon
WeaponSymbols
    .by $40,$41,$42,$43,$44,$45,$46,$47
    .by $48,$49,$4a,$4b,$4c,$4d,$4e,$4f
    .by $50,$51,$52,$53,$54,$55,$56,$57
    .by $58,$59,$5a,$5b,$60,$7b,$1f,$7d
    .by $20,$00,$00,$00,$00,$00,$00,$00
    .by $00,$00,$00,$00,$00,$00,$00,$00
    .by $5f,$1c,$03,$06,$1d,$0a,$1b,$1b  ; defensives
    .by $1e,$3b,$3d,$3c,$3e,$3f,$1d,$7d

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
    dta d"Buy me!         " ; 30
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
    dta d"                " ; 47 ; special (no weapon) name to simplify display

    dta d"White Flag      " ; 48 ($30)                                        
    dta d"Battery         " ; 49                                              
    dta d"Bal Guidance    " ; 50                                              
    dta d"Horz Guidance   " ; 51                                              
    dta d"Let's go!       " ; 52                                              
    dta d"Lazy Boy        " ; 53                            
    dta d"Parachute       " ; 54    - no energy         
    dta d"Strong Parachute" ; 55    - with energy  (earlier Battery)        
    dta d"Mag Deflector   " ; 56    - with shield and energy           
    dta d"Shield          " ; 57    - shield for one shot - no energy       
    dta d"Heavy Shield    " ; 58    - shield with energy          
    dta d"Force Shield    " ; 59    - shield with energy and parachute
    dta d"Super Mag       " ; 60               
    dta d"Bouncy Castle   " ; 61    - with shield and energy 
    dta d"Long Schlong    " ; 62                                              
    dta d"Nuclear Winter  " ; 63
DefensiveEnergy = * - 48
	.by 00	; White Flag
	.by 00	; Heat Guidance
	.by 00	; Bal Guidance
	.by 00	; Horz Guidance
	.by 00	; Let's go!
	.by 00	; Lazy Boy
	.by 00	; Parachute       
	.by 99	; Strong Parachute
	.by 99	; Mag Deflector
	.by 00	; Shield
	.by 99	; Heavy Shield
	.by 99	; Force Shield
	.by 00	; Super Mag
	.by 99	; Bouncy Castle
	.by 00	; Long Barrel
	.by 00	; Nuclear Winter
weaponsOfDeath
	dta 1,2,3,7,17,18,19,20,21,22,23,24,25,26,27
weaponsOfDeathEnd
joyToKeyTable
  ; .by  00, 01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15
    .by $ff,$ff,$ff,$ff,$ff,$ff,$ff,$07,$ff,$ff,$ff,$06,$ff,$0f,$0e,$ff

;-----------------------------------
keycodes ;tables for converting KeyCode to Screen Code (38 -1  characters)
    .by $3f,$15,$12,$3a,$2a,$38,$3d,$39
    .by $0d,$01,$05,$00,$25,$23,$08,$0a
    .by $2f,$28,$3e,$2d,$0b,$10,$2e,$16
    .by $2b,$17,$1f,$1e,$1a,$18,$1d,$1b
    .by $33,$35,$30,$32,$22,$21 ;,$0e <-- hyphen removed from the table, sorry hyphen lovers
keycodesEnd
scrcodes
    dta d"abcdefgh"
    dta d"ijklmnop"
    dta d"qrstuvwx"
    dta d"yz123456"
    dta d"7890. " ; "-"
;-----------------------------------
gameOverSpritesTop
    ; end of the Gover sprites by number of players
    ;    1   2   3   4   5   6
    .by 130,130,136,142,148,154
;-------decimal constans
zero
digits   dta d"0123456789"
nineplus dta d"9"+1
space    dta d" "
;------credits
CreditsStart
	dta d"         "*
	dta d"You were playin",d"g"*
	dta d"Scorc",d"h"*
	dta d"Warsaw, Miam",d"i"*
	dta d"2000-202",d"2"*
	dta d" "*
	dta d"B",d"y"*
	dta d" "*
	dta d"Programmin",d"g"*
	dta d"Tomasz 'Pecus' Peck",d"o"*
	dta d"Pawel 'pirx' Kalinowsk",d"i"*
	dta d" "*
	dta d"SFX, Music and Suppor",d"t"*
	dta d"Michal 'Miker' Szpilowsk",d"i"*
	dta d" "*
	dta d"Additional Musi",d"c"*
	dta d"Mario 'Emkay' Kri",d"x"*
	dta d" "*
	dta d"Code Optimizatio",d"n"*
	dta d"Piotr '0xF' Fusi",d"k"*
	dta d" "*
	dta d"Ar",d"t"*
	dta d"Adam Wachowsk",d"i"*
	dta d"Krzysztof 'Kaz' Ziembi",d"k"*
	dta d" "*
	dta d"Ideas and Q",d"A"*
	dta d"Bocianu, Probabilitydragon, EnderDude",d","*
	dta d"Beeblebrox, KrzysRog, lopezpb, Dracon",d","*
	dta d"brad-colbert, archon800, nowy80",d","*
	dta d"Shaggy the Atarian, RetroBorsuk, ZP",d"H"*
	dta d" "*
	dta d"Additional testin",d"g"*
	dta d"Arek Peck",d"o"*
	dta d"  "*
	dta d"Stay tuned for the FujiNet version",d"!"*
	dta d"         "*
CreditsEnd
CreditsLines=44
.endif
