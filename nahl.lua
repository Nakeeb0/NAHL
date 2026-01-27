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
	player = pc.new(17, 32+arenax, 32+arenay)
	level_up_options = {}
	selected_option = 1
	player.dash_sprite_frames=0
	load_arena(curr_arena)
end

function _update60()
	timer += 1
	if timer %  60 == 0 then
		local vec = vec2d.new(1, 1)
		local x,y = roll_xy()
		--make_projectile(83, x, y,vec, 0, 1, 150) 
	end
	_upd()
	run_update_coroutines()
end

function _draw()
	_dr()
	run_draw_coroutines()
end
