;   @com.wudsn.ide.asm.mainsourcefile=scorch.asm

screenheight = 200
screenBytes = 40
screenwidth = screenBytes*8 ; Max screenwidth = 512!!!

TankWidth	=	8
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
PMOffsetY = $23 ; P/M to graphics offset
napalmRadius = 10
StandardBarrel = 6 ; standard tank barrel length
LongBarrel = 20	; long barrel length

TextBackgroundColor = $02   ; REAL constans - use: LDA #TextBackgroundColor
TextForegroundColor = $0A
space = 0  ; space in screencodes

;character codes for symbols (tank, parachute, etc. )
char_parachute_______ = $02
char_flag____________ = $1e
char_flame___________ = $14
char_clear_flame_____ = $1c
char_digger__________ = $04
char_sandhog_________ = $0c
char_sandhog_offset = char_sandhog_________ - char_digger__________
char_tank1___________ = $20
char_tank2___________ = $24
char_tank3___________ = $28

;Weapon prices (*10 on screen)
price_Baby_Missile___ =    0  ;_00
price_Missile________ =   96  ;_01
price_Baby_Nuke______ =  111  ;_02
price_Nuke___________ =  144  ;_03
price_LeapFrog_______ =  192  ;_04
price_Funky_Bomb_____ =  293  ;_05
price_MIRV___________ =  456  ;_06
price_Death_s_Head___ =  337  ;_07
price_Napalm_________ =  125  ;_08
price_Hot_Napalm_____ =  162  ;_09
price_Tracer_________ =  102  ;_10
price_Smoke_Tracer___ =  291  ;_11
price_Baby_Roller____ =  211  ;_12
price_Roller_________ =  244  ;_13
price_Heavy_Roller___ =  326  ;_14
price_Riot_Charge____ =  230  ;_15
price_Riot_Blast_____ =  241  ;_16
price_Riot_Bomb______ =  259  ;_17
price_Heavy_Riot_Bomb =  272  ;_18
price_Baby_Digger____ =  136  ;_19
price_Digger_________ =  176  ;_20
price_Heavy_Digger___ =  207  ;_21
price_Baby_Sandhog___ =  158  ;_22
price_Sandhog________ =  191  ;_23
price_Heavy_Sandhog__ =  223  ;_24
price_Dirt_Clod______ =  104  ;_25
price_Dirt_Ball______ =  130  ;_26
price_Ton_of_Dirt____ =  171  ;_27
price_Liquid_Dirt____ =  330  ;_28
price_Dirt_Charge____ =  343  ;_29
price_Buy_me_________ =  170  ;_30
price_Laser__________ =  277  ;_31
price_White_Flag_____ =   $0  ;_32
price_Battery________ =  300  ;_33            
price_Hovercraft_____ =  352  ;_34            
price_Parachute______ =  234  ;_35            
price_StrongParachute = 1000  ;_36            
price_Mag_Deflector__ =  745  ;_37            
price_Shield_________ =  224  ;_38            
price_Heavy_Shield___ =  628  ;_39            
price_Force_Shield___ = 1100  ;_40            
price_Bouncy_Castle__ =  512  ;_41            
price_Long_Barrel____ = 2100  ;_42            
price_Nuclear_Winter_ = 1000  ;_43
;Weapon indexes (numbers)
ind_Baby_Missile___ = 0
first_offensive____ = ind_Baby_Missile___
ind_Missile________ = 1
ind_Baby_Nuke______ = 2
ind_Nuke___________ = 3
ind_LeapFrog_______ = 4
ind_Funky_Bomb_____ = 5
ind_MIRV___________ = 6
ind_Death_s_Head___ = 7
ind_Napalm_________ = 8
ind_Hot_Napalm_____ = 9
ind_Tracer_________ = 10
ind_Smoke_Tracer___ = 11
ind_Baby_Roller____ = 12
ind_Roller_________ = 13
ind_Heavy_Roller___ = 14
ind_Riot_Charge____ = 15
ind_Riot_Blast_____ = 16
ind_Riot_Bomb______ = 17
ind_Heavy_Riot_Bomb = 18
ind_Baby_Digger____ = 19
ind_Digger_________ = 20
ind_Heavy_Digger___ = 21
ind_Baby_Sandhog___ = 22
ind_Sandhog________ = 23
ind_Heavy_Sandhog__ = 24
ind_Dirt_Clod______ = 25
ind_Dirt_Ball______ = 26
ind_Ton_of_Dirt____ = 27
ind_Liquid_Dirt____ = 28
ind_Dirt_Charge____ = 29
ind_Buy_me_________ = 30
ind_Laser__________ = 31
last_offensive_____ = ind_Laser__________
ind_White_Flag_____ = 32
first_defensive____ = ind_White_Flag_____
ind_Battery________ = 33            
ind_Hovercraft_____ = 34            
ind_Parachute______ = 35            
ind_StrongParachute = 36            
ind_Mag_Deflector__ = 37            
ind_Shield_________ = 38            
ind_Heavy_Shield___ = 39            
ind_Force_Shield___ = 40                        
ind_Bouncy_Castle__ = 41            
ind_Long_Barrel____ = 42            
ind_Nuclear_Winter_ = 43
last_defensive_____ = ind_Nuclear_Winter_
number_of_offensives = last_offensive_____ - first_offensive____+1
number_of_defensives = (last_defensive_____ - first_defensive____+1)
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
sfx_tank_move	= $1f
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
