;    @com.wudsn.ide.lng.mainsourcefile=RANDOM_test.asm

;mads RANDOM_test.asm -o:RANDOM_test.bin -d:TARGET=5200
;mads RANDOM_test.asm -o:RANDOM_test.xex -d:TARGET=800


;---------------------------------------------------
.IFNDEF TARGET
    .def TARGET = 800 ; 5200
.ENDIF
;---------------------------------------------------
         OPT r+  ; saves 10 bytes, and probably works :) https://github.com/tebe6502/Mad-Assembler/issues/10

;---------------------------------------------------

;---------------------------------------------------
;---------------------------------------------------
FirstZpageVariable = $50
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
    ;* RMT ZeroPage addresses in artwork/sfx/scorch_str9-NTSC.rmt

DISPLAY = $1000
SCREENHEIGHT = 256
screenwidth = 32
;-----------------------------------------------
; libraries
;-----------------------------------------------
    .IF TARGET = 800
      icl 'Atari/lib/ATARISYS.ASM'
      icl 'Atari/lib/MACRO.ASM'
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
    ORG $3000
    ; These tebles are at the beginning of memory pages becouse ....
bittable1_long
    .ds $100
bittable2_long
    .ds $100
linetableL
    .ds (screenHeight)
linetableH
    .ds (screenHeight)
    

    ; loading address
    ORG $4000

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

    ; generate linetables
    jsr GenerateLineTable

    .IF TARGET = 800
      ; pokeys init
      lda #3        ; stereo (pseudo)
      sta POKEY+$0f ; stereo
      sta POKEY+$1f ; stereo
    .ELIF TARGET = 5200
      mva #$7f SkStatSimulator
    .ENDIF


    .IF TARGET = 5200
      mva #$0f STICK0
      mva #$04 CONSOL5200      ; Speaker off, Pots enabled, port #1 selected
      mwa #kb_continue VKEYCNT ; Keyboard handler
    .ENDIF
    VMAIN VBLinterrupt,7       ; jsr SetVBL

    mva #2 chactl              ; necessary for 5200

        mwa #dl dlptrs  ; issue #72 (glitches when switches)
    mva #@dmactl(narrow|dma) dmactls
    
@    
    mva random xdraw

    ;mva random ydraw
    lda random
    ;and #%00111111
    sta ydraw
    
    ; let's calculate coordinates from xdraw and ydraw

    ;xbyte = xbyte/8
    lda xdraw
    :3 lsr
    sta xbyte
    ;---
    ldx ydraw
    ldy linetableL,x
    lda linetableH,x
    sta xbyte+1

    ldx xdraw   ; optimization (256 bytes long bittable)
    
    lda (xbyte),y
    ora bittable1_long,x
    sta (xbyte),y

    
    jmp @-
    
dl
    .byte SKIP8, SKIP8, SKIP8
    .byte LMS|MODEF
    .word DISPLAY
    :127 .byte MODEF
    .byte JVB
    .word dl
    
;--------------------------------------------------
.proc GenerateLineTable

    mwa #display temp
    mwa #linetableL temp2
    mwa #linetableH modify
    ldy #0
@     lda temp
      sta (temp2),y
      lda temp+1
      sta (modify),y
      adw temp #screenwidth
      iny
      cpy #0  ;#screenheight+1
    bne @-
    ; and bittables for fastest plot and point (thanks @jhusak)
    ldy #0
    lda #$40
@   asl
    adc #0
    sta bittable1_long,y
    tax
    eor #%11111111
    sta bittable2_long,y
    txa
    dey
    bne @-
endof
    rts
.endp
; -----------------------------------------
.proc plot  ;plot (xdraw, ydraw, color)
; color == 1 --> put pixel
; color == 0 --> erase pixel
; xdraw (word) - X coordinate
; ydraw (word) - Y coordinate
; this is one of the most important routines in the whole
; game. If you are going to speed up the game, start with
; plot - it is used by every single effect starting from explosions
; through line drawing and small text output!!!
;
; Optimized by 0xF (Fox) THXXXX!!!

; -----------------------------------------
MakePlot
    ; let's calculate coordinates from xdraw and ydraw

    ;xbyte = xbyte/8
    lda xdraw
    :3 lsr
    sta xbyte
    ;---
    ldx ydraw
    ldy linetableL,x
    lda linetableH,x
    sta xbyte+1

    ldx xdraw   ; optimization (256 bytes long bittable)
    
    lda (xbyte),y
    ora bittable1_long,x
    sta (xbyte),y
    rts
.endp
;--------------------------------------------------
MakeDarkScreen
;--------------------------------------------------
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
.proc VBLinterrupt
    mva #0 dliCounter
    mva #$02 DliColorBack

    lda PAL
    and #%00001110
    beq itsPAL
    ;it is NTSC here
    dec NTSCcounter
    bne itsPAL
    mva #6 NTSCcounter
    bne SkippedIfNTSC ; skip doing VBL things each 6 frames in Amerika, Amerika
                ; We're all living in Amerika, Coca Cola, Wonderbra

itsPAL
    ; pressTimer is trigger tick counter. always 50 ticks / s
    bit:smi:inc pressTimer ; timer halted if >127. max time measured 2.5 s

SkippedIfNTSC

    .IF TARGET = 800
        ; support for joysticks :)
        ldx JoystickNumber
        lda STICK0,x
        sta STICK0
        lda STRIG0,x
        sta STRIG0
        ; and PADDLES (2 and 3 joystick button)
        txa
        asl
        tax
        lda PADDL0,x
        sta PADDL0
        jmp XITVBV
    .ELIF TARGET = 5200
        lda SkStatSimulator
        smi:inc SkStatSimulator
        
        lda JoystickNumber        ; select port
        ora #%00000100          ; Speaker off, Pots enabled
        sta CONSOL5200

        center = 114            ;Read analog stick and make it look like a digital stick
        threshold = 60

        lda JoystickNumber
        asl
        tax
        lda paddl0,x            ;Read POT0 value (horizontal position)
        cmp #center+threshold       ;Compare with right threshold
        rol stick0          ;Feed carry into digital stick value
        cmp #center-threshold       ;Compare with left threshold
        rol stick0          ;Feed carry into digital stick value

        lda paddl1,x            ;Read POT1 value (vertical position)
        cmp #center+threshold       ;Compare with down threshold
        rol stick0          ;Feed carry into digital stick value
        cmp #center-threshold       ;Compare with down threshold
        rol stick0          ;Feed carry into digital stick value

        lda stick0          ;0 indicates a press so the right/down values need to be inverted
        eor #2+8
        and #$0f
        sta stick0

        ldx JoystickNumber
        ; check shift key (5200 second fire button)
        lda SKSTAT
        :3 lsr        ; third bit
        and trig0,x    ; and first button
        ;lda trig0,x
        sta strig0        ;Move hardware to shadow

        mva chbas chbase

        lda skstat          ;Reset consol key shadow is no key is pressed anymore
        and #4
        beq @+
          mva #consol_reset consol
          mva #@kbcode._none kbcode
@
exit
        pla
        tay
        pla
        tax
        pla
        rti
    .ENDIF
.endp
    .IF TARGET = 5200
.proc kb_continue
    cmp #$0c    ; START key on 5200 keypad
    beq StartPressed
    sta kbcode          ;Store key code in shadow.
    mva #0 SkStatSimulator
    beq VBLinterrupt.exit
StartPressed
    mvx #%00000110 CONSOL   ; virtual CONSOL Start key pressed
    bne VBLinterrupt.exit
.endp
    .ENDIF

;--------------------------------------------------
.proc CheckStartKey
;--------------------------------------------------
    lda CONSOL  ; turbo mode
    and #%00000001 ; START KEY
    rts
.endp
;-------------------------------------------------
  .ECHO "Bytes on top left: ",$bfe8-* ; ROM_SETTINGS-*
  .IF TARGET = 800
     run FirstSTART
  .ELIF TARGET = 5200
    .IF * > ROM_SETTINGS-1
      .ERROR 'Code too long to fit in 5200'
    .ENDIF
    org ROM_SETTINGS             ; 5200 ROM settings address $bfe8
    ;     "01234567890123456789"
    .byte " pokey random test  " ; 20 characters title
    .byte " ", $ff               ; $BFFD == $ff means diagnostic cart, no splash screen
    .word FirstSTART
  .ENDIF
