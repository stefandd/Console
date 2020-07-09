import std
import gl

def string_find(s:string, pat:string) -> int: // slow brute force
    //let a:int, b:int = 1, 2
    //let N:int, M:int = s.length, pat.length
    let N:int = s.length
    let M:int = pat.length
    for (N - M + 1) i:
        for (M) j:
            if substring(s, i+j, 1) != substring(pat, j, 1): // no match -> abort
                break
            elif j == M - 1: // still matching at last loop cycle? -> match
                return i // return position
    return -1 // no match

def string_replace(s:string, search:string, replace:string) -> string:
    // recursive solution
    let slen = s.length
    let srchlen = search.length
    for (slen - srchlen + 1) i:
        if substring(s, i, srchlen) == search:
            if i == 0:
                return replace + string_replace(substring(s, srchlen, -1), search, replace)
            else:
                return substring(s, 0, i) + replace + string_replace(substring(s, i + srchlen, -1), search, replace)
    return s

class console:
    running = false
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
    tab_num_spaces:int = 4
    tab_stops:[int] = [1, 11, 21, 31]
    ulc_buffer_idx:int = 0
    text_rbuffer:[int] = []
    text_c1buffer:[xyzw_f] = []
    text_c2buffer:[xyzw_f] = []
    cursor_char = "_"   
    cursor_blink_time:float = 0.5
    cursor_pos_x:int = 1
    cursor_pos_y:int = 1
    autoscroll = true
    wait_for_keypress = false
    input_mode_on = false
    input_text = ""
    last_key_pressed = ""
    key_is_down = false
    input_start_lpointer:int = 1
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
    ignore_arg_err_ = false

    //------------------ class internal functions
    
    def error_(msg):
            print msg // nothing else for now
                    
    def textdraw_():
        // draw screen characters
        var bufferidx = ulc_buffer_idx
        gl_translate(xy_f{border_x_px_, border_y_px_})
        for (num_cells_y):
            for (num_cells_x):
                let curr_chr = text_rbuffer[bufferidx]
                // background cell
                gl_color(text_c2buffer[bufferidx])
                gl_rect(rectsize_xy_)
                if curr_chr != 32: // speed boost in sparse texts
                    // foreground text
                    gl_color(text_c1buffer[bufferidx])
                    gl_text(unicode_to_string([curr_chr]))
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

    def check_col_row_(col, row):
        if ignore_arg_err_ or (col >= 0 and col < num_cells_x and row >= 0 and row < num_cells_y):
            return true
        else:
            error_("Illegal x, y operands: " + col + ", " + row)
            return false

    //------------------ print functions

    def printxy_print_(col:int, row:int, s:string): // operands of col row must be checked before this is called; should also not call on empty strings
        var p1_text_rbuffer:[int] = []
        var p1_text_c1buffer:[xyzw_f] = []
        var p1_text_c2buffer:[xyzw_f] = []
        let p2_text_rbuffer:[int] = []
        let p2_text_c1buffer:[xyzw_f] = []
        let p2_text_c2buffer:[xyzw_f] = []        
        let n_text_rbuffer:[int] = []
        let n_text_c1buffer:[xyzw_f] = []
        let n_text_c2buffer:[xyzw_f] = []
        let insertpos_buffer_idx = ulc_buffer_idx + col + num_cells_x * row
        var curr_col, curr_row = col, row
        var add_chr, add_chr_tot = 0, 0
        let chr_vec = string_to_unicode(s)
        if chr_vec:
            if insertpos_buffer_idx > 0: // first save the buffer objects before the cursor position
                p1_text_rbuffer = slice(text_rbuffer, 0, insertpos_buffer_idx)
                p1_text_c1buffer = slice(text_c1buffer, 0, insertpos_buffer_idx)
                p1_text_c2buffer = slice(text_c2buffer, 0, insertpos_buffer_idx)
            for (chr_vec) chr:
                // filter special characters
                add_chr = 0
                if chr == 9: // \t
                    for (tab_num_spaces):
                        n_text_rbuffer.push(32)
                        n_text_c1buffer.push(text_color)
                        n_text_c2buffer.push(background_color)
                    add_chr += tab_num_spaces
                elif chr == 10: // \n
                    for (num_cells_x - curr_col):
                        n_text_rbuffer.push(32)
                        n_text_c1buffer.push(text_color)
                        n_text_c2buffer.push(background_color)
                    add_chr += num_cells_x - curr_col
                elif chr == 13: // \r
                    pass() // ignore
                else:
                    n_text_rbuffer.push(chr)
                    n_text_c1buffer.push(text_color)
                    n_text_c2buffer.push(background_color)
                    add_chr++
                // advance cursor position
                if curr_col + add_chr < num_cells_x:
                    curr_col += add_chr
                else:
                    curr_col = 0
                    curr_row++
                add_chr_tot += add_chr
            // additional spaces for any newly started row to prefill the buffer full rows
            if curr_row > row:
                    for (num_cells_x - curr_col):
                        n_text_rbuffer.push(32)
                        n_text_c1buffer.push(text_color)
                        n_text_c2buffer.push(background_color)
                    add_chr_tot += num_cells_x - curr_col
            // the asserts are bug test
            if curr_row != row:
                assert (col + num_cells_x * row + add_chr_tot) % num_cells_x == 0
                assert (insertpos_buffer_idx + add_chr_tot) % num_cells_x == 0            
            // decide how to modify the class buffers
            assert n_text_rbuffer.length == add_chr_tot
            if insertpos_buffer_idx > 0:
                if insertpos_buffer_idx + add_chr_tot >= text_rbuffer.length: // can we just overwrite the current buffers with the new text?
                    text_rbuffer = append(p1_text_rbuffer, n_text_rbuffer)
                    text_c1buffer = append(p1_text_c1buffer, n_text_c1buffer)
                    text_c2buffer = append(p1_text_c2buffer, n_text_c2buffer)
                else:
                    text_rbuffer = append(p1_text_rbuffer, append(n_text_rbuffer, slice(text_rbuffer, insertpos_buffer_idx + add_chr_tot, -1)))
                    text_c1buffer = append(p1_text_c1buffer, append(n_text_c1buffer, slice(text_c1buffer, insertpos_buffer_idx + add_chr_tot, -1)))
                    text_c2buffer = append(p1_text_c2buffer, append(n_text_c2buffer, slice(text_c2buffer, insertpos_buffer_idx + add_chr_tot, -1)))
            else:
                if insertpos_buffer_idx + add_chr_tot >= text_rbuffer.length: // can we just overwrite the current buffers with the new text?
                    text_rbuffer = n_text_rbuffer
                    text_c1buffer = n_text_c1buffer
                    text_c2buffer = n_text_c2buffer
                else:
                    text_rbuffer = append(n_text_rbuffer, slice(text_rbuffer, add_chr_tot, -1))
                    text_c1buffer = append(n_text_c1buffer, slice(text_c1buffer, add_chr_tot, -1))
                    text_c2buffer = append(n_text_c2buffer, slice(text_c2buffer, add_chr_tot, -1))
            // update cursor position
            if (insertpos_buffer_idx + add_chr_tot >= text_rbuffer.length) and autoscroll: // can we just overwrite the current buffers with the new text?
                ulc_buffer_idx = insertpos_buffer_idx + add_chr_tot - num_cells_x * num_cells_y
                cursor_pos_x, cursor_pos_y = curr_col, num_cells_y - 1
            else:
                cursor_pos_x, cursor_pos_y = curr_col, curr_row
            // more tests
            assert text_rbuffer.length % num_cells_x == 0
            assert text_rbuffer.length == text_c1buffer.length and text_rbuffer.length == text_c2buffer.length
            return true
        else:
            return false

    def writexy(col:int, row:int, s:string): // operands of col row must be checked before this is called; should also not call on empty strings
        if not check_col_row_(col, row): return
        printxy_print_(col, row, s)
        //print "Debug pos after writexy: " + cursor_pos_x + ", " + cursor_pos_y
        
    def write(s:string): // operands of col row must be checked before this is called; should also not call on empty strings
        printxy_print_(cursor_pos_x, cursor_pos_y, s)
        //print "Calling writexy(" + cursor_pos_x + ", " + cursor_pos_y + ", " + "..)"
        //writexy(cursor_pos_x, cursor_pos_y, s)
        //print "Debug pos after write: " + cursor_pos_x + ", " + cursor_pos_y
        
    def writeln(s:string): // operands of col row must be checked before this is called; should also not call on empty strings
        printxy_print_(cursor_pos_x, cursor_pos_y, s + "\n")
        //print "Debug pos after writeln: " + cursor_pos_x + ", " + cursor_pos_y
        
    def gotoxy(col:int, row:int):
        if not check_col_row_(col, row): return
        cursor_pos_x, cursor_pos_y = col, row

    def wherexy():
        return cursor_pos_x, cursor_pos_y

    def clreol():
        let base_idx = ulc_buffer_idx + cursor_pos_x + num_cells_x * cursor_pos_y
        for (num_cells_x - cursor_pos_x) i:
            text_rbuffer[base_idx + i] = 32
            text_c1buffer[base_idx + i] = text_color
            text_c2buffer[base_idx + i] = background_color

    def clr():
        let num_cells = num_cells_x*num_cells_y
        text_c1buffer = map(num_cells): text_color
        text_c2buffer = map(num_cells): background_color
        text_rbuffer = map(num_cells): 32
        ulc_buffer_idx = 0
        cursor_pos_x, cursor_pos_y = 0, 0
        
    def rnd_screen():
        let num_cells = num_cells_x*num_cells_y
        text_c1buffer = map(num_cells): xyzw_f{rnd_float(), rnd_float(), rnd_float(), 1.0}
        text_c2buffer = map(num_cells): xyzw_f{rnd_float(), rnd_float(), rnd_float(), 1.0}
        text_rbuffer = map(num_cells):  32 + rnd(64)
        ulc_buffer_idx = 0
        cursor_pos_x, cursor_pos_y = 0, 0

    def putchar(col:int, row:int, c:int):
        if not check_col_row_(col, row): return
        text_rbuffer[ulc_buffer_idx + col + num_cells_x * row] = c

    def getchar(col:int, row:int) -> int:
        if not check_col_row_(col, row): return
        return text_rbuffer[ulc_buffer_idx + col + num_cells_x * row]

    //------------------ management functions

    def init(title:string, font_path:string, flags:int): // should add cols, rows, buffersize
        // init window
        border_x_px_ = border_cells_x * fontwidth_
        border_y_px_ = border_cells_y * fontheight
        let init_xs, init_ys = num_cells_x * fontwidth_ + 2 * border_x_px_, num_cells_y * line_height + 2 * border_y_px_
        fatal(gl_window(title, init_xs, init_ys, flags))
        // init font
        check(gl_set_font_name(font_path), "can\'t load font!")
        gl_set_font_size(fontheight)
        // recalc frame size in px
        fontwidth_ = gl_text_size(" ").x
        clr() // create empty buffer objects of size num_cells_x * num_cells_y
        running = true

    def sleep(t):
        let t0 = gl_time()
        while gl_frame() and gl_time() -  t0 < t:
            draw_()

    def update():
        if gl_frame() and gl_button("escape") != 1:
            running = true
            draw_()
        else:
            running = false

