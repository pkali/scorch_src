;   @com.wudsn.ide.asm.mainsourcefile=scorch.asm

.IF *>0 ;this is a trick that prevents compiling this file alone

statusBuffer
     ; 0123456789012345678901234567890123456789
 dta d"Player:         *                       "
 dta d"Energy:        Angle:        Force:     "
 dta d"Round:     Wind:                        "

.ENDIF