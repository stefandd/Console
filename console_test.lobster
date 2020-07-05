import console

c:console = console{}

c.init("Test1", "data/fonts/Square/Square.ttf")
while c.running:
    c.update()
