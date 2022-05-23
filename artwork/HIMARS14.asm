;   @com.wudsn.ide.asm.mainsourcefile=../scorch.asm
/***************************************/
/*  Use MADS http://mads.atari8.info/  */
/*  Mode: DLI (char mode)              */
/***************************************/

	;icl "HIMARS14.h"
	;ICL '../lib/atari.hea'


WIDTH	= 40
HEIGHT	= 30

; ---	BASIC switch OFF
	org $2000\ mva #$ff portb\ rts\ ini $2000

; --- dmsc LZSS player routine on zero page
    org $80

chn_copy    .ds     9
chn_pos     .ds     9
bptr        .ds     2
cur_pos     .ds     1
chn_bits    .ds     1

bit_data    .byte   1

.proc get_byte
    lda song_data+1
    inc song_ptr
    bne skip
    inc song_ptr+1
skip
    rts
.endp
song_ptr = get_byte + 1
    

fcnt    .ds 2
fadr    .ds 2
fhlp    .ds 2
cloc    .ds 1
regA    .ds 1
regX    .ds 1
regY    .ds 1
; ---	MAIN PROGRAM
	org $2000
ant	dta $80
	dta $42,a(scr),$02,$02,$02,$02,$02,$02,$02,$02,$02,$82,$02,$02,$02,$02,$82
	dta $02,$02,$02,$82,$82,$82,$02,$82,$02,$02,$02,$82
	dta $42,a(verline)
	dta $41,a(ant)

verline
    :37 dta d" "
    build

scr	ins "HIMARS14.scr"

	.ds 2*40

	.ALIGN $0400
fnt	ins "HIMARS14.fnt"

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
        ins     'mmm_16.lzs'
song_end

POKEY = $D200

buffers
    .ds 256 * 9

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Song Initialization - this runs in the first tick:
;
.proc init_song

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
.proc check_end_song
    lda song_ptr + 1
    cmp #>song_end
    ;bne wait_frame
    lda song_ptr
    cmp #<song_end
    ;bne wait_frame
.endp

end_loop
    rts


main
    jsr init_song

; ---	init PMG

	ift USESPRITES
	mva >pmg pmbase		;missiles and players data address
	mva #$03 pmcntl		;enable players and missiles
	eif

	lda:cmp:req $14		;wait 1 frame

    ; copy system font to $a000
    ldx #0
@   lda $e000,x
    sta $a000,x
    ;lda $e100,x  ; i need digits only :]
    ;sta $a100,x
    ;lda $e200,x
    ;sta $a200,x
    ;lda $e300,x
    ;sta $a300,x
    inx
    bne @-

	sei			;stop IRQ interrupts
	mva #$00 nmien		;stop NMI interrupts
	sta dmactl
	mva #$fe portb		;switch off ROM to get 16k more ram

	mwa #NMI $fffa		;new NMI handler

	mva #$c0 nmien		;switch on NMI+DLI again

	ift CHANGES		;if label CHANGES defined

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

	els

null	jmp DLI.dli1		;CPU is busy here, so no more routines allowed

	eif


stop
	mva #$00 pmcntl		;PMG disabled
	tax
	sta:rne hposp0,x+

	mva #$ff portb		;ROM switch on
	mva #$40 nmien		;only NMI interrupts, DLI disabled
	cli			;IRQ enabled

    
    lda #0
    ldx #8
@   sta POKEY,x
    dex
    bpl @-
        
    ;no glitching please (issue #67)
    lda #0
    sta $D400 ;dmactl
    sta $022F ;dmactls
	rts			;return to ... DOS

; ---	DLI PROGRAM

.local	DLI

	?old_dli = *

	ift !CHANGES

dli1	lda trig0		; FIRE #0
	beq stop

	lda trig1		; FIRE #1
	beq stop

	lda consol		; START
	and #1
	beq stop

	lda skctl
	and #$04
	beq stop

	lda vcount
	cmp #$02
	bne dli1

	:3 sta wsync

	DLINEW dli10

	eif

dli_start

dli10
	sta regA

c4	lda #$04
	sta wsync		;line=8
	sta color0
	sta gtictl
	DLINEW DLI.dli2 1 0 0

dli2
	sta regA
	lda >fnt+$400*$01
	sta wsync		;line=96
	sta chbase
	DLINEW dli3 1 0 0

dli3
	sta regA
	lda >fnt+$400*$02
	sta wsync		;line=136
	sta chbase
	DLINEW dli4 1 0 0

dli4
	sta regA
	lda >fnt+$400*$01
	sta wsync		;line=168
	sta chbase
	DLINEW dli5 1 0 0

dli5
	sta regA
	lda >fnt+$400*$02
	sta wsync		;line=176
	sta chbase
	DLINEW dli6 1 0 0

dli6
	sta regA
	lda >fnt+$400*$03
	sta wsync		;line=184
	sta chbase
	DLINEW dli7 1 0 0

dli7
	sta regA
	lda >fnt+$400*$00
	sta wsync		;line=200
	sta chbase
	DLINEW dli11 1 0 0

dli11
	sta regA

    lda #>$a000  ; system font
	sta wsync		;line=232
    sta chbase
    lda #$01
	sta gtictl

	lda regA
	rti

.endl

; ---

CHANGES = 1
FADECHR	= 0

SCHR	= 127

; ---

.proc	NMI

	bit nmist
	bpl VBL

	jmp DLI.dli_start
dliv	equ *-2

VBL
	sta regA
	stx regX
	sty regY

	sta nmist		;reset NMI flag

	mwa #ant dlptr		;ANTIC address program

	mva #@dmactl(standard|dma|lineX1) dmactl	;set new screen width

	inc cloc		;little timer

; Initial values

	lda >fnt+$400*$00
	sta chbase
c0	lda #$00
	sta colbak
	lda #$02
	sta chrctl
	lda #$01
	sta gtictl
c1	lda #$0C
	sta color1
c2	lda #$02
	sta color2
c3	lda #$0E
	sta color3
x0	lda #$00
	sta hposp0
	sta hposp1
	sta hposp2
	sta hposp3
	sta hposm0
	sta hposm1
	sta hposm2
	sta hposm3
	sta sizep0
	sta sizep1
	sta sizep2
	sta sizep3
	sta sizem
	sta colpm0
	sta colpm1
	sta colpm2
	sta colpm3
	sta color0

	mwa #DLI.dli_start dliv	;set the first address of DLI interrupt

;this area is for yours routines
    jsr play_frame

quit
	lda regA
	ldx regX
	ldy regY
	rti

.endp

; ---
	ini main
; ---

	opt l-

.MACRO	SPRITES
missiles
	.ds $100
player0
	.ds $100
player1
	.ds $100
player2
	.ds $100
player3
	.ds $100
.ENDM

USESPRITES = 0

.MACRO	DLINEW
	mva <:1 NMI.dliv
	ift [>?old_dli]<>[>:1]
	mva >:1 NMI.dliv+1
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

