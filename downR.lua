-- title:   down
-- author:  game developer, email, etc.
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

t = 0
p = {x = 100, y = 10, dx = 0, dy = 0, cr = {w = 6, h = 7}, maxSpeed = 2, grounded = false, canJump = false}
	p.sprites = {flip = 0, stand = 256, jump = 257, fall = 258, land1 = 259, land2 = 260, run1 = 261, run2 = 262}
	p.history = {x1 = 0, y1 = 0}
cam = {x = 120, y = 68}

tiles={}
maxx=23
maxy=63
minx=3
miny=0

function floor()
    for x=minx,maxx do
        for y=miny,maxy do
            mset(x,y,0)
        end
    end
end
function perimeter()
    for x=minx,maxx do
        for y=miny,maxy do
            if x==minx then
                mset(x,y,2)
            elseif x==maxx then
                mset(x,y,3)
            elseif y==miny or y==maxy then
                mset(x,y,4)
            end
        end
    end
end

function tile_is_good(n)
    local x=n[1]
    local y=n[2]

    if
        mget(x  ,y-1)<1 and
        mget(x+2,y-1)<1 and
        mget(x-2,y-1)<1 and
        mget(x  ,y+1)<1 and
        mget(x+2,y+1)<1 and
        mget(x-2,y+1)<1 or

        mget(x-2,y  )<1 and
        mget(x-2,y-2)<1 and
        mget(x-2,y+2)<1 and
        mget(x+2,y  )<1 and
        mget(x+2,y-2)<1 and
        mget(x+2,y+2)<1 then
        return true
    else
        return false
    end
end
function log_all_tiles()
    for x=minx,maxx do
        for y=miny,maxy do
            if mget(x,y)==0 then
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
        mset(x,y,4)
    end
    table.remove(tiles,index)
end
function build_map()
    lay_wall()
    if #tiles>0 then
        build_map()
    end
end

function initMap()
    floor()
    perimeter()
    log_all_tiles()
    build_map()
end

function isSolid(x, y)
     return mget(x // 8, y // 8) < 80 and mget(x // 8, y // 8) > 0
end

function checkFloor(p)
    return isSolid(p.x + 1, p.y + p.cr.h + p.dy) or isSolid(p.x+p.cr.w, p.y + p.cr.h + p.dy)
end

function checkWall(p)
    return isSolid(p.x + 1 + p.dx, p.y + p.dy) or isSolid(p.x + p.cr.w + p.dx, p.y + p.dy) or
    		isSolid(p.x + 1 + p.dx, p.y + p.cr.h + p.dy) or isSolid(p.x + p.cr.w + p.dx, p.y + p.cr.h + p.dy)
end

function checkCeiling(p)
    return isSolid(p.x + 1, p.y + p.dy) or isSolid(p.x + p.cr.w, p.y + p.dy)
end

function movePlayer()
    p.history.x = p.x
    p.history.y = p.y
    p.x = p.x + p.dx
    p.y = p.y + p.dy

    p.dy = math.min(p.dy + 0.25, 3)


    if btn(2) then
        p.dx = math.max(0 - p.maxSpeed, p.dx - 1)
        p.sprites.flip = 1
    elseif btn(3) then
        p.dx = math.min(p.maxSpeed, p.dx + 1)
        p.sprites.flip = 0
    elseif not btn(2) or not btn(3) then
        p.dx = 0
    end

    if btn(0) and p.canJump then
        p.dy = -3
        p.canJump = false
    elseif btnp(0) and p.grounded then
        p.canJump = true
    end

    if checkFloor(p) then
        p.dy = 0
        p.grounded = true
    else
        p.grounded = false
    end

    if checkWall(p) then
        p.dx = 0
    end
    if checkCeiling(p) then
        p.dy = 0
    end

end
initMap()
function moveCamera()
    cam.x = p.x - 120
    cam.y = p.y - 68
    map(0, 0, 29, 136, -cam.x, -cam.y)
end

function draw(t)
    cls()
    moveCamera()
    local fx = p.x - cam.x
    local fy = p.y - cam.y

    if p.dx ~= 0 and p.grounded then
        spr(p.sprites.run1 + (t / 4) % 2, fx, fy, 0, 1, p.sprites.flip)
	elseif p.dy < 0 then
        spr(p.sprites.jump, fx, fy, 0, 1, p.sprites.flip)
    elseif p.dy > 0 then
		spr(p.sprites.fall, fx, fy, 0, 1, p.sprites.flip)
	else
        spr(p.sprites.stand, fx, fy, 0, 1, p.sprites.flip)
    end

    if p.history.y - p.y < 0 and p.dy == 0 then
		spr(p.sprites.land1, fx, fy, 0, 1, p.sprites.flip)
    end
end


function TIC()

    movePlayer()
    draw(t)
    t = t + 1
end

-- <TILES>
-- 002:2001100120001101000100112000000120001011000101112000001101110001
-- 003:1001000211010002101000001111010211100012110100021011001210010100
-- 004:2222222220000001200000212000020120202021220202012020202111111111
-- </TILES>

-- <SPRITES>
-- 000:0003300000003000000000000003300003003000000000300000000000300300
-- 001:0003300003003030000000000003300000003000000000300000000000300000
-- 002:0003300003003000000000300003300000003000000000000003000000000030
-- 003:0000000000033000000030000000003003033000000030000000001001301300
-- 004:0003300000003000000000000003300003003000000000301000100100310300
-- 005:0000330000000300000000000303300000003030000000000300000000000300
-- 006:0000330000000300000000000003300000303000000003000003000000003000
-- </SPRITES>

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
-- 000:1a1c2cfffffd4d4d4df26822ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

