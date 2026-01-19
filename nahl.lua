timer = 0
last_pressed = {
	left = -500,
	right = -500,
	up = -500,
	down = -500,
	special1 = -500,
	special2 = -500,
}
last_nothing = -600

player = make_actor(17, 32, 32)
player.w = 3
player.h = 3
player.accel = 0.2
player.weight = 1
player.friction = 0.98

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

function drift(dir, actor)
	nor = vec2d.new(dir.y, -dir.x):normalize()
	dir = dir:normalize()
	vel = actor.vel
	component_dir = dir:proj(vel)
	component_nor = nor:proj(vel)
	if component_dir:dot(dir) < 0 then
		component_dir = vec2d.new(0, 0)
	end
	actor.vel = component_nor * 0.3 + component_dir * 0.8
end

function _update60()
	timer += 1
	local x = 0
	local y = 0
	local pressed = 0
	if btn(0) then
		x -= 1
		last = last_pressed.left
		if (timer - last) < 45 and (last_nothing > last) and not (btn(1) or btn(2) or btn(3) or btn(4) or btn(5)) then
			local flag = 1
			for time in all(last_pressed) do
				if time > last then
					flag = 0
				end
			end
			if flag == 1 then
				drift(vec2d.new(x, y), player)
			end
		end
		last_pressed.left = timer
		pressed = 1
	end
	if btn(1) then
		x += 1
		last = last_pressed.right
		if (timer - last) < 45 and (last_nothing > last) and not (btn(2) or btn(3) or btn(4) or btn(5) or btn(0)) then
			local flag = 1
			for time in all(last_pressed) do
				if time > last then
					flag = 0
				end
			end
			if flag == 1 then
				drift(vec2d.new(x, y), player)
			end
		end
		last_pressed.right = timer
		pressed = 1
	end
	if btn(2) then
		y -= 1
		last = last_pressed.down
		if (timer - last) < 45 and (last_nothing > last) and not (btn(1) or btn(3) or btn(4) or btn(5) or btn(0)) then
			local flag = 1
			for time in all(last_pressed) do
				if time > last then
					flag = 0
				end
			end
			if flag == 1 then
				drift(vec2d.new(x, y), player)
			end
		end
		last_pressed.down = timer
		pressed = 1
	end
	if btn(3) then
		y += 1
		last = last_pressed.up
		if (timer - last) < 45 and (last_nothing > last) and not (btn(1) or btn(2) or btn(4) or btn(5) or btn(0)) then
			local flag = 1
			for time in all(last_pressed) do
				if time > last then
					flag = 0
				end
			end
			if flag == 1 then
				drift(vec2d.new(x, y), player)
			end
		end
		last_pressed.up = timer
		pressed = 1
	end
	if pressed == 0 then
		last_nothing = timer
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
