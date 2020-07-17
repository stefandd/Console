import console2 
import texture
import color

// vars for FPS counter
var FPS_counter, FPS_sum = 0, 0.0
var t0 = 0.0

// console setup
let c:console = console{num_cells_x:40, num_cells_y:40, fontheight:12, fontwidth_:12, lineheight:12}
c.background_color = color{0.2, 0.2, 1.0, 1}
c.init("SpriteTest1", "data/fonts/Px437_IBM/Px437_IBM_BIOS.ttf", gl_window_init_no_vsync)

// define objects for UFOs and player
class UFO : sprite
    weapon_state = 0
    health_state = 0
    t_moved = 0.0
    move_delay = 0.2

    def clone() -> UFO:
        let cp = UFO{}
        cp.text_rbuffer = text_rbuffer.copy()
        cp.text_c1buffer = text_c1buffer.copy()
        cp.text_c2buffer = text_c2buffer.copy()
        cp.chr_vecs = chr_vecs.copy()
        cp.extend = extend
        cp.pos = pos
        cp.alpha_chr = alpha_chr
        return cp

class Bullet : sprite
    t_moved = 0.0
    move_delay = 0.01

    def clone() -> Bullet:
        let cp = Bullet{}
        cp.text_rbuffer = text_rbuffer.copy()
        cp.text_c1buffer = text_c1buffer.copy()
        cp.text_c2buffer = text_c2buffer.copy()
        cp.chr_vecs = chr_vecs.copy()
        cp.extend = extend
        cp.pos = pos
        cp.alpha_chr = alpha_chr
        return cp
        
class Player : sprite
    weapon_state = 0
    health_state = 0
    bullet_spawn_posx = 0
    t_fired = 0.0
    t_moved = 0.0
    fire_delay = 0.1
    move_delay = 0.03

// set up sprites
let player = Player{}
player.fromREXPaint("data/textsprites/spaceship.csv")
player.pos = xy_i{ 18, 36}
let ufosprite = UFO{}
ufosprite.fromREXPaint("data/textsprites/ufo.csv")
let UFO_NUMBER = 16
var UFOs = map(UFO_NUMBER): ufosprite.clone() // many UFOs
let bulletsprite = Bullet{text_rbuffer:[cp437_to_unicode[249]], text_c1buffer:[color_white], text_c2buffer:[c.background_color], chr_vecs:[xy_i{0, 0}]}
var active_bullets:[Bullet] = []

// inital placement UFOs
def place_ufos():
    for (UFOs) ufo, i:
        var pos_OK = false
        while not pos_OK:
            ufo.pos = xy_i{rnd(c.num_cells_x), rnd(c.num_cells_y / 4) + 2} // put them into the upper third of the screen
            if i > 0: // 2nd UFO needs to also account for the 1st etc.
                let collision_info = map(i) j:
                    ufo.collisiontest(UFOs[j])
                pos_OK = not any(collision_info) and not player.collisiontest(ufo)
            else:
                pos_OK = not player.collisiontest(ufo) // 1st UFO we only check for collision with player


def move_update_ufos():
    // move UFOs but so that they don't collide with each other or the player and horizontally towards the player ship
    let t_now = gl_time()
    for (UFOs) ufo, i:
        if (t_now - ufo.t_moved > ufo.move_delay) and (not rnd(500)):
            var pos_OK = false
            var player_ufo_collision = false
            while not pos_OK:
                let pos_x = ufo.pos.x + 2*(ufo.pos.x < player.pos.x) + rnd(3) - 2 // biased motion towards the player
                var pos_y = ufo.pos.y + (rnd(3) - 1)
                while pos_y < 0: pos_y = ufo.pos.y + (rnd(3) - 1) // make sure they don't go out of screen
                ufo.pos = xy_i{pos_x, pos_y}
                // test for collisions
                player_ufo_collision = player.collisiontest(ufo)
                //if player_ufo_collision:
                    //player.health_state = 1 // collision with UFO
                    
                // BUGGY THIS NEEDS TO TEST ALSO THE OTHER ONES!!!!
                if i > 0: // nth UFO needs to check for collisions with the n-1 placed beforehand
                    let collision_info = map(i) j:
                        ufo.collisiontest(UFOs[j])
                    pos_OK = not any(collision_info) and not player_ufo_collision
                else:
                    pos_OK = not player_ufo_collision // 1st UFO we only check for collision with player
            ufo.t_moved = t_now
        c.blit(ufo)

def handle_player():
    // helper function to detect collisions
    def move_check_collisions(testpos):
        let origpos = player.pos
        player.pos = testpos
        let collision_info = map(UFOs) ufo:
                                    player.collisiontest(ufo)
        if any(collision_info):
            player.pos = origpos // move player back

    // first check for player health:
    if player.health_state == 0: // alive
        let t_now = gl_time()
        if t_now - player.t_moved > player.move_delay: // limit the player key repeat rate
            if gl_button("right") >= 1:
                move_check_collisions(xy_i{player.pos.x + 1, player.pos.y})
            if gl_button("left") >= 1:
                move_check_collisions(xy_i{player.pos.x - 1, player.pos.y})
            if gl_button("up") >= 1:
                move_check_collisions(xy_i{player.pos.x, player.pos.y - 1})
            if gl_button("down") >= 1:
                move_check_collisions(xy_i{player.pos.x, player.pos.y + 1})
            player.t_moved = t_now
        if t_now - player.t_fired > player.fire_delay:
            if gl_button("space") >= 1:
                bulletsprite.pos = player.pos + xy_i{player.bullet_spawn_posx, 0}
                active_bullets.push(bulletsprite.clone()) // put bullet in active bullets list
                player.bullet_spawn_posx = 4 - player.bullet_spawn_posx // activate other barrel
                play_wav("data/sounds/laser_buzz.wav", 0, 1) // make buzzer sound
                player.t_fired = t_now
    else:
        pass() // animate explosion etc.
        
    c.blit(player)

def update_projectiles():
    // bullet movement
    let t_now = gl_time()
    active_bullets = filter(active_bullets) ab: (ab.pos.y >= 0)
    for (active_bullets) b:
        if t_now - b.t_moved > b.move_delay:
            b.pos += xy_i{0, -1}
            b.t_moved = t_now
        //let collision_info = map(UFOs) ufo:
                                    //b.collisiontest(ufo)
        c.blit(b)

// init stuff
let bgmusic = play_wav("data/sounds/Cyber-Dream-Loop short.wav", -1) // by Eric Matyas from https://soundimage.org/looping-music/
if bgmusic: sound_volume(bgmusic, 0.5) else: print "can\'t load music!"
place_ufos()

// main loop
t0 = gl_time()
c.run():
    c.clr() 
    move_update_ufos()
    update_projectiles()
    handle_player()
    //c.sleep(0.005)
    // stats (turn off vsync to measure)
    FPS_sum += c.FPS
    FPS_counter++
    let t_now = gl_time()
    if t_now-t0 > 2: // only every 2 secs
        print "avg. FPS: " + FPS_sum / FPS_counter
        t0 = t_now
        FPS_counter, FPS_sum = 0, 0.0
