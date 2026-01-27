function spawn_particle(p)
    update_particle = function()  --trail by default
        while p.t > 0 do
            p.t -= 1
            yield()
        end
    end
    if p.type == "explosion" then
        update_particle = function()
            while p.t > 0 do
                p.x += p.dx
                p.y += p.dy
                p.dy += 0.05 -- gravity
                p.t -= 1
                yield()
            end
        end
    elseif p.type == "collision" then
        update_particle = function()
            while p.t > 0 do
                p.x += p.dx
                p.y += p.dy
                p.dx *= 0.9
                p.dy *= 0.9
                p.t -= 1
                yield()
            end
        end
    end
	add_update_coroutine(update_particle)
	add_draw_coroutine(function()
		while p.t > 0 do
			pset(p.x, p.y, p.c)
			yield()
		end
	end)
end

function spawn_trail(x, y, col, count, time)
  for i = 1, count or 1 do
    local p = {
    x = x + rnd(2)-1,
    y = y + rnd(2)-1,
    t = time or 10,
    c = col or 6,
    type = "trail",
  }
    spawn_particle(p)
  end
end

function explosion(x, y, count)
	for i = 1, count do
		local p = {
		x = x,
		y = y,
		dx = rnd(2) - 1, -- -1 to 1
		dy = rnd(2) - 1,
		t = 30, -- lifetime in frames
		c = 7, -- white
        type = "explosion",
	}
    spawn_particle(p)
	end
end

function collision_particles(x, y, count)
	for i = 1, count do
		local p = {
		x = x,
		y = y,
		dx = rnd(2) - 1, -- -1 to 1
		dy = rnd(2) - 1,
		t = 20, -- lifetime in frames
		c = 9, 
        type = "collision",
	}
    spawn_particle(p)
	end
end
