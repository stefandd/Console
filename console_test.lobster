import console
import gl

let c:console = console{}
var FPS_counter, FPS_deltas = 0, 0.0
var t0 = gl_time()

let t:region = region{}
t.fromREXPaint("data/textsprites/spaceship.csv")

c.init("Test1", "data/fonts/PetMe/PetMe.ttf", gl_window_init_no_vsync)
//c.init("Test1", "data/fonts/Px437_IBM/Px437_IBM_BIOS.ttf", gl_window_init_no_vsync)

// part I

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

t0 = gl_time()
while c.running:
    c.update()
    FPS_deltas += gl_delta_time()
    FPS_counter++
    // stats (turn off vsync to measure)
    if gl_time()-t0 > 2: // only every 2 secs
        print "avg. FPS: " + FPS_counter/FPS_deltas
        t0 = gl_time()
        FPS_counter, FPS_deltas = 0, 0.0

c.running = true
//c.rnd_screen()
c.gotoxy(10, 10)
c.write("!")
c.clreol()
c.putchar(9, 10, c.getchar(10,10))
c.putchar(11, 10, c.getchar(10,10))

t0 = gl_time()
while c.running:
    c.update()

var tcopy:[int], c1copy:[xyzw_f], c2copy:[xyzw_f] = [], [], []
tcopy = c.text_rbuffer.copy()
c1copy = c.text_c1buffer.copy()
c2copy = c.text_c2buffer.copy()
let ulccopy = c.ulc_buffer_idx

// part II

let teststr = "▁▂▃▄▅▆▇█◣▁♠♣♥♦○●░▒▓█♠♣♥♦○●░▒▓█▁▂▃▄▅▆▇█◣▁"
//let teststr = "0123456789012345678901234567890123456789"
c.clr()    
FPS_counter, FPS_deltas = 0, 0.0
c.running = true
c.autoscroll = false
t0 = gl_time()
while c.running:    
    for (25) i:
        c.text_color = xyzw_f{rnd_float(), rnd_float(), rnd_float(), 1}
        //c.background_color = xyzw_f{rnd_float(), rnd_float(), rnd_float(), 1}
        c.writexy(0, i, teststr)
    c.update()
    FPS_deltas += gl_delta_time()
    FPS_counter++
    // stats (turn off vsync to measure)
    if gl_time()-t0 > 2: // only every 2 secs
        print "avg. FPS: " + FPS_counter/FPS_deltas
        t0 = gl_time()
        FPS_counter, FPS_deltas = 0, 0.0
        print "debug buffer length: " + c.text_rbuffer.length
let screencopy = c.getscreen() // c.getscreenregion(0, 0, c.num_cells_x - 1, c.num_cells_y - 1)
if !screencopy:
    return

// part III

c.running = true
c.text_color = xyzw_f{ 1, 1, 1, 1}
t0 = gl_time()
while c.running:
    //c.rnd_screen()
    // simulate some activity
    if gl_button("space") >= 1:
    // screen copy by using preset buffers
            c.text_rbuffer = tcopy.copy()
            c.text_c1buffer = c1copy.copy()
            c.text_c2buffer = c2copy.copy()
            c.ulc_buffer_idx = ulccopy // must also restore the index pointer to the buffer position of the screen ulc.
    elif gl_button("s") >= 1:
            c.blit(screencopy, 0, 0)
    elif gl_button("r") >= 1:
        c.rnd_screen()    
    else:
        c.clr()
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