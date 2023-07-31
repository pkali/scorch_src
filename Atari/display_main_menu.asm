;   @com.wudsn.ide.asm.mainsourcefile=scorch.asm

.IF *>0 ;this is a trick that prevents compiling this file alone
;-----------------------------------------------
; start of "variables" (RAM)
;-----------------------------------------------
OptionsHere
     ; 0123456789012345678901234567890123456789
 dta d"Players  :   2     3     4     5     6  "
 dta d"Cash     : none   2K    8K    12K   20K "
 dta d"Gravity  : 0.2G  0.5G   1G    2G    4G  "
 dta d"Wind     :  1B    3B    5B    7B    9B  "
 dta d"Rounds   :  10    20    30    40    50  "
 dta d"Missiles : slug  slow  norm  fast  hare "
 dta d"Seppuku  : nevr  rare  norm  oftn  alws "
 dta d"Mountain :  NL    BE    CZ    CH    NP  "
 dta d"Walls    : none  wrap  bump  boxy  rand "
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
 dta d"  Tank 1  "
 dta char_joy
 dta            d"1  "
 dta char_tank
 dta                d"1  Name:"
NameAdr
 dta                        d"         "
NameScreen4
 dta d" "
NamesOfLevels
 dta  d" HUMAN     Moron     Shooter   "
 dta d"  Poolshark Tosser    Chooser   "
 dta d"  Spoiler   Cyborg    Unknown   "
;------------------------
; end of "variables" (RAM)
;------------------------

.endif