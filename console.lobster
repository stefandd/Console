class console:
    fontheight = 20.0
    line_spacing = 1.0
    line_height = 20
    num_cells_x = 40
    num_cells_y = 25
    border_cells_x = 3
    border_cells_y = 2
    scale_x = 1
    scale_y = 1
    border_color = xyz_f{0.3, 0.3, 0.3}
    border_show = false
    text_color = xyz_f{0, 0, 0}
    background_color = xyz_f{0.2, 0.2, 0.2}
    autoscroll = true
    tab_num_spaces = 4
    tab_stops = [1, 11, 21, 31]
    text_rbuffer_pagenum = 1
    screen_row_idx = 1
    text_rbuffer:[int] = []
    text_c1buffer:[xyz_f] = []
    text_c2buffer:[xyz_f] = []
    cursor_char = "_"
    cursor_blink_time = 0.5
    cursor_pos_x = 1
    cursor_pos_y = 1
    wait_for_keypress = false
    input_mode_on = false
    input_text = ""
    last_key_pressed = ""
    key_is_down = false
    input_start_lpointer = 1
    setup_error = true
    running = true
    __window_xy = xy_f{0, 0}
    __fontwidth = 20.0
    __line_height = 24
    __border_x_px = 40
    __border_y_px = 40
    __rectsize_xy = []
    __rectsize_xy = xy_f{ __fontwidth, __line_height * fontheight }
    //__dcell_x = xy_f{ __fontwidth, 0 } // single char translation
    //__dcr = xy_f{ -num_cells_x * __fontwidth, __line_height * fontheight } //  cr translation
    __input_backspace_semaphore = false
    __time = 0
    __update_clients = []
    __do_client_updates = false
    
    def clearall():
        let num_cells = num_cells_x*num_cells_y
        text_c1buffer = map(num_cells):
                                text_color
        text_c2buffer = map(num_cells):
                                background_color
        text_rbuffer = map(num_cells):
                                32

    def rnd_screen():
        return map(num_cells_x*num_cells_y):
                    48 + rnd(75)
                    
    def __textdraw():
        // draw screen characters
        let bufferidx = 0
        for (num_cells_y) y:
            for (num_cells_x) x:
                // background cell
                gl_color(text_c2buffer[bufferidx])
                gl_rect(this.__rectsize_xy)
                // foreground text
                gl_color(text_c1buffer[bufferidx])
                //love.graphics.print(txt_ptr[j], self.scale_x * (self.__border_x_px + (j - 1) * self.fontwidth), self.scale_y * (self.__border_y_px + self.line_height * (i - 1)), 0, self.scale_x, self.scale_y)
                gl_text(unicode_to_string([text_rbuffer[y*num_cells_x + x]]))
                gl_translate(this.__dcell_x)
            gl_translate(this.__dcr)
                
    def __draw_border()
        let border_height = scale_y * __border_y_px
        let border_width = scale_x * __border_x_px
        /*
        love.graphics.setColor(self.border_color)
        if border_height > 0:
            love.graphics.rectangle("fill", 0, 0, self.__window_width, border_height)
            love.graphics.rectangle("fill", 0, border_height, border_width, self.__window_height - border_height)
        
        if border_width > 0:
            love.graphics.rectangle("fill", self.__window_width - border_width, border_height, self.__window_width, self.__window_height)
            love.graphics.rectangle("fill", 0, self.__window_height - border_height, self.__window_width - border_width, self.__window_height)
       */
        
    def __draw()
        // clear the window
        gl_set_font_size(fontheight)
        gl_clear(background_color)
        
        if border_show:
            __draw_border()
        //__draw_behind()
        //self:__draw_sprites_background()
        __rescale()
        __textdraw()
        //self:__draw_sprites_foreground()
        //__draw_in_front()
            
    def __rescale():
        //__window_xy = gl_window_size()
        //let orig_width, orig_height = num_cells_x*__fontwidth + 2*__border_x_px, num_cells_y*__line_height + 2*__border_y_px
        //scale_x = window_xy.x / orig_width
        //scale_y = window_xy.y / orig_height
        __rectsize_xy = xy_f{ __fontwidth, fontheight }
        __dcell_x = xy_f{ __fontwidth, 0 }
        __dcr = xy_f{ -num_cells_x * __fontwidth, __line_height }

    def init(title:string, font_path:string, flags:int): // should add cols, rows, buffersize
        // init window
        fatal(gl_window(title, num_cells_x*__fontwidth + 2*__border_x_px, num_cells_y*__line_height + 2*__border_y_px, flags))
        // init font
        fatal(gl_set_font_name(font_path))
        gl_set_font_size(this.fontheight)
        __line_height = line_spacing * fontheight // * fontobj:getHeight() // line height in pixels
        // recalc frame size in px
        __fontwidth = gl_text_size(" ").x
        __border_x_px = border_cells_x * __fontwidth
        __border_y_px = border_cells_y * fontheight
        // call to resize to refresh canvas
        // TODO
        //__resize()
        // set up text buffer
        clearall()
        // mark setup as successful
        setup_error = false

    def update():
        while gl_frame() and gl_button("escape") != 1:
            __draw()
        else:
            running = false
