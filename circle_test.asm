      icl 'Atari/lib/ATARISYS.ASM'
      icl 'Atari/lib/MACRO.ASM'
      
screenheight = 200
screenbytes = 40
screenwidth  = screenBytes*8  ; Max screenwidth = 512!!!
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
      
;-----------------------------------------------
; variable declarations in RAM (no code)
;-----------------------------------------------
    ORG $2000
    ; These tebles are at the beginning of memory pages becouse ....
bittable1_long
    .ds $100
bittable2_long
    .ds $100
linetableL
    .ds (screenHeight)
linetableH
    .ds (screenHeight)
oldora  .DS [5]
OldOraTemp .DS 1
oldplotH .DS [5]
oldplotL .DS [5]
oldply  .DS [5]
WhichUnPlot .DS 1

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
.proc unPlot
; plots a point and saves the plotted byte, reverts the previous plot.
; -----------------------------------------
    ldx #0 ; only one pixel
unPlotAfterX
    stx WhichUnPlot

    ; first remake the oldie
    lda oldplotL,x
    sta oldplot
    lda oldplotH,x
    sta oldplot+1

    ldy oldply,x
    lda oldora,x
    sta (oldplot),y


    ; is it not out of the screen ????
    cpw ydraw #screenheight
    jcc CheckX
    mwa #0 ydraw
CheckX
    cpw xdraw #screenwidth
    jcs EndOfUnPlot
MakeUnPlot
    ; let's count coordinates taken from xdraw and ydraw
    ;xbyte = xbyte/8
    lda xdraw+1
    lsr
    lda xdraw
    ror ;just one bit over 256. Max screenwidth = 512!!!
    lsr
    lsr
;---
    tay
    ldx WhichUnPlot
    ;tya
    sta oldply,x

    ldx ydraw
    lda linetableL,x
    sta xbyte
    sta oldplot
    lda linetableH,x
    sta xbyte+1
    sta oldplot+1

;    lda xdraw
;    and #$7
;    tax
    ldx xdraw   ; optimization (256 bytes long bittable)
    
    lda color
    bne ClearUnPlot

    ;plotting here
    lda (xbyte),y
    sta OldOraTemp
    ora bittable1_long,x
    sta (xbyte),y
    bne ContinueUnPlot ; allways <>0
ClearUnPlot
    lda (xbyte),y
    sta OldOraTemp
    and bittable2_long,x
    sta (xbyte),y
ContinueUnPlot
    ldx WhichUnPlot
    lda OldOraTemp
    sta oldora,x
    lda oldplot
    sta oldplotL,x
    lda oldplot+1
    sta oldplotH,x
    ; and now we must solve the problem of several plots
    ; in one byte
    ldx #4
    ldy WhichUnPlot
LetsCheckOverlapping
    cpx WhichUnPlot
    beq SkipThisPlot
    lda oldplotL,x
    cmp oldplotL,y
    bne NotTheSamePlot
    lda oldplotH,x
    cmp oldplotH,y
    bne NotTheSamePlot
    lda oldply,x
    cmp oldply,y
    bne NotTheSamePlot
    ; the pixel is in the same byte so let's take correct contents
    lda oldora,x
    sta oldora,y
NotTheSamePlot
SkipThisPlot
    dex
    bpl LetsCheckOverlapping
EndOfUnPlot
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
    ; is it not over the screen ???
    cpw ydraw #(screenheight+1); changed for one additional line. cpw ydraw #(screenheight-1)
    bcs unPlot.EndOfUnPlot ;nearest RTS
CheckX02
    cpw xdraw #screenwidth
    bcs EndOfPlot
MakePlot
    ; let's calculate coordinates from xdraw and ydraw

    ;xbyte = xbyte/8
    lda xdraw+1
    lsr
    lda xdraw
    ror ;just one bit over 256. Max screenwidth = 512!!!
    lsr
    lsr
    sta xbyte
    ;---
    ldx ydraw
    ldy linetableL,x
    lda linetableH,x
    sta xbyte+1

;    lda xdraw
;    and #$7
;    tax
    ldx xdraw   ; optimization (256 bytes long bittable)
    
    lda color
    bne ClearPlot

    lda (xbyte),y
    ora bittable1_long,x
    sta (xbyte),y
EndOfPlot
    rts
ClearPlot
    lda (xbyte),y
    and bittable2_long,x
    sta (xbyte),y
    rts
.endp
      
      icl 'circle1.asm'
      ;icl 'circle2.asm'
      
start
    ;jsr generatelinetable
    halt
    

    run start
    .align $1000
    .ds 10
display