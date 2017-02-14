inputFromPortCmdHandler:

		; clear temp text buff
		lxi	B,textBuffer
		mvi	A,0
		mvi	L,32
		call	memFill

		; skip spaces after command name, 
		; stop at first parameter
		lxi	B,commandBuffer+2	
		call	skipSpaces		
		
		; convert two next chars to bin (one byte)
		call	strHex2Byte		
		jnc	.inputError
		; result in HL, get only L		
		mov	A,L
		lxi	B,textBuffer		
		call 	byte2HexStr

		call	sendOk

		; send first part of response
		lxi	B,.txt1
		call 	uartPutStr		

		; then send converted parameter as echo
		lxi	B,textBuffer				
		call 	uartPutStr		

		; send the second part of response
		lxi	B,.txt2
		call 	uartPutStr		

		; do real IN operation here
		; ACC - return value, TO BE IMPLEMENTED
		
		; convert result
		mvi	A,0feh			; FIX IT!
		lxi	B,textBuffer		
		call 	byte2HexStr
		
		; and send it back
		lxi	B,textBuffer				
		call 	uartPutStr		

		; finish with CRLF
		lxi	B,.txt3
		call 	uartPutStr								
		
		; back to interpreter loop
		jmp	dinoMonLoop
		
.inputError:
		call 	sendInvalidInputParamMsg
		jmp	dinoMonLoop
		
.txt1:		.db	"IN(",0
.txt2:		.db	")=",0
.txt3:		.db	CR,LF,0
