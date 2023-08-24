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
         LDY # <:1
         LDX # >:1
         LDA #:2
         JSR SETVBV
         .ENDM
;-------------------------------------
         .MACRO VDLI
;	VDLI #WORD
;	Initialises Display List Interrupts
         LDY # <:1
         LDX # >:1
         LDA #$C0
         STY $0200
         STX $0201
         STA NMIEN
         .ENDM
;-------------------------------------
        .MACRO VDL
;   VDL #WORD
;   Changes Display List addres
; and sets width of the screen
;    vdl dl,$01 - narrow screen (32 bytes)
;    vdl dl,$02 - normal screen (40 bytes)
;    vdl dl,$03 - wide screen   (48 bytes)
;       (works only with system interrupts ON)

         .if %0=2
           lda dmactls
           and #$fc
           ora #%2
           sta dmactls
         .endif

         LDA # <%1
         STA DLPTRS
         LDA # >%1
         STA DLPTRS+1
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
         PHA
?CK1      LDA SKSTAT
         AND #$04
         BEQ ?CK1
?CK       LDA SKSTAT
         AND #$04
         BNE ?CK
         PLA
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
	lda RTCLOK+2
?wa	cmp RTCLOK+2
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
    .macro pause
      ;waits :1 number (byte) of frames
      ldx #:1
?PAUSELOOP
      wait
      dex
      bne ?PAUSELOOP
    .ENDM

