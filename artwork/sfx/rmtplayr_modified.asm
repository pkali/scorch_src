;
; Raster Music Tracker, RMT Atari routine version 1.20090108
; (c) Radek Sterba, Raster/C.P.U., 2002 - 2009
; http://raster.atari.org
;
; Warnings:
;
; 1. RMT player routine needs 19 itself reserved bytes in zero page (no accessed
;    from any other routines) as well as cca 1KB of memory before the "PLAYER"
;    address for frequency tables and functionary variables. It's:
;      a) from PLAYER-$03c0 to PLAYER for stereo RMTplayer
;    b) from PLAYER-$0320 to PLAYER for mono RMTplayer
;
; 2. RMT player routine MUST (!!!) be compiled from the begin of the memory page.
;    i.e. "PLAYER" address can be $..00 only!
;
; 3. Because of RMTplayer provides a lot of effects, it spent a lot of CPU time.
;
; STEREOMODE    equ 0..3            ;0 => compile RMTplayer for 4 tracks mono
;                                    ;1 => compile RMTplayer for 8 tracks stereo
;                                    ;2 => compile RMTplayer for 4 tracks stereo L1 R2 R3 L4
;                                    ;3 => compile RMTplayer for 4 tracks stereo L1 L2 R3 R4

TRACKS        equ 4
; RMT FEATures definitions file
; For optimizations of RMT player routine to concrete RMT modul only!
    icl "feat.txt"
;FEAT_EFFECTS equ FEAT_EFFECTVIBRATO||FEAT_EFFECTFSHIFT
;
; RMT ZeroPage addresses
.zpvar p_tis            .word
p_instrstable = p_tis
.zpvar p_trackslbstable .word
.zpvar p_trackshbstable .word
.zpvar p_song           .word
.zpvar ns               .word
.zpvar nr               .word
.zpvar nt               .byte
.zpvar reg1             .byte
.zpvar reg2                .byte
.zpvar reg3             .byte
.zpvar tmp              .byte
.zpvar v_audctl         .byte  ; de-self-modification vars
.zpvar v_ainstrspeed    .byte
.zpvar v_maxtracklen    .byte
.zpvar v_abeat          .byte
.zpvar v_bspeed         .byte
.zpvar v_speed          .byte
.zpvar RMTSFXVOLUME     .byte

;  MOVED TO variables.asm
;    org PLAYER-$400+$e0
;track_variables
;trackn_db    .ds TRACKS
;trackn_hb    .ds TRACKS
;trackn_idx    .ds TRACKS
;trackn_pause    .ds TRACKS
;trackn_note    .ds TRACKS
;trackn_volume    .ds TRACKS
;trackn_distor     .ds TRACKS
;trackn_shiftfrq    .ds TRACKS
;trackn_instrx2    .ds TRACKS
;trackn_instrdb    .ds TRACKS
;trackn_instrhb    .ds TRACKS
;trackn_instridx    .ds TRACKS
;trackn_instrlen    .ds TRACKS
;trackn_instrlop    .ds TRACKS
;trackn_instrreachend    .ds TRACKS
;trackn_volumeslidedepth .ds TRACKS
;trackn_volumeslidevalue .ds TRACKS
;trackn_effdelay            .ds TRACKS
;trackn_effvibratoa        .ds TRACKS
;trackn_effshift        .ds TRACKS
;trackn_tabletypespeed .ds TRACKS
;trackn_tablenote    .ds TRACKS
;trackn_tablea        .ds TRACKS
;trackn_tableend        .ds TRACKS
;trackn_tablelop        .ds TRACKS
;trackn_tablespeeda    .ds TRACKS
;trackn_command        .ds TRACKS
;trackn_filter        .ds TRACKS
;trackn_audf    .ds TRACKS
;trackn_audc    .ds TRACKS
;trackn_audctl    .ds TRACKS
;v_aspeed        .ds 1
;track_endvariables

INSTRPAR    equ 12
tabbeganddistor
 dta frqtabpure-frqtab,$00
 dta frqtabpure-frqtab,$20
 dta frqtabpure-frqtab,$40
 dta frqtabbass1-frqtab,$c0
 dta frqtabpure-frqtab,$80
 dta frqtabpure-frqtab,$a0
 dta frqtabbass1-frqtab,$c0
 dta frqtabbass2-frqtab,$c0
vibtabbeg dta 0,vib1-vib0,vib2-vib0,vib3-vib0
vib0    dta 0
vib1    dta 1,-1,-1,1
vib2    dta 1,0,-1,-1,0,1
vib3    dta 1,1,0,-1,-1,-1,-1,0,1,1
vibtabnext
        dta vib0-vib0+0
        dta vib1-vib0+1,vib1-vib0+2,vib1-vib0+3,vib1-vib0+0
        dta vib2-vib0+1,vib2-vib0+2,vib2-vib0+3,vib2-vib0+4,vib2-vib0+5,vib2-vib0+0
        dta vib3-vib0+1,vib3-vib0+2,vib3-vib0+3,vib3-vib0+4,vib3-vib0+5,vib3-vib0+6,vib3-vib0+7,vib3-vib0+8,vib3-vib0+9,vib3-vib0+0
    .align $100
frqtab
    ERT [<frqtab]!=0    ;* frqtab must begin at the memory page bound! (i.e. $..00 address)
frqtabbass1
    dta $BF,$B6,$AA,$A1,$98,$8F,$89,$80,$F2,$E6,$DA,$CE,$BF,$B6,$AA,$A1
    dta $98,$8F,$89,$80,$7A,$71,$6B,$65,$5F,$5C,$56,$50,$4D,$47,$44,$3E
    dta $3C,$38,$35,$32,$2F,$2D,$2A,$28,$25,$23,$21,$1F,$1D,$1C,$1A,$18
    dta $17,$16,$14,$13,$12,$11,$10,$0F,$0E,$0D,$0C,$0B,$0A,$09,$08,$07
frqtabbass2
    dta $FF,$F1,$E4,$D8,$CA,$C0,$B5,$AB,$A2,$99,$8E,$87,$7F,$79,$73,$70
    dta $66,$61,$5A,$55,$52,$4B,$48,$43,$3F,$3C,$39,$37,$33,$30,$2D,$2A
    dta $28,$25,$24,$21,$1F,$1E,$1C,$1B,$19,$17,$16,$15,$13,$12,$11,$10
    dta $0F,$0E,$0D,$0C,$0B,$0A,$09,$08,$07,$06,$05,$04,$03,$02,$01,$00
frqtabpure
    dta $F3,$E6,$D9,$CC,$C1,$B5,$AD,$A2,$99,$90,$88,$80,$79,$72,$6C,$66
    dta $60,$5B,$55,$51,$4C,$48,$44,$40,$3C,$39,$35,$32,$2F,$2D,$2A,$28
    dta $25,$23,$21,$1F,$1D,$1C,$1A,$18,$17,$16,$14,$13,$12,$11,$10,$0F
    dta $0E,$0D,$0C,$0B,$0A,$09,$08,$07,$06,$05,$04,$03,$02,$01,$00,$00

    .align $100
volumetab
    dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    dta $00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01
    dta $00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02
    dta $00,$00,$00,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$03,$03,$03
    dta $00,$00,$01,$01,$01,$01,$02,$02,$02,$02,$03,$03,$03,$03,$04,$04
    dta $00,$00,$01,$01,$01,$02,$02,$02,$03,$03,$03,$04,$04,$04,$05,$05
    dta $00,$00,$01,$01,$02,$02,$02,$03,$03,$04,$04,$04,$05,$05,$06,$06
    dta $00,$00,$01,$01,$02,$02,$03,$03,$04,$04,$05,$05,$06,$06,$07,$07
    dta $00,$01,$01,$02,$02,$03,$03,$04,$04,$05,$05,$06,$06,$07,$07,$08
    dta $00,$01,$01,$02,$02,$03,$04,$04,$05,$05,$06,$07,$07,$08,$08,$09
    dta $00,$01,$01,$02,$03,$03,$04,$05,$05,$06,$07,$07,$08,$09,$09,$0A
    dta $00,$01,$01,$02,$03,$04,$04,$05,$06,$07,$07,$08,$09,$0A,$0A,$0B
    dta $00,$01,$02,$02,$03,$04,$05,$06,$06,$07,$08,$09,$0A,$0A,$0B,$0C
    dta $00,$01,$02,$03,$03,$04,$05,$06,$07,$08,$09,$0A,$0A,$0B,$0C,$0D
    dta $00,$01,$02,$03,$04,$05,$06,$07,$07,$08,$09,$0A,$0B,$0C,$0D,$0E
    dta $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
;*
;* Set of RMT main vectors:
;*
RASTERMUSICTRACKER
    jmp rmt_init
    jmp rmt_play
    jmp rmt_p3
    jmp rmt_silence
    jmp SetPokey
    jmp rmt_sfx            ;* A=note(0,..,60),X=channel(0,..,3 or 0,..,7),Y=instrument*2(0,2,4,..,126)
rmt_init
    stx ns
    sty ns+1
    pha
    ldy #track_endvariables-track_variables
    lda #0
ri0    sta track_variables-1,y
    dey
    bne ri0
    ldy #4
    lda (ns),y
    sta v_maxtracklen
    iny
    lda (ns),y
    sta v_speed
    ldy #8
ri1    lda (ns),y
    sta p_tis-8,y
    iny
    cpy #8+8
    bne ri1
    pla
    pha
    asl @
    asl @
    clc
    adc p_song
    sta p_song
    pla
    php
    and #$c0
    asl @
    rol @
    rol @
    plp
    adc p_song+1
    sta p_song+1
    jsr GetSongLineTrackLineInitOfNewSetInstrumentsOnlyRmtp3
rmt_silence
    lda #0
    sta $d208
    sta $d208+$10
    ldy #3
    sty $d20f
    sty $d20f+$10
    ldy #8
si1    sta $d200,y
        sta $d200+$10,y
    dey
    bpl si1
    lda #FEAT_INSTRSPEED
    rts
GetSongLineTrackLineInitOfNewSetInstrumentsOnlyRmtp3
GetSongLine
    ldx #0
    stx v_abeat
nn0
nn1    txa
    tay
    lda (p_song),y
    cmp #$fe
    bcs nn2
    tay
    lda (p_trackslbstable),y
    sta trackn_db,x
    lda (p_trackshbstable),y
nn1a sta trackn_hb,x
    lda #0
    sta trackn_idx,x
    lda #1
nn1a2 sta trackn_pause,x
    lda #$80
    sta trackn_instrx2,x
    inx
xtracks01    cpx #TRACKS
    bne nn1
    lda p_song
    clc
xtracks02    adc #TRACKS
    sta p_song
    bcc GetTrackLine
    inc p_song+1
nn1b
    jmp GetTrackLine
nn2
    beq nn3
nn2a
    lda #0
    beq nn1a2
nn3
    ldy #2
    lda (p_song),y
    tax
    iny
    lda (p_song),y
    sta p_song+1
    stx p_song
    ldx #0
    beq nn0
GetTrackLine
oo0
oo0a
    lda v_speed

    sta v_bspeed
    ldx #-1
oo1
    inx
    dec trackn_pause,x
    bne oo1x
oo1b
    lda trackn_db,x
    sta ns
    lda trackn_hb,x
    sta ns+1
oo1i
    ldy trackn_idx,x
    inc trackn_idx,x
    lda (ns),y
    sta reg1
    and #$3f
    cmp #61
    beq oo1a
    bcs oo2
    sta trackn_note,x
    iny
    lda (ns),y
    lsr @
    and #$3f*2
    sta trackn_instrx2,x
oo1a
    lda #1
    sta trackn_pause,x
    ldy trackn_idx,x
    inc trackn_idx,x
    lda (ns),y
    lsr @
    ror reg1
    lsr @
    ror reg1
    lda reg1
    and #$f0
    sta trackn_volume,x
oo1x
xtracks03sub1    cpx #TRACKS-1
    bne oo1
    lda v_bspeed

    sta v_speed
    sta v_aspeed
    jmp InitOfNewSetInstrumentsOnly
oo2
    cmp #63
    beq oo63
    lda reg1
    and #$c0
    beq oo62_b
    asl @
    rol @
    rol @
    sta trackn_pause,x
    jmp oo1x
oo62_b
    iny
    lda (ns),y
    sta trackn_pause,x
    inc trackn_idx,x
    jmp oo1x
oo63
    lda reg1
    bmi oo63_1X
    iny
    lda (ns),y
    sta v_bspeed
    inc trackn_idx,x
    jmp oo1i
oo63_1X
    cmp #255
    beq oo63_11
    iny
    lda (ns),y
    sta trackn_idx,x
    jmp oo1i
oo63_11
    jmp GetSongLine
p2xrmtp3    jmp rmt_p3
p2x0 dex
     bmi p2xrmtp3
InitOfNewSetInstrumentsOnly
p2x1 ldy trackn_instrx2,x
    bmi p2x0
    jsr SetUpInstrumentY2
    jmp p2x0
rmt_sfx
    sta trackn_note,x
    lda RMTSFXVOLUME                ;* sfx note volume*16
        ;* label for sfx note volume parameter overwriting
    sta trackn_volume,x
SetUpInstrumentY2
    lda (p_instrstable),y
    sta trackn_instrdb,x
    sta nt
    iny
    lda (p_instrstable),y
    sta trackn_instrhb,x
    sta nt+1
    lda #1
    sta trackn_filter,x
    tay
    lda (nt),y
    sta trackn_tablelop,x
    iny
    lda (nt),y
    sta trackn_instrlen,x
    iny
    lda (nt),y
    sta trackn_instrlop,x
    iny
    lda (nt),y
    sta trackn_tabletypespeed,x
    sta trackn_tablespeeda,x
    iny
    lda (nt),y
    sta trackn_audctl,x
    iny
    lda (nt),y
    sta trackn_volumeslidedepth,x
    ldy #8
    lda (nt),y
    sta trackn_effdelay,x
    iny
    lda (nt),y
    tay
    lda vibtabbeg,y
    sta trackn_effvibratoa,x
    ldy #10
    lda (nt),y
    sta trackn_effshift,x
    lda #128
    sta trackn_volumeslidevalue,x
    sta trackn_instrx2,x
    asl @
    sta trackn_instrreachend,x
    sta trackn_shiftfrq,x
    tay
    lda (nt),y
    sta trackn_tableend,x
    adc #0
    sta trackn_instridx,x
    lda #INSTRPAR
    sta trackn_tablea,x
    tay
    lda (nt),y
    sta trackn_tablenote,x
xata_rtshere
    rts
rmt_play
rmt_p0
    jsr SetPokey
rmt_p1
rmt_p2
    dec v_aspeed
    bne rmt_p3
    inc v_abeat
    lda v_abeat

    cmp v_maxtracklen

    beq p2o3
    jmp GetTrackLine
p2o3
    jmp GetSongLineTrackLineInitOfNewSetInstrumentsOnlyRmtp3
go_ppnext    jmp ppnext
rmt_p3
    lda #>frqtab
    sta nr+1
xtracks05sub1    ldx #TRACKS-1
pp1
    lda trackn_instrhb,x
    beq go_ppnext
    sta ns+1
    lda trackn_instrdb,x
    sta ns
    ldy trackn_instridx,x
    lda (ns),y
    sta reg1
    iny
    lda (ns),y
    sta reg2
    iny
    lda (ns),y
    sta reg3
    iny
    tya
    cmp trackn_instrlen,x
    bcc pp2
    beq pp2
    lda #$80
    sta trackn_instrreachend,x
pp1b
    lda trackn_instrlop,x
pp2    sta trackn_instridx,x
    lda reg1
    and #$0f
    ora trackn_volume,x
    tay
    lda volumetab,y
    sta tmp
    lda reg2
    and #$0e
    tay
    lda tabbeganddistor,y
    sta nr
    lda tmp
    ora tabbeganddistor+1,y
    sta trackn_audc,x
InstrumentsEffects
    lda trackn_effdelay,x
    beq ei2
    cmp #1
    bne ei1
    lda trackn_shiftfrq,x
    clc
    adc trackn_effshift,x
    clc
    ldy trackn_effvibratoa,x
    adc vib0,y
    sta trackn_shiftfrq,x
    lda vibtabnext,y
    sta trackn_effvibratoa,x
    jmp ei2
ei1
    dec trackn_effdelay,x
ei2
    ldy trackn_tableend,x
    cpy #INSTRPAR+1
    bcc ei3
    lda trackn_tablespeeda,x
    bpl ei2f
ei2c
    tya
    cmp trackn_tablea,x
    bne ei2c2
    lda trackn_tablelop,x
    sta trackn_tablea,x
    bne ei2a
ei2c2
    inc trackn_tablea,x
ei2a
    lda trackn_instrdb,x
    sta nt
    lda trackn_instrhb,x
    sta nt+1
    ldy trackn_tablea,x
    lda (nt),y
    sta trackn_tablenote,x
    lda trackn_tabletypespeed,x
ei2f
    sec
    sbc #1
    sta trackn_tablespeeda,x
ei3
    lda trackn_instrreachend,x
    bpl ei4
    lda trackn_volume,x
    beq ei4
    tay
    lda trackn_volumeslidevalue,x
    clc
    adc trackn_volumeslidedepth,x
    sta trackn_volumeslidevalue,x
    bcc ei4
    tya
    sbc #16
    sta trackn_volume,x
ei4
    lda reg2
    sta trackn_command,x
    and #$70
    beq cmd0
cmd1
    lda reg3
    jmp cmd0c
cmd2
cmd3
cmd4
cmd5
cmd6
cmd7
cmd0
    lda trackn_note,x
    clc
    adc reg3
cmd0a
    clc
    adc trackn_tablenote,x
    cmp #61
    bcc cmd0a1
    lda #0
    sta trackn_audc,x
    lda #63
cmd0a1
    tay
    lda (nr),y
    clc
    adc trackn_shiftfrq,x
cmd0c
    sta trackn_audf,x
pp9
ppnext
    dex
    bmi rmt_p4
    jmp pp1
rmt_p4
    lda trackn_audctl+0
    ora trackn_audctl+1
    ora trackn_audctl+2
    ora trackn_audctl+3
    tax
qq1
    stx v_audctl
    lda trackn_command+0
    bpl qq2
    lda trackn_audc+0
    and #$0f
    beq qq2
    lda trackn_audf+0
    clc
    adc trackn_filter+0
    sta trackn_audf+2
    lda #0
    sta trackn_audc+2
qq1a
    txa
    ora #4
    tax
qq2
    lda trackn_command+1
    bpl qq3
    lda trackn_audc+1
    and #$0f
    beq qq3
    lda trackn_audf+1
    clc
    adc trackn_filter+1
    sta trackn_audf+3
    lda #0
    sta trackn_audc+3
qq2a
    txa
    ora #2
    tax
qq3
;    cpx v_audctl
;    bne qq5
;qq5
    stx v_audctl
rmt_p5
;    lda v_ainstrspeed
.IF TARGET = 800
    ldx #$10                ; pseudo stereo
    bne SetPokey_OffsetX    ; pseudo stereo
.ELIF TARGET = 5200
    rts
.ENDIF
SetPokey
    ldx #0    ; POKEY registers offset (for stereo)
SetPokey_OffsetX
    lda trackn_audf+0
    sta AUDF1,x
    lda trackn_audc+0
    sta AUDC1,x
    lda trackn_audf+1
    sta AUDF2,x
    lda trackn_audc+1
    sta AUDC2,x
    lda trackn_audf+2
    sta AUDF3,x
    lda trackn_audc+2
    sta AUDC3,x
    lda trackn_audf+3
    sta AUDF4,x
    lda trackn_audc+3
    sta AUDC4,x
    lda v_audctl
    sta AUDCTL,x
    rts
RMTPLAYEREND
