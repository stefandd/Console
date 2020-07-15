import console  
import texture


// crt shader
let pixshader =
"""
SHADER simplecrt // Shader based on https://the8bitpimp.wordpress.com/2014/07/17/retro-crt-shader/
    VERTEX
        INPUTS apos:4 atc:2
        UNIFORMS mvp
        gl_Position = mvp * apos;
        itc = atc;
    PIXEL
        INPUTS itc:2
        UNIFORMS tex0
        UNIFORM float time
        float f  = sin( itc.y * 320.f * 3.14f ); // per row offset
        float o  = f * (0.35f / 320.f); // scale to per pixel
        float s  = f * .03f + 0.97f; // scale for subtle effect
        //float l  = sin(time * 32.0f)*.1f + 0.9f; // scan line fading; turned off for now (performance)
        // sample in 3 colour offset
        float r = texture( tex0, vec2( itc.x+o, itc.y+o ) ).x;
        float g = texture( tex0, vec2( itc.x-o, itc.y+o ) ).y;
        float b = texture( tex0, vec2( itc.x  , itc.y-o ) ).z;
        frag_color = vec4(r, g, b, 1.0) * s; // vec4(r, g, b, l) * s;
"""

var FPS_counter, FPS_deltas, FPS_avg = 0, 0.0, 0.0
var t0 = 0.0
let c:console = console{border_show : true}

c.init("Test1", "data/fonts/PetMe/PetMe.ttf", gl_window_init_no_vsync)
fatal(gl_load_materials(pixshader, true))
c.text_color = xyzw_f{1, 1, 1, 1}

t0 = gl_time()
set_print_decimals(2)
while c.running:
    let t_now = gl_time()
    post_process(nil, gl_window_size(), "simplecrt", false, texture_format_nomipmap):
        //gl_set_uniform("time", t_now)
        c.rnd_screen(2)
        FPS_deltas += gl_delta_time()
        FPS_counter++
        // stats (turn off vsync to measure)
        if t_now - t0 > 1: // only every 2 secs
            FPS_avg = FPS_counter/FPS_deltas
            FPS_counter, FPS_deltas = 0, 0.0
            t0 = t_now
        
        c.writexy(0, 0, "avg. FPS: " + FPS_avg, 1)
        c.update()
