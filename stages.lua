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
	camera(room_x * 128 + 16, room_y * 128 + 16)

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
		if score > 0 and flr(score / 5) > player.power_ups then
			start_level_up()
		else 
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
	if #enemies == 0 then
		a = straight_boss.new(64, 64)
		a:create_minions(400)
	end
end
