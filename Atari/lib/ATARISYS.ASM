;****************************************************************************
;*                         ATARI PERSONAL COMPUTER                          *
;*                              SYSTEM EQUATES                              *
;****************************************************************************
;
; OPERATING SYSTEM EQUATE FILE
;
; MODULE ORIGIN TABLE
;
; VECTOR TABLE
;
; HANDLER ENTRY POINTS ARE CALL-
; ED OUT IN THE FOLLOWING VECTOR
; TABLE. THESE ARE THE ADDRESSES
; MINUS ONE.
;
; EXAMPLE FOR EDITOR
;
; E400     OPEN
;    2     CLOSE
;    4     GET
;    6     PUT
;    8     STATUS
;    A     SPECIAL
;    C     JUMP TO POWER ON INIT
;    F     NOT USED
;
EDITRV	EQU	$E400	;EDITOR
SCRENV	EQU	$E410	;TV SCREEN
KEYBDV	EQU	$E420	;KEYBOARD
PRINTV	EQU	$E430	;PRINTER
CASETV	EQU	$E440	;CASSETTE
;
; JUMP VECTOR TABLE
;
; THE FOLLOWING IS A TABLE OF
; JUMP INSTRUCTIONS TO VARIOUS
; ENTRY POINTS IN THE OPERATING
; SYSTEM
;
DISKIV	EQU	$E450	;DISK INITIALIZATION
DSKINV	EQU	$E453	;DISK INTERFACE
CIOV  	EQU	$E456	;CENTRAL I/O ROUTINE
SIOV  	EQU	$E459	;SERIAL I/O ROUTINE
SETVBV	EQU	$E45C	;SET SYSTEM TIMERS
SYSVBV	EQU	$E45F	;VBLANK CALCULATIONS
XITVBV	EQU	$E462	;EXIT VBLANK
SIOINV	EQU	$E465	;SIO INITIALIZATION
SENDEV	EQU	$E468	;SEND ENABLE ROUTINE
INTINV	EQU	$E46B	;INTRPT HANDLER INIT
CIOINV	EQU	$E46E	;CIO INITIALIZATION
BLKBDV	EQU	$E471	;BLACKBOARD MODE
WARMSV	EQU	$E474	;WARM START VECTOR
COLDSV	EQU	$E477	;COLD START VECTOR
RBLOKV	EQU	$E47A	;CASSETTE READ BLOCK
CSOPIV	EQU	$E47D	;CASSETTE INPUT OPEN
;
; VECTORS ADDED FOR 800XL
;
PUPDIV	EQU	$E480	;POWER UP DISPLAY
SLFTSV	EQU	$E483	;SELF TEST PROGRAM
PHENTV	EQU	$E486	;UPLOADED HANDLER ENTER
PHULNV	EQU	$E489	;UPLOADED HANDLER UNLINK
PHINIV	EQU	$E48C	;UPLOADED HANDLER INIT
;
; OPERATING SYSTEM EQUATES
;
; COMMAND CODES FOR IOCBS
;
_OPEN  	EQU	$03	;OPEN FOR I/O
GETREC	EQU	$05	;GET RECORD (TEXT)
GETCHR	EQU	$07	;GET CHARACTER(S)
PUTREC	EQU	$09	;PUT RECORD (TEXT)
PUTCHR	EQU	$0B	;PUT CHARACTER(S)
_CLOSE 	EQU	$0C	;CLOSE DEVICE
STATIS	EQU	$0D	;STATUS REQUEST
SPECIL	EQU	$0E	;SPECIAL ENTRY COMMAND
;
; SPECIAL ENTRY COMMANDS
;
DRAWLN	EQU	$11	;DRAW LINE
FILLIN	EQU	$12	;FILL
RENAME	EQU	$20	;RENAME DISK FILE
DELETE	EQU	$21	;DELETE DISK FILE
FORMAT	EQU	$22	;FORMAT DISK
LOCKFL	EQU	$23	;LOCK FILE
UNLOCK	EQU	$24	;UNLOCK FILE
POINT 	EQU	$25	;POINT SECTOR
NOTE  	EQU	$26	;NOTE SECTOR
IOCFRE	EQU	$FF	;IOCB "FREE"
;
; AUX1 EQUATES
; () INDICATES WHICH DEVICES
;
APPEND	EQU	$01	;WR APPEND(D)-SCN RD(E)
DIRECT	EQU	$02	;OPEN DIRECTORY(D)
OPNIN 	EQU	$04	;OPEN FOR INPUT(ALL)
OPNOT 	EQU	$08	;OPEN FOR OUTPUT(ALL)
OPNINO	EQU	$0C	;OPEN INPUT&OUTPUT(ALL)
MXDMOD	EQU	$10	;OPEN MIXED MODE(E,S)
INSCLR	EQU	$20	;OPEN W/O CLEAR(E,S)
;
; DEVICE NAMES
;
SCREDT	EQU	'E'	;SCREEN EDITOR (R/W)
KBD   	EQU	'K'	;KEYBOARD (R ONLY)
DISPLY	EQU	'S'	;SCREEN DISPLAY (R/W)
PRINTR	EQU	'P'	;PRINTER (W ONLY)
CASSET	EQU	'C'	;CASSETTE (R/W)
RS232 	EQU	'R'	;MODEM (R/W)
DISK  	EQU	'D'	;DISK (R/W)
;
;
;
; OPERATING SYSTEM STATUS CODES
;
SUCCES	EQU	$01	;SUCCESSFUL OPERATION
BRKABT	EQU	$80	;BREAK KEY ABORT
PRVOPN	EQU	$81	;IOCB ALREADY OPEN
NONDEV	EQU	$82	;NON-EXISTANT DEVICE
WRONLY	EQU	$83	;IOCB OPEN FOR W ONLY
NVALID	EQU	$84	;INVALID COMMAND
NOTOPN	EQU	$85	;DEVICE/FILE NOT OPEN
BADIOC	EQU	$86	;INVALID IOCB #
RDONLY	EQU	$87	;IOCB OPEN FOR R ONLY
EOFERR	EQU	$88	;END OF FILE
TRNRCD	EQU	$89	;TRUNCATED RECORD
TIMOUT	EQU	$8A	;PERIPHERAL TIMEOUT
DNACK 	EQU	$8B	;DEVICE NO ACKNOWLEDGE
FRMERR	EQU	$8C	;SERIAL BUS FRAME ERR
CRSROR	EQU	$8D	;CURSOR OVERRANGE
OVRRUN	EQU	$8E	;SERIAL DATA OVERRUN
CHKERR	EQU	$8F	;SERIAL CHECKSUM ERR
DERRER	EQU	$90	;PERIPHRAL DEVICE ERR
BADMOD	EQU	$91	;BAD SCREEN MODE #
FNCNOT	EQU	$92	;NONEXISTANT FUNCTION
SCRMEM	EQU	$93	;SCREEN MEM TOO SMALL
FILENF  EQU $AA ;FILE NOT FOUND
;
; PAGE ZERO RAM ASSIGNMENTS
;
LNFLG 	EQU	$00	;LINBUG RAM
NGFLAG	EQU	$01	;POWER-UP SELF-TEST FLAG
;
; THESE LOCATIONS NOT CLEARED
;
CASINI	EQU	$02	;CASSETTE INIT LOC
RAMLO 	EQU	$04	;RAM POINTER MEM TST
TRAMSZ	EQU	$06	;TEMP REG RAM SIZE
TSTDAT	EQU	$07	;RAM TEST DATA REG
;
;CLEARED ON COLDSTART ONLY
;
WARMST	EQU	$08	;WARM START FLAG
BOOTQ 	EQU	$09	;SUCCESSFUL BOOT FLG
DOSVEC	EQU	$0A	;DOS START VECTOR
DOSINI	EQU	$0C	;DOS INIT ADDRESS
APPMHI	EQU	$0E	;APPL MEM HI LIMIT
;
;CLEARED ON COLD OR WARM START
;
POKMSK	EQU	$10	;MASK POKEY IRQ
BRKKEY	EQU	$11	;BREAK KEY FLAG
RTCLOK	EQU	$12	;REAL TIME CLOCK
BUFADR	EQU	$15	;INDIRECT BUFF ADDR
ICCOMT	EQU	$17	;COMMAND FOR VECTOR
DSKFMS	EQU	$18	;FMS POINTER
DSKUTL	EQU	$1A	;DISK UTILITIES PTR
ABUFPT	EQU	$1C	;RESERVED
ICHIDZ	EQU	$20	;HANDLER INDEX #
ICDNOZ	EQU	$21	;DEVICE NUMBER
ICCOMZ	EQU	$22	;COMMAND CODE
ICSTAZ	EQU	$23	;STATUS RETURN
ICBALZ	EQU	$24	;BUFFER ADDRESS
ICBAHZ	EQU	$25
ICPTLZ	EQU	$26	;PUT BYTE ROUTINE-1
ICPTHZ	EQU	$27
ICBLLZ	EQU	$28	;BUFFER LENGTH
ICBLHZ	EQU	$29
ICAX1Z	EQU	$2A	;AUXILIARY BYTES
ICAX2Z	EQU	$2B
ICSPRZ	EQU	$2C	;SPARE BYTES
ICIDNO	EQU	$2E	;IOCB # X 16
CIOCHR	EQU	$2F	;CIO CHARACTER BYTE
STATUS	EQU	$30	;INTERNAL STATUS
CHKSUM	EQU	$31	;CHECKSUM
BUFRLO	EQU	$32	;DATA BUFFER LO BYTE
BUFRHI	EQU	$33	;DATA BUFFER HI BYTE
BFENLO	EQU	$34	;NEXT BYTE PAST DATA
BFENHI	EQU	$35	;BUFFER (HI & LO)
LTEMP 	EQU	$36	;LOADER TEMP
BUFRFL	EQU	$38	;DATA BUFFR FULL FLG
RECVDN	EQU	$39	;RECIEVE DONE FLAG
XMTDON	EQU	$3A	;XMIT DONE FLAG
CHKSNT	EQU	$3B	;CHECKSUM SENT FLAG
NOCKSM	EQU	$3C	;NO CHKSUM SENT FLAG
;BPTR  	EQU	$3D	;CASSETTE DATA INDEX
FTYPE 	EQU	$3E	;INTERRECORD GAP TYPE
FEOF  	EQU	$3F	;END OF FILE FLAG
FREQ  	EQU	$40	;BEEP COUNT
SOUNDR	EQU	$41	;NOISY I/O FLAG
CRITIC	EQU	$42	;CRITICAL MODE
FMSZPG	EQU	$43	;FMS ZERO PAGE
ZCHAIN	EQU	$4A	;HANDLER LOADER TEMP
DSTAT 	EQU	$4C	;DISPLAY STATUS
ATRACT	EQU	$4D	;ATTRACT FLAG
DRKMSK	EQU	$4E	;DARK ATTRACT MASK
COLRSH	EQU	$4F	;COLOR SHIFTER
TMPCHR	EQU	$50	;TEMP STORAGE
HOLD1 	EQU	$51	;TEMP STORAGE
LMARGN	EQU	$52	;LEFT MARGIN (1)
RMARGN	EQU	$53	;RIGHT MARGIN (38)
ROWCRS	EQU	$54	;CURSOR COUNTERS
COLCRS	EQU	$55
DINDEX	EQU	$57	;DISPLAY MODE #
SAVMSC	EQU	$58	;SCREEN MEM ADDR
OLDROW	EQU	$5A	;DRAW START POSIT
OLDCOL	EQU	$5B
OLDCHR	EQU	$5D	;DATA UNDER CURSOR
OLDADR	EQU	$5E	;CURSOR MEM ADDR
FKDEF 	EQU	$60	;FUNC KEY DEFEAT POINTER
PALNTS	EQU	$62	;PAL/NTSC FLAG
LOGCOL	EQU	$63	;COL IN LOGICAL LINE
ADRESS	EQU	$64	;TEMP STORAGE
MLTEMP	EQU	$66	;TEMP STORAGE
SAVADR	EQU	$68	;TEMP STORAGE
RAMTOP	EQU	$6A	;AVAILABLE RAM PAGES
BUFCNT	EQU	$6B	;BUFFER COUNT
BUFSTR	EQU	$6C	;EDITOR GETCH POINTR
BITMSK	EQU	$6E	;BIT MASK
SHFAMT	EQU	$6F	;PIXEL JUSTIFICATION
ROWAC 	EQU	$70	;ROW ACCUMULATOR
COLAC 	EQU	$72	;COLUMN ACCUMULATOR
ENDPT 	EQU	$74	;LINE LENGTH
DELTAR	EQU	$76	;DELTA ROW
DELTAC	EQU	$77	;DELTA COLUMN
KEYDEF	EQU	$79	;KEY DEFEAT POINTER
SWPFLG	EQU	$7B	;SPLIT SCN CURS CNTL
HOLDCH	EQU	$7C	;KB CHAR TEMP HOLD
INSDAT	EQU	$7D	;TEMP STORAGE
COUNTR	EQU	$7E	;DRAW ITERATION CNT
;
; 80-FF ARE RESERVED FOR USER
;
; NOTE: SEE FLOATING POINT
; SUBROUTINE AREA FOR ZERO
; PAGE CELLS
;
; PAGE 1 - HARDWARE STACK
;
; PAGE TWO RAM ASSIGNMENTS
;
VDSLST	EQU	$0200	;DSP LIST NMI VECTOR
VPRCED	EQU	$0202	;PROCEED IRQ VECTOR
VINTER	EQU	$0204	;INTERUPT IRQ VECTOR
VBREAK	EQU	$0206	;BRK INST IRQ VECTOR
VKEYBD	EQU	$0208	;POKEY KB IRQ VECTOR
VSERIN	EQU	$020A	;POKEY INPUT RDY IRQ
VSEROR	EQU	$020C	;POKEY OUTPUT RDY
VSEROC	EQU	$020E	;POKEY OUTPUT DONE
VTIMR1	EQU	$0210	;POKEY TIMER 1 IRQ
VTIMR2	EQU	$0212	;POKEY TIMER 2 IRQ
VTIMR4	EQU	$0214	;POKEY TIMER 4 IRQ
VIMIRQ	EQU	$0216	;IMMED IRQ VECTOR
CDTMV1	EQU	$0218	;COUNT DOWN TIMER 1
CDTMV2	EQU	$021A	;COUNT DOWN TIMER 2
CDTMV3	EQU	$021C	;COUNT DOWN TIMER 3
CDTMV4	EQU	$021E	;COUNT DOWN TIMER 4
CDTMV5	EQU	$0220	;COUNT DOWN TIMER 5
VVBLKI	EQU	$0222	;IMM VBLK NMI VECTOR
VVBLKD	EQU	$0224	;DEF VBLK NMI VECTOR
CDTMA1	EQU	$0226	;CDTMV1 JSR ADDRESS
CDTMA2	EQU	$0228	;CDTMV2 JSR ADDRESS
CDTMF3	EQU	$022A	;CDTMV3 FLAG
SRTIMR	EQU	$022B	;SOFTWARE REPEAT TMR
CDTMF4	EQU	$022C	;CDTMV4 FLAG
INTEMP	EQU	$022D	;IAN'S TEMP
CDTMF5	EQU	$022E	;CDTMV5 FLAG
DMACTLS	EQU	$022F	;SAVE DMACTL REG
DLPTRS	EQU	$0230	;SAVE DISP LIST LO
;SDLSTH	EQU	$0231	;SAVE DISP LIST HI
SSKCTL	EQU	$0232	;SKCTL REGISTER RAM
LCOUNT	EQU	$0233	;LOADER TEMP
LPENH 	EQU	$0234	;LIGHT PEN HORIZONTAL
LPENV 	EQU	$0235	;LIGHT PEN VERTICAL
BRKKY 	EQU	$0236	;BREAK KEY VECTOR
RELADR	EQU	$0238	;LOADER REL ADDR
CDEVIC	EQU	$023A	;COMMAND BUFFER-DEV
CCOMND	EQU	$023B	;COMMAND BUFFER-CMND
CAUX1 	EQU	$023C	;COMMAND BUFFER AUX1
CAUX2 	EQU	$023D	;COMMAND BUFFER AUX2
;TEMP  	EQU	$023E	;TEMPORARY RAM CELL
ERRFLG	EQU	$023F	;DEVICE ERROR FLAG
DFLAGS	EQU	$0240	;DISK FLAGS(SECTOR1)
DBSECT	EQU	$0241	;# DISK BOOT SECTORS
BOOTAD	EQU	$0242	;DISK BOOT ADDRESS
COLDST	EQU	$0244	;COLDSTART FLAG 1=CS
RECLEN	EQU	$0245	;LOADER LENGTH
DSKTIM	EQU	$0246	;DISK TIME OUT REG
VSFLAG	EQU	$026C	;FINE SCROLL TEMP
KEYDIS	EQU	$026D	;KEY DISABLE FLAG
FINE  	EQU	$026E	;FINE SCROLL ENABLE(A1200)
GPRIOR	EQU	$026F	;GLOBAL PRIORITY
PADDL0	EQU	$0270	;POT 0 RAM CELL
PADDL1	EQU	$0271
PADDL2	EQU	$0272
PADDL3	EQU	$0273
STICK0	EQU	$0278	;JOYSTICK 0 RAM CELL
STICK1	EQU	$0279
PTRIG0	EQU	$027C	;PADDLE TRIGGER 0
PTRIG1	EQU	$027D
PTRIG2	EQU	$027E
PTRIG3	EQU	$027F
STRIG0	EQU	$0284	;JOYSTICK TRIGGER 0
STRIG1	EQU	$0285
HIBYTE	EQU	$0288	;LOADER
WMODE 	EQU	$0289	;CASSETTE R/W MODE
BLIM  	EQU	$028A	;CASSETTE RECORD SIZE
IMASK 	EQU	$028B
JVECK 	EQU	$028C	;JUMP VECTOR
NEWADR	EQU	$028E	;LOADER NEW ADDRESS
TXTROW	EQU	$0290	;TEXT ROWCRS
TXTCOL	EQU	$0291	;TEXT COLCRS
TINDEX	EQU	$0293	;TEXT INDEX
TXTMSC	EQU	$0294	;TEXT WINDOW MEM ADD
TXTOLD	EQU	$0296	;TEXT OLDROW & COL
CRETRY	EQU	$029C	;# COMMAND RETRIES
HOLD3 	EQU	$029D
SUBTMP	EQU	$029E
HOLD2 	EQU	$029F
DMASK 	EQU	$02A0	;PIXEL LOCATION MASK
TMPLBT	EQU	$02A1
ESCFLG	EQU	$02A2	;ESCAPE FLAG
TABMAP	EQU	$02A3	;TAB STOP MAP
LOGMAP	EQU	$02B2 	;LINE START BIT MAP
INVFLG	EQU	$02B6	;INVERSE VIDEO FLAG
FILFLG	EQU	$02B7	;FILL FLAG FOR DRAW
TMPROW	EQU	$02B8
TMPCOL	EQU	$02B9
SCRFLG	EQU	$02BB	;SET IF SCROLLING
HOLD4 	EQU	$02BC	;TEMP USED BY DRAW
DRETRY	EQU	$02BD	;# OF DEVICE RETRIES
SHFLOK	EQU	$02BE	;SHIFT/CTL LOCK FLAG
BOTSCR	EQU	$02BF	;BOTTOM OF SCREEN
PCOLR0	EQU	$02C0	;P0 COLOR
PCOLR1	EQU	$02C1	;P1 COLOR
PCOLR2	EQU	$02C2	;P2 COLOR
PCOLR3	EQU	$02C3	;P3 COLOR
COLOR0	EQU	$02C4	;COLOR 0
COLOR1	EQU	$02C5
COLOR2	EQU	$02C6
COLOR3	EQU	$02C7
COLOR4	EQU	$02C8
COLBAKS EQU COLOR4
RUNADR	EQU	$02C9	;LOADER
HIUSED	EQU	$02CB	;LOADER
ZHIUSE	EQU	$02CD	;LOADER
GBYTEA	EQU	$02CF	;LOADER
LOADAD	EQU	$02D1	;LOADER
ZLOADA	EQU	$02D3	;LOADER
DSCTLN	EQU	$02D5	;DISK SECTOR LENGTH
ACMISR	EQU	$02D7	;RESERVED
KRPDEL	EQU	$02D9	;KEY REPEAT DELAY
KEYREP	EQU	$02DA	;KEY REPEAT RATE(VBLANKS)
NOCLIK	EQU	$02DB	;CLICK ENABLE/DISABLE
HELPFG	EQU	$02DC	;HELP KEY FLAG
DMASAV	EQU	$02DD	;DMA SAVE STATE
PBPNT 	EQU	$02DE	;PRINT BUFFER POINTER
PBUFSZ	EQU	$02DF	;PRINT BUFFER SIZE
DOSRUN	EQU	$02E0	;DOS RUN/INIT ADDRESSES
RAMSIZ	EQU	$02E4	;RAM SIZE-HIGH BYTE
MEMTOP	EQU	$02E5	;TOP OF AVAIL MEMORY
MEMLO 	EQU	$02E7	;BOTTOM OF AVAIL MEM
HNDLOD	EQU	$02E9	;POLL FLAG (1200)
DVSTAT	EQU	$02EA	;STATUS BUFFER
CBAUDL	EQU	$02EE	;CASSETTE BAUD RATE
CBAUDH	EQU	$02EF
CRSINH	EQU	$02F0	;CURSOR INHIBIT 0=ON
KEYDEL	EQU	$02F1	;KEY DELAY
CH1	    EQU	$02F2	;PRIOR KB CHAR CODE
CHACT 	EQU	$02F3	;CHACTL REGISTER RAM
CHBAS 	EQU	$02F4	;CHBAS REGISTER RAM
NEWROW	EQU	$02F5	;POINT DRAW GOES TO
NEWCOL	EQU	$02F6
ROWINC	EQU	$02F8	;ROW INCREMENT VALUE
COLINC	EQU	$02F9	;COL INCREMENT VALUE
CHAR  	EQU	$02FA	;INTERNAL CHAR CODE
ATACHR	EQU	$02FB	;ATASCII CHARACTER
CHKEY  	EQU	$02FC	;KB CHAR CODE (FIFO)
FILDAT	EQU	$02FD	;RIGHT FILL DATA
DSPFLG	EQU	$02FE	;DISPLAY FLAG
SSFLAG	EQU	$02FF	;START/STOP FLAG
;
; PAGE THREE RAM ASSIGNMENTS
;
DDEVIC	EQU	$0300	;BUS I.D. NUMBER
DUNIT 	EQU	$0301	;UNIT NUMBER
DCOMND	EQU	$0302	;BUS COMMAND
DSTATS	EQU	$0303	;COMMAND TYPE/STATUS
DBUFLO	EQU	$0304	;DATA BUFFER LO BYTE
DBUFHI	EQU	$0305	;DATA BUFFER HI BYTE
DTIMLO	EQU	$0306	;DEVICE TIMEOUT SECS
DUNUSE	EQU	$0307	;UNUSED BYTE
DBYTLO	EQU	$0308	;# OF BYTES XFERRED
DBYTHI	EQU	$0309
DAUX1 	EQU	$030A	;COMMAND AUX BYTE 1
DAUX2 	EQU	$030B	;COMMAND AUX BYTE 2
TIMER1	EQU	$030C	;INITIAL TIMER VALUE
JMPERS	EQU	$030E	;OPTIONS (1200)
CASFLG	EQU	$030F	;CASSETE MODE IF SET
TIMER2	EQU	$0310	;FINAL TIMER VALUE
;TEMP1 	EQU	$0312	;TEMP STORAGE
;TEMP2 	EQU	$0313	;TEMP STORAGE
PTIMOT	EQU	$0314	;PRINTER TIMEOUT REG
;TEMP3 	EQU	$0315	;TEMP STORAGE
SAVIO 	EQU	$0316	;SAVE SERIAL IN DATA
TIMFLG	EQU	$0317	;TIMEOUT FLAG C BAUD
STACKP	EQU	$0318	;SIO STACK PTR SAVE
TSTAT 	EQU	$0319	;TEMP STATUS HOLDER
HATABS	EQU	$031A	;HANDLER ADDR TABLE
PUPBT1	EQU	$033D	;POWER/UP RESET
PUPBT2	EQU	$033E
PUPBT3	EQU	$033F
ICHID 	EQU	$0340	;HANDLER INDEX #
ICDNO 	EQU	$0341	;DEVICE NUMBER
ICCOM 	EQU	$0342	;COMMAND CODE
ICSTA 	EQU	$0343	;STATUS
ICBAL 	EQU	$0344	;BUFFER ADDR LO BYTE
ICBAH 	EQU	$0345	;BUFFER ADDR HI BYTE
ICPTL 	EQU	$0346	;PUT ROUTINE ADDR-1
ICPTH 	EQU	$0347
ICBLL 	EQU	$0348	;BUFFER LENGTH LO
ICBLH 	EQU	$0349	;BUFFER LENGTH HI
ICAX1 	EQU	$034A	;AUX BYTE 1
ICAX2 	EQU	$034B	;AUX BYTE 2
ICSPR 	EQU	$034C 	;SPARE BYTES
PRNBUF	EQU	$03C0	;PRINTER BUFFER (40 BYTES)
SUPERF	EQU	$03E8	;SCREEN EDITOR
CKEY  	EQU	$03E9	;START KEY FLAG
CASSBT	EQU	$03EA	;CASSETTE BOOT FLAG
CARTCK	EQU	$03EB	;CARTRIDGE CHECKSUM
ACMVAR	EQU	$03ED	;RESERVED
MINTLK	EQU	$03F9	;RESERVED
GINTLK	EQU	$03FA	;CART INTERLOCK
CHLINK	EQU	$03FB	;HANDLER CHAIN
;
; PAGE FOUR RAM ASSIGNMENTS
;
CASBUF	EQU	$03FD	;CASSETTE BUFFER (131 BYTES)
USAREA	EQU	$0480	;USER AREA
;
; PAGE FIVE AND SIX ARE RESERVED
; FOR USER WORK SPACE
;
;    COLLEEN MNEMONICS
;
; ---------------------------------------------------------------------------
POKEY 	EQU	$D200
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
GTIA  	EQU	$D000
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
VDELAY	EQU	GTIA+$1c
GRACTL	EQU	GTIA+$1d
HITCLR	EQU	GTIA+$1e
CONSOL	EQU	GTIA+$1f
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
;
; ---------------------------------------------------------------------------
PIA   	EQU	$D300
; ---------------------------------------------------------------------------
;
PORTA 	EQU	PIA+0
PORTB 	EQU	PIA+1
PACTL 	EQU	PIA+2
PBCTL 	EQU	PIA+3
;
; ---------------------------------------------------------------------------
;                 Atari ANTIC chip display list equates
; ---------------------------------------------------------------------------
;
JUMP	EQU	$01	; display list jump instruction (3 byte)
JVB	    EQU	$41	; display list jump and wait for vblank instruction (3)
;
SCH	    EQU	$10	; display list horizontal scrolling
SCV	    EQU	$20	; display list vertical scrolling
LMS	    EQU	$40	; display list load memory scan instruction (3 byte)
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
; ---------------------------------------------------------------------------
; KBCODEs
; ---------------------------------------------------------------------------
.enum @kbcode
    _none  = 255
    _esc   = 28
    _1     = 31
    _2     = 30
    _3     = 26
    _4     = 24
    _5     = 29
    _6     = 27
    _7     = 51
    _8     = 53
    _9     = 48
    _0     = 50
    _lt    = 54
    _gt    = 55
    _del   = 52
    _tab   = 44
    _Q     = 47
    _W     = 46
    _E     = 42
    _R     = 40
    _T     = 45
    _Y     = 43
    _U     = 11
    _I     = 13
    _O     = 8
    _P     = 10
    _min   = 14
    _up    =  14  ; cursor function 
    _eq    = 15
    _down  = 15 ; cursor function
    _ret   = 12
    _A     = 63
    _S     = 62
    _D     = 58
    _F     = 56
    _G     = 61
    _H     = 57
    _J     = 1
    _K     = 5
    _L     = 0
    _semicolon = 2
    _plus  = 6
    _left  = 6  ; cursor function
    _asterisk = 7
    _right = 7 ; cursor function
    _caps  = 60
    _Z     = 23
    _X     = 22
    _C     = 18
    _V     = 16
    _B     = 21
    _N     = 36
    _M     = 37
    _comma = 32
    _dot   = 34
    _slash = 38
    _atari = 39
    _help  = 17
    _F1    = 3
    _F2    = 4
    _F3    = 19
    _F4    = 20
    _space = 33
.ende
EOL = $9b