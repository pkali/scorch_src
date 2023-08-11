;   @com.wudsn.ide.asm.mainsourcefile=scorch.asm

screenheight = 200
screenBytes = 40
screenwidth = screenBytes*8 ; Max screenwidth = 512!!!

TankWidth    =    8
;----------------------------------------------
; Player/missile memory
PMGraph =  $1800  ; real PM start = PMGraph + $0300
; Generated tables
display = $2010 ;screen takes $1f68 because it has screenHeight+1 lines because of out of screen tracer(?)
;----------------------------------------------

margin = 40 ;mountain drawing Y variable margin
MaxPlayers = 6
maxOptions = 9  ;number of all options
PMOffsetX = $2C ; P/M to graphics offset
PMOffsetY = $2A ; P/M to graphics offset
napalmRadius = 10
StandardBarrel = 6 ; standard tank barrel length
LongBarrel = 20    ; long barrel length

TextBackgroundColor = $02   ; REAL constans - use: LDA #TextBackgroundColor
TextForegroundColor = $0A
space = 0  ; space in screencodes

KeyRepeatSpeed = 8 ; (max 127 !!!)

;character codes for symbols (tank, parachute, etc. )
; characters from tanks.fnt (graphics screen)
char_parachute        = $02
char_flag             = $1e
char_flame            = $14
char_clear_flame      = $1c
char_digger           = $04
char_sandhog          = $0c
char_sandhog_offset = char_sandhog          - char_digger
char_tank1            = $20
char_tank2            = $24
char_tank3            = $2c
char_tank4            = $28    ; robotank shape
; characters from weapons.fnt (text mode - menus etc.)
char_TAB              = $7f
char_DEL              = $7e
char_bracketO         = $08 ; (
char_bracketC         = $09 ; )
char_computer         = $5e ; computer symbol (Auto Defense)
char_joy              = $0a ; joystick symbol
char_tank             = $0b ; tank symbol

;Weapon prices (*10 on screen)
price_Baby_Missile    =    0  ;_00
price_Missile         =   96  ;_01
price_Baby_Nuke       =  111  ;_02
price_Nuke            =  144  ;_03
price_LeapFrog        =  192  ;_04
price_Funky_Bomb      =  293  ;_05
price_MIRV            =  456  ;_06
price_Death_s_Head    =  337  ;_07
price_Napalm          =  125  ;_08
price_Hot_Napalm      =  162  ;_09
price_Tracer          =  102  ;_10
price_Smoke_Tracer    =  291  ;_11
price_Baby_Roller     =  211  ;_12
price_Roller          =  244  ;_13
price_Heavy_Roller    =  326  ;_14
price_Riot_Charge     =  230  ;_15
price_Riot_Blast      =  241  ;_16
price_Riot_Bomb       =  259  ;_17
price_Heavy_Riot_Bomb =  272  ;_18
price_Baby_Digger     =  136  ;_19
price_Digger          =  176  ;_20
price_Heavy_Digger    =  207  ;_21
price_Sandhog         =  191  ;_22
price_Heavy_Sandhog   =  223  ;_23
price_Dirt_Clod       =  104  ;_24
price_Dirt_Ball       =  130  ;_25
price_Ton_of_Dirt     =  171  ;_26
price_Liquid_Dirt     =  330  ;_27
price_Dirt_Charge     =  343  ;_28
price_Punch           =  208  ;_29
price_Buy_me          =  170  ;_30
price_Laser           =  277  ;_31
price_White_Flag      =   $0  ;_32
price_Battery         =  300  ;_33
price_Hovercraft      =  352  ;_34
price_Parachute       =  234  ;_35
price_StrongParachute = 1000  ;_36
price_Mag_Deflector   =  745  ;_37
price_Shield          =  224  ;_38
price_Heavy_Shield    =  628  ;_39
price_Force_Shield    = 1100  ;_40
price_Bouncy_Castle   =  512  ;_41
price_Long_Barrel     = 2100  ;_42
price_Nuclear_Winter_ = 1000  ;_43
price_Lazy_Boy        =  500  ;_44
price_Lazy_Darwin     =  730  ;_45
price_Auto_Defense    =  250  ;_46
price_Spy_Hard        =   83  ;_47
;Weapon indexes (numbers)
ind_Baby_Missile    = 0
first_offensive     = ind_Baby_Missile
ind_Missile         = 1
ind_Baby_Nuke       = 2
ind_Nuke            = 3
ind_LeapFrog        = 4
ind_Funky_Bomb      = 5
ind_MIRV            = 6
ind_Death_s_Head    = 7
ind_Napalm          = 8
ind_Hot_Napalm      = 9
ind_Tracer          = 10
ind_Smoke_Tracer    = 11
ind_Baby_Roller     = 12
ind_Roller          = 13
ind_Heavy_Roller    = 14
ind_Riot_Charge     = 15
ind_Riot_Blast      = 16
ind_Riot_Bomb       = 17
ind_Heavy_Riot_Bomb = 18
ind_Baby_Digger     = 19
ind_Digger          = 20
ind_Heavy_Digger    = 21
ind_Sandhog         = 22
ind_Heavy_Sandhog   = 23
ind_Dirt_Clod       = 24
ind_Dirt_Ball       = 25
ind_Ton_of_Dirt     = 26
ind_Liquid_Dirt     = 27
ind_Dirt_Charge     = 28
ind_Punch           = 29
ind_Buy_me          = 30
ind_Laser           = 31
last_offensive      = ind_Laser
ind_White_Flag      = 32
first_defensive     = ind_White_Flag
ind_Battery         = 33
ind_Hovercraft      = 34
ind_Parachute       = 35
ind_StrongParachute = 36
ind_Mag_Deflector   = 37
ind_Shield          = 38
ind_Heavy_Shield    = 39
ind_Force_Shield    = 40
ind_Bouncy_Castle   = 41
ind_Long_Barrel     = 42
ind_Nuclear_Winter_ = 43
ind_Lazy_Boy        = 44
ind_Lazy_Darwin     = 45
ind_Auto_Defense    = 46
ind_Spy_Hard        = 47
last_defensive      = ind_Spy_Hard
last_real_defensive = ind_Bouncy_Castle
number_of_offensives = last_offensive      - first_offensive    +1
number_of_defensives = (last_defensive      - first_defensive    +1)
number_of_weapons = number_of_offensives + number_of_defensives
;--------------------------------
; names of RMT instruments (sfx)
;--------------------------------
sfx_set_power_1 = $00 ;A
sfx_set_power_2 = $01 ;b
sfx_lightning   = $02 ;c
sfx_dunno       = $03 ;d
sfx_nuke        = $04 ;e
sfx_baby_missile= $05 ;f
sfx_death_begin = $06 ;g
sfx_plasma_1_2  = $07 ;h
sfx_plasma_2_2  = $08 ;i
sfx_napalm      = $09 ;j
sfx_dirt_charge = $0a ;k
sfx_missile_hit = $0b ;l
sfx_funky_hit   = $0c ;m
sfx_shield_on   = $0d ;n
sfx_shield_off  = $0e ;o
sfx_parachute   = $0f ;p
sfx_smoke_cloud = $10 ;q
sfx_riot_blast  = $11 ;r
sfx_sandhog     = $12 ;s
sfx_dirt_chrg_s = $13 ;t
sfx_digger      = $14 ;u
sfx_silencer    = $15 ;v
sfx_next_player = $16 ;w
sfx_purchase    = $17 ;x
sfx_keyclick    = $18 ;y
sfx_shoot       = $19 ;z
sfx_seppuku     = $1a ;1
sfx_liquid_dirt = $1b ;2
sfx_battery     = $1c ;3
sfx_white_flag  = $1d ;4
sfx_long_barrel = $1e
sfx_tank_move    = $1f
sfx_auto_defense= $2b
sfx_lazy_boys    = $2c
;--------------------------------
; RMT songs (lines)
;--------------------------------
song_silencio   = $00
song_main_menu  = $02
song_ingame     = $06
song_round_over = $0b
song_ending_looped = $0e
song_supermarket = $1b
song_inventory = $1d
