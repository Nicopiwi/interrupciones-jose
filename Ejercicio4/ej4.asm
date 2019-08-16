;--------------------------------------------------------------------
; Nombre del archivo: ej4.asm
;--------------------------------------------------------------------
; Descripción: Realizar un toggle en el pin RA2 cada 8 flancos descendentes 
; en el pin RA4 (utilizando interrupción de TMR0).
; 
;--------------------------------------------------------------------
; Versión ensamblador: MPASM™ Assembler v5.42
; Archivos requeridos:
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
; Frecuencia del oscilador externo: XXMHz (XT)
;--------------------------------------------------------------------
; Autores: XXXXXXXXX       Fecha: XX/XX/XX               Versión:X.X
;--------------------------------------------------------------------
	LIST	p=PIC16F84A
	INCLUDE	<p16f84a.inc>
	__CONFIG _WDT_OFF & _PWRTE_ON & _CP_OFF & _XT_OSC
	ERRORLEVEL	-302

;- Definiciones y Equivalencias --------------------------------------
#DEFINE	bank0	bcf	STATUS,RP0		; Cambio al banco 0
#DEFINE	bank1	bsf	STATUS,RP0		; Cambio al banco 1	

;- Declaración de Variables ------------------------------------------
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

;- Servicio de Interrupción -----------------------------------------
	ORG	    0x004       ; Vector de Interrupción
Isr						; Rutina de Interrupción
	push				; Guardo el contexto (Reg W y STATUS)
	btfss	INTCON,T0IF	
	goto	Salir
	bcf		PORTA,RA2
	bcf		INTCON,T0IF
	movlw	.247		; 255-8
	movwf	TMR0
;- Toggle --------------
	movlw	1<<RA2
	xorwf	PORTA
	
Salir	
	pop					; Recupero el contexto (Reg W y STATUS)
	retfie

;--------------------------------------------------------------------
Main
	bank1
	movlw	1<<RA4
	movwf	TRISA
	movlw	b'10100000'
	movwf	INTCON		; Interrupcion TMR0
	
	movlw   b'00110000' ; Counter Mode
						; Flanco Descendente
	movwf	OPTION_REG
	bank0
	movlw	.247		; 255-8
	movwf	TMR0
Loop
	goto	Loop
;- Subrutinas -------------------------------------------------------
; Aqui escribir las subrutinas


;--------------------------------------------------------------------
	END				
