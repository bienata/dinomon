;///////////////////////////////////////////////////////
;//
;// convert.inc - procedury konwertuj¹ce
;//
;///////////////////////////////////////////////////////


;-------------------------------------------------------
; strHex2Byte
;
; Konwertuje string hex (dwa znaki ascii) na bajt.
;
; we:	
;	BC - adres napisu do analizy
;
; wy:   
;	CY = 1 - konwersja OK
;	HL - wynik konwersji, H (msb) - zero, L(lsb) - dana
;
;	CY = 0 - b³¹d konwersji
;	HL - zawartoœæ bez znaczenia
;	
strHex2Byte:
		push	PSW
		push	B	
		
		ldax	B
		call	char2HexDigit
		jnc	.convErr
		rlc	; A << 4
		rlc		
		rlc		
		rlc		
		mov	L,A
		inx	B	; nastepna cyfra
		ldax	B		
		call	char2HexDigit
		jnc	.convErr
		ora	L	; A = A | L
		mov	L,A		
		mvi	H,0
		pop	B
		pop	PSW
		>SET_CY_FLAG		
		ret
.convErr:	
		pop	B
		pop	PSW
		>CLEAR_CY_FLAG		
		ret


;-------------------------------------------------------
; strHex2Word
;
; Konwertuje string hex (cztery znaki ascii) na s³owo.
;
; we:	
;	BC - adres napisu do analizy
;
; wy:   
;	CY = 1 - konwersja OK
;	HL - wynik konwersji: H (msb), L(lsb) 
;
;	CY = 0 - b³¹d konwersji
;	HL - zawartoœæ bez znaczenia
;	
strHex2Word:
		push	PSW
		push	B	
		
		; starszy bajt +0, +1
		ldax	B
		call	char2HexDigit
		jnc	.convErr
		rlc	; A << 4
		rlc		
		rlc		
		rlc		
		mov	H,A
		inx	B	; nastepna cyfra
		ldax	B		
		call	char2HexDigit
		jnc	.convErr
		ora	H	; A = A | H
		mov	H,A		
		
		; m³odszy bajt
		inx	B	
		ldax	B
		call	char2HexDigit
		jnc	.convErr
		rlc	; A << 4
		rlc		
		rlc		
		rlc		
		mov	L,A
		inx	B	; nastepna cyfra
		ldax	B		
		call	char2HexDigit
		jnc	.convErr
		ora	L	; A = A | L
		mov	L,A		
		
		pop	B
		pop	PSW
		>SET_CY_FLAG		
		ret
.convErr:	
		pop	B
		pop	PSW
		>CLEAR_CY_FLAG		
		ret

		
;-------------------------------------------------------
; char2HexDigit
;
; Konwertuje kod ascii bêd¹cy cyfra hex (0..9,a..f,A..F) 
; na jego wartoœæ binarn¹.
;
; we:	
;	ACC - kod znaku ascii
;
; wy:   
;	CY = 1 - konwersja OK
;	ACC - wartoœæ liczbowa
;
;	CY = 0 - b³¹d konwersji
;	ACC - zawartoœæ bez znaczenia
;	
char2HexDigit:	
		push	B
		push	D
		push	H
		
		mov	H,A		
		lxi	B,validHexChars	; adres tabeli z dopuszcz. znakami
		>LENGTH L,validHexChars
		lxi	D,validHexVals	; adres tabeli z wartoœciami 
.continue:		
		ldax	B		; a = *validHexChars
		cmp	H		; a == inputChar ?
		jz	.codeFound	; yyeeeea!
		inx	B		; validHexChars++
		inx	D		; validHexVals++
		dcr	L		; L--
		jnz	.continue		
		; znaku nie ma w tabeli
		pop	H
		pop	D
		pop	B
		>CLEAR_CY_FLAG
		ret	
.codeFound:	
		ldax	D		; a = *validHexValues - pobierz wartoœæ
		pop	H
		pop	D
		pop	B
		>SET_CY_FLAG
		ret	

		
;-------------------------------------------------------
; byte2HexStr
;
; Konwertuje bajt podany w ACC na napis hex, dane sk³aduje 
; pod adres wskazany rejestrem BC, koñcz¹c napis
; wartoœci¹ 0 (buduje z-string)
;
; we:	
;	ACC - bajt do konwersji na napis hex
;	BC - adres bufora docelowego (3 znaki)
;
; wy:   -
;	
byte2HexStr:
		push	PSW
		push	B
		
		push	PSW
		ani	0F0h
		rrc			; A >> 4
		rrc
		rrc
		rrc
		call	bin2char
		stax	B
		inx	B
		pop	PSW
		ani	0Fh
		call	bin2char		
		stax	B
		; zakoñcz zerem
		inx	B
		mvi	A,0
		stax	B		
		
		pop	B
		pop	PSW
		ret



;-------------------------------------------------------
; word2HexStr
;
; Konwertuje s³owo podane w HL na napis hex, dane sk³aduje 
; pod adres wskazany rejestrem BC, koñcz¹c napis
; wartoœci¹ 0 (buduje z-string)
;
; we:	
;	HL - s³owo do konwersji na napis hex
;	BC - adres bufora docelowego (5 znaków)
;
; wy:   
;	-	
;
word2HexStr:
		push	PSW
		push	B
		
		; rejest H (msb)
		mov	A,H		; 
		ani	0F0h		; starszy nibble MSB
		rrc			; A >> 4
		rrc
		rrc
		rrc
		call	bin2char
		stax	B
		
		inx	B		; ptr++
		
		mov	A,H
		ani	0Fh		; m³odszy nibble LSB
		call	bin2char		
		stax	B
		
		inx	B		; ptr++
		
		; rejest L (lsb)
		mov	A,L
		ani	0F0h		; starszy nibble LSB
		rrc			; A >> 4
		rrc
		rrc
		rrc
		call	bin2char
		stax	B
		
		inx	B		; ptr++
		
		mov	A,L
		ani	0Fh		; m³odszy nibble LSB
		call	bin2char		
		stax	B
		
		; zakoñcz zerem
		inx	B
		mvi	A,0
		stax	B		
		
		pop	B
		pop	PSW		
		ret


;-------------------------------------------------------
; bin2char
;
; Zwraca kod ascii cyfry binarnej (0..F) podanej w ACC
;
; we:	
;	ACC - cyfra binarna
;
; wy:   
;	ACC - jej kod ascii z lookup table
;
bin2char:
		push	H
		push	B
		
		lxi	H,validHexChars		
		mvi	B,0
		mov	C,A
		dad	B
		mov	A,M
		pop	B
		pop	H
		ret

;-------------------------------------------------------------
; tabele pomocnicze do funkcji konwertuj¹cych
; dopuszczalne kody ascii cyfr szesnastkowych
validHexChars:	.db	'0','1','2','3','4','5','6','7','8','9'
		.db	'A','B','C','D','E','F'
		.db 	'a','b','c','d','e','f'
validHexCharsEnd:
; wartoœci binarne dla kodów z tabeli powy¿ej
validHexVals:	.db	00h,01h,02h,03h,04h,05h,06h,07h,08h,09h
		.db	0Ah,0Bh,0Ch,0Dh,0Eh,0Fh
		.db	0Ah,0Bh,0Ch,0Dh,0Eh,0Fh

; eof convert.inc
