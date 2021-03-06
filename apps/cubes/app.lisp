;imports
(import 'apps/math.inc)
(import 'apps/cubes/app.inc)

(structure 'event 0
	(byte 'close 'max 'min)
	(byte 'grid 'plain 'axis))

(defun-bind trans (_)
	;transparent colour
	(+ (logand 0xffffff _) 0x60000000))

(defq canvas_width 600 canvas_height 600 min_width 300 min_height 300
	style_buttons (list) num_verts 100 rate (/ 1000000 60)
	palette (list argb_white argb_red argb_green argb_blue argb_cyan argb_yellow argb_magenta))

(ui-window window ()
	(ui-title-bar _ "Cubes" (0xea19 0xea1b 0xea1a) (const event_close))
	(ui-tool-bar _ ()
		(ui-buttons (0xe9a3 0xe976 0xe9f0) (const event_grid) () style_buttons))
	(ui-scroll image_scroll (logior scroll_flag_vertical scroll_flag_horizontal)
			(min_width canvas_width min_height canvas_height)
		(ui-backdrop backdrop (color argb_black ink_color argb_grey8 style 2)
			(ui-canvas layer1_canvas canvas_width canvas_height 1))))

(defun-bind radio-select (l i)
	;radio select buttons
	(each (lambda (b)
		(def (view-dirty b) 'color (if (= _ i) (const argb_grey14) (const *env_toolbar_col*)))) l) i)

(defun-bind redraw (verts mask)
	;redraw layer/s
	(tuple-set dlist_layer1_verts dlist verts)
	(tuple-set dlist_mask dlist (logior (tuple-get dlist_mask dlist) mask)))

(defun-bind vertex-cloud (num)
	;array of random verts
	(defq out (list))
	(while (> (setq num (dec num)) -1)
		(push out (list
			(vec
				(i2n (- (random (const (* box_size 2))) box_size))
				(i2n (- (random (const (* box_size 2))) box_size))
				(i2n (- (random (const (* box_size 2))) box_size)))
			(vec
				(i2n (- (random (const (inc (* max_vel 2)))) (const max_vel)))
				(i2n (- (random (const (inc (* max_vel 2)))) (const max_vel)))
				(i2n (- (random (const (inc (* max_vel 2)))) (const max_vel))))
			(i2n 50)
			(elem (random (length palette)) palette)))) out)

(defun-bind vertex-update (verts)
	(each (lambda (vert)
		(bind '(p v _ _) vert)
		(vec-add p v p)
		(bind '(x y z) p)
		(bind '(vx vy vz) v)
		(if (or (> x (const (i2n box_size))) (< x (const (i2n (neg box_size)))))
			(setq vx (* vx (const (i2n -1)))))
		(if (or (> y (const (i2n box_size))) (< y (const (i2n (neg box_size)))))
			(setq vy (* vy (const (i2n -1)))))
		(if (or (> z (const (i2n box_size))) (< z (const (i2n (neg box_size)))))
			(setq vz (* vz (const (i2n -1)))))
		(tuple-set vertex_v vert (vec vx vy vz))) verts))

(defun-bind main ()
	;ui tree initial setup
	(defq dlist (list 0 rate layer1_canvas (list)))
	(canvas-set-flags layer1_canvas 1)
	(view-set-size backdrop canvas_width canvas_height)
	(radio-select style_buttons 2)
	(gui-add (apply view-change (cat (list window 256 192) (view-pref-size window))))
	(def image_scroll 'min_width min_width 'min_height min_height)

	;create child and send args
	(mail-send dlist (defq child_mbox (open-child "apps/cubes/child.lisp" kn_call_open)))

	;random cloud of verts
	(defq verts (vertex-cloud num_verts))
	(redraw verts 1)

	;main event loop
	(defq last_state 'u last_point nil last_mid_point nil id t)
	(while id (while (mail-poll (array (task-mailbox))) (cond
		((= (setq id (get-long (defq msg (mail-read (task-mailbox))) (const ev_msg_target_id))) (const event_close))
			;close button
			(setq id nil))
		((= id (const event_min))
			;min button
			(apply view-change-dirty (cat (list window) (view-get-pos window) (view-pref-size window))))
		((= id (const event_max))
			;max button
			(def image_scroll 'min_width canvas_width 'min_height canvas_height)
			(apply view-change-dirty (cat (list window) (view-get-pos window) (view-pref-size window)))
			(def image_scroll 'min_width min_width 'min_height min_height))
		((<= (const event_grid) id (const event_axis))
			;styles
			(def (view-dirty backdrop) 'style (radio-select style_buttons (- id (const event_grid)))))
		((= id (component-get-id layer1_canvas))
			;event for canvas
			(when (= (get-long msg (const ev_msg_type)) (const ev_type_mouse))
				;mouse event in canvas
				(defq new_point (path (i2f (get-int msg (const ev_msg_mouse_rx)))
					(i2f (get-int msg (const ev_msg_mouse_ry)))))
				(cond
					((/= (get-int msg (const ev_msg_mouse_buttons)) 0)
						;mouse button is down
						(case last_state
							(d	;was down last time
								)
							(u	;was up last time
								(setq last_state 'd last_point new_point
									verts (vertex-cloud num_verts)))))
					(t	;mouse button is up
						(case last_state
							(d	;was down last time
								(setq last_state 'u))
							(u	;was up last time, so we are hovering
								t))))))
		(t (view-event window msg))))
		(vertex-update verts)
		(redraw verts 1)
		(task-sleep rate))
	;close child and window
	(mail-send "" child_mbox)
	(view-hide window))
