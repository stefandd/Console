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
    windows_xy_ = xy_f{0, 0}
    fontwidth_ = 20.0
    line_height_ = 24
    border_x_px_ = 40
    border_y_px_ = 40
    rectsize_xy_ = xy_f{ fontwidth_, line_height_ * fontheight }
    dcell_x_ = xy_f{ fontwidth_, 0 } // single char translation
    dcr_ = xy_f{ -num_cells_x * fontwidth_, line_height_ * fontheight } //  cr translation    
    input_backspace_semaphore_ = false
    time_ = 0
    update_clients_ = []
    do_client_updates_ = false
    
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
                    
    def textdraw_():
        // draw screen characters
        let bufferidx = 0
        for (num_cells_y) y:
            for (num_cells_x) x:
                // background cell
                gl_color(text_c2buffer[bufferidx])
                gl_rect(this.rectsize_xy_)
                // foreground text
                gl_color(text_c1buffer[bufferidx])
                //love.graphics.print(txt_ptr[j], self.scale_x * (self.border_x_px_ + (j - 1) * self.fontwidth), self.scale_y * (self.border_y_px_ + self.line_height * (i - 1)), 0, self.scale_x, self.scale_y)
                gl_text(unicode_to_string([text_rbuffer[y*num_cells_x + x]]))
                gl_translate(this.dcell_x_)
            gl_translate(this.dcr_)
                
    def draw_border_()
        let border_height = scale_y * border_y_px_
        let border_width = scale_x * border_x_px_
        /*
        love.graphics.setColor(self.border_color)
        if border_height > 0:
            love.graphics.rectangle("fill", 0, 0, self.__window_width, border_height)
            love.graphics.rectangle("fill", 0, border_height, border_width, self.__window_height - border_height)
        
        if border_width > 0:
            love.graphics.rectangle("fill", self.__window_width - border_width, border_height, self.__window_width, self.__window_height)
            love.graphics.rectangle("fill", 0, self.__window_height - border_height, self.__window_width - border_width, self.__window_height)
       */
        
    def draw_()
        // clear the window
        gl_set_font_size(fontheight)
        gl_clear(background_color)
        
        if border_show:
            draw_border_()
        //draw__behind()
        //self:draw__sprites_background()
        rescale_()
        textdraw_()
        //self:draw__sprites_foreground()
        //draw__in_front()
            
    def rescale_():
        //windows_xy_ = gl_window_size()
        //let orig_width, orig_height = num_cells_x*fontwidth_ + 2*border_x_px_, num_cells_y*line_height_ + 2*border_y_px_
        //scale_x = window_xy.x / orig_width
        //scale_y = window_xy.y / orig_height
        rectsize_xy_ = xy_f{ fontwidth_, fontheight }
        dcell_x_ = xy_f{ fontwidth_, 0 }
        dcr_ = xy_f{ -num_cells_x * fontwidth_, line_height_ }

    def init(title:string, font_path:string, flags:int): // should add cols, rows, buffersize
        // init window
        fatal(gl_window(title, num_cells_x*fontwidth_ + 2*border_x_px_, num_cells_y*line_height_ + 2*border_y_px_, flags))
        // init font
        fatal(gl_set_font_name(font_path))
        gl_set_font_size(this.fontheight)
        line_height_ = line_spacing * fontheight // * fontobj:getHeight() // line height in pixels
        // recalc frame size in px
        fontwidth_ = gl_text_size(" ").x
        border_x_px_ = border_cells_x * fontwidth_
        border_y_px_ = border_cells_y * fontheight
        // call to resize to refresh canvas
        // TODO
        //__resize()
        // set up text buffer
        clearall()
        // mark setup as successful
        setup_error = false

    def update():
        while gl_frame() and gl_button("escape") != 1:
            draw_()
        else:
            running = false
