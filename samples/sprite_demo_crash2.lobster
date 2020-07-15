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
        float l  = sin( time * 32.f )*.1f + 0.9f; // scan line fading; turned off for now (performance)
        // sample in 3 colour offset
        float r = texture( tex0, vec2( itc.x+o, itc.y+o ) ).x;
        float g = texture( tex0, vec2( itc.x-o, itc.y+o ) ).y;
        float b = texture( tex0, vec2( itc.x  , itc.y-o ) ).z;
        frag_color = vec4(r, g, b, l) * s; // vec4(r, g, b, 1.0) * s; // vec4(r, g, b, l) * s;
"""

// vars for FPS counter
var FPS_counter, FPS_deltas = 0, 0.0
var t0 = 0.0

// console setup
let c:console = console{num_cells_x:40, num_cells_y:40}
c.background_color = xyzw_f{0.2, 0.2, 1.0, 1}
c.init("SpriteTest1", "data/fonts/Px437_IBM/Px437_IBM_BIOS.ttf", gl_window_init_no_vsync)
fatal(gl_load_materials(pixshader, true))

// player and test sprites
let playersprite = sprite{}
playersprite.fromREXPaint("data/textsprites/spaceship.csv")
let ufosprite = sprite{}
ufosprite.fromREXPaint("data/textsprites/ufo.csv")
let ufosprites = map(64): ufosprite.clone() // 128 UFOs
var collisions = 0

// player movement
var last_key_down = gl_time()
def handle_player_motion():
    if gl_time() - last_key_down > 0.03: // limit the player key repeat rate
        if gl_button("right") >= 1:
            playersprite.pos = xy_i{playersprite.pos.x + 1, playersprite.pos.y}
        if gl_button("left") >= 1:
            playersprite.pos = xy_i{playersprite.pos.x - 1, playersprite.pos.y}
        if gl_button("up") >= 1:
            playersprite.pos = xy_i{playersprite.pos.x, playersprite.pos.y - 1}
        if gl_button("down") >= 1:
            playersprite.pos = xy_i{playersprite.pos.x, playersprite.pos.y + 1}
        last_key_down = gl_time()

// main loop
t0 = gl_time()
while c.running:
    let t_now = gl_time()
    post_process(nil, gl_window_size(), "simplecrt", false, texture_format_nomipmap):
        c.clr() 
        for (ufosprites) ufo, i:
            var pos_OK = false
            while not pos_OK:
                ufo.pos = xy_i{rnd(c.num_cells_x + 16) - 8, rnd(c.num_cells_y + 16) - 8}
                if i > 0: // 2nd UFO needs to also account for the 1st etc.
                    let collision_info = map(i) j:
                        ufo.collisiontest(ufosprites[j])
                    pos_OK = not any(collision_info) and not playersprite.collisiontest(ufo)
                else:
                    pos_OK = not playersprite.collisiontest(ufo) // 1st UFO we only check for collision with player
            c.blit(ufo)
        handle_player_motion()
        c.blit(playersprite)
        c.update()
        gl_set_uniform("time", gl_time())
        FPS_deltas += gl_delta_time()
        FPS_counter++
    // stats (turn off vsync to measure)
    if t_now-t0 > 2: // only every 2 secs
        print "avg. FPS: " + FPS_counter/FPS_deltas
        t0 = t_now
        FPS_counter, FPS_deltas = 0, 0.0
