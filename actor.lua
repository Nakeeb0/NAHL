next_actor_id = 1
function rng(l, r)
	return rnd(r - l + 1) + l
end
base_actor = {}
base_actor.__index = base_actor
function base_actor:new(index,x,y)
	local o = {
		index = index,
		pos = vec2d.new(x+arenax, y+arenay),
		vel = vec2d.new(0, 0),
		accel = 0.15,
		frame = 0,
		t = 0,
		friction = 0.94,
		bounce = 0.8,
		weight = 1,
		frames = 6,
		velocity_cutoff = 0.25,
		max_velocity = 999,
		damage = 1,
		w = 4,
		h = 4,
		ghosted = false,
		frozen = false,

	}
	setmetatable(o, self)
	-- add(actor,o) hold on here
	return o
end
-- function make_actor(index, x, y)
-- 	local a = {
-- 		index = index,
-- 		pos = vec2d.new(x+arenax, y+arenay),
-- 		vel = vec2d.new(0, 0),
-- 		id = next_actor_id,
-- 		next_actor_id = next_actor_id + 1,
-- 		accel = 0.15,
-- 		frame = 0,
-- 		t = 0,
-- 		friction = 0.94,
-- 		bounce = 0.8,
-- 		weight = 1,
-- 		frames = 6,
-- 		velocity_cutoff = 0.25,
-- 		max_velocity = 999,
-- 		hp = 10, -- will be in new 
-- 		hp_max = 10, -- will be in new
-- 		damage = 1, 
-- 		w = 4,
-- 		h = 4,
-- 		force = 1, -- will be in new
-- 		team = 1,	--will be in new
-- 		invul_frames = 30, --will be in new
-- 		force_threshold = 1.5, -- will be in new
-- 		dead = false, --will be in new
-- 		ghosted = false, 
-- 		frozen = false,
-- 		invulnerable = false, --will be in new
-- 	}
-- 	add(actors, a)
-- 	return a
-- end

actor = setmetatable({}, {__index = base_actor})
actor.__index = actor
function actor:new_actor(index,x,y)
	local o = base_actor:new(index,x,y)
	o.id = next_actor_id
	next_actor_id = next_actor_id + 1
	o.hp = 10 
	o.hp_max = 10
	o.force = 1
	o.team = 1
	o.invul_frames = 30
	o.force_threshold = 1.5
	o.dead = false
	o.invulnerable = false
	add(actors,o)
	return o
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

	if not a.type == "projectile" and not can_damage_pair(damager, damaged) then
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

	--if a collision is BIG (todo, define big..), make the camera shake
	--right now i'm multiplying the magnitude difference with the max weight with some coeff
	--shake_timer = min(max_shake_duration,shake_duration_coeff * (mag_damager-mag_damaged)*max(a.weight,b.weight))
	--+0.5 to round
	--shake_factor = min(max_shake_amount,flr((mag_damager-mag_damaged)*shake_amount_coeff*max(a.weight,b.weight)+0.5))
	--printh("ce "..shake_timer..' sf '..shake_factor..' maga'..mag_damager..' magb'..mag_damaged,"debug.txt")

	spawn_dmg_text(damaged.pos.x - 2, damaged.pos.y - damaged.h - 6, damager.damage, damaged.hurt_col)
	if damaged.hp <= 0 then
		actor_death(damaged)
		if damaged.type == "straight-laced-boss" then
			explosion(damaged.pos.x, damaged.pos.y, 50)
		else
			explosion(damaged.pos.x, damaged.pos.y, 10)
		end
	end
end

function resolve_collide(a, b)
	local dir_a = (b.pos - a.pos):normalize()
	local dir_b = (a.pos - b.pos):normalize()
	local force_a = dir_a:proj(a.vel) * a.weight
	local force_b = dir_b:proj(b.vel) * b.weight
	local mag_a = (force_a * a.force / a.weight):magnitude()
	local mag_b = (force_b * b.force / b.weight):magnitude()

	if dir_a:dot(a.vel) > 0 then
		ppos = dir_a * a.w / (a.w + b.w)
		collision_particles(a.pos.x + ppos.x, b.pos.y + ppos.y, max(a.vel:magnitude() * 3, b.vel:magnitude() * 3))

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
	for act in all(actors) do
		if act.dead == true then
			if act == player then
			    del(actors, act)
				game_over()
				return
			end
			if act.type == "straight-laced-boss" then
				score += 4
			elseif act.type == "follower-boss" then
				score += 5
			else
				score += 1
			end
			if score > 0 and flr(score / 2) > player.power_ups then
				start_level_up()
			end
			del(actors, act)
			del(enemies, act)
		end
	end
end
