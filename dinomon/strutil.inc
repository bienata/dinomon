;///////////////////////////////////////////////////////
;//
;// strutil.inc - procedury operuj�ce na napisach
;//
;///////////////////////////////////////////////////////


;-------------------------------------------------------
; skipSpaces
;
; Skanuje napis pocz�wszy od adresu podanego w BC 
; pomijaj�c znaki spacji. Analiza ko�czy si� z chwil�
; napotkania ascii nie b�d�cego spacj� i jego adres
; jest zwracany w BC
;
; we:	
;	BC - adres napisu do analizy
;
; wy:   
;	BC - zmodyfikowana warto��
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
; Dokonuje kontaktencji napis�w o adresach podanych odpowiednio
; w rejestrach BC (napis docelowy/rozszerzany) i DE (napis, kt�ry
; trzeba doda�. Oba napisy musz� ko�czy� si� bajtem 0 (z-string)
;
; we:	
;	BC - adres napisu do rozszerzenia/modyfikacji
;	DE - adres napisu, kt�ry nale�y doda� na ko�cu tego z BC
;
; wy:   
;	-
;	
strAppend:
		push	B
		push	D
		push	PSW
		
		; przewi� na koniec napisu docelowego
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
		stax	B			; zako�cz zerem
		
		pop	PSW
		pop	D
		pop	B
		ret


;-------------------------------------------------------
; strEquals
;
; Por�wnuje dwa napisy o adresach podanych odpowiednio
; w rejestrach BC i DE, por�wnywane jest tylko tyle znak�w
; ile nakazano warto�ci� rejestru L
;
; we:	
;	BC - adres pierwszego napisu (wzorca)
;	DE - adres drugiego napisu (do sprawdzenia)
;	L - ilo�� bajt�w (znak�w) do sprawdzenia
; wy:   
;	CY = 1 - napisy pasuj� do siebie na L znakach
;	CY = 0 - napisy r�ni� si� w obr�bie L znak�w
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
