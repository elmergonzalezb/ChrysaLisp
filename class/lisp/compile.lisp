;;;;;;;;;;;;;;;;;;;;
; VP Assembler Child
;;;;;;;;;;;;;;;;;;;;

;imports
(import 'sys/lisp.inc)
(import 'class/lisp.inc)

;read args from parent
(bind '((*files* *abi* *cpu* mbox debug_mode debug_emit debug_inst) _)
	(read (string-stream (mail-read (task-mailbox))) (const (ascii-code " "))))

;set up reply stream
(defq msg_out (msg-out-stream mbox))

;redirect print to my msg_out
(defun-bind print (&rest args)
	(push args (const (ascii-char 10)))
	(write msg_out (apply str args)))

;catch any errors
(catch
	;compile the file list
	(within-compile-env (lambda ()
		(each! 0 -1 include (list *files*))))
	(progn (print _) t))

;close data out stream
(stream-flush msg_out)
(msg-out-set-state msg_out stream_mail_state_stopped)
(print "")
(stream-flush msg_out)