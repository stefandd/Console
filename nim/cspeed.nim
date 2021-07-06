import random
import nimraylib_now
import "modules/vector2"
import "modules/oop"
import "modules/console3"

var c: Console = new Console
c.num_cells_x = 40
c.num_cells_y = 40
c.border_show = true
c.use_crt_shader = true
c.text_color = Color_2_uint32(RED)
c.background_color = Color_2_uint32(BLUE)
c.fontsize_y = 16
c.fontsize_x = 16
c.font_dx = 0
c.font_dy = 0
c.lineheight = 16
c.open("ASCII console test", "fonts/Px437_IBM/Px437_IBM_BIOS.fnt") #, 0x266B)

var
    t_last_move = getTime()
    screen = new Region
    debugmsg = new Sprite
    sc_taken = false
    testpos: Vector2i = (0, 0)
    ship = new Sprite

ship.fromREXPaint("textsprites/ufo.csv", 0x0)
ship.blitlevel = 2
ship.pos = (0, 0)

#c.randomize()
#screen = c.getscreen()

proc runner(): bool =
    result = true
    let t_now = getTime()

    c.clr()
    #c.randomize()
    for i in 0 ..< 80:
        #let s = ship.copy()
        #s.pos = (rand(35), rand(38))
        #s.blit(c)
        ship.pos = (rand(35), rand(38))
        ship.blit(c)

    #for i in 0 ..< len(debugmsg.text_c1buffer):
        #debugmsg.text_c1buffer[i] = rand(255).uint32 shl 16 + rand(255).uint32 shl 8 + rand(255).uint32
    #debugmsg.blit(c)

    if t_now - t_last_move > 0.05:
        if isKeyDown(KeyboardKey.D):
            c.viewport.x = c.viewport.x + 1
            t_last_move = t_now
        if isKeyDown(KeyboardKey.A):
            c.viewport.x = c.viewport.x - 1
            t_last_move = t_now
        if isKeyDown(KeyboardKey.W):
            c.viewport.y = c.viewport.y - 1
            t_last_move = t_now
        if isKeyDown(KeyboardKey.S):
            c.viewport.y = c.viewport.y + 1
            t_last_move = t_now

#debugmsg.fromstring("Hello world.", RED, WHITE)
#debugmsg.pos = (1, 1)
#debugmsg.blitlevel = 1

c.run(runner)
