;----------------------------------------------------------------
; dino85.inc
;----------------------------------------------------------------

; general hardware definitions

CS1_BASE	.eq	00h
CS2_BASE	.eq	20h
CS3_BASE	.eq	40h
CS4_BASE	.eq	60h
CS5_BASE	.eq	80h
CS6_BASE	.eq	0A0h

ROM_BEGIN	.eq	0h
ROM_END		.eq	1FFFh

RAM_BEGIN	.eq	8000h
RAM_END		.eq	0FFFFh

; begin of RAM reserved for internal purpose
SYS_MEM_BEGIN	.eq	0FD00h	

; initial stack settings
SYSTEM_STACK	.eq	SYS_MEM_BEGIN-2 


; 8085 CPU interrupt vectors fixed locations

RST_1_ROM_VECT 	.eq	08h
RST_2_ROM_VECT 	.eq	10h
RST_3_ROM_VECT 	.eq	18h
RST_4_ROM_VECT 	.eq	20h
TRAP_ROM_VECT	.eq	24h
RST_5_ROM_VECT 	.eq	28h
RST_55_ROM_VECT	.eq	2Ch
RST_6_ROM_VECT 	.eq	30h
RST_65_ROM_VECT	.eq	34h
RST_7_ROM_VECT 	.eq	38h
RST_75_ROM_VECT	.eq	3Ch


; consts for system communication module 

; the UART chip
SYS_UART_BASE	.eq	CS1_BASE
SYS_UART_DATA	.eq	SYS_UART_BASE
SYS_UART_CMST	.eq	SYS_UART_BASE+1

; 8-bit simple I/O - have the same addresses (!)
SYS_OUTPORT	.eq	CS1_BASE+2
SYS_INPORT	.eq	CS1_BASE+2


; ========= SYS_MEM do-not-touch area ==============

; system memory layout (at the top of RAM)
; 512 bytes reserved for internal usage

		.or	SYS_MEM_BEGIN
		.du

; terminal mode, 0 - mono, 1 - decorated/color
terminalMode	.bs	1

; system serial communication buffer, 128 bytes is enough
serialBuffer	.bs	80h	; receive/transmit
serialBufferEnd:

; copy of last command, may be re-executed 
commandBuffer	.bs	80h	
commandBufferEnd:


; general purspose text buffer for string operations,
; conversions etc...
textBuffer	.bs	80h	; receive/transmit/str oper.
textBufferEnd:

; general purspose text additional buffer for...
auxBuffer	.bs	80h	; receive/transmit/str oper.
auxBufferEnd:

; dynamic interrupt vectors, 3 bytes for each one
rst1RamVector	.bs	3	; RST 1
rst2RamVector	.bs	3	; RST 2
rst3RamVector	.bs	3	; RST 3
rst4RamVector	.bs	3	; RST 4
trapRamVector	.bs	3	; TRAP signal	
rst5RamVector	.bs	3	; RST 5
rst55RamVector	.bs	3	; RST5.5
rst6RamVector	.bs	3	; RST 6
rst65RamVector	.bs	3	; RST6.5
rst7RamVector	.bs	3	; RST 7
rst75RamVector	.bs	3	; RST7.5


; system procedures entry points available at fixed 
; locations as stored in system RAM area
sysProcJumpTable:
dnLcdInit	.bs	3	; as lcdInit
dnLcdPutChar	.bs	3	; as lcdPutChar
dnLcdPutCmd	.bs	3	; as lcdPutCmd
dnLcdPutStr	.bs	3	; as lcdPutStr
dnUartInit	.bs	3	; as uartInit
dnUartGetChar	.bs	3	; as uartGetChar
dnUartGetStr	.bs	3	; as uartGetStr
dnUartPutChar	.bs	3	; as uartPutChar
dnUartPutStr	.bs	3	; as uartPutStr
dnMemCopy	.bs	3	; as memCopy
dnMemFill	.bs	3	; as memFill
sysProcJumpTableEnd:		
		.ed
; end of dino85.inc