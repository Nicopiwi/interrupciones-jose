;--------------------------------------------------------------------
; Nombre del archivo: ej3.asm
;--------------------------------------------------------------------
; Descripci�n: Realizar un toggle en el pin RA2 cada 20 mS (utilizando 
; interrupci�n de TMR0).
;--------------------------------------------------------------------
; Versi�n ensamblador:�MPASM� Assembler v5.42
; p16F84.inc
;--------------------------------------------------------------------
; Descripci�n del Hardware:
;
;                     1 --------------16
;                      |RA2  �|_|  RA1|
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
; Autores: Nicol�s Rozenberg & Camilo Elman       
;--------------------------------------------------------------------
	LIST	p=PIC16F84A
	INCLUDE	<p16f84a.inc>
	__CONFIG _WDT_OFF & _PWRTE_ON & _CP_OFF & _XT_OSC
	ERRORLEVEL	-302

;- Definiciones y Equivalencias --------------------------------------
#DEFINE	bank0	bcf	STATUS,RP0		; Cambio al banco 0
#DEFINE	bank1	bsf	STATUS,RP0		; Cambio al banco 1	
#DEFINE pin1		RA2

;- Declaraci�n de Variables ------------------------------------------
	CBLOCK	0x0C
	w_temp
	status_temp
	ENDC

;- Macros ------------------------------------------------------------
push	    MACRO
	movwf	w_temp
	swapf	STATUS,W
	movwf   status_temp
	ENDM
pop	        MACRO
	swapf	status_temp,W
	movwf	STATUS
	swapf	w_temp,F
	swapf	w_temp,W
	ENDM

;- Vectores ---------------------------------------------------------
	ORG	    0x000       ; Vector de Reset
	clrw
	goto	Main		

;- Servicio de Interrupci�n -----------------------------------------
	ORG	    0x004       ; Vector de Interrupci�n
Isr						; Rutina de Interrupci�n
	push				; Guardo el contexto (Reg W y STATUS)
; Aca escribir el Servicio de Interrupci�n
	
	pop					; Recupero el contexto (Reg W y STATUS)
	retfie

;--------------------------------------------------------------------
Main
	bank1
	clrf	TRISA
	bank0

;- Subrutinas -------------------------------------------------------

retardo
	return

;- Librer�as --------------------------------------------------------
; Incluir las librerias usadas

;--------------------------------------------------------------------
	END					; FIN del pgm
