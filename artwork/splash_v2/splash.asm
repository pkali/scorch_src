/***************************************/
/*  Use MADS http://mads.atari8.info/  */
/*  Mode: GED- (bitmap mode)           */
/***************************************/

    icl "splash.h"

; --- dmsc LZSS player routine on zero page
    org $80

chn_copy    .ds     9
chn_pos     .ds     9
bptr        .ds     2
cur_pos     .ds     1
chn_bits    .ds     1

bit_data    .ds     1
; ---

    org $00

fcnt    .ds 2
fadr    .ds 2
fhlp    .ds 2
cloc    .ds 1
regA    .ds 1
regX    .ds 1
regY    .ds 1
byt2    .ds 1

zc    .ds ZCOLORS

    org $600
ManualLangFlag .ds 1

* ---    BASIC switch OFF
    org $2000\ mva #$ff portb\ rts\ ini $2000

* ---    MAIN PROGRAM
    org $2010
    IFT PIC_HEIGHT>=204
scr    ins "output.png.mic", 0, 8160
    :16 .byte 0
    ins "output.png.mic" , +8160
    ELS
scr    ins "output.png.mic"
    EIF

    .ifdef nil_used
nil    :8*40 brk
    eif

    .ALIGN $0400
ant    ANTIC_PROGRAM scr,ant

fnt

    ift USESPRITES
    .ALIGN $0800
    .ds $0300
pmg    SPRITES
    eif

FontSplash
    ins '../../artwork/weapons_AW6_mod.fnt'  ; 'artwork/weapons.fnt'

mother
;    dta d"        The Mother of All Games         "
    dta d"      Father Unknown of All Games       "
    icl "lzss_player.asm"    ; player (and data) for splash music

main
    mva #00 ManualLangFlag  ; no manual page
    jsr init_song

* ---    init PMG

    ift USESPRITES
    mva >pmg pmbase        ;missiles and players data address
    mva #$03 pmcntl        ;enable players and missiles
    eif

    lda:cmp:req $14        ;wait 1 frame

    sei            ;stop interrups
    mva #$00 nmien        ;stop all interrupts
    mva #$fe portb        ;switch off ROM to get 16k more ram

    ZPINIT

////////////////////
// RASTER PROGRAM //
////////////////////

;    jmp line239
    jmp raster_program_end

LOOP    lda vcount        ;synchronization for the first screen (picture) line
    cmp #$02
    ;sta    colpf0
    ;sta    colpm0
    ;sta colbak
    bne LOOP

    mva #%00111110 dmactl    ;set new screen width
    mva <ant dlptr
    mva >ant dlptr+1

  icl "output.png.rp.ini"

;--- 16 lines down ---- !!!
    :16 sta wsync

    ; wait 13 cycles !!!
    :4 nop
    inc byt2

;--- wait 18 cycles
;    jsr _rts
;    inc byt3


;--- set global offset (23 cycles)
    jsr _rts
    cmp byt3\ pha:pla

;--- empty line
    jsr wait54cycle
    inc byt2

  icl "output.png.rp"

raster_program_end

    lda >FontSplash
    sta chbase
c0    lda #$00
    sta colbak
c1    lda #$00
    sta colpf0
c2    lda #$02
    sta colpf1
c3    lda #$08
    sta colpf2
c4    lda #$00
    sta colpf3
s0    lda #$03
    sta sizep0
    sta sizep1
    sta sizep2
    sta sizep3
    mva #$ff sizem
    sta grafm
    mva #$20 hposm0
    mva #$28 hposm1
    mva #$d0 hposm2
    mva #$d8 hposm3
    mva #$02 pmcntl
    lda #$14
    sta gtictl


//--------------------
//    EXIT
//--------------------

    lda trig0        ; FIRE #0
    beq stop

    lda trig1        ; FIRE #1
    beq stop

    lda consol        ; START
    and #1
    beq stop

    lda skctl        ; ANY KEY
    and #$04
    bne skp
    lda kbcode
    cmp #$25    ; "M" key
    bne stop
    mva #01 ManualLangFlag  ; english manual page 
stop    mva #$00 pmcntl        ;PMG disabled
    tax
    sta:rne hposp0,x+

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

    lda ManualLangFlag
    beq waitkey2release
    ; and now display manual language selection screen
    mva <lngDL dlptrs
    mva >lngDL dlptrs+1
    mva #%00111110 dmactls    ;set new screen width

    ; wait for key
waitkey2
    lda skctl        ; ANY KEY
    and #$04
    bne waitkey2
    lda kbcode
    cmp #$2A    ; "E" key
    bne notEng
    mva #01 ManualLangFlag  ; english manual page
    bne endsplash
notEng
    cmp #$0A    ; "P" key
    bne waitkey2
    mva #02 ManualLangFlag  ; polish manual page 
endsplash
    ;no glitching please (issue #67)
    lda #0
    sta $D400 ;dmactl
    sta $022F ;dmactls
waitkey2release
    lda skctl        ; ANY KEY
    and #$04
    beq waitkey2release

    rts            ;return to ... DOS
skp

//--------------------
    jsr play_frame

    jmp LOOP

;---

wait54cycle
    :2 inc byt2
wait44cycle
    inc byt3
    nop
wait36cycle
    inc byt3
    jsr _rts
wait18cycle
    inc byt3
_rts    rts

byt3    brk


;---

lngDL
        .byte $70,$70,$70,$70,$70
        .byte $47
        .word LngTitle
        .byte $70,$70
       .byte $42
        .word LngList
        .byte $50,$02
        .byte $41
        .word lngDL
LngTitle
    dta d"  select language   "*
LngList
    dta d"         E - English Manual             "
    dta d"         P - Polska instrukcja          "

;---
.MACRO    ANTIC_PROGRAM
    dta $70,$70
    :+8 dta $4e,a(:1+$0000+#*40)
    :+8 dta $4e,a(:1+$0140+#*40)
    :+8 dta $4e,a(:1+$0280+#*40)
    :+8 dta $4e,a(:1+$03C0+#*40)
    :+8 dta $4e,a(:1+$0500+#*40)
    :+8 dta $4e,a(:1+$0640+#*40)
    :+8 dta $4e,a(:1+$0780+#*40)
    :+8 dta $4e,a(:1+$08C0+#*40)
    :+8 dta $4e,a(:1+$0A00+#*40)
    :+8 dta $4e,a(:1+$0B40+#*40)
    :+8 dta $4e,a(:1+$0C80+#*40)
    :+8 dta $4e,a(:1+$0DC0+#*40)
    :+8 dta $4e,a(:1+$0F00+#*40)
    :+8 dta $4e,a(:1+$1040+#*40)
    :+8 dta $4e,a(:1+$1180+#*40)
    :+8 dta $4e,a(:1+$12C0+#*40)
    :+8 dta $4e,a(:1+$1400+#*40)
    :+8 dta $4e,a(:1+$1540+#*40)
    :+8 dta $4e,a(:1+$1680+#*40)
    :+8 dta $4e,a(:1+$17C0+#*40)
    :+8 dta $4e,a(:1+$1900+#*40)
    :+8 dta $4e,a(:1+$1A40+#*40)
    :+8 dta $4e,a(:1+$1B80+#*40)
    :+8 dta $4e,a(:1+$1CC0+#*40)
    :+8 dta $4e,a(:1+$1E00+#*40)
;    :+4 dta $4e,a(:1+$1F40+#*40)
;    :+4 dta $4e,a(:1+$1FF0+#*40)
;    :+8 dta $4e,a(:1+$2090+#*40)
;    :+8 dta $4e,a(:1+$21D0+#*40)
;    :+8 dta $4e,a(:1+$2310+#*40)
;    :+8 dta $4e,a(:1+$2450+#*40)
    dta $00
    dta $42,a(mother)
    dta $41,a(:2)
.ENDM

CL

.MACRO    ZPINIT
.ENDM

ZCOLORS    = 0

;---
    ini main
;---

    opt l-

.MACRO    SPRITES
    icl "output.png.pmg"
.ENDM

USESPRITES = 1

