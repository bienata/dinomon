;///////////////////////////////////////////////////////
;//
;// memutil.inc - procedury operauj�ce na blokach pami�ci
;//
;///////////////////////////////////////////////////////


;-------------------------------------------------------
; memFill
;
; Wype�nia blok pami�ci o rozmiarze L bajt�w warto�ci�
; podan� w ACC, adres bloku podaje si� w BC
;
; we:	
;	BC - adres bloku pami�ci
;	ACC - warto�� wype�niaj�ca
;	L - ilo�� bajt�w
;
; wy:   
;	-
;	
memFill:
		push	PSW
		push	H	
		push	B
.fill:		
		stax	B	; *ptr = A
		inx	B	; ptr++
		dcr	L	; cntr--
		jnz	.fill
		pop	B
		pop	H	
		pop	PSW
		ret



;-------------------------------------------------------
; memCopy
;
; Kopiuje L bajt�w z bloku pami�ci o adresie podanym w BC
; pod docelowy adres wskazany w DE.
;
; we:	
;	BC - adres �r�d�owego bloku pami�ci
;	DE - adres docelowego bloku pami�ci
;	L - ilo�� bajt�w do skopiowania
;
; wy:   
;	-
;	
memCopy:
		push	PSW
		push	H	
		push	B
		push	D
.copy:		
		ldax	B	; A = *src
		stax	D	; *dest = A
		inx	B	; src++
		inx	D	; dest++
		dcr	L	; cntr--
		jnz	.copy
		pop	D
		pop	B
		pop	H	
		pop	PSW
		ret


; eof memutil.inc
