%include 'inc/func.ninc'
%include 'class/class_symbol.ninc'

def_func class/symbol/create_from_cstr
	;inputs
	;r0 = c symbol pointer
	;outputs
	;r0 = 0 if error, else object
	;trashes
	;r1-r3, r5-r7

	func_call string, create_from_cstr, {r0}, {r0}
	vpif r0, !=, 0
		func_path class, symbol
		fn_bind _function_, r1
		vp_cpy r1, [r0 + obj_vtable]
	endif
	vp_ret

def_func_end
