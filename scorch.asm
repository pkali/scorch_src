;    @com.wudsn.ide.lng.mainsourcefile=scorch.asm

;Atari 8-bit Scorch source code
;---------------------------------------------------
;by Tomasz 'pecus' Pecko and Pawel 'pirx' Kalinowski
;Warsaw 2000, 2001, 2002, 2003, 2009, 2012, 2013
;Miami & Warsaw 2022, 2023, 2024

;WUDSN run settings:
;atari800  -5200 -cart ${outputFilePath} -cart-type 4
;atari800  -run ${outputFilePath}


;WARNING! requires mads compiled on 2023-09-13 or later
;compilation:
;mads scorch.asm -o:scorch.bin -d:TARGET=5200
;mads scorch.asm -o:scorch.xex -d:TARGET=800
;mads scorch.asm -o:scorch.xex -d:TARGET=800 -d:SPLASH=1  #xex version with splash
;mads scorch.asm -o:scorch.xex -d:TARGET=800 -d:SPLASH=1 -d:CART_VERSION=1 #xex version for cart


;---------------------------------------------------
.IFNDEF TARGET
    .def TARGET = 800 ; 5200
.ENDIF
;---------------------------------------------------
.ifndef SPLASH
    .def SPLASH = 0         ; if 0 - no splash screens
.endif
.ifndef CART_VERSION
    .def CART_VERSION = 0    ; if 1 - dual splash screen
.endif
.def METEORS = 1             ; if 1 - meteors on game
.def VU_METER = 1             ; if 1 - VU Meter on game
.def XCORRECTION_FOR_PM = 0  ; if 1 - active x position of tanks correction fo PMG
.def FASTER_GRAF_PROCS = 1   ; if 1 - activates faster graphics routines
                             ; (direct writes to screen memory - atari only :) )
;---------------------------------------------------

         OPT r+  ; saves 10 bytes, and probably works :) https://github.com/tebe6502/Mad-Assembler/issues/10

;---------------------------------------------------
.macro build
    dta d"1.55" ; number of this build (4 bytes)
.endm
.macro year
    dta d"2025" ; year of this build (4 bytes)
.endm

.macro RMTSong
      lda #:1
      jsr RMTSongSelect
.endm

;---------------------------------------------------
    icl 'definitions.asm'
;---------------------------------------------------
AdditionalZPvariables = $20
    .zpvar EplotX           .word = AdditionalZPvariables
    .zpvar EplotByte        .word
    .zpvar EplotY           .byte
    .zpvar Mpoint1X         .word  ; meteor first point X position
    .zpvar Mpoint2X         .word  ; meteor last point X position
    .zpvar Mpoint1Y         .byte  ; meteor first point Y position
    .zpvar Mcounter         .byte  ; meteor length counter ( $ff - no meteor on sky )
    .zpvar Mpoint2Y         .byte  ; meteor last point Y position
    .zpvar MeteorsFlag      .byte  ; set 7th bit - block meteors
    .zpvar MeteorsRound     .byte  ; set 7th bit - block meteors in round
    

FirstZpageVariable = $4f
    .zpvar DliColorBack     .byte = FirstZpageVariable
    .zpvar ClearSky         .byte  ; $ff - Crear sky during drawmountains, 0 - no clear sky
    .zpvar PaddleState      .byte  ; old state 2nd button for 2 buttons joysticks
    .zpvar GradientNr       .byte
    .zpvar GradientColors   .word
    .zpvar JoystickNumber   .byte
    .zpvar LazyFlag         .byte  ; 7 bit - run Lazy Darwin, 6 bit - run Lazy Boy or Darwin (!) after inventory
                                   ; 0 - nothing
    .zpvar SpyHardFlag      .byte  ; >$7f - run SpyHard after inventory
    .zpvar Vdebug           .byte  ; "visual debug" flag ($00 - off, $ff - on)
    .zpvar xdraw            .word  ; = $64 ;variable X for plot
    .zpvar ydraw            .word  ; variable Y for plot 
                                   ; (like in Atari Basic - Y=0 in upper right corner of the screen)
    .zpvar xbyte            .word
    .zpvar ybyte            .word
    .zpvar CharCode         .byte
    .zpvar fontind          .word
    .zpvar tanknr           .byte
    .zpvar oldplot          .word
    .zpvar xc               .word
    .zpvar temp             .word  ; temporary word for the most embeded loops only
    .zpvar temp2            .word  ; same as above
    .zpvar modify           .word  ; origially used to replace self-modyfying code
    .zpvar tempXROLLER      .word  ; same as above for XROLLER routine (used also in result display routine)
    .zpvar xtempDRAW        .word  ; same as above for XDRAW routine
    .zpvar ytempDRAW        .word  ; same as above for XDRAW routine
    .zpvar tempor2          .word
    .zpvar CreditsVScrol    .byte
    ;--------------temps used in circle routine
    .zpvar xi               .word  ; X (word) in draw routine
    .zpvar fx               .byte
    .zpvar yi               .word  ; Y (word) in draw routine
    .zpvar fy               .byte
    .zpvar xk               .word
    .zpvar fs               .byte
    .zpvar yc               .byte  ; ycircle - temporary for circle
    .zpvar dx               .word
    .zpvar dy               .word
    .zpvar dd               .word
    .zpvar di               .word
    .zpvar dp               .word
    ;----------------------------
    .zpvar UnderTank1       .byte
    .zpvar UnderTank2       .byte
    ;----------------------------
    .zpvar TestFlightFlag   .byte  ; For AI test flights ($ff - test, $00 - standard shoot flight)
    .zpvar weaponPointer    .word
    .zpvar dliCounter       .byte
    .zpvar pressTimer       .byte
    .zpvar NTSCcounter      .byte
    .zpvar sfx_effect       .byte
    .zpvar RMT_blocked      .byte
    .zpvar ScrollFlag       .byte
    .zpvar SkStatSimulator  .byte
    .zpvar FloatingAlt      .byte  ; floating tank altitude
    .zpvar OverTankDir      .byte  ; (0 go right, $ff go left) direction of bypassing tanks on screen

    ; --------------OPTIMIZATION VARIABLES--------------
    .zpvar Force            .word
    .zpvar Force_           .byte  ; Force is 3 bytes long
    .zpvar Angle            .byte
    .zpvar Parachute        .byte  ; are you insured with parachute?
    .zpvar color            .byte
    .zpvar Erase            .byte  ; if 1 only mask of the character is printed
                                   ; on the graphics screen. if 0 character is printed normally
    .zpvar radius           .byte
    .zpvar decimal          .word
    .zpvar NumberOfPlayers  .byte  ; current number of players (counted from 1)
    .zpvar Counter          .byte  ; temporary Counter for outside loops
    .zpvar ExplosionRadius  .byte
    .zpvar FunkyBombCounter .byte
    .zpvar ResultY          .byte
    .zpvar xcircle          .word
    .zpvar ycircle          .word
    .zpvar vy               .word
    .zpvar vy_              .word  ; 4 bytes
    .zpvar vx               .word
    .zpvar vx_              .word  ; 4 bytes
    .zpvar HitFlag          .byte  ; $ff when missile hit ground, $00 when no hit,
                                   ; $01-$06 tank index+1 when hit tank
    .zpvar PositionOnTheList   .byte ; pointer position on the list being displayed
    .zpvar FirstKeypressDelay  .byte
    .zpvar IsEndOfTheFallFlag  .byte ;for small speedup ground falling
    .zpvar TankSequencePointer .byte
    .zpvar WindChangeInRound   .byte ; wind change after each turn (not round only) flag
                                     ; (0 - round only, >0 - each turn)
    .zpvar RandomMountains  .byte  ; mountains type change after each turn flag
                                   ; (0 - round only, >0 - each turn)
    .zpvar FastSoilDown     .byte  ; 0 - standard, >0 - fast
    .zpvar BlackHole        .byte  ; 0 - no, >0 - yes
    .zpvar TeamGame         .byte  ; 0 - no, >0 - Teams
    .zpvar XHit             .word
    .zpvar delta            .word
    .zpvar HowMuchToFall    .byte
    .zpvar magic            .word  ; worst var name in the whole business
    .zpvar xtraj            .word
    .zpvar xtraj_           .byte  ; 3 bytes
    .zpvar ytraj            .word
    .zpvar ytraj_           .byte  ; 3 bytes
    .zpvar Wind             .word
    .zpvar Wind_            .word  ; 4 bytes
    .zpvar RangeLeft        .word
    .zpvar RangeRight       .word
    .zpvar NewAngle         .byte
    .zpvar escFlag          .byte  ; 7 bit - Exit game, 
                                   ; 6 bit - Exit to GameOver (cleared - exit to Menu), 0 - nothing
    .zpvar LineYdraw        .byte
    .zpvar LineXdraw        .word
    .zpvar plot4x4color     .byte  ; $00 / $ff
    .zpvar Multiplier       .word
    .zpvar Multiplier_      .byte  ; 3 bytes
    .zpvar HowToDraw        .byte
    .zpvar DrawDirFactor    .byte
    .zpvar gravity          .byte
    .zpvar LineLength       .word
    .zpvar tracerflag       .byte
    .zpvar isInventory      .byte
    .zpvar DifficultyLevel  .byte
    .zpvar goleft           .byte
    .zpvar OffsetDL1        .byte
    .zpvar L1               .byte
    HotNapalmFlag = FunkyBombCounter  ; variable reuse!
    displayposition = modify
    LineAddress4x4 = xcircle
    ;* RMT ZeroPage addresses in artwork/sfx/rmtplayr_modified.asm

;-----------------------------------------------
; libraries
;-----------------------------------------------
    .IF TARGET = 800
      icl 'Atari/lib/ATARISYS.ASM'
      icl 'Atari/lib/MACRO.ASM'
      .IF SPLASH = 1
        icl 'artwork/splash_v2/splash.asm'  ; new splash screen and musix
        .IF CART_VERSION = 1
          icl 'artwork/splash_v1/splash.asm'  ; old splash screen (plays music from new splash)
        .ENDIF
      .ELSE
        ; no splash.... dark screean and BASIC off
        ORG $2000
        mva #0 dmactls             ; dark screen
        mva #$ff portb
        ; and wait one frame :)
        seq:wait                   ; or waitRTC ?
        mva #$ff portb        ; BASIC off
        rts
        ini $2000
      .ENDIF
    .ELIF TARGET = 5200
      OPT h-f+  ; no headers, single block --> cart bin file
      icl 'Atari/lib/5200SYS.ASM'
      icl 'Atari/lib/5200MACRO.ASM'
      .enum @kbcode
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
        _help  = $0b  ; Visual Debug in 5200
        _del   = $fc  ; $0c ;not used in 5200
        _M     = $0d
        _S     = $0e
        _atari = $fd  ; not used in 5200
        _ret   = $0c  ; fire in 5200
        _none  = $0f
      .ende
    .ENDIF

;-----------------------------------------------
; variable declarations in RAM (no code)
;-----------------------------------------------
    ORG PMGraph + $0300 - (variablesEnd - OneTimeZeroVariables)
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
@     lda NewSplashText,y
      sta splash_copyright,y
      dey
    bpl @-

    ; splash screen delay. maybe add fire to speed up?
@    cpx RTCLOK+1
    bne @-
no5200splash
    .ENDIF
StartAfterSplash
    jsr MakeDarkScreen
    
    ; one time zero variables in RAM (non zero page)
    lda #0
    ldy #OneTimeZeroVariablesCount-1
@     sta OneTimeZeroVariables,y
      dey
    bpl @-

    ; one time zero variables in RAM (zero page)
    ldy #FirstZpageVariable
@     sta $0000,y
      iny
    bne @-

    ; initialize variables in RAM (non zero page)
    ldy #initialvaluesCount-1
@     lda initialvaluesStart,y
      sta variablesToInitialize,y
      dey
    bpl @-

    ; set teams names
    ldy #5
@   lda Team_Header,y
    sta TanksNames+(6*8),y
    sta TanksNames+(7*8),y
    dey
    bpl @-
    inc TanksNames+(7*8) ; B-Team :)

    ; set gradient to the full LGBTIQQAAPP+ flag on start
    .IF CART_VERSION = 1
       mva #$ff GradientNr  ; #1 to set gradient number 2 :) (next one) - 0 (B/W)
    .ELSE
       .IF TARGET=5200
         mva #1 GradientNr
       .ELSE
         mva #0 GradientNr    ; #1 to set gradient number 2 :) (next one) - 1 (polish rainbow)
       .ENDIF
    .ENDIF
    jsr SelectNextGradient.NotWind

    ; generate linetables
    jsr GenerateLineTable

    .IF TARGET = 800
      ; pokeys init
      lda #3        ; stereo (pseudo)
      sta POKEY+$0f ; stereo
      sta POKEY+$1f ; stereo
    .IF CART_VERSION = 0
      sta COLDST    ; Cold start after Reset key
    .ENDIF
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
    lda #$f0                   ; initial value
    sta RMTSFXVOLUME           ; sfx note volume * 16 (0,16,32,...,240)

    lda #$ff                   ; initial value
    sta sfx_effect
    sta Mcounter
    sta MeteorsFlag
    
    RMTSong 0

    .IF TARGET = 5200
      mva #$0f STICK0
      mva #$04 CONSOL5200      ; Speaker off, Pots enabled, port #1 selected
      mwa #kb_continue VKEYCNT ; Keyboard handler
    .ENDIF
    VMAIN VBLinterrupt,7       ; jsr SetVBL

    mva #2 chactl              ; necessary for 5200

;--------------------------------------------------
; Main program of the game
    icl 'game.asm'
;--------------------------------------------------

.proc SetJoystickPort
    sta JoystickNumber
    .IF TARGET = 800           ; second joy button state update only on A800
      jsr WaitOneFrame         ; is necessary for update shadow registers (PADDL0) in VBI
      jmp GetKeyFast.Check2button  ; update state second joy button
    .ELSE
      rts
    .ENDIF
.endp


;--------------------------------------------------
MakeDarkScreen
;--------------------------------------------------
    jsr PMoutofScreen          ; hide P/M
    mva #0 dmactls             ; dark screen
    ; and wait one frame :)
;--------------------------------------------------
.proc WaitOneFrame
;--------------------------------------------------
    jsr CheckStartKey             ; START KEY
    seq:wait                   ; or waitRTC ?
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
.proc ShellDelay
;--------------------------------------------------
    ldy flyDelay
Y   jsr CheckStartKey             ; START KEY
    beq noShellDelay
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
    cmp #song_main_menu
    beq noingame               ; noMusic blocks only ingame songs
    bit noMusic
    spl:lda #song_silencio
noingame
    mvx #$ff RMT_blocked
    ldx #<MODUL                ; low byte of RMT module to X reg
    ldy #>MODUL                ; hi byte of RMT module to Y reg
    jsr RASTERMUSICTRACKER     ; Init
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
    icl 'Atari/inputs.asm'
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
    icl 'artwork/talk_packed.asm'
;----------------------------------------------
TankFont
    ins 'artwork/tanksv4.fnt',+0,384   ; 48 characters only
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
    asl                        ; 8 chars per name
    tax
@     lda CheatName,y
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
@     iny
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
    smi:lda DliColorBack
    sta COLPF2
    lda dliColorsFore
    bit random
    smi:lda DliColorBack
    sta COLPF1
EndofBFGDLI
    inc dliCounter
    pla
    rti
.endp
; ------------------------
.proc BFGblink
    SetDLI DLIinterruptBFG     ; blinking on
    ldy #50
    jsr PauseYFrames
    SetDLI DLIinterruptGraph   ; blinking off
    rts
.endp
;--------------------------------------------------
    .IF * > MODUL-1
      .ECHO *
      .ERROR 'Code and data too long'
    .ENDIF
    .ECHO "Bytes left: ",$b000-*


    org $b000  ; address of RMT module
MODUL
               ; RMT module is standard Atari binary file already
               ; include music RMT module:
      ins "artwork/sfx/scorch_str9-NTSC.rmt",+6
MODULEND
;----------------------------------------------
    icl 'constants_top.asm'
;----------------------------------------------

  .ECHO "Bytes on top left: ",$bfe8-* ; ROM_SETTINGS-*
  .IF TARGET = 800
     run FirstSTART
  .ELIF TARGET = 5200
    .IF * > ROM_SETTINGS-1
      .ERROR 'Code and RMT song too long to fit in 5200'
    .ENDIF
    org ROM_SETTINGS             ; 5200 ROM settings address $bfe8
    ;     "01234567890123456789"
    .byte " scorch supersystem " ; 20 characters title
    .byte " ", $ff               ; $BFFD == $ff means diagnostic cart, no splash screen
    .word FirstSTART
  .ENDIF
