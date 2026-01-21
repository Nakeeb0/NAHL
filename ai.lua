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