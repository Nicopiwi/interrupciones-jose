;--------------------------------------------------------------------
; Nombre del archivo: ej1.asm
;--------------------------------------------------------------------
; Descripción: Realizar un toggle en el pin RA2 cada 50 mS (sin habilitar
; interrupciones). (Un toggle es invertir el estado de ese bit o pín).
; 
;--------------------------------------------------------------------
; Versión ensamblador: MPASM™ Assembler v5.42
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
#DEFINE pin1		RA2

;- Declaración de Variables ------------------------------------------
	CBLOCK	0x0C
	d1
	d2
	ENDC

;- Vectores ---------------------------------------------------------
	ORG	    0x000       ; Vector de Reset
	clrw
	goto	Main		

	ORG	    0x004       ; Vector de Interrupción

;--------------------------------------------------------------------
Main
	bank1
	clrf	TRISA
	bank0
Loop
	bsf		PORTA,2
	call	retardo
	bcf		PORTA,2
	goto	Loop

;- Subrutinas -------------------------------------------------------

retardo
			
	movlw	0x0E
	movwf	d1
	movlw	0x28
	movwf	d2
retardo_0
	decfsz	d1, f
	goto	$+2
	decfsz	d2, f
	goto	retardo_0

	goto	$+1
	nop
	return
	
	END					; FIN del pgm
