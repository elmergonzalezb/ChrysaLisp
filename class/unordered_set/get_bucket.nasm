%include 'inc/func.ninc'
%include 'class/class_unordered_set.ninc'
%include 'class/class_vector.ninc'

def_func class/unordered_set/get_bucket
	;inputs
	;r0 = unordered_set object
	;r1 = key object
	;outputs
	;r0 = unordered_set object
	;r1 = bucket vector
	;trashes
	;all but r0, r4

	def_struct local
		ptr local_inst
		ptr local_length
	def_struct_end

	;save inputs
	vp_sub local_size, r4
	set_src r0
	set_dst [r4 + local_inst]
	map_src_to_dst

	;search hash bucket
	vp_cpy [r0 + unordered_set_buckets], r2
	vp_cpy [r2 + vector_length], r2
	vpif r2, !=, 1
		vp_cpy r2, [r4 + local_length]
		v_call obj, hash, {r1}, {r0}
		vp_cpy [r4 + local_length], r1
		vp_xor r2, r2
		vp_div_u r1, r2, r0
		vp_cpy [r4 + local_inst], r0
	else
		vp_xor r2, r2
	endif
	f_call vector, get_element, {[r0 + unordered_set_buckets], r2}, {r1}

	vp_cpy [r4 + local_inst], r0
	vp_add local_size, r4
	vp_ret

def_func_end
