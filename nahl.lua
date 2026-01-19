player = make_actor(17, 32, 32)
player.w = 3
player.h = 3
ai = make_actor(3, 64, 64)
ai.frames = 4
ai.vel = vec2d.new(1, 1)
ai.friction = 1
ai.wieght = 3

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
