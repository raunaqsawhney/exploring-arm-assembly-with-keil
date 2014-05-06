;*-------------------------------------------------------------------
;* Name:    	lab_4_program.s 
;* Purpose: 	A sample style for lab-4
;* Term:		Winter 2013
;* Authors: 	Raunaq Sawhney (rsawhney) and Simarpreet Singh (s244sing)
;*-------------------------------------------------------------------
				THUMB 								; Declare THUMB instruction set 
				AREA 	My_code, CODE, READONLY 	; 
				EXPORT 		__MAIN 					; Label __MAIN is used externally 
				;EXPORT 		EINT3_IRQHandler 		; The ISR will be known to the startup_LPC17xx.s program 

				ENTRY 

__MAIN

; The following lines are similar to previous labs.
; They just turn off all LEDs 
				LDR			R10, =LED_BASE_ADR		; R10 is a  pointer to the base address for the LEDs
				MOV 		R3, #0xB0000000			; Turn off three LEDs on port 1  
				STR 		R3, [r10, #0x20]
				MOV 		R3, #0x0000007C
				STR 		R3, [R10, #0x40] 		; Turn off five LEDs on port 2 
				
				MOV			R9, #0x1				; used as a flag for interrupt.
				MOV			R7, #0x0				; Latency delay counter.
				MOV			R1, #0x1
		
				
				MOV			R11, #0x200000			; Enable EINT3
				LDR			R10, =ISER0
				STR			R11, [R10]
		
				
				MOV			R11,  #0x400			; Enable GPIO interrupt on pin P2.10 for falling edge 
				LDR			R10, =IO2IntEnf
				STR			R11, [R10]

; This line is very important in your main program
; Initializes R11 to a 16-bit non-zero value and NOTHING else can write to R11 !!
				MOV			R11, #0x5				; Init the random number generator with a non-zero number ;default = #0xABCD
LOOP 			MOV			R7, #0x0  				; Reset latency counter
				BL 			RNG  
				MOV			R12, R11				; Store value of random number into local register
				MOV			R9, #0x1 				; Initialize ISR Request Register
				MOV			R1, #0x1 				; Initialize counter

RandomDelayLoop
				B			InitialFlashing
process			SUBS		R12, R12, #1
				BNE			RandomDelayLoop			; Go do a random loop of R11 times for flash swapping
				BEQ			FlashAll
	
				;B 			LOOP

				
;*------------------------------------------------------------------- 
; InitialFlashing: Allows for 2 sets of 4 LEDS to FLASH Alternatively
;*-------------------------------------------------------------------
InitialFlashing
				LDR			R10, =LED_BASE_ADR
				MOV			R0, #0xFA						; DELAY between consequetive group flashing	;default = #0xFFFF
				BL			RightON
				BL			DELAY
				;MOV			R0, #0xFA					; DELAY between consequetive group flashing	
				BL			LeftON
				BL			DELAY
				B			process

RightON
				MOV 		R3, #0xB0000000					; Turn off three LEDs on port 1  
				STR			R3, [R10, #0x20]				; Turn OFF ALL LEDS on P1
				
				LSR			R3, R3, #0x1D					; Shift Right 29 decimal and then AND to get 
				AND			R3, R3, #0x4					; Value to store to turn off P2.2
				STR			R3, [R10, #0x40]				; Turn ofF LED  P2.2
				
				MOV			R3, #0x4						; Turn ON LED in P2.3 to P2.6 
				STR			R3, [R10, #0x40]				; Store it which turns it ON
				BX			LR

LeftON
				MOV			R3, #0x4FFFFFFF					; Turn ON LED in P1
				STR			R3, [R10, #0x20]				;
				
				LSR			R3, R3, #0x1D					; Shift Right 29 decimal and then AND to get
				AND			R3, R3, #0x4					; Value to store to turn ON P2.2
				STR			R3, [R10, #0x40]				; Store it which turns it ON
				
				MOV			R3, #0x78						; Turn off P2.3 to P2.6 LEDS
				STR			R3, [R10, #0x40]				; Store it which turns it OFF
				BX			LR			

;*------------------------------------------------------------------- 
; FlashAll ... Flash All LEDs to display the user to press the button
;				And Handle incrementing the delay counter...
;*-------------------------------------------------------------------
FlashAll		
				MOV 		R7, #0x0						; Reset the latency counter for the actual delay to be recorded.				
				LDR			R10, =LED_BASE_ADR
				
start			MOV			R0, #0xFA						; default = #0xFFFF
				BL			LEDON
				BL			DELAY
				BL			LEDOFF
				BL			DELAY
				;MOV			R7, #0xFF					; new delay
			    ;ADD			R7, #1
				CMP         R9, #0x0	            		; This value would be set by the ISR.
				BNE			start							; At this point go to flash the LEDs with the appropiate latency counter value
				BL			execute							; The button hasn't been pressed yet..
				
				B			LOOP							; Loop back to the main program..
		
LEDON
				MOV			R3, #0x4FFFFFFF
				STR			R3, [R10, #0x20]
				MOV			R3, #0x0						;#0xFFFFFF83....Turns the LED ON
				STR			R3, [R10, #0x40]
				BX 			LR
				

LEDOFF
				MOV			R3, #0xB0000000
				STR			R3, [R10, #0x20]				; Turns the LED OFF
				MOV			R3, #0x7C
				STR			R3, [R10, #0x40]
				BX			LR


;*------------------------------------------------------------------- 
; Subroutine RNG ... Generates a pseudo-Random Number in R11 
;*------------------------------------------------------------------- 
; R11 holds a random number as per the Linear feedback shift register (Fibonacci) on WikiPedia
; R11 MUST be initialized to a non-zero 16-bit value at the start of the program
; R11 can be read anywhere in the code but must only be written to by this subroutine
RNG 			STMFD		R13!,{R1-R3, R14} 	; Random Number Generator 
				AND			R1, R11, #0x8000
				AND			R2, R11, #0x2000
				LSL			R2, #2
				EOR			R3, R1, R2
				AND			R1, R11, #0x1000
				LSL			R1, #3
				EOR			R3, R3, R1
				AND			R1, R11, #0x0400
				LSL			R1, #5
				EOR			R3, R3, R1			; The new bit to go into the LSB is present
				LSR			R3, #15
				LSL			R11, #1
				ORR			R11, R11, R3
				LDMFD		R13!,{R1-R3, R15}


;*------------------------------------------------------------------- 
; DisplayNum ... Display the LED pattern of the latency
;*------------------------------------------------------------------- 
execute			STMFD		R13!,{R0,R1,R3,R4,R6, R14}

				MOV			R8, R7

executeagain	AND			R6, R8, #0xFF					;AND FF with Counter Register
				B			DisplayNum
			


DisplayNum		
				BL			P2Shifting
				BL			P1Shifting
				
				
				
				MOV 		R0, #0x7D0						;0x4E20 ;2 second delay  ;default = #0xFFFF
				BL			DELAY
				BL			ledoff
				MOV 		R0, #0x7D0						;0x4E20 ;2 				 ;default = #0xFFFF
				BL			DELAY
				
				LSR			R8, R8, #8						;Shift by 8 the Counter Register
				ADD			R1, R1, #1						;Byte counter -- Increment each time a byte is displayed
				CMP			R1, #5							;See if it has displayed 4 bytes, if yes, then do DONE
				BNE			executeagain					;Otherwise do execute again
				B			done
P2Shifting		
				AND 		R2, R6, #0x1F					
				RBIT 		R3, R2
				LSR      	R3, #25
				EOR			R3, #0xFF
				STR			R3, [R10, #0x40]
				BX			LR 
				
P1Shifting	
				AND 		R2, R6, #0x000000E0
				RBIT		R3, R2
				LSL			R3, #5
				LSR			R4, R3, #1
				ORR			R3, R3, R4
				EOR			R3, #0xFFFFFFFF
				STR			R3, [R10, #0x20]
				BX			LR
		
ledoff
				MOV 		R3, #0x0000007C
				STR 		R3, [R10, #0x40] 				; Turn off five LEDs on port 2 
				
				MOV 		R3, #0xB0000000					; Turn off three LEDs on port 1  
				STR 		R3, [r10, #0x20]
				BX 			LR
				
done			MOV			R0, #0x7D0					;2 second delay after pattern is displayed
				BL			DELAY
				
				LDMFD		R13!, {R0,R1,R3,R4,R6, R15}


;*------------------------------------------------------------------- 
; Subroutine DELAY ... Causes a delay of 1ms * R0 times
;*------------------------------------------------------------------- 
; 		aim for better than 10% accuracy
DELAY			STMFD		R13!,{R0-R2, R14}

MultipleDelay	TEQ			R0,#0
				BEQ 		exitDelay
				MOV		R2, #0x2AA
				;MOV			R2, #0xDA
													

delayloop
				SUBS		R2, R2, #1
				BNE			delayloop
				SUBS		R0, #1
				
				ADD			R7, R7, #1					; Latency counter for the button delay incrementing
				BNE			MultipleDelay

exitDelay		LDMFD		R13!,{R0-R2, R15}


;*-------------------------------------------------------------------
; Below is a list of useful registers with their respective memory addresses.
;*------------------------------------------------------------------- 
LED_BASE_ADR	EQU 	0x2009c000 		; Base address of the memory that controls the LEDs 
PINSEL3			EQU 	0x4002C00C 		; Pin Select Register 3 for P1[31:16]
PINSEL4			EQU 	0x4002C010 		; Pin Select Register 4 for P2[15:0]
FIO1DIR			EQU		0x2009C020 		; Fast Input Output Direction Register for Port 1 
FIO2DIR			EQU		0x2009C040 		; Fast Input Output Direction Register for Port 2 
FIO1SET			EQU		0x2009C038 		; Fast Input Output Set Register for Port 1 
FIO2SET			EQU		0x2009C058 		; Fast Input Output Set Register for Port 2 
FIO1CLR			EQU		0x2009C03C 		; Fast Input Output Clear Register for Port 1 
FIO2CLR			EQU		0x2009C05C 		; Fast Input Output Clear Register for Port 2 
IO2IntEnf		EQU		0x400280B4		; GPIO Interrupt Enable for port 2 Falling Edge 
ISER0			EQU		0xE000E100		; Interrupt Set-Enable Register 0 
IO2IntClr		EQU		0x400280AC		; Clear the Interrupt GPIO Register.

				ALIGN 

				END 
