import console  
import texture


let c:console = console{}
var FPS_counter, FPS_deltas = 0, 0.0
var t0 = gl_time()

let mats =
"""
SHADER simplecrt
    VERTEX
        INPUTS apos:4 atc:2
        UNIFORMS mvp
        gl_Position = mvp * apos;
        itc = atc;
    PIXEL
        INPUTS itc:2
        UNIFORMS tex0 framebuffer_size
        //UNIFORM float time
        float f  = sin( itc.y * 320.f * 3.14f ); // per row offset
        float o  = f * (0.35f / 320.f); // scale to per pixel
        float s  = f * .03f + 0.97f; // scale for subtle effect
        //float l  = sin( time * 32.f )*.03f + 0.97f; // scan line fading
        // sample in 3 colour offset
        float r = texture( tex0, vec2( itc.x+o, itc.y+o ) ).x;
        float g = texture( tex0, vec2( itc.x-o, itc.y+o ) ).y;
        float b = texture( tex0, vec2( itc.x  , itc.y-o ) ).z;
        frag_color = vec4(r, g, b, 1) * s; //frag_color = vec4(r, g, b, l) * s;
"""

c.init("Test1", "data/fonts/PetMe/PetMe.ttf", gl_window_init_no_vsync)
//c.init("Test1", "data/fonts/Px437_IBM/Px437_IBM_BIOS.ttf", gl_window_init_no_vsync)
fatal(gl_load_materials(mats, true))

let treeobj = region{}
treeobj.fromREXPaint("data/textsprites/tree.csv")

c.clr()
let blank_r = c.text_rbuffer.copy()
let blank_c1 = c.text_c1buffer.copy()
let blank_c2 = c.text_c2buffer.copy()

let smalltree = treeobj.scaledcopy(8, 8)
if !smalltree:
    return

let testsprite = sprite{}
testsprite.fromregion(smalltree)
//testsprite.fromREXPaint("data/textsprites/ufo.csv")

var last_key_down = gl_time()
def handle_player_motion():
    if gl_time() - last_key_down > 0.05:
        if gl_button("right") >= 1:
            testsprite.pos = xy_i{testsprite.pos.x + 1, testsprite.pos.y}
        if gl_button("left") >= 1:
            testsprite.pos = xy_i{testsprite.pos.x - 1, testsprite.pos.y}
        if gl_button("up") >= 1:
            testsprite.pos = xy_i{testsprite.pos.x, testsprite.pos.y - 1}
        if gl_button("down") >= 1:
            testsprite.pos = xy_i{testsprite.pos.x, testsprite.pos.y + 1}
        last_key_down = gl_time()

t0 = gl_time()
while c.running:
    post_process(nil, gl_window_size(), "simplecrt", false, texture_format_nomipmap):
        c.update()
        c.text_rbuffer = blank_r.copy()
        c.text_c1buffer = blank_c1.copy()
        c.text_c2buffer = blank_c2.copy()
        //c.clr() 
        for (80):
            c.blit(smalltree, rnd(c.num_cells_x + 16) - 8, rnd(c.num_cells_y + 16) - 8)
        handle_player_motion()
        c.blit(testsprite)
        //c.blit(smalltree, 0, 0)
    FPS_deltas += gl_delta_time()
    FPS_counter++
    // stats (turn off vsync to measure)
    if gl_time()-t0 > 2: // only every 2 secs
        print "avg. FPS: " + FPS_counter/FPS_deltas
        t0 = gl_time()
        FPS_counter, FPS_deltas = 0, 0.0
