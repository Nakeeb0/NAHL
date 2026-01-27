function blackhole_update()
    for act in all(actor) do
        act.vel += (vec2d.new(64+arenax-act.pos.x, 64+arenay-act.pos.y):normalize()*0.05) -- black hole effect
    end
    if #enemies < 2 then
        local a = dasher_ai.new(roll_xy())
        a:dash_in(100)
    end
end

function default_update()
	if #enemies < 2 then
		local a = straight_ai.new(roll_xy())
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
        update = default_update,
    },
    ["blackhole"] = {
        x = 16,
        y = 0,
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
        del(actor, ai)
    end
    enemies = {}
    
end

arena_names = {"default", "blackhole"}
