;	@com.wudsn.ide.asm.mainsourcefile=scorch.asm
;C64 8-bit Scorched Earth source code
;---------------------------------------------------
;by Tomasz 'pecus' Pecko and Pawel 'pirx' Kalinowski
;Warsaw 2000, 2001, 2002, 2003, 2009, 2012, 2013
;Miami & Warsaw 2022, 2023

;---------------------------------------------------
.def TARGET = C64 ; :)
;---------------------------------------------------
.def XCORRECTION_FOR_PM = 0
; if 1 - active x position of tanks correction fo PMG
.def FASTER_GRAF_PROCS = 0
; if 1 - activates faster graphics routines
;        (direct writes to screen memory - atari only :) )
;---------------------------------------------------


    opt h-f+
    org $801
    org [a($801)],$801
    basic_start(FirstSTART)
	
	
;---------------------------------------------------
.macro build
	dta d"1.28" ; number of this build (4 bytes)
.endm

.macro RMTSong
      lda #:1
      rts	; do nothing in C64
.endm

;---------------------------------------------------
    icl 'definitions.asm'
;---------------------------------------------------

FirstZpageVariable = $57
    .zpvar DliColorBack		.byte = FirstZpageVariable
	.zpvar GradientNr		.byte
	.zpvar GradientColors	.word
	.zpvar WindChangeInRound	.byte	; wind change after each turn (not round only) flag - (0 - round only, >0 - each turn)
	.zpvar JoystickNumber	.byte
	.zpvar LazyFlag			.byte	; 7 bit - run Lazy Darwin, 6 bit - run Lazy Boy or Darwin (!) after inventory, 0 - nothing
	.zpvar SpyHardFlag		.byte	; >$7f - run SpyHard after inventory
	.zpvar Vdebug			.byte ; "visual debug" flag ($00 - off, $ff - on)
    .zpvar xdraw            .word ;= $64 ;variable X for plot
    .zpvar ydraw            .word ;variable Y for plot (like in Atari Basic - Y=0 in upper right corner of the screen)
    .zpvar xbyte            .word
    .zpvar ybyte            .word
    .zpvar CharCode         .byte
    .zpvar fontind          .word
    .zpvar tanknr           .byte
    .zpvar TankSequencePointer .byte
    .zpvar oldplot          .word
    .zpvar xc               .word
    .zpvar temp             .word ;temporary word for the most embeded loops only
    .zpvar temp2            .word ;same as above
    .zpvar modify           .word ;origially used to replace self-modyfying code
    .zpvar tempXROLLER      .word ;same as above for XROLLER routine (used also in result display routine)
    .zpvar xtempDRAW        .word ;same as above for XDRAW routine
    .zpvar ytempDRAW        .word ;same as above for XDRAW routine
    .zpvar tempor2          .word
	.zpvar CreditsVScrol	.byte
    ;--------------temps used in circle routine
    .zpvar xi               .word ;X (word) in draw routine
    .zpvar fx               .byte 
    .zpvar yi               .word ;Y (word) in draw routine
    .zpvar fy               .byte
    .zpvar xk               .word
    .zpvar fs               .byte
    .zpvar yc               .byte ;ycircle - temporary for circle
    .zpvar dx               .word
    .zpvar dy               .word
    .zpvar dd               .word
    .zpvar di               .word
    .zpvar dp               .word
    ;----------------------------
	.zpvar UnderTank1		.byte
	.zpvar UnderTank2		.byte	
    ;----------------------------
	.zpvar TestFlightFlag	.byte ; For AI test flights ($ff - test, $00 - standard shoot flight)
    .zpvar weaponPointer    .word
	.zpvar dliCounter       .byte
	.zpvar pressTimer       .byte
	.zpvar NTSCcounter      .byte
	.zpvar IsEndOfTheFallFlag .byte ; for small speedup ground falling
	.zpvar sfx_effect		.byte
	.zpvar RMT_blocked		.byte
	.zpvar ScrollFlag		.byte
	.zpvar SkStatSimulator	.byte
	.zpvar FloatingAlt		.byte	; floating tank altitude
	.zpvar OverTankDir		.byte	; (0 go right, $ff go left) direction of bypassing tanks on screen

    ; --------------OPTIMIZATION VARIABLES--------------
    .zpvar Force .word
    .zpvar Force_ .byte ; Force is 3 bytes long
    .zpvar Angle .byte
    .zpvar Parachute .byte ; are you insured with parachute?
    .zpvar color .byte
    .zpvar Erase .byte  ; if 1 only mask of the character is printed
                        ; on the graphics screen. if 0 character is printed normally
    .zpvar radius .byte
    .zpvar decimal .word
    .zpvar NumberOfPlayers .byte ;current number of players (counted from 1)
    .zpvar Counter .byte ;temporary Counter for outside loops
    .zpvar ExplosionRadius .byte
	.zpvar FunkyBombCounter .byte
    .zpvar ResultY .byte
    .zpvar xcircle .word
    .zpvar ycircle .word
    .zpvar vy .word
    .zpvar vy_ .word ; 4 bytes
    .zpvar vx .word
    .zpvar vx_ .word ; 4 bytes
    .zpvar HitFlag .byte ;$ff when missile hit ground, $00 when no hit, $01-$06 tank index+1 when hit tank
    .zpvar PositionOnTheList .byte ; pointer position on the list being displayed
    .zpvar XHit .word
    .zpvar delta .word
    .zpvar HowMuchToFall .byte
    .zpvar magic .word
    .zpvar xtraj .word
    .zpvar xtraj_ .byte  ; 3 bytes
    .zpvar ytraj .word
    .zpvar ytraj_ .byte  ; 3 bytes
    .zpvar Wind .word
    .zpvar Wind_ .word  ; 4 bytes
    .zpvar RangeLeft .word
    .zpvar RangeRight .word
    .zpvar NewAngle .byte
    .zpvar escFlag .byte
    .zpvar LineYdraw .byte
    .zpvar LineXdraw .word
    .zpvar plot4x4color .byte	; $00 / $ff 
    .zpvar Multiplier .word
    .zpvar Multiplier_ .byte  ; 3 bytes
    .zpvar HowToDraw .byte
    .zpvar gravity .byte
    .zpvar LineLength .word
    .zpvar tracerflag .byte
    .zpvar isInventory .byte
    .zpvar DifficultyLevel .byte
    .zpvar goleft .byte
    .zpvar OffsetDL1 .byte
    .zpvar L1 .byte
	HotNapalmFlag = FunkyBombCounter ; reuse variable!
    ;* RMT ZeroPage addresses in artwork/sfx/rmtplayr.a65

    displayposition = modify
    LineAddress4x4 = xcircle

;-----------------------------------------------
; libraries
;-----------------------------------------------
      icl 'C64/lib/C64_ATARISYS.ASM'
      icl 'C64/lib/C64SYS.ASM'
      icl 'C64/lib/MACRO.ASM'
    
;-----------------------------------------------
; variable declarations in RAM (no code)
;-----------------------------------------------
    ORG PMGraph + $0300 - (variablesEnd - OneTimeZeroVariables + 1)
    icl 'variables.asm'
        
    ; Game loading address
    ORG $4000
    
WeaponFont
    ins 'artwork/weapons_AW6_mod.fnt'  ; 'artwork/weapons.fnt'

    
;--------------------------------------------------
; Game Code
;--------------------------------------------------
FirstSTART
	jsr MakeDarkScreen

	; one time zero variables in RAM (non zero page)
	lda #0
	ldy #OneTimeZeroVariablesCount-1
@	  sta OneTimeZeroVariables,y
	  dey
	bpl @-
	
	; one time zero variables in RAM (zero page)
	ldy #FirstZpageVariable
@	sta $0000,y
	iny
	bne @-
	
	; initialize variables in RAM (non zero page)
	ldy #initialvaluesCount-1
@	  lda initialvaluesStart,y
	  sta variablesToInitialize,y
	  dey
	bpl @-

    ; set gradient to the full LGBTIQQAAPP+ flag on start
	mva #0 GradientNr	; #1 to set gradient number 2 :) (next one)
	jsr SelectNextGradient.NotWind

    ; generate linetables
	jsr GenerateLineTable


    ; RMT INIT
    lda #$f0                    ;initial value
    sta RMTSFXVOLUME            ;sfx note volume * 16 (0,16,32,...,240)

    lda #$ff                    ;initial value
    sta sfx_effect

    RMTSong 0

    VMAIN VBLinterrupt,7  		;jsr SetVBL
	
	mva #2 chactl  ; necessary for 5200

;--------------------------------------------------
; Main program of the game
    icl 'game.asm'
;--------------------------------------------------

	
;--------------------------------------------------
.proc GetKey
; waits for pressing a key and returns pressed value in A
; when [ESC] is pressed, escFlag is set
; result: A=keycode
;--------------------------------------------------
    jsr WaitForKeyRelease
@
      .IF TARGET = 800
          lda SKSTAT
          cmp #$ff
          beq checkJoyGetKey ; key not pressed, check Joy
          cmp #$f7  ; SHIFT
          beq checkJoyGetKey
	  .ELSE
		  lda SkStatSimulator
		  and #%11111110
		  bne checkJoyGetKey ; key not pressed, check Joy
      .ENDIF            
          lda kbcode
          cmp #@kbcode._none
          beq checkJoyGetKey
          and #$3f ;CTRL and SHIFT ellimination
          cmp #@kbcode._esc  ; 28  ; ESC
          bne getkeyend
            mvy #$80 escFlag
          bne getkeyend

checkJoyGetKey
      ;------------JOY-------------
      ;happy happy joy joy
      ;check for joystick now
      lda STICK0
      and #$0f
      cmp #$0f
      beq notpressedJoyGetKey
      tay 
      lda joyToKeyTable,y
      bne getkeyend

notpressedJoyGetKey
	;fire
	lda STRIG0
 	beq JoyButton
	.IF TARGET = 800	; Select and Option key only on A800
	bne checkSelectKey
checkSelectKey
	lda CONSOL
	and #%00000010	; Select
	beq SelectPressed
	lda CONSOL
	and #%00000100	; Option	
	.ENDIF
    bne @-
OptionPressed
	lda #@kbcode._atari	; Option key
	bne getkeyend	
SelectPressed
	lda #@kbcode._tab	; Select key
	bne getkeyend
JoyButton
    lda #@kbcode._ret ;Return key    
getkeyend
	ldy #0
    sty ATRACT	; reset atract mode	
    mvy #sfx_keyclick sfx_effect
    rts
.endp

;--------------------------------------------------
.proc getkeynowait
;--------------------------------------------------
    jsr WaitForKeyRelease 
    lda kbcode
    and #$3f ;CTRL and SHIFT ellimination
    rts
.endp

;--------------------------------------------------
.proc WaitForKeyRelease
;--------------------------------------------------
	mva #128-KeyRepeatSpeed pressTimer	; tricky
StillWait	
	bit pressTimer
	bmi KeyReleased
      lda STICK0
      and #$0f
      cmp #$0f
      bne StillWait
      lda STRIG0
      beq StillWait
    .IF TARGET = 800
      lda SKSTAT
      cmp #$ff
      bne StillWait
      lda CONSOL
      and #%00000110	; Select and Option only
      cmp #%00000110
      bne StillWait
	.ELSE
	lda SkStatSimulator
	and #%11111110
	beq StillWait
    .ENDIF
KeyReleased
      rts
.endp
;--------------------------------------------------
.proc IsKeyPressed
; result: A=0 - yes , A>0 - no
;--------------------------------------------------
	lda SKSTAT
	and #%00000100
	beq @+
	lda #1
@	and STRIG0
	rts
.endp
;--------------------------------------------------
.proc DemoModeOrKey
; Waits for the key pressed if at least one human is playing.
; Otherwise, waits 3 seconds (demo mode).
;--------------------------------------------------
    ;check demo mode
    ldx numberOfPlayers
    dex
checkForHuman ; if all in skillTable other than 0 then switch to DEMO MODE
    lda skillTable,x
    beq peopleAreHere
    dex
    bpl checkForHuman
    ; no people, just wait a bit
    ;pause 150
    ldy #75
    jsr PauseYFrames
    rts
peopleAreHere
    jmp getkey  ; jsr:rts
.endp

;--------------------------------------------------
MakeDarkScreen
;--------------------------------------------------
	jsr PMoutofScreen	; hide P/M
	mva #0 dmactls		; dark screen
	; and wait one frame :)
;--------------------------------------------------
.proc WaitOneFrame
;--------------------------------------------------
	lda CONSOL
	and #%00000101	; Start + Option
	sne:mva #$40 escFlag	
	and #%00000001 ; START KEY
	seq:wait	; or waitRTC ?
    rts
.endp

;--------------------------------------------------
.proc PauseYFrames
; Y - number of frames to wait (divided by 2)
; pauses for maximally 510 frames (255 * 2)
;--------------------------------------------------
@     jsr WaitOneFrame
      jsr WaitOneFrame
      dey
    bne @-
    rts
.endp

;--------------------------------------------------
.proc RmtSongSelect
;  starting song line 0-255 to A reg
;--------------------------------------------------
	cmp #song_ingame
	bne noingame	; noMusic blocks only ingame song
    bit noMusic
    spl:lda #song_silencio
noingame
	mvx #$ff RMT_blocked
    ldx #<MODUL                 ;low byte of RMT module to X reg
    ldy #>MODUL                 ;hi byte of RMT module to Y reg
    jsr RASTERMUSICTRACKER      ;Init
	mva #0 RMT_blocked
	rts
.endp
;-------------------------------------------------
.proc CopyFromROM
;-------------------------------------------------
;copy from CART to RAM
; trashes: Y
; temp: source
; temp2: destination
; modify: destination-end
;usage:
;    mwa #DisplayCopyRom temp
;    mwa #display temp2
;    mwa #DisplayCopyEnd+1 modify
;    jsr CopyFromROM

    ldy #0
@     lda (temp),y
      sta (temp2),y
      inw temp
      inw temp2
      cpw temp2 modify
    bne @-
    rts
.endp
;--------------------------------------------------
	icl 'C64/interrupts.asm'
;----------------------------------------------
    icl 'constants.asm'
;----------------------------------------------
    icl 'C64/textproc.asm'
;----------------------------------------------
    icl 'grafproc.asm'
;----------------------------------------------
    icl 'weapons.asm'
;----------------------------------------------
    icl 'ai.asm'
;----------------------------------------------
    icl 'artwork/talk.asm'
;----------------------------------------------
TankFont
    ins 'artwork/tanksv4.fnt',+0,384	; 48 characters only
;----------------------------------------------
font4x4
    ins 'artwork/font4x4s.bmp',+62
;----------------------------------------------
;RMT PLAYER loading shenaningans
    icl 'artwork/sfx/rmtplayr_modified.asm'
;-------------------------------------------------
.proc CheckTankCheat
    ldy #$07
    lda TankNr
    asl
    asl
    asl ; 8 chars per name
    tax
@
    lda CheatName,y
	sec
    sbc tanksnames,x
	cmp #$27
	bne NoCheat
    inx
    dey
    bpl @-
YesCheat
	ldx TankNr
	lda TanksWeaponsTableL,x
	sta temp
	lda TanksWeaponsTableH,x
	sta temp+1
	lda #99
@	iny
	sta (temp),y
	cpy #(number_of_weapons - 1)
	bne @-
NoCheat
    rts
.endp
CheatName
	dta d"   008.T"+$27
;----------------------------------------------
.proc DLIinterruptBFG
	pha
	lda dliCounter
	bne EndofBFGDLI
	lda dliColorsFore
	bit random
	bmi @+
	lda DliColorBack
@	sta COLPF2
	lda dliColorsFore
	bit random
	bmi @+
	lda DliColorBack
@	sta COLPF1
EndofBFGDLI
	inc dliCounter
    pla
    rti
.endp
; ------------------------
.proc BFGblink
	SetDLI DLIinterruptBFG	; blinking on
	ldy #50
	jsr PauseYFrames
	SetDLI DLIinterruptGraph	; blinking off
	rts
.endp
;--------------------------------------------------
    .IF * > MODUL-1
	  .ECHO *
      .ERROR 'Code and data too long'
    .ENDIF
    .ECHO "Bytes left: ",$b000-*
    
    
    org $b000                                    ;address of RMT module
MODUL                                            
                                                 ;RMT module is standard Atari binary file already
      ins "artwork/sfx/scorch_str9-NTSC.rmt",+6  ;include music RMT module
MODULEND
;----------------------------------------------
    icl 'constants_top.asm'
;----------------------------------------------
  
  .ECHO "Bytes on top left: ",$bfe8-* ;ROM_SETTINGS-*
  .IF target = 5200
    .IF * > ROM_SETTINGS-1
      .ERROR 'Code and RMT song too long to fit in 5200'
    .ENDIF
    org ROM_SETTINGS  ; 5200 ROM settings address $bfe8
    ;     "01234567890123456789"
    .byte " scorch supersystem "    ;20 characters title
    .byte " ", $ff          ;$BFFD == $ff means diagnostic cart, no splash screen
    .word FirstSTART
  .ELSE
     run FirstSTART
  .ENDIF
