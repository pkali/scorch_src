;   @com.wudsn.ide.asm.mainsourcefile=scorch.asm

.IF *>0 ;this is a trick that prevents compiling this file alone
;------------------------
; start of "constants" (ROM)
;-----------------------------------------------
;Screen displays go first to avoid crossing 4kb barrier
;-----------------------------------------------
OptionsScreen
 dta d"Welcome to Scorch v. "
 build  ; 4 bytes from scorch.asm (fancy method) :) 
 dta d"  (un)2000-2022"
 dta d" Please select option with cursor keys  "
 dta d"     and press (Return) to proceed      "
MoreUp
 dta d"         "
 dta 92,92,92
 dta d"  more  "
 dta 92,92,92
 dta d"         "
MoreDown
 dta d"         "
 dta 93,93,93
 dta d"  more  "
 dta 93,93,93
 dta d"         "
WeaponsDescription
     ; 0123456789012345678901234567890123456789
 dta d"Tab"*
 dta d   ": Defensive/Offensive weapon "
PurchaseDescription
     ; 0123456789012345678901234567890123456789
 dta d"Space"*
 dta      d": Purchase  "
 dta                  d"Return"*
 dta                        d": Finish "
ActivateDescription
     ; 0123456789012345678901234567890123456789
 dta d"Space"*
 dta      d": Activate  "
 dta                  d"Return"*
 dta                        d": Finish "
EmptyLine
 dta d"                                        "
;---------------------------------------------------
OptionsTitle
 dta d"       scorch       "*
DifficultyTitle
 dta d"   difficulty   "*
PurchaseTitle
 dta d"purchase weapons"
InventoryTitle
 dta d"activate weapons"*
GameOverTitle
 dta d"     game  over     "*
GameOverTitle2
 dta d"   Player   Points  Hits   Earned Money "
;-----------------------------------------------------
;-------------display-lists---------------------------
;-----------------------------------------------------

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
        ;.ALIGN $1000  ; WARNING!!!! 4KiB barrier crossing here, might need reassignment!!!
OptionsDL
        .byte $70
		.byte $47
		.word OptionsTitle
        .byte $70,$70
       .byte $42
        .word OptionsScreen
        .byte $30,$02,$02,$70
		.byte $42
		.word OptionsHere
		.byte $10
        :maxOptions-1 .by $02,$10
		:(9-maxOptions) .by $70,$10
		.byte $80
        .byte $4f
        .word (display+140*40)
        :21 .by $0f                     ;76
        .byte $41
        .word OptionsDL
;------------------------
;Enter names of tanks DL
NameDL
        .byte $70
		.byte $47
		.word DifficultyTitle
		.byte $70,$70
        .byte $42
        .word NameScreen
        .byte $30
        .byte $02,$30+$80,$02
        .byte $10,$02,$02,$02,$30,$02,$02
        .byte $41
        .word NameDL
; -------------------------------------------------
GameOverResults = display+$0ff0 ; reuse after game
Credits = GameOverResults +(6*40)
CreditsLastLine = Credits + (CreditsLines*40)
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
	   .byte $01
	   .word DLCreditsFragm
; ---------------
; end of "constants" (ROM)
;-----------------------------------------------
.endif