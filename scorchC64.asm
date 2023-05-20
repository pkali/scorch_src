;    @com.wudsn.ide.asm.mainsourcefile=scorch.asm
;C64 8-bit Scorched Earth source code
;---------------------------------------------------
;by Tomasz 'pecus' Pecko and Pawel 'pirx' Kalinowski
;Warsaw 2000, 2001, 2002, 2003, 2009, 2012, 2013
;Miami & Warsaw 2022, 2023

;---------------------------------------------------
.def TARGET = 64 ; :)
;---------------------------------------------------
.def XCORRECTION_FOR_PM = 0
; if 1 - active x position of tanks correction fo PMG
.def FASTER_GRAF_PROCS = 1
; if 1 - activates faster graphics routines
;        (direct writes to screen memory - C64 only :) )
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
      lda #:1     ; do nothing in C64
.endm

;---------------------------------------------------
    icl 'definitions.asm'
;---------------------------------------------------

FirstZpageVariable = $58 ; $57
    .zpvar DliColorBack        .byte = FirstZpageVariable
    .zpvar GradientNr        .byte
    .zpvar GradientColors    .word
    .zpvar WindChangeInRound    .byte    ; wind change after each turn (not round only) flag - (0 - round only, >0 - each turn)
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
      icl 'C64/lib/C64_ATARISYS.ASM'
      icl 'C64/lib/C64SYS.ASM'
      icl 'C64/lib/MACRO.ASM'
    
;-----------------------------------------------
; variable declarations in RAM (no code)
;-----------------------------------------------
        
    ; Game loading address
    ORG $4100
    icl 'variables.asm'
    
WeaponFont
    ins 'artwork/weapons_AW6_mod.fnt'  ; 'artwork/weapons.fnt'

    
;--------------------------------------------------
; Game Code
;--------------------------------------------------
FirstSTART
    DL = 0
    StatusBufferROM = 0
    ;StatusBufferCopy = 0
    StatusBufferCopyEnd = 0
    TRACKS = 4
    DisplayCopyPurchaseEnd = 0
    DisplayCopyPurchaseStart = 0
    displayC64 = $2000    ;    graphics screen memory start

        SEI             ; disable IRQ
         LDA #$36
        STA $0001      ; Turn Off BASIC ROM
        LDA #<NMI    ;
        STA $0318       ; change NMI vector
        LDA #>NMI    ; to our routine
        STA $0319       ;
        LDA #$00        ; stop Timer A
        STA $DD0E       ;
        STA $DD04       ; set Timer A to 0, after starting
        STA $DD05       ; NMI will occur immediately
        LDA #$81        ;
        STA $DD0D       ; set Timer A as source for NMI
        LDA #$01        ;
        STA $DD0E       ; start Timer A -> NMI

                        ; from here on NMI is disabled

    
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


    ; generate linetables
    jsr GenerateLineTable


    ; Random INIT
    InitializeSIDrnd

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
    lda #0
    sta escFlag
    lda #$ff
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
StillWait
      rts
.endp
;--------------------------------------------------
.proc IsKeyPressed
; result: A=0 - yes , A>0 - no
;--------------------------------------------------
    lda #1
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
;    mva #0 dmactls        ; dark screen
    ; and wait one frame :)
;--------------------------------------------------
.proc WaitOneFrame
;--------------------------------------------------
    wait    ; or waitRTC ?
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
.proc CheckExitKeys
;--------------------------------------------------
; Checks keyboard and sets appropriate flags for exit procedures
; If START+OPTION is pressed - exit to GameOver screen
; If 'O' key is pressed - displays "Are you sure?" and - exit to GameOver screen
; If 'Esc' key is pressed - displays "Are you sure?" and - exit to Menu screen
; Just setting the right flags!!!

    rts
;
.endp
;--------------------------------------------------
.proc ShellDelay
    ldx flyDelay
DelayLoop
      lda $d012
@     cmp $d012
      beq @-
      lda $d012
@     cmp $d012
      beq @-
      dex
    bne DelayLoop
noShellDelay
    rts
.endp
;--------------------------------------------------
.proc RmtSongSelect
;  starting song line 0-255 to A reg
;--------------------------------------------------
    rts
.endp
.proc CopyFromRom
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
    icl 'C64/gr_basics.asm'    
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
;    SetDLI DLIinterruptBFG    ; blinking on
    ldy #50
    jsr PauseYFrames
;    SetDLI DLIinterruptGraph    ; blinking off
    rts
.endp
;----------------------------------------------
    icl 'constants_top.asm'
;----------------------------------------------
NMI
         INC $D020      ; change border colour, indication for a NMI
        RTI             ; exit interrupt
                        ; (not acknowledged!)
  