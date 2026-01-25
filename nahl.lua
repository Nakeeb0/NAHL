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
	player.accel = 0.1
	player.force = 1.3
	player.weight = 1
	player.friction = 0.975
	player.team = 0
	player.hp = 5
	player.hp_max = 5
	player.force_threshold = 0.35
	-- Define the available powerups
	all_powerups = {
		{
			name = "Repair",
			desc = "Heal 1 HP",
			apply = function(p) 
				p.hp = min(p.hp + 1, p.hp_max)
			end,
			is_eligible = function(p)
				return p.hp < p.hp_max 
			end
		},
		{
			name = "Sharpen",
			desc = "Damage +1",
			apply = function(p) 
				p.damage += 1 
			end,
			is_eligible = function(p)
    			return true
			end

		},
		{ 
			--todo: revise the limit
			name = "Turbo",
			desc = "acceleration +10%",
			apply = function(p) 
				p.accel = min(p.accel*1.1,0.45) 
			end,
			is_eligible = function(p)
				return p.accel < 0.45
			end
		},
		{
			name = "Sturdy",
			desc = "Max HP +1",
			apply = function(p) 
				p.hp_max += 1 
			end,
			is_eligible = function(p)
				return true
			end
		}
	}

	level_up_options = {}
	selected_option = 1

	player.force_threshold = 0.5

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
