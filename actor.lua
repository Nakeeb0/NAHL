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
		bounce = 0.8,
		weight = 1,
		frames = 6,
		velocity_cutoff = 0.25,
		max_velocity = 999,
		dash_speed = 2.5,
		hp = 10,
		hp_max = 10,
		damage = 1,
		w = 4,
		h = 4,
		force = 1,
		team = 1,
		invul_frames = 30,
		force_threshold = 1.5,
		type = "player",
		flags = {
			dead = false,
			ghosted = false,
			frozen = false,
			invulnerable = false,
		},
	}
	add(actor, a)
	return a
end

pair_last_hit = {}
pair_cd = 10

function actor_death(a)
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

function set_invulnerable(a, frames)
	a.invulnerable = true
	local t = 0
	add_update_coroutine(function()
		while t < frames do
			t += 1
			yield()
		end
		a.invulnerable = false
	end)
end

function resolve_damage(a, b, mag_a, mag_b)
	local damaged = b
	local damager = a
	local eps = 0.3

	local mag_damaged = mag_b
	local mag_damager = mag_a

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
		or damaged.invulnerable == true
	then
		sfx(1)
		return
	end

	damaged.hp -= damager.damage
	set_invulnerable(damaged, damaged.invul_frames)

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
		actor_death(damaged)
	end
end

function resolve_collide(a, b)
	local dir_a = (b.pos - a.pos):normalize()
	local dir_b = (a.pos - b.pos):normalize()
	local force_a = dir_a:proj(a.vel) * a.weight * a.force
	local force_b = dir_b:proj(b.vel) * b.weight * b.force
	local mag_a = (force_a / a.weight):magnitude()
	local mag_b = (force_b / b.weight):magnitude()

	if dir_a:dot(a.vel) > 0 then
		b.vel += force_a / b.weight
		a.vel -= (force_a * a.bounce) / a.weight
	else
		mag_a *= -1
	end
	if dir_b:dot(b.vel) > 0 then
		a.vel += force_b / a.weight
		b.vel -= (force_b * b.bounce) / b.weight
	else
		mag_b *= -1
	end
	resolve_damage(a, b, mag_a, mag_b)
end
function move_actor(a)
	--a.vel += (vec2d.new(80-a.pos.x, 80-a.pos.y):normalize()*0.05) -- experimenting with a "black hole" at the center
	if a.vel:magnitude() > a.max_velocity then
		a.vel = a.vel:normalize() * a.max_velocity
	end
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

function check_death()
	for act in all(actor) do
		if act.dead == true then
			if act == player then
				game_over()
				return
			end
			print(act.type)
			score += 1
			del(actor, act)
			del(enemies, act)
		end
	end
end
