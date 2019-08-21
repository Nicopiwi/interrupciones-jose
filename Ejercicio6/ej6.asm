;--------------------------------------------------------------------
; Nombre del archivo: ej6.asm
;--------------------------------------------------------------------
; Descripción: Usar el pin RB7 como interrupción de RBI (Nibble alto 
; del PORTB). Cuando el pin se active con un "1" encender un led en 
; el pin RA2 y en simultáneo deberá parpadear un led en RB3 (100mS en
; ON 400ms en OFF). Esto se debe realizar utilizando 
; la interrupción del TMR0.
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
	counter
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
	btfss	INTCON,RBIF	
	goto	_tmr0_Interruption
_RBI_Interruption	
	bsf		INTCON,T0IE
_tmr0_Interruption
	btfss	INTCON,T0IF
	goto	Salir
	bsf		PORTA,2
	; PONER TITILACION ACA
;- Toggle -----------------------------------------------------------
	movlw	1<<3
	xorwf	PORTB
Salir	
	pop					; Recupero el contexto (Reg W y STATUS)
	retfie

;--------------------------------------------------------------------
Main
	bank1
	movlw	1<<7
	movwf	TRISB
	clrf	TRISA
	movlw	b'10001000'
	movwf	INTCON		; Interrupcion RBI
	movlw   b'00110000' ; Counter Mode
						; Flanco Descendente
	movwf	OPTION_REG
	bank0
	
Loop
	goto	Loop
	
	END				
