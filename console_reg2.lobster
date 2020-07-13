import console  


let c:console = console{}
var FPS_counter, FPS_deltas = 0, 0.0
var t0 = gl_time()
c.init("Test1", "data/fonts/PetMe/PetMe.ttf", gl_window_init_no_vsync)
//c.init("Test1", "data/fonts/Px437_IBM/Px437_IBM_BIOS.ttf", gl_window_init_no_vsync)


let treeobj = region{}
treeobj.fromREXPaint("data/textsprites/tree.csv")

c.clr()
let blank_r = c.text_rbuffer.copy()
let blank_c1 = c.text_c1buffer.copy()
let blank_c2 = c.text_c2buffer.copy()

let smalltreereg = treeobj.scaledcopy(8, 8)
if !smalltreereg:
    return
let smalltree = sprite{}
smalltree.fromregion(smalltreereg)

let testsprite = sprite{}
testsprite.fromregion(smalltreereg)
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
    c.update()
    c.text_rbuffer = blank_r.copy()
    c.text_c1buffer = blank_c1.copy()
    c.text_c2buffer = blank_c2.copy()
    //c.clr() 
    for (80):
        smalltree.pos = xy_i{rnd(c.num_cells_x + 16) - 8, rnd(c.num_cells_y + 16) - 8}
        c.blit(smalltree)
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

