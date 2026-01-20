actor = {}
next_actor_id = 1
function make_actor(index, x, y)
	a = {
		index = index,
		pos = vec2d.new(x, y),
		vel = vec2d.new(0, 0),
		id = next_actor_id,
		next_actor_id = next_actor_id + 1,
		accel = 0.15,
		frame = 0,
		t = 0,
		friction = 0.94,
		bounce = 0.7,
		weight = 1,
		frames = 6,
		velocity_cutoff = 0.25,
		dash_speed = 2.5,
		hp = 5,
		hp_max = 10,
		damage = 1,
		control = true,
		w = 4,
		h = 4,
		team = 1,
		last_hit = -600,
		invul_frames = 20,
		force_threshold = 1.5,
		dead = false,
	}
	add(actor, a)
	return a
end

pair_last_hit = {}
pair_cd = 10

function game_over()
	--nop
end

function death(a)
	local sp = a.index + (a.frame or 0)
	add(death_fx, {
		sp = sp,
		x = a.pos.x - a.w,
		y = a.pos.y - a.h,
		t = 0,
		life = 12,
	})
	if a == player then
		sfx(5)
		game_over()
	else
		sfx(6)
	end
	a.dead = true
end

local function pair_key(a, b)
	local i = a.id
	local j = b.id
	if i > j then
		i, j = j, i
	end
	return i, j
end

function can_damage_pair(damager, damaged)
	local i, j = pair_key(damager, damaged)
	local row = pair_last_hit[i]
	local last = row and row[j]

	if last and timer - last < pair_cd then
		return false
	end

	if not row then
		row = {}
		pair_last_hit[i] = row
	end
	row[j] = timer
	return true
end

function damage_resolve(a, b, force_a, force_b)
	local damaged = b
	local damager = a
	local eps = 0.5

	local mag_damager = force_a:magnitude()
	local mag_damaged = force_b:magnitude()
	if mag_damaged > mag_damager then
		damager, damaged = b, a
		mag_damager, mag_damaged = mag_damaged, mag_damager
	end

	if not can_damage_pair(damager, damaged) then
		return
	end
	if
		a.team == b.team
		or mag_damager - mag_damaged < eps
		or mag_damager < damaged.force_threshold
		or timer - damaged.last_hit < damaged.invul_frames
	then
		sfx(1)
		return
	end

	damaged.hp -= damager.damage
	damaged.last_hit = timer

	if damaged == player then
		sfx(3)
	elseif damager == player then
		sfx(4)
	else
		sfx(5)
	end

	if damaged == player then
		damaged.hurt_col = 12
	else
		damaged.hurt_col = 8
	end

	spawn_dmg_text(damaged.pos.x - 2, damaged.pos.y - damaged.h - 6, damager.damage, damaged.hurt_col)
	if damaged.hp <= 0 then
		death(damaged)
	end
end

function move_actor(a)
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

function check_all_actor_collision()
	for i = 1, #actor - 1 do
		local a = actor[i]
		for j = i + 1, #actor do
			local b = actor[j]
			if a ~= b then
				if actor_collision(a, b) then
					local dir_a = (b.pos - a.pos):normalize()
					local dir_b = (a.pos - b.pos):normalize()
					local force_a = dir_a:proj(a.vel) * a.weight
					local force_b = dir_b:proj(b.vel) * b.weight
					if dir_a:dot(a.vel) > 0 then
						b.vel += force_a / b.weight
						a.vel -= (force_a * a.bounce) / a.weight
					end
					if dir_b:dot(b.vel) > 0 then
						a.vel += force_b / a.weight
						b.vel -= (force_b * b.bounce) / b.weight
					end
					damage_resolve(a, b, force_a / a.weight, force_b / b.weight)
				end
			end
		end
	end
	for act in all(actor) do
		if act.dead == true then
			del(actor, act)
		end
	end
end
