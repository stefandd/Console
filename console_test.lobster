import console
import gl

let c:console = console{}
var FPS_counter, FPS_deltas = 0, 0.0
var t0 = gl_time()

c.init("Test1", "data/fonts/PetMe/PetMe.ttf", gl_window_init_no_vsync)

c.writexy(0, 0, "Hello")
c.text_color = xyzw_f{ 1, 1, 0, 1}
c.writexy(0, 0, "Hello\nHello\n\tHello")
c.text_color = xyzw_f{ 1, 0, 0, 1}
c.writexy(10, 10, "Here")
c.text_color = xyzw_f{ 0, 0, 1, 1}
c.writexy(39, 10, "!!")
c.writexy(36, 24, "Hello")
c.gotoxy(10, 10)
c.text_color = xyzw_f{ 0, 1, 0, 1}
c.write("Hereafter")

while c.running:
    c.update()

c.running = true
//c.rnd_screen()
c.gotoxy(10, 10)
c.write("!")
c.clreol()
c.putchar(9, 10, c.getchar(10,10))
c.putchar(11, 10, c.getchar(10,10))

while c.running:
    c.update()

//let teststr = "▁▂▃▄▅▆▇█◣▁♠♣♥♦○●░▒▓█♠♣♥♦○●░▒▓█▁▂▃▄▅▆▇█◣▁"
let teststr = "0123456789012345678901234567890123456789"
c.clr()    
FPS_counter, FPS_deltas = 0, 0.0
c.running = true
while c.running:
    c.gotoxy(0, 0)
    for (25) i:
        c.text_color = xyzw_f{rnd_float(), rnd_float(), rnd_float(), 1}
        //c.background_color = xyzw_f{rnd_float(), rnd_float(), rnd_float(), 1}
        //c.writexy(0, i, teststr)
        c.write(teststr)
        print "debug pos: " + "cylce " + i + ", " + c.cursor_pos_x + ", " + c.cursor_pos_y
        print "debug length: " + c.text_rbuffer.length
    c.update()
    FPS_deltas += gl_delta_time()
    FPS_counter++
    // stats (turn off vsync to measure)
    if gl_time()-t0 > 2: // only every 2 secs
        print "avg. FPS: " + FPS_counter/FPS_deltas
        t0 = gl_time()
        FPS_counter, FPS_deltas = 0, 0.0

c.running = true
while c.running:
    c.rnd_screen()
    c.update()
    FPS_deltas += gl_delta_time()
    FPS_counter++
    // stats (turn off vsync to measure)
    if gl_time()-t0 > 2: // only every 2 secs
        print "avg. FPS: " + FPS_counter/FPS_deltas
        t0 = gl_time()
        FPS_counter, FPS_deltas = 0, 0.0
        /*
        let orig_width, orig_height = c.num_cells_x * c.fontwidth_ + 2 * c.border_x_px_, c.num_cells_y * c.line_height + 2 * c.border_y_px_
        print "---- debug info:"
        print "\t orig: " + orig_width + ", " + orig_height
        print "\t window_xy_: " + c.window_xy_
        print "\t scaling: " + c.scale_x + ", " + c.scale_y
        print "\t rectsize_xy_: " + c.rectsize_xy_
        print "\t fontheight: " + int(c.scale_x * c.fontheight + 0.5)
        print "----"
        */