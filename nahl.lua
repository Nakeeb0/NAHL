function _init()
	_dr = norm_draw
	_upd = norm_update
	score = 0
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

	enemies = {}
	player = make_actor(17, 32, 32)
	player.w = 3
	player.h = 3
	player.accel = 0.11
	player.weight = 1
	player.friction = 0.98
	player.team = 0
	player.hp = 5
	player.hp_max = 5
	player.force_threshold = 0.35

	create_ai("straight-laced", 64, 64)
	create_ai("straight-laced", 64, 64)
end

function create_ai(type, x, y)
	if type == "straight-laced" then
		a = make_actor(3, x, y)
		a.type = "straight-laced"
		a.frames = 4
		a.max_velocity = 1.11
		a.accel = 0.01
		a.friction = 1
		a.bounce = 1
		a.weight = 2
		a.hp_max = 3
		a.hp = 3
		add(enemies, a)
		return a
	end
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
end

function ai_update()
	for enemy in all(enemies) do
		if enemy.type == "straight-laced" then
			local dir = enemy.vel:normalize()
			if enemy.vel:magnitude() == 0 then
				dir = vec2d.new(rnd(2) - 1, rnd(2) - 1)
			end
			enemy.vel += dir * enemy.accel
		end
	end
end

function _update60()
	timer += 1
	_upd()
end

function _draw()
	_dr()
end

function norm_draw()
	cls()
	draw_health_bar(20, 139, 80, 142, 8)
	draw_dash_cooldown(94, 139, 140, 142, 7)
	draw_dmg_texts()
	draw_death_fx()
	room_x = flr((player.pos.x - 16) / 128)
	room_y = flr((player.pos.y - 16) / 128)
	camera(room_x * 128 + 16, room_y * 128 + 16)

	map()
	for act in all(actor) do
		draw_actor(act)
	end
end

function norm_update()
	update_dmg_texts()
	player_input()
	ai_update()
	check_all_actor_collision()
	for act in all(actor) do
		move_actor(act)
	end
	if timer % 600 == 0 then
		create_ai("straight-laced", 64, 64)
	end
	if #enemies == 0 then
		create_ai("straight-laced", 64, 64)
	end
end
