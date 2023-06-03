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
    .REPT MaxPlayers, #+1
    .by <TanksWeapon:1
    .ENDR
TanksWeaponsTableH
    .REPT MaxPlayers, #+1
    .by >TanksWeapon:1
    .ENDR
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
    .IF TARGET = 800
        dta d"# SURE?  Y/N #"
    .ELIF TARGET = 5200
        dta d"#END? Y-1/N-0#"
    .ENDIF

lineClear
    dta d"              "

TankColoursTable        .BYTE $58,$2a,$96,$ca,$7a,$ed
;TankStatusColoursTable  .BYTE $54,$24,$92,$c4,$74,$e4  ; standard order
TankStatusColoursTable  .BYTE $74,$c4,$24,$e4,$54,$94   ; Adam's order
;-----------
GradientAddrL
    .by <dliColorsFore, <dliColorsFore, <dliColorsFore2
GradientAddrH
    .by >dliColorsFore, >dliColorsFore, >dliColorsFore2
dliColorsFore2        ; colors for NTSC
    .by $0a                                            ; one mountains color
    .by $7a,$7a,$7a,$6a,$6a,$5a,$5a,$4a,$4a,$3a
    .by $3a,$1a,$1a,$ea,$ea,$d8,$d8,$b8,$b8,$b8
dliColorsFore2PAL    ; colors for PAL
    .by $0a                                            ; one mountains color
    .by $7a,$7a,$7a,$6a,$6a,$5a,$5a,$4a,$4a,$3a
    .by $3a,$1a,$1a,$ea,$ea,$c8,$c8,$a8,$a8,$a8

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
.REPT MaxPlayers-1, #+3
    .by screenwidth/:1
.ENDR

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
;    .BY %00001100
SlideLeftTableLen = *-SlideLeftTable
;-------------------------------------------------
TankShapesTable         .BYTE char_tank1
                        .BYTE char_tank2
                        .BYTE char_tank3
                        .BYTE char_tank4
;-------------------------------------------------
WeaponPriceH ; weapons prices (tables with prices of weapons)
  .by >price_Baby_Missile
  .by >price_Missile
  .by >price_Baby_Nuke
  .by >price_Nuke
  .by >price_LeapFrog
  .by >price_Funky_Bomb
  .by >price_MIRV
  .by >price_Death_s_Head
  .by >price_Napalm
  .by >price_Hot_Napalm
  .by >price_Tracer
  .by >price_Smoke_Tracer
  .by >price_Baby_Roller
  .by >price_Roller
  .by >price_Heavy_Roller
  .by >price_Riot_Charge
  .by >price_Riot_Blast
  .by >price_Riot_Bomb
  .by >price_Heavy_Riot_Bomb
  .by >price_Baby_Digger
  .by >price_Digger
  .by >price_Heavy_Digger
  .by >price_Sandhog
  .by >price_Heavy_Sandhog
  .by >price_Dirt_Clod
  .by >price_Dirt_Ball
  .by >price_Ton_of_Dirt
  .by >price_Liquid_Dirt
  .by >price_Dirt_Charge
  .by >price_Punch
  .by >price_Buy_me
  .by >price_Laser
  .by >price_White_Flag
  .by >price_Battery
  .by >price_Hovercraft
  .by >price_Parachute
  .by >price_StrongParachute
  .by >price_Mag_Deflector
  .by >price_Shield
  .by >price_Heavy_Shield
  .by >price_Force_Shield
  .by >price_Bouncy_Castle
  .by >price_Long_Barrel
  .by >price_Nuclear_Winter_
  .by >price_Lazy_Boy
  .by >price_Lazy_Darwin
  .by >price_Auto_Defense
  .by >price_Spy_Hard
WeaponPriceL
  .by <price_Baby_Missile
  .by <price_Missile
  .by <price_Baby_Nuke
  .by <price_Nuke
  .by <price_LeapFrog
  .by <price_Funky_Bomb
  .by <price_MIRV
  .by <price_Death_s_Head
  .by <price_Napalm
  .by <price_Hot_Napalm
  .by <price_Tracer
  .by <price_Smoke_Tracer
  .by <price_Baby_Roller
  .by <price_Roller
  .by <price_Heavy_Roller
  .by <price_Riot_Charge
  .by <price_Riot_Blast
  .by <price_Riot_Bomb
  .by <price_Heavy_Riot_Bomb
  .by <price_Baby_Digger
  .by <price_Digger
  .by <price_Heavy_Digger
  .by <price_Sandhog
  .by <price_Heavy_Sandhog
  .by <price_Dirt_Clod
  .by <price_Dirt_Ball
  .by <price_Ton_of_Dirt
  .by <price_Liquid_Dirt
  .by <price_Dirt_Charge
  .by <price_Punch
  .by <price_Buy_me
  .by <price_Laser
  .by <price_White_Flag
  .by <price_Battery
  .by <price_Hovercraft
  .by <price_Parachute
  .by <price_StrongParachute
  .by <price_Mag_Deflector
  .by <price_Shield
  .by <price_Heavy_Shield
  .by <price_Force_Shield
  .by <price_Bouncy_Castle
  .by <price_Long_Barrel
  .by <price_Nuclear_Winter_
  .by <price_Lazy_Boy
  .by <price_Lazy_Darwin
  .by <price_Auto_Defense
  .by <price_Spy_Hard

;-------------------------------------------------
; how many units (bulletd) of a given weapon we get for a given price
; This is a table of constans.
; If on a given position is 0 it means that this weapon
; is not present in the game.
; This is the slot for adding new weapons.
WeaponUnits
  .by 10 ;Baby_Missile   ;_00
  .by 5  ;Missile        ;_01
  .by 2  ;Baby_Nuke      ;_02
  .by 1  ;Nuke           ;_03
  .by 2  ;LeapFrog       ;_04
  .by 3  ;Funky_Bomb     ;_05
  .by 2  ;MIRV           ;_06
  .by 1  ;Death_s_Head   ;_07
  .by 4  ;Napalm         ;_08
  .by 2  ;Hot_Napalm     ;_09
  .by 20 ;Tracer         ;_10
  .by 10 ;Smoke_Tracer   ;_11
  .by 5  ;Baby_Roller    ;_12
  .by 3  ;Roller         ;_13
  .by 2  ;Heavy_Roller   ;_14
  .by 5  ;Riot_Charge    ;_15
  .by 2  ;Riot_Blast     ;_16
  .by 5  ;Riot_Bomb      ;_17
  .by 2  ;Heavy_Riot_Bomb;_18
  .by 10 ;Baby_Digger    ;_19
  .by 5  ;Digger         ;_20
  .by 2  ;Heavy_Digger   ;_21
  .by 5  ;Sandhog        ;_22
  .by 2  ;Heavy_Sandhog  ;_23
  .by 5  ;Dirt_Clod      ;_24
  .by 3  ;Dirt_Ball      ;_25
  .by 1  ;Ton_of_Dirt    ;_26
  .by 4  ;Liquid_Dirt    ;_27
  .by 2  ;Dirt_Charge    ;_28
  .by 2  ;Punch          ;_29
  .by 1  ;Buy_me         ;_30
  .by 5  ;Laser          ;_31
  .by 1  ;White_Flag     ;_32
  .by 3  ;Battery        ;_33
  .by 2  ;Floating_Tank  ;_34
  .by 3  ;Parachute      ;_35
  .by 2  ;StrongParachute;_36
  .by 2  ;Mag_Deflector  ;_37
  .by 3  ;Shield         ;_38
  .by 2  ;Heavy_Shield   ;_39
  .by 3  ;Force_Shield   ;_40
  .by 1  ;Auto_Defense   ;_41
  .by 2  ;Long_Barrel    ;_42
  .by 1  ;Nuclear_Winter_;_43
  .by 2  ;Lazy_Boy       ;_44
  .by 2  ;Lazy_Darwin    ;_45
  .by 2  ;Auto_Defense   ;_46
  .by 4  ;Spy_Hard       ;_47

PurchaseMeTable ;weapons good to be purchased by the robot
                ;the comment is an index in the tables
    ; "Baby Missile    ","Missile         ","Baby Nuke       ","Nuke            "
    ; "LeapFrog        ","Funky Bomb      ","MIRV            ","Death's Head    "
    .by %01111111
    ; "Napalm          ","Hot Napalm      ","Tracer          ","Smoke Tracer    "
    ; "Baby Roller     ","Roller          ","Heavy Roller    ","Riot Charge     "
    .by %11001110
    ; "Riot Blast      ","Riot Bomb       ","Heavy Riot Bomb ","Baby Digger     "
    ; "Digger          ","Heavy Digger    ","Sandhog         ","Heavy Sandhog   "
    .by %00000000
    ; "Dirt Clod       ","Dirt Ball       ","Ton of Dirt     ","Liquid Dirt     "
    ; "Dirt Charge     ","Punch           ","Buy me!         ","Laser           "
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
    ; "Digger          ","Heavy Digger    ","Sandhog         ","Heavy Sandhog   "
    .by %00000000
    ; "Dirt Clod       ","Dirt Ball       ","Ton of Dirt     ","Liquid Dirt     "
    ; "Dirt Charge     ","Punch           ","Buy me!         ","Laser           "
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
    .by $40 ;ind_Baby_Missile    ;_00
    .by $41 ;ind_Missile         ;_01
    .by $42 ;ind_Baby_Nuke       ;_02
    .by $43 ;ind_Nuke            ;_03
    .by $44 ;ind_LeapFrog        ;_04
    .by $45 ;ind_Funky_Bomb      ;_05
    .by $46 ;ind_MIRV            ;_06
    .by $47 ;ind_Death_s_Head    ;_07
    .by $48 ;ind_Napalm          ;_08
    .by $49 ;ind_Hot_Napalm      ;_09
    .by $4a ;ind_Tracer          ;_10
    .by $4b ;ind_Smoke_Tracer    ;_11
    .by $4c ;ind_Baby_Roller     ;_12
    .by $4d ;ind_Roller          ;_13
    .by $4e ;ind_Heavy_Roller    ;_14
    .by $4f ;ind_Riot_Charge     ;_15
    .by $50 ;ind_Riot_Blast      ;_16
    .by $51 ;ind_Riot_Bomb       ;_17
    .by $52 ;ind_Heavy_Riot_Bomb ;_18
    .by $53 ;ind_Baby_Digger     ;_19
    .by $54 ;ind_Digger          ;_20
    .by $55 ;ind_Heavy_Digger    ;_21
    .by $57 ;ind_Sandhog         ;_22
    .by $58 ;ind_Heavy_Sandhog   ;_23
    .by $59 ;ind_Dirt_Clod       ;_24
    .by $5a ;ind_Dirt_Ball       ;_25
    .by $5b ;ind_Ton_of_Dirt     ;_26
    .by $60 ;ind_Liquid_Dirt     ;_27
    .by $7b ;ind_Dirt_Charge     ;_28
    .by $56 ;ind_Punch           ;_29
    .by $1f ;ind_Buy_me          ;_30
    .by $20 ;ind_Laser           ;_31
    .by $5f ;ind_White_Flag      ;_32
    .by $1c ;ind_Battery         ;_33
    .by $06 ;ind_Floating_Tank   ;_34
    .by $1b ;ind_Parachute       ;_35
    .by $1b ;ind_StrongParachute ;_36
    .by $1e ;ind_Mag_Deflector   ;_37
    .by $3b ;ind_Shield          ;_38
    .by $3d ;ind_Heavy_Shield    ;_39
    .by $3c ;ind_Force_Shield    ;_40
    .by $3f ;ind_Bouncy_Castle   ;_41
    .by $1d ;ind_Long_Barrel     ;_42
    .by $7d ;ind_Nuclear_Winter_ ;_43
    .by $02 ;ind_Lazy_Boy        ;_44
    .by $03 ;ind_Lazy_Darwin     ;_45
    .by $5e ;ind_Auto_Defense    ;_46
    .by $7c ;ind_Spy_Hard        ;_47

; Names of weapons (max 16 chars long)
NamesOfWeapons ;the comment is an index in the tables
    dta d"Baby Missil", d"e"*     ; 0
    dta d"Missil", d"e"*          ; 1
    dta d"Baby Nuk", d"e"*        ; 2
    dta d"Nuk", d"e"*             ; 3
    dta d"LeapFro", d"g"*         ; 4
    dta d"Funky Bom", d"b"*       ; 5
    dta d"MIR", d"V"*             ; 6
    dta d"Death's Hea", d"d"*     ; 7
    dta d"Napal", d"m"*           ; 8
    dta d"Hot Napal", d"m"*       ; 9
    dta d"Trace", d"r"*           ; 10
    dta d"Smoke Trace", d"r"*     ; 11
    dta d"Baby Rolle", d"r"*      ; 12
    dta d"Rolle", d"r"*           ; 13
    dta d"Heavy Rolle", d"r"*     ; 14
    dta d"Riot Charg", d"e"*      ; 15
    dta d"Riot Blas", d"t"*       ; 16
    dta d"Riot Bom", d"b"*        ; 17
    dta d"Heavy Riot Bom", d"b"*  ; 18
    dta d"Baby Digge", d"r"*      ; 19
    dta d"Digge", d"r"*           ; 20
    dta d"Heavy Digge", d"r"*     ; 21
    dta d"Sandho", d"g"*          ; 22
    dta d"Heavy Sandho", d"g"*    ; 23
    dta d"Dirt Clo", d"d"*        ; 24
    dta d"Dirt Bal", d"l"*        ; 25
    dta d"Ton of Dir", d"t"*      ; 26
    dta d"Liquid Dir", d"t"*      ; 27
    dta d"Dirt Charg", d"e"*      ; 28
    dta d"Stom", d"p"*            ; 29
    dta d"Best F...g Gift", d"s"* ; 30
    dta d"Lase", d"r"*            ; 31
;------defensives
    dta d"White Fla", d"g"*       ; 32
    dta d"Batter", d"y"*          ; 33
    dta d"Hovercraf", d"t"*       ; 34
    dta d"Parachut", d"e"*        ; 35    - no energy
    dta d"Strong Parachut", d"e"* ; 36    - with energy  (earlier Battery)
    dta d"Mag Deflecto", d"r"*    ; 37    - with shield and energy
    dta d"Shiel", d"d"*           ; 38    - shield for one shot - no energy
    dta d"Heavy Shiel", d"d"*     ; 39    - shield with energy
    dta d"Force Shiel", d"d"*     ; 40    - shield with energy and parachute
    dta d"Bouncy Castl", d"e"*    ; 41    - with shield and energy
    dta d"Long Schlon", d"g"*     ; 42
    dta d"Nuclear Winte", d"r"*   ; 43
    dta d"Lazy Bo", d"y"*         ; 44
    dta d"Lazy Darwi", d"n"*      ; 45
    dta d"Auto Defens", d"e"*     ; 46
    dta d"Spy Har", d"d"*         ; 47

DefensiveEnergy = *-number_of_offensives  ; to fake the table for ALL weapons
    .by 00  ; White Flag
    .by 00  ; Battery
    .by 98  ; Hovercraft
    .by 00  ; Parachute
    .by 99  ; Strong Parachute
    .by 99  ; Mag Deflector
    .by 00  ; Shield
    .by 99  ; Heavy Shield
    .by 99  ; Force Shield
    .by 99  ; Bouncy Castle
    .by 00  ; Long Barrel
    .by 00  ; Nuclear Winter
    .by 00  ; Lazy Boy
    .by 00  ; Lazy Darwin
    .by 00  ; Auto Defense
    .by 00  ; Spy Hard
weaponsOfDeath  ; weapons used in tank death animations
    dta ind_Missile
    dta ind_Baby_Nuke
    dta ind_Nuke
    dta ind_Death_s_Head
    dta ind_Hot_Napalm      ; why not?
    dta ind_Riot_Bomb
    dta ind_Heavy_Riot_Bomb
    dta ind_Baby_Digger
    dta ind_Digger
    dta ind_Heavy_Digger
    dta ind_Sandhog
    dta ind_Heavy_Sandhog
    dta ind_Dirt_Clod
    dta ind_Dirt_Ball
    dta ind_Ton_of_Dirt
weaponsOfDeathEnd
joyToKeyTable
    .by $ff             ;00
    .by $ff             ;01
    .by $ff             ;02
    .by $ff             ;03
    .by $ff             ;04
    .by $ff             ;05
    .by $ff             ;06
    .by @kbcode._right  ;07
    .by $ff             ;08
    .by $ff             ;09
    .by $ff             ;0a
    .by @kbcode._left   ;0b
    .by $ff             ;0c
    .by @kbcode._down   ;0d
    .by @kbcode._up     ;0e
    .by $ff             ;0f

;-----------------------------------
keycodes ;tables for converting KeyCode to Screen Code (38-1  characters)
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
;-------decimal constans + end of scrcodes
zero
digits
    dta d"0123456"
    dta d"789. " ; "-"

;-----------------------------------
gameOverSpritesTop
    ; end of the GameOver sprites by number of players
    ;   1     2     3     4     5     6
    .by 130+7,130+7,136+7,142+7,148+7,154+7
;------credits
CreditsStart
    dta   d"         "*
    dta   d"You were playin",d"g"*
    dta   d"Scorc",d"h"*
    dta   d"Warsaw, Miam",d"i"*
    dta   d"2000-202",d"3"*
    dta   d" "*
    dta   d"Programmin",d"g"*
    dta   d"Tomasz 'Pecus' Peck",d"o"*
    dta   d"Pawel 'pirx' Kalinowsk",d"i"*
    dta   d" "*
    dta   d"SFX, Music and Suppor",d"t"*
    dta   d"Michal 'Miker' Szpilowsk",d"i"*
    dta   d" "*
    .IF TARGET = 800
      dta d"Additional Musi",d"c"*
      dta d"Mario 'Emkay' Kri",d"x"*
      dta d" "*
    .ENDIF
    dta   d"Code Optimizatio",d"n"*
    dta   d"Piotr '0xF' Fusi",d"k"*
    dta   d" "*
    dta   d"Ar",d"t"*
    dta   d"Adam Wachowsk",d"i"*
    .IF TARGET = 800
      dta d"Roman 'xorcerer' Fierfa",d"s"*
    .ENDIF
    dta   d" "*
    dta   d"Ideas, help and Q",d"A"*
    dta   d"Bocianu, Probabilitydragon",d","*
    dta   d"EnderDude, Dracon",d","*
    dta   d"Beeblebrox, KrzysRog, lopezpb",d","*
    dta   d"brad-colbert, archon800, nowy80",d","*
    dta   d"Shaggy the Atarian, RetroBorsuk, ZPH"
    .IF TARGET = 800
      dta d" "*
    .ELIF TARGET = 5200
      dta d","*
      dta d"x-usr(1536), Aking, JAC!, phaeron",d","*
      dta d"RB520",d"0"*
    .ENDIF
    dta   d" "*
    dta   d"Additional testin",d"g"*
    dta   d"Arek and Alex Peck",d"o"*
    dta   d" "*
    dta   d"Special thank",d"s"*
    dta   d"Krzysztof 'Kaz' Ziembi",d"k"*
    .IF TARGET = 800
      dta d"  "*
      dta d"Stay tuned for the FujiNet version",d"!"*
    .ENDIF
    dta d"         "*
CreditsEnd
.IF TARGET = 800
  CreditsLines=40 + 7  ; add 7 for scrollout
.ELIF TARGET = 5200
  CreditsLines=34 + 7; add 7 for scrollout
.ENDIF

.IF TARGET = 5200
  ; Atari 5200 splash
  NewSplashText=*
    dta d" 2023  atariage", $4e, "com "  ; $4e - non blinking dot
.ENDIF

.endif  ; .IF *>0
