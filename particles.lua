particles = {}
function spawn_particle(x, y)
  local p = {
    x = x,
    y = y,
    dx = rnd(2)-1,   -- -1 to 1
    dy = rnd(2)-1,
    t = 30,          -- lifetime in frames
    c = 7            -- white
  }
  add(particles, p)
end

function explosion(x, y, count)
  for i=1,count do
    spawn_particle(x, y)
  end
end

function update_particles()
  for p in all(particles) do
    p.x += p.dx
    p.y += p.dy
    p.dy += 0.05     -- gravity
    p.t -= 1

    if p.t <= 0 then
      del(particles, p)
    end
  end
end

function draw_particles()
  for p in all(particles) do
    pset(p.x, p.y, p.c)
  end
end


