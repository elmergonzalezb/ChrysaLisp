%include 'inc/func.ninc'
%include 'class/class_button.ninc'

def_func class/button/mouse_up
	;inputs
	;r0 = button object
	;r1 = mouse event message
	;trashes
	;all but r0, r4

	vp_cpy [r0 + button_state], r1
	vp_push r1

	vp_cpy r1, r2
	vp_and ~button_state_pressed, r1
	vp_cpy r1, [r0 + button_state]
	vpif r1, !=, r2
		v_call button, layout, {r0}
		f_call button, dirty, {r0}
	endif

	;emit pressed signal ?
	vp_pop r1
	vp_and button_state_pressed, r1
	vpif r1, !=, 0
		f_jmp button, emit, {r0, &[r0 + button_pressed_signal]}
	endif
	vp_ret

def_func_end
