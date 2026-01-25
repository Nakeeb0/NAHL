particles = {}
function spawn_particle(x, y)
	local p = {
		x = x,
		y = y,
		dx = rnd(2) - 1, -- -1 to 1
		dy = rnd(2) - 1,
		t = 30, -- lifetime in frames
		c = 7, -- white
		isrunning = true,
	}
	add_update_coroutine(function()
		while p.t > 0 do
			p.x += p.dx
			p.y += p.dy
			p.dy += 0.05 -- gravity
			p.t -= 1
			yield()
		end
		p.isrunning = false
	end)
	add_draw_coroutine(function()
		while p.isrunning do
			pset(p.x, p.y, p.c)
			yield()
		end
	end)
end

function explosion(x, y, count)
	for i = 1, count do
		spawn_particle(x, y)
	end
end
