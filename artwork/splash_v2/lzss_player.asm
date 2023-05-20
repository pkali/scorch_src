; --- dmsc LZSS player routine

song_data
        ins 'mmm_16.lzs'
song_end

buffers
    .ds 256 * 9
    
POKEY2 = POKEY+$10    ; stereo

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Song Initialization - this runs in the first tick:
;
.proc init_song

; pokeys init
    lda #3    ; stereo
    sta POKEY+$0f ; stereo
    sta POKEY2+$0f ; stereo

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
    sta POKEY2,x    ; stereo
    sta stereo_buff,x ; stereo
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
    ldx #8    ; stereo
@    lda stereo_buff,x    ; stereo
    sta POKEY2,x    ; stereo
    dex    ;stereo
    bpl @-    ; stereo
    
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
    sta POKEY,x        ; Store to output and buffer
    sta stereo_buff,x    ; stereo
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

stereo_buff    ; stereo
    .ds 9    ; stereo
    