%include 'inc/func.ninc'
%include 'class/class_vector.ninc'
%include 'class/class_stream.ninc'
%include 'class/class_error.ninc'
%include 'class/class_lisp.ninc'

def_func class/lisp/func_macroexpand
	;inputs
	;r0 = lisp object
	;r1 = args
	;outputs
	;r0 = lisp object
	;r1 = value

	ptr this, args, value
	ulong length

	push_scope
	retire {r0, r1}, {this, args}

	devirt_call vector, get_length, {args}, {length}
	vpif (length == 1)
		func_call lisp, func_copy, {this, args}, {value}
		loop_start
			func_call lisp, repl_expand, {this, &value}, {length}
		loop_until {length}
	else
		func_call error, create, {"(macroexpand form) wrong number of args", args}, {value}
	endif

	expr {this, value}, {r0, r1}
	pop_scope
	return

def_func_end
