		.cr	8085            
		.tf	lcdtest.hex,INT
		.lf	lcdtest.lst
		;--------------------------------------------------------	
		; lcdtest.asm - small test application as a template
		; for other ones. Just include dino85.inc file to 
		; have access to all (most?) dino-85 features,
		; set entry point to 8000h or better to: RAM_BEGIN
		;
		; Important: do not call dino system functions from ROM,
		; use RAM locations instead, as declared in dino85.inc
		; Dino-mon may change, so all direct invocations might
		; produce unexpected results...feel warned.
		;
		; compile:
		;	sbasm lcdtest.asm
		; run:
		; 	when loaded - type run 8000<enter> on terminal
		;--------------------------------------------------------	
		.in	../common/dino85.inc
		;
		.or	RAM_BEGIN
		;
		; initialise LCD module
		call	dnLcdInit
		;
		; show defined message
		mvi	H, helloMessage1
		call	dnLcdPutStr
		; then hang until reset
		;  jmp	$
		hlt
		;
helloMessage1: .db	"maidin mhaith :-)",13,10,0				
		;
		; end of lcdtest.asm