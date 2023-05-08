;	@com.wudsn.ide.asm.mainsourcefile=scorch.asm

    .IF *>0 ;this is a trick that prevents compiling this file alone

DLIinterruptGraph = 0
;--------------------------------------------------
.macro SetDLI
;	SetDLI #WORD
;	Initialises Display List Interrupts
         LDY # <:1
         LDX # >:1
		 jsr _SetDLIproc
.endm
.proc _SetDLIproc
;	LDA #$C0
;	STY VDSLST
;	STX VDSLST+1
;	STA NMIEN
	rts
.endp

    .ENDIF
