;   @com.wudsn.ide.asm.mainsourcefile=scorch.asm

    .IF *>0 ;this is a trick that prevents compiling this file alone

; initial values for some variables
initialvaluesStart
I_OptionsTable .by 0,1,2,2,0,1,3,2,0
I_RoundsInTheGame .by 10 ;how many rounds in the current game
I_seppukuVal .by 75
I_mountainDeltaH .by 3
I_mountainDeltaL .by $ff
;----------------------------------------------------
I_LineHeader1
    dta d"# ROUND: "
I_RoundNrDisplay
    dta d"    #", $ff
initialvaluesCount = *-initialvaluesstart  ; MAX 128 bytes !
;===================================================================================
;==========================CONSTANT TABLES, do not erase!===========================
;===================================================================================

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
    dta d"(%%%%%%%%%%%%)"
;# - vertical, () * +, % - horizontal
LineBottom
    dta d"*%%%%%%%%%%%%+"
LineEmpty
    dta d"#            #"
LineHeader2
    dta d"#  RESULTS   #"
LineGameOver
    dta d"# GAME  OVER #"
seppukuText
    dta d"#  SEPPUKU!  #"
areYouSureText
    dta d"# SURE?  Y/N #"
lineClear
    dta d"              "

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
    .by 1
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

;linetableL
;    :screenheight+1 .by <(display+screenBytes*#)
;linetableH
;    :screenheight+1 .by >(display+screenBytes*#)
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
  .by >price_Laser__________
  .by >price_White_Flag_____
  .by >price_Battery________
  .by >price_Hovercraft_____
  .by >price_Parachute______
  .by >price_StrongParachute
  .by >price_Mag_Deflector__
  .by >price_Shield_________
  .by >price_Heavy_Shield___
  .by >price_Force_Shield___
  .by >price_Bouncy_Castle__
  .by >price_Long_Barrel____
  .by >price_Nuclear_Winter_
  .by >price_Lazy_Boy_______
  .by >price_Lazy_Darwin____
  .by >price_Auto_Defense___
  .by >price_Spy_Hard_______
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
  .by <price_Laser__________
  .by <price_White_Flag_____
  .by <price_Battery________
  .by <price_Hovercraft_____
  .by <price_Parachute______
  .by <price_StrongParachute
  .by <price_Mag_Deflector__
  .by <price_Shield_________
  .by <price_Heavy_Shield___
  .by <price_Force_Shield___
  .by <price_Bouncy_Castle__
  .by <price_Long_Barrel____
  .by <price_Nuclear_Winter_
  .by <price_Lazy_Boy_______
  .by <price_Lazy_Darwin____
  .by <price_Auto_Defense___
  .by <price_Spy_Hard_______

;-------------------------------------------------
; how many units (bulletd) of a given weapon we get for a given price
; This is a table of constans.
; If on a given position is 0 it means that this weapon
; is not present in the game.
; This is the slot for adding new weapons.
WeaponUnits
  .by 10 ;Baby_Missile___;_00
  .by 5  ;Missile________;_01
  .by 2  ;Baby_Nuke______;_02
  .by 1  ;Nuke___________;_03
  .by 2  ;LeapFrog_______;_04
  .by 3  ;Funky_Bomb_____;_05
  .by 2  ;MIRV___________;_06
  .by 1  ;Death_s_Head___;_07
  .by 4  ;Napalm_________;_08
  .by 2  ;Hot_Napalm_____;_09
  .by 20 ;Tracer_________;_10
  .by 10 ;Smoke_Tracer___;_11
  .by 5  ;Baby_Roller____;_12
  .by 3  ;Roller_________;_13
  .by 2  ;Heavy_Roller___;_14
  .by 5  ;Riot_Charge____;_15
  .by 2  ;Riot_Blast_____;_16
  .by 5  ;Riot_Bomb______;_17
  .by 2  ;Heavy_Riot_Bomb;_18
  .by 10 ;Baby_Digger____;_19
  .by 5  ;Digger_________;_20
  .by 2  ;Heavy_Digger___;_21
  .by 10 ;Baby_Sandhog___;_22
  .by 5  ;Sandhog________;_23
  .by 2  ;Heavy_Sandhog__;_24
  .by 5  ;Dirt_Clod______;_25
  .by 3  ;Dirt_Ball______;_26
  .by 1  ;Ton_of_Dirt____;_27
  .by 4  ;Liquid_Dirt____;_28
  .by 2  ;Dirt_Charge____;_29
  .by 1  ;Buy_me_________;_30
  .by 5  ;Laser__________;_31
  .by 1  ;White_Flag_____;_32
  .by 3  ;Battery________;_33
  .by 2  ;Floating_Tank__;_34
  .by 3  ;Parachute______;_35
  .by 2  ;StrongParachute;_36
  .by 2  ;Mag_Deflector__;_37
  .by 3  ;Shield_________;_38
  .by 2  ;Heavy_Shield___;_39
  .by 3  ;Force_Shield___;_40
  .by 1  ;Auto_Defense___;_41
  .by 2  ;Long_Barrel____;_42
  .by 1  ;Nuclear_Winter_;_43
  .by 2	 ;Lazy_Boy_______;_44
  .by 2  ;Lazy_Darwin____;_45
  .by 2  ;Auto_Defense___;_46
  .by 4  ;Spy_Hard_______;_47

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
	; "Liquid Dirt     ","Dirt Charge     ","Buy me!         ","Laser           "
	.by %00000000
	; "White Flag      ","Battery         ","Hovercraft      ","Parachute       "
    ; "Strong Parachute","Mag Deflector   ","Shield          ","Heavy Shield    "
    .by %01011111
	; "Force Shield    ","Bouncy Castle   ","Long Barrel     ","Nuclear Winter  "
	; "Lazy Boy        ","Lazy Darwin     ","Auto Defense    ","Spy Hard        "
	.by %11000000

PurchaseMeTable2 ;weapons good to be purchased by the robot (Cyborg)
                ;the comment is an index in the tables
    ; "Baby Missile    ","Missile         ","Baby Nuke       ","Nuke            "
    ; "LeapFrog        ","Funky Bomb      ","MIRV            ","Death's Head    "
    .by %01110000
    ; "Napalm          ","Hot Napalm      ","Tracer          ","Smoke Tracer    "
    ; "Baby Roller     ","Roller          ","Heavy Roller    ","Riot Charge     "
    .by %01000000
    ; "Riot Blast      ","Riot Bomb       ","Heavy Riot Bomb ","Baby Digger     "
    ; "Digger          ","Heavy Digger    ","Baby Sandhog    ","Sandhog         "
    .by %00000000
    ; "Heavy Sandhog   ","Dirt Clod       ","Dirt Ball       ","Ton of Dirt     "
    ; "Liquid Dirt     ","Dirt Charge     ","Buy me!         ","Laser           "
    .by %00000000
    ; "White Flag      ","Battery         ","Hovercraft      ","Parachute       "
    ; "Strong Parachute","Mag Deflector   ","Shield          ","Heavy Shield    "
    .by %01001101
    ; "Force Shield    ","Bouncy Castle   ","Long Barrel     ","Nuclear Winter  "
	; "Lazy Boy        ","Lazy Darwin     ","Auto Defense    ","Spy Hard        "
    .by %11000000

;-------------------------------------------------
; Screen codes of icons (chars) representing a given weapon
WeaponSymbols
    .by $40 ;ind_Baby_Missile___ ;_00
    .by $41 ;ind_Missile________ ;_01
    .by $42 ;ind_Baby_Nuke______ ;_02
    .by $43 ;ind_Nuke___________ ;_03
    .by $44 ;ind_LeapFrog_______ ;_04
    .by $45 ;ind_Funky_Bomb_____ ;_05
    .by $46 ;ind_MIRV___________ ;_06
    .by $47 ;ind_Death_s_Head___ ;_07
    .by $48 ;ind_Napalm_________ ;_08
    .by $49 ;ind_Hot_Napalm_____ ;_09
    .by $4a ;ind_Tracer_________ ;_10
    .by $4b ;ind_Smoke_Tracer___ ;_11
    .by $4c ;ind_Baby_Roller____ ;_12
    .by $4d ;ind_Roller_________ ;_13
    .by $4e ;ind_Heavy_Roller___ ;_14
    .by $4f ;ind_Riot_Charge____ ;_15
    .by $50 ;ind_Riot_Blast_____ ;_16
    .by $51 ;ind_Riot_Bomb______ ;_17
    .by $52 ;ind_Heavy_Riot_Bomb ;_18
    .by $53 ;ind_Baby_Digger____ ;_19
    .by $54 ;ind_Digger_________ ;_20
    .by $55 ;ind_Heavy_Digger___ ;_21
    .by $56 ;ind_Baby_Sandhog___ ;_22
    .by $57 ;ind_Sandhog________ ;_23
    .by $58 ;ind_Heavy_Sandhog__ ;_24
    .by $59 ;ind_Dirt_Clod______ ;_25
    .by $5a ;ind_Dirt_Ball______ ;_26
    .by $5b ;ind_Ton_of_Dirt____ ;_27
    .by $60 ;ind_Liquid_Dirt____ ;_28
    .by $7b ;ind_Dirt_Charge____ ;_29
    .by $1f ;ind_Buy_me_________ ;_30
    .by $20 ;ind_Laser__________ ;_31
    .by $5f ;ind_White_Flag_____ ;_32
    .by $1c ;ind_Battery________ ;_33
    .by $06 ;ind_Floating_Tank__ ;_34
    .by $1b ;ind_Parachute______ ;_35
    .by $1b ;ind_StrongParachute ;_36
    .by $1e ;ind_Mag_Deflector__ ;_37
    .by $3b ;ind_Shield_________ ;_38
    .by $3d ;ind_Heavy_Shield___ ;_39
    .by $3c ;ind_Force_Shield___ ;_40
    .by $3f ;ind_Bouncy_Castle__ ;_41
    .by $1d ;ind_Long_Barrel____ ;_42
    .by $7d ;ind_Nuclear_Winter_ ;_43
	.by $02 ;ind_Lazy_Boy_______ ;_44
	.by $03 ;ind_Lazy_Darwin____ ;_45
	.by $5e ;ind_Auto_Defense___ ;_46
	.by $7c ;ind_Spy_Hard_______ ;_47

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
    dta d"Best F...g Gifts" ; 30
    dta d"Laser           " ; 31
;------defensives
    dta d"White Flag      " ; 32                                        
    dta d"Battery         " ; 33                                              
    dta d"Hovercraft      " ; 34                                              
    dta d"Parachute       " ; 35    - no energy         
    dta d"Strong Parachute" ; 36    - with energy  (earlier Battery)        
    dta d"Mag Deflector   " ; 37    - with shield and energy           
    dta d"Shield          " ; 38    - shield for one shot - no energy       
    dta d"Heavy Shield    " ; 39    - shield with energy          
    dta d"Force Shield    " ; 40    - shield with energy and parachute
    dta d"Bouncy Castle   " ; 41    - with shield and energy 
    dta d"Long Schlong    " ; 42                                              
    dta d"Nuclear Winter  " ; 43
	dta d"Lazy Boy        " ; 44
	dta d"Lazy Darwin     " ; 45
	dta d"Auto Defense    " ; 46
	dta d"Spy Hard        " ; 47

DefensiveEnergy = *-(last_offensive_____ - first_offensive____ +1)  ; to fake the table for ALL weapons
	.by 00	; White Flag
	.by 00	; Heat Guidance
	.by 98	; Let's go!
	.by 00	; Parachute       
	.by 99	; Strong Parachute
	.by 99	; Mag Deflector
	.by 00	; Shield
	.by 99	; Heavy Shield
	.by 99	; Force Shield
	.by 99	; Bouncy Castle
	.by 00	; Long Barrel
	.by 00	; Nuclear Winter
	.by 00  ; Lazy Boy
	.by 00  ; Lazy Darwin
	.by 00  ; Auto Defense
	.by 00  ; Spy Hard
weaponsOfDeath  ; weapons used in tank death animations
	dta 1,2,3,7,17,18,19,20,21,22,23,24,25,26,27
weaponsOfDeathEnd
joyToKeyTable
    .by $ff  ;00
    .by $ff  ;01
    .by $ff  ;02
    .by $ff  ;03
    .by $ff  ;04
    .by $ff  ;05
    .by $ff  ;06
    .by @kbcode._right  ;07
    .by $ff  ;08
    .by $ff  ;09
    .by $ff  ;0a
    .by @kbcode._left  ;0b
    .by $ff  ;0c
    .by @kbcode._down  ;0d
    .by @kbcode._up  ;0e
    .by $ff  ;0f

;-----------------------------------
keycodes ;tables for converting KeyCode to Screen Code (38 -1  characters)
    .by $3f,$15,$12,$3a,$2a,$38,$3d,$39
    .by $0d,$01,$05,$00,$25,$23,$08,$0a
    .by $2f,$28,$3e,$2d,$0b,$10,$2e,$16
    .by $2b,$17
	.by $32,$1f,$1e,$1a,$18,$1d,$1b
    .by $33,$35,$30,$22,$21 ;,$0e <-- hyphen removed from the table, sorry hyphen lovers
keycodesEnd
scrcodes
    dta d"abcdefgh"
    dta d"ijklmnop"
    dta d"qrstuvwx"
    dta d"yz"
zero
digits	; decimal constans
	dta d"0123456"
    dta d"789. " ; "-"
;-------decimal constans
;zero
;digits   dta d"0123456789"

;-----------------------------------
gameOverSpritesTop
    ; end of the Gover sprites by number of players
    ;    1   2   3   4   5   6
    .by 130+7,130+7,136+7,142+7,148+7,154+7
;------credits
CreditsStart
	dta d"         "*
	dta d"You were playin",d"g"*
	dta d"Scorc",d"h"*
	dta d"Warsaw, Miam",d"i"*
	dta d"2000-202",d"2"*
	dta d" "*
	dta d"Programmin",d"g"*
	dta d"Tomasz 'Pecus' Peck",d"o"*
	dta d"Pawel 'pirx' Kalinowsk",d"i"*
	dta d" "*
	dta d"SFX, Music and Suppor",d"t"*
	dta d"Michal 'Miker' Szpilowsk",d"i"*
	dta d" "*
	.IF target != 5200
	  dta d"Additional Musi",d"c"*
	  dta d"Mario 'Emkay' Kri",d"x"*
	  dta d" "*
	.ENDIF
	dta d"Code Optimizatio",d"n"*
	dta d"Piotr '0xF' Fusi",d"k"*
	dta d" "*
	dta d"Ar",d"t"*
	dta d"Adam Wachowsk",d"i"*
	.IF target != 5200
	  dta d"Krzysztof 'Kaz' Ziembi",d"k"*
	.ENDIF
	dta d" "*
	dta d"Ideas, help and Q",d"A"*
	dta d"Bocianu, Probabilitydragon, EnderDude",d","*
	dta d"Beeblebrox, KrzysRog, lopezpb, Dracon",d","*
	dta d"brad-colbert, archon800, nowy80",d","*
	dta d"Shaggy the Atarian, RetroBorsuk, ZP",d"H"*
	.IF target = 5200
    dta d"x-usr(1536), Aking, JAC!, phaero",d"n"*
	.ENDIF
	dta d" "*
	dta d"Additional testin",d"g"*
	dta d"Arek and Alex Peck",d"o"*
	.IF target != 5200
	  dta d"  "*
	  dta d"Stay tuned for the FujiNet version",d"!"*
	.ENDIF
	dta d"         "*
CreditsEnd
.IF target = 5200
  CreditsLines=37
.ELSE
  CreditsLines=42  ; 34 in reality. add 7?
.ENDIF

.endif
