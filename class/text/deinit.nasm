%include 'inc/func.ninc'
%include 'class/class_text.ninc'
%include 'class/class_string.ninc'
%include 'class/class_vector.ninc'

def_func class/text/deinit
	;inputs
	;r0 = text object
	;trashes
	;all but r0, r4

	;save object
	vp_push r0

	;deref any string and words objects
	vp_cpy [r0 + text_string], r0
	vpif r0, !=, 0
		f_call string, deref, {r0}
		vp_cpy [r4], r0
		f_call vector, deref, {[r0 + text_words]}
	endif

	;deinit parent
	vp_pop r0
	s_jmp text, deinit, {r0}

def_func_end
