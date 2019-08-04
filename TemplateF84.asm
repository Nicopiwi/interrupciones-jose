;--------------------------------------------------------------------
; Nombre del archivo: XXXXXXX.asm
;--------------------------------------------------------------------
; Descripci�n:
; 
;--------------------------------------------------------------------
; Versi�n ensamblador:�MPASM� Assembler v5.42
; Archivos requeridos:
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
; Frecuencia del oscilador externo: XXMHz (XT)
;--------------------------------------------------------------------
; Autores: XXXXXXXXX       Fecha: XX/XX/XX               Versi�n:X.X
;--------------------------------------------------------------------
	LIST	p=PIC16F84A
	INCLUDE	<p16f84a.inc>
	__CONFIG _WDT_OFF & _PWRTE_ON & _CP_OFF & _XT_OSC
	ERRORLEVEL	-302

;- Definiciones y Equivalencias --------------------------------------
#DEFINE	bank0	bcf	STATUS,RP0		; Cambio al banco 0
#DEFINE	bank1	bsf	STATUS,RP0		; Cambio al banco 1	

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
; Aqui escribir el c�digo 

;- Subrutinas -------------------------------------------------------
; Aqui escribir las subrutinas

;- Librer�as --------------------------------------------------------
; Incluir las librerias usadas

;--------------------------------------------------------------------
	END					; FIN del pgm