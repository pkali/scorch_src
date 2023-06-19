;    @com.wudsn.ide.lng.mainsourcefile=scorch.asm
;Atari 8-bit Scorched Earth source code
;---------------------------------------------------
;by Tomasz 'pecus' Pecko and Pawel 'pirx' Kalinowski
;Warsaw 2000, 2001, 2002, 2003, 2009, 2012, 2013
;Miami & Warsaw 2022, 2023

;---------------------------------------------------
.IFNDEF TARGET
    .def TARGET = 800 ; 5200
.ENDIF
;WARNING! requires mads compiled on 2023-06-03 or later
;atari800  -5200 -cart ${outputFilePath} -cart-type 4
;atari800  -run ${outputFilePath}
;---------------------------------------------------
.def XCORRECTION_FOR_PM = 0
; if 1 - active x position of tanks correction fo PMG
.def FASTER_GRAF_PROCS = 1
; if 1 - activates faster graphics routines
;        (direct writes to screen memory - atari only :) )
;---------------------------------------------------

       ; OPT r+  ; saves 12 bytes, but does not work (yet): https://github.com/tebe6502/Mad-Assembler/issues/10 

;---------------------------------------------------
.macro build
    dta d"1.32" ; number of this build (4 bytes)
.endm

.macro RMTSong
      lda #:1
      jsr RMTSongSelect
.endm

;---------------------------------------------------
    icl 'definitions.asm'
;---------------------------------------------------

FirstZpageVariable = $54
    .zpvar DliColorBack        .byte = FirstZpageVariable
    .zpvar ClearSky         .byte   ; $ff - Crear sky during drawmountains, 0 - no clear sky
    .zpvar PaddleState      .byte   ; old state 2nd button for 2 buttons joysticks
    .zpvar GradientNr        .byte
    .zpvar GradientColors    .word
    .zpvar WindChangeInRound    .byte    ; wind change after each turn (not round only) flag - (0 - round only, >0 - each turn)
    .zpvar FastSoilDown     .byte   ; 0 - standard, >0 - fast
    .zpvar JoystickNumber    .byte
    .zpvar LazyFlag            .byte    ; 7 bit - run Lazy Darwin, 6 bit - run Lazy Boy or Darwin (!) after inventory, 0 - nothing
    .zpvar SpyHardFlag        .byte    ; >$7f - run SpyHard after inventory
    .zpvar Vdebug            .byte ; "visual debug" flag ($00 - off, $ff - on)
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
    .zpvar CreditsVScrol    .byte
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
    .zpvar UnderTank1        .byte
    .zpvar UnderTank2        .byte
    ;----------------------------
    .zpvar TestFlightFlag    .byte ; For AI test flights ($ff - test, $00 - standard shoot flight)
    .zpvar weaponPointer    .word
    .zpvar dliCounter       .byte
    .zpvar pressTimer       .byte
    .zpvar NTSCcounter      .byte
    .zpvar IsEndOfTheFallFlag .byte ; for small speedup ground falling
    .zpvar sfx_effect        .byte
    .zpvar RMT_blocked        .byte
    .zpvar ScrollFlag        .byte
    .zpvar SkStatSimulator    .byte
    .zpvar FloatingAlt        .byte    ; floating tank altitude
    .zpvar OverTankDir        .byte    ; (0 go right, $ff go left) direction of bypassing tanks on screen

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
    .zpvar escFlag .byte    ; 7 bit - Exit game, 6 bit - Exit to GameOver (cleared - exit to Menu), 0 - nothing
    .zpvar LineYdraw .byte
    .zpvar LineXdraw .word
    .zpvar plot4x4color .byte    ; $00 / $ff
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
    .IF TARGET = 800
      icl 'Atari/lib/ATARISYS.ASM'
      icl 'Atari/lib/MACRO.ASM'
      icl 'artwork/splash_v2/splash.asm'  ; splash screen and musix
      icl 'Atari/Manual/manual.asm'     ; manuals display
    .ELIF TARGET = 5200
      OPT h-f+  ; no headers, single block --> cart bin file
      icl 'Atari/lib/5200SYS.ASM'
      icl 'Atari/lib/5200MACRO.ASM'
      .enum @kbcode
        /*
        _0
        _1
        _2
        _3
        _4
        _5
        _6
        _7
        _8
        _9
        _asterisk = $0a
        _hash = $0b
        _start = $0c
        _pause = $0d
        _reset = $0e
        */
        _space = $00
        _Y     = $01
        _up    = $02
        _O     = $03
        _left  = $04
        _tab   = $05
        _right = $06
        _A     = $07
        _down  = $08
        _I     = $09
        _esc   = $0a
        _ret   = $fb  ;$0b ;not used in 5200
        _del   = $fc  ;$0c ;not used in 5200
        _M     = $0d
        _S     = $0e
        _atari = $fd  ; not used in 5200
        _none = $0f

      .ende
    .ENDIF

;-----------------------------------------------
; variable declarations in RAM (no code)
;-----------------------------------------------
    ORG PMGraph + $0300 - (variablesEnd - OneTimeZeroVariables + 1)
    icl 'variables.asm'

    ; Game loading address
    ORG $4000

WeaponFont
    ins 'artwork/weapons_AW6_mod.fnt'  ; 'artwork/weapons.fnt'

;-----------------------------------------------
;Screen displays go here to avoid crossing 4kb barrier
;-----------------------------------------------
    DisplayCopyRom = *
    org display, DisplayCopyRom
DisplayCopyStart
    icl 'Atari/display_main_menu.asm'
DisplayCopyEnd
    org DisplayCopyRom + (DisplayCopyEnd - DisplayCopyStart)

    DisplayCopyPurchaseDlROM = *
    org DisplayCopyPurchase, DisplayCopyPurchaseDlROM
DisplayCopyPurchaseStart
    icl 'Atari/display_purchasedl.asm'
DisplayCopyPurchaseEnd
    org DisplayCopyPurchaseDlROM + (DisplayCopyPurchaseEnd - DisplayCopyPurchaseStart)

    StatusBufferROM = *
    org StatusBufferCopy, StatusBufferROM
StatusBufferCopyStart
    icl 'Atari/display_status.asm'
StatusBufferCopyEnd
    org StatusBufferROM + (StatusBufferCopyEnd - StatusBufferCopyStart)


    icl 'Atari/display_static.asm'
;----------------------------------------------

;--------------------------------------------------
; Game Code
;--------------------------------------------------
FirstSTART
    .IF TARGET = 5200
    ; start in 5200 diagnostic mode
    ; move original startup procedure to RAM

    Modified5200Splash = $2100  ; apparently there is some free space here
    ; check kernel version
    Atari5200KernelByte = $fff8
    ; $32 - 4 joy
    ; $00 - 2 joy
    ; $ff - Altirra kernel

    lda Atari5200KernelByte
    beq rom2joy
    cmp #$32
    beq rom4joy
altirra_kernel
    mwa #Modified5200Splash+$8a modify
    bne @+  ; JMP

rom4joy
    mwa #Modified5200Splash+$16b modify
    bne @+  ; JMP

rom2joy
    mwa #Modified5200Splash+$181 modify
@
    mwa $fffc temp  ; startup proc address
    mwa #Modified5200Splash temp2
    jsr CopyFromROM
    ; modify the end of the splash procedure
    lda #$60  ; rts
    sta (temp2),y

    jsr Modified5200Splash+$0f  ; after the diag cart detection
    ; modify the text
    splash_text = $3c80 ; '.scorch.supersystem.copyright.19xx.atari'
    splash_year = splash_text + $1e
    splash_copyright = splash_text + $14
    ldy #19    ; 20 characters
@    lda NewSplashText,y
    sta splash_copyright,y
    dey
    bpl @-

    ; splash screen delay. maybe add fire to speed up?
@    cpx RTCLOK+1
    bne @-
no5200splash
    .ENDIF
    jsr MakeDarkScreen

    ; one time zero variables in RAM (non zero page)
    lda #0
    ldy #OneTimeZeroVariablesCount-1
@      sta OneTimeZeroVariables,y
      dey
    bpl @-

    ; one time zero variables in RAM (zero page)
    ldy #FirstZpageVariable
@    sta $0000,y
    iny
    bne @-

    ; initialize variables in RAM (non zero page)
    ldy #initialvaluesCount-1
@      lda initialvaluesStart,y
      sta variablesToInitialize,y
      dey
    bpl @-

    ; set gradient to the full LGBTIQQAAPP+ flag on start
    mva #0 GradientNr    ; #1 to set gradient number 2 :) (next one)
    jsr SelectNextGradient.NotWind

    ; generate linetables
    jsr GenerateLineTable

    .IF TARGET = 800
      ; pokeys init
      lda #3    ; stereo
      sta POKEY+$0f ; stereo
      sta POKEY+$1f ; stereo
  
      lda PAL
      and #%00001110
      bne NoRMT_PALchange
      ;it is PAL here
      ; Change RMT to PAL version
      ; 5 values in RMT file
      ; not elegant :(
      mva #$06 MODUL-6+$967    ; $07 > $06
      sta MODUL-6+$bc3    ; $07 > $06
      sta MODUL-6+$e69    ; $08 > $06
      sta MODUL-6+$ebc    ; $08 > $06
      mva #$10 MODUL-6+$a69    ; $12 > $10
      mva #$04 MODUL-6+$bf8    ; $05 > $04
      mva #$08 MODUL-6+$e3d    ; $0a > $08
  
      ; and mountains colors table address
      mva #<dliColorsFore2PAL GradientAddrL+2
      mva #>dliColorsFore2PAL GradientAddrH+2
NoRMT_PALchange
    .ELIF TARGET = 5200
      mva #$7f SkStatSimulator
    .ENDIF


    ; RMT INIT
    lda #$f0                    ;initial value
    sta RMTSFXVOLUME            ;sfx note volume * 16 (0,16,32,...,240)

    lda #$ff                    ;initial value
    sta sfx_effect

    RMTSong 0

    .IF TARGET = 5200
        mva #$0f STICK0
        mva #$04 CONSOL5200          ;Speaker off, Pots enabled, port #1 selected
        mwa #kb_continue VKEYCNT     ;Keyboard handler
    .ENDIF
    VMAIN VBLinterrupt,7          ;jsr SetVBL

    mva #2 chactl  ; necessary for 5200

;--------------------------------------------------
; Main program of the game
    icl 'game.asm'
;--------------------------------------------------

.proc SetJoystickPort
    sta JoystickNumber
    .IF TARGET = 800    ; second joy button state update only on A800
    jsr WaitOneFrame         ; is necessary for update shadow registers (PADDL0) in VBI
    jmp GetKey.Check2button  ; update state second joy button
    .ELSE
    rts
    .ENDIF
.endp

;--------------------------------------------------
.proc GetKey
; waits for pressing a key and returns pressed value in A
; when [ESC] is pressed, escFlag is set
; result: A=keycode
;--------------------------------------------------
    jsr WaitForKeyRelease
getKeyAfterWait
    .IF TARGET = 800
      lda SKSTAT
      cmp #$ff
      beq checkJoyGetKey ; key not pressed, check Joy
      cmp #$f7  ; SHIFT
      beq checkJoyGetKey
    .ELIF TARGET = 5200
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
    .IF TARGET = 800    ; Second joy button , Select and Option key only on A800
      jsr Check2button
      bcc SecondButton
      bne checkSelectKey
checkSelectKey
      lda CONSOL
      and #%00000010    ; Select
      beq SelectPressed
      lda CONSOL
      and #%00000100    ; Option
    .ENDIF
    bne getKeyAfterWait
OptionPressed
    lda #@kbcode._atari    ; Option key
    bne getkeyend
SecondButton
SelectPressed
    lda #@kbcode._tab    ; Select key
    bne getkeyend
JoyButton
    lda #@kbcode._ret ;Return key
getkeyend
    ldy #0
    sty ATRACT    ; reset atract mode
    mvy #sfx_keyclick sfx_effect
    rts
    .IF TARGET = 800    ; Second joy button only on A800
Check2button
    lda PADDL0
    and #$c0
    eor #$C0
    cmp PaddleState
    sta PaddleState
    rts
    .ENDIF
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
    mva #128-KeyRepeatSpeed pressTimer    ; tricky
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
      ; second joy button
;      jsr GetKey.Check2button
;      bcs StillWait
      lda SKSTAT
      cmp #$ff
      bne StillWait
      lda CONSOL
      and #%00000110    ; Select and Option only
      cmp #%00000110
      bne StillWait
    .ELIF TARGET = 5200
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
@   and STRIG0
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
    jmp PauseYFrames
    ; rts
peopleAreHere
    jmp getkey  ; jsr:rts
.endp

;--------------------------------------------------
MakeDarkScreen
;--------------------------------------------------
    jsr PMoutofScreen    ; hide P/M
    mva #0 dmactls        ; dark screen
    ; and wait one frame :)
;--------------------------------------------------
.proc WaitOneFrame
;--------------------------------------------------
    lda CONSOL
    and #%00000001 ; START KEY
    seq:wait    ; or waitRTC ?
    rts
.endp

;--------------------------------------------------
.proc PauseYFrames
; Y - number of frames to wait (divided by 2)
; pauses for maximally 510 frames (255 * 2)
;--------------------------------------------------
@   jsr WaitOneFrame
    jsr WaitOneFrame
    dey
    bne @-
    rts
.endp

;--------------------------------------------------
.proc CheckExitKeys
;--------------------------------------------------
; Checks keyboard and sets appropriate flags for exit procedures
; If START+OPTION is pressed - exit to GameOver screen
; If 'O' key is pressed - displays "Are you sure?" and - exit to GameOver screen
; If 'Esc' key is pressed - displays "Are you sure?" and - exit to Menu screen
; Just setting the right flags!!!

    ; Select and Option
    lda CONSOL
    and #%00000101    ; Start + Option
    beq QuitToGameover
    lda SKSTAT
    cmp #$ff
    jeq nokeys
    cmp #$f7  ; SHIFT
    jeq nokeys

    lda kbcode
    and #%10111111 ; SHIFT elimination

    cmp #@kbcode._O  ; $08  ; O
    bne CheckEsc
    jsr AreYouSure
    bit escFlag
    bpl nokeys
    ;---O pressed-quit game to game over screen---
QuitToGameover
    mva #$C0 escFlag    ; bits 7 and 6 set
    rts
CheckEsc
    cmp #@kbcode._esc  ; 28  ; ESC
    bne nokeys
DisplayAreYouSure
    jsr AreYouSure
    ;---esc pressed-quit game---
nokeys
    bit escFlag
    rts
;
.endp
;--------------------------------------------------
.proc ShellDelay
;--------------------------------------------------
    lda CONSOL
    and #%00000001 ; START KEY
    beq noShellDelay
    ldy flyDelay
DelayLoop
      lda VCOUNT
@     cmp VCOUNT
      beq @-
      dey
    bne DelayLoop
noShellDelay
    rts
.endp

;--------------------------------------------------
.proc RmtSongSelect
;  starting song line 0-255 to A reg
;--------------------------------------------------
    cmp #song_ingame
    bne noingame    ; noMusic blocks only ingame song
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
    icl 'Atari/interrupts.asm'
;----------------------------------------------
    icl 'constants.asm'
;----------------------------------------------
    icl 'Atari/textproc.asm'
;----------------------------------------------
    icl 'grafproc.asm'
    icl 'Atari/gr_basics.asm'
;----------------------------------------------
    icl 'weapons.asm'
;----------------------------------------------
    icl 'ai.asm'
;----------------------------------------------
    icl 'artwork/talk.asm'
;----------------------------------------------
TankFont
    ins 'artwork/tanksv4.fnt',+0,384    ; 48 characters only
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
@    iny
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
@    sta COLPF2
    lda dliColorsFore
    bit random
    bmi @+
    lda DliColorBack
@    sta COLPF1
EndofBFGDLI
    inc dliCounter
    pla
    rti
.endp
; ------------------------
.proc BFGblink
    SetDLI DLIinterruptBFG    ; blinking on
    ldy #50
    jsr PauseYFrames
    SetDLI DLIinterruptGraph    ; blinking off
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
  .IF TARGET = 800
     run FirstSTART
  .ELIF TARGET = 5200
    .IF * > ROM_SETTINGS-1
      .ERROR 'Code and RMT song too long to fit in 5200'
    .ENDIF
    org ROM_SETTINGS  ; 5200 ROM settings address $bfe8
    ;     "01234567890123456789"
    .byte " scorch supersystem "    ;20 characters title
    .byte " ", $ff          ;$BFFD == $ff means diagnostic cart, no splash screen
    .word FirstSTART
  .ENDIF
