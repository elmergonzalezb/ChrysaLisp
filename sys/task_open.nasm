%include 'inc/func.inc'
%include 'inc/task.inc'

	fn_function sys/task_open, no_debug_enter
		;inputs
		;r0 = new task function name
		;outputs
		;r0, r1 = new task mailbox ID
		;trashes
		;r2-r3, r5-r6

		class_bind task, statics, r1
		vp_cpy [r1 + tk_statics_cpu_id], r1
		class_jmp task, device

	fn_function_end
