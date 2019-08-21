;--------------------------------------------------------------------
; Nombre del archivo: ej5.asm
;--------------------------------------------------------------------
; Descripción: Realizar un toggle en el pin RA2 cada 3 flancos 
; descendentes en el pin RB0 (utilizando interrupción de INT).
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
; Frecuencia del oscilador externo: 4MHz (XT)
;------------------------------------------------------------------------------------------
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
	btfss	INTCON,INTF	
	goto	Salir
	bcf		INTCON,INTF
	decfsz	TMR0,F
	goto	Salir
;- Toggle --------------
	movlw	1<<2
	xorwf	PORTA
	movlw	.3			
	movwf	TMR0
Salir	
	pop					; Recupero el contexto (Reg W y STATUS)
	retfie

;--------------------------------------------------------------------
Main
	bank1
	movlw	1<<0
	movwf	TRISB
	bcf		TRISA,2
	movlw	b'10010000'
	movwf	INTCON		; Interrupcion RB0
	movlw   b'00110000' ; Counter Mode
						; Flanco Descendente
	movwf	OPTION_REG
	bank0
	movlw	.3		
	movwf	TMR0
Loop
	goto	Loop
	
	END				
