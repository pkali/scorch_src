
      icl '../../Atari/lib/ATARISYS.ASM'
      icl '../../Atari/lib/MACRO.ASM'

    .zpvar dliCounter        .byte = $80
    .zpvar TetryxColor       .byte
    .zpvar TetryxColorS      .byte

    org $2000

WeaponFont
    ins '../weapons_AW6_mod.fnt'  ; 'artwork/weapons.fnt'

main
    lda #0
    sta dmactls
    jsr WaitOneFrame
    lda #0
    sta TetryxColor
    sta TetryxColorS
    lda RANDOM
    bmi TnotVisible
    lda #10
    sta TetryxColor
TnotVisible
    lda #0
    ldx #3
@   sta COLOR0-1,x
    dex
    bpl @-
    mva #>WeaponFont chbas
    mwa #MenuDL dlptrs
    VMAIN VBLinterrupt,7          ;jsr SetVBL
    SetDLI DLIinterrupt
    lda #@dmactl(narrow|dma) ; narrow screen width, DL on, P/M off
    sta dmactls
    jsr WaitOneFrame
    jsr FadeIn
    jsr WaitOneFrame
    
    jsr GetKey

    jsr WaitOneFrame
    jsr FadeOut
    VMAIN XITVBV,7          ; jsr SetVBL (off user proc)
    LDA #%01000000          ; DLI off
    STA NMIEN
    lda #0 ; DL off, P/M off
    sta dmactls
    jsr WaitOneFrame
    
    jmp main
    
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
        .byte $70,$70,$70,$70
        .byte $4e
        .word picData
        :29 .byte $0e
        .byte $70,$70+$80
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
    .byte 0   ; offset
 .BYTE $00,$00,$01,$55,$15,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$15,$55,$00,$00,$00,$00,$00,$00,$00,$00
 .BYTE $00,$00,$05,$55,$45,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$15,$55,$00,$00,$00,$00,$00,$00,$00,$00
 .BYTE $00,$00,$05,$55,$55,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$15,$56,$00,$00,$00,$00,$00,$00,$00,$00
 .BYTE $00,$00,$15,$7D,$55,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$15,$57,$00,$00,$00,$00,$00,$00,$00,$00
 .BYTE $00,$00,$15,$3F,$55,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$2E,$5B,$00,$00,$00,$00,$00,$00,$00,$00
 .BYTE $00,$00,$55,$C0,$C7,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$5B,$00,$00,$00,$00,$00,$00,$00,$00
 .BYTE $00,$00,$55,$F0,$3F,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$5F,$00,$00,$00,$00,$00,$00,$00,$00
 .BYTE $00,$00,$57,$C0,$3F,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$5F,$00,$00,$00,$00,$00,$00,$00,$00
 .BYTE $00,$00,$55,$C0,$0F,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$54,$00,$00,$00,$00,$00,$00,$00,$00
 .BYTE $00,$00,$55,$70,$00,$00,$00,$D5,$5F,$54,$00,$F5,$56,$F0,$09,$55,$68,$56,$00,$15,$55,$40,$00,$55,$05,$50,$00,$00,$00,$00,$00,$00
 .BYTE $00,$00,$A9,$57,$00,$00,$02,$55,$56,$54,$03,$95,$55,$7C,$09,$55,$69,$54,$00,$55,$55,$50,$00,$55,$55,$54,$00,$00,$00,$00,$00,$00
 .BYTE $00,$00,$3D,$55,$80,$00,$09,$55,$55,$58,$02,$55,$55,$5F,$09,$55,$65,$5A,$05,$55,$55,$50,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00
 .BYTE $00,$00,$3F,$55,$50,$00,$35,$5F,$F5,$5C,$0D,$56,$E5,$5B,$09,$55,$55,$7C,$05,$5B,$E5,$5C,$00,$56,$A9,$55,$00,$00,$00,$00,$00,$00
 .BYTE $00,$00,$0F,$D5,$57,$00,$15,$7F,$FD,$7C,$05,$5F,$FD,$57,$0F,$D5,$55,$FC,$15,$7F,$FE,$BC,$00,$57,$FF,$55,$00,$00,$00,$00,$00,$00
 .BYTE $00,$00,$03,$F5,$55,$C0,$15,$FC,$0F,$FC,$35,$7F,$FD,$57,$00,$D5,$5F,$FC,$D5,$FC,$0F,$F0,$00,$57,$00,$D7,$00,$00,$00,$00,$00,$00
 .BYTE $00,$00,$00,$FF,$55,$70,$D5,$F0,$03,$FC,$35,$70,$03,$57,$00,$D5,$7F,$00,$55,$F0,$03,$C0,$00,$5F,$00,$97,$00,$00,$00,$00,$00,$00
 .BYTE $00,$00,$00,$3F,$D5,$70,$57,$C0,$00,$FC,$15,$F0,$03,$57,$00,$D5,$7C,$00,$57,$C0,$00,$00,$00,$5F,$00,$57,$00,$00,$00,$00,$00,$00
 .BYTE $00,$00,$00,$0F,$D5,$70,$57,$C0,$00,$00,$15,$F0,$03,$57,$00,$D5,$F0,$00,$57,$C0,$00,$00,$00,$5F,$00,$57,$00,$00,$00,$00,$00,$00
 .BYTE $00,$00,$00,$00,$F5,$70,$57,$C0,$00,$00,$15,$F0,$03,$5F,$00,$D5,$C0,$00,$57,$00,$00,$00,$00,$5F,$00,$57,$00,$00,$00,$00,$00,$00
 .BYTE $00,$00,$00,$00,$D5,$70,$57,$C0,$00,$00,$15,$F0,$03,$5F,$00,$D5,$C0,$00,$57,$C0,$00,$00,$00,$5F,$00,$57,$00,$00,$00,$00,$00,$00
 .BYTE $00,$00,$55,$00,$15,$F0,$57,$C0,$00,$00,$15,$F0,$03,$5F,$00,$D5,$F0,$00,$57,$C0,$00,$00,$00,$5F,$00,$57,$00,$00,$00,$00,$00,$00
 .BYTE $00,$00,$55,$F0,$15,$F0,$55,$F0,$00,$00,$15,$70,$01,$5F,$00,$D5,$F0,$00,$55,$C0,$00,$00,$00,$5F,$00,$57,$00,$00,$00,$00,$00,$00
 .BYTE $00,$00,$55,$C0,$15,$F0,$D5,$70,$03,$70,$35,$7F,$0D,$5C,$00,$D5,$F0,$00,$D5,$40,$01,$40,$00,$57,$00,$57,$00,$00,$00,$00,$00,$00
 .BYTE $00,$00,$55,$73,$D5,$F0,$FD,$5C,$0D,$5C,$3F,$57,$CD,$7C,$00,$D5,$FF,$00,$3D,$50,$01,$50,$00,$57,$00,$57,$40,$00,$00,$00,$00,$00
 .BYTE $00,$00,$55,$5C,$57,$F0,$3F,$57,$35,$5C,$0F,$D7,$F5,$7C,$00,$D5,$7F,$C0,$3C,$54,$05,$50,$00,$55,$00,$55,$40,$00,$00,$00,$00,$00
 .BYTE $00,$00,$96,$55,$5B,$F0,$3F,$95,$55,$7C,$0F,$E5,$55,$F0,$05,$55,$55,$C0,$3F,$15,$55,$7C,$15,$55,$50,$55,$54,$00,$00,$00,$00,$00
 .BYTE $00,$00,$5F,$D5,$5F,$C0,$0F,$E5,$55,$F0,$03,$F5,$56,$F0,$05,$5B,$A5,$C0,$0F,$E5,$56,$F0,$15,$6E,$A0,$5B,$A8,$00,$00,$00,$00,$00
 .BYTE $00,$00,$FF,$F5,$7F,$C0,$03,$FD,$5F,$FC,$00,$FF,$5F,$F0,$05,$7F,$FF,$C0,$03,$FD,$5F,$F0,$15,$FF,$F0,$4F,$FC,$00,$00,$00,$00,$00
 .BYTE $00,$00,$3F,$3F,$FF,$00,$00,$FF,$FF,$C0,$00,$3F,$FF,$C0,$04,$FF,$FF,$C0,$00,$FF,$FF,$C0,$13,$FF,$F0,$3F,$FC,$00,$00,$00,$00,$00
 .BYTE $00,$00,$FF,$CF,$FC,$00,$00,$3F,$FF,$00,$00,$0F,$FF,$00,$0F,$FF,$FF,$C0,$00,$0F,$FC,$00,$0F,$FF,$F0,$FF,$FC,$00,$00,$00,$00,$00
 
; Color data
colors
    .BYTE 0,14,10,4
 
MenuTitle
    dta d" SELECT  OPTION "
MenuOptions
    dta d"     E - English Manual         "
    dta d"     P - Polska instrukcja      "
    dta d"     G - Start Game             "
    dta d"     T - Start Tetryx Game      "

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