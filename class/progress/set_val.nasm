%include 'inc/func.ninc'
%include 'class/class_progress.ninc'

def_func class/progress/set_val
	;inputs
	;r0 = progress object
	;r1 = value
	;outputs
	;r1 = value, clipped to max

	vpif r1, >, [r0 + progress_max]
		vp_cpy [r0 + progress_max], r1
	endif
	vp_cpy r1, [r0 + progress_val]
	vp_ret

def_func_end
