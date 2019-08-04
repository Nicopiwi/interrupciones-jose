;--------------------------------------------------------------------
; Nombre del archivo: ej3.asm
;--------------------------------------------------------------------
; Descripción: Realizar un toggle en el pin RA2 cada 20 mS (utilizando 
; interrupción de TMR0).
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
	w_temp
	status_temp
	d1
	d2
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
						; Interrumpe cada 16384 uS. Faltan 3616 uS
	bcf		INTCON, GIE
	bcf		INTCON,	T0IF
	clrf	OPTION_REG
	call	retardo_faltante	;16384 uS + 3600 uS = 19984 uS
	bcf		PORTA,2				;Toggle
	movlw	b'00000101'
	movwf	OPTION_REG
	pop
	clrf	TMR0
	retfie
	

;--------------------------------------------------------------------
Main
	bank1
	clrf	TRISA
	movlw	b'10100000' ;Habilitar interrupcion de timer-overflow
	movwf	INTCON
	movlw	b'00000101' ;Prescaler 1:64
	movwf	OPTION_REG
	bank0
	clrf	TMR0
Loop
	bsf		PORTA,2
	goto	Loop

;- Subrutinas -------------------------------------------------------

retardo_faltante ;3600 ciclos -> 3600 uS
			
	movlw	0xCE
	movwf	d1
	movlw	0x03
	movwf	d2
retardo_faltante_0
	decfsz	d1, f
	goto	$+2
	decfsz	d2, f
	goto	retardo_faltante_0
	goto	$+1
	nop
	return

	END					; FIN del pgm
