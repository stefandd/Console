import math
import simplerand
import strutils
import strformat
import unicode
import parsecsv
from streams import newFileStream
import nimraylib_now
import vector2

# cp437 translation table, needed for the REXPaint import function in cp437_DOSLatinUS order
const cp437_to_unicode*: array[256, int] = [
    0x0000, #NULL
    0x263A, 0x263B, 0x2665, 0x2666, 0x2663, 0x2660, 0x2022, 0x25D8,
    0x25CB, 0x25D9, 0x2642, 0x2640, 0x266A, 0x266B, 0x263C, 0x25BA,
    0x25C4, 0x2195, 0x203C,   0xB6,   0xA7, 0x25AC, 0x21A8, 0x2191,
    0x2193, 0x2192, 0x2190, 0x221F, 0x2194, 0x25B2, 0x25BC,
    0x0020, #SPACE
    0x0021, #EXCLAMATION MARK
    0x0022, #QUOTATION MARK
    0x0023, #NUMBER SIGN
    0x0024, #DOLLAR SIGN
    0x0025, #PERCENT SIGN
    0x0026, #AMPERSAND
    0x0027, #APOSTROPHE
    0x0028, #LEFT PARENTHESIS
    0x0029, #RIGHT PARENTHESIS
    0x002a, #ASTERISK
    0x002b, #PLUS SIGN
    0x002c, #COMMA
    0x002d, #HYPHEN-MINUS
    0x002e, #FULL STOP
    0x002f, #SOLIDUS
    0x0030, #DIGIT ZERO
    0x0031, #DIGIT ONE
    0x0032, #DIGIT TWO
    0x0033, #DIGIT THREE
    0x0034, #DIGIT FOUR
    0x0035, #DIGIT FIVE
    0x0036, #DIGIT SIX
    0x0037, #DIGIT SEVEN
    0x0038, #DIGIT EIGHT
    0x0039, #DIGIT NINE
    0x003a, #COLON
    0x003b, #SEMICOLON
    0x003c, #LESS-THAN SIGN
    0x003d, #EQUALS SIGN
    0x003e, #GREATER-THAN SIGN
    0x003f, #QUESTION MARK
    0x0040, #COMMERCIAL AT
    0x0041, #LATIN CAPITAL LETTER A
    0x0042, #LATIN CAPITAL LETTER B
    0x0043, #LATIN CAPITAL LETTER C
    0x0044, #LATIN CAPITAL LETTER D
    0x0045, #LATIN CAPITAL LETTER E
    0x0046, #LATIN CAPITAL LETTER F
    0x0047, #LATIN CAPITAL LETTER G
    0x0048, #LATIN CAPITAL LETTER H
    0x0049, #LATIN CAPITAL LETTER I
    0x004a, #LATIN CAPITAL LETTER J
    0x004b, #LATIN CAPITAL LETTER K
    0x004c, #LATIN CAPITAL LETTER L
    0x004d, #LATIN CAPITAL LETTER M
    0x004e, #LATIN CAPITAL LETTER N
    0x004f, #LATIN CAPITAL LETTER O
    0x0050, #LATIN CAPITAL LETTER P
    0x0051, #LATIN CAPITAL LETTER Q
    0x0052, #LATIN CAPITAL LETTER R
    0x0053, #LATIN CAPITAL LETTER S
    0x0054, #LATIN CAPITAL LETTER T
    0x0055, #LATIN CAPITAL LETTER U
    0x0056, #LATIN CAPITAL LETTER V
    0x0057, #LATIN CAPITAL LETTER W
    0x0058, #LATIN CAPITAL LETTER X
    0x0059, #LATIN CAPITAL LETTER Y
    0x005a, #LATIN CAPITAL LETTER Z
    0x005b, #LEFT SQUARE BRACKET
    0x005c, #REVERSE SOLIDUS
    0x005d, #RIGHT SQUARE BRACKET
    0x005e, #CIRCUMFLEX ACCENT
    0x005f, #LOW LINE
    0x0060, #GRAVE ACCENT
    0x0061, #LATIN SMALL LETTER A
    0x0062, #LATIN SMALL LETTER B
    0x0063, #LATIN SMALL LETTER C
    0x0064, #LATIN SMALL LETTER D
    0x0065, #LATIN SMALL LETTER E
    0x0066, #LATIN SMALL LETTER F
    0x0067, #LATIN SMALL LETTER G
    0x0068, #LATIN SMALL LETTER H
    0x0069, #LATIN SMALL LETTER I
    0x006a, #LATIN SMALL LETTER J
    0x006b, #LATIN SMALL LETTER K
    0x006c, #LATIN SMALL LETTER L
    0x006d, #LATIN SMALL LETTER M
    0x006e, #LATIN SMALL LETTER N
    0x006f, #LATIN SMALL LETTER O
    0x0070, #LATIN SMALL LETTER P
    0x0071, #LATIN SMALL LETTER Q
    0x0072, #LATIN SMALL LETTER R
    0x0073, #LATIN SMALL LETTER S
    0x0074, #LATIN SMALL LETTER T
    0x0075, #LATIN SMALL LETTER U
    0x0076, #LATIN SMALL LETTER V
    0x0077, #LATIN SMALL LETTER W
    0x0078, #LATIN SMALL LETTER X
    0x0079, #LATIN SMALL LETTER Y
    0x007a, #LATIN SMALL LETTER Z
    0x007b, #LEFT CURLY BRACKET
    0x007c, #VERTICAL LINE
    0x007d, #RIGHT CURLY BRACKET
    0x007e, #TILDE
    0x007f, #DELETE
    0x00c7, #LATIN CAPITAL LETTER C WITH CEDILLA
    0x00fc, #LATIN SMALL LETTER U WITH DIAERESIS
    0x00e9, #LATIN SMALL LETTER E WITH ACUTE
    0x00e2, #LATIN SMALL LETTER A WITH CIRCUMFLEX
    0x00e4, #LATIN SMALL LETTER A WITH DIAERESIS
    0x00e0, #LATIN SMALL LETTER A WITH GRAVE
    0x00e5, #LATIN SMALL LETTER A WITH RING ABOVE
    0x00e7, #LATIN SMALL LETTER C WITH CEDILLA
    0x00ea, #LATIN SMALL LETTER E WITH CIRCUMFLEX
    0x00eb, #LATIN SMALL LETTER E WITH DIAERESIS
    0x00e8, #LATIN SMALL LETTER E WITH GRAVE
    0x00ef, #LATIN SMALL LETTER I WITH DIAERESIS
    0x00ee, #LATIN SMALL LETTER I WITH CIRCUMFLEX
    0x00ec, #LATIN SMALL LETTER I WITH GRAVE
    0x00c4, #LATIN CAPITAL LETTER A WITH DIAERESIS
    0x00c5, #LATIN CAPITAL LETTER A WITH RING ABOVE
    0x00c9, #LATIN CAPITAL LETTER E WITH ACUTE
    0x00e6, #LATIN SMALL LIGATURE AE
    0x00c6, #LATIN CAPITAL LIGATURE AE
    0x00f4, #LATIN SMALL LETTER O WITH CIRCUMFLEX
    0x00f6, #LATIN SMALL LETTER O WITH DIAERESIS
    0x00f2, #LATIN SMALL LETTER O WITH GRAVE
    0x00fb, #LATIN SMALL LETTER U WITH CIRCUMFLEX
    0x00f9, #LATIN SMALL LETTER U WITH GRAVE
    0x00ff, #LATIN SMALL LETTER Y WITH DIAERESIS
    0x00d6, #LATIN CAPITAL LETTER O WITH DIAERESIS
    0x00dc, #LATIN CAPITAL LETTER U WITH DIAERESIS
    0x00a2, #CENT SIGN
    0x00a3, #POUND SIGN
    0x00a5, #YEN SIGN
    0x20a7, #PESETA SIGN
    0x0192, #LATIN SMALL LETTER F WITH HOOK
    0x00e1, #LATIN SMALL LETTER A WITH ACUTE
    0x00ed, #LATIN SMALL LETTER I WITH ACUTE
    0x00f3, #LATIN SMALL LETTER O WITH ACUTE
    0x00fa, #LATIN SMALL LETTER U WITH ACUTE
    0x00f1, #LATIN SMALL LETTER N WITH TILDE
    0x00d1, #LATIN CAPITAL LETTER N WITH TILDE
    0x00aa, #FEMININE ORDINAL INDICATOR
    0x00ba, #MASCULINE ORDINAL INDICATOR
    0x00bf, #INVERTED QUESTION MARK
    0x2310, #REVERSED NOT SIGN
    0x00ac, #NOT SIGN
    0x00bd, #VULGAR FRACTION ONE HALF
    0x00bc, #VULGAR FRACTION ONE QUARTER
    0x00a1, #INVERTED EXCLAMATION MARK
    0x00ab, #LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
    0x00bb, #RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
    0x2591, #LIGHT SHADE
    0x2592, #MEDIUM SHADE
    0x2593, #DARK SHADE
    0x2502, #BOX DRAWINGS LIGHT VERTICAL
    0x2524, #BOX DRAWINGS LIGHT VERTICAL AND LEFT
    0x2561, #BOX DRAWINGS VERTICAL SINGLE AND LEFT DOUBLE
    0x2562, #BOX DRAWINGS VERTICAL DOUBLE AND LEFT SINGLE
    0x2556, #BOX DRAWINGS DOWN DOUBLE AND LEFT SINGLE
    0x2555, #BOX DRAWINGS DOWN SINGLE AND LEFT DOUBLE
    0x2563, #BOX DRAWINGS DOUBLE VERTICAL AND LEFT
    0x2551, #BOX DRAWINGS DOUBLE VERTICAL
    0x2557, #BOX DRAWINGS DOUBLE DOWN AND LEFT
    0x255d, #BOX DRAWINGS DOUBLE UP AND LEFT
    0x255c, #BOX DRAWINGS UP DOUBLE AND LEFT SINGLE
    0x255b, #BOX DRAWINGS UP SINGLE AND LEFT DOUBLE
    0x2510, #BOX DRAWINGS LIGHT DOWN AND LEFT
    0x2514, #BOX DRAWINGS LIGHT UP AND RIGHT
    0x2534, #BOX DRAWINGS LIGHT UP AND HORIZONTAL
    0x252c, #BOX DRAWINGS LIGHT DOWN AND HORIZONTAL
    0x251c, #BOX DRAWINGS LIGHT VERTICAL AND RIGHT
    0x2500, #BOX DRAWINGS LIGHT HORIZONTAL
    0x253c, #BOX DRAWINGS LIGHT VERTICAL AND HORIZONTAL
    0x255e, #BOX DRAWINGS VERTICAL SINGLE AND RIGHT DOUBLE
    0x255f, #BOX DRAWINGS VERTICAL DOUBLE AND RIGHT SINGLE
    0x255a, #BOX DRAWINGS DOUBLE UP AND RIGHT
    0x2554, #BOX DRAWINGS DOUBLE DOWN AND RIGHT
    0x2569, #BOX DRAWINGS DOUBLE UP AND HORIZONTAL
    0x2566, #BOX DRAWINGS DOUBLE DOWN AND HORIZONTAL
    0x2560, #BOX DRAWINGS DOUBLE VERTICAL AND RIGHT
    0x2550, #BOX DRAWINGS DOUBLE HORIZONTAL
    0x256c, #BOX DRAWINGS DOUBLE VERTICAL AND HORIZONTAL
    0x2567, #BOX DRAWINGS UP SINGLE AND HORIZONTAL DOUBLE
    0x2568, #BOX DRAWINGS UP DOUBLE AND HORIZONTAL SINGLE
    0x2564, #BOX DRAWINGS DOWN SINGLE AND HORIZONTAL DOUBLE
    0x2565, #BOX DRAWINGS DOWN DOUBLE AND HORIZONTAL SINGLE
    0x2559, #BOX DRAWINGS UP DOUBLE AND RIGHT SINGLE
    0x2558, #BOX DRAWINGS UP SINGLE AND RIGHT DOUBLE
    0x2552, #BOX DRAWINGS DOWN SINGLE AND RIGHT DOUBLE
    0x2553, #BOX DRAWINGS DOWN DOUBLE AND RIGHT SINGLE
    0x256b, #BOX DRAWINGS VERTICAL DOUBLE AND HORIZONTAL SINGLE
    0x256a, #BOX DRAWINGS VERTICAL SINGLE AND HORIZONTAL DOUBLE
    0x2518, #BOX DRAWINGS LIGHT UP AND LEFT
    0x250c, #BOX DRAWINGS LIGHT DOWN AND RIGHT
    0x2588, #FULL BLOCK
    0x2584, #LOWER HALF BLOCK
    0x258c, #LEFT HALF BLOCK
    0x2590, #RIGHT HALF BLOCK
    0x2580, #UPPER HALF BLOCK
    0x03b1, #GREEK SMALL LETTER ALPHA
    0x00df, #LATIN SMALL LETTER SHARP S
    0x0393, #GREEK CAPITAL LETTER GAMMA
    0x03c0, #GREEK SMALL LETTER PI
    0x03a3, #GREEK CAPITAL LETTER SIGMA
    0x03c3, #GREEK SMALL LETTER SIGMA
    0x00b5, #MICRO SIGN
    0x03c4, #GREEK SMALL LETTER TAU
    0x03a6, #GREEK CAPITAL LETTER PHI
    0x0398, #GREEK CAPITAL LETTER THETA
    0x03a9, #GREEK CAPITAL LETTER OMEGA
    0x03b4, #GREEK SMALL LETTER DELTA
    0x221e, #INFINITY
    0x03c6, #GREEK SMALL LETTER PHI
    0x03b5, #GREEK SMALL LETTER EPSILON
    0x2229, #INTERSECTION
    0x2261, #IDENTICAL TO
    0x00b1, #PLUS-MINUS SIGN
    0x2265, #GREATER-THAN OR EQUAL TO
    0x2264, #LESS-THAN OR EQUAL TO
    0x2320, #TOP HALF INTEGRAL
    0x2321, #BOTTOM HALF INTEGRAL
    0x00f7, #DIVISION SIGN
    0x2248, #ALMOST EQUAL TO
    0x00b0, #DEGREE SIGN
    0x2219, #BULLET OPERATOR
    0x00b7, #MIDDLE DOT
    0x221a, #SQUARE ROOT
    0x207f, #SUPERSCRIPT LATIN SMALL LETTER N
    0x00b2, #SUPERSCRIPT TWO
    0x25a0, #BLACK SQUARE
    0x00a0, #NO-BREAK SPACE
]

########

proc uint32_2_Color*(col: uint32): Color = # this takes a 24-bit color value (html) and converts it to Color with a = 0xFF
    let
        r = uint8((col shr 16) and 0xFF)
        g = uint8((col shr 8) and 0xFF)
        b = uint8(col and 0xFF)
    result = Color(r:r, g:g, b:b, a:0xFF)

proc Color_2_uint32*(col: Color): uint32 = # this takes a Color object and converts it to the 24-bit color value (discarding alpha)
    #result = 0xFF000000.uint32 + col.r.uint32 shl 16 + col.g.uint32 shl 8 + col.b.uint32
    result = col.r.uint32 shl 16 + col.g.uint32 shl 8 + col.b.uint32

proc RGB_2_uint32*(r: int, g: int, b: int): uint32 = # this takes a Color object and converts it to the 24-bit color value (discarding alpha)
    #result = 0xFF000000.uint32 + col.r.uint32 shl 16 + col.g.uint32 shl 8 + col.b.uint32
    result = r.uint32 shl 16 + g.uint32 shl 8 + b.uint32

######## global vars

const buffsize = 3200 
var
    font: Font
    render_tx: RenderTexture2D
    shader: Shader
    t_now: cfloat
    timeLoc: cint
    text_rbuffer: array[buffsize, int]
    text_c1buffer: array[buffsize, uint32]
    text_c2buffer: array[buffsize, uint32]

######## objects

type Region* = ref object of RootObj
    text_rbuffer*: seq[int]
    text_c1buffer*: seq[uint32]
    text_c2buffer*: seq[uint32]
    blitlevel*: int
    alpha_color*: uint32
    extend*: Vector2i
    pos*: Vector2i
    id*: int

type Sprite* = ref object of RootObj
    text_rbuffer*: seq[int]
    text_c1buffer*: seq[uint32]
    text_c2buffer*: seq[uint32]
    chr_vecs*: seq[Vector2i]
    blitlevel*: int
    extend*: Vector2i
    pos*: Vector2i
    id*: int

type Console* = ref object of RootObj
    running: bool
    fontsize_y*: int
    fontsize_x*: int
    font_dx*: int
    font_dy*: int
    lineheight*: int
    num_cells_x*: int
    num_cells_y*: int
    border_cells_x*: int
    border_cells_y*: int
    screen_x: int
    screen_y: int
    border_color*: uint32
    border_show*: bool
    use_crt_shader*: bool
    text_color*: uint32
    background_color*: uint32
    viewport*: Vector2i
    cursoridx: int

########### Region methods #########################

method copy*(self: Region): Region {.base.} = # warning must be overriden in derived types
    result = new Region
    result.text_rbuffer = self.text_rbuffer
    result.text_c1buffer = self.text_c1buffer
    result.text_c2buffer = self.text_c2buffer
    result.blitlevel = self.blitlevel
    result.alpha_color = self.alpha_color
    result.extend = self.extend
    result.pos = self.pos
    result.id = self.id

method scaledcopy*(self: Region, tgt_extend: Vector2i): Region {.base.} = # warning must be overriden in derived types
    result = new Region
    if tgt_extend.x < 2 or tgt_extend.y < 2:
        echo ("Error: illegal operands to scaledcopy!")
        return # result
    let
        extend_x = float(self.extend.x)
        extend_y = float(self.extend.y)
        t2s_sc_x = extend_x / float(tgt_extend.x) # target-to-source (inverse) scaling factor
        t2s_sc_y = extend_y / float(tgt_extend.y)
    for i in 0 ..< tgt_extend.y:
        for j in 0 ..< tgt_extend.x:
            let src_idx = int(floor(t2s_sc_y * float(i) + 0.5) * extend_x + floor(t2s_sc_x * float(j) + 0.5)).clamp(0, len(self.text_rbuffer) - 1)
            result.text_rbuffer.add(self.text_rbuffer[src_idx])
            result.text_c1buffer.add(self.text_c1buffer[src_idx])
            result.text_c2buffer.add(self.text_c2buffer[src_idx])
    assert(len(result.text_rbuffer) == tgt_extend.x * tgt_extend.y)
    result.blitlevel = self.blitlevel
    result.alpha_color = self.alpha_color
    result.extend = tgt_extend
    result.pos = self.pos
    result.id = self.id

# interface to regions and sprites (blit, retrieve screen regions)
method blit*(self: Region, c: Console) {.base.} =
    # TODO: rewrite with Vector2i ?
    let
        extend_x = self.extend.x
        extend_y = self.extend.y
        num_cells_x = c.num_cells_x
        num_cells_y = c.num_cells_y
        screen_size = num_cells_x * num_cells_y
    var
        col = self.pos.x - c.viewport.x
        row = self.pos.y - c.viewport.y
        portion_x = extend_x # this will hold the rectangular effective blit area
        portion_y = extend_y
        offset_x = 0 # offset coordinates in the region
        offset_y = 0 
        cursoridx = -1
    # determine the section of the region which will get blitted to the viewport
    if col + portion_x > num_cells_x:
        portion_x = num_cells_x - col
    elif col < 0:
        portion_x = portion_x + col
        offset_x = -col
        col = 0
    if row + portion_y > num_cells_y:
        portion_y = num_cells_y - row
    elif row < 0:
        portion_y = portion_y + row
        offset_y = -row
        row = 0
    #echo ("Debug: adjusted row, col: ", col, ", ", row)
    #echo ("Debug: region offsets: ", offset_y, ", ", offset_x)
    #echo ("Debug: region portions: ", portion_y, ", ", portion_x)
    if self.blitlevel == 2:
        for i in 0 ..< portion_y:
            for j in 0 ..< portion_x:
                let src_idx = (offset_x + j) + extend_x * (offset_y + i)
                let curr_chr = self.text_rbuffer[src_idx]
                let backcolor = self.text_c2buffer[src_idx]
                if curr_chr != 0x20 or backcolor != self.alpha_color:
                    let tgt_idx = (col + j) + num_cells_x * (row + i)
                    if tgt_idx >= 0 and tgt_idx < screen_size:
                        text_rbuffer[tgt_idx] = curr_chr
                        text_c1buffer[tgt_idx] = self.text_c1buffer[src_idx]
                        text_c2buffer[tgt_idx] = backcolor
                        cursoridx = tgt_idx
                    else:
                        echo "Debug indices: src: ", src_idx, ", tgt: ", tgt_idx
    elif self.blitlevel == 1:
        for i in 0 ..< portion_y:
            for j in 0 ..< portion_x:
                let src_idx = (offset_x + j) + extend_x * (offset_y + i)
                let curr_chr = self.text_rbuffer[src_idx]
                if curr_chr != 0x20:
                    let tgt_idx = (col + j) + num_cells_x * (row + i)
                    if tgt_idx >= 0 and tgt_idx < screen_size:
                        text_rbuffer[tgt_idx] = curr_chr
                        text_c1buffer[tgt_idx] = self.text_c1buffer[src_idx]
                        cursoridx = tgt_idx
                    else:
                        echo "Debug indices: src: ", src_idx, ", tgt: ", tgt_idx
    elif self.blitlevel == 0:
        for i in 0 ..< portion_y:
            for j in 0 ..< portion_x:
                let curr_chr = self.text_rbuffer[(offset_x + j) + extend_x * (offset_y + i)]
                if curr_chr != 0x20:
                    let tgt_idx = (col + j) + num_cells_x * (row + i)
                    if tgt_idx >= 0 and tgt_idx < screen_size:
                        text_rbuffer[tgt_idx] = curr_chr
                        cursoridx = tgt_idx
                    else:
                        echo "Debug indices: tgt: ", tgt_idx
    # advance the cursor from the last write index (cursoridx) by incrementing by 1
    if cursoridx != -1:
        if cursoridx < screen_size - 1:
            c.cursoridx = cursoridx + 1
        else: # if the cursor is at the last character of the screen, we cannot advance it
            c.cursoridx = cursoridx
    
method modblit*(self: Region, c: Console) {.base.} =
    # TODO: rewrite with Vector2i ?
    let
        extend_x = self.extend.x
        extend_y = self.extend.y
        num_cells_x = c.num_cells_x
        num_cells_y = c.num_cells_y
        offset_x = c.viewport.x - self.pos.x # offset relative to the viewport
        offset_y = c.viewport.y - self.pos.y
    var cursoridx = -1
    if self.blitlevel == 2:
        for i in 0 ..< num_cells_y:
            for j in 0 ..< num_cells_x:
                var col = (offset_x + j) mod extend_x
                if col < 0: col += extend_x
                var row = (offset_y + i) mod extend_y
                if row < 0: row += extend_y
                let src_idx =  col + extend_x * row
                let curr_chr = self.text_rbuffer[src_idx]
                let backcolor = self.text_c2buffer[src_idx]
                if curr_chr != 0x20 or backcolor != self.alpha_color:
                    let tgt_idx = j + num_cells_x * i
                    #print "Debug indices: src: " + src_idx + ", tgt: " + tgt_idx
                    text_rbuffer[tgt_idx] = curr_chr
                    text_c1buffer[tgt_idx] = self.text_c1buffer[src_idx]
                    text_c2buffer[tgt_idx] = backcolor
                    cursoridx = tgt_idx
    elif self.blitlevel == 1:
        for i in 0 ..< num_cells_y:
            for j in 0 ..< num_cells_x:
                var col = (offset_x + j) mod extend_x
                if col < 0: col += extend_x
                var row = (offset_y + i) mod extend_y
                if row < 0: row += extend_y
                let src_idx =  col + extend_x * row
                let curr_chr = self.text_rbuffer[src_idx]
                if curr_chr != 0x20:
                    let tgt_idx = j + num_cells_x * i
                    #print "Debug indices: src: " + src_idx + ", tgt: " + tgt_idx
                    text_rbuffer[tgt_idx] = curr_chr
                    text_c1buffer[tgt_idx] = self.text_c1buffer[src_idx]
                    cursoridx = tgt_idx
    elif self.blitlevel == 0:
        for i in 0 ..< num_cells_y:
            for j in 0 ..< num_cells_x:
                var col = (offset_x + j) mod extend_x
                if col < 0: col += extend_x
                var row = (offset_y + i) mod extend_y
                if row < 0: row += extend_y
                let src_idx =  col + extend_x * row
                let curr_chr = self.text_rbuffer[src_idx]
                if curr_chr != 0x20:
                    let tgt_idx = j + num_cells_x * i
                    text_rbuffer[tgt_idx] = curr_chr
                    cursoridx = tgt_idx
    # advance the cursor from the last write index (cursoridx) by incrementing the index by 1
    if cursoridx != -1:
        if cursoridx < num_cells_x * num_cells_y - 1:
            c.cursoridx = cursoridx + 1
        else: # if the cursor is at the last character of the screen, we cannot advance it
            c.cursoridx = cursoridx

method fromREXPaint*(self: Region, REXPaint_csv: string, alpha_color: uint32) {.base.} = 
    var
        line_idx = 0
        col_min = 99999999
        col_max = -1
        row_min = 99999999
        row_max = -1
        c: CsvParser
        s = newFileStream(REXPaint_csv, fmRead)
    if s == nil:
        echo("cannot open the file" & REXPaint_csv)
        return
    self.text_rbuffer.setLen(0)
    self.text_c1buffer.setLen(0)
    self.text_c2buffer.setLen(0)
    self.alpha_color = alpha_color
    self.blitlevel = 2 # default
    # 1st pass: find bounding box
    open(c, s, REXPaint_csv)
    c.readHeaderRow() # read (and discard) header
    while c.readRow():
        line_idx += 1
        if len(c.row) == 5:
            let
                (x, y, chr) = (parseInt(c.row[0]), parseInt(c.row[1]), parseInt(c.row[2]))
                chbgcol = uint32(parseHexInt("0x" & c.row[4].substr(1)))
            # determine bounding box
            if chr != 0x20 or chbgcol != self.alpha_color: #if chr != 0x20:
                if x < col_min: col_min = x
                if x > col_max: col_max = x
                if y < row_min: row_min = y
                if y > row_max: row_max = y
                # echo ("Chr: ", x, y, chr, chbgcol, self.alpha_color) # Debug
        else:
            echo("Error parsing file " & REXPaint_csv & ", line: ", line_idx)
    close(c)
    # 2nd pass: capture region in bounding box
    s = newFileStream(REXPaint_csv, fmRead)
    open(c, s, REXPaint_csv)
    c.readHeaderRow() # read (and discard) header
    while c.readRow():
        let (x, y, chr) = (parseInt(c.row[0]), parseInt(c.row[1]), parseInt(c.row[2]))
        if x >= col_min and x <= col_max and y >= row_min and y <= row_max: # inside bounding box            
            # convert html color strings to uint32
            let
                chfgcol = uint32(parseHexInt("0x" & c.row[3].substr(1)))
                chbgcol = uint32(parseHexInt("0x" & c.row[4].substr(1)))
            self.text_rbuffer.add(cp437_to_unicode[chr])
            self.text_c1buffer.add(chfgcol)
            self.text_c2buffer.add(chbgcol)
            #let tmp1 = uint32_2_Color(chfgcol) # Debug
            #echo (x, y, cp437_to_unicode[chr], chfgcol, chbgcol, "   ", tmp1.r, tmp1.g, tmp1.b) # Debug
    close(c)    
    if line_idx > 0: self.extend = (col_max - col_min + 1, row_max - row_min + 1) # did we read ANYTHING? --> then we can define the extend
    self.pos = (0, 0)
    assert(len(self.text_rbuffer) == self.extend.x * self.extend.y, "Error processing REXPAINT -- dimension mismatch")

method fromstring*(self: Region, txt: string, tcol: uint32, bcol: uint32, alpha_color: uint32, startcol: int = 0, wraplen: int = 0) {.base.} =
    ## TODO: think about and/or implement the scroll function
    assert startcol >= 0 and (wraplen == 0 or startcol < wraplen), fmt("{startcol} {wraplen} {startcol >= 0} {wraplen == 0 or startcol < wraplen}")
    const tab_num_spaces = 4
    var
        col = startcol
        row = 0
        col_max = 0
        col_min = col
    # initialise/reset Sprite fields
    self.text_rbuffer.setLen(0)
    self.text_c1buffer.setLen(0)
    self.text_c2buffer.setLen(0)
    self.alpha_color = alpha_color
    self.blitlevel = 2 # default
    # we ignore pos (defaults to (0, 0) anyhow); extend is set at the end
    # 1st pass -- determine the region geometry
    for ch in txt:
        let asciival = ord(ch)
        case asciival:
            of 9: # \t
                for i in 0 ..< tab_num_spaces:
                    if col < col_min: col_min = col # check for new icol min
                    col += 1 # advance insert position
                    if col > col_max: col_max = col # check for new icol max
                    if wraplen > 0 and col >= wraplen: (col, row) = (0, row + 1)
            of 10: # \n
                if col < col_min: col_min = col # check for new icol min
                if wraplen > 0 and wraplen > col_max: col_max = wraplen # this is because we fill the line with spaces!
                col = 0 # new insert position on next line
                row += 1
            else: # other characters
                if col < col_min: col_min = col # check for new icol min
                col += 1 # advance insert position
                if col > col_max: col_max = col # check for new icol max
                if wraplen > 0 and col >= wraplen: (col, row) = (0, row + 1)
    #echo fmt"debug: col_min = {col_min}, col_max = {col_max}, col = {col}, row = {row}"
    # 2nd pass -- write the region    
    if col_min < startcol: # did we have carriage return or wrap events?
        # we need to first perform any space filling of the incomplete first line
        for i in 0 ..< startcol:
            self.text_rbuffer.add(0x20)
            self.text_c1buffer.add(tcol)
            self.text_c2buffer.add(self.alpha_color)
        #echo fmt"debug first line padding: {self.text_rbuffer.len}"
    col = startcol
    row = 0
    for ch in txt:
        let asciival = ord(ch)        
        case asciival:
            of 9: # \t
                #echo fmt"adding {tab_num_spaces} space chrs for tab"
                for i in 0 ..< tab_num_spaces:
                    self.text_rbuffer.add(0x20)
                    self.text_c1buffer.add(tcol)
                    self.text_c2buffer.add(bcol)
                    col += 1 # advance insert position
                    if wraplen > 0 and col >= wraplen: (col, row) = (0, row + 1)
            of 10: # \n
                # fill the line with spaces
                #echo fmt"adding {col_max - col} space chrs for newline"
                for i in 0 ..< col_max - col:
                    self.text_rbuffer.add(0x20)
                    self.text_c1buffer.add(tcol)
                    self.text_c2buffer.add(self.alpha_color)
                (col, row) = (0, row + 1) # new insert position on next line
            else: # other characters
                self.text_rbuffer.add(asciival)
                self.text_c1buffer.add(tcol)
                self.text_c2buffer.add(bcol)
                col += 1 # advance insert position
                if wraplen > 0 and col >= wraplen: (col, row) = (0, row + 1)
    # fill last row with spaces up to colmax?
    if col > 0: # if on the last character col == 0, then we do not add 1 to the y-extend
        for i in 0 ..< col_max - col:
            self.text_rbuffer.add(0x20)
            self.text_c1buffer.add(tcol)
            self.text_c2buffer.add(self.alpha_color)
        #echo fmt"debug last line padding: {col_max - col - 1}"
        self.extend = (col_max - col_min, row + 1)
    else:
        self.extend = (col_max - col_min, row) # a line without characters (this case) does not need to be considered
    #self.alpha_color = 0x7e7e7e # debug color
    self.pos.x = col_min
    assert self.extend.x * self.extend.y == self.text_rbuffer.len, fmt"{self.extend} vs. {self.text_rbuffer.len}"
    #echo fmt"Debug extend: {self.extend}, buffer length: {self.text_rbuffer.len}"

########### Sprite methods #########################

method fromregion*(self: Sprite, r: Region) {.base.} =
    self.text_rbuffer.setLen(0)
    self.text_c1buffer.setLen(0)
    self.text_c2buffer.setLen(0)
    self.chr_vecs.setLen(0)
    self.blitlevel = r.blitlevel
    self.extend = r.extend
    self.pos = r.pos
    for i in 0 ..< r.extend.y:
        for j in 0 ..< r.extend.x:
            let
                src_idx = i * r.extend.x + j
                curr_chr = r.text_rbuffer[src_idx]
                backcolor = r.text_c2buffer[src_idx]
            if curr_chr != 0x20 or backcolor != r.alpha_color:
                self.chr_vecs.add(Vector2i(x:j, y:i))
                self.text_rbuffer.add(curr_chr)
                self.text_c1buffer.add(r.text_c1buffer[src_idx])
                self.text_c2buffer.add(backcolor)

method fromREXPaint*(self: Sprite, REXPaint_csv: string, alpha_color: uint32) {.base.} =
    let r = new Region
    r.fromREXPaint(REXPaint_csv, alpha_color)
    self.fromregion(r)

method fromstring*(self: Sprite, txt: string, tcol: uint32, bcol: uint32, startcol: int = 0, wraplen: int = 0, scroll: bool = false) {.base.} =
    assert startcol >= 0 and (wraplen == 0 or startcol < wraplen), fmt("{startcol} {wraplen} {startcol >= 0} {wraplen == 0 or startcol < wraplen}")
    const tab_num_spaces = 4
    var
        col = startcol
        row = 0
        col_max = 0
        col_min = col
    # initialise/reset Sprite fields
    self.text_rbuffer.setLen(0)
    self.text_c1buffer.setLen(0)
    self.text_c2buffer.setLen(0)
    self.chr_vecs.setLen(0)
    self.blitlevel = 2 # default
    # we ignore pos (defaults to (0, 0) anyhow); extend is set at the end
    for i  in 0 ..< txt.len:
        let asciival = ord(txt[i])
        let peekval = if i == txt.len - 1: -1 else: ord(txt[i + 1])
        case asciival:
            of 9: # \t
                for j in 0 ..< tab_num_spaces:
                    if col < col_min: col_min = col # check for new icol min
                    self.text_rbuffer.add(0x20)
                    self.text_c1buffer.add(tcol)
                    self.text_c2buffer.add(bcol)
                    self.chr_vecs.add(Vector2i(x:col, y:row))
                    col += 1 # advance insert position
                    if col > col_max: col_max = col # check for new icol max
                    if wraplen > 0 and col >= wraplen and ((j < tabnumspaces - 1) or peekval != 10): (col, row) = (0, row + 1)
            of 10: # \n
                if col < col_min: col_min = col # check for new icol min
                (col, row) = (0, row + 1) # new insert position on next line
            else: # other characters
                if col < col_min: col_min = col # check for new icol min
                self.text_rbuffer.add(asciival)
                self.text_c1buffer.add(tcol)
                self.text_c2buffer.add(bcol)
                self.chr_vecs.add(Vector2i(x:col, y:row))    
                col += 1 # advance insert position
                if col > col_max: col_max = col # check for new icol max
                if wraplen > 0 and col >= wraplen and peekval != 10: (col, row) = (0, row + 1)
    # update sprite extend
    if col > 0: # if on the last character col == 0, then we do not add 1 to the y-extend
        self.extend = (col_max - col_min, row + 1)
    else:
        self.extend = (col_max - col_min, row)
    #echo fmt"Debug extend: {self.extend}, buffer length: {self.text_rbuffer.len}"

method copy*(self: Sprite): Sprite {.base.} = # warning must be overriden in derived types
    result = new Sprite
    result.text_rbuffer = self.text_rbuffer
    result.text_c1buffer = self.text_c1buffer
    result.text_c2buffer = self.text_c2buffer
    result.chr_vecs = self.chr_vecs
    result.blitlevel = self.blitlevel
    result.extend = self.extend
    result.pos = self.pos
    result.id = self.id

method copyfrom*(self: Sprite, src: Sprite, copy_pos: bool) {.base.} =
    self.text_rbuffer = src.text_rbuffer
    self.text_c1buffer = src.text_c1buffer
    self.text_c2buffer = src.text_c2buffer
    self.chr_vecs = src.chr_vecs
    self.blitlevel = src.blitlevel
    self.extend = src.extend
    if copy_pos: self.pos = src.pos
    self.id = src.id

method section*(self: Sprite, col_start: int, row_start: int, width: int, height: int): Sprite {.base.} =
    result = new Sprite
    # instead of doing these tests as asserts, we simply return an empty sprite in these cases..
    if width <= 0 or height <= 0: return
    if (col_start >= 0 and col_start < self.extend.x and col_start + width - 1 < self.extend.x) and (row_start >= 0 and row_start < self.extend.y and row_start + height - 1 < self.extend.y):
        result.pos = (col_start, row_start)
        let pos_max = result.pos + (width - 1, height - 1)
        var m: Vector2i = (-1, -1)
        for i in 0 ..< self.chr_vecs.len:
            let pos = self.chr_vecs[i]
            if pos >= result.pos and pos <= pos_max:
                m = Vector2i_max(m, pos)
                result.text_rbuffer.add(self.text_rbuffer[i])
                result.text_c1buffer.add(self.text_c1buffer[i])
                result.text_c2buffer.add(self.text_c2buffer[i])
                result.chr_vecs.add(self.chr_vecs[i] - result.pos)
        result.blitlevel = self.blitlevel
        result.extend = (1, 1) + m  - result.pos
        result.id = self.id
    #else:
        #echo "(col_start >= 0 and col_start < self.extend.x and col_start + width - 1 < self.extend.x) and (row_start >= 0 and row_start < self.extend.y and row_start + height - 1 < self.extend.y)"
        #echo fmt"{col_start >= 0} {col_start < self.extend.x} {col_start + width - 1 < self.extend.x} {row_start >= 0} {row_start < self.extend.y} {row_start + height - 1 < self.extend.y}"

method hflip*(self: Sprite, cp437_char_mirroring: bool) {.base.} =
    if cp437_char_mirroring:
        for i in 0 ..< len(self.chr_vecs):
            self.chr_vecs[i].x = self.extend.x - self.chr_vecs[i].x
            case self.text_rbuffer[i]
            of 9658: self.text_rbuffer[i] = 9668 # triangle
            of 8594: self.text_rbuffer[i] = 8592 # arrow
            of 40  : self.text_rbuffer[i] = 41   # ()
            of 47  : self.text_rbuffer[i] = 92   # /\
            of 60  : self.text_rbuffer[i] = 62   # <>
            of 91  : self.text_rbuffer[i] = 93   # []
            of 123 : self.text_rbuffer[i] = 125  # {}
            of 8976: self.text_rbuffer[i] = 172  # uneven corner
            of 171 : self.text_rbuffer[i] = 187  # double bracket
            of 9508: self.text_rbuffer[i] = 9500  # single lines...
            of 9492: self.text_rbuffer[i] = 9496 
            of 9484: self.text_rbuffer[i] = 9488 
            of 9571: self.text_rbuffer[i] = 9568  # double lines...
            of 9562: self.text_rbuffer[i] = 9565 
            of 9556: self.text_rbuffer[i] = 9559 
            of 9569: self.text_rbuffer[i] = 9566  # mixed lines...
            of 9570: self.text_rbuffer[i] = 9567 
            of 9561: self.text_rbuffer[i] = 9564 
            of 9560: self.text_rbuffer[i] = 9563 
            of 9554: self.text_rbuffer[i] = 9557 
            of 9555: self.text_rbuffer[i] = 9558 
            of 9612: self.text_rbuffer[i] = 9616  # halves
            of 8805: self.text_rbuffer[i] = 8804  # >=/<=
            # and the other way around
            of 9668: self.text_rbuffer[i] = 9658 # triangle
            of 8592: self.text_rbuffer[i] = 8594 # arrow
            of 41  : self.text_rbuffer[i] = 40   # ()
            of 92  : self.text_rbuffer[i] = 47   # /\
            of 62  : self.text_rbuffer[i] = 60   # <>
            of 93  : self.text_rbuffer[i] = 91   # []
            of 125 : self.text_rbuffer[i] = 123  # {}
            of 172 : self.text_rbuffer[i] = 8976 # uneven corner
            of 187 : self.text_rbuffer[i] = 171  # double bracket
            of 9500: self.text_rbuffer[i] = 9508  # single lines...
            of 9496: self.text_rbuffer[i] = 9492 
            of 9488: self.text_rbuffer[i] = 9484 
            of 9568: self.text_rbuffer[i] = 9571  # double lines...
            of 9565: self.text_rbuffer[i] = 9562 
            of 9559: self.text_rbuffer[i] = 9556 
            of 9566: self.text_rbuffer[i] = 9569  # mixed lines...
            of 9567: self.text_rbuffer[i] = 9570 
            of 9564: self.text_rbuffer[i] = 9561 
            of 9563: self.text_rbuffer[i] = 9560 
            of 9557: self.text_rbuffer[i] = 9554 
            of 9558: self.text_rbuffer[i] = 9555 
            of 9616: self.text_rbuffer[i] = 9612  # halves
            of 8804: self.text_rbuffer[i] = 8805  # >=/<=
            else:
                discard
    else:
        for i in 0 ..< len(self.chr_vecs):
            self.chr_vecs[i].x = self.extend.x - self.chr_vecs[i].x

method vflip*(self: Sprite, cp437_char_mirroring: bool) {.base.} =    
    if cp437_char_mirroring:
        for i in 0 ..< len(self.chr_vecs):
            self.chr_vecs[i].y = self.extend.y - self.chr_vecs[i].y
            case self.text_rbuffer[i]
            of 9650: self.text_rbuffer[i] = 9660 # arrow
            of 47  : self.text_rbuffer[i] = 92   # triangle
            of 9524: self.text_rbuffer[i] = 9516 # /\
            of 9492: self.text_rbuffer[i] = 9484 # single lines...
            of 9488: self.text_rbuffer[i] = 9496 #
            of 9577: self.text_rbuffer[i] = 9574 #
            of 9562: self.text_rbuffer[i] = 9556 # double lines...
            of 9559: self.text_rbuffer[i] = 9565 #
            of 9576: self.text_rbuffer[i] = 9573 #
            of 9575: self.text_rbuffer[i] = 9572 # mixed lines...
            of 9561: self.text_rbuffer[i] = 9555 #
            of 9560: self.text_rbuffer[i] = 9554 #
            of 9558: self.text_rbuffer[i] = 9564 #
            of 9557: self.text_rbuffer[i] = 9563 #
            of 9604: self.text_rbuffer[i] = 9600 #
            of 8595: self.text_rbuffer[i] = 8593 # halves
            # and the other way around
            of 9660: self.text_rbuffer[i] = 9650 # arrow
            of 92  : self.text_rbuffer[i] = 47   # triangle
            of 9516: self.text_rbuffer[i] = 9524 # /\
            of 9484: self.text_rbuffer[i] = 9492 # single lines...
            of 9496: self.text_rbuffer[i] = 9488 #
            of 9574: self.text_rbuffer[i] = 9577 #
            of 9556: self.text_rbuffer[i] = 9562 # double lines...
            of 9565: self.text_rbuffer[i] = 9559 #
            of 9573: self.text_rbuffer[i] = 9576 #
            of 9572: self.text_rbuffer[i] = 9575 # mixed lines...
            of 9555: self.text_rbuffer[i] = 9561 #
            of 9554: self.text_rbuffer[i] = 9560 #
            of 9564: self.text_rbuffer[i] = 9558 #
            of 9563: self.text_rbuffer[i] = 9557 #
            of 9600: self.text_rbuffer[i] = 9604 #
            of 8593: self.text_rbuffer[i] = 8595 # halves
            else:
                discard
    else:
        for i in 0 ..< len(self.chr_vecs):
            self.chr_vecs[i].y = self.extend.y - self.chr_vecs[i].y

method blit*(self: Sprite, c: Console) {.base.} =
    let
        ulc = c.viewport
        lrc: Vector2i = ulc + (c.num_cells_x - 1, c.num_cells_y - 1)
        num_cells_x = c.num_cells_x
        screen_size = c.num_cells_x * c.num_cells_y
    var cursoridx = -1
    if self.blitlevel == 2:
        for i in 0 ..< self.chr_vecs.len:
            let
                chr_pos = self.chr_vecs[i] + self.pos
                chr_pos_in_c = chr_pos - ulc
            if chr_pos_in_c * (lrc - chr_pos) >= 0:
                let tgt_idx = chr_pos_in_c.x + num_cells_x * chr_pos_in_c.y
                if tgt_idx >= 0 and tgt_idx < screen_size:
                    text_rbuffer[tgt_idx] = self.text_rbuffer[i]
                    text_c1buffer[tgt_idx] = self.text_c1buffer[i]
                    text_c2buffer[tgt_idx] = self.text_c2buffer[i]
                    cursoridx = tgt_idx
                else:
                    echo "Debug indices: tgt: ", tgt_idx
    elif self.blitlevel == 1:
        for i in 0 ..< self.chr_vecs.len:
            let
                chr_pos = self.chr_vecs[i] + self.pos
                chr_pos_in_c = chr_pos - ulc
            if chr_pos_in_c * (lrc - chr_pos) >= 0:
                let tgt_idx = chr_pos_in_c.x + num_cells_x * chr_pos_in_c.y
                if tgt_idx >= 0 and tgt_idx < screen_size:
                    text_rbuffer[tgt_idx] = self.text_rbuffer[i]
                    text_c1buffer[tgt_idx] = self.text_c1buffer[i]
                    cursoridx = tgt_idx
                else:
                    echo "Debug indices: tgt: ", tgt_idx
    elif self.blitlevel == 0:
        for i in 0 ..< self.chr_vecs.len:
            let
                chr_pos = self.chr_vecs[i] + self.pos
                chr_pos_in_c = chr_pos - ulc
            if chr_pos_in_c * (lrc - chr_pos) >= 0:
                let tgt_idx = chr_pos_in_c.x + num_cells_x * chr_pos_in_c.y
                if tgt_idx >= 0 and tgt_idx < screen_size:
                    text_rbuffer[tgt_idx] = self.text_rbuffer[i]
                    cursoridx = tgt_idx
                else:
                    echo "Debug indices: tgt: ", tgt_idx
    # save last write operation position
    if cursoridx != -1:
        if cursoridx < screen_size - 1:
            c.cursoridx = cursoridx + 1
        else: # if the cursor is at the last character of the screen, we cannot advance it
            c.cursoridx = cursoridx

method collisiontest*(self: Sprite, s: Sprite, detailed: bool = true): bool {.base.} =
    # 1st # bounding box overlap test, and only if overlap in bounding box then proceed
    # with the detailed character collision test #> gains ~20% performance in collisiontest
    let extmax = Vector2i_max(self.extend, s.extend)
    let dist_vec = s.pos - self.pos
    # test both the vector joining the upper left corners and the vector joining the lower right corners to be shorter than the maximum of the extends in each dimension.
    if (Vector2i_abs(dist_vec) < extmax) and (Vector2i_abs(dist_vec + s.extend - self.extend) < extmax):
        if detailed:
            # 2nd # detailed test collisions in the character coordinate vectors, only performed if the bounding boxes collided
            for j in 0 ..< len(s.chr_vecs): # loop over the other sprite's chars
                let testpos = dist_vec + s.chr_vecs[j]
                for i in 0 ..< len(self.chr_vecs): # loop over our chars
                    if self.chr_vecs[i] == testpos:
                        return true
        else:
            return true
    return false

method occupies*(self: Sprite, pos: Vector2i): bool {.base.} =
    let dist_vec = pos - self.pos
    for i in 0 ..< len(self.chr_vecs): # loop over our chars
        if self.chr_vecs[i] == dist_vec:
            return true
    return false

method collisiontest*(self: Sprite, r: Region): bool {.base.} =
    # bounding box overlap test
    let
        extmax = Vector2i_max(self.extend, r.extend)
        dist_vec = r.pos - self.pos
    # test both the vector joining the upper left corners and the vector joining the lower right corners to be shorter than the maximum of the extends in each dimension.
    return (Vector2i_abs(dist_vec) < extmax) and (Vector2i_abs(dist_vec + r.extend - self.extend) < extmax)

########### Console methods #########################

proc init*(self: Console) =
    self.fontsize_y = 16
    self.fontsize_x = 16
    self.font_dx = 1
    self.font_dy = 1
    self.lineheight = 16
    self.num_cells_x = 40
    self.num_cells_y = 25
    self.border_cells_x = 3
    self.border_cells_y = 2
    self.border_color = 0x323232
    self.border_show = true
    self.use_crt_shader = false
    self.viewport = (0, 0)
    self.text_color = 0x0
    self.background_color = 0x505050

proc open*(self: Console, wd_title: string, font_fname: string, font_max_char: int = 0) =
    assert self.num_cells_x * self.num_cells_y < buffsize
    if self.border_show:
        self.screen_x = (self.num_cells_x + 2 * self.border_cells_x) * self.fontsize_x
        self.screen_y = (self.num_cells_y + 2 * self.border_cells_y) * self.fontsize_y
    else:
        self.screen_x = self.num_cells_x * self.fontsize_x
        self.screen_y = self.num_cells_y * self.fontsize_y
    #setConfigFlags(0x00000004)
    setConfigFlags(ConfigFlags.WINDOW_RESIZABLE) # Set to allow resizable window
    initWindow(self.screen_x, self.screen_y, wd_title)
    #Raylib.SetTargetFPS(60) # Set our game to run at 60 frames-per-second
    # NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
    render_tx = loadRenderTexture(self.screen_x, self.screen_y)
    if font_fname[^3 .. ^1] == "ttf":
        font = loadFontEx(font_fname, self.fontsize_y, nil, font_max_char) # TTF FONT
    else:
        font = loadFont(font_fname) # BITMAP FONT
    setTextureFilter(font.texture, 1)
    shader = loadShader(nil, "shaders/crt.fs")
    timeLoc = getShaderLocation(shader, "time")
    self.running = true

proc embedded_open*(self: Console, font_fname: string, font_max_char: int = 0) =
    self.border_show = false
    self.screen_x = self.num_cells_x * self.fontsize_x
    self.screen_y = self.num_cells_y * self.fontsize_y
    render_tx = loadRenderTexture(self.screen_x, self.screen_y)
    if font_fname[^3 .. ^1] == "ttf":
        font = loadFontEx(font_fname, self.fontsize_y, nil, font_max_char) # TTF FONT
    else:
        font = loadFont(font_fname) # BITMAP FONT
    setTextureFilter(font.texture, 1)
    #shader = loadShader(nil, "crt.fs")
    #timeLoc = getShaderLocation(shader, "time")
    self.running = true

proc embedded_close*(self: Console) =
    unloadFont(font)
    unloadRenderTexture(render_tx)
    unloadShader(shader)

proc randomize*(self: Console) =
    var idx: int = 0
    for j in 0 ..< self.num_cells_y: # loop over rows
        for i in 0 ..< self.num_cells_x: # loop over cols
            text_rbuffer[idx] = 0x20 + rand(90)
            text_c1buffer[idx] = rand(0xFFFFFF.uint32)
            text_c2buffer[idx] = rand(0xFFFFFF.uint32)
            idx += 1

proc clr*(self: Console) =
    let tcol = self.text_color
    let bcol = self.background_color
    for i in 0 ..< self.num_cells_x * self.num_cells_y:
        text_rbuffer[i] = 0x20
        text_c1buffer[i] = tcol
        text_c2buffer[i] = bcol

proc textdraw(self: Console) =
    let
        fontsize_x = self.fontsize_x
        fontsize_y = self.fontsize_y
        fontspacing: cfloat = 0.0
        fdx = self.font_dx
        fdy = self.font_dy
    var
        col_pix: int = 0
        row_pix: int = (if self.border_show: self.border_cells_y * self.fontsize_y else: 0)
        col_pix0: int = (if self.border_show: self.border_cells_x * self.fontsize_x else: 0)
        idx: int = 0
    for j in 0 ..< self.num_cells_y: # loop over rows
        col_pix = col_pix0
        for i in 0 ..< self.num_cells_x: # loop over cols
            # background
            drawRectangle(col_pix, row_pix, fontsize_x, fontsize_y, uint32_2_Color(text_c2buffer[idx]))
            let chr = text_rbuffer[idx]
            if chr != 0x20:
                drawTextEx(font, toUTF8(chr.Rune), (float(col_pix + fdx), float(row_pix + fdy)), float(fontsize_x), fontspacing, uint32_2_Color(text_c1buffer[idx]))
            idx += 1
            col_pix += fontsize_x
        row_pix += fontsize_y

proc internaldraw(self: Console) =
    let
        insertpos: Vector2 = (0.0, 0.0)
        srcrect: Rectangle = (0.0, 0.0, float(self.screen_x), float(-self.screen_y)) # -screen_y to flip the texture back to right side up
        dstrect: Rectangle = (0.0, 0.0, float(getScreenWidth()), float(getScreenHeight()))
    t_now = t_now + getFrameTime().cfloat
    # render the current state
    beginTextureMode(render_tx)
    if self.border_show:
        clearBackground(uint32_2_Color(self.border_color))
    self.textdraw()
    endTextureMode()
    drawTexturePro(render_tx.texture, srcrect, dstrect, insertpos, 0, WHITE)

proc internalshaderdraw(self: Console) =
    let
        insertpos: Vector2 = (0.0, 0.0)
        srcrect: Rectangle = (0.0, 0.0, float(self.screen_x), float(-self.screen_y)) # -screen_y to flip the texture back to right side up
        dstrect: Rectangle = (0.0, 0.0, float(getScreenWidth()), float(getScreenHeight()))
    t_now = t_now + getFrameTime().cfloat
    # render the current state
    beginTextureMode(render_tx)
    if self.border_show:
        clearBackground(uint32_2_Color(self.border_color))
    self.textdraw()
    endTextureMode()
    beginShaderMode(shader):
        setShaderValue(shader, timeLoc, addr t_now, 0)
        clearBackground(BLACK)
        drawTexturePro(render_tx.texture, srcrect, dstrect, insertpos, 0, WHITE)

proc draw*(self: Console, pos: Vector2i, background_alpha: uint32) =
    let
        fontsize_x = self.fontsize_x
        fontsize_y = self.fontsize_y
        fontspacing: cfloat = 0.0
        fdx = self.font_dx
        fdy = self.font_dy
    var
        col_pix: int = 0
        row_pix: int = pos.y
        col_pix0: int = pos.x
        idx: int = 0
    for j in 0 ..< self.num_cells_y: # loop over rows
        col_pix = col_pix0
        for i in 0 ..< self.num_cells_x: # loop over cols
            # background
            if text_c2buffer[idx] != background_alpha:
                drawRectangle(col_pix, row_pix, fontsize_x, fontsize_y, uint32_2_Color(text_c2buffer[idx]))
            let chr = text_rbuffer[idx]
            if chr != 0x20: drawTextEx(font, toUTF8(chr.Rune), (float(col_pix + fdx), float(row_pix + fdy)), float(fontsize_x), fontspacing, uint32_2_Color(text_c1buffer[idx]))
            idx += 1
            col_pix += fontsize_x
        row_pix += fontsize_y

proc sleep*(self: Console, t: float) = 
    var
        t_0: float64 = getTime()
    if self.running:            
        while true:
            if not windowShouldClose():
                if self.use_crt_shader:
                    beginDrawing():
                        self.internalshaderdraw()
                        drawFPS(0, 0)
                else:
                    beginDrawing():
                        self.internaldraw()
                        drawFPS(0, 0)
            else:
                self.running = false
                break
            if getTime() - t_0 > t:
                break

proc run*(self: Console, body: (proc(): bool)) =
    #var
        # t_last: float64 = getTime()
        #frames: int = 0
    if self.use_crt_shader:
        while self.running and not windowShouldClose(): # Detect window close button or ESC key
            #frames += 1
            # run the game code 
            if body != nil:
                self.running = body() and self.running # and self.running in case somce code in body() such as maybe sleep() may have changed .running
            beginDrawing():
                self.internalshaderdraw()
                drawFPS(0, 0)
    else:
        while self.running and not windowShouldClose(): # Detect window close button or ESC key
            #frames += 1
            # run the game code 
            if body != nil:
                self.running = body() and self.running # and self.running in case somce code in body() such as maybe sleep() may have changed .running
            beginDrawing():
                self.internaldraw()
                drawFPS(0, 0)
    unloadFont(font)
    unloadRenderTexture(render_tx)
    unloadShader(shader)
    closeWindow() # Close window and OpenGL context

proc getscreenregion*(self: Console, col1: int, row1: int, col2: int, row2: int): Region =
    result = new Region
    # if not check_col_row_(col1, row1) or not check_col_row_(col2, row2): return region{}
    # swap the parameter orders if col2 is smaller than col1 etc.
    if col1 > col2:
        return self.getscreenregion(col2, row1, col1, row2)
    if row1 > row2:
        return self.getscreenregion(col1, row2, col2, row1)
    result.extend.x = col2 - col1 + 1
    result.extend.y = row2 - row1 + 1
    for i in 0 ..< result.extend.y:
        for j in 0 ..< result.extend.x:
            let src_idx = (col1 + j) + self.num_cells_x * (row1 + i) # parentheses for clarity!echo("got here 1")                        
            result.text_rbuffer.add(text_rbuffer[src_idx])
            result.text_c1buffer.add(text_c1buffer[src_idx])
            result.text_c2buffer.add(text_c2buffer[src_idx])
    assert (len(result.text_rbuffer) == result.extend.x * result.extend.y)
    result.blitlevel = 2 # we default to full
    
proc getscreenregion*(self: Console, tlc, brc: Vector2i): Region =
    let
        (col1, row1) = (tlc.x, tlc.y)
        (col2, row2) = (brc.x, brc.y)
    self.getscreenregion(col1, row1, col2, row2)

proc getscreen*(self: Console): Region =
    return self.getscreenregion(0, 0, self.num_cells_x - 1, self.num_cells_y - 1)

proc writexy*(self: Console, col: int, row: int, str: string, blitlevel: int = 1, scroll: bool = false) =
    assert(col >= 0 and col < self.num_cells_x and row >= 0 and row < self.num_cells_y)
    let text: Sprite = new Sprite
    text.fromstring(str, self.text_color, self.background_color, col, self.num_cells_x)
    text.pos = (self.viewport.x, self.viewport.y + row)
    text.blitlevel = blitlevel
    if scroll:
        let dy = row + text.extend.y - self.num_cells_y
        #echo fmt"{row} + {text.extend.y} - {self.num_cells_y} = {dy}"
        if dy > 0:
            let sc = self.getscreen()
            sc.pos = (0, self.viewport.y) # the local coord system's (0, 0)
            self.viewport.y += dy # shift the viewport
            sc.blit(self) # re-blit the screen in the new viewport position
    text.blit(self)

proc writexy*(self: Console, pos: Vector2i, str: string, blitlevel: int = 1, scroll: bool = false) =
    assert(pos.x >= 0 and pos.x < self.num_cells_x and pos.y >= 0 and pos.y < self.num_cells_y)
    let text: Sprite = new Sprite
    text.fromstring(str, self.text_color, self.background_color, pos.x, self.num_cells_x)
    text.pos = (self.viewport.x, self.viewport.y + pos.y)
    text.blitlevel = blitlevel
    if scroll:
        let dy = pos.y + text.extend.y - self.num_cells_y
        #echo fmt"{pos.y} + {text.extend.y} - {self.num_cells_y} = {dy}"
        if dy > 0:
            let sc = self.getscreen()
            sc.pos = (0, self.viewport.y) # the local coord system's (0, 0)
            self.viewport.y += dy
            sc.blit(self) # re-blit the screen in the new viewport position
    text.blit(self)

proc write*(self: Console, str: string, blitlevel: int = 1, scroll: bool = false) =
    let
        row = self.cursoridx div self.num_cells_x
        text: Sprite = new Sprite
    text.fromstring(str, self.text_color, self.background_color, self.cursoridx mod self.num_cells_x, self.num_cells_x)
    text.pos = (self.viewport.x, self.viewport.y + row)
    text.blitlevel = blitlevel
    if scroll:
        let dy = row + text.extend.y - self.num_cells_y
        #echo fmt"{row} + {text.extend.y} - {self.num_cells_y} = {dy}"
        if dy > 0:
            let sc = self.getscreen()
            sc.pos = (0, self.viewport.y) # the local coord system's (0, 0)
            self.viewport.y += dy
            sc.blit(self) # re-blit the screen in the new viewport position
    text.blit(self)

#[ #these implementations with Regions -- potentially slower actually!
proc writexy*(self: Console, col: int, row: int, str: string, blitlevel: int = 1, local_coords: bool = true) =
    let text: Region = new Region
    var acol = self.background_color div 2 + self.text_color div 2 # we make up some alpha color by averaging text and background colors
    if acol == 0: acol = 1
    text.fromstring(str, self.text_color, self.background_color, acol, 0, self.num_cells_x) #
    if local_coords:
        text.pos = (self.viewport.x + col, self.viewport.y + row)
    else:
        text.pos = (col, row)
    text.blitlevel = blitlevel
    text.blit(self)

proc writexy*(self: Console, pos: Vector2i, str: string, blitlevel: int = 1, local_coords: bool = true) =
    let text: Region = new Region
    var acol = self.background_color div 2 + self.text_color div 2 # we make up some alpha color by averaging text and background colors
    if acol == 0: acol = 1
    text.fromstring(str, self.text_color, self.background_color, acol, 0, self.num_cells_x) #
    if local_coords:
        text.pos = self.viewport + pos
    else:
        text.pos = pos
    text.blitlevel = blitlevel
    text.blit(self)

proc write*(self: Console, str: string, blitlevel: int = 1, local_coords: bool = true) =
    let text: Region = new Region
    var acol = self.background_color div 2 + self.text_color div 2 # we make up some alpha color by averaging text and background colors
    if acol == 0: acol = 1
    text.fromstring(str, self.text_color, self.background_color, acol, 0, self.num_cells_x) #
    if local_coords:
        text.pos = (self.viewport.x + self.cursoridx mod self.num_cells_x, self.viewport.y + self.cursoridx div self.num_cells_x)
    else:
        text.pos = (self.cursoridx mod self.num_cells_x, self.cursoridx div self.num_cells_x)
    text.blitlevel = blitlevel
    text.blit(self)
]#

proc putchar*(self: Console, c: int) =
    let cursoridx = self.cursoridx
    text_rbuffer[cursoridx] = c
    text_c1buffer[cursoridx] = self.text_color
    text_c2buffer[cursoridx] = self.background_color
    # save last write operation position
    if cursoridx < self.num_cells_x * self.num_cells_y - 1:
        self.cursoridx = cursoridx + 1
    else: # if the cursor is at the last character of the screen, we cannot advance it
        self.cursoridx = cursoridx

proc putchar*(self: Console, col: int, row: int, c: int) =
    assert(col >= 0 and col < self.num_cells_x and row >= 0 and row < self.num_cells_y)
    let cursoridx = col + self.num_cells_x * row
    text_rbuffer[cursoridx] = c
    text_c1buffer[self.cursoridx] = self.text_color
    text_c2buffer[self.cursoridx] = self.background_color
    # save last write operation position
    if cursoridx < self.num_cells_x * self.num_cells_y - 1:
        self.cursoridx = cursoridx + 1
    else: # if the cursor is at the last character of the screen, we cannot advance it
        self.cursoridx = cursoridx

proc putchar*(self: Console, pos: Vector2i, c: int) =
    let (col, row) = (pos.x, pos.y)
    assert(col >= 0 and col < self.num_cells_x and row >= 0 and row < self.num_cells_y)
    let cursoridx = col + self.num_cells_x * row
    text_rbuffer[cursoridx] = c
    text_c1buffer[self.cursoridx] = self.text_color
    text_c2buffer[self.cursoridx] = self.background_color
    # save last write operation position
    if cursoridx < self.num_cells_x * self.num_cells_y - 1:
        self.cursoridx = cursoridx + 1
    else: # if the cursor is at the last character of the screen, we cannot advance it
        self.cursoridx = cursoridx

proc getchar*(self: Console, col: int, row: int): int =
    assert(col >= 0 and col < self.num_cells_x and row >= 0 and row < self.num_cells_y)
    return text_rbuffer[col + self.num_cells_x * row]

proc getchar*(self: Console, pos: Vector2i): int =
    let (col, row) = (pos.x, pos.y)
    assert(col >= 0 and col < self.num_cells_x and row >= 0 and row < self.num_cells_y)
    return text_rbuffer[col + self.num_cells_x * row]

proc gotoxy*(self: Console, col: int, row: int) =
    assert(col >= 0 and col < self.num_cells_x and row >= 0 and row < self.num_cells_y)
    self.cursoridx = col + self.num_cells_x * row
    
proc gotoxy*(self: Console, pos: Vector2i) =
    let (col, row) = (pos.x, pos.y)
    assert(col >= 0 and col < self.num_cells_x and row >= 0 and row < self.num_cells_y)
    self.cursoridx = col + self.num_cells_x * row

proc wherexy*(self: Console): Vector2i =
    return (self.cursoridx mod self.num_cells_x, self.cursoridx div self.num_cells_x)

proc clreol(self: Console) =
    let cursoridx = self.cursoridx
    let num_chrs_2_fill = self.num_cells_x - (cursoridx mod self.num_cells_x)
    #echo (fmt"clreol(): cursoridx = {cursoridx}, num_chrs_2_fill = {num_chrs_2_fill}")
    for i in 0 ..< num_chrs_2_fill:
        #echo (fmt"clreol(): clearing {cursoridx + i}")
        text_rbuffer[cursoridx + i] = 0x20
        text_c1buffer[cursoridx + i] = self.text_color
        text_c2buffer[cursoridx + i] = self.background_color

# raylib-dependent implementation of inputxy
proc inputxy*(self: Console, col: int, row: int, prompt: string = "?", min_length:int = 0, max_length:int = 256, cursor_chr: int = ord('_'), cursor_blinking: bool = true): string =
    assert(col >= 0 and col < self.num_cells_x and row >= 0 and row < self.num_cells_y)
    assert(min_length <= max_length)
    var
        c = -1
        scroll_rows_last = 0
        bkspc = false
        t_now = getTime()
        t_blink = t_now
        dt_blink = 0.5
        blinkstate = true
    let
        curr_screen = self.getscreen()    
        start_row = row
        text: Sprite = new Sprite
    result = ""
    while self.running:
        t_now = getTime()
        # handle keyboard input
        c = getCharPressed()
        if c >= 32 and c <= 125 and result.len < max_length:
            let chr_str = $chr(c)
            result &= chr_str
            bkspc = false
        if isKeyPressed(KeyboardKey.ENTER) and result.len >= min_length: return result
        elif isKeyPressed(KeyboardKey.BACKSPACE) and result.len > 0:
            result = result[0 .. ^2]
            bkspc = true
        # calculate the need for scrolling
        let scroll_rows = if start_row + text.extend.y <= self.num_cells_y: 0 else: start_row + text.extend.y - self.num_cells_y
        # blit original screen
        curr_screen.pos = (0, self.viewport.y - scroll_rows) # the local coord system's (0, 0) = (0, self.viewport.y)!
        curr_screen.blit(self)
        # create and blit input string with cursor
        if cursor_blinking and t_now - t_blink > dt_blink:
            blinkstate = not blinkstate
            t_blink = t_now
        # in the following .fromstring, the cursor character is reprsented by a space char. This is because fromstring does only parse text characters,
        # and secondly, in every second blink state, the cursor is a space character anyhow.
        text.fromstring(prompt & result & " ", self.text_color, self.background_color, col, self.num_cells_x)
        if blinkstate: text.text_rbuffer[^1] = cursor_chr # correct the cursor character in the "on" blink state
        text.pos = (self.viewport.x, self.viewport.y + row - scroll_rows)
        text.blit(self)
        # check if line-clearing is necessary
        if scroll_rows != scroll_rows_last:
            if scroll_rows > scroll_rows_last: self.clreol()
            scroll_rows_last = scroll_rows
        if bkspc:
            self.clreol()
            bkspc = false
        #echo fmt"debug2: {self.cursoridx}, {self.cursoridx div self.num_cells_x}, {start_row} // {text.extend}, {start_row + text.extend.y - 1}, {scroll_rows_last}"
        self.sleep(-1) # single render call
