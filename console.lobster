import std
import gl

class console:
    fontheight:int = 20
    line_height:int = 20
    num_cells_x:int = 40
    num_cells_y:int = 25
    border_cells_x:int = 3
    border_cells_y:int = 2
    scale_x:float = 1.0
    scale_y:float = 1.0
    border_color = xyzw_f{0.3, 0.3, 0.3, 1.0}
    border_show = false
    text_color = xyzw_f{0.0, 0.0, 0.0, 1.0}
    background_color = xyzw_f{0.2, 0.2, 1.0, 1.0}
    autoscroll = true
    tab_num_spaces:int = 4
    tab_stops:[int] = [1, 11, 21, 31]
    text_rbuffer_pagenum:int = 1
    screen_row_idx:int = 0
    text_rbuffer:[int] = []
    text_c1buffer:[xyzw_f] = []
    text_c2buffer:[xyzw_f] = []
    cursor_char = "_"   
    cursor_blink_time:float = 0.5
    cursor_pos_x:int = 1
    cursor_pos_y:int = 1
    wait_for_keypress = false
    input_mode_on = false
    input_text = ""
    last_key_pressed = ""
    key_is_down = false
    input_start_lpointer:int = 1
    running = true
    window_xy_ = xy_i{0, 0}
    fontwidth_:int = 20
    border_x_px_:int = 40
    border_y_px_:int = 40
    rectsize_xy_ = xy_f{0, 0}
    dcell_x_ = xy_f{0, 0} // single char translation
    dcr_ = xy_f{0, 0} //  cr translation    
    input_backspace_semaphore_ = false
    time_:float = 0.0
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
        let num_cells = num_cells_x*num_cells_y
        text_c1buffer = map(num_cells):
                            xyzw_f{rnd_float(), rnd_float(), rnd_float(), 1.0}
        text_c2buffer = map(num_cells):
                            xyzw_f{rnd_float(), rnd_float(), rnd_float(), 1.0}
        text_rbuffer = map(num_cells):
                        48 + rnd(75)
                    
    def textdraw_():
        // draw screen characters
        var bufferidx = 0
        gl_translate(xy_f{border_x_px_, border_y_px_})
        for (num_cells_y) y:
            let idx_ = (y + screen_row_idx) * num_cells_x
            for (num_cells_x) x:
                // background cell
                gl_color(text_c2buffer[bufferidx])
                gl_rect(this.rectsize_xy_)
                // foreground text
                gl_color(text_c1buffer[bufferidx])
                //love.graphics.print(txt_ptr[j], self.scale_x * (self.border_x_px_ + (j - 1) * self.fontwidth), self.scale_y * (self.border_y_px_ + self.line_height * (i - 1)), 0, self.scale_x, self.scale_y)
                gl_text(unicode_to_string([text_rbuffer[idx_ + x]]))
                gl_translate(dcell_x_)
                bufferidx++
            gl_translate(dcr_)
                
    def draw_border_():
        let border_height = scale_y * border_y_px_
        let border_width = scale_x * border_x_px_
        pass()
        /*
        love.graphics.setColor(self.border_color)
        if border_height > 0:
            love.graphics.rectangle("fill", 0, 0, self.__window_width, border_height)
            love.graphics.rectangle("fill", 0, border_height, border_width, self.__window_height - border_height)
        
        if border_width > 0:
            love.graphics.rectangle("fill", self.__window_width - border_width, border_height, self.__window_width, self.__window_height)
            love.graphics.rectangle("fill", 0, self.__window_height - border_height, self.__window_width - border_width, self.__window_height)
       */
        
    def draw_():
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
        window_xy_ = gl_window_size()
        let orig_width, orig_height = num_cells_x * fontwidth_ + 2 * border_x_px_, num_cells_y * line_height + 2 * border_y_px_
        scale_x = float(window_xy_.x) / orig_width
        scale_y = float(window_xy_.y) / orig_height
        if scale_x < scale_y: scale_y = scale_x
        elif scale_x > scale_y: scale_x = scale_y
        rectsize_xy_ = xy_f{ scale_x * fontwidth_, scale_y * line_height }
        dcell_x_ = xy_f{ scale_x * fontwidth_, 0 }
        dcr_ = xy_f{ -num_cells_x * scale_x * fontwidth_, scale_y * line_height }
        border_x_px_ = int(scale_x * border_cells_x * fontwidth_)
        border_y_px_ = int(scale_y * border_cells_y * fontheight)
        gl_set_font_size(int(scale_y * fontheight + 0.5))

    def init(title:string, font_path:string, flags:int): // should add cols, rows, buffersize
        // init window
        border_x_px_ = border_cells_x * fontwidth_
        border_y_px_ = border_cells_y * fontheight
        let init_xs, init_ys = num_cells_x * fontwidth_ + 2 * border_x_px_, num_cells_y * line_height + 2 * border_y_px_
        print "Init debug: "
        print "\t" + init_xs + ", " + init_ys
        fatal(gl_window(title, init_xs, init_ys, flags))
        // init font
        check(gl_set_font_name(font_path), "can\'t load font!")
        gl_set_font_size(fontheight)
        // recalc frame size in px
        fontwidth_ = gl_text_size(" ").x
        // set up text buffer
        clearall()

    def update():
        if gl_frame() and gl_button("escape") != 1:
            running = true
            draw_()
        else:
            running = false
