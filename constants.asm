;   @com.wudsn.ide.asm.mainsourcefile=scorch.asm

    .IF *>0 ;this is a trick that prevents compiling this file alone

;===================================================================================
;==========================CONSTANT TABLES, do not erase!===========================
;===================================================================================
TankColoursTable        .BYTE $88,$cc,$38,$1c,$6a,$02
TankStatusColoursTable  .BYTE $80,$c0,$30,$10,$60,$00
dliColorsBack
    :10 .by $02,$00
dliColorsFore
    .by $0a
TextBackgroundColor = $02	; REAL constans - use: LDA #TextBackgroundColor
TextForegroundColor = $0c
CashOptionL ;(one zero less than on the screen)
    .by 0,<200,<500,<800,<1000
CashOptionH   
    .by 0,>200,>500,>800,>1000
GravityTable   .by 10,20,25,30,40
MaxWindTable   .by 5,20,40,70,99
RoundsTable    .by 10,20,30,40,50
flyDelayTable  .by 255,150,75,35,1
seppukuTable   .by 255, 45,25,15,9
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
;-----4x4 texts-----

LineTop
    dta d"(%%%%%%%%%%%%)"
    .byte $ff
;# - vertical, () * +, % - horizontal
LineBottom
    dta d"*%%%%%%%%%%%%+"
    .byte $ff
LineEmpty
    dta d"#            #"
    .byte $ff
LineHeader2
    dta d"#  RESULTS   #"
    .byte $ff
LineGameOver
    dta d"# GAME  OVER #"
    .byte $ff
seppukuText
    dta d"#  SEPPUKU!  #"
    .byte $ff
lineClear
    dta d"              "
    .byte $ff


;-----------
pmtableL ; addressess of the P/M memory for 5 tanks (6th is without P/M background)
    .by <(pmgraph+$400)
    .by <(pmgraph+$500)
    .by <(pmgraph+$600)
    .by <(pmgraph+$700)
    .by <(pmgraph+$300)  ; this is a missile background
pmtableH
    .by >(pmgraph+$400)
    .by >(pmgraph+$500)
    .by >(pmgraph+$600)
    .by >(pmgraph+$700)
    .by >(pmgraph+$300)
;-----------
; this table changes Angle to the appropriate tank character
BarrelTableL
    .by $02,$02,$02,$02,$02,$02,$02,$02
    .by $04,$04,$04,$04,$04,$04,$04,$04
    .by $06,$06,$06,$06,$06,$06,$06,$06,$06
    .by $08,$08,$08,$08,$08,$08,$08,$08
    .by $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a
    .by $0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c
    .by $0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e
    .by $10,$10,$10,$10,$10,$10,$10,$10
    .by $12,$12,$12,$12,$12,$12,$12,$12,$12
    .by $14,$14,$14,$14,$14,$14,$14,$14
    .by $16,$16,$16,$16,$16,$16,$16,$16
BarrelTableR
    .by $2c,$2c,$2c,$2c,$2c,$2c,$2c,$2c
    .by $2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a
    .by $28,$28,$28,$28,$28,$28,$28,$28,$28
    .by $26,$26,$26,$26,$26,$26,$26,$26
    .by $24,$24,$24,$24,$24,$24,$24,$24
    .by $22,$22,$22,$22,$22,$22,$22,$22,$22
    .by $20,$20,$20,$20,$20,$20,$20,$20
    .by $1e,$1e,$1e,$1e,$1e,$1e,$1e,$1e
    .by $1c,$1c,$1c,$1c,$1c,$1c,$1c,$1c,$1c
    .by $1a,$1a,$1a,$1a,$1a,$1a,$1a,$1a
    .by $18,$18,$18,$18,$18,$18,$18,$18

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
; there are 3 bits used here
; bit 0 - go down
; bit 1 - go left
; bit 2 - go right
; position in the table equals to bit pattern of soil below tank

WhereToSlideTable
  ; we have 3 bits, when set: 2 - go left, 1 - go right, 0 - go down
    .BY %001  ; 00000000
    .BY %101  ; 00000001
    .BY %100  ; 00000010
    .BY %100  ; 00000011
    .BY %100  ; 00000100
    .BY %100  ; 00000101
    .BY %100  ; 00000110
    .BY %100  ; 00000111
    .BY %000  ; 00001000
    .BY %000  ; 00001001
    .BY %000  ; 00001010
    .BY %000  ; 00001011
    .BY %100  ; 00001100
    .BY %000  ; 00001101
    .BY %000  ; 00001110
    .BY %000  ; 00001111
    .BY %000  ; 00010000
    .BY %000  ; 00010001
    .BY %000  ; 00010010
    .BY %000  ; 00010011
    .BY %000  ; 00010100
    .BY %000  ; 00010101
    .BY %000  ; 00010110
    .BY %000  ; 00010111
    .BY %000  ; 00011000
    .BY %000  ; 00011001
    .BY %000  ; 00011010
    .BY %000  ; 00011011
    .BY %000  ; 00011100
    .BY %000  ; 00011101
    .BY %000  ; 00011110
    .BY %000  ; 00011111
    .BY %010  ; 00100000
    .BY %000  ; 00100001
    .BY %000  ; 00100010
    .BY %000  ; 00100011
    .BY %000  ; 00100100
    .BY %000  ; 00100101
    .BY %000  ; 00100110
    .BY %000  ; 00100111
    .BY %000  ; 00101000
    .BY %000  ; 00101001
    .BY %000  ; 00101010
    .BY %000  ; 00101011
    .BY %000  ; 00101100
    .BY %000  ; 00101101
    .BY %000  ; 00101110
    .BY %000  ; 00101111
    .BY %010  ; 00110000
    .BY %000  ; 00110001
    .BY %000  ; 00110010
    .BY %000  ; 00110011
    .BY %000  ; 00110100
    .BY %000  ; 00110101
    .BY %000  ; 00110110
    .BY %000  ; 00110111
    .BY %000  ; 00111000
    .BY %000  ; 00111001
    .BY %000  ; 00111010
    .BY %000  ; 00111011
    .BY %000  ; 00111100
    .BY %000  ; 00111101
    .BY %000  ; 00111110
    .BY %000  ; 00111111
    .BY %010  ; 01000000
    .BY %000  ; 01000001
    .BY %000  ; 01000010
    .BY %000  ; 01000011
    .BY %000  ; 01000100
    .BY %000  ; 01000101
    .BY %000  ; 01000110
    .BY %000  ; 01000111
    .BY %000  ; 01001000
    .BY %000  ; 01001001
    .BY %000  ; 01001010
    .BY %000  ; 01001011
    .BY %000  ; 01001100
    .BY %000  ; 01001101
    .BY %000  ; 01001110
    .BY %000  ; 01001111
    .BY %000  ; 01010000
    .BY %000  ; 01010001
    .BY %000  ; 01010010
    .BY %000  ; 01010011
    .BY %000  ; 01010100
    .BY %000  ; 01010101
    .BY %000  ; 01010110
    .BY %000  ; 01010111
    .BY %000  ; 01011000
    .BY %000  ; 01011001
    .BY %000  ; 01011010
    .BY %000  ; 01011011
    .BY %000  ; 01011100
    .BY %000  ; 01011101
    .BY %000  ; 01011110
    .BY %000  ; 01011111
    .BY %010  ; 01100000
    .BY %000  ; 01100001
    .BY %000  ; 01100010
    .BY %000  ; 01100011
    .BY %000  ; 01100100
    .BY %000  ; 01100101
    .BY %000  ; 01100110
    .BY %000  ; 01100111
    .BY %000  ; 01101000
    .BY %000  ; 01101001
    .BY %000  ; 01101010
    .BY %000  ; 01101011
    .BY %000  ; 01101100
    .BY %000  ; 01101101
    .BY %000  ; 01101110
    .BY %000  ; 01101111
    .BY %000  ; 01110000
    .BY %000  ; 01110001
    .BY %000  ; 01110010
    .BY %000  ; 01110011
    .BY %000  ; 01110100
    .BY %000  ; 01110101
    .BY %000  ; 01110110
    .BY %000  ; 01110111
    .BY %000  ; 01111000
    .BY %000  ; 01111001
    .BY %000  ; 01111010
    .BY %000  ; 01111011
    .BY %000  ; 01111100
    .BY %000  ; 01111101
    .BY %000  ; 01111110
    .BY %000  ; 01111111
    .BY %011  ; 10000000
    .BY %000  ; 10000001
    .BY %000  ; 10000010
    .BY %000  ; 10000011
    .BY %000  ; 10000100
    .BY %000  ; 10000101
    .BY %000  ; 10000110
    .BY %000  ; 10000111
    .BY %000  ; 10001000
    .BY %000  ; 10001001
    .BY %000  ; 10001010
    .BY %000  ; 10001011
    .BY %000  ; 10001100
    .BY %000  ; 10001101
    .BY %000  ; 10001110
    .BY %000  ; 10001111
    .BY %000  ; 10010000
    .BY %000  ; 10010001
    .BY %000  ; 10010010
    .BY %000  ; 10010011
    .BY %000  ; 10010100
    .BY %000  ; 10010101
    .BY %000  ; 10010110
    .BY %000  ; 10010111
    .BY %000  ; 10011000
    .BY %000  ; 10011001
    .BY %000  ; 10011010
    .BY %000  ; 10011011
    .BY %000  ; 10011100
    .BY %000  ; 10011101
    .BY %000  ; 10011110
    .BY %000  ; 10011111
    .BY %010  ; 10100000
    .BY %000  ; 10100001
    .BY %000  ; 10100010
    .BY %000  ; 10100011
    .BY %000  ; 10100100
    .BY %000  ; 10100101
    .BY %000  ; 10100110
    .BY %000  ; 10100111
    .BY %000  ; 10101000
    .BY %000  ; 10101001
    .BY %000  ; 10101010
    .BY %000  ; 10101011
    .BY %000  ; 10101100
    .BY %000  ; 10101101
    .BY %000  ; 10101110
    .BY %000  ; 10101111
    .BY %000  ; 10110000
    .BY %000  ; 10110001
    .BY %000  ; 10110010
    .BY %000  ; 10110011
    .BY %000  ; 10110100
    .BY %000  ; 10110101
    .BY %000  ; 10110110
    .BY %000  ; 10110111
    .BY %000  ; 10111000
    .BY %000  ; 10111001
    .BY %000  ; 10111010
    .BY %000  ; 10111011
    .BY %000  ; 10111100
    .BY %000  ; 10111101
    .BY %000  ; 10111110
    .BY %000  ; 10111111
    .BY %010  ; 11000000
    .BY %000  ; 11000001
    .BY %000  ; 11000010
    .BY %000  ; 11000011
    .BY %000  ; 11000100
    .BY %000  ; 11000101
    .BY %000  ; 11000110
    .BY %000  ; 11000111
    .BY %000  ; 11001000
    .BY %000  ; 11001001
    .BY %000  ; 11001010
    .BY %000  ; 11001011
    .BY %000  ; 11001100
    .BY %000  ; 11001101
    .BY %000  ; 11001110
    .BY %000  ; 11001111
    .BY %000  ; 11010000
    .BY %000  ; 11010001
    .BY %000  ; 11010010
    .BY %000  ; 11010011
    .BY %000  ; 11010100
    .BY %000  ; 11010101
    .BY %000  ; 11010110
    .BY %000  ; 11010111
    .BY %000  ; 11011000
    .BY %000  ; 11011001
    .BY %000  ; 11011010
    .BY %000  ; 11011011
    .BY %000  ; 11011100
    .BY %000  ; 11011101
    .BY %000  ; 11011110
    .BY %000  ; 11011111
    .BY %010  ; 11100000
    .BY %000  ; 11100001
    .BY %000  ; 11100010
    .BY %000  ; 11100011
    .BY %000  ; 11100100
    .BY %000  ; 11100101
    .BY %000  ; 11100110
    .BY %000  ; 11100111
    .BY %000  ; 11101000
    .BY %000  ; 11101001
    .BY %000  ; 11101010
    .BY %000  ; 11101011
    .BY %000  ; 11101100
    .BY %000  ; 11101101
    .BY %000  ; 11101110
    .BY %000  ; 11101111
    .BY %000  ; 11110000
    .BY %000  ; 11110001
    .BY %000  ; 11110010
    .BY %000  ; 11110011
    .BY %000  ; 11110100
    .BY %000  ; 11110101
    .BY %000  ; 11110110
    .BY %000  ; 11110111
    .BY %000  ; 11111000
    .BY %000  ; 11111001
    .BY %000  ; 11111010
    .BY %000  ; 11111011
    .BY %000  ; 11111100
    .BY %000  ; 11111101
    .BY %000  ; 11111110
    .BY %000  ; 11111111

EndOfTheBarrelX
	; right angles from 0 (vertically up) to 90 (horizontally to the right)
    .by 4,4,4,4,4,4,4,4,4,4,4
    .by 5,5,5,5,5,5,5,5,5,5
    .by 6,6,6,6,6,6,6,6,6
    .by 7,7,7,7,7,7,7,7,7,7,7,7,7,7,7
    .by 7,7,7,7,7,7,7,7,7
    .by 7,7,7,7,7,7,7,7,7,7
    .by 7,7,7,7,7,7,7,7,7,7,7,7,7
    .by 7,7,7,7,7,7,7,7,7,7,7,7,7,7

    .by 0,0,0,0,0,0,0,0,0,0		; not used
    .by 0,0,0,0,0,0,0,0,0,0		; not used
    .by 0,0,0,0,0,0,0,0,0,0		; not used
    .by 0,0,0,0,0,0,0,0,0,0		; not used
    .by 0,0,0,0,0,0,0,0,0,0		; not used
    .by 0,0,0,0,0,0,0,0,0,0		; not used
    .by 0,0,0,0,0,0,0,0,0,0		; not used
    .by 0,0,0,0					; not used

	; left angles from 90 (horizontally to the left) to 1 (vertically up)
    .by 0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .by 0,0,0,0,0,0,0,0,0,0,0,0,0
    .by 0,0,0,0,0,0,0,0,0,0
    .by 0,0,0,0,0,0,0,0,0
    .by 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .by 1,1,1,1,1,1,1,1,1
    .by 2,2,2,2,2,2,2,2,2,2
    .by 3,3,3,3,3,3,3,3,3,3,3

EndOfTheBarrelY
	; right angles from 0 (vertically up) to 90 (horizontally to the right)
    .by 7,7,7,7,7,7,7,7,7,7,7
    .by 7,7,7,7,7,7,7,7,7,7
    .by 7,7,7,7,7,7,7,7,7
    .by 7,7,7,7,7,7,7,7,7,7,7,7,7,7,7
    .by 6,6,6,6,6,6,6,6,6
    .by 5,5,5,5,5,5,5,5,5,5
    .by 4,4,4,4,4,4,4,4,4,4,4,4,4
    .by 3,3,3,3,3,3,3,3,3,3,3,3,3,3

    .by 0,0,0,0,0,0,0,0,0,0		; not used
    .by 0,0,0,0,0,0,0,0,0,0		; not used
    .by 0,0,0,0,0,0,0,0,0,0		; not used
    .by 0,0,0,0,0,0,0,0,0,0		; not used
    .by 0,0,0,0,0,0,0,0,0,0		; not used
    .by 0,0,0,0,0,0,0,0,0,0		; not used
    .by 0,0,0,0,0,0,0,0,0,0		; not used
    .by 0,0,0,0					; not used

	; left angles from 90 (horizontally to the left) to 1 (vertically up)
    .by 3,3,3,3,3,3,3,3,3,3,3,3,3,3
    .by 4,4,4,4,4,4,4,4,4,4,4,4,4
    .by 5,5,5,5,5,5,5,5,5,5
    .by 6,6,6,6,6,6,6,6,6
    .by 7,7,7,7,7,7,7,7,7,7,7,7,7,7,7
    .by 7,7,7,7,7,7,7,7,7
    .by 7,7,7,7,7,7,7,7,7,7
    .by 7,7,7,7,7,7,7,7,7,7,7
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
  .by >price_Earth_Disrupter
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
  .by >price_Heat_Guidance__
  .by >price_Bal_Guidance___
  .by >price_Horz_Guidance__
  .by >price_Vert_Guidance__
  .by >price_Lazy_Boy_______
  .by >price_Parachute______
  .by >price_Battery________
  .by >price_Mag_Deflector__
  .by >price_Shield_________
  .by >price_Force_Shield___
  .by >price_Heavy_Shield___
  .by >price_Super_Mag______
  .by >price_Auto_Defense___
  .by >price_Fuel_Tank______
  .by >price_Contact_Trigger
  .by >price_White_Flag_____

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
  .by <price_Earth_Disrupter
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
  .by <price_Heat_Guidance__
  .by <price_Bal_Guidance___
  .by <price_Horz_Guidance__
  .by <price_Vert_Guidance__
  .by <price_Lazy_Boy_______
  .by <price_Parachute______
  .by <price_Battery________
  .by <price_Mag_Deflector__
  .by <price_Shield_________
  .by <price_Force_Shield___
  .by <price_Heavy_Shield___
  .by <price_Super_Mag______
  .by <price_Auto_Defense___
  .by <price_Fuel_Tank______
  .by <price_Contact_Trigger
  .by <price_White_Flag_____

;-------------------------------------------------
; how many units (bulletd) of a given weapon we get for a given price
; This is a table of constans.
; If on a given position is 0 it means that this weapon
; is not present in the game.
; This is the slot for adding new weapons.
WeaponUnits
  .by 10 ;Baby_Missile___
  .by 5  ;Missile________
  .by 3  ;Baby_Nuke______
  .by 1  ;Nuke___________
  .by 2  ;LeapFrog_______
  .by 2  ;Funky_Bomb_____
  .by 3  ;MIRV___________
  .by 1  ;Death_s_Head___
  .by 10 ;Napalm_________
  .by 2  ;Hot_Napalm_____
  .by 20 ;Tracer_________
  .by 10 ;Smoke_Tracer___
  .by 10 ;Baby_Roller____
  .by 5  ;Roller_________
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
  .by 10 ;Dirt_Clod______
  .by 5  ;Dirt_Ball______
  .by 2  ;Ton_of_Dirt____
  .by 4  ;Liquid_Dirt____
  .by 2  ;Dirt_Charge____
  .by 10 ;Earth_Disrupter
  .by 5  ;Plasma_Blast___
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
  .by 6  ;Heat_Guidance__
  .by 2  ;Bal_Guidance___
  .by 5  ;Horz_Guidance__
  .by 5  ;Vert_Guidance__
  .by 2  ;Lazy_Boy_______
  .by 8  ;Parachute______
  .by 10 ;Battery________
  .by 2  ;Mag_Deflector__
  .by 3  ;Shield_________
  .by 3  ;Force_Shield___
  .by 2  ;Heavy_Shield___
  .by 2  ;Super_Mag______
  .by 1  ;Auto_Defense___
  .by 10 ;Fuel_Tank______
  .by 25 ;Contact_Trigger
  .by 1  ;_____________63

PurchaseMeTable ;weapons good to be purchased by the robot 
                ;the comment is an index in the tables
    dta 1 ;"Baby Missile    " ; 0
    dta 1 ;"Missile         " ; 1
    dta 1 ;"Baby Nuke       " ; 2
    dta 1 ;"Nuke            " ; 3
    dta 1 ;"LeapFrog        " ; 4
    dta 1 ;"Funky Bomb      " ; 5
    dta 1 ;"MIRV            " ; 6
    dta 1 ;"Death's Head    " ; 7
    dta 0 ;"Napalm          " ; 8
    dta 0 ;"Hot Napalm      " ; 9
    dta 0 ;"Tracer          " ; 10
    dta 0 ;"Smoke Tracer    " ; 11
    dta 1 ;"Baby Roller     " ; 12
    dta 1 ;"Roller          " ; 13
    dta 1 ;"Heavy Roller    " ; 14
    dta 0 ;"Riot Charge     " ; 15
    dta 0 ;"Riot Blast      " ; 16
    dta 0 ;"Riot Bomb       " ; 17
    dta 0 ;"Heavy Riot Bomb " ; 18
    dta 0 ;"Baby Digger     " ; 19
    dta 0 ;"Digger          " ; 20
    dta 0 ;"Heavy Digger    " ; 21
    dta 0 ;"Baby Sandhog    " ; 22
    dta 0 ;"Sandhog         " ; 23
    dta 0 ;"Heavy Sandhog   " ; 24
    dta 0 ;"Dirt Clod       " ; 25
    dta 0 ;"Dirt Ball       " ; 26
    dta 0 ;"Ton of Dirt     " ; 27
    dta 0 ;"Liquid Dirt     " ; 28
    dta 0 ;"Dirt Charge     " ; 29
    dta 0 ;"Earth Disrupter " ; 30
    dta 0 ;"Plasma Blast    " ; 31
    dta 1 ;"Laser           " ; 32
    dta 0 ;"----------------" ; 33
    dta 0 ;"----------------" ; 34
    dta 0 ;"----------------" ; 35
    dta 0 ;"----------------" ; 36
    dta 0 ;"----------------" ; 37
    dta 0 ;"----------------" ; 38
    dta 0 ;"----------------" ; 39
    dta 0 ;"----------------" ; 40
    dta 0 ;"----------------" ; 41
    dta 0 ;"----------------" ; 42
    dta 0 ;"----------------" ; 43
    dta 0 ;"----------------" ; 44
    dta 0 ;"----------------" ; 45
    dta 0 ;"----------------" ; 46
    dta 0 ;"----------------" ; 47
 

;-------------------------------------------------
; Screen codes of icons (chars) representing a given weapon
WeaponSymbols
    .by $40,$41,$42,$43,$44,$45,$46,$47
    .by $48,$49,$4a,$4b,$4c,$4d,$4e,$4f
    .by $50,$51,$52,$53,$54,$55,$56,$57
    .by $58,$59,$5a,$5b,$60,$7b,$7c,$7d
    .by $20,$00,$00,$00,$00,$00,$00,$00
    .by $00,$00,$00,$00,$00,$00,$00,$00
    .by $02,$03,$06,$1d,$0a,$1b,$1c,$1e
    .by $3b,$3c,$3d,$3e,$3f,$5e,$5f,$00

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
    dta d"White Flag      " ; 63
weaponsOfDeath
	dta 1,2,3,7,15,16,17,18,19,20,21,22,23,24,25,26,27
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
    .by $33,$35,$30,$32,$22 ;,$0e <-- hyphen removed from the table, sorry hyphen lovers
keycodesEnd
scrcodes
    dta d"abcdefgh"
    dta d"ijklmnop"
    dta d"qrstuvwx"
    dta d"yz123456"
    dta d"7890." ; "-"

.endif
