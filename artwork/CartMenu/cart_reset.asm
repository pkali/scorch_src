
BankNr = $D500
; ---	
	org $0100
reset_proc
    ; set cartridge bank to 0
    mva #$0 BankNr
    ; and reset
    jmp ($fffd)
initialization
    mwa #reset_proc $0A ; set DOSVEC
    mva #$01 $09
    rts
;    
    ini initialization
