

* ---    MAIN PROGRAM
    org $2000
FontManual
    ins '../../artwork/weapons_AW6_mod.fnt'  ; 'artwork/weapons.fnt'

StartManual
;    jsr init_song

    lda >FontManual
    sta chbase
    sta chbas
    lda #$00
    sta colbak
    lda #$00
    sta colpf0
    lda #$02
    sta colpf1
    lda #$08
    sta colpf2
    lda #$00
    sta colpf3
    lda #$03

    ; and now display manual language selection screen
    mva <ManualDL dlptrs
    mva >ManualDL dlptrs+1
    mva #%00111110 dmactls    ;set new screen width

@checkkey
    lda trig0        ; FIRE #0
    beq game

    lda trig1        ; FIRE #1
    beq game

    lda consol        ; START
    and #1
    beq game

    lda skctl        ; ANY KEY
    and #$04
    bne @checkkey

game
    ; silent
    lda #0
    ldx #8
@   sta POKEY,x
    sta POKEY2,x    ; stereo
    dex
    bpl @-

    ;no glitching please (issue #67)
    lda #0
    sta $D400 ;dmactl
    sta $022F ;dmactls


    mva #$ff portb        ;ROM switch on
    mva #$40 nmien        ;only NMI interrupts, DLI disabled
    cli            ;IRQ enabled

    ; and now display manual language selection screen
    mva <lngDL dlptrs
    mva >lngDL dlptrs+1
    mva #%00111110 dmactls    ;set new screen width
    rts            ;return to ... DOS
    
    
InitEnglish
    lda ManualLangFlag
    cmp #1  ; english
    jeq StartManual
    rts
    
InitPolish
    lda ManualLangFlag
    cmp #2  ; polish
    jeq StartManual
    rts

//--------------------
ManualDL
        .byte $70
        .byte $47
        .word ManTitle
        .byte $70,$70
       .byte $42
        .word ManText
        .byte $02
        .byte $41
        .word ManualDL
; ------------------------------------------------
ManualTexts
ManTitle
    dta d"       manual       "*
ManText
    dta d"             English Manual             "
    dta d"             English Manual             "
;---
    ini InitEnglish
;---

    org ManualTexts
    dta d"     instrukcja     "*
    dta d"           Polska instrukcja            "
    dta d"           Polska instrukcja            "
;---
    ini InitPolish
;---
   