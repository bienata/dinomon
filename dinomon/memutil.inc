;///////////////////////////////////////////////////////
;//
;// memutil.inc - procedury operauj¹ce na blokach pamiêci
;//
;///////////////////////////////////////////////////////


;-------------------------------------------------------
; memFill
;
; Wype³nia blok pamiêci o rozmiarze L bajtów wartoœci¹
; podan¹ w ACC, adres bloku podaje siê w BC
;
; we:	
;	BC - adres bloku pamiêci
;	ACC - wartoœæ wype³niaj¹ca
;	L - iloœæ bajtów
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
; Kopiuje L bajtów z bloku pamiêci o adresie podanym w BC
; pod docelowy adres wskazany w DE.
;
; we:	
;	BC - adres Ÿród³owego bloku pamiêci
;	DE - adres docelowego bloku pamiêci
;	L - iloœæ bajtów do skopiowania
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
