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
	counter1
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
	clrf	W
	goto	Main		

;- Servicio de Interrupción -----------------------------------------
	ORG	    0x004       ; Vector de Interrupción
Isr						; Rutina de Interrupción
	push				; Guardo el contexto (Reg W y STATUS)
	btfss	INTCON,RBIF	
	goto	_tmr0_Interruption
_RBI_Interruption	
	bcf		INTCON,RBIF
	bsf		INTCON,T0IE
	bsf		INTCON,T0IF ; Para que TMR0 interrumpa, luego de RB
_tmr0_Interruption
	btfss	INTCON,T0IF
	goto	Salir
	bcf		INTCON,T0IF
	btfss	PORTA,3
	goto	_Off400mS
	goto	_On100mS
;- Toggle -----------------------------------------------------------
Toggle
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
	movlw   b'00000111' ; Counter Mode
						; Flanco Descendente
						; Periodo de 256 uS
	movwf	OPTION_REG
	bank0
	
Loop
	goto	Loop


;- Etiquetas --------------------------------------------

_On100mS	;100000uS/256uS = 390 
	clrf	TMR0
ask
	btfss	INTCON,T0IF
	goto	ask
	bcf		INTCON,T0IF
	movlw	.122	;256-(390-256)
	movwf	TMR0
	btfss	INTCON,T0IF
	goto	$-1	
	bcf		INTCON,T0IF
	goto	Toggle
_Off400mS ;100000uS/256uS = 1562
	movlw	.6	;Debo repetir el mismo codigo
				;6 veces. Esto se debe a que 256
				;entra 6 veces en 1562. En la ultima
				;el timer debe contar 26 para desbordar
	movwf	counter1
_400mSLoop
	decfsz	counter1
	goto	_Code
	goto	_Last
_Code
	clrf	TMR0
	btfss	INTCON,T0IF
	goto	$-1	
	bcf		INTCON,T0IF
	goto	_400mSLoop
_Last	
	movlw	.230 	;256-26
	btfss	INTCON,T0IF
	goto	$-1	
	bcf		INTCON,T0IF
	goto	Toggle


	END				
