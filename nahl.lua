timer = 0

player = make_actor(17, 32, 32)
player.w = 3
player.h = 3
player.weight = 1
player.friction = 0.97

ai = make_actor(3, 64, 64)
ai.frames = 4
ai.vel = vec2d.new(1, 1)
ai.friction = 1
ai.weight = 1.5

ai2 = make_actor(3, 90, 90)
ai2.frames = 4
ai2.vel = vec2d.new(1, 1)
ai2.friction = 1
ai2.weight = 2

function _update60()
	timer += 1
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
	ai.vel += vec2d.new(rnd(0.10) - 0.05, rnd(0.10) - 0.05)
	ai2.vel += vec2d.new(rnd(0.10) - 0.05, rnd(0.10) - 0.05)
	local input_vec = vec2d.new(x, y)
	local input_acc = input_vec:normalize() * player.accel
	player.vel += input_acc
	if btn(4) and input_vec:magnitude() > 0 then
		player.vel = input_vec:normalize() * player.dash_speed
	end
	check_all_actor_collision()
	for act in all(actor) do
		move_actor(act)
	end
end

function _draw()
	cls()

	room_x = flr((player.pos.x - 16) / 128)
	room_y = flr((player.pos.y - 16) / 128)
	camera(room_x * 128 + 16, room_y * 128 + 16)

	map()
	for act in all(actor) do
		draw_actor(act)
	end
end
