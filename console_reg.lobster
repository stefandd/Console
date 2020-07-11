import console  


let c:console = console{}
var FPS_counter, FPS_deltas = 0, 0.0
var t0 = gl_time()
//c.init("Test1", "data/fonts/PetMe/PetMe.ttf", gl_window_init_no_vsync)
c.init("Test1", "data/fonts/Px437_IBM/Px437_IBM_BIOS.ttf", gl_window_init_no_vsync)


let treeobj = region{}
treeobj.fromREXPaint("data/textsprites/tree.csv")

c.clr()
let blank_r = c.text_rbuffer.copy()
let blank_c1 = c.text_c1buffer.copy()
let blank_c2 = c.text_c2buffer.copy()

let smalltree = treeobj.scaledcopy(8, 8)
if !smalltree:
    return
    
t0 = gl_time()
while c.running:
    c.update()
    c.text_rbuffer = blank_r.copy()
    c.text_c1buffer = blank_c1.copy()
    c.text_c2buffer = blank_c2.copy()
    //c.clr() 
    for (64):
        c.blit(smalltree, rnd(c.num_cells_x + 16) - 8, rnd(c.num_cells_y + 16) - 8)
    FPS_deltas += gl_delta_time()
    FPS_counter++
    // stats (turn off vsync to measure)
    if gl_time()-t0 > 2: // only every 2 secs
        print "avg. FPS: " + FPS_counter/FPS_deltas
        t0 = gl_time()
        FPS_counter, FPS_deltas = 0, 0.0

