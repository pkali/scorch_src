
    icl '../../Atari/lib/ATARISYS.ASM'
    icl '../../Atari/lib/MACRO.ASM'
    icl '../../Atari/lib/cartloader_vectors.inc'
    icl 'cart_reset.asm'

    .zpvar dliCounter        .byte = $80
    .zpvar TetryxColor       .byte
    .zpvar TetryxColorS      .byte

; ------- constans --------
; start addr of loader

; cart banks numbers
LoaderBank  = 0
ScorchBank  = 1
MenuENBank  = 10
MenuPLBank  = 15
TetryxBank  = 20
    org $2000

WeaponFont
    ins '../weapons_AW6_mod.fnt'  ; 'artwork/weapons.fnt'
LogoFont
    ins 'Scorch_logo_mod_AW.fnt'

main
    lda #0
    sta dmactls
    jsr WaitOneFrame
    lda #0
    sta TetryxColor
    sta TetryxColorS
    lda RANDOM
    and #%11110000  ; 1:16
    bne TnotVisible
    lda colors+2    ; visible
    sta TetryxColor
TnotVisible
    lda #0
    ldx #3
@   sta COLOR0-1,x
    dex
    bpl @-
    mva #>LogoFont chbas
    mwa #MenuDL dlptrs
    VMAIN VBLinterrupt,7          ;jsr SetVBL
    SetDLI DLIinterrupt
    lda #@dmactl(narrow|dma) ; narrow screen width, DL on, P/M off
    sta dmactls
    jsr WaitOneFrame
    jsr FadeIn
    jsr WaitOneFrame
    
WaitForKey
    jsr GetKey
    cmp #@kbcode._space
    bne @+
    mva #ScorchBank X_BANK
    bne GoLoader
@   cmp #@kbcode._E
    bne @+
    mva #MenuENBank X_BANK
    bne GoLoader
@   cmp #@kbcode._P
    bne @+
    mva #MenuPLBank X_BANK
    bne GoLoader
@   cmp #@kbcode._T
    bne WaitForKey
    mva #TetryxBank X_BANK
    bne GoLoader

GoLoader
    jsr WaitOneFrame
    jsr FadeOut
    VMAIN XITVBV,7          ; jsr SetVBL (off user proc)
    LDA #%01000000          ; DLI off
    STA NMIEN
    lda #0 ; DL off, P/M off
    sta dmactls
    jsr WaitOneFrame
    mwa #$a000 X_SRC
    mva #$10 X_CLRSTART
    ;cli
    ;jmp main
    jmp X_LOADER_START
stop
    jmp stop

;--------------------------------------------------
.proc FadeIn
    ldy #15
FirstLoop
    ldx #3
@   lda COLOR0-1,x
    cmp colors,x
    beq ColorOK
    inc COLOR0-1,x
ColorOK
    dex
    bpl @-
    lda TetryxColorS
    cmp TetryxColor
    beq TcolorOK
    inc TetryxColorS
TcolorOK
    jsr WaitOneFrame
    dey
    bpl FirstLoop
    rts
.endp
;--------------------------------------------------
.proc FadeOut
    ldy #15
FirstLoop
    ldx #3
@   lda COLOR0-1,x
    beq ColorOK
    dec COLOR0-1,x
ColorOK
    dex
    bpl @-
    lda TetryxColorS
    beq TcolorOK
    dec TetryxColorS
TcolorOK
    jsr WaitOneFrame
    dey
    bpl FirstLoop
    rts
.endp
;--------------------------------------------------
.proc DLIinterrupt
    pha
    lda dliCounter
    bne SecondDLI
FirstDLI
    mva #>WeaponFont chbase
    lda #0
    ;sta WSYNC
    sta COLPF2
    beq EndOfDLI
SecondDLI
    lda TetryxColorS
    sta COLPF1
EndOfDLI
    inc dliCounter
    pla
DLIinterruptNone
    rti
.endp
;--------------------------------------------------
.proc VBLinterrupt
    mva #0 dliCounter
    jmp XITVBV
.endp
;--------------------------------------------------
.macro SetDLI
;    SetDLI #WORD
;    Initialises Display List Interrupts
         LDY # <:1
         LDX # >:1
         jsr _SetDLIproc
.endm
.proc _SetDLIproc
    LDA #%11000000
    STY VDSLST
    STX VDSLST+1
    STA NMIEN
    rts
.endp
;--------------------------------------------------
.proc WaitOneFrame
;--------------------------------------------------
    waitRTC    ; or wait ?
    rts
.endp
;--------------------------------------------------

; DL for menu
MenuDL
        .byte $70,$70,$70
        .byte $44
        .word picData
        :3 .byte $04
        .byte $20+$80
        .byte $42
        .word MenuTitle2        
        .byte $70,$70
        .byte $47
        .word MenuTitle
        .byte $30,$70
        .byte $42
        .word MenuOptions
        .byte $10,$02
        .byte $10,$02
        .byte $10+$80,$02
        .byte $41
        .word MenuDL


; Picture data (narrow screen)
picData
    ins 'Scorch_logo_mod_AW.scr',+32, 32*4  ; load 4 lines without the first one
 
; Color data
colors
    .BYTE 0,14,10,6
    
MenuTitle2
    dta d"   Unknown Father of All Games  "
MenuTitle
    dta d" SELECT  OPTION "
MenuOptions
    dta d"       E - English Manual       "
    dta d"       P - Polska instrukcja    "
    dta d"   SPACE - Start Scorch Game    "
    dta d"       T - Start Tetryx Game    "

;--------------------------------------------------
.proc GetKey
; waits for pressing a key and returns pressed value in A
; result: A=keycode
;--------------------------------------------------
    jsr WaitForKeyRelease
getKeyAfterWait
    lda SKSTAT
    cmp #$ff
    beq checkJoyGetKey ; key not pressed, check Joy
    lda kbcode
    cmp #@kbcode._none
    beq checkJoyGetKey
    and #$3f ;CTRL and SHIFT ellimination
    bne getkeyend   ; allways
checkJoyGetKey
    ;fire
    lda STRIG0
    beq JoyButton
checkStarttKey
      lda CONSOL
      and #%00000001    ; Start
      beq StartPressed
    bne getKeyAfterWait
StartPressed
JoyButton
    lda #@kbcode._space    ; Start key
getkeyend
    ldy #0
    sty ATRACT    ; reset atract mode
    rts
.endp
;--------------------------------------------------
.proc WaitForKeyRelease
;--------------------------------------------------
StillWait
      lda STRIG0
      beq StillWait
      lda SKSTAT
      cmp #$ff
      bne StillWait
      lda CONSOL
      and #%00000001    ; Start only
      cmp #%00000001
      bne StillWait
KeyReleased
      rts
.endp


    run main
