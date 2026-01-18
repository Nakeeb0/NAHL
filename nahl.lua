local vec2d = {
	__type = "vec2d",
}
vec2d.__index = vec2d

function vec2d.new(a, b)
	return setmetatable({ x = a, y = b }, vec2d)
end

function vec2d:normalize()
	local mag = self:magnitude()
	if abs(mag) <= 0.001 then
		return vec2d.new(0, 0)
	end
	return vec2d.new(self.x / mag, self.y / mag)
end

function vec2d:magnitude()
	return sqrt(self.x ^ 2 + self.y ^ 2)
end

function vec2d:dot(vb)
	return self.x * vb.x + self.y * vb.y
end

function vec2d.__add(va, vb)
	return vec2d.new(va.x + vb.x, va.y + vb.y)
end

function vec2d.__sub(va, vb)
	return vec2d.new(va.x - vb.x, va.y - vb.y)
end

function vec2d.__div(va, b)
	return vec2d.new(va.x / b, va.y / b)
end

function vec2d.__mul(va, b)
	return vec2d.new(va.x * b, va.y * b)
end

function vec2d.__unm(va, b)
	return vec2d.new(-va.x, -va.y)
end

actor = {}
function make_actor(index, x, y)
	a={
		index = index,
		pos = vec2d.new(x, y),
		vel = vec2d.new(0, 0),
		accel = 0.4,
		frame = 0,
		t = 0,
		friction = 0.93,
		bounce  = 0.3,
		frames = 2,
		velocity_cutoff = 0.50,
		dash_speed = 5,
		w = 4,
		h = 4 
	}
	add(actor,a)
	return a
end
local player = make_actor(2, 16, 16)
local ai = make_actor(3, 64, 64)

function solid_tile(tx, ty)
	return fget(mget(tx, ty), 7)
end

function solid_aabb(a, check_x, check_y)
	local l = check_x - a.w
	local r = check_x + a.w - 1
	local t = check_y - a.h
	local b = check_y + a.h - 1

	local tx0 = flr(l / 8)
	local tx1 = flr(r / 8)
	local ty0 = flr(t / 8)
	local ty1 = flr(b / 8)

	return solid_tile(tx0, ty0) or solid_tile(tx1, ty0) or solid_tile(tx0, ty1) or solid_tile(tx1, ty1)
end

function move_actor(a)
	if not solid_aabb(a, a.pos.x + a.vel.x, a.pos.y) then
		a.pos.x += a.vel.x
	else
		a.vel.x *= -a.bounce
	end

	if not solid_aabb(a, a.pos.x, a.pos.y + a.vel.y) then
		a.pos.y += a.vel.y
	else
		a.vel.y *= -a.bounce
	end

	a.vel *= a.friction
end

function _update()
	local x = 0
	local y = 0
	if (btn(0)) then x -= 1 end
	if (btn(1)) then x += 1 end
	if (btn(2)) then y -= 1 end
	if (btn(3)) then y += 1 end
	local input_vec = vec2d.new(x, y)
	local input_acc = input_vec:normalize() * player.accel
	player.vel += input_acc
	if (btn(4) and input_vec:magnitude() > 0) then
		 player.vel = input_vec:normalize() * player.dash_speed 
	end
	move_actor(player)
end

function _draw()
	cls()

	room_x = flr(player.pos.x / 128)
	room_y = flr(player.pos.y / 128)
	camera(room_x * 128, room_y * 128)

	map()
	for act in all(actor) do
		spr(act.index + act.frame, act.pos.x - act.w, act.pos.y - act.h)
	end
end

