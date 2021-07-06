import console2 
import texture
import color

// vars for FPS counter
var FPS_counter, FPS_sum = 0, 0.0
var t0 = 0.0
var last_key_down = 0.0

// console setup
let c:console = console{num_cells_x:40, num_cells_y:40, fontheight:12, fontwidth_:12, lineheight:12}
c.background_color = color{0.2, 0.2, 1.0, 1}
c.init("SpriteTest1", "data/fonts/Px437_IBM/Px437_IBM_BIOS.ttf", gl_window_init_no_vsync)

// player and test sprites
let playersprite = sprite{}
playersprite.fromREXPaint("data/textsprites/spaceship.csv")
let ufosprite = sprite{}
ufosprite.fromREXPaint("data/textsprites/ufo.csv")
let UFO_NUMBER = 128
let ufosprites = map(UFO_NUMBER): ufosprite.clone() // 128 UFOs

// inital placement UFOs
def place_ufos():
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

// move UFOs but so that they don't collide with each other or the player
def move_ufos():
    // move them in the horizontal position of the player ship
    for (ufosprites) ufo, i:
        var pos_OK = false or (rnd(5) - 3)
        while not pos_OK:
            ufo.pos = xy_i{ufo.pos.x + (rnd(3) - 1), ufo.pos.y + (rnd(3) - 1)}
            if i > 0: // 2nd UFO needs to also account for the 1st etc.
                let collision_info = map(i) j:
                    ufo.collisiontest(ufosprites[j])
                pos_OK = not any(collision_info) and not playersprite.collisiontest(ufo)
            else:
                pos_OK = not playersprite.collisiontest(ufo) // 1st UFO we only check for collision with player
        c.blit(ufo)

// player movement
def handle_player_motion():
    def move_check_collisions(testpos):
        let origpos = playersprite.pos
        playersprite.pos = testpos
        let collision_info = map(ufosprites) ufo:
                                    playersprite.collisiontest(ufo)
        if any(collision_info):
            playersprite.pos = origpos // move player back

    if gl_time() - last_key_down > 0.03: // limit the player key repeat rate
        if gl_button("right") >= 1:
            move_check_collisions(xy_i{playersprite.pos.x + 1, playersprite.pos.y})
        if gl_button("left") >= 1:
            move_check_collisions(xy_i{playersprite.pos.x - 1, playersprite.pos.y})
        if gl_button("up") >= 1:
            move_check_collisions(xy_i{playersprite.pos.x, playersprite.pos.y - 1})
        if gl_button("down") >= 1:
            move_check_collisions(xy_i{playersprite.pos.x, playersprite.pos.y + 1})
        last_key_down = gl_time()


// main loop
place_ufos()

t0 = gl_time()
c.run():
    c.clr() 
    handle_player_motion()
    move_ufos()
    c.blit(playersprite)
    c.sleep(0.1)
    // stats (turn off vsync to measure)
    FPS_sum += c.FPS
    FPS_counter++
    let t_now = gl_time()
    if t_now-t0 > 2: // only every 2 secs
        print "avg. FPS: " + FPS_sum / FPS_counter
        t0 = t_now
        FPS_counter, FPS_sum = 0, 0.0
