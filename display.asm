;   @com.wudsn.ide.asm.mainsourcefile=scorch.asm

.IF *>0 ;this is a trick that prevents compiling this file alone

;-----------------------------------------------------
;-------------display-lists---------------------------
;-----------------------------------------------------
PurchaseDL
        .byte $70,$70,$20
        .byte $42+$80
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
        .byte $30,$02,$02,$70
        :maxOptions .by $02,$10
        .byte $41
        .word OptionsDL
;------------------------
;Enter names of tanks DL
NameDL
        :5 .byte $70
        .byte $42
        .word NameScreen
        .byte $30
        .byte $02,$30+$80,$02
        .byte $10,$02,$02,$02,$30,$02,$02
        .byte $41
        .word NameDL
; -------------------------------------------------

dl ; MAIN game display list
        .byte 0
        .byte $42 
        .word textbuffer
        .byte $02, $02 +$80 ;DLI
        .byte $10  ; 2 blank lines 

        .byte $4f
        .word display                   ; 1 line
        :76 .by $0f                     ;76
        .by $0f+$80 ; DLI (black bar)   ;2
        .by $0f+$80 ; DLI
        :13 .by $0f                     ;13
        .by $0f+$80 ; DLI (black bar)   ;2
        .by $0f+$80 ; DLI
        :8 .by $0f                      ;8
        .by $4f                         ;1
        .wo display+$0ff0
        :2 .by $0f                      ;2
        .by $0f+$80 ; DLI (black bar)   ;2
        .by $0f+$80 ; DLI
        :9 .by $0f                      ;9
        .by $0f+$80 ; DLI (black bar)   ;2
        .by $0f+$80 ; DLI
        :8 .by $0f                      ;8
        .by $0f+$80 ; DLI (black bar)   ;2
        .by $0f+$80 ; DLI
        :7 .by $0f                      ;7
        .by $0f+$80 ; DLI (black bar)   ;2
        .by $0f+$80 ; DLI
        :6 .by $0f                      ;6
        .by $0f+$80 ; DLI (black bar)   ;2
        .by $0f+$80 ; DLI
        :5 .by $0f                      ;5
        .by $0f+$80 ; DLI (black bar)   ;2
        .by $0f+$80 ; DLI
        :4 .by $0f                      ;4
        .by $0f+$80 ; DLI (black bar)   ;2
        .by $0f+$80 ; DLI
        :3 .by $0f                      ;3
        .by $0f+$80 ; DLI (black to end);1
       :38 .byte $0f                    ;35 ..... = 200
        .by $4f
        .wo EmptyLine   ; additional line of ground
        .byte $41
        .word dl
;-----------------------------------------------
;Screen displays go first to avoid crossing 4kb barrier
;-----------------------------------------------
OptionsScreen
 dta d"Welcome to Scorch ver. "
 build  ; 3 bytes from scorch.asm (fancy method) :) 
 dta d" (un)2000-2022"
 dta d" Please select option with cursor keys  "
 dta d"     and press (Return) to proceed      "
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
OptionsScreenEnd
;-----------------------------------------------
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
GameOverResults ; reuse after game (remember to clear on start new)
ListOfDefensiveWeapons
 :16 dta d"                                        "
ListOfDefensiveWeaponsEnd ;constant useful when clearing
WeaponsDescription
 dta d"  "
 dta d"Tab"*
 dta d" - Defensive/Offensive weapon    "
 dta d"   "
 dta d"Space"*
 dta d" - "
purchaseActivate 
 dta d"Purchase  "
 dta d"Return"*
 dta d" - Finish    "
EmptyLine
 dta d"                                        "
; -------------------------------------------------
;    .ALIGN $1000  ; WARNING!!!! 4KiB barrier crossing here, might need reassignment!!!
;-----------------------------------------------
GameOverDL
       .byte $70,$40
       .byte $47    ; 16 gr8 lines
       .word GameOverTitle
       .byte $4f   ; 1 line
       .word display+(40*72)
       :28 .byte $0f   ; 28 lines
       .byte $0f+$80
       .byte $4f   ; 1 line
       .word display+(40*32)
       :30 .byte $0f   ; 30 lines
       .byte $0f+$80   ; 1 line
       .byte $4f   ; 1 line
       .word display+(40*72)
       :7 .byte $0f    ; 7 lines
       .byte $00+$80    ; 1 line
       .byte $42    ; 7 tekst lines
       .word GameOverTitle2
       .byte $00+$80
       .byte $42
       .word GameOverResults
       :5 .byte $00+$80,$02
       .byte $70
       .byte $41
       .word GameOverDL

NameScreen
 dta d"    Enter names of players      "
 dta d"   Tank  01    Name:"
NameAdr
 dta d"            "
 dta d" Human/Atari (difficulty level) "
 dta d" "
NamesOfLevels
 dta  d" HUMAN     Moron     Shooter   "
 dta d"  Poolshark Tosser    Chooser   "
 dta d"  Spoiler   Cyborg    Unknown   "
 dta d"  "
 dta d"Tab"*
 dta d" - Player/Difficulty level "
 dta d"       "
 dta d"Return"*
 dta d" - Proceed         "
;---------------------------------------------------
textbuffer
     ; 0123456789012345678901234567890123456789
 dta d"Player:                                 "
 dta d"Energy:        Angle:        Force:     "
 dta d"Round:     Wind:                        "
textbuffer2
 dta d"Player:                Cash:     0      "  ; ZERO TO MAKE YOU RICHER ON THE SCREEN
 dta d"----------------------------------------"
;---------------------------------------------------
activateText
 dta d"Activate"
activateTextEnd
purchaseText
 dta d"Purchase"
purchaseTextEnd
GameOverTitle
 dta d"     game  over     "*
GameOverTitle2
 dta d"   Player   Points  Hits   Earned Money "
.endif