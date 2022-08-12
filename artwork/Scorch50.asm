/***************************************/
/*  Use MADS http://mads.atari8.info/  */
/*  Mode: DLI (char mode)              */
/***************************************/

	;icl "Scorch50.h"

; --- dmsc LZSS player routine on zero page
    org $80

chn_copy    .ds     9
chn_pos     .ds     9
bptr        .ds     2
cur_pos     .ds     1
chn_bits    .ds     1

bit_data    .ds     1

fcnt	.ds 2
fadr	.ds 2
fhlp	.ds 2
cloc	.ds 1
regA	.ds 1
regX	.ds 1
regY	.ds 1

WIDTH	= 40
HEIGHT	= 30

; ---	BASIC switch OFF
	;org $2000\ mva #$ff portb\ rts\ ini $2000

; ---	MAIN PROGRAM
	org $2000
ant	dta $C2,a(scr)
	dta $02,$82,$02,$02,$82,$02,$82,$02,$82,$02,$02,$02,$82,$02,$82,$82
	dta $02,$02,$82,$02,$02,$82,$02,$02,$82,$82,$02,$82,$22
	;dta $42,a(verline)
	dta $41,a(ant)

;verline
;    :37 dta d" "
;    dta build
    
scr	ins "Scorch50.scr"

	.ds 0*40

	.ALIGN $0400
fnt	ins "Scorch50.fnt"

	ift USESPRITES
	.ALIGN $0800
pmg	.ds $0300
	ift FADECHR = 0
	SPRITES
	els
	.ds $500
	eif
	eif


song_data
        ins 'mmm_16.lzs'
song_end

POKEY = $D200

buffers
    .ds 256 * 9

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Song Initialization - this runs in the first tick:
;
.proc init_song

    mva #1 bit_data

    ; Example: here initializes song pointer:
    
    ;mwa #song_data song_ptr

    ; Init all channels:
    ldx #8
    ldy #0
clear
    ; Read just init value and store into buffer and POKEY
    jsr get_byte
    sta POKEY, x
    sty chn_copy, x
cbuf
    sta buffers + 255
    inc cbuf + 2
    dex
    bpl clear

    ; Initialize buffer pointer:
    sty bptr
    sty cur_pos
    rts
.endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Wait for next frame
;
.proc wait_frame

    lda 20
delay
    cmp 20
    beq delay
.endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Play one frame of the song
;
.proc play_frame
    lda #>buffers
    sta bptr+1

    lda song_data
    sta chn_bits
    ldx #8

    ; Loop through all "channels", one for each POKEY register
chn_loop:
    lsr chn_bits
    bcs skip_chn       ; C=1 : skip this channel

    lda chn_copy, x    ; Get status of this stream
    bne do_copy_byte   ; If > 0 we are copying bytes

    ; We are decoding a new match/literal
    lsr bit_data       ; Get next bit
    bne got_bit
    jsr get_byte       ; Not enough bits, refill!
    ror                ; Extract a new bit and add a 1 at the high bit (from C set above)
    sta bit_data       ;
got_bit:
    jsr get_byte       ; Always read a byte, it could mean "match size/offset" or "literal byte"
    bcs store          ; Bit = 1 is "literal", bit = 0 is "match"

    sta chn_pos, x     ; Store in "copy pos"

    jsr get_byte
    sta chn_copy, x    ; Store in "copy length"

                        ; And start copying first byte
do_copy_byte:
    dec chn_copy, x     ; Decrease match length, increase match position
    inc chn_pos, x
    ldy chn_pos, x

    ; Now, read old data, jump to data store
    lda (bptr), y

store:
    ldy cur_pos
    sta POKEY, x        ; Store to output and buffer
    sta (bptr), y

skip_chn:
    ; Increment channel buffer pointer
    inc bptr+1

    dex
    bpl chn_loop        ; Next channel

    inc cur_pos
.endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check for ending of song and jump to the next frame
;

; not checking really so the tune gets funky :)))
    ;lda song_ptr + 1
    ;cmp #>song_end
    ;bne wait_frame
    ;lda song_ptr
    ;cmp #<song_end
    ;bne wait_frame

end_loop
    rts

song_ptr = get_byte + 1
.proc get_byte
    lda song_data+1
    inc song_ptr
    bne skip
    inc song_ptr+1
skip
    rts
.endp


main

    jsr init_song
    
;    ; copy system font to $a000
;    ldx #0
;@   lda $e000,x
;    sta $a000,x
;    ;lda $e100,x  ; i need digits only :]
;    ;sta $a100,x
;    ;lda $e200,x
;    ;sta $a200,x
;    ;lda $e300,x
;    ;sta $a300,x
;    inx
;    bne @-

; ---	init PMG

	ift USESPRITES
	mva >pmg pmbase		;missiles and players data address
	mva #$03 pmcntl		;enable players and missiles
	eif

	lda:cmp:req $14		;wait 1 frame

	sei			;stop IRQ interrupts
	mva #$00 nmien		;stop NMI interrupts
	sta dmactl
	;mva #$fe portb		;switch off ROM to get 16k more ram

	;mwa #NMI $fffa		;new NMI handler

    VMAIN NMI.vbl,6        ;jsr SetVBL
    VDLI DLI.dli_start
    

	mva #1 vscrol

	mva #$c0 nmien		;switch on NMI+DLI again

_lp	lda trig0		; FIRE #0
	beq stop

	lda trig1		; FIRE #1
	beq stop

	lda consol		; START
	and #1
	beq stop

	lda skctl
	and #$04
	bne _lp			;wait to press any key; here you can put any own routine


stop
	
	cli
	vmain sysvbv,6
	
	mva #$00 pmcntl		;PMG disabled
	tax
	sta:rne hposp0,x+

	;mva #$ff portb		;ROM switch on
	mva #$40 nmien		;only NMI interrupts, DLI disabled
	;cli			;IRQ enabled

	lda #0
    ldx #8
@   sta POKEY,x
    dex
    bpl @-
    
        
    ;no glitching please (issue #67)
    lda #0
    sta $D400 ;dmactl
    sta $022F ;dmactls
    rts         ;return to ... DOS

; ---	DLI PROGRAM

.local	DLI

	?old_dli = *

dli_start

dli13
	sta regA

	sta wsync		;line=8
	sta wsync		;line=9
	sta wsync		;line=10
	sta wsync		;line=11
	sta wsync		;line=12
	sta wsync		;line=13
c9	lda #$14
	sta wsync		;line=14
	sta colpm3
	DLINEW DLI.dli2 1 0 0

dli2
	sta regA
	lda >fnt+$400*$01
	sta wsync		;line=24
	sta chbase
	DLINEW dli3 1 0 0

dli3
	sta regA
	lda >fnt+$400*$02
	sta wsync		;line=48
	sta chbase
	sta wsync		;line=49
	sta wsync		;line=50
	sta wsync		;line=51
s3	lda #$07
	sta wsync		;line=52
	sta sizem
	DLINEW dli14 1 0 0

dli14
	sta regA
	stx regX
	sty regY

x8	lda #$A3
	sta wsync		;line=64
	sta hposp3
x9	lda #$AB
	sta wsync		;line=65
	sta hposm3
	sta wsync		;line=66
	sta wsync		;line=67
	sta wsync		;line=68
	sta wsync		;line=69
	sta wsync		;line=70
s4	lda #$13
x10	ldx #$A6
	sta wsync		;line=71
	sta sizem
	stx hposm2
s5	lda #$01
x11	ldx #$72
x12	ldy #$62
	sta wsync		;line=72
	sta sizep2
	sta sizep3
	stx hposp2
	sty hposp3
x13	lda #$A9
	sta wsync		;line=73
	sta hposp1
	DLINEW dli4 1 1 1

dli4
	sta regA
	lda >fnt+$400*$03
	sta wsync		;line=80
	sta chbase
	DLINEW dli5 1 0 0

dli5
	sta regA
	stx regX
	lda >fnt+$400*$04
	sta wsync		;line=112
	sta chbase
	sta wsync		;line=113
	sta wsync		;line=114
	sta wsync		;line=115
	sta wsync		;line=116
	sta wsync		;line=117
	sta wsync		;line=118
s6	lda #$07
x14	ldx #$A3
	sta wsync		;line=119
	sta sizem
	stx hposm1
s7	lda #$01
x15	ldx #$93
	sta wsync		;line=120
	sta sizep1
	stx hposp1
	DLINEW dli15 1 1 0

dli15
	sta regA
	stx regX

	sta wsync		;line=128
	sta wsync		;line=129
	sta wsync		;line=130
	sta wsync		;line=131
x16	lda #$4A
	sta wsync		;line=132
	sta hposp1
c10	lda #$D4
	sta wsync		;line=133
	sta color2
s8	lda #$C3
x17	ldx #$5A
	sta wsync		;line=134
	sta sizem
	stx hposm3
	DLINEW dli6 1 1 0

dli6
	sta regA
	stx regX
	sty regY
	lda >fnt+$400*$05
	sta wsync		;line=136
	sta chbase
	sta wsync		;line=137
	sta wsync		;line=138
	sta wsync		;line=139
	sta wsync		;line=140
	sta wsync		;line=141
	sta wsync		;line=142
s9	lda #$C7
x18	ldx #$A9
	sta wsync		;line=143
	sta sizem
	stx hposm1
s10	lda #$D7
x19	ldx #$9E
c11	ldy #$02
	sta wsync		;line=144
	sta sizem
	stx hposm2
	sty colpm2
	sta wsync		;line=145
c12	lda #$04
	sta wsync		;line=146
	sta colpm1
	sta wsync		;line=147
	sta wsync		;line=148
	sta wsync		;line=149
s11	lda #$00
x20	ldx #$74
c13	ldy #$02
	sta wsync		;line=150
	sta sizep3
	stx hposp3
	sty colpm3
	sta wsync		;line=151
	sta wsync		;line=152
	sta wsync		;line=153
	sta wsync		;line=154
	sta wsync		;line=155
	sta wsync		;line=156
	sta wsync		;line=157
c14	lda #$04
	sta wsync		;line=158
	sta color0
	DLINEW dli7 1 1 1

dli7
	sta regA
	lda >fnt+$400*$06
	sta wsync		;line=160
	sta chbase
	DLINEW dli8 1 0 0

dli8
	sta regA
	stx regX
	sty regY
	lda >fnt+$400*$07
	sta wsync		;line=184
	sta chbase
	sta wsync		;line=185
s12	lda #$00
x21	ldx #$8E
c15	ldy #$08
	sta wsync		;line=186
	sta sizep2
	stx hposp2
	sty colpm2
x22	lda #$4C
c16	ldx #$0E
	sta wsync		;line=187
	sta hposp3
	stx colpm3
c17	lda #$0A
c18	ldx #$34
	sta wsync		;line=188
	sta color1
	stx colpm3
s13	lda #$43
x23	ldx #$49
	sta wsync		;line=189
	sta sizem
	stx hposm3
c19	lda #$08
c20	ldx #$34
	sta wsync		;line=190
	sta color1
	stx colpm2
	sta wsync		;line=191
c21	lda #$0A
	sta wsync		;line=192
	sta color1
c22	lda #$08
	sta wsync		;line=193
	sta color1
c23	lda #$0A
	sta wsync		;line=194
	sta color1
c24	lda #$34
	sta wsync		;line=195
	sta color2
c25	lda #$0C
	sta wsync		;line=196
	sta color1
c26	lda #$0A
	sta wsync		;line=197
	sta color1
c27	lda #$0C
	sta wsync		;line=198
	sta color1
	sta wsync		;line=199
	sta wsync		;line=200
c28	lda #$0E
	sta wsync		;line=201
	sta color1
c29	lda #$0C
	sta wsync		;line=202
	sta color1
c30	lda #$0E
	sta wsync		;line=203
	sta color1
c31	lda #$0C
	sta wsync		;line=204
	sta color1
c32	lda #$0E
	sta wsync		;line=205
	sta color1
	DLINEW dli16 1 1 1

dli16
	sta regA

	sta wsync		;line=208
	sta wsync		;line=209
c33	lda #$0C
	sta wsync		;line=210
	sta color1
c34	lda #$0E
	sta wsync		;line=211
	sta color1
c35	lda #$0C
	sta wsync		;line=212
	sta color1
	DLINEW dli9 1 0 0

dli9
	sta regA
	stx regX
	sty regY
	lda >fnt+$400*$08
c36	ldx #$0A
	sta wsync		;line=216
	sta chbase
	stx color1
c37	lda #$0C
	sta wsync		;line=217
	sta color1
c38	lda #$0A
x24	ldx #$9D
c39	ldy #$34
	sta wsync		;line=218
	sta color1
	stx hposm1
	sty colpm1
s14	lda #$03
x25	ldx #$7D
	sta wsync		;line=219
	sta sizep3
	stx hposp3
c40	lda #$08
s15	ldx #$13
x26	ldy #$45
	sta wsync		;line=220
	sta color1
	stx sizem
	sty hposm2
s16	lda #$03
x27	ldx #$59
	sta wsync		;line=221
	sta sizep2
	stx hposp2
s17	lda #$53
x28	ldx #$49
x29	ldy #$79
	sta wsync		;line=222
	sta sizem
	stx hposp1
	sty hposm3
c41	lda #$06
c42	ldx #$00
	sta wsync		;line=223
	sta color1
	stx color2
	lda >fnt+$400*$01
s18	ldx #$50
x30	ldy #$44
	sta wsync		;line=224
	sta chbase
	stx sizem
	sty hposm0
	sta wsync		;line=225
c43	lda #$08
	sta wsync		;line=226
	sta color1
c44	lda #$0C
	sta wsync		;line=227
	sta color1
	sta wsync		;line=228
	sta wsync		;line=229
c45	lda #$0E
	sta wsync		;line=230
	sta color1
	DLINEW dli10 1 1 1

dli10
	sta regA
	lda >fnt+$400*$00
	sta wsync		;line=232
	sta chbase
    ;DLINEW dli11 1 0 0

	lda regA
	rti

;dli11
;    sta regA
;
;    lda #>$a000  ; system font
;    sta wsync       ;line=232
;    sta chbase
;    lda #$01
;    sta gtictl
;
;    lda regA
;    rti


.endl

; ---

CHANGES = 1
FADECHR	= 0

SCHR	= 127

dliv = $0200

; ---

.proc	NMI

	bit nmist
	bpl VBL

	jmp DLI.dli_start


VBL
	sta regA
	stx regX
	sty regY

	;sta nmist		;reset NMI flag

	mwa #ant dlptr		;ANTIC address program

	mva #@dmactl(standard|dma|lineX1|players|missiles) dmactl	;set new screen width

	inc cloc		;little timer

; Initial values

	lda >fnt+$400*$00
	sta chbase
c0	lda #$00
	sta colbak
c1	lda #$0E
	sta color1
c2	lda #$84
	sta color2
c3	lda #$0E
	sta color3
	lda #$02
	sta chrctl
	lda #$01
	sta gtictl
	sta sizep0
s0	lda #$03
	sta sizem
x0	lda #$D0
	sta hposp0
x1	lda #$28
	sta hposm0
c4	lda #$00
	sta colpm0
x2	lda #$A2
	sta hposm3
c5	lda #$0E
	sta colpm3
s1	lda #$00
	sta sizep2
	sta sizep3
x3	lda #$92
	sta hposp2
x4	lda #$8A
	sta hposp3
c6	lda #$14
	sta colpm2
s2	lda #$00
	sta sizep1
x5	lda #$9A
	sta hposp1
c7	lda #$14
	sta colpm1
x6	lda #$A4
	sta hposm2
x7	lda #$A6
	sta hposm1
c8	lda #$00
	sta color0

	mwa #DLI.dli_start dliv	;set the first address of DLI interrupt

;this area is for yours routines
    jsr play_frame

quit
	lda regA
	ldx regX
	ldy regY
	jmp sysvbv

.endp

; ---
	ini main
; ---

	opt l-

.MACRO	SPRITES
missiles
	.he 00 00 00 00 00 00 00 00 03 03 C3 03 03 03 03 03
	.he 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	.he 03 03 03 03 03 03 03 03 03 83 83 83 C3 C3 C3 C3
	.he C3 C3 C3 C3 C3 E3 E3 E3 E3 E3 E3 F3 F3 F3 F3 FB
	.he FB FB FB FB FF FF FF FF F3 33 83 83 83 83 C3 D3
	.he D3 D3 13 03 03 03 03 03 03 03 03 03 03 03 03 03
	.he 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	.he 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 0F
	.he 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 03 03 03 03 C3 C3
	.he C3 C3 C3 C3 C3 C3 C3 C3 C3 D3 FF FF 3F 3F 3F 3F
	.he 3F 3F 33 13 03 03 03 03 03 03 03 03 03 03 03 03
	.he 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	.he 03 03 03 03 03 03 03 43 43 C3 C3 C3 C3 03 03 03
	.he 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03
	.he 03 03 0F 0F 3F 3F FF FC FE FE FF DB 03 03 03 03
	.he 03 03 03 03 03 03 03 03 00 00 00 00 00 00 00 00
player0
	.he 00 00 00 00 00 00 00 00 FF FF FF FF FF FF FF FF
	.he FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
	.he FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
	.he FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
	.he FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
	.he FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
	.he FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
	.he FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
	.he FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
	.he FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
	.he FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
	.he FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
	.he FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
	.he FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
	.he FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
	.he FF FF FF FF FF FF FF FF 00 00 00 00 00 00 00 00
player1
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 F0 FC FE FE FF FF FF FF
	.he FF 0F 0F 0F 0F 0F 0F 0F 0F 0F 07 07 07 07 07 07
	.he 03 03 03 FF FF FF FF FF CF CF FF FF FF FF FF 9F
	.he 9F FF FF FF FF FF FF FF 00 00 00 00 00 00 00 00
	.he 00 F0 F0 F0 F0 78 F8 78 78 78 78 38 78 38 3C 3C
	.he 3C 3C 1C 3C 1C 1C 1C 1C 1E 1E 1E 1E 0E 1E 0E 0E
	.he 0E 0F 07 0F 07 0F 07 07 07 07 07 07 06 06 06 06
	.he FF FF FF FF FF FF FF FF FF FF FF 00 00 3E 3F 7F
	.he 7F 7F 7F 7F 7F 7F 7F 3F 3F 3F 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 FF FF FF FF FF FF 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
player2
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 FF FF FF FF FF FF FF FF
	.he FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 FF FF FF FF FF 99 99 FF FF FF FF FF 33
	.he 33 FF FF FF FF FF FF FF 00 00 00 00 00 00 00 00
	.he 00 00 80 F0 F8 F8 F8 FC FC FC FC FC FC FC FC FC
	.he FC FE FE FE FE FE FE FF FF FF FF FF FF FF FE FC
	.he F8 F8 F8 F8 F0 F0 F0 F0 F0 F0 F0 F0 E0 E0 E0 E0
	.he E0 E0 E0 FC FE FE FF FF 8F 87 87 87 07 07 07 07
	.he 07 07 07 07 07 07 07 03 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 F8 FC FC FE FE FF FF 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 FF FF FF FF FF FF 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
player3
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 01 07 0F 1F 1F 3F 3F 7F
	.he 7F 78 78 F0 F0 F0 F0 F8 F8 F8 78 7C 7C 7C 3C 3E
	.he 3E 3E 1E 1F 1F 1F 0F 0F 0F 0F 0F 1F 1F 1F 1F 1F
	.he 1F 3F 3F 3F 3F 3F 3F 3F FF 7F 7F 3F 3F 1F 1F 0F
	.he 1F 1F 1F 3F 3F 3F 3F 3F 3F 3B 30 30 30 30 30 30
	.he 30 30 30 30 38 3E 7F 7F 7F 7F 7F 7F 7F 7F 7F 7F
	.he 7F 7F 7F 7F 7F 7F 7F FF FF FF FF FF FF FF FF FF
	.he FF FF FF FF FF FF FF FF 7F 7F 7F 7F 7F 7F FF FF
	.he FF FF FF FF FE FE FE FE FE FE FE FE FC 1C FF 7E
	.he 7E FE FE FE FE FF FF FF 7F 7E 7E 3C 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 7C FE FE FF FF FF 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 FF FF FF FF FF FF FF FF FF 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
.ENDM

USESPRITES = 1

.MACRO	DLINEW
	mva <:1 dliv
	ift [>?old_dli]<>[>:1]
	mva >:1 dliv+1
	eif

	ift :2
	lda regA
	eif

	ift :3
	ldx regX
	eif

	ift :4
	ldy regY
	eif

	rti

	.def ?old_dli = *
.ENDM

