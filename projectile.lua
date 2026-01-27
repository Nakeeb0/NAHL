next_projectile_id = 0
projectiles = {}
function make_projectile(index, x, y, vel, team, dmg, life)
	local p = {
		index = index,
		pos = vec2d.new(x + arenax, y + arenay),
		vel = vel or vec2d.new(0,0),
		max_velocity = 5,
		id = next_projectile_id,
		next_projectile_id = next_projectile_id + 1,
		friction = 1,
		bounce = 1,
		weight = 0.1,
		damage = dmg or 1,
		w = 1,
		h = 1,
		force = 1000,
		team = team or 2,
		type = "projectile",
		lifetime = life or 120,
	}
	add(projectiles, p)
	return p
end

function check_proj_death() 
	for proj in all(projectiles) do
	  if proj.lifetime == 0 then
		del(projectiles, proj)
	  end	
	end
end

function check_all_projectile_collisions()
	for i = 1, #projectiles - 1 do
		local a = projectiles[i]
		for j = i + 1, #projectiles do
			local b = projectiles[j]
			if a ~= b and a.team ~= b.team then
				if actor_collision(a, b) then
					a.lifetime = 0
					b.lifetime = 0
				end
			end
		end
	end
	check_proj_death()
	for i = 1, #projectiles - 1 do
		local a = projectiles[i]
		for j = 1, #actor do
			local b = actor[j]
			if b.ghosted == false and a.team ~= b.team then
				if actor_collision(a, b) then
					if b.invulnerable == false then
						b.hp -= a.damage
						spawn_dmg_text(b.pos.x - 2, b.pos.y - b.h - 6, a.damage, 9)
					end
					a.lifetime = 0
					if b.hp <= 0 then
						b.dead = true
					end
				end
			end
		end
	end
	check_death()
	check_proj_death()
end



function move_proj(a)
	if not solid_aabb(a, a.pos.x + a.vel.x, a.pos.y) then
		a.pos.x += a.vel.x
	else
		a.vel.x *= -a.bounce
	end

	if not solid_aabb(a, a.pos.x, a.pos.y + a.vel.y) then
		a.pos.y += a.vel.y
	else
		a.vel.y *= -a.bounce
	end

	a.vel *= a.friction
end