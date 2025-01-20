;    @com.wudsn.ide.asm.mainsourcefile=scorch.asm

    .IF *>0 ;this is a trick that prevents compiling this file alone

;--------------------------------------------------
.proc DLIinterruptGraph
    pha
    phy
    ldy dliCounter
    cpy #$14
    beq GoBlackHole
    lda dliColorsBack,y
    .IF TARGET = 800
        nop  ; necessary on 800 because DLIs take less time, jitter visible without it
        nop
        nop
    .ENDIF
    nop
    ;nop
    sta COLPF1
    lda GradientNr
    bne GoGradient
    ldy #$ff    ; one mauntain color
GoGradient
    iny
    lda (GradientColors),y        ; mountains colors array
    sta COLPF2
NoBlacHoleLine
EndOfDLI_Gr
    inc dliCounter
    ply
    pla
    rti
GoBlackHole
    lda BlackHole
    beq NoBlacHoleLine
    nop
    lda #$00    ; color of last line
    sta COLPF2
    beq EndOfDLI_Gr
.endp
;--------------------------------------------------
.proc DLIinterruptOptions
    pha
    phy
    lda dliCounter
    bne Subtitle
    lda #0    ; background color
    sta COLPF1
    ldy GradientNr
    beq @+
    ldy #1
@    lda (GradientColors),y        ; mountains colors array
    sta COLPF2  ; allways <> 0 !!!
    bne DLIinterruptGraph.EndOfDLI_Gr
Subtitle
    lda #0
    sta COLPF2
    lda random
    and #%00000011
    ora #%00010000
    sta COLPF1
    bne DLIinterruptGraph.EndOfDLI_Gr
.endp
;--------------------------------------------------
.proc DLIinterruptGameOver
    pha
    phy
    lda dliCounter
    bne EndofPMG
    lda #%00100001    ; playfield after P/M - prior=1
    ;STA WSYNC
    sta PRIOR
    bne DLIinterruptGraph.EndOfDLI_Gr
EndofPMG
    cmp #1
    bne ColoredLines
    lda #%00100100    ; playfield before P/M
    ;STA WSYNC
    sta PRIOR
    bne DLIinterruptGraph.EndOfDLI_Gr
ColoredLines
    cmp #9
    beq CreditsScroll
    tay
    lda GameOverColoursTable-3,y    ; -2 because this is DLI nr 2 and -1 (labels line)
    ldy #$0a    ; text colour (brightnes)
    ;STA WSYNC
    sta COLPF2
    sty COLPF1
    bne DLIinterruptGraph.EndOfDLI_Gr
CreditsScroll
    lda #$00
    sta COLPF2
    beq DLIinterruptGraph.EndOfDLI_Gr
.endp
;--------------------------------------------------
.proc DLIinterruptText
    pha
    lda dliCounter
    bne MoreBarsColorChange
    lda #TextBackgroundColor
    ;sta WSYNC
    sta COLPF2
    mva #TextForegroundColor COLPF3
    bne EndOfDLI_Text
MoreBarsColorChange
    and #%00000001
    rol
    sta COLPF2
EndOfDLI_Text
    inc dliCounter
    pla
DLIinterruptNone
    rti

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

    bit RMT_blocked
    bmi SkipRMTVBL
    ; ------- RMT -------
    lda sfx_effect
    bmi lab2
    asl @                       ; * 2
    tay                         ;Y = 2,4,..,16  instrument number * 2 (0,2,4,..,126)
    ldx #0                      ;X = 0          channel (0..3 or 0..7 for stereo module)
    lda #0                      ;A = 0          note (0..60)
    bit noSfx
    smi:jsr RASTERMUSICTRACKER+15   ;RMT_SFX start tone (It works only if FEAT_SFX is enabled !!!)

    lda #$ff
    sta sfx_effect              ;reinit value
lab2
    jsr RASTERMUSICTRACKER+3    ;1 play
    ; ------- RMT -------
SkipRMTVBL
    ; ------ meteors ------ start
  .IF METEORS = 1
    ldx #0
    bit Mcounter
    bpl MeteorOnSky
    bit MeteorsFlag
    bmi SkipMeteors
    ; randomize meteor
    lda random
    and #%11111111
    bne SkipMeteors
    lda random
    sta Mpoint1X
    sta Mpoint2X
    lda #0
    sta Mpoint1X+1
    sta Mpoint2X+1
    lda random
    and #$1f
    sta Mpoint1Y
    sta Mpoint2Y
    mva #10 Mcounter
MeteorOnSky
    jsr GoMplot
NoFirstPlot
    ldx #2  ; second point coordinates
    lda Mcounter
    beq @+
    dec Mcounter
    bpl SkipSecondPlot
@   lda Mpoint1Y,x
    cmp #64
    bne GoSecondPlot
    mva #$ff Mcounter
    bmi SkipMeteors
GoSecondPlot
    jsr GoMplot2
SkipSecondPlot
SkipMeteors
  .ENDIF
    ; ------ meteors ------ end
    bit ScrollFlag
    bpl EndOfCreditsVBI
CreditsVBI
    inc CreditsVScrol
    lda CreditsVScrol
    cmp #32        ;not too fast
    beq nextlinedisplay
    :2 lsr        ;not too fast
    sta VSCROL
    jmp EndOfCreditsVBI
nextlinedisplay
    lda #0
    sta CreditsVScrol
    sta VSCROL
    clc
    lda DLCreditsAddr
    adc #40
    sta DLCreditsAddr
    bcc @+
    inc DLCreditsAddr+1
@
    cmp #<CreditsLastLine
    bne EndOfCreditsVBI
    lda DLCreditsAddr+1
    cmp #>CreditsLastLine
    bne EndOfCreditsVBI
;    adw DLCreditsAddr #40
;    cpw DLCreditsAddr #CreditsLastLine
;    bne EndOfCreditsVBI
    mwa #Credits DLCreditsAddr
EndOfCreditsVBI
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
;        lda PADDL1,x
;        sta PADDL1
        jmp XITVBV
    .ELIF TARGET = 5200
        lda SkStatSimulator
        bmi @+
        inc SkStatSimulator
@
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
    ; ------ meteors plot/flight subroutine ------ start
  .IF METEORS = 1
GoMplot
    lda Mpoint1Y,x
    cmp #64
    beq @+
GoMplot2
    sta EplotY
    inc Mpoint1Y,x
    mwa Mpoint1X,x EplotX
    inw Mpoint1X,x
    jmp Explot
@   rts
  .ENDIF
    ; ------ meteors plot/flight subroutine ------ end
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
.macro SetDLI
;    SetDLI #WORD
;    Initialises Display List Interrupts
         LDY # <:1
         LDX # >:1
         jsr _SetDLIproc
.endm
.proc _SetDLIproc
    LDA #$00
    STA NMIEN
    LDA #$C0
    STY VDSLST
    STX VDSLST+1
    STA NMIEN
    rts
.endp

    .ENDIF
