actor = {}
function make_actor(index, x, y)
	a={
		index = index,
		x = x,
		y = y,
		dx = 0,
		dy = 0,
		frame = 0,
		t = 0,
		friction = 0.15,
		bounce  = 0.3,
		frames = 2,
		w = 4,
		h =4 
	}
	add(actor,a)
	return a
end

function _init()
  player = make_actor(2, 16, 16)
  player.friction = 0.92
end

function draw_actor(a)
	local sx = a.x - a.w
	local sy = a.y - a.h
	spr(a.index , sx, sy)
end

function _draw()
  cls()
	room_x=flr(player.x/128)
	room_y=flr(player.y/128)
	camera(room_x*128,room_y*128)
	map()
	foreach(actor,draw_actor)
end

function move_actor(actor)
  if not solid_aabb(actor.x + actor.dx, actor.y, actor.w, actor.h) then
    actor.x += actor.dx
  else
    actor.dx *= -actor.bounce
  end

  if not solid_aabb(actor.x, actor.y + actor.dy, actor.w, actor.h) then
    actor.y += actor.dy
  else
    actor.dy *= -actor.bounce
  end

  actor.dx *= actor.friction
  actor.dy *= actor.friction
end

function _update()
  local ac=0.4
  if (btn(⬅️)) player.dx-=ac
  if (btn(➡️)) player.dx+=ac
  if (btn(⬆️)) player.dy-=ac
  if (btn(⬇️)) player.dy+=ac
  move_actor(player)
end

function solid_tile(tx, ty)
  return fget(mget(tx, ty), 7)
end

function solid_aabb(px, py, w, h)
  local l = px - w
  local r = px + w - 1
  local t = py - h
  local b = py + h - 1

  local tx0 = flr(l/8)
  local tx1 = flr(r/8)
  local ty0 = flr(t/8)
  local ty1 = flr(b/8)

  return solid_tile(tx0, ty0)
      or solid_tile(tx1, ty0)
      or solid_tile(tx0, ty1)
      or solid_tile(tx1, ty1)
end

