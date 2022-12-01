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
 dta                          d"  (un)2000-2022"

.IF TARGET = 800
 dta d" Please select option with cursor keys  "
 dta d"     and press (Return) to proceed      "
.ELIF TARGET = 5200
 dta d" Please select option with joystick one "
 dta d"       and press FIRE to proceed        "
.ENDIF
     ; 0123456789012345678901234567890123456789
;-----------------------------------------------
NameScreen
.IF TARGET = 800
 dta d"     Enter names of players     "
.ELIF TARGET = 5200
 dta d"Hold "
 dta d     "FIRE"*
 dta d         " to enter player names "
.ENDIF
NameScreen3
 dta d" Human/Atari (difficulty level) "
NameScreen5
 .IF TARGET = 800
 dta d" "
 dta  d"TAB"*
 dta     d" - Port nr "
 dta                d"Joy"*
 dta                   d" - Difficulty "
 dta d"       "
 dta        d"Return"*
 dta              d" - Proceed         "
.ELIF TARGET = 5200
 dta d" "
 dta  d"(5)"*
 dta     d" - Port nr "
 dta                d"Joy"*
 dta                   d" - Difficulty "
 dta d"        "
 dta        d"FIRE"*
 dta             d" - Proceed          "
.ENDIF
;-----------------------------------------------
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
 .IF TARGET = 800
 dta d"Tab"*
 dta d   ": Defensive/Offensive weapon "
.ELIF TARGET = 5200
 dta d"Left"*
 dta d    ": Defensive/Offensive weapon"
.ENDIF
PurchaseDescription
     ; 0123456789012345678901234567890123456789
 .IF TARGET = 800
 dta d"Space"*
 dta      d": Purchase  "
 dta                  d"Return"*
 dta                        d": Finish "
.ELIF TARGET = 5200
 dta d"Right"*
 dta      d": Purchase    "
 dta                    d"FIRE"*
 dta                        d": Finish "
.ENDIF
ActivateDescription
     ; 0123456789012345678901234567890123456789
 .IF TARGET = 800
 dta d"Space"*
 dta      d": Activate  "
 dta                  d"Return"*
 dta                        d": Finish "
.ELIF TARGET = 5200
 dta d"Right"*
 dta      d": Activate    "
 dta                    d"FIRE"*
 dta                        d": Finish "
.ENDIF
EmptyLine
 dta d"                                        "
;---------------------------------------------------
OptionsTitle
.IF TARGET = 800
 dta d"       scorch       "*
.ELIF TARGET = 5200
 dta d" scorch supersystem "*
; dta d"     scorch "*
; dta             d"5"
; dta              d"k"*
; dta               d"2"
; dta                d"     "*
.ENDIF
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
        .byte $70
        .byte $42 
        .word statusBuffer
        .byte $02, $02
        .byte $10+$80  ; 2 blank lines + DLI

        .byte $4f
        .word display                   ; 1 line
        :76 .by $0f                     ;76
        .by $0f+$80,$0f ; DLI (black bar)   ;3
        .by $0f+$80 ; DLI
        :12 .by $0f                     ;12
        .by $0f+$80,$0f ; DLI (black bar)   ;3
        .by $0f+$80 ; DLI
        :7 .by $0f                      ;7
        .by $4f                         ;1
        .wo display+$0ff0
        :2 .by $0f                      ;2
        .by $0f+$80,$0f ; DLI (black bar)   ;3
        .by $0f+$80 ; DLI
        :8 .by $0f                      ;8
        .by $0f+$80,$0f ; DLI (black bar)   ;3
        .by $0f+$80 ; DLI
        :7 .by $0f                      ;7
        .by $0f+$80,$0f ; DLI (black bar)   ;3
        .by $0f+$80 ; DLI
        :6 .by $0f                      ;6
        .by $0f+$80,$0f ; DLI (black bar)   ;3
        .by $0f+$80 ; DLI
        :5 .by $0f                      ;5
        .by $0f+$80,$0f ; DLI (black bar)   ;3
        .by $0f+$80 ; DLI
        :4 .by $0f                      ;4
        .by $0f+$80,$0f ; DLI (black bar)   ;3
        .by $0f+$80 ; DLI
        :3 .by $0f                      ;3
        .by $0f+$80,$0f ; DLI (black bar)   ;3
        .by $0f+$80 ; DLI
        :2 .by $0f                      ;2
        .by $0f+$80 ; DLI (black to end);1
       :38 .byte $0f                    ;35 ..... = 200
        .by $4f
        .wo EmptyLine   ; additional line of ground
        .byte $41
        .word dl
;-----------------------------------------------
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
		.byte $60  ; to match moved sprites
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
		.byte $70,$70	; 16 empty lines
        .byte $42
        .word NameScreen
        .byte $30	; 4 empty lines
		.byte $42
		.word NameScreen2
		.byte $30+$80	; 4 empty lines + DLI
		.byte $42
		.word NameScreen3
        .byte $10	; 2 empty lines
		.byte $42
		.word NameScreen4
		.byte $02,$02
		.byte $30	; 4 empty lines
		.byte $42
		.word NameScreen5
		.byte $02
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
;       .byte $60  ; 7 lines down to match new sprite position
       .byte $4f   ; 1 line
       .word display+(40*72)
       :28 .byte $0f   ; 28 lines
       .byte $0f+$80
       .byte $4f   ; 1 line
       .word display+(40*(32-7)) ;7 lines up to match new sprite position
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