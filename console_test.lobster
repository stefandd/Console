import console
import gl

let c:console = console{}
var FPS_counter, FPS_deltas = 0, 0.0
var t0 = gl_time()

c.init("Test1", "data/fonts/Square/Square.ttf", gl_window_init_no_vsync)

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
        let orig_width, orig_height = c.num_cells_x * c.fontwidth_ + 2 * c.border_x_px_, c.num_cells_y * c.line_height + 2 * c.border_y_px_
        print "---- debug info:"
        print "\t orig: " + orig_width + ", " + orig_height
        print "\t window_xy_: " + c.window_xy_
        print "\t scaling: " + c.scale_x + ", " + c.scale_y
        print "\t rectsize_xy_: " + c.rectsize_xy_
        print "\t fontheight: " + int(c.scale_x * c.fontheight + 0.5)
        print "----"