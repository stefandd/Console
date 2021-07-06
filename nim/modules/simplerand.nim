import times

#
#  "RANDOM NUMBER GEUERATORS:
#   GOOD ONES ARE HARD TO FIND"
#  STEPHEN K. PARK AND KEITH W. MILLER 
#  Communications of the ACM October 1988 Volume :I2 Number 10
#
#  slightly improved by using their 1993 suggested multiplier 48271


var
    seed: uint32 = 7051833 # Brahms
    irand_call_cnt = 0

proc getseed*(): uint32 =
    seed

proc setseed*(x: uint32) =
    if x != 0:
        seed = x

proc randomize*() =
    seed = uint32(epochTime())
    irand_call_cnt = 0

proc randomize*(x: uint32) =
    if x != 0:
        seed = x
        irand_call_cnt = 0
    else:
        randomize()

proc randomize*(x: int) =
    if x != 0:
        seed = x.uint32
        irand_call_cnt = 0
    else:
        randomize()

proc irand*(): uint32 =
    irand_call_cnt += 1
    # Integer Version 2
    const
        a = 48271
        m = 0x7FFFFFFF
        q = m div a # m div a
        r = m mod a # m mod a
    var
        lo, hi, test : uint32
    hi = seed div q
    lo = seed mod q
    test = a * lo - r * hi
    if test > 0:
        seed = test
    else:
        seed = test + m
    result = seed

proc irand_calls*(): int64 =
    irand_call_cnt

proc frand*(): float =
    # Integer Version 2
    const
        a = 48271
        m = 0x7FFFFFFF
        q = m div a # m div a
        r = m mod a # m mod a
    var
        lo, hi, test : uint32
    hi = seed div q
    lo = seed mod q
    test = a * lo - r * hi
    if test > 0:
        seed = test
    else:
        seed = test + m
    result = float(seed) / float(m)

proc rand*(): uint32 =
    result = irand()

proc rand*(ul: uint32): uint32 =
    if ul > 0:
        result = irand() mod (ul + 1)
    else:
        result = 0

proc rand*(ul: int): int =
    if ul > 0:
        result = (irand() mod (ul.uint32 + 1)).int
    else:
        result = 0


when isMainModule:
    let firstcall = irand()
    while true:
        let newrand = irand()
        let irc = irand_calls()
        if irc mod 1000000000 == 0:
            echo "*, ", irc
        if newrand == firstcall:
            echo "period length", irand_calls()
            break

#var lvl_seed: int = rand(0x7FFFFFFD)
#echo fmt"Randomize({lvl_seed})"
#randomize(lvl_seed)
#echo rand(0x7FFFFFFD)
