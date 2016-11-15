%include 'inc/func.ninc'
%include 'class/class_ref.ninc'

def_func class/ref/ref_if
	;inputs
	;r0 = 0, else object
	;trashes
	;r1

	;inc ref count
	vpif r0, !=, 0
		vp_cpy [r0 + ref_count], r1
		vp_inc r1
		vp_cpy r1, [r0 + ref_count]
	endif
	vp_ret

def_func_end
