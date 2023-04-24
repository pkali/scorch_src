
.enum	@@dmactl
	blank	= %00
	narrow	= %01
	standard= %10
	wide	= %11
	missiles= %100
	players	= %1000
	lineX1	= %10000
	lineX2	= %00000
	dma	= %100000
.ende

.enum	@@pmcntl
	missiles= %1
	players	= %10
	trigs	= %100
.ende

.enum	@@gtictl
	prior0	= %0
	prior1	= %1
	prior2	= %10
	prior4	= %100
	prior8	= %1000
	ply5	= %10000	; Fifth Player Enable
	mlc	= %100000	; Multiple Color Player Enable
	mode9	= %01000000
	mode10	= %10000000
	mode11	= %11000000
.ende

* ---------------------------------------------------------------------------------------------
* ---	GTIA
* ---------------------------------------------------------------------------------------------

gtictl	=	PRIOR		; rejestr kontroli uk³adu GTIA
gtiactl	=	gtictl

pmcntl	=	GRACTL		; rejestr kontroli graczy i pocisków

* ---------------------------------------------------------------------------------------------
* ---	POKEY
* ---------------------------------------------------------------------------------------------

irqens	=	$0010		; rejestr-cieñ IRQEN
irqstat	=	$0011		; rejestr-cieñ IRQST

skstres	=	SKRES		; rejestr statusu z³¹cza szeregowego (Z)

* ---------------------------------------------------------------------------------------------
* ---	ANTIC
* ---------------------------------------------------------------------------------------------
chrctl	=	CHACTL		; rejestr kontroli wyœwietlania znaków

