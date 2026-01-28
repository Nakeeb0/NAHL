function blackhole_update()
	for act in all(actors) do
        if not(flr(act.pos.x /8) <= 24 and flr(act.pos.x/8) >= 23 
        and flr(act.pos.y/8) >= 7 and flr(act.pos.y/8) <= 8) then
		    act.vel += (vec2d.new(64 + arenax - act.pos.x, 64 + arenay - act.pos.y):normalize() * 0.035) -- black hole effect
        end
	end
    if timer % 600 == 0 then
		rnd(arenas[curr_arena].possible_enemy_spawn)(roll_xy())
    end
	if #enemies < 1 then
		rnd(arenas[curr_arena].possible_enemy_spawn)(roll_xy())
	end
end

function default_update()
    if timer % 600 == 0 then
		rnd(arenas[curr_arena].possible_enemy_spawn)(roll_xy())
    end
	if #enemies < 1 then
		rnd(arenas[curr_arena].possible_enemy_spawn)(roll_xy())
	end
end
function bang_update()
	if #enemies <= player.hard_mode then
		local x, y = roll_xy()
		local a = straight_boss.new(x, y)
		a:create_minions(400)
		x, y = roll_xy()
		local b = follower_boss.new(x, y)
		x, y = roll_xy()
		local c = dasher_ai.new(x, y)
		c:dash(100)
	end
end


--all arena update functions must be defined before the arenas table
arenas = {
	["default"] = {
		x = 0,
		y = 0,
		possible_enemy_spawn = { dasher_ai.new, straight_ai.new },
		update = default_update,
	},
	["blackhole"] = {
		x = 16,
		y = 0,
		possible_enemy_spawn = { dasher_ai.new, straight_ai.new },
		update = blackhole_update,
	},
}

function load_arena(name)
	arenax = arenas[name].x * 8
	arenay = arenas[name].y * 8
	curr_arena = name
	player.pos.x = 32 + arenax
	player.pos.y = 32 + arenay
	for ai in all(enemies) do
		del(actors, ai)
	end
	enemies = {}
end

arena_names = { "default", "blackhole" }
