import std
import imgui

private var debug_window_enabled = false

def debugger_enable():
    if not debug_window_enabled:
        if manhattan(gl_window_size()) > 0:
            im_init(false)
            assert im_add_font("data/fonts/Droid_Sans/DroidSans.ttf", 20.0)
            debug_window_enabled = true
        else:
            print "Cannot enable debugger without prior call to gl_window!"

def breakpoint(label:string = "0"):
    if debug_window_enabled:
        var quit = false
        while gl_frame() and not quit:
            im_frame():
                im_window("BP: " + label + " -- press [Cancel] to quit", im_window_always_autoresize):
                    //im_show_engine_stats()
                    im_show_vars()
                    im_button("Cancel"): quit = true
        gl_grab(true)

// tests
if program_name() == "debug_tools.lobster":
    fatal(gl_window("debug demo", 1280, 1024))
    debugger_enable()
    breakpoint("Label 1")
