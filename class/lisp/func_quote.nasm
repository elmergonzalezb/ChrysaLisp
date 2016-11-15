%include 'inc/func.ninc'
%include 'class/class_vector.ninc'
%include 'class/class_error.ninc'
%include 'class/class_lisp.ninc'

def_func class/lisp/func_quote
	;inputs
	;r0 = lisp object
	;r1 = args
	;outputs
	;r0 = lisp object
	;r1 = value

	ptr this, args
	ulong length

	push_scope
	retire {r0, r1}, {this, args}

	devirt_call vector, get_length, {args}, {length}
	vpif {length == 1}
		devirt_call vector, ref_element, {args, 0}, {args}
	else
		func_call error, create, {"(quote arg) wrong numbers of args", args}, {args}
	endif

	expr {this, args}, {r0, r1}
	pop_scope
	return

def_func_end
