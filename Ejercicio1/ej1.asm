;--------------------------------------------------------------------
; Nombre del archivo: ej1.asm
;--------------------------------------------------------------------
; Descripción: Realizar un toggle en el pin RA2 cada 50 mS (sin habilitar
; interrupciones). (Un toggle es invertir el estado de ese bit o pín).
; 
;--------------------------------------------------------------------
; Versión ensamblador: MPASM™ Assembler v5.42
; p16F84.inc
;--------------------------------------------------------------------
; Descripción del Hardware:
;
;                     1 --------------16
;                      |RA2  °|_|  RA1|
;                      |RA3        RA0| 
;                      |RA4/T0CKI OSC2| XTAL
;          R10 K a Vdd |/MCLR     OSC1| XTAL
;                  GND |VSS        VDD| 5V 
;                      |RB0/INT    RB7|
;                      |RB1        RB6|
;                      |RB2        RB5|
;                      |RB3        RB4| -> 
;                     9 --------------10
;
; Frecuencia del oscilador externo: 4MHz (XT)
;--------------------------------------------------------------------
; Autores: Nicolás Rozenberg & Camilo Elman       
;--------------------------------------------------------------------
	LIST	p=PIC16F84A
	INCLUDE	<p16f84a.inc>
	__CONFIG _WDT_OFF & _PWRTE_ON & _CP_OFF & _XT_OSC
	ERRORLEVEL	-302

;- Definiciones y Equivalencias --------------------------------------
#DEFINE	bank0	bcf	STATUS,RP0		; Cambio al banco 0
#DEFINE	bank1	bsf	STATUS,RP0		; Cambio al banco 1	
;- Vectores ---------------------------------------------------------
	ORG	    0x000       ; Vector de Reset
	clrw
	goto	Main		

;--------------------------------------------------------------------
Main
	bank1
	clrf	TRISA
	clrf	TRISB
	movlw	b'00000111' ; Frecuencia se divide en 256
	movwf	OPTION_REG
	
	bank0
	
Loop
	call	_50mS
	movlw	1<<2
	xorwf	PORTA
	goto	Loop
	
;- Subrutinas -----------------------------------------------------------------

_50mS
	movlw	.61			; 256-195. 195 se consigue mediante
						; 50000 uS / 256 uS, siendo 256 uS el
						; período del TMR0
	movwf	TMR0 
Ask
	btfss   INTCON, T0IF 		; wait for flag set
 	goto 	Ask
 	bcf		INTCON, T0IF
 	return
	
	END					; FIN del pgm
