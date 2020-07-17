import console2 
import texture
import color

// console setup
let c:console = console{num_cells_x:40, num_cells_y:40, fontheight:20, fontwidth_:20, lineheight:20}
c.background_color = color{0.2, 0.2, 1.0, 1}
c.init("Space Attack", "data/fonts/Px437_IBM/Px437_IBM_BIOS.ttf", gl_window_init_no_vsync)

// define objects for UFOs and player
class UFO : sprite
    weapon_state = 0
    health_state = 0 // 0 - alive, 1 - xplosion 1, 2 - explosion 2
    t_state_chg = 0.0

    def clone() -> UFO:
        let cp = UFO{}
        cp.text_rbuffer = text_rbuffer.copy()
        cp.text_c1buffer = text_c1buffer.copy()
        cp.text_c2buffer = text_c2buffer.copy()
        cp.chr_vecs = chr_vecs.copy()
        cp.extend = extend
        cp.pos = pos
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
        return cp
        
class Player : sprite
    weapon_state = 0
    health_state = 0
    bullet_spawn_posx = 0
    t_fired = 0.0
    fire_delay = 0.1
    t_moved = 0.0
    move_delay = 0.03

// set up sprites
var player = Player{}
let playersprite, playersprite_xp1, playersprite_xp2 = sprite{}, sprite{}, sprite{}
playersprite.fromREXPaint("data/textsprites/spaceship.csv")
playersprite_xp1.fromREXPaint("data/textsprites/spaceship_xp1.csv")
playersprite_xp2.fromREXPaint("data/textsprites/spaceship_xp2.csv")
let ufo_zero, ufosprite_xp1, ufosprite_xp2 = UFO{}, sprite{}, sprite{}
ufo_zero.fromREXPaint("data/textsprites/ufo.csv")
ufosprite_xp1.fromREXPaint("data/textsprites/ufo_xp1.csv")
ufosprite_xp2.fromREXPaint("data/textsprites/ufo_xp2.csv")
let bulletsprite = Bullet{text_rbuffer:[cp437_to_unicode[249]], text_c1buffer:[color_white], text_c2buffer:[c.background_color], chr_vecs:[xy_i{0, 0}]}
let UFO_NUMBER = 12
var UFOs:[UFO] = []
var active_bullets:[Bullet] = []
var game_over = 0 // 1 -- player won, 2 - player killed
var FPS_counter, FPS_sum, FPS_t0 = 0, 0.0, 0.0 // remove me later

def initialize(level:int = 0):
    // inital placement UFOs
    def place_ufos():
        for (UFOs) ufo, i:
            var pos_OK = false
            while not pos_OK:
                ufo.pos = xy_i{rnd(c.num_cells_x), rnd(c.num_cells_y / 4) + 2} // put them into the upper third of the screen
                if i > 0: // 2nd UFO needs to also account for the 1st etc.
                    let collision_info = map(i) j: ufo.collisiontest(UFOs[j])
                    pos_OK = not any(collision_info) and not player.collisiontest(ufo)
                else:
                    pos_OK = not player.collisiontest(ufo) // 1st UFO we only check for collision with player

    player = Player{}
    player.copyfrom(playersprite, false)
    player.pos = xy_i{ 18, 36}
    UFOs = map(UFO_NUMBER): ufo_zero.clone() // many UFOs
    active_bullets = []
    game_over = 0 // 1 -- player won, 2 - player killed
    place_ufos()
    // background sound
    let bgmusic = play_wav("data/sounds/Cyber-Dream-Loop short.wav", -1) // by Eric Matyas from https://soundimage.org/looping-music/
    if bgmusic: sound_volume(bgmusic, 0.5) else: print "can\'t load music!"
    
def move_update_ufos():
    // move one UFO but so that the UFOs don't collide with each other or the player and horizontally towards the player ship
    if game_over == 0:
        let UFOs_alive = filter(UFOs) u: u.health_state == 0
        let num_alive = UFOs_alive.length
        if num_alive:
            let ufo_move_idx = rnd(num_alive) // this one will move this frame
            let u = UFOs_alive[ufo_move_idx] // pick on UFO
            let ufo_opos = u.pos
            var pos_OK = rnd(2) // rnd(2) makes it rest with 50% chance
            var player_ufo_collision = false
            while not pos_OK:
                let pos_x = ufo_opos.x + 2*(ufo_opos.x < player.pos.x) + rnd(3) - 2 // biased motion towards the player
                var pos_y = ufo_opos.y + (rnd(3) - 1)
                while pos_y < 0: pos_y = ufo_opos.y + (rnd(3) - 1) // make sure they don't go out of screen
                u.pos = xy_i{pos_x, pos_y}
                // test for collisions
                player_ufo_collision = player.collisiontest(u)
                //if player_ufo_collision:
                    //player.health_state = 1 // collision with UFO
                let collision_info = map(num_alive) i:
                        if i == ufo_move_idx:
                            false
                        else:
                            u.collisiontest(UFOs_alive[i])
                pos_OK = not any(collision_info) and not player_ufo_collision
        else:
            game_over = 1 // player won
    // update sprite stages and show sprites
    let t_now = gl_time()
    for (UFOs) u:
        if u.health_state == 1 and t_now - u.t_state_chg > 0.3:
            u.health_state = 2
            u.copyfrom(ufosprite_xp2, false)
            u.t_state_chg = t_now            
        if u.health_state == 2 and t_now - u.t_state_chg > 0.2:
            u.health_state = 3
        if u.health_state < 3:
            c.blit(u)

def handle_player():
    // helper function to detect collisions
    def move_check_collisions(testpos):
        let origpos = player.pos
        player.pos = testpos
        let collision_info = map(UFOs) ufo: player.collisiontest(ufo)
        if any(collision_info):
            player.pos = origpos // move player back

    // first check for player health:
    let t_now = gl_time()
    if player.health_state == 0: // alive
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
        pass() //play_wav("data/sounds/player_killed.wav", 0, 1) // animate explosion etc.
    //
    c.blit(player)

def update_projectiles():
    // bullet movement
    let t_now = gl_time()
    active_bullets = filter(active_bullets) ab: (ab.pos.y >= 0)
    for (active_bullets) b:
        if t_now - b.t_moved > b.move_delay:
            b.pos += xy_i{0, -1}
            b.t_moved = t_now
        for (UFOs) ufo:
            if b.collisiontest(ufo) and ufo.health_state == 0:
                ufo.health_state = 1
                ufo.copyfrom(ufosprite_xp1, false)
                ufo.t_state_chg = t_now
                b.pos = xy_i{-99, -99} // move bullet out of screen to deactive it and have it removed later
        c.blit(b, 1) // level 1 = character and text color
    //for (active_bolts) l:
        //pass()

initialize()
FPS_t0 = gl_time()
// main loop
c.run_crt():
    c.clr() 
    move_update_ufos()
    update_projectiles()
    handle_player()
    //c.sleep(0.05)
    // stats (turn off vsync to measure)
    FPS_sum += c.FPS
    FPS_counter++
    let t_now = gl_time()
    if t_now-FPS_t0 > 2: // only every 2 secs
        //print "avg. FPS: " + FPS_sum / FPS_counter
        FPS_t0 = t_now
        FPS_counter, FPS_sum = 0, 0.0
