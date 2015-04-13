;*******************************************************************************
;	Register.s
;	Constantes des registres hardware
; V1.2 Octobre 2014
;*******************************************************************************

;*******************************************************************************
; Registres des custom chips
;*******************************************************************************

; Base address
CUSTOM		=	$DFF000

; Registers offset
BLTDDAT		=	$000
DMACONR		=	$002
VPOSR			=	$004
VHPOSR		=	$006
DSKDATR		=	$008
JOY0DAT		=	$00A
JOY1DAT		=	$00C
CLXDAT		=	$00E
ADKCONR		=	$010
POT0DAT		=	$012
POT1DAT		=	$014
POTGOR		=	$016
SERDATR		=	$018
DSKBYTR		=	$01A
INTENAR		=	$01C
INTREQR		=	$01E
DSKPT			=	$020
DSKPTH		=	$020
DSKPTL		=	$022
DSKLEN		=	$024
DSKDAT		=	$026
REFPTR		=	$028
VPOSW			=	$02A
VHPOSW		=	$02C
COPCON		=	$02E
SERDAT		=	$030
SERPER		=	$032
POTGO			=	$034
JOYTEST		=	$036
STREQU		=	$038
STRVBL		=	$03A
STRHOR		=	$03C
STRLONG		=	$03E
BLTCON0		=	$040
BLTCON1		=	$042
BLTAFWM		=	$044
BLTALWM		=	$046
BLTCPT		=	$048
BLTCPTH		=	$048
BLTCPTL		=	$04A
BLTBPT		=	$04C
BLTBPTH		=	$04C
BLTBPTL		=	$04E
BLTAPT		=	$050
BLTAPTH		=	$050
BLTAPTL		=	$052
BLTDPT		=	$054
BLTDPTH		=	$054
BLTDPTL		=	$056
BLTSIZE		=	$058
BLTCMOD		=	$060
BLTBMOD		=	$062
BLTAMOD		=	$064
BLTDMOD		=	$066
BLTCDAT		=	$070
BLTBDAT		=	$072
BLTADAT		=	$074
DSKSYNC		=	$07E
COP1LC		=	$080
COP1LCH		=	$080
COP1LCL		=	$082
COP2LC		=	$084
COP2LCH		=	$084
COP2LCL		=	$086
COPJMP1		=	$088
COPJMP2		=	$08A
COPINS		=	$08C
DIWSTRT		=	$08E
DIWSTOP		=	$090
DDFSTRT		=	$092
DDFSTOP		=	$094
DMACON		=	$096
CLXCON		=	$098
INTENA		=	$09A
INTREQ		=	$09C
ADKCON		=	$09E
AUD0LC		=	$0A0
AUD0LCH		=	$0A0
AUD0LCL		=	$0A2
AUD0LEN		=	$0A4
AUD0PER		=	$0A6
AUD0VOL		=	$0A8
AUD0DAT		=	$0AA
AUD1LC		=	$0B0
AUD1LCH		=	$0B0
AUD1LCL		=	$0B2
AUD1LEN		=	$0B4
AUD1PER		=	$0B6
AUD1VOL		=	$0B8
AUD1DAT		=	$0BA
AUD2LC		=	$0C0
AUD2LCH		=	$0C0
AUD2LCL		=	$0C2
AUD2LEN		=	$0C4
AUD2PER		=	$0C6
AUD2VOL		=	$0C8
AUD2DAT		=	$0CA
AUD3LC		=	$0D0
AUD3LCH		=	$0D0
AUD3LCL		=	$0D2
AUD3LEN		=	$0D4
AUD3PER		=	$0D6
AUD3VOL		=	$0D8
AUD3DAT		=	$0DA
BPL1PT		=	$0E0
BPL1PTH		=	$0E0
BPL1PTL		=	$0E2
BPL2PT		=	$0E4
BPL2PTH		=	$0E4
BPL2PTL		=	$0E6
BPL3PT		=	$0E8
BPL3PTH		=	$0E8
BPL3PTL		=	$0EA
BPL4PT		=	$0EC
BPL4PTH		=	$0EC
BPL4PTL		=	$0EE
BPL5PT		=	$0F0
BPL5PTH		=	$0F0
BPL5PTL		=	$0F2
BPL6PT		=	$0F4
BPL6PTH		=	$0F4
BPL6PTL		=	$0F6
BPL7PT		=	$0F8
BPL7PTH		=	$0F8
BPL7PTL		=	$0FA
BPL8PT		=	$0FC
BPL8PTH		=	$0FC
BPL8PTL		=	$0FE
BPLCON0		=	$100
BPLCON1		=	$102
BPLCON2		=	$104
BPLCON3		=	$106
BPL1MOD		=	$108
BPL2MOD		=	$10A
BPLCON4		=	$10C
BPL1DAT		=	$110
BPL2DAT		=	$112
BPL3DAT		=	$114
BPL4DAT		=	$116
BPL5DAT		=	$118
BPL6DAT		=	$11A
SPR0PT		=	$120
SPR0PTH		=	$120
SPR0PTL		=	$122
SPR1PT		=	$124
SPR1PTH		=	$124
SPR1PTL		=	$126
SPR2PT		=	$128
SPR2PTH		=	$128
SPR2PTL		=	$12A
SPR3PT		=	$12C
SPR3PTH		=	$12C
SPR3PTL		=	$12E
SPR4PT		=	$130
SPR4PTH		=	$130
SPR4PTL		=	$132
SPR5PT		=	$134
SPR5PTH		=	$134
SPR5PTL		=	$136
SPR6PT		=	$138
SPR6PTH		=	$138
SPR6PTL		=	$13A
SPR7PT		=	$13C
SPR7PTH		=	$13C
SPR7PTL		=	$13E
SPR0POS		=	$140
SPR0CTL		=	$142
SPR0DATA	=	$144
SPR0DATB	=	$146
SPR1POS		=	$148
SPR1CTL		=	$14A
SPR1DATA	=	$14C
SPR1DATB	=	$14E
SPR2POS		=	$150
SPR2CTL		=	$152
SPR2DATA	=	$154
SPR2DATB	=	$156
SPR3POS		=	$158
SPR3CTL		=	$15A
SPR3DATA	=	$15C
SPR3DATB	=	$15E
SPR4POS		=	$160
SPR4CTL		=	$162
SPR4DATA	=	$164
SPR4DATB	=	$166
SPR5POS		=	$168
SPR5CTL		=	$16A
SPR5DATA	=	$16C
SPR5DATB	=	$16E
SPR6POS		=	$170
SPR6CTL		=	$172
SPR6DATA	=	$174
SPR6DATB	=	$176
SPR7POS		=	$178
SPR7CTL		=	$17A
SPR7DATA	=	$17C
SPR7DATB	=	$17E
COLOR00		=	$180
COLOR01		=	$182
COLOR02		=	$184
COLOR03		=	$186
COLOR04		=	$188
COLOR05		=	$18A
COLOR06		=	$18C
COLOR07		=	$18E
COLOR08		=	$190
COLOR09		=	$192
COLOR10		=	$194
COLOR11		=	$196
COLOR12		=	$198
COLOR13		=	$19A
COLOR14		=	$19C
COLOR15		=	$19E
COLOR16		=	$1A0
COLOR17		=	$1A2
COLOR18		=	$1A4
COLOR19		=	$1A6
COLOR20		=	$1A8
COLOR21		=	$1AA
COLOR22		=	$1AC
COLOR23		=	$1AE
COLOR24		=	$1B0
COLOR25		=	$1B2
COLOR26		=	$1B4
COLOR27		=	$1B6
COLOR28		=	$1B8
COLOR29		=	$1BA
COLOR30		=	$1BC
COLOR31		=	$1BE
HTOTAL		=	$1C0
HSSTOP		=	$1C2
HBSTRT		=	$1C4
HBSTOP		=	$1C6
VTOTAL		=	$1C8
VSSTOP		=	$1CA
VBSTRT		=	$1CC
VBSTOP		=	$1CE
SPRHSTRT	=	$1D0
SPRHSTOP	=	$1D2
BPLHSTRT	=	$1D4
BPLHSTOP	=	$1D6
HHPOSW		=	$1D8
HHPOSR		=	$1DA
BEAMCON0	=	$1DC
HSSTRT		=	$1DE
VSSTRT		=	$1E0
HCENTER		=	$1E2
DIWHIGH		=	$1E4
BPLHMOD		=	$1E6
SPRHPT		=	$1E8
SPRHPTH		=	$1E8
SPRHPTL		=	$1EA
BPLHPT		=	$1EC
BPLHPTH		=	$1EC
BPLHPTL		=	$1EE
FMODE			=	$1FC

;*******************************************************************************
; Registres des CIA
;*******************************************************************************

; Base address
CIAA			=	$BFE001
CIAB			=	$BFD000

; Registers offset
CIAPRA		=	$000
CIAPRB		=	$100
CIADDRA		=	$200
CIADDRB		=	$300
CIATALO		=	$400
CIATAHI		=	$500
CIATBLO		=	$600
CIATBHI		=	$700
CIATODLO	=	$800
CIATODMID	=	$900
CIATODHI	=	$A00
CIASDR		=	$C00
CIAICR		=	$D00
CIACRA		=	$E00
CIACRB		=	$F00

;*******************************************************************************
; Registre AKIKO
;*******************************************************************************

AKIKO			= $B80038
