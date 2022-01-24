;   @com.wudsn.ide.asm.mainsourcefile=scorch.asm
/***************************************/
/*  Use MADS http://mads.atari8.info/  */
/*  Mode: DLI (char mode)              */
/***************************************/

	;icl "HIMARS14.h"
	;ICL '../lib/atari.hea'

	org $f0

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
	org $2000\ mva #$ff portb\ rts\ ini $2000

; ---	MAIN PROGRAM
	org $2000
ant	dta $F0
	dta $42,a(scr),$02,$02,$02,$02,$02,$02,$02,$02,$02,$82,$02,$02,$02,$02,$82
	dta $02,$02,$02,$82,$82,$82,$02,$82,$02,$02,$02,$82,$70
	dta $41,a(ant)

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

main
; ---	init PMG

	ift USESPRITES
	mva >pmg pmbase		;missiles and players data address
	mva #$03 pmcntl		;enable players and missiles
	eif

	lda:cmp:req $14		;wait 1 frame

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

	lda #$01
	sta wsync		;line=232
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

