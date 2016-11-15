%include 'inc/func.ninc'
%include 'class/class_stream.ninc'
%include 'class/class_pair.ninc'
%include 'class/class_error.ninc'
%include 'class/class_lisp.ninc'

def_func class/lisp/repl_read_pair
	;inputs
	;r0 = lisp object
	;r1 = stream
	;r2 = next char
	;outputs
	;r0 = lisp object
	;r1 = pair
	;r2 = next char

	const char_space, ' '
	const char_rab, '>'

	ptr this, stream, pair, first, second
	ulong char

	push_scope
	retire {r0, r1, r2}, {this, stream, char}

	;skip "<"
	func_call stream, read_char, {stream}, {char}

	func_call lisp, repl_read, {this, stream, char}, {first, char}
	vpif {first->obj_vtable == @class/class_error}
		assign {first}, {pair}
		goto error
	endif
	func_call lisp, repl_read, {this, stream, char}, {second, char}
	vpif {second->obj_vtable == @class/class_error}
		func_call ref, deref, {first}
		assign {second}, {pair}
		goto error
	endif

	;skip white space
	loop_while {char <= char_space && char != -1}
		func_call stream, read_char, {stream}, {char}
	loop_end

	vpif {char == char_rab}
		func_call stream, read_char, {stream}, {char}
		func_call pair, create, {first, second}, {pair}
	else
		func_call ref, deref, {second}
		func_call ref, deref, {first}
		func_call error, create, {"expected >", this->lisp_sym_nil}, {pair}
	endif
error:
	expr {this, pair, char}, {r0, r1, r2}
	pop_scope
	return

def_func_end
