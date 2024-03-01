;-------------------------------------
  .MACRO ROLW
     ROL :1
    ROL :1+1
  .ENDM
;-------------------------------------
  .MACRO ASLW
    ASL :1
    ROL :1+1
  .ENDM
;-------------------------------------
  .MACRO RORW
    ROR :1+1
    ROR :1
  .ENDM
;-------------------------------------
  .MACRO LSRW
    LSR :1+1
    ROR :1
  .ENDM

;-------------------------------------
         .MACRO VMAIN
;	VMAIN #WORD,interrupt.vector
; interrupt.vector:
;    0 - VIMIRQ
;    1 - TIMCNT1
;    2 - TIMCNT2
;    3 - TIMCNT3
;    4 - TIMCNT4
;    5 - TIMCNT5
;    6 - VVBLKI
;    7 - VVBLKD
;    8 - TIMVEC1
;    9 - TIMVEC2
;	Initialises Vertical Blank Interrupts
;       (works only with system interrupts ON)
;----------
; on 5200 it sets up deferred VBL ONLY for now
    sei
    lda #$00            ;Disable all interruptes
    sta nmien
    sta irqen
    
@   lda vcount
    bne @-
    mwa #:1 VVBLKD
    mva #$40 nmien
    ;Enable IRQ interrupts
    sta pokmsk
    sta irqen
    cli
    
         .ENDM
;-------------------------------------
         .MACRO VDLI
;	VDLI #WORD
;	Initialises Display List Interrupts
    mwa #:1 VDSLST
    mva #$C0 NMIEN
         .ENDM
;-------------------------------------
      .MACRO halt
?stop  
      lda RANDOM 
      and #$05
      sta COLBAK
      jmp ?stop
      .ENDM
;-------------------------------------
         .MACRO KEY
;	KEY
;	waits for releasing and pressing "any key"

         .ENDM
;-------------------------------------
	.MACRO WAIT
;	WAIT
;	waits one frame (1/50 s(PAL) or 1/60s(NTSC))
?ze	LDA VCOUNT
	cmp #16	; if line<16 then wait for line>15 (long VBI protection)
	bcc ?ze
	sbc #10	; last lines correction
?wa	cmp VCOUNT
	bcc ?wa
?wf	cmp VCOUNT
	bcs ?wf
	.ENDM
;-------------------------------------
	.macro waitRTC
	lda RTCLOK+1
?wa	cmp RTCLOK+1
	beq ?wa
	.endm
;-------------------------------------
    .macro negw
    ; negate the given word (0-a)
;-------------------------------------
        sec
        lda #$00
        sbc :1
        sta :1
        lda #$00
        sbc :1+1
        sta :1+1
    .endm
;-------------------------------------
    .macro randomize
    ;usage: randomize floor ceiling
    ;returns (in A) a random .byte between "floor" and "ceiling"
    .if :2 < :1
      .error "floor higher than ceiling"
    .endif
?rand
      lda random
      cmp #:2+1-:1 ;ceiling
      bcs ?rand
    .if %1>0    ; if floor = 0 - no add offset
      adc #:1
    .endif
    .endm
;-------------------------------------
    .macro phx
      txa
      pha
    .endm
;-------------------------------------
    .macro phy
      tya
      pha
    .endm
;-------------------------------------
    .macro plx
      pla
      tax
    .endm
;-------------------------------------
    .macro ply
      pla
      tay
    .endm
;-------------------------------------
    .macro txy
      txa
      tay
    .endm
;-------------------------------------
    .macro tyx
      tya
      tax
    .endm
;-------------------------------------
    .macro pause
      ;waits :1 number (byte) of frames
      ldx #:1
?PAUSELOOP
      wait
      dex
      bne ?PAUSELOOP
    .ENDM

