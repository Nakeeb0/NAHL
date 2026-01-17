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
	--if typeof(b) == "table" and b.__type == "vec2d" then
	return vec2d.new(va.x + vb.x, va.y + vb.y)
	--else
	--	return
	--end
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

local player_position = vec2d.new(16, 16)
local current_velocity = vec2d.new(0, 0)
local acceleration = 0.3
local max_speed = 200
local friction_multiplier = 0.98
local velocity_cutoff = 0.50
local w = 4
local h = 4
local bounce = 0.3

function solid_tile(tx, ty)
	return fget(mget(tx, ty), 7)
end

function solid_aabb(px, py)
	local l = px - w
	local r = px + w - 1
	local t = py - h
	local b = py + h - 1

	local tx0 = flr(l / 8)
	local tx1 = flr(r / 8)
	local ty0 = flr(t / 8)
	local ty1 = flr(b / 8)

	return solid_tile(tx0, ty0) or solid_tile(tx1, ty0) or solid_tile(tx0, ty1) or solid_tile(tx1, ty1)
end

local function handle_movement_input()
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

	local input = vec2d.new(x, y)
	local input_acceleration = input:normalize() * acceleration
	current_velocity += input_acceleration

	if current_velocity:magnitude() >= max_speed then
		current_velocity = current_velocity:normalize() * max_speed
	end

	if input:magnitude() == 0 and current_velocity:magnitude() <= velocity_cutoff then
		current_velocity = vec2d.new(0, 0)
	end

	if not solid_aabb(player_position.x + current_velocity.x, player_position.y) then
		player_position.x += current_velocity.x
	else
		current_velocity.x *= -bounce
	end

	if not solid_aabb(player_position.x, player_position.y + current_velocity.y) then
		player_position.y += current_velocity.y
	else
		current_velocity.y *= -bounce
	end

	current_velocity *= friction_multiplier
end

function _update()
	handle_movement_input()
end

function _draw()
	cls(1)

	room_x = flr(player_position.x / 128)
	room_y = flr(player_position.y / 128)
	camera(room_x * 128, room_y * 128)

	map()
	spr(2, player_position.x - w, player_position.y - h)
end

