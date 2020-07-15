import texture
import vec

let width, height = 320, 200
let screen:[[xyzw_f]] = init_screen() // Works, but why? there is no return type, not even on the first use of screen in init_screen ???
//let screen:[[xyzw_f]] = vector_reserve(typeof [[xyzw_f]], width*height) // Works
//let screen:[[xyzw_f]] = vector_reserve(typeof [xyzw_f], width*height) // CRASHES! on typo with single []

def init_screen():
    // init screen texture vector
    return map(height):
                map(width):
                    xyzw { 0.0, 0.0, 0.0, 1.0 }

def randomize_texture():
    // randomize screen texture vector
    for (height) y:
        for (width) x:
            screen[y][x] = xyzw { rnd_float(), rnd_float(), rnd_float(), 1.0 }

//
// main
//
var t0 = 0.0
var FPS_counter, FPS_deltas, FPS_avg = 0, 0.0, 0.0

fatal(gl_window("Lobster texture pixel access", width, height))

while gl_frame():
    randomize_texture() // random pixel colors
    gl_clear(color_black)
    gl_set_primitive_texture(0, gl_create_texture(screen))
    gl_set_shader("textured")
    gl_color(color_white)
    gl_translate(float(gl_window_size())/2)
    gl_scale(float(gl_window_size())/2)
    gl_rect(xy_1, 1)
    FPS_deltas += gl_delta_time()
    FPS_counter++
    // stats (turn off vsync to measure)
    let t_now = gl_time()
    if t_now - t0 > 1: // only every 2 secs
        FPS_avg = FPS_counter/FPS_deltas
        print FPS_avg
        FPS_counter, FPS_deltas = 0, 0.0
        t0 = t_now