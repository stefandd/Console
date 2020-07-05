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
