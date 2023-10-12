
Bank0 = $D500
; ---	
	org $0100
reset_proc
    ; set cartridge bank to 0
    sta Bank0
    ; and reset
    jmp ($fffc)
initialization
    mwa #reset_proc $0C ; set DOSINI
    mva #$01 $09
    rts
;    
    ini initialization
