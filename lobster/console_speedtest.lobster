import console2
import texture

var FPS_counter, FPS_deltas, FPS_avg = 0, 0.0, 0.0
var t0 = 0.0
let c:console = console{border_show : true}

c.init("Test1", "data/fonts/PetMe/PetMe.ttf", gl_window_init_no_vsync)
c.text_color = color_white
t0 = gl_time()
set_print_decimals(2)

var blitmode = 2
var dirchg = -1
c.run():
    let t_now = gl_time()
    c.clr()
    c.rnd_screen(blitmode)
    if gl_button("space") == 1:
        if blitmode == 2:
            dirchg = -1
        elif blitmode == 0:
            dirchg = 1
        blitmode += dirchg
    c.writexy(0, 0, "avg. FPS: " + FPS_avg, 1)
    FPS_deltas += gl_delta_time()
    FPS_counter++
    // stats (turn off vsync to measure)
    if t_now - t0 > 1: // only every 2 secs
        FPS_avg = FPS_counter/FPS_deltas
        FPS_counter, FPS_deltas = 0, 0.0
        t0 = t_now
    
