;   @com.wudsn.ide.asm.mainsourcefile=scorch.asm

.IF *>0 ;this is a trick that prevents compiling this file alone
;-----------------------------------------------
; start of "variables" (RAM)
;-----------------------------------------------
OptionsHere   
     ; 0123456789012345678901234567890123456789
 dta d"Players  :    2    3    4    5    6     "
 dta d"Cash     :  none  2K   8K   12K  20K    "
 dta d"Gravity  :  0.2G 0.5G  1G   2G   4G     "
 dta d"Wind     :   1B   3B   5B   7B   9B     "
 dta d"Rounds   :   10   20   30   40   50     "
 dta d"Missiles :  slug slow norm fast hare    "
 dta d"Seppuku  :  nevr rare norm oftn alws    "
 dta d"Mountains:   NL   BE   CZ   CH   NP     "
 dta d"Walls    :  none wrap bump boxy rand    "
;;      01234567890123456789012345678901
; dta d"Players:  2    3    4    5    6 "
; dta d"Cash   :none  2K   8K   12K  20K"
; dta d"Gravity:0.2G 0.5G  1G   2G   4G "
; dta d"Wind   : 1B   3B   5B   7B   9B "
; dta d"Rounds : 10   20   30   40   50 "
; dta d"Missile:slug slow norm fast hare"
; dta d"Seppuku:nevr rare norm oftn alws"
; dta d"Hills  : NL   BE   CZ   CH   NP "
; dta d"Walls  :none wrap bump boxy rand"
OptionsScreenEnd

;-----------------------------------------------
NameScreen2
 dta d"   Tank  01    Name:"
NameAdr
 dta                     d"            "
NameScreen4
 dta d" "
NamesOfLevels
 dta  d" HUMAN     Moron     Shooter   "
 dta d"  Poolshark Tosser    Chooser   "
 dta d"  Spoiler   Cyborg    Unknown   "
;---------------------------------------------------
textbuffer2
 dta d"Player:             Cash:      0"  ; ZERO TO MAKE YOU RICHER ON THE SCREEN

; DLs fragments (modified by game code)
; all Purchase DL :)
PurchaseDL
        .byte $70
		.byte $47
DLPurTitleAddr
		.word PurchaseTitle
		.byte $50
        .byte $42+$80
        .word textbuffer2
        .byte $60,$42
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
	   .byte $42+$20	; VSCRL
DLCreditsAddr
	   .word Credits
	   :6 .byte $02+$20
	   .byte $02
       .byte $41
       .word GameOverDL
;------------------------
; end of "variables" (RAM)
;------------------------

.endif