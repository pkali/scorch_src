;   @com.wudsn.ide.asm.mainsourcefile=scorch.asm

    .IF *>0 ;this is a trick that prevents compiling this file alone

;TanksPMOrder   .BYTE 4,3,1,5,0,2 ; 0-3 = P0-P3 , 4 = M0+M1 , 5 = M2+M3
TanksPMOrder    .BYTE 4,3,1,5,0,2 ; 0-3 = P0-P3 , 4 = M0+M1 , 5 = M2+M3
dliColorsBack
    :10 .by $02,$00
dliColorsFore
    .by $0a                                            ; one mountains color
;    .by $0e,$0c,$0c,$0b,$0b,$0a,$0a,$09,$09,$08        ; mountains colors array
;    .by $08,$08,$07,$07,$07,$06,$06,$06,$06,$05
    .by $0e,$0c,$0c,$0c,$0c,$0a,$0a,$0a,$0a,$08        ; mountains colors array new
    .by $08,$08,$08,$06,$06,$06,$06,$06,$06,$04
CashOptionL ;(one zero less than on the screen)
    .by 0,<200,<800,<1200,<2000
CashOptionH   
    .by 0,>200,>800,>1200,>2000
GravityTable   .by 10,20,25,30,40
MaxWindTable   .by 5,20,40,70,99
RoundsTable    .by 10,20,30,40,50
AIForceTable    .wo 375,470,630,720,820 ; starting shoot forces for different gravity
flyDelayTable  .by 255,150,75,35,1
seppukuTable   .by 255, 45,25,15,9
.ENDIF
