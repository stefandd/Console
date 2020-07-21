import console2 
import texture
import color
import date_time
import sound_debug

// console setup
let c:console = console{num_cells_x:40, num_cells_y:40, fontheight:20, fontwidth_:20, lineheight:20}
c.text_color = color{0.2, 1.0, 0.2, 1}
c.background_color = color{0.2, 0.2, 0.2, 1}
c.init("Space Attack -- press ESC to quit", "data/fonts/Px437_IBM/Px437_IBM_BIOS.ttf", gl_window_init_no_vsync)

class IntroClass:
    t_started = 0.0
    slice_len = 0
    cycles = 3
    txt = "\n\n[INCOMING MESSAGE FROM H.Q.]:\n\n\nWelcome Pilot! You have been recruited\nto defend earth from a fleet of alien\ninvasion ships.\nWe have reliable intel on the strategy\nof the alien ships. The enemy will send waves of remote controlled, self-learn-\ning ships that are equipped with laser\nturrets. In each swarm, more and more\nships will know how to shoot laser bolts,and over time they will improve their\nlaser recharging process, resulting in\nmore rapid fire.\n\nKill as many as you can, soldier!\n\nYour remote controlled viper is moved\nusing the arrow keys and the hyper-\nprojectile gun fires with SPACE.\n\n\n\n\n[PRESS A KEY TO CONTINUE]"
    cursor = cp437_to_unicode[0xdb]
    def run():
        // 169 / 255 / 225 -- color-picked from a screen shot
        // 163 / 255 / 222
        // 176 / 255 / 228
        //c.textcolor = color{0.2, 1.0, 0.6, 1} // nice bright monochrome retro green    
        //c.background_color = color{0.06667, 0.23922, 0.14902, 1}
        c.text_color = color{0.66405, 1.0, 0.88235, 1}
        for (txt.length) i:
            c.writexy(0, 0, substring(txt, 0, i) + unicode_to_string([cursor]))
            c.sleep(0.01)

// define objects for UFOs and player
class UFO : sprite
    health_state = 0 // 0 - alive, 1 - xplosion 1, 2 - explosion 2
    activated = false
    activation_counter = 0
    t_fired = 0.0
    fire_delay = 0.5
    t_state_chg = 0.0
    t_moved = 0.0
    move_delay = 0.1
    def clone() -> UFO:
        let cp = UFO{}
        cp.text_rbuffer = text_rbuffer.copy()
        cp.text_c1buffer = text_c1buffer.copy()
        cp.text_c2buffer = text_c2buffer.copy()
        cp.chr_vecs = chr_vecs.copy()
        cp.extend = extend
        cp.pos = pos
        cp.activation_counter = activation_counter
        return cp

class Projectile : sprite
    t_moved = 0.0
    move_delay = 0.01 // on slow computers this might mean (as fast as possible)
    def clone() -> Projectile:
        let cp = Projectile{}
        cp.move_delay = move_delay // need to copy since there are 2 different types of Projectile
        cp.text_rbuffer = text_rbuffer.copy()
        cp.text_c1buffer = text_c1buffer.copy()
        cp.text_c2buffer = text_c2buffer.copy()
        cp.chr_vecs = chr_vecs.copy()
        cp.extend = extend
        cp.pos = pos
        return cp
        
class Player : sprite
    health_state = 0
    bullet_spawn_posx = 0
    t_fired = 0.0
    fire_delay = 0.1
    t_state_chg = 0.0
    t_moved = 0.0
    move_delay = 0.02

// set up sprites / objects
let intro = IntroClass{}
var player = Player{}
let playersprite, playersprite_xp1, playersprite_xp2 = sprite{}, sprite{}, sprite{}
playersprite.fromREXPaint("data/textsprites/spaceship.csv")
playersprite_xp1.fromREXPaint("data/textsprites/spaceship_xp1.csv")
playersprite_xp2.fromREXPaint("data/textsprites/spaceship_xp2.csv")
let ufo_zero, ufosprite_xp1, ufosprite_xp2 = UFO{}, sprite{}, sprite{}
ufo_zero.fromREXPaint("data/textsprites/ufo.csv")
ufosprite_xp1.fromREXPaint("data/textsprites/ufo_xp1.csv")
ufosprite_xp2.fromREXPaint("data/textsprites/ufo_xp2.csv")
let bulletsprite = Projectile{text_rbuffer:[cp437_to_unicode[249]], text_c1buffer:[color_white], text_c2buffer:[c.background_color], chr_vecs:[xy_i{0, 0}], move_delay: 0.01}
let lasersprite = Projectile{text_rbuffer:['|'], text_c1buffer:[color_red], text_c2buffer:[c.background_color], chr_vecs:[xy_i{0, 0}], move_delay: 0.05}
let UFO_num = 16
var UFO_initially_activated = 2
var UFO_activation_thresh = 1
var UFOs:[UFO], UFOs_lw:[UFO] = [], []
var active_bullets:[Projectile] = []
var active_lasers:[Projectile] = []
var t_now = 0.0
var t_seed:int = date_time()[dt_epoch]
var game_stage = 0 // 0: pre-stage, 1: stage loaded/paused, 2: stage running, 3: stage over
var FPS_counter, FPS_sum, FPS_t0 = 0, 0.0, 0.0 // remove me later

def initialize(difflevel:int = 0, wave_repeat:bool = false):
    player = Player{}
    player.copyfrom(playersprite, false) // load undamaged ship
    player.pos = xy_i{ 18, 36}
    active_bullets = []
    active_lasers = []
    // inital placement UFOs
    if wave_repeat:
        UFOs = map(UFO_num) i: UFOs_lw[i].clone()
        for (UFOs) u: u.t_moved = t_now // set move time flag
    else:
        UFOs = map(UFO_num): ufo_zero.clone() // many UFOs
        for (UFOs) u, i: // place UFOs collision-free
            var pos_OK = false
            while not pos_OK:
                u.pos = xy_i{rnd(c.num_cells_x), rnd(c.num_cells_y / 4) + 2} // put them into the upper third of the screen
                if i > 0: // 2nd UFO needs to also account for the 1st etc.
                    let collision_info = map(i) j: u.collisiontest(UFOs[j])
                    pos_OK = not any(collision_info) and not player.collisiontest(u)
                else:
                    pos_OK = not player.collisiontest(u) // 1st UFO we only check for collision with player
            u.t_moved = t_now // set move time flag
        for (UFO_initially_activated) i: // activate a certain initial number of UFOs
            var idx = rnd(UFO_num)
            while UFOs[idx].activation_counter: idx = rnd(UFO_num)
            UFOs[idx].activation_counter = UFO_activation_thresh
        UFOs_lw = map(UFO_num) i: UFOs[i].clone() // save the positions of this wave for a potential repeat!

def kill_player(): // function because we need this in 2 places (UFO collision and laser hit)
    player.health_state = 1
    player.copyfrom(playersprite_xp1, false)
    player.t_state_chg = t_now
    sound_volume(play_wav("data/sounds/player_killed.wav", 0, 1), 1.0) // explosion sound

def update_ufos():
    // move one UFO but so that the UFOs don't collide with each other or the player and horizontally towards the player ship
    let UFOs_alive = filter(UFOs) u: u.health_state == 0
    let num_alive = UFOs_alive.length
    if num_alive:
        for (UFOs_alive) u, ufo_idx:
            // 1st part -- firing at player
            if player.health_state == 0: // shoot at player if they are alive
                if u.activated:
                    if t_now - u.t_fired > u.fire_delay:
                        lasersprite.pos = u.pos + xy_i{2, 2}
                        u.text_c1buffer[5] = color{0.74902, 0.74902, 0.74902, 1} // reseting to original color
                        active_lasers.push(lasersprite.clone()) // put bullet in active bullets list
                        play_wav("data/sounds/126423__cabeeno-rossley__shoot-laser_short.wav", 0, 0) // make laser sound
                        u.t_fired = t_now
                    else:
                        let normlz = 1 - (t_now - u.t_fired) / u.fire_delay // color animation showing the heating up of the laser gun
                        u.text_c1buffer[5] = color{1 + (0.74902 - 1) * normlz, 0.74902 * normlz, 0.74902 * normlz, 1} // laser pod is the 6th character
                else:
                    if u.activation_counter >= UFO_activation_thresh:
                        u.activated = true
                        u.t_fired = t_now
            // 2nd part -- move attempt
            if t_now - u.t_moved > u.move_delay:
                let ufo_opos = u.pos
                var player_ufo_collision = false
                let pos_x = ufo_opos.x + 2*(ufo_opos.x < player.pos.x) + rnd(3) - 2 // biased motion towards the player
                var pos_y = ufo_opos.y + (rnd(3) - 1)
                while pos_y < 0 or pos_y > 3 * (c.num_cells_y / 4): pos_y = ufo_opos.y + (rnd(3) - 1) // make sure they don't go out of screen vertically, horizontally we don't care :)
                u.pos = xy_i{pos_x, pos_y}
                // test for collisions, first with player
                player_ufo_collision = player.collisiontest(u) and player.health_state == 0 // UFO does not collide with an already exploding player ship
                if player_ufo_collision:
                    kill_player()
                // collisions with other UFOs
                let collision_info = filter(num_alive) i: i != ufo_idx and u.collisiontest(UFOs_alive[i])
                // if this UFO is activated already, bumping into another one increases the chances for that one to be activated
                for (collision_info) i:
                    if u.activated: UFOs_alive[i].activation_counter++ 
                // however, abandon move attempt if UFO-UFO collision
                if collision_info.length or player_ufo_collision:
                    u.pos = ufo_opos
                u.t_moved = t_now // move attempts count as move
    elif active_lasers.length == 0: // decide stage outcome only after last UFO laser bolts are off the screen!
        game_stage = 3 // one side won
    // update sprite stages and show sprites
    for (UFOs) u:
        if u.health_state == 1 and t_now - u.t_state_chg > 0.2:
            u.health_state = 2
            u.copyfrom(ufosprite_xp2, false)
            u.t_state_chg = t_now            
        if u.health_state == 2 and t_now - u.t_state_chg > 0.2:
            u.health_state = 3
        if u.health_state < 3:
            c.blit(u, 1)

def update_player():
    // helper function to detect collisions
    def move_check_collisions(testpos):
        let origpos = player.pos
        player.pos = testpos
        let collision_info = map(UFOs) ufo: player.collisiontest(ufo)
        if any(collision_info):
            player.pos = origpos // move player back

    // first check for player health:
    if player.health_state == 0: // alive
        if t_now - player.t_moved > player.move_delay: // limit the player key repeat rate
            if gl_button("right") >= 1:
                move_check_collisions(xy_i{player.pos.x + 1, player.pos.y})
            if gl_button("left") >= 1:
                move_check_collisions(xy_i{player.pos.x - 1, player.pos.y})
            if gl_button("up") >= 1:
                move_check_collisions(xy_i{player.pos.x, player.pos.y - 1})
            if gl_button("down") >= 1:
                if player.pos.y < c.num_cells_y - 2: // don't let the player fully disappear at the screen bottom
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
        game_stage = 3 // one side won
    // update sprite stages and show sprites
    if player.health_state == 1 and t_now - player.t_state_chg > 0.2:
        player.health_state = 2
        player.copyfrom(playersprite_xp2, false)
        player.pos -= xy_i{1, 1} // bigger explosion cloud needs to be shifted a bit
        player.t_state_chg = t_now            
    if player.health_state == 2 and t_now - player.t_state_chg > 0.2:
        player.health_state = 3
    if player.health_state < 3:
        c.blit(player, 1)

def update_projectiles():
    // bullet movement
    active_bullets = filter(active_bullets) ab: (ab.pos.y >= 0)
    for (active_bullets) b:
        if t_now - b.t_moved > b.move_delay:
            b.pos -= xy_i{0, 1}
            b.t_moved = t_now
        for (UFOs) ufo:
            if b.collisiontest(ufo) and ufo.health_state == 0:
                ufo.health_state = 1
                ufo.copyfrom(ufosprite_xp1, false)
                ufo.t_state_chg = t_now
                b.pos = xy_i{0, -1} // move out of screen (it will be removed on the next filter call)
                play_wav("data/sounds/player_killed.wav", 0, 1) // explosion sound
        c.blit(b, 1) // level 1 = character and text color
    // laser bolt movement
    active_lasers = filter(active_lasers) al: (al.pos.y < c.num_cells_y)
    for (active_lasers) l:
        if t_now - l.t_moved > l.move_delay:
            l.pos += xy_i{0, 1}
            l.t_moved = t_now
        if l.collisiontest(player) and player.health_state == 0:
            kill_player()
            l.pos = xy_i{0, c.num_cells_y} // move laser out of screen (it will be removed on the next filter call)
        c.blit(l, 1)

// background sound
let bgmusic = play_wav("data/sounds/Cyber-Dream-Loop short.wav", -1) // by Eric Matyas from https://soundimage.org/looping-music/
if bgmusic: sound_volume(bgmusic, 0.5) else: print "can\'t load music!"
FPS_t0 = gl_time()
// main loop
c.run():
    c.clr() 
    t_now = gl_time()
    switch game_stage:
        case 0:
            //intro.run()
            game_stage = 1
        case 1:
            c.text_color = color{rnd_float(), rnd_float(), rnd_float(), 1}
            c.writexy(9, 10, "Press <return> to start")
            if gl_button("return") >= 1:
                game_stage++
        case 2,3:
            update_ufos()
            update_projectiles()
            update_player()
            switch game_stage:
                case 2:
                    c.text_color = color_white
                    c.writexy(0, 0, string(sound_info()), 1)
                case 3:
                    c.text_color = color{rnd_float(), rnd_float(), rnd_float(), 1}
                    if player.health_state == 0:
                        c.writexy(5, 10, "Press <return> for next wave")
                    else:
                        c.writexy(4, 10, "Press <return> to retry this wave")
                    if gl_button("return") >= 1:
                        initialize(0, player.health_state != 0) // wave repeat flag based on player health
                        rnd_seed(t_seed) // make sure that even subtle effects are identical
                        game_stage =  2 // 0: pre-stage, 1: stage loaded/paused, 2: stage running, 3: stage over
            //c.sleep(0.05)
    // stats (turn off vsync to measure)
    FPS_sum += c.FPS
    FPS_counter++
    if t_now-FPS_t0 > 2: // only every 2 secs
        print "avg. FPS: " + FPS_sum / FPS_counter
        FPS_t0 = t_now
        FPS_counter, FPS_sum = 0, 0.0
        if game_stage == 0: // start stage
            initialize()
            rnd_seed(t_seed) // make sure that even subtle effects are identical
            game_stage =  2 // 0: pre-stage, 1: stage loaded/paused, 2: stage running, 3: stage over
