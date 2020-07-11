import console  


let c:console = console{}
var FPS_counter, FPS_deltas = 0, 0.0
var t0 = gl_time()
//c.init("Test1", "data/fonts/PetMe/PetMe.ttf", gl_window_init_no_vsync)
c.init("Test1", "data/fonts/Px437_IBM/Px437_IBM_BIOS.ttf", gl_window_init_no_vsync)


let treeobj = region{}
treeobj.fromREXPaint("data/textsprites/tree.csv")

    
t0 = gl_time()
while c.running:
    c.update()
    c.clr()
    for (100):
        let smalltree = treeobj.scaledcopy(10, 10)
        if !smalltree:
            c.running = false
            break
        smalltree.blit(c, rnd(c.num_cells_x + 10) - 5, rnd(c.num_cells_y + 10) - 5)
    FPS_deltas += gl_delta_time()
    FPS_counter++
    // stats (turn off vsync to measure)
    if gl_time()-t0 > 2: // only every 2 secs
        print "avg. FPS: " + FPS_counter/FPS_deltas
        t0 = gl_time()
        FPS_counter, FPS_deltas = 0, 0.0

