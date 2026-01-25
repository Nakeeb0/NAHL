particles = {}
function explosion(x, y, count)
  for i=1,count do
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
end

function spawn_trail(x, y, col)
  local p = {
    x = x + rnd(2)-1,
    y = y + rnd(2)-1,
    dx = (rnd()-0.5)*0.5,
    dy = (rnd()-0.5)*0.5,
    t = 20,
    c = col or 6
  }
  add(particles, p)
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


