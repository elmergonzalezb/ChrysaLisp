%include 'inc/func.ninc'
%include 'inc/mail.ninc'

def_func sys/mail_out
	;parcels going off chip task

	loop_start
		;read parcel
		f_call sys_mail, mymail, {}, {r15}

		;create next parcel id
		f_call sys_cpu, id, {}, {r6}
		f_bind sys_mail, statics, r1
		vp_cpy [r1 + ml_statics_parcel_id], r7
		vp_inc r7
		vp_cpy r7, [r1 + ml_statics_parcel_id]

		;header info for each fragment
		vp_cpy msg_data, r10
		vp_cpy [r15 + msg_length], r11
		vp_cpy [r15 + msg_dest + id_mbox], r12
		vp_cpy [r15 + msg_dest + id_cpu], r13
		loop_start
			;create fragment
			f_call sys_mail, alloc, {}, {r14}
			assert r0, !=, 0

			;fill in fragment header
			vp_cpy r12, [r14 + msg_dest + id_mbox]
			vp_cpy r13, [r14 + msg_dest + id_cpu]
			vp_cpy r10, [r14 + msg_parcel_frag]
			vp_cpy r11, [r14 + msg_parcel_size]
			vp_cpy r6, [r14 + msg_parcel_id + id_mbox]
			vp_cpy r7, [r14 + msg_parcel_id + id_cpu]

			;data source and destination
			vp_lea [r15 + r10], r0
			vp_lea [r14 + msg_data], r1

			;length of fragment data
			vp_cpy msg_size - msg_data, r2
			vp_add r2, r10
			vpif r10, >, r11
				vp_sub r11, r10
				vp_sub r10, r2
				vp_cpy r11, r10
			endif
			vp_lea [r2 + msg_data], r3
			vp_cpy r3, [r14 + msg_length]

			;copy data block, round up for speed
			vp_add ptr_size - 1, r2
			vp_and -ptr_size, r2
			f_call sys_mem, copy, {r0, r1, r2}, {_, _}

			;queue it on the outgoing packet list
			f_bind sys_mail, statics, r0
			vp_lea [r0 + ml_statics_offchip_list], r0
			lh_add_at_tail r0, r14, r1

			;let links get at some packets
			f_call sys_task, yield
		loop_until r10, ==, r11

		;free parcel
		f_call sys_mem, free, {r15}
	loop_end
	vp_ret

def_func_end
