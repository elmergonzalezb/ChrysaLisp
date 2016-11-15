%include 'inc/func.ninc'
%include 'class/class_stream.ninc'

def_func class/stream/deinit
	;inputs
	;r0 = stream object
	;trashes
	;all but r0, r4

	;deref any buffer object
	vp_push r0
	vp_cpy [r0 + stream_object], r0
	vpif r0, !=, 0
		f_call ref, deref, {r0}
	endif

	;free any buffer
	vp_cpy [r4], r0
	f_call sys_mem, free, {[r0 + stream_buffer]}
	vp_pop r0

	;parent deinit
	s_jmp stream, deinit, {r0}

def_func_end
