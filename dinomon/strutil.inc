;///////////////////////////////////////////////////////
;//
;// strutil.inc - procedury operuj¹ce na napisach
;//
;///////////////////////////////////////////////////////


;-------------------------------------------------------
; skipSpaces
;
; Skanuje napis pocz¹wszy od adresu podanego w BC 
; pomijaj¹c znaki spacji. Analiza koñczy siê z chwil¹
; napotkania ascii nie bêd¹cego spacj¹ i jego adres
; jest zwracany w BC
;
; we:	
;	BC - adres napisu do analizy
;
; wy:   
;	BC - zmodyfikowana wartoœæ
;	
skipSpaces:
		push	PSW
.continue:
		ldax	B
		cpi	' '
		jnz	.enough
		inx	B
		jmp	.continue
.enough:	
		pop	PSW
		ret


;-------------------------------------------------------
; strAppend
;
; Dokonuje kontaktencji napisów o adresach podanych odpowiednio
; w rejestrach BC (napis docelowy/rozszerzany) i DE (napis, który
; trzeba dodaæ. Oba napisy musz¹ koñczyæ siê bajtem 0 (z-string)
;
; we:	
;	BC - adres napisu do rozszerzenia/modyfikacji
;	DE - adres napisu, który nale¿y dodaæ na koñcu tego z BC
;
; wy:   
;	-
;	
strAppend:
		push	B
		push	D
		push	PSW
		
		; przewiñ na koniec napisu docelowego
.seekEnd:		
		ldax	B			; A := *ptr
		cpi	0			; == 0?
		jz	.hasLastOne
		inx	B			; ptr++
		jmp	.seekEnd			;
.hasLastOne:					; *ptr jest 0x00
.appendNext:
		ldax	D			; A := *src
		cpi	0			; == 0 ?
		jz	.done
		stax	B			; *dest := A
		inx	B			; dest++
		inx	D			; src++
		jmp	.appendNext
.done:
		mvi	A,0
		stax	B			; zakoñcz zerem
		
		pop	PSW
		pop	D
		pop	B
		ret


;-------------------------------------------------------
; strEquals
;
; Porównuje dwa napisy o adresach podanych odpowiednio
; w rejestrach BC i DE, porównywane jest tylko tyle znaków
; ile nakazano wartoœci¹ rejestru L
;
; we:	
;	BC - adres pierwszego napisu (wzorca)
;	DE - adres drugiego napisu (do sprawdzenia)
;	L - iloœæ bajtów (znaków) do sprawdzenia
; wy:   
;	CY = 1 - napisy pasuj¹ do siebie na L znakach
;	CY = 0 - napisy ró¿ni¹ siê w obrêbie L znaków
;	
strEquals:
		push	PSW
		push	B
		push	D
		push	H		
.continue
		ldax	B	; A = *source
		mov	H,A	; zachowaj w H na moment
		ldax	D	; A = *template
		cmp	H	; A == H ? equ - Z, diff - NZ
		jnz	.different 
		inx	B	; source++
		inx	D	; template++
		dcr	L	; counter--
		jnz	.continue
		
		pop	H
		pop	D
		pop	B
		pop	PSW
		>SET_CY_FLAG
		ret
.different:		
		pop	H
		pop	D
		pop	B
		pop	PSW
		>CLEAR_CY_FLAG
		ret

; eof strutils.inc
