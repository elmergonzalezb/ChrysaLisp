%include 'inc/func.ninc'
%include 'class/class_pair.ninc'

def_func class/pair/create
	;inputs
	;r0 = first object
	;r1 = second object
	;outputs
	;r0 = 0 if error, else object
	;trashes
	;r1-r3, r5-r7

	;save data
	vp_cpy r0, r6
	vp_cpy r1, r7

	;create new string object
	f_call pair, new, {}, {r0}
	vpif r0, !=, 0
		;init the object
		func_path class, pair
		f_call pair, init, {r0, @_function_, r6, r7}, {r1}
		vpif r1, ==, 0
			;error with init
			v_call pair, delete, {r0}, {}, r1
			vp_xor r0, r0
		endif
	endif
	vp_ret

def_func_end
