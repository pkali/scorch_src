;	@com.wudsn.ide.asm.mainsourcefile=scorch.asm

.IF *>0 ;this is a trick that prevents compiling this file alone

;-----------------------------------------------------
;-------------display-lists---------------------------
;-----------------------------------------------------
PurchaseDL
        .byte $70,$70,$20
        .byte $42
        .word textbuffer2
        .byte $02,$10,$42
MoreUpdl
        .word EmptyLine
        .byte 0,$42
WeaponsListDL
        .word ListOfWeapons
 :15 .byte 0,2
 .byte 0, $42
MoreDownDL
 .word EmptyLine
 .byte $10,$42
 .word WeaponsDescription
 .byte 2
        .byte $41
        .word PurchaseDL
;------------------------
OptionsDL
        :5 .byte $70
        .byte $42
        .word OptionsScreen
        .byte $02,$02,$70,$02,0,$02,0,$2,0,$2
        .byte $41
        .word OptionsDL
;------------------------
;Enter names of tanks DL
NameDL
        :5 .byte $70
        .byte $42
        .word NameScreen
        .byte $30
        .byte $02,$30,$2
        .byte $10,2,2,2,$30,2,2
        .byte $41
        .word NameDL
; -------------------------------------------------

dl ; MAIN game display list
        .byte $70,$00
        .byte $42 
        .word textbuffer
        .byte $02 +$80 ;DLI
        .byte $00 

        .byte $4f
        .word WhiteLine
	.byte $4f
	.word PlotLine
        .byte $4f
        .word WhiteLine

        .byte $4f
        .word display

        :100 .by $0f
        .by $0f
        .by $4f
        .wo display+$0ff0
        :97 .byte $0f
        .byte $41
        .word dl
; horizontal line
WhiteLine
 :screenBytes .by $ff
PlotLine = display + screenHeight*screenBytes ; the last line is plot pointer 
;-----------------------------------------------
;Screen displays go first to avoid crossing 4kb barrier
;-----------------------------------------------
OptionsScreen
 dta d"Welcome to Scorch ver. 125 (un)2000-2022"
 dta d" Please select option with cursor keys  "
 dta d"     and press (Return) to proceed      "
OptionsHere   
     ; 0123456789012345678901234567890123456789
 dta d"Players :    2    3    4    5    6      "
 dta d"Cash    :  none   2K   5K   8K  10K     "
 dta d"Gravity :  0.2G 0.5G  1G   2G   4G      "
 dta d"Wind    :   1B   3B   5B   7B   9B      "
OptionsScreenEnd
; -------------------------------------------------
NameScreen
 dta d"    Enter names of players      "
 dta d"   Tank  01    Name:"
NameAdr
 dta d"            "
 dta d" Human/Atari (difficulty level) "
 dta d" "
NamesOfLevels
 dta d" HUMAN     Moron     Shooter   "
 dta d"  Poolshark Toosser   Chooser   "
 dta d"  Spoiler   Cyborg    Unknown   "
 dta d"  "
 dta d"Tab"*
 dta d" - Player/Difficulty level "
 dta d"       "
 dta d"Return"*
 dta d" - Proceed         "
;---------------------------------------------------
MoreUp
 dta d"             "
 dta 92,92,92
 dta d"  more  "
 dta 92,92,92
 dta d"             "
MoreDown
 dta d"             "
 dta 93,93,93
 dta d"  more  "
 dta 93,93,93
 dta d"             "
ListOfWeapons
 :36 dta d"                                        "
ListOfWeapons1End
ListOfDefensiveWeapons
 :16 dta d"                                        "
ListOfDefensiveWeaponsEnd ;constant useful when clearing
WeaponsDescription
 dta d"  "
 dta d"Tab"*
 dta d" - Defensive/Offensive weapon    "
 dta d"   "
 dta d"Space"*
 dta d" - Purchase  "
 dta d"Return"*
 dta d" - Finish    "
EmptyLine
 dta d"                                        "
;-----------------------------------------------
textbuffer
 dta d"Player:                                 "
 dta d"                                        "
textbuffer2
 dta d"Player: ********       Cash: 00000      "
 dta d"----------------------------------------"


.endif
