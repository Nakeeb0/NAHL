local vec2d = {
	__type = "vec2d"
}
vec2d.__index = vec2d

function vec2d.new(a, b)
	return setmetatable({x = a, y = b}, vec2d)
end

function vec2d:normalize()
	local mag = self:magnitude()
	if abs(mag) <= 0.001 then
		return vec2d.new(0, 0)
	end
	return vec2d.new(self.x / mag, self.y / mag)
end

function vec2d:magnitude()
	return sqrt(self.x^2 + self.y^2)
end

function vec2d:dot(vb)
	return self.x*vb.x + self.y*vb.y
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


local player_position = vec2d.new(2, 2)
local current_velocity = vec2d.new(0, 0)
local acceleration = 0.014
local max_speed = 100
local friction_multiplier = 0.97
local velocity_cutoff = 0.015

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
	current_velocity *= friction_multiplier
	if input:magnitude() == 0 and current_velocity:magnitude() <= velocity_cutoff then
		current_velocity = vec2d.new(0, 0)
	end

	player_position += current_velocity
end

function _update()
	handle_movement_input()
end

function _draw()
	cls(1)
	
	room_x=flr(player_position.x/16)
	room_y=flr(player_position.y/16)
	camera(room_x*128,room_y*128)

	map()
	spr(2, player_position.x * 8 - 4, player_position.y * 8 - 4)
end