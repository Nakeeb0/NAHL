trail_running_for = 0
last_input = false
function player_input()
	local x = 0
	local y = 0
	local pressed = 0
	if btn(0) then
		x -= 1
		last = last_pressed.left
		check_double_tap(x, y, player, last)
		last_pressed.left = timer
		pressed = 1
	end
	if btn(1) then
		x += 1
		last = last_pressed.right
		check_double_tap(x, y, player, last)
		last_pressed.right = timer
		pressed = 1
	end
	if btn(2) then
		y -= 1
		last = last_pressed.down
		check_double_tap(x, y, player, last)
		last_pressed.down = timer
		pressed = 1
	end
	if btn(3) then
		y += 1
		last = last_pressed.up
		check_double_tap(x, y, player, last)
		last_pressed.up = timer
		pressed = 1
	end
	if pressed == 0 then
		last_nothing = timer
	end

	local input_vec = vec2d.new(x, y)
	local input_acc = input_vec:normalize() * player.accel
	player.vel += input_acc
	if btn(4) and input_vec:magnitude() > 0 then
		if timer - last_pressed.special1 >= 100 then
			last_pressed.special1 = timer
			player.vel = input_vec:normalize() * player.dash_speed * player.vel:magnitude()
			sfx(2)
		end
	end

	if input_vec:magnitude() == 0 and last_input == true then
		trail_running_for = player.vel:magnitude() * 20
	else
		last_input = false
		trail_running_for -= 1
	end

	if input_vec:magnitude() > 0 or trail_running_for > 0 then
		count = player.vel:magnitude()
		spawn_trail(player.pos.x, player.pos.y, 8, count)
	end
	last_input = (input_vec:magnitude() > 0)
end
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
function check_double_tap(x, y, player, last)
	if (timer - last) < 45 and (last_nothing > last) then
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
end
