function game_over_screen()
	map()
	print("score: " .. score, 64, 64, 6)
end

function game_over_update()
	if timer > 50 then
		run()
	end
end

function game_over()
	_dr = game_over_screen
	_upd = game_over_update
	timer = 1
end

function normal_draw()
	cls()
	draw_health_bar(20, 139, 80, 142, 8)
	draw_dash_cooldown(94, 139, 140, 142, 7)
	draw_particles()
	draw_death_fx()
	room_x = flr((player.pos.x - 16) / 128)
	room_y = flr((player.pos.y - 16) / 128)
	camera(room_x * 128 + 16, room_y * 128 + 16)

	map()
	for act in all(actor) do
		draw_actor(act)
	end
end

function infinite_straight_laced()
	player_input()
	ai_update()
	update_particles()
	check_all_actor_collision()
	for act in all(actor) do
		move_actor(act)
	end
	if #enemies == 0 then
		a = straight_boss.new(64, 64)
		a:create_minions(400)
	end
end
