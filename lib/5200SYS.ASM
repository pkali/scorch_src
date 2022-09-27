;****************************************************************************
;*                            ATARI 5200 CONSOLE                            *
;*                              SYSTEM EQUATES                              *
;****************************************************************************
; based on https://web.archive.org/web/20200831200348/http://www.atarimuseum.com/videogames/consoles/5200/conv_to_5200.html
;
; OS VARIABLES FOR 5200
; 
; PAGE 0
POKMSK  = $00               ;pokmsk at $00 on Atari 5200 instead of $10 on Atari XL
RTCLOK  = $01               ;Actually $01/$02
CRITIC  = $03
ATRACT  = $04               ;attact at $04 on Atari 5200 instead of $4D on Atari XL             
DLPTRS  = $05               ;DLPTRS at $05/$06 on Atari 5200 instead of $230 on Atari XL
DMACTLS = $07               ;DMACTLS at $07 on Atari 5200 instead of $22f on Atari XL
SSKCTL  = skctl             ;There is no shadow on Atari 5200
PCOLR0  EQU $08   ;P0 COLOR
PCOLR1  EQU $09   ;P1 COLOR
PCOLR2  EQU $0a   ;P2 COLOR
PCOLR3  EQU $0b   ;P3 COLOR
COLOR0  EQU $0c   ;COLOR 0
COLOR1  EQU $0d
COLOR2  EQU $0e
COLOR3  EQU $0f
COLOR4  EQU $10
COLBAKS EQU COLOR4
PADDL0  EQU $11
PADDL1  EQU $12
PADDL2  EQU $13
PADDL3  EQU $14
PADDL4  EQU $15
PADDL5  EQU $16
PADDL6  EQU $17
PADDL7  EQU $18
STICK0  = $19     ;There is no stick0 but we will make the analog stick look like a digital one and store it here
STRIG0  = $1a     ;There is no strig0 but we will make this the shadow of the TRIG0 ($c010) of GTIA
chbas   = $1b     ;There is no CHBAS but we will make this the shadow of the CHBASE
CONSOL  = $1c     ;There are no console keys on Atari 5200, so we replace console h/w reads with a new shadow based on the keypad keys
consol_reset = $07;The constant value representing that no consol key is pressed

; PAGE 2
VIMIRQ  EQU $0200   ;IMMED IRQ VECTOR
VVBLKI  EQU $0202   ;IMM VBLK NMI VECTOR
VVBLKD  EQU $0204   ;DEF VBLK NMI VECTOR
VDSLST  EQU $0206   ;DSP LIST NMI VECTOR
VKEYBD  EQU $0208   ;POKEY KB IRQ VECTOR
VKEYCNT EQU $020A   ;Keypad routine continuation vector
BRKKY   EQU $023C   ;BREAK KEY VECTOR
VBREAK  EQU $020E   ;BRK INST IRQ VECTOR
VSERIN  EQU $0210   ;POKEY INPUT RDY IRQ
VSEROR  EQU $0212   ;POKEY OUTPUT RDY
VSEROC  EQU $0214   ;POKEY OUTPUT DONE
VTIMR1  EQU $0216   ;POKEY TIMER 1 IRQ
VTIMR2  EQU $0218   ;POKEY TIMER 2 IRQ
VTIMR4  EQU $021A   ;POKEY TIMER 4 IRQ


ROM_SETTINGS = $bfe8  ; game ROM info start (24 bytes total, 20b title, 2b year, 2b start vector)

; HARDWARE REGISTERS

; ---------------------------------------------------------------------------
POKEY 	EQU	$EB00
; ---------------------------------------------------------------------------
;
; READ
;
POT0  	EQU	POKEY+$00
POT1  	EQU	POKEY+$01
POT2  	EQU	POKEY+$02
POT3  	EQU	POKEY+$03
POT4  	EQU	POKEY+$04
POT5  	EQU	POKEY+$05
POT6  	EQU	POKEY+$06
POT7  	EQU	POKEY+$07
ALLPOT	EQU	POKEY+$08
KBCODE	EQU	POKEY+$09
RANDOM	EQU	POKEY+$0a
POTGO 	EQU	POKEY+$0b
SERIN 	EQU	POKEY+$0d
IRQST 	EQU	POKEY+$0e
SKSTAT	EQU	POKEY+$0f
;
; WRITE
;
AUDF1 	EQU	POKEY+$00
AUDC1 	EQU	POKEY+$01
AUDF2 	EQU	POKEY+$02
AUDC2 	EQU	POKEY+$03
AUDF3 	EQU	POKEY+$04
AUDC3 	EQU	POKEY+$05
AUDF4 	EQU	POKEY+$06
AUDC4 	EQU	POKEY+$07
AUDCTL	EQU	POKEY+$08
STIMER	EQU	POKEY+$09
SKRES 	EQU	POKEY+$0a
SEROUT	EQU	POKEY+$0d
IRQEN 	EQU	POKEY+$0e
SKCTL 	EQU	POKEY+$0f
;
;
;
; ---------------------------------------------------------------------------
GTIA  	EQU	$C000
; ---------------------------------------------------------------------------
;
; WRITE
;
HPOSP0	EQU	GTIA+$00
HPOSP1	EQU	GTIA+$01
HPOSP2	EQU	GTIA+$02
HPOSP3	EQU	GTIA+$03
HPOSM0	EQU	GTIA+$04
HPOSM1	EQU	GTIA+$05
HPOSM2	EQU	GTIA+$06
HPOSM3	EQU	GTIA+$07
SIZEP0	EQU	GTIA+$08
SIZEP1	EQU	GTIA+$09
SIZEP2	EQU	GTIA+$0a
SIZEP3	EQU	GTIA+$0b
SIZEM 	EQU	GTIA+$0c
GRAFP0	EQU	GTIA+$0d
GRAFP1	EQU	GTIA+$0e
GRAFP2	EQU	GTIA+$0f
GRAFP3	EQU	GTIA+$10
GRAFM 	EQU	GTIA+$11
COLPM0	EQU	GTIA+$12
COLPM1	EQU	GTIA+$13
COLPM2	EQU	GTIA+$14
COLPM3	EQU	GTIA+$15
COLPF0	EQU	GTIA+$16
COLPF1	EQU	GTIA+$17
COLPF2	EQU	GTIA+$18
COLPF3	EQU	GTIA+$19
COLBAK	EQU	GTIA+$1a
PRIOR 	EQU	GTIA+$1b
GPRIOR = PRIOR  ; no PRIOR shadow (GPRIOR)
VDELAY	EQU	GTIA+$1c
GRACTL	EQU	GTIA+$1d
HITCLR	EQU	GTIA+$1e
CONSOL5200	EQU	GTIA+$1f  ; no CONSOL in 5200
;
; READ
;
M0PF  	EQU	GTIA+$00
M1PF  	EQU	GTIA+$01
M2PF  	EQU	GTIA+$02
M3PF  	EQU	GTIA+$03
P0PF  	EQU	GTIA+$04
P1PF  	EQU	GTIA+$05
P2PF  	EQU	GTIA+$06
P3PF  	EQU	GTIA+$07
M0PL  	EQU	GTIA+$08
M1PL  	EQU	GTIA+$09
M2PL  	EQU	GTIA+$0a
M3PL  	EQU	GTIA+$0b
P0PL  	EQU	GTIA+$0c
P1PL  	EQU	GTIA+$0d
P2PL  	EQU	GTIA+$0e
P3PL  	EQU	GTIA+$0f
TRIG0 	EQU	GTIA+$10
TRIG1 	EQU	GTIA+$11
TRIG2 	EQU	GTIA+$12
TRIG3 	EQU	GTIA+$13
PAL     EQU GTIA+$14
;
;
; ---------------------------------------------------------------------------
ANTIC 	EQU	$D400
; ---------------------------------------------------------------------------
;
DMACTL	EQU	ANTIC+$00
CHACTL	EQU	ANTIC+$01
DLPTR	EQU	ANTIC+$02
;DLISTH	EQU	ANTIC+$03
HSCROL	EQU	ANTIC+$04
VSCROL	EQU	ANTIC+$05
PMBASE	EQU	ANTIC+$07
CHBASE	EQU	ANTIC+$09
WSYNC 	EQU	ANTIC+$0a
VCOUNT	EQU	ANTIC+$0b
PENH  	EQU	ANTIC+$0c
PENV  	EQU	ANTIC+$0d
NMIEN 	EQU	ANTIC+$0e
NMIRES	EQU	ANTIC+$0f
NMIST 	EQU	ANTIC+$0f
;
; ---------------------------------------------------------------------------
;                 Atari ANTIC chip display list equates
; ---------------------------------------------------------------------------
;
JUMP	EQU	$01	; display list jump instruction (3 byte)
JVB	EQU	$41	; display list jump and wait for vblank instruction (3)
;
SCH	EQU	$10	; display list horizontal scrolling
SCV	EQU	$20	; display list vertical scrolling
LMS	EQU	$40	; display list load memory scan instruction (3 byte)
DLII	EQU	$80	; display list interrupt instruction
;
SKIP1	EQU	$00	; display list skip 1 scan line instruction
SKIP2	EQU	$10	; display list skip 2 scan lines instruction
SKIP3	EQU	$20	; display list skip 3 scan lines instruction
SKIP4	EQU	$30	; display list skip 4 scan lines instruction
SKIP5	EQU	$40	; display list skip 5 scan lines instruction
SKIP6	EQU	$50	; display list skip 6 scan lines instruction
SKIP7	EQU	$60	; display list skip 7 scan lines instruction
SKIP8	EQU	$70	; display list skip 8 scan lines instruction
;
MODE2	EQU	$02	; display list mode 2
MODE4	EQU	$04	; display list mode 4
MODE8	EQU	$08	; display list mode 8
MODEE	EQU	$0E	; display list mode E
MODEF	EQU	$0F	; display list mode F
; ---------------------------------------------------------------------------
; ENUMS
; ---------------------------------------------------------------------------

.enum   @dmactl
    blank   =    %00
    narrow  =    %01
    standard=    %10
    wide    =    %11
    missiles=   %100
    players =  %1000
    lineX1  = %10000
    lineX2  = %00000
    dma =    %100000
.ende

scr48   = @dmactl(wide|dma|players|missiles|lineX1)
scr40   = @dmactl(standard|dma|players|missiles|lineX1)
scr32   = @dmactl(narrow|dma|players|missiles|lineX1)

.enum   @pmcntl
    missiles=   %1
    players =  %10
    trigs   = %100
.ende

.enum   @gtictl
    prior0  =        %0
    prior1  =        %1
    prior2  =       %10
    prior4  =      %100
    prior8  =     %1000
    ply5    =    %10000 ; Fifth Player Enable
    mlc     =   %100000 ; Multiple Color Player Enable
    mode9   = %01000000
    mode10  = %10000000
    mode11  = %11000000
.ende
