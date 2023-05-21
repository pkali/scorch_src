
    icl '../lib/atari.hea'

    org $2000
joytest
    mva #0 dmactls

@
    lda trig0
    beq pressed
    mva #0 colbak
    beq @-
pressed
    lda #$0f
    ;ora jstick0
    sta colbak
    jmp @-

    run joytest
