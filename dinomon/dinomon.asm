		.cr	8085            
		.tf	dinomon.bin,BIN
		.lf	dinomon.lst
		
		; globalne deklaracje "dino-85" 
		.in	../common/dino85.inc
		
		; makra i inne helpery
		.in 	dino85.mac

RET_OPC		.eq	0C9h		; kod rozkazu RET 
NOP_OPC		.eq	00h		; kod rozkazu NOP 
JMP_OPC		.eq	0C3h		; kod rozkazu JMP nnnn 
CALL_OPC	.eq	0CDh		; kod rozkazu CALL nnnn 
CR		.eq	0Dh		; /r
LF		.eq	0Ah		; /n


		.or	ROM_BEGIN		
		
		; stos systemowy
		lxi	SP,SYSTEM_STACK									
			
		; i idziemy do kodu g³ównego dina
		jmp	dinoMain
	
		; przekierowania sta³ych wektorów przerwañ
		; na górny RAM
		
		; RST 1 - programowe
		.no 	RST_1_ROM_VECT
		jmp	rst1RamVector

		; RST 2 - programowe
		.no 	RST_2_ROM_VECT
		jmp	rst2RamVector

		; RST 3 - programowe
		.no 	RST_3_ROM_VECT
		jmp	rst3RamVector

		; RST 4 - programowe
		.no 	RST_4_ROM_VECT
		jmp	rst4RamVector

		; TRAP niemaskowalne
		.no	TRAP_ROM_VECT
		jmp	trapRamVector

		; RST 5 - programowe
		.no 	RST_5_ROM_VECT
		jmp	rst5RamVector
				
		; RST_55 maskowalne 
		.no	RST_55_ROM_VECT
		jmp	rst55RamVector

		; RST 6 - programowe
		.no 	RST_6_ROM_VECT
		jmp	rst6RamVector
		
		; RST_65 maskowalne
		.no	RST_65_ROM_VECT
		jmp	rst65RamVector

		; RST 7 - programowe
		.no 	RST_7_ROM_VECT
		jmp	rst7RamVector

		; RST_75 naskowalne
		.no	RST_75_ROM_VECT
		jmp	rst75RamVector
		

		;
		; to jest program g³ówny - interpreter/loader
		;
dinoMain:	
		; zainicjuj wektor TRAP na samym pocz¹tku
		mvi	A,RET_OPC
		sta	trapRamVector

		; inicjacja mapy z adresami udostêpnionych procedur
		; systemowych
		; content of sysProcJumpTableDef to location
		; pointed by sysProcJumpTable
		lxi	B,sysProcJumpTableDef
		lxi	D,sysProcJumpTable
		>LENGTH L,sysProcJumpTableDef
		call	memCopy

		; user code autostart feature - ale kicha :-) /* tasza */
		;rim	
		;ani	80h	; maska na bit 7 czyli stan SID
		;jnz	RAM_BEGIN
		;SID jednak = 0 (zworka zapieta), kontynuuj program monitora
		;
		
		; init serial port, then send welcome message
		call	uartInit
		call	sendWelcomeMessage

		; clear buffers
		lxi	B,serialBuffer
		mvi	A,0
		>LENGTH L,serialBuffer
		call	memFill

		lxi	B,commandBuffer
		mvi	A,0
		>LENGTH L,commandBuffer
		call	memFill

		lxi	B,textBuffer
		mvi	A,0
		>LENGTH L,textBuffer
		call	memFill
		
dinoMonLoop:
		; czekaj na polecenie z terminala
		lxi	B,serialBuffer
		>LENGTH L,serialBuffer
		call	uartGetStr

		; ok, cos jest
		; porównaj z "."
		; je¿eli . to wywo³aj ostatnio nades³an¹ komendê
		; je¿ell nie . to interpretuj jako now¹

		lxi	B,serialBuffer
		ldax	B
		cpi	'.'
		jz	.processLastCommand
		
		; jednak nowa, przepisz do commandBuffer
		lxi	B,serialBuffer
		lxi	D,commandBuffer
		>LENGTH L,serialBuffer
		call	memCopy
		
.processLastCommand:		
		; CRLF aby zachowaæ porz¹dek na terminalu
		call	sendCrLf
		; 	
		>ADD_CMD_HANDLER commandBuffer,i2cReadCmd
		>ADD_CMD_HANDLER commandBuffer,i2cWriteCmd		
		>ADD_CMD_HANDLER commandBuffer,setTimeCmd
		>ADD_CMD_HANDLER commandBuffer,getTimeCmd
		>ADD_CMD_HANDLER commandBuffer,setDateCmd
		>ADD_CMD_HANDLER commandBuffer,getDateCmd
		>ADD_CMD_HANDLER commandBuffer,memoryDumpToScreenCmd
		>ADD_CMD_HANDLER commandBuffer,memoryDumpToIntelHexCmd
		>ADD_CMD_HANDLER commandBuffer,runCmd
		>ADD_CMD_HANDLER commandBuffer,resetCmd
		>ADD_CMD_HANDLER commandBuffer,inputFromPortCmd
		>ADD_CMD_HANDLER commandBuffer,outputToPortCmd
		>ADD_CMD_HANDLER commandBuffer,editMemoryCmd		
				
		; unknown command - report error?
		call	sendUnknownCommandMsg
		; continue interpreter loop
		jmp	dinoMonLoop		


; wysy³a CR-LF na terminal
sendCrLf:	; 
		push	B
		lxi	B,.CRLF
		call 	uartPutStr		
		pop	B
		ret
.CRLF:		.db	CR,LF,0


		
;++ to be deleted!!!				
processRestart:
		lxi	B,.m2
		call	uartPutStr
		; piêkne, cudowne ale skuteczne /* tasza */
		.db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		
		.db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		
		.db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		
		.db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		
		.db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		
		jmp	ROM_BEGIN
.m2:		.db	"reboot",13,10,13,10,0
;--



;------- dino-mon commands handlers implementation ---------------

;-----------------------------------------------------------------
; "i2rb" command - reads byte from device present on I2C bus
; syntax: 
;	i2rb hh nnnn - for long (16-bit) internal address
;	or
;	i2rb hh nn - for short (8-bit) internal address
; where:
;	hh - hardware (bus) address, application specific 
;	nn,nnnn - internal register or memory location to read
;
i2cReadCmdHandler:
		lxi	B,.txt
		call	uartPutStr
		jmp	dinoMonLoop
.txt:		.db	"i2cReadCmdHandler is here...",CR,LF,0

;-----------------------------------------------------------------
; "i2wb" command - writes byte to device present on I2C bus
; syntax: 
;	i2wb hh nnnn dd - for long (16-bit) internal address
;	or
;	i2wb hh nn dd - for short (8-bit) internal address
; where:
;	hh - hardware (bus) address, application specific 
;	nn,nnnn - internal register or memory location to read
;	dd - data to be written to specified location
;
i2cWriteCmdHandler:
		lxi	B,.txt
		call	uartPutStr
		jmp	dinoMonLoop
.txt:		.db	"i2cWriteCmdHandler is here...",CR,LF,0
		

		
;-----------------------------------------------------------------
; "st" command - sets current time (comm. module specific feature)
; syntax: 
;	st hh mm ss
; where:
;	hh - hours (bcd)
;	mm - minutes (bcd)
;	ss - seconds (bcd)
;
setTimeCmdHandler:
		lxi	B,.txt
		call	uartPutStr
		jmp	dinoMonLoop
.txt:		.db	"setTimeCmdHandler is here...",CR,LF,0
		


;-----------------------------------------------------------------
; "gt" command - gets current time (comm. module specific feature)
; syntax: 
;	gt
;
getTimeCmdHandler:
		lxi	B,.txt
		call	uartPutStr
		jmp	dinoMonLoop
.txt:		.db	"getTimeCmdHandler is here...",CR,LF,0



;-----------------------------------------------------------------
; "sd" command - sets current date (comm. module specific feature)
; syntax: 
;	sd yyyy mm dd
; where:
;	yyyy - year (bcd)
;	mm - month (bcd)
;	dd - day (bcd)
;
setDateCmdHandler:
		lxi	B,.txt
		call	uartPutStr
		jmp	dinoMonLoop
.txt:		.db	"setDateCmdHandler is here...",CR,LF,0

		
;-----------------------------------------------------------------
; "gd" command - gets current date (comm. module specific feature)
; syntax: 
;	gd
;
getDateCmdHandler:
		lxi	B,.txt
		call	uartPutStr
		jmp	dinoMonLoop
.txt:		.db	"getDateCmdHandler is here...",CR,LF,0

		
		
;-----------------------------------------------------------------
; "md" command - memory dump to screen in human readable format
; syntax: 
;	md bbbb eeee - dumps memory content between bbbb and eeee adresses
;	or
;	md bbbb - dumps from bbbb address but only 10h mem locations
; where:
;	bbbb - start address
;	eeee - end address
;
memoryDumpToScreenCmdHandler:
		; clear temp text buff
		lxi	B,textBuffer
		mvi	A,0
		mvi	L,32
		call	memFill

		; skip spaces after command name, 
		; stop at first parameter
		lxi	B,commandBuffer+2	
		call	skipSpaces		
		
		; 1-st par, start address, 16 bit
		; convert four next chars to word (two bytes)
		call	strHex2Word		
		jnc	.inputError
		; result ok
		
		push	H	; DE := HL
		pop	D

		inx	B
		inx	B
		inx	B
		inx	B
		call	skipSpaces		

		call	strHex2Word		
		jc	.secParamOk
		; no sec param then prepare it

		push	D
		pop	H
		mov	A,L
		ani	0F0h
		adi	10h
		mov	L,A
		mov	A,H
		aci	0
		mov	H,A
		
		
.secParamOk:		
		
		; result ok, HL valid
		
		; test dump 0000...0100
		
		; hl - end addr 
		; de = begin (current), incremeted

		;save this values for end report
		push	D		; save DE
		push	H		; save HL				
		
.continue:				
		; print address of data block if the lowest nibble is 0 (mod 16)
		
		mov	A,E
		ani	0Fh
		jnz	.noAddress
		
		; print block address
		push	D		; save DE
		push	H		; save HL				

		push	D		; HL := DE
		pop	H		

		lxi	B,textBuffer	; convert & send address of data block
		call 	word2HexStr		
		lxi	B,textBuffer				
		call 	uartPutStr				

		lxi	B,.separatorTxt
		call 	uartPutStr				
		
		pop	H		; get DE back		
		pop	D		; get DE back		
		
.noAddress:				
		
		ldax	D		; A := *DE

		lxi	B,textBuffer		
		call 	byte2HexStr
		lxi	B,textBuffer				
		call 	uartPutStr		

		mvi	A,' '
		call 	uartPutChar
		
		inx	D		; DE++
		
		mov	A,E
		ani	0Fh
		jnz	.noLineBreak
		
		; CR,LF here		
		mvi	A,CR
		call 	uartPutChar
		mvi	A,LF
		call 	uartPutChar
		
.noLineBreak:		
		mov	A,E
		sub	L
		mov	A,D
		sbb	H
		jc	.continue
		; CY = 0 current >= end , CY=1 current < end

		mov	A,E
		ani	0Fh
		jz	.noFinalLineBreak
		
		; CR,LF here		
		mvi	A,CR
		call 	uartPutChar
		mvi	A,LF
		call 	uartPutChar
		
.noFinalLineBreak:				

		
		; restore user input
		pop	H
		pop	D
		
		
		; report status and go back to  mon
		
		call	sendOk
		
		lxi	B,.txt1
		call 	uartPutStr		

		push	H
		
		push	D		; HL := DE
		pop	H		
		lxi	B,textBuffer	
		call 	word2HexStr		
		lxi	B,textBuffer				
		call 	uartPutStr				

		lxi	B,.txt2
		call 	uartPutStr		

		pop	H

		lxi	B,textBuffer	
		call 	word2HexStr		
		lxi	B,textBuffer				
		call 	uartPutStr				

		lxi	B,.txt3
		call 	uartPutStr		
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
;		lxi	B,textBuffer	
;		mvi	A,0
;		stax	B		
;		lxi	D,.txt1
;		call	strAppend
;		lxi	D,.txt2
;		call	strAppend
;		lxi	D,.txt3
;		call	strAppend
;		lxi	D,.CRLF
;		call	strAppend
;		lxi	B,textBuffer	
;		call 	uartPutStr		
;;;;;;;;;;;;;;;;;;;;;;;;
		
		; back to interpreter loop
		jmp	dinoMonLoop
		
.inputError:
		call 	sendInvalidInputParamMsg
		jmp	dinoMonLoop
	
.separatorTxt:	.db	" -> ",0
.txt1:		.db	"MD(",0
.txt2:		.db	",",0
.txt3:		.db	")",CR,LF,0
.CRLF:		.db	CR,LF,0



		
		
;-----------------------------------------------------------------
; "mi" command - memory dump to screen as IntelHex record(s)
; syntax: 
;	mi bbbb eeee - dumps memory content between bbbb and eeee adresses
;	or
;	mi bbbb - dumps from bbbb address but only 10h mem locations
; where:
;	bbbb - start address
;	eeee - end address
;
memoryDumpToIntelHexCmdHandler:
		lxi	B,.txt
		call	uartPutStr
		jmp	dinoMonLoop
.txt:		.db	"memoryDumpToIntelHexCmdHandler is here...",CR,LF,0
		
		
;-----------------------------------------------------------------
; "run" command - starts user code
; syntax: 
;	run nnnn
; where:
;	nnnn - application entry point
;
runCmdHandler:
		lxi	B,.txt
		call	uartPutStr
		jmp	dinoMonLoop
.txt:		.db	"runCmdHandler is here...",CR,LF,0

		
		
;-----------------------------------------------------------------
; "reset" command - warm reset of dino-85 system
; syntax: 
;	reset
;
resetCmdHandler:
		lxi	B,.txt
		call	uartPutStr
		jmp	dinoMonLoop
.txt:		.db	"resetCmdHandler is here...",CR,LF,0

		
		
;-----------------------------------------------------------------
; "in" command - reads byte from input port 
; syntax: 
;	in ii
; where:
;	ii - input port address
;
		.in incmd.inc

		

;-----------------------------------------------------------------
; "out" command - writes byte to output port
; syntax: 
;	out oo dd
; where:
;	oo - output port address
;	dd - data to write
; OK, OUT(aa,bb)
outputToPortCmdHandler:

		; clear temp text buff
		lxi	B,textBuffer
		mvi	A,0
		mvi	L,32
		call	memFill

		; skip spaces after command name, 
		; stop at first parameter
		lxi	B,commandBuffer+3	
		call	skipSpaces		
		
		; 1-st par, i/o address
		; convert two next chars to bin (one byte)
		call	strHex2Byte		
		jnc	.inputError
		; result in HL, get only L		
		mov	D,L
		inx	B
		inx	B
		inx	B
		call	skipSpaces		

		; 2-nd param		
		call	strHex2Byte		
		jnc	.inputError
		; result in HL, get only L		
		mov	E,L

		; real OUT operation here		
		
		; send feedback
		
		call	sendOk		
		
		lxi	B,.txt1
		call 	uartPutStr								
		
		mov	A,D
		lxi	B,textBuffer		
		call 	byte2HexStr
		call 	uartPutStr								

		lxi	B,.txt2
		call 	uartPutStr								
		
		mov	A,E
		lxi	B,textBuffer		
		call 	byte2HexStr
		call 	uartPutStr								
		
		lxi	B,.txt3
		call 	uartPutStr								
		
		; back to interpreter loop
		jmp	dinoMonLoop
		
.inputError:
		call 	sendInvalidInputParamMsg
		jmp	dinoMonLoop
		
.txt1:		.db	"OUT(",0
.txt2:		.db	",",0
.txt3:		.db	")",CR,LF,0



;-----------------------------------------------------------------
; "em" command - edits selected memory location
; syntax: 
;	em nnnn dd
; where:
;	nnnn - address of cell to edit
;	dd - data to write
;
editMemoryCmdHandler:		
		lxi	B,.txt
		call	uartPutStr
		jmp	dinoMonLoop
.txt:		.db	"editMemoryCmdHandler is here...",CR,LF,0

		

;------------------------ end of handlers impl. --------------------		


			.in 	convert.inc
			.in 	strutil.inc
			.in 	memutil.inc			


;-------------------------------------------


		
		



;--------------------------------------------------------------------
; dnUartInitImpl - raw implementation
; waits for a new character in UART receive buffer in endless loop
; in: 	n/a
; out:	n/a
uartInit:
		push	PSW
		mvi	A,0
		out	SYS_UART_CMST
		.db	0,0,0,0,0,0,0,0,0,0
		out	SYS_UART_CMST
		.db	0,0,0,0,0,0,0,0,0,0
		out	SYS_UART_CMST
		.db	0,0,0,0,0,0,0,0,0,0
		out	SYS_UART_CMST
		.db	0,0,0,0,0,0,0,0,0,0
		mvi	A,40h
		out	SYS_UART_CMST
		.db	0,0,0,0,0,0,0,0,0,0
		mvi	A,4eh
		out	SYS_UART_CMST
		.db	0,0,0,0,0,0,0,0,0,0	
		in	SYS_UART_DATA	
		mvi	A,07h
		out	SYS_UART_CMST		
		pop	PSW
		ret


;--------------------------------------------------------------------
; dnUartGetChrImpl - raw implementation
; waits for a new character in UART receive buffer in endless loop
; in: 	n/a
; out:	A - already read, new char. 
uartGetChar:
.wait:
		in	SYS_UART_CMST	; get current status of UART
		ani	%0000.0010	; check RxRDY flag  
		jz	.wait		; no incoming data, then wait
		in	SYS_UART_DATA	; get new data
		ret


;--------------------------------------------------------------------
; dnUartGetStrImpl - raw implementation
; Collects incoming characters in receiving text buffer until <CR> received
; out buffer is then ended by 0h byte (null-string)
; in:	BC - buffer address
;	L - length of buffer
; out:	n/a
uartGetStr:	
		push	PSW
		push	H
		push	B
.receive:	
		call	uartGetChar	; wait for char.
		cpi	CR			; do we have CR?
		jz	.crReceived		; yea...
		stax	B			; no CR? so, *prt = A
		inx	B			; ptr++
		dcr	L			; counter--
		jnz	.receive		; receive until buffer finished
		; uups, buffer ends, still no CR
		; so do the same action as for CR, the last valid
		; character will be damaged...but who cares? 
		; (all completed string is probably a bullshit anyway)
		dcx	B			; a byte back, ptr--
.crReceived:
		; we have CR, so finalise string
		mvi	A,0
		stax	B
		; then return control to upper layer
		pop	B
		pop	H
		pop	PSW
		ret


;--------------------------------------------------------------------
; dnUartPutChar_impl - raw implementation
;
; in:	A - char (ascii code) to send via serial link
; out:	n/a
uartPutChar:
		push	PSW	; save Acc, we need this reg. in IN instr.
.wait:
		in	SYS_UART_CMST	; get status of UART
		ani	%0000.0001	; check TxRDY flag
		jz	.wait		; wait unitl ready (flag = 1)
		pop	PSW		; restore A, so we have byte to send
		out	SYS_UART_DATA	; send data
		ret


;--------------------------------------------------------------------
; dnUartPutStrImpl - raw implementation
; in:	BC - address of text to send (with NULL @ end)
; out:	n/a
uartPutStr:
		push	PSW
		push	B
.send:
		ldax	B	; get data to send
		cpi	0	; end of string?
		jz	.done	; yes, then exit
		call	uartPutChar
		inx	B	; show next data
		jmp	.send	; and repeat
.done:
		pop	B
		pop	PSW
		ret


		;--------------------------------------------------------------------
		; dnLcdInitImpl - raw implementation
lcdInit:
		; TO BE IMPLEMENTED!
		ret
		;
		;		
		;--------------------------------------------------------------------
		; dnLcdPutCharImpl - raw implementation
lcdPutChar:
		; TO BE IMPLEMENTED!
		ret
		;
		;		
		;--------------------------------------------------------------------
		; dnLcdPutCmdImpl - raw implementation
lcdPutCmd:
		; TO BE IMPLEMENTED!
		ret
		;
		;		
		;--------------------------------------------------------------------
		; dnLcdPutStrImpl - raw implementation
lcdPutStr:
		; TO BE IMPLEMENTED!
		ret


; ================ internal purpose stuff starts here ===================
;
; all functinos and procedures below ARE NOT EXPORTED, their addresses
; may change during modification of dino-mon code

; sends welcome message and similar gadgets

sendOk:
		push	B
		lxi	B,msgGenericOk
		call	uartPutStr
		pop	B
		ret

sendErr:
		push	B
		lxi	B,msgGenericErr
		call	uartPutStr
		pop	B
		ret

sendWelcomeMessage:
		push	B
		call	sendOk
		lxi	B,msgWelcome
		call	uartPutStr
		pop	B
		ret


sendUnknownCommandMsg:
		push	B
		call	sendErr
		lxi	B,msgUnknownCmd
		call	uartPutStr
		pop	B
		ret


sendInvalidInputParamMsg:
		push	B
		call	sendErr
		lxi	B,msgInvalidInp
		call	uartPutStr
		pop	B
		ret

;-------------
; code of this function will be copied into upper ram
; we A- dana
;    B port addres
;
;.	in	00
;	ret
;	
;	.db	IN_OPCODE,ADDR_
;
;--------------------------------------------------------------------
; ROM data here, stuff with messages, tables and similar mess
; to be used in dino-mon or copied to the upper (RAM) memory blocks
;
; system messages 
; red - 31  , cyan 36 - def. , 32- green
; tasza, term vt100 colors
msgGenericOk	.db	27,"[0;32mOK",27,"[0;36m, ",0		
msgGenericErr	.db	27,"[0;33;41mERR",27,"[0;36m, ",0
msgWelcome:	.db 	"dino-85 (c) 2008, `dino-mon` by Natasza, rev.1.1",CR,LF,0
msgUnknownCmd:	.db	"unknown command entered",CR,LF,0
msgInvalidInp:	.db	"invalid input parameter(s)",CR,LF,0

			
		>DEF_CMD_NAME	"i2r ",i2cReadCmd
		>DEF_CMD_NAME	"i2w ",i2cWriteCmd
		>DEF_CMD_NAME	"st ",setTimeCmd
		>DEF_CMD_NAME	"gt",getTimeCmd
		>DEF_CMD_NAME	"sd ",setDateCmd
		>DEF_CMD_NAME	"gd",getDateCmd
		>DEF_CMD_NAME	"md ",memoryDumpToScreenCmd
		>DEF_CMD_NAME	"mi ",memoryDumpToIntelHexCmd
		>DEF_CMD_NAME	"run ",runCmd
		>DEF_CMD_NAME	"reset",resetCmd
		>DEF_CMD_NAME	"in ",inputFromPortCmd
		>DEF_CMD_NAME	"out ",outputToPortCmd
		>DEF_CMD_NAME	"em ",editMemoryCmd
;
; table to be copied as-is to upper RAM, it must be in the same order 
; as declared in dino85.inc file (in SYS_MEM) area
;	
	
sysProcJumpTableDef:
		>DEF_SYS_PROC_JUMP lcdInit
		>DEF_SYS_PROC_JUMP lcdPutChar
		>DEF_SYS_PROC_JUMP lcdPutCmd
		>DEF_SYS_PROC_JUMP lcdPutStr
		>DEF_SYS_PROC_JUMP uartInit
		>DEF_SYS_PROC_JUMP uartGetChar
		>DEF_SYS_PROC_JUMP uartGetStr
		>DEF_SYS_PROC_JUMP uartPutChar
		>DEF_SYS_PROC_JUMP uartPutStr
		>DEF_SYS_PROC_JUMP memCopy
		>DEF_SYS_PROC_JUMP memFill
sysProcJumpTableDefEnd:	


; end of dinomon.asm

