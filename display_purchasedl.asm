;   @com.wudsn.ide.asm.mainsourcefile=scorch.asm

.IF *>0 ;this is a trick that prevents compiling this file alone
;---------------------------------------------------
purchaseTextBuffer
 dta d"Player:             Cash:      0"  ; ZERO TO MAKE YOU RICHER ON THE SCREEN

; DLs fragments (modified by game code)
; all Purchase DL :)
PurchaseDL
        .byte $70
        .byte $47
DLPurTitleAddr
        .word PurchaseTitle
        .byte $50
        .byte $42
        .word purchaseTextBuffer
		.byte $00+$80
        .byte $50,$42
MoreUpdl
        .word EmptyLine
        .byte 0,$42
WeaponsListDL
        .word ListOfWeapons
 :15 .byte 0,2
 .byte 0, $42
MoreDownDL
 .word EmptyLine
 .byte $40,$42
 .word WeaponsDescription
 .byte $0,$42
PurActDescAddr
 .word PurchaseDescription
        .byte $41
        .word PurchaseDL
;------------------------
DLCreditsFragm
       .byte $60+$80
       .byte $42+$20    ; VSCRL
DLCreditsAddr
       .word Credits
       :6 .byte $02+$20
       .byte $02
       .byte $41
       .word GameOverDL
.endif