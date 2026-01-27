arenas = {
   ["default"] = {
        x = 0,
        y = 0,
    },
    ["blackhole"] = {
        x = 44,
        y = 48,
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
		del(enemies, ai)
    end
    
end

arena_names = {"default", "blackhole"}
