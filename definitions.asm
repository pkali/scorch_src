;   @com.wudsn.ide.asm.mainsourcefile=scorch.asm

screenheight = 200
screenBytes = 40
screenwidth = screenBytes*8 ; Max screenwidth = 512!!!

;----------------------------------------------
; Player/missile memory
PMGraph =  $0800  ; real PM start = $0b00


; Generated tables
linetableL = $0b00 - (screenHeight+1)*2
linetableH = $0b00 - (screenHeight+1)

display = $1010 ;screen takes $1f68 because it has screenHeight+1 lines because of out of screen tracer(?)

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
price_Baby_Missile___ = 0      ;_0
price_Missile________ = 96     ;_1
price_Baby_Nuke______ = 111    ;_2
price_Nuke___________ = 144    ;_3
price_LeapFrog_______ = 192    ;_4
price_Funky_Bomb_____ = 293    ;_5
price_MIRV___________ = 456    ;_6
price_Death_s_Head___ = 337    ;_7
price_Napalm_________ = 125    ;_8
price_Hot_Napalm_____ = 162    ;_9
price_Tracer_________ = 102    ;_10
price_Smoke_Tracer___ = 291    ;_11
price_Baby_Roller____ = 211    ;_12
price_Roller_________ = 244    ;_13
price_Heavy_Roller___ = 326    ;_14
price_Riot_Charge____ = 230    ;_15
price_Riot_Blast_____ = 241    ;_16
price_Riot_Bomb______ = 259    ;_17
price_Heavy_Riot_Bomb = 272    ;_18
price_Baby_Digger____ = 136    ;_19
price_Digger_________ = 176    ;_20
price_Heavy_Digger___ = 207    ;_21
price_Baby_Sandhog___ = 158    ;_22
price_Sandhog________ = 191    ;_23
price_Heavy_Sandhog__ = 223    ;_24
price_Dirt_Clod______ = 104    ;_25
price_Dirt_Ball______ = 130    ;_26
price_Ton_of_Dirt____ = 171    ;_27
price_Liquid_Dirt____ = 330    ;_28
price_Dirt_Charge____ = 343    ;_29
price_Buy_me_________ = 170	   ;430    ;_30
price_Plasma_Blast___ = $ffff ;274    ;_31
price_Laser__________ = 277    ;_32
;price______________33 = 0
;price______________34 = 0
;price______________35 = 0
;price______________36 = 0
;price______________37 = 0
;price______________38 = 0
;price______________39 = 0
;price______________40 = 0
;price______________41 = 0
;price______________42 = 0
;price______________43 = 0
;price______________44 = 0
;price______________45 = 0
;price______________46 = 0
;price______________47 = 0   
price_White_Flag_____ = $0        ;_33
price_Battery________ =   300     ;_34            
price_Bal_Guidance___ = $ffff     ;_35            
price_Horz_Guidance__ = $ffff     ;_36            
price_Floating_Tank__ = 352       ;_37            
price_Lazy_Boy_______ = $ffff     ;_38            
price_Parachute______ =   234     ;_39            
price_StrongParachute =  1000     ;_40            
price_Mag_Deflector__ =   745     ;_41            
price_Shield_________ =   224     ;_42            
price_Heavy_Shield___ =   628     ;_43            
price_Force_Shield___ =  1100     ;_44            
price_Super_Mag______ = $ffff     ;_45            
price_Bouncy_Castle__ =   512     ;_46            
price_Long_Barrel____ =  2100     ;_47            
price_Nuclear_Winter_ =  1000     ;_48
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
ind_Plasma_Blast___ = 31
ind_Laser__________ = 32
last_offensive_____ = ind_Laser__________
;ind______________33 = 0
;ind______________34 = 0
;ind______________35 = 0
;ind______________36 = 0
;ind______________37 = 0
;ind______________38 = 0
;ind______________39 = 0
;ind______________40 = 0
;ind______________41 = 0
;ind______________42 = 0
;ind______________43 = 0
;ind______________44 = 0
;ind______________45 = 0
;ind______________46 = 0
;ind______________47 = 0   
ind_White_Flag_____ = 33
first_defensive____ = ind_White_Flag_____
ind_Battery________ = 34            
ind_Bal_Guidance___ = 35            
ind_Horz_Guidance__ = 36            
ind_Floating_Tank__ = 37            
ind_Lazy_Boy_______ = 38            
ind_Parachute______ = 39            
ind_StrongParachute = 40            
ind_Mag_Deflector__ = 41            
ind_Shield_________ = 42            
ind_Heavy_Shield___ = 43            
ind_Force_Shield___ = 44            
ind_Super_Mag______ = 45            
ind_Bouncy_Castle__ = 46            
ind_Long_Barrel____ = 47            
ind_Nuclear_Winter_ = 48
last_defensive_____ = ind_Nuclear_Winter_
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
