;--------------------------------------------------------------------
; Nombre del archivo: ej3.asm
;--------------------------------------------------------------------
; Descripción: Realizar un toggle en el pin RA2 cada 20 mS (utilizando 
; interrupción de TMR0).
;--------------------------------------------------------------------
; Versión ensamblador: MPASM Assembler v5.42
; p16F84.inc
;--------------------------------------------------------------------
; Descripción del Hardware:
;
;                     1 --------------16
;                      |RA2  Â°|_|  RA1|
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
; Autores: NicolÃ¡s Rozenberg & Camilo Elman       
;--------------------------------------------------------------------
;-----------------------------------------------------------------
; Inter3.asm
; Objetivo:Realizar un toggle en el pin RA2 cada 20 mS 
; (utilizando interrupción de TMR0). 
;-----------------------------------------------------------------
; OSC @ 4 MHz (XT)     
;-----------------------------------------------------------------
        LIST           p=PIC16F84A
        INCLUDE        <p16F84A.inc>
        __CONFIG       _WDT_OFF & _CP_OFF & _XT_OSC & _PWRTE_ON
        ERRORLEVEL     -302

;- Definiciones y macros -----------------------------------------
#DEFINE bank1 bsf STATUS,RP0
#DEFINE bank0 bcf STATUS,RP0

push	MACRO
	movwf	w_temp
	swapf	STATUS,W
	movwf	status_temp
ENDM

pop	MACRO
	swapf	status_temp,W
	movwf	STATUS
	swapf	w_temp,F
	swapf	w_temp,W
ENDM

;- Variables -----------------------------------------------------
CBLOCK	0x0C
w_temp	; w_temp en la pos 0x0C
status_temp	; starus_temp en la pos 0x0D
ENDC

;- Vectores ------------------------------------------------------        
        ORG        	0x000
clrw
clrf	PORTA
clrf	PORTB	
        goto       Main

;-----------------------------------------------------------------        
        ORG        	0x004
Isr
push	; guardamos W y STATUS
; Pregunto de donde viene la interrupción:
	btfss	INTCON,T0IF	
	goto	Salir_Isr
	bcf	INTCON,T0IF	
	movlw	.100
	movwf	TMR0	; Aqui hago el toggle
	movlw	1<<RA2
	xorwf	PORTA
Salir_Isr
	pop				; recupero W y STATUS
	retfie
	     
	;-----------------------------------------------------------------            
Main
	bank1
	clrf	TRISA
	clrf	TRISB
	movlw	(1<<PS2)|(1<<PS1)
	movwf	OPTION_REG
	bank0
	movlw	(1<<GIE)|(1<<T0IE)
	movwf	INTCON
	movlw	.100
	movwf	TMR0
Loop
	goto	Loop

;----------------------------------------------------------- FIN -            
        END
