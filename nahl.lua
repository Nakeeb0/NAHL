function _init()
	_dr = normal_draw
	_upd = arena_update
	difficulty = 0
	curr_arena = rnd(arena_names)
	arenax = arenas[curr_arena].x * 8
	arenay = arenas[curr_arena].y * 8
	score = 0
	timer = 0
	shake_timer = 0
	shake_amount_coeff = 0.4
	shake_duration_coeff = 0.4
	max_shake_amount = 4
	max_shake_duration = 8
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
	actor = {}
	player = make_actor(17, 32+arenax, 32+arenay)
	player.w = 3
	player.h = 3
	player.accel = 0.1
	player.force = 1.5
	player.weight = 2
	player.friction = 0.975
	player.team = 0
	player.hp = 5
	player.hp_max = 5
	player.force_threshold = 0.35
	player.damage = 1
	player.type = "player"
	level_up_options = {}
	selected_option = 1
	player.force_threshold = 0.5
	player.dash_sprite_frames=0
	load_arena(curr_arena)
end

function _update60()
	timer += 1

	_upd()
	run_update_coroutines()
end

function _draw()
	_dr()
	run_draw_coroutines()
end
