	org 0x7c00

pj_pos:	equ 0x0fa0
rand:	equ 0x0fa2
pike:	equ 0x0fa4
jmp_pow:	equ 0x0fa6
score:	equ 0x0fa8

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
	jmp reset_pike
main_loop:
	inc word [rand]

	;; wait frm
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
	cmp cx,4
	jc jmp_handle_down	; cx < 3

	sub word [pj_pos],160
	mov di,[pj_pos]
	mov word [di+480],0x0000

	jmp jmp_handle_out
jmp_handle_down:		;let's fall
	mov di,[pj_pos]
	mov word [di],0x0000
	add word [pj_pos],160
jmp_handle_out:
	sub word [jmp_pow],1

print_map:
	cld

	mov ax,[score]
	mov di,100
	call print_hex

	call print_guy

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
	stosw
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
	mov word [pike],154
	jmp main_loop
die:
	mov word [0],0x0f64
	mov word [2],0x0f65
	mov word [4],0x0f61
	mov word [6],0x0f64
exit:
	int 0x20

	;; to remove or refacto
print_hex:
	mov dx,ax
	mov bx,0xf000
	mov cl,12
	call print_hex_gen	;0xf000
	call print_hex_gen 	;0x0f00
	call print_hex_gen	;0x00f0
	call print_hex_gen	;0x000f
	ret

add_ascii:
	cmp ax,10
	jnc add_a_hex
	add ax,'0'
	ret
add_a_hex:
	sub ax,10
	add ax,'A'
	ret

print_hex_gen:
	and ax,bx
	jz phg1
	shr ax,cl
phg1:
	call add_ascii
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
	add word [score],1
	mov word [jmp_pow],6
	jmp print_map

print_guy:
	mov di,[pj_pos]
	mov word [di],0x0f02
	mov word [di+160],0x0bf2
	mov word [di+320],0x0213
	ret

	;; boot sector stuff
	times 510-($-$$) db 0
	db 0x55,0xaa
