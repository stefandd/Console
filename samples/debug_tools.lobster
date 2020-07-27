import imgui

im_init(false)
assert im_add_font("data/fonts/Droid_Sans/DroidSans.ttf", 20.0)

def breakpoint():
    while gl_frame() and gl_button("escape") < 1:
        im_frame():
            im_window("Realtime Debugger -- press ESC to quit", im_window_always_autoresize):
                im_show_engine_stats()
                im_show_vars()
    while gl_button("escape") != 0: gl_frame() // wait until ESC key has been released; necessary in case the calling code also detects "escape" presses..
