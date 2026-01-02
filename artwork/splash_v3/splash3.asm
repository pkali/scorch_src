/***************************************/
/*  Use MADS http://mads.atari8.info/  */
/*  Mode: GED- (bitmap mode)           */
/***************************************/

	;icl "no_name.h"
	;icl "output.png.opt.h"

/* ; --- dmsc LZSS player routine on zero page
    org $80

chn_copy    .ds     9
chn_pos     .ds     9
bptr        .ds     2
cur_pos     .ds     1
chn_bits    .ds     1

bit_data    .ds     1
; ---

fcnt	.ds 2
fadr	.ds 2
fhlp	.ds 2
cloc	.ds 1
regA	.ds 1
regX	.ds 1
regY	.ds 1
byt2	.ds 1

zc	.ds ZCOLORS

    org $1fff
SplashTypeFlag .ds 1 */

* ---	MAIN PROGRAM
	org $2010
	IFT PIC_HEIGHT>=204
scr3	ins "output.png.mic", 0, 8160
	:16 .byte 0
	ins "output.png.mic" , +8160
	ELS
scr3	ins "output.png.mic"
	EIF

	.ifdef nil_used
nil	:8*40 brk
	eif

	.ALIGN $0400
ant3	ANTIC_PROGRAM3 scr3,ant3

fnt3

	ift USESPRITES
	.ALIGN $0800
	.ds $0300
pmg3	SPRITES3
	eif

FontSplash3
    ins '../../artwork/weapons_AW6_mod.fnt'  ; 'artwork/weapons.fnt'

mother3
;    dta d"        The Mother of All Games         "
    dta d"    Unknown Father of All Team Games    "

main3
.IF CART_VERSION
    lda SplashTypeFlag
    cmp #100     ; (0 - 100 ; first splash , 101 - 200 ; second splash , 201 - 255 ; KAZ)
    bcc not_this
    cmp #200
    bcc this_splash2 ; second splash
not_this
    rts ; next splash
this_splash2
.ENDIF


    jsr init_song

* ---    init PMG

    ift USESPRITES
    mva >pmg3 pmbase        ;missiles and players data address
    mva #$03 GRACTL        ;enable players and missiles
    eif

    lda:cmp:req $14        ;wait 1 frame

    sei            ;stop interrups
    mva #$00 nmien        ;stop all interrupts
    mva #$fe portb        ;switch off ROM to get 16k more ram

    ZPINIT

////////////////////
// RASTER PROGRAM //
////////////////////

;	jmp line239
	jmp raster_program_end3

LOOP3	lda vcount		;synchronization for the first screen line
	cmp #$02
	bne LOOP3

	mva #%00111110 dmactl	;set new screen width
	mva <ant dlptr
	mva >ant dlptr+1

  icl "output.png.opt.ini"

;--- wait 18 cycles
	jsr _rts3
	inc byt33

;--- set global offset (23 cycles)
	jsr _rts3
	cmp byt33\ pha:pla

;--- empty line
	jsr wait54cycle3
	inc byt2

.local
  icl "output.png.opt"
.endl

raster_program_end3

    lda >FontSplash3
    sta chbase
    sta chbas
c03    lda #$00
    sta colbak
c13    lda #$00
    sta colpf0
c23    lda #$02
    sta colpf1
c33    lda #$08
    sta colpf2
c43    lda #$00
    sta colpf3
s03	lda #$03
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
	mva #$02 GRACTL
	lda #$14
	sta PRIOR


//--------------------
//	EXIT
//--------------------

    lda trig0        ; FIRE #0
    beq stop3

    lda trig1        ; FIRE #1
    beq stop3

    lda consol        ; START
    and #1
    beq stop3

    lda skctl        ; ANY KEY
    and #$04
    bne skp3
stop3    mva #$00 GRACTL        ;PMG disabled
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

    rts            ;return to ... DOS
skp3

//--------------------
    jsr play_frame

	jmp LOOP3

;---

wait54cycle3
	:2 inc byt2
wait44cycle3
	inc byt33
	nop
wait36cycle3
	inc byt33
	jsr _rts3
wait18cycle3
	inc byt33
_rts3	rts

byt33	brk

;    org $8000   ; fixed address of music routine and data
;    icl "../splash_v2/lzss_player.asm"    ; player (and data) for splash music


;---

.MACRO	ANTIC_PROGRAM3
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
;	:+4 dta $4e,a(:1+$1F40+#*40)
;	:+4 dta $4e,a(:1+$1FF0+#*40)
;	:+8 dta $4e,a(:1+$2090+#*40)
;	:+8 dta $4e,a(:1+$21D0+#*40)
;	:+8 dta $4e,a(:1+$2310+#*40)
;	:+8 dta $4e,a(:1+$2450+#*40)
    dta $00
    dta $42,a(mother3)
    dta $41,a(:2)
.ENDM


;ZCOLORS	= 0

;---
	ini main3
;---

	opt l-

.MACRO	SPRITES3
.local
	icl "output.png.pmg"
.endl
.ENDM

;USESPRITES = 1