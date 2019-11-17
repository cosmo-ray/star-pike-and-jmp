 ;         DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
 ;                   Version 2, December 2004
 ;
 ; Copyright (C) 2019 Matthias Gatto <uso.cosmo.ray@gmail.com>
 ;
 ; Everyone is permitted to copy and distribute verbatim or modified
 ; copies of this license document, and changing it is allowed as long
 ; as the name is changed.
 ;
 ;            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
 ;  TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
 ;
 ;  0. You just DO WHAT THE FUCK YOU WANT TO.
 ;


	org 0x7c00

pj_pos:	equ 0x0fa0
rand:	equ 0x0fa2
pike:	equ 0x0fa4
jmp_pow:	equ 0x0fa6
score:	equ 0x0fa8
can_border:	equ 0x0faa

	mov ax,0x0002 		; set 80x25 txt mode
	int 0x10
	cld			; reset dir flag
	mov ax,0xb800		; video segment pos
	mov ds,ax
	mov es,ax
	;; variables init
	mov word [pj_pos],3360 + 10	; 22 * 160 + 4
	xor ax,ax
	mov di,jmp_pow
	stosw		; jmp_pow
	stosw		; score
	stosw		; can_border
	jmp reset_pike
main_loop:
	inc word [rand]
	cmp word [can_border],0x00
	jz wait_frm
	dec word [can_border]

wait_frm:
	xor ah,ah
	int 0x1a
frm_wait_loop:
	push dx
	xor ah,ah
	int 0x1a
	pop bx
	cmp bx,dx
	jz frm_wait_loop

	;; get input
	mov ah,0x01
	int 0x16
	jne key_pressed

	;; handle guy jmp
	mov cx,[jmp_pow]

	jcxz print_map		; jmp_pow is 0
	cmp cx,5
	jc jmp_handle_down	; cx < 4

	sub word [pj_pos],160
	mov di,[pj_pos]
	mov word [di+480],0x0000
	mov word [di+322],0x0000

	jmp jmp_handle_out
jmp_handle_down:		;let s fall
	mov di,[pj_pos]
	mov word [di+162],0x0000
	mov word [di],0x0000
	add word [pj_pos],160
jmp_handle_out:
	dec word [jmp_pow]

print_map:
	cld

	mov ax,[score]
	mov di,100
	call print_hex

	mov cx,160
border_next0:
	sub cx,2
	jcxz try_add_border
	mov di,3838
	sub di,cx
	cmp word [di],0xffb0
	jnz border_next0

	mov word [di],0x0000
	cmp cx,158
	jz try_add_border
	mov word [di - 2],0xffb0
	jmp border_next0

try_add_border:
	test word [rand],0x1f
	jnz print_guy
	cmp word [can_border],0x00
	jnz print_guy
	mov word [di],0xffb0

print_guy:
	mov di,[pj_pos]
	mov word [di],0x0f02	; head
	mov word [di+160],0xb000 ; body
	mov word [di+162],0x0f5c ; body
	mov word [di+320],0x0213 ; legs

	;; print floor
	mov cx,160
floor:
	mov di,3838
	add di,cx
	mov word [di],0xff00
	dec cx
	loop floor

	add di,[pike]
	mov ax,0x0c1e
	stosw			; pike are 3 case long
	stosw
	stosw

	mov word [220],0x0604	; print star
	mov word [670],0x0604	; print star
	mov word [312],0x0604	; print star
	mov word [394],0x0604	; print star
	mov word [300],0x0604	; print star
	mov word [404],0x0604	; print star
	mov word [764],0x0604	; print star
	sub word [pike],2
	;; must reset if cary
	jc reset_pike

	mov di,[pj_pos]
	cmp byte [di + 480],0x00
	jnz die
	cmp byte [di + 323],0xff
	jz die
	jmp main_loop

key_pressed:
	mov ah,0x00
	int 0x16
	add [rand],al
	cmp al,0x1b
	jz exit
	cmp al,' '
	jz guy_jmp
	jmp print_map

reset_pike:
	mov word [can_border],9
	mov word [pike],154
	jmp main_loop
die:
	mov word [0],0x0f64	; 'd'
	mov word [2],0x0f65	; 'e'
	mov word [4],0x0f61	; 'a'
	mov word [6],0x0f64	; 'd'
exit:
	int 0x20

	;; unsafe func
	;; need to preotect cx,dx
	;; but I need place more
print_hex:
	mov dx,ax
	mov bx,0xf000
	mov cl,12
	call print_hex_gen	;0xf000
	call print_hex_gen 	;0x0f00
	call print_hex_gen	;0x00f0
	call print_hex_gen	;0x000f
	ret

print_hex_gen:
	and ax,bx
	jz phg1
	shr ax,cl
phg1:
	cmp ax,10
	jnc add_a_hex
	add ax,'0'
	jmp phg2
add_a_hex:
	sub ax,10
	add ax,'A'
phg2:
	or ax,0x0f00
	stosw
	sub cl,4
	mov ax,dx
	shr bx,4
	ret

guy_jmp:
	mov di,[pj_pos]
	cmp word [jmp_pow],0
	jnz print_map
	inc word [score]
	mov word [jmp_pow],8
	jmp print_map

	;; boot sector stuff
	times 510-($-$$) db 0
	db 0x55,0xaa
