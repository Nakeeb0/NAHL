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

function vec2d:proj(vb) --u is vb, v is self
	if abs(self:magnitude()) <= 0.001 then
		return vec2d.new(0, 0)
	end
	return self * (self:dot(vb) / (self:magnitude() * self:magnitude()))
end

actor = {}
function make_actor(index, x, y)
	a = {
		index = index,
		pos = vec2d.new(x, y),
		vel = vec2d.new(0, 0),
		accel = 0.4,
		frame = 0,
		t = 0,
		friction = 0.85,
		bounce = 0.7,
		frames = 6,
		velocity_cutoff = 0.25,
		dash_speed = 2.5,
		hp = 5,
		control = true,
		w = 4,
		h = 4,
	}
	add(actor, a)
	return a
end
player = make_actor(17, 16, 16)
player.w = 3
player.h = 3
ai = make_actor(3, 64, 64)
ai.frames = 1

function solid_tile(tx, ty)
	return fget(mget(tx, ty), 7)
end

function solid_aabb(a, check_x, check_y)
	local l = check_x - a.w + 1
	local r = check_x + a.w
	local t = check_y - a.h + 1
	local b = check_y + a.h

	local tx0 = flr(l / 8)
	local tx1 = flr(r / 8)
	local ty0 = flr(t / 8)
	local ty1 = flr(b / 8)

	return solid_tile(tx0, ty0) or solid_tile(tx1, ty0) or solid_tile(tx0, ty1) or solid_tile(tx1, ty1)
end

function actor_collision(a, b)
	return not (
		a.pos.x + a.w < b.pos.x - b.w
		or a.pos.x - a.w > b.pos.x + b.w
		or a.pos.y + a.h < b.pos.y - b.h
		or a.pos.y - a.h > b.pos.y + b.h
	)
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

function check_all_actor_collision(a)
	for b in all(actor) do
		if a ~= b then
			local runs = 0
			while runs < 3 and actor_collision(a, b) do
				runs += 1
				--sfx(1)
				local dir_a = (b.pos - a.pos):normalize()
				local dir_b = (a.pos - b.pos):normalize()
				if dir_a:dot(a.vel) > 0 then
					local force_a = dir_a:proj(a.vel)
					b.vel += force_a * 0.2 + dir_a * 0.2
				end
				if dir_b:dot(b.vel) > 0 then
					local force_b = dir_b:proj(b.vel)
					a.vel += force_b * 0.2 + dir_b * 0.2
				end
				move_actor(a)
				move_actor(b)
			end
		end
	end
end

function _update60()
	local x = 0
	local y = 0
	if btn(0) then
		x -= 1
	end
	if btn(1) then
		x += 1
	end
	if btn(2) then
		y -= 1
	end
	if btn(3) then
		y += 1
	end
	local input_vec = vec2d.new(x, y)
	local input_acc = input_vec:normalize() * player.accel
	player.vel += input_acc
	if btn(4) and input_vec:magnitude() > 0 then
		player.vel = input_vec:normalize() * player.dash_speed
	end
	check_all_actor_collision(player)
	move_actor(player)
	move_actor(ai)
end

function _draw()
	cls()

	room_x = flr(player.pos.x / 128)
	room_y = flr(player.pos.y / 128)
	camera(room_x * 128, room_y * 128)

	map()
	for act in all(actor) do
		local anim_speed = 6
		local mag = act.vel:magnitude()
		if mag >= 4 then
			anim_speed = 2
		elseif mag >= 2.5 then
			anim_speed = 4
		end
		act.frame = flr(act.t / anim_speed) % act.frames
		act.t += 1
		if act.vel:magnitude() < act.velocity_cutoff then
			act.frame = 0
		end
		spr(act.index + act.frame, act.pos.x - act.w, act.pos.y - act.h)
	end
end