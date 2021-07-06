import random
import nimraylib_now
import strformat
import "modules/vector2"
import "modules/console3"
import "modules/repeat_until"
import "modules/oop"

const shipnum = 0

class TRex of RootObj:
    var
        sprites: seq[Sprite]
        direction: int
        animstate: int
        spriteidx: int
        dt_anim: float
        t_last_anim: float
        pos: Vector2i

    method init*() {.base.} =
        var trex1, trex2, trex3, trex4: Sprite = new Sprite
        trex1.fromREXPaint("textsprites/t-rex.csv", 0x0)
        trex2.fromREXPaint("textsprites/t-rex2.csv", 0x0)
        trex1.blitlevel = 1
        trex2.blitlevel = 1
        trex3 = trex1.copy(); trex3.hflip(true)
        trex4 = trex2.copy(); trex4.hflip(true)
        self.sprites = @[trex1, trex2, trex3, trex4]
        self.direction = 0 # 0 - pointing right, 1 - pointing left
        self.animstate = 0
        self.spriteidx = 0
        self.t_last_anim = getTime()
        self.dt_anim = 0.2
        self.pos = (0, 0)

    method blit(c: Console) {.base.} =
        self.spriteidx =  2 * self.direction + self.animstate # which sub-sprite to blit?
        self.sprites[self.spriteidx].pos = self.pos # move to the parent position
        self.sprites[self.spriteidx].blit(c)

    method move(dx: Vector2i) {.base.} =
        self.pos = self.pos + dx
        if dx.x == 1:
            self.direction = 0
        elif dx.x == -1:
            self.direction = 1
        let t_now = getTime()
        if t_now - self.t_last_anim > self.dt_anim:
            self.animstate = (self.animstate + 1) mod 2
            self.t_last_anim = t_now

var
    t_last_keypress = getTime()
    debugmsg = new Sprite
    nightsky = new Region
    ship = new Sprite
    ships: seq[Sprite] = @[]
    player = new TRex()
    c = new Console()
 
c.num_cells_y = 40
c.use_crt_shader = true
c.text_color = Color_2_uint32(RED)
c.background_color = Color_2_uint32(BLUE)
c.font_dx = 0
c.font_dy = 0

c.open("ASCII console test", "fonts/Px437_IBM/Px437_IBM_BIOS.fnt")
#setTargetFPS(60) # Set our game to run at 60 frames-per-second
    
nightsky.fromREXPaint("textsprites/nightsky.csv", 0x0)
nightsky.blitlevel = 2
ship.fromREXPaint("textsprites/ufo.csv", 0x0)
ship.blitlevel = 1
player.pos = (10, 27)

#c.randomize()
#screen = c.getscreen()

var teststr = ""

proc runner(): bool = # return true keeps this being called...
    let t_now = getTime()
    var attempts: int = 0

    result = true
    
    # put background
    c.clr()
    nightsky.modblit(c)

    # place UFOs
    ships.setLen(0)    
    block place_ships:
        for i in 0 ..< shipnum:
            let s = ship.copy()
            # test for collisions
            attempts = 0
            repeat:
                var no_collision = true                
                # generate a test position
                s.pos = (rand(35), rand(39))
                if s.collisiontest(player.sprites[player.spriteidx], true):
                    no_collision = false
                else:
                    for j in 0 ..< len(ships):
                        if s.collisiontest(ships[j], true): # is there a collision
                            no_collision = false
                            break                        
                attempts += 1
                if attempts > 100:
                    break place_ships # break out of all loops
                until no_collision #if no_collision: break
            s.blit(c)
            ships.add(s)

    debugmsg.fromstring(teststr & fmt"{c.viewport.x}, {c.viewport.y}", 0xff0000, 0xffffff, c.num_cells_x)
    debugmsg.blit(c)
    player.blit(c)

    # check key presses
    if t_now - t_last_keypress > 0.05:
        if isKeyDown(KeyboardKey.D):
            player.move((1, 0))
            t_last_keypress = t_now
        if isKeyDown(KeyboardKey.A):
            player.move((-1, 0))
            t_last_keypress = t_now
        if isKeyDown(KeyboardKey.S):
            teststr = teststr & "S"
            t_last_keypress = t_now
        #[ 
        if isKeyDown(KeyboardKey.W):
            player.move((0, -1))
            t_last_keypress = t_now
        if isKeyDown(KeyboardKey.S):
            player.move((0, 1))
            t_last_keypress = t_now
        ]#

    # scrolling of the view port
    if player.pos.x - c.viewport.x < 2:
        c.viewport.x -= 1
    elif player.pos.x - c.viewport.x > c.num_cells_x - player.sprites[player.spriteidx].extend.x - 2:
        c.viewport.x += 1

debugmsg.pos = (0, 0)
debugmsg.blitlevel = 2
c.run(runner)
