local base_ai = {}
base_ai.__index = base_ai

function base_ai.new(x, y)
    a = make_actor(3, x, y)
    a.type = "default"
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

local follow_ai = setmetatable({}, base_ai)
follow_ai.__index = follow_ai

function follow_ai.new(x, y)
    follow = base_ai.new(x, y)
    return follow
end

function co_ghost(ai, start_time, total_time)
	while true do
		if timer - start_time >= total_time then
			ai.ghosted = false
			return
		end
		yield()
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
