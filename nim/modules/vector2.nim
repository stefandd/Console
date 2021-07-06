import random

type Vector2i* {.bycopy.} = object
  ## 2-component vector of integers
  x*: int
  y*: int

type Vector2f* {.bycopy.} = object
  ## 2-component vector of floats
  x*: float
  y*: float

# ================ funcs

proc Vector2f_abs*(v: Vector2f): Vector2f =
    result.x = abs(v.x)
    result.y = abs(v.y)
proc Vector2f_manhattan*(v: Vector2f): float =
    result = abs(v.x) + abs(v.y)
proc Vector2f_max*(v1: Vector2f, v2: Vector2f): Vector2f =
    result.x = max(v1.x, v2.x)
    result.y = max(v1.y, v2.y)
proc Vector2f_min*(v1: Vector2f, v2: Vector2f): Vector2f =
    result.x = min(v1.x, v2.x)
    result.y = min(v1.y, v2.y)
proc Vector2i_abs*(v: Vector2i): Vector2i =
    result.x = abs(v.x)
    result.y = abs(v.y)
proc Vector2i_manhattan*(v: Vector2i): int =
    result = abs(v.x) + abs(v.y)
proc Vector2i_max*(v1: Vector2i, v2: Vector2i): Vector2i =
    result.x = max(v1.x, v2.x)
    result.y = max(v1.y, v2.y)
proc Vector2i_min*(v1: Vector2i, v2: Vector2i): Vector2i =
    result.x = min(v1.x, v2.x)
    result.y = min(v1.y, v2.y)
proc Vector2i_rand*(n: int): Vector2i =
    result.x = rand(n)
    result.y = rand(n)

# ================ operators

proc vec2*(x, y: int): Vector2i = Vector2i(x: x, y: y)
  ## *Returns*: Vector2i with these coordinates
proc vec2*(x, y: cint): Vector2i = Vector2i(x: int(x), y: int(y))
  ## *Returns*: Vector2i with these coordinates
proc vec2*(x, y: float): Vector2f = Vector2f(x: x, y: y)
  ## *Returns*: Vector2f with these coordinates
proc vec2*(x, y: cfloat): Vector2f = Vector2f(x: float(x), y: float(y))
  ## *Returns*: Vector2f with these coordinates

proc `+`*(a, b: Vector2f): Vector2f = vec2(a.x+b.x, a.y+b.y)
  ## *Returns*: memberwise addition
proc `-`*(a, b: Vector2f): Vector2f = vec2(a.x-b.x, a.y-b.y)
  ## *Returns*: memberwise subtraction
proc `*`*(a: Vector2f, b: float): Vector2f = vec2(a.x*b, a.y*b)
  ## *Returns*: memberwise multiplication by ``b``
proc `*`*(a: Vector2f, b: int): Vector2f =
  let bf = float(b)
  result = vec2((a.x)*bf, (a.y)*bf)
  ## *Returns*: memberwise multiplication by ``b``
proc `*`*(a: Vector2f, b: Vector2f): Vector2f = vec2(a.x*b.x, a.y*b.y)
  ## *Returns*: memberwise multiplication by ``b``
proc `/`*(a: Vector2f, b: float): Vector2f = vec2(a.x/b, a.y/b)
  ## *Returns*: memberwise division by ``b``
proc `/`*(a: Vector2f, b: int): Vector2f =
  let bf = float(b)
  result = vec2(a.x/bf, a.y/bf)
  ## *Returns*: memberwise division by ``b``
proc `-`*(a: Vector2f): Vector2f = vec2(-a.x, -a.y)
  ## *Returns*: memberwise opposite
proc `<`*(a: Vector2f, b: float): bool = a.x<b and a.y<b
  ## *Returns*: whether corresponding members of two Vector2fs are less than
proc `<`*(a: float, b: Vector2f): bool = a<b.x and a<b.y
  ## *Returns*: whether corresponding members of two Vector2fs are less than
proc `==`*(a: Vector2f, b: float): bool = a.x==b and a.y==b
  ## *Returns*: whether corresponding members of two Vector2fs are equal
proc `==`*(a: float, b: Vector2f): bool = a==b.x and a==b.y
  ## *Returns*: whether corresponding members of two Vector2fs are equal
proc `<=`*(a: Vector2f, b: float): bool = a.x<=b and a.y<=b
  ## *Returns*: whether corresponding members of two Vector2fs are less or equal
proc `<=`*(a: float, b: Vector2f): bool = a<=b.x and a<=b.y
  ## *Returns*: whether corresponding members of two Vector2fs are less or equal

proc `+`*(a, b: Vector2i): Vector2i = vec2(a.x+b.x, a.y+b.y)
  ## *Returns*: memberwise addition
proc `-`*(a, b: Vector2i): Vector2i = vec2(a.x-b.x, a.y-b.y)
  ## *Returns*: memberwise subtraction
proc `*`*(a: Vector2i, b: int): Vector2i = vec2(a.x*b, a.y*b)
  ## *Returns*: memberwise multiplication by ``b``
proc `*`*(a: Vector2i, b: Vector2i): Vector2i = vec2(a.x*b.x, a.y*b.y)
  ## *Returns*: memberwise multiplication by ``b``
proc `div`*(a: Vector2i, b: int): Vector2i = vec2(a.x div b, a.y div b)
  ## *Returns*: memberwise integer division by ``b``
proc `-`*(a: Vector2i): Vector2i = vec2(-a.x, -a.y)
  ## *Returns*: memberwise opposite
proc `<`*(a, b: Vector2i): bool = a.x<b.x and a.y<b.y
  ## *Returns*: whether corresponding members of two Vector2is are less than
proc `==`*(a, b: Vector2i): bool = a.x==b.x and a.y==b.y
  ## *Returns*: whether corresponding members of two Vector2is are equal
proc `<=`*(a, b: Vector2i): bool = a.x<=b.x and a.y<=b.y
  ## *Returns*: whether corresponding members of two Vector2is are less or equal
proc `<`*(a: Vector2i, b: int): bool = a.x<b and a.y<b
  ## *Returns*: whether corresponding members of two Vector2is are less than
proc `<`*(a: int, b: Vector2i): bool = a<b.x and a<b.y
  ## *Returns*: whether corresponding members of two Vector2is are less than
proc `==`*(a: Vector2i, b: int): bool = a.x==b and a.y==b
  ## *Returns*: whether corresponding members of two Vector2is are equal
proc `==`*(a: int, b: Vector2i): bool = a==b.x and a==b.y
  ## *Returns*: whether corresponding members of two Vector2is are equal
proc `<=`*(a: Vector2i, b: int): bool = a.x<=b and a.y<=b
  ## *Returns*: whether corresponding members of two Vector2is are less or equal
proc `<=`*(a: int, b: Vector2i): bool = a<=b.x and a<=b.y
  ## *Returns*: whether corresponding members of two Vector2is are less or equal

# ================ converters

converter vec2*(a: Vector2i): Vector2f = Vector2f(x: float(a.x), y: float(a.y))
  ## Conversion from Vector2i to Vector2f
converter tupleToVector2i*(self: tuple[x,y: int]): Vector2i = Vector2i(x: self.x, y: self.y)
  ## Conversion from (int, int) to Vector2i
converter tupleToVector2f*(self: tuple[x,y: float]): Vector2f = Vector2f(x: self.x, y: self.y)
  ## Conversion from (float, float) to Vector2f
