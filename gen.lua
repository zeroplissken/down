-- title:   game title
-- author:  game developer, email, etc.
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

tiles = {}
maxx=29
maxy=16
minx=0
miny=0
FLOOR=1
WALL=2

function floor()
    for x=minx,maxx do
        for y=miny, maxy do
            mset(x, y, FLOOR)
        end
    end
end

function perimeter()
    for x=minx, maxx do
        for y=miny, maxy do
            if x==minx or x==maxx then
                mset(x,y,WALL)
            end
        end
    end
end

function tile_is_good(n)
    local x=n[1]
    local y=n[2]

    if
        mget(x  ,y-1)<WALL and
        mget(x+1,y-1)<WALL and
        mget(x-1,y-1)<WALL and
        mget(x  ,y+1)<WALL and
        mget(x+1,y+1)<WALL and
        mget(x-1,y+1)<WALL or

        mget(x-1,y  )<WALL and
        mget(x-1,y-1)<WALL and
        mget(x-1,y+1)<WALL and
        mget(x+1,y  )<WALL and
        mget(x+1,y-1)<WALL and
        mget(x+1,y+1)<WALL then
        return true
    else
        return false
    end
end

function log_all_tiles()
    for x=minx,maxx do
        for y=miny,maxy do
            if mget(x,y)==FLOOR then
                table.insert(tiles,#tiles+1,{x,y})
            end
        end
    end
end

function lay_wall()
    local index=math.random(1,#tiles)
    local cell=tiles[index]
    local x=cell[1]
    local y=cell[2]

    if tile_is_good(cell) then
        mset(x,y,WALL)
    end
    table.remove(tiles,index)
end

function build_map()
    lay_wall()
    if #tiles>0 then
        build_map()
    end
end

function draw()
    cls()
    map(minx, miny, maxx+1, maxy+1)
end

function init()
    floor()
    perimeter()
    log_all_tiles()
    build_map()
end
init()
function TIC()
    draw()
end

-- <TILES>
-- 001:1010101001010101101010101010101001010101010101010101010110101010
-- 002:3555555533555554330000443300004433000044330000443222224422222224
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

