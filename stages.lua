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
	draw_death_fx()
	room_x = flr((player.pos.x - 16) / 128)
	room_y = flr((player.pos.y - 16) / 128)
	-- rng(10,20)
	shake_x = 0
	shake_y = 0
	if shake_timer>0 then 
		shake_x = rng(-shake_factor,shake_factor)
		shake_y = rng(-shake_factor,shake_factor)
		shake_timer = shake_timer-1
	end
	camera(room_x * 128 + 16 + shake_x, room_y * 128 + 16 + shake_y)

	map()
	for act in all(actor) do
		draw_actor(act)
	end
end

function start_level_up()
    -- 1. Pick 3 random UNIQUE powerups
	player.power_ups += 1
    level_up_options = {}
    local choices = {}
    for i = 1, #all_powerups do
		if all_powerups[i].is_eligible(player) then
        	add(choices, all_powerups[i])
		end
    end

    for i = 1, min(3,#choices) do
        if #choices > 0 then
            local idx = flr(rnd(#choices)) + 1
            add(level_up_options, choices[idx])
            deli(choices, idx)
        end
    end

    -- 2. Reset selection
    selected_option = 1

    -- 3. Switch Game State (Pause the game)
	paused = true
    _upd = level_up_update
    _dr = level_up_draw
end

function level_up_update()
    -- Left / Right to select
    if btnp(0) then
        selected_option = max(1, selected_option - 1)
    end
    if btnp(1) then
        selected_option = min(#level_up_options, selected_option + 1)
    end

    -- Z or X to confirm
    if btnp(4) or btnp(5) then
        -- Apply the powerup
        level_up_options[selected_option].apply(player)
        -- Resume Game
		if score > 0 and flr(score / 15) > player.power_ups then
			start_level_up()
		else 
			set_invulnerable(player, 60)
			paused = false
			_upd = infinite_straight_laced
			_dr = normal_draw
		end
	end
end


function infinite_straight_laced()
	player_input()
	ai_update()
	check_all_actor_collision()
	for act in all(actor) do
		move_actor(act)
	end
	function roll_xy()
		local x = 128
		local y = 128
		while true do
			x = rng(32,128)
			y = rng(32,128)
			local v = vec2d.new(x,y)
			local dist = (v-player.pos):magnitude()
			printh('dist: '..dist..' x= '..x..' y='..y..' px='..player.pos.x..' py= '..player.pos.y,"debug.txt")
			if (v-player.pos):magnitude()>64 then
				break
			end
		end
		return x,y
	end
	if #enemies <= player.hard_mode then
		local x,y = roll_xy()
		local a = straight_boss.new(x, y)
		a:create_minions(400)
		x,y = roll_xy()
		local b = follower_boss.new(x,y)
		
		
	end
end
