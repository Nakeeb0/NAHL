function _init()
	_dr = normal_draw
	_upd = infinite_straight_laced
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
	asdf = 5

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

	a = straight_boss.new(100, 100)
	a:create_minions(400)
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
