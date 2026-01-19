actor = {}
function make_actor(index, x, y)
	a = {
		index = index,
		pos = vec2d.new(x, y),
		vel = vec2d.new(0, 0),
		accel = 0.15,
		frame = 0,
		t = 0,
		friction = 0.94,
		bounce = 0.7,
		weight = 1,
		frames = 6,
		velocity_cutoff = 0.25,
		dash_speed = 2.5,
		hp = 10,
		hp_max = 10,
		control = true,
		w = 4,
		h = 4,
	}
	add(actor, a)
	return a
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
					sfx(1)
					a.hp -= 1
					b.hp -= 1
					if(a.hp <= 0) then 
						--do something 
					end
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
				end
			end
		end
	end
end

function draw_actor(act)
	local anim_speed = 6
	local mag = act.vel:magnitude()
	if mag >= 4 then
		anim_speed = 2
	elseif mag >= 2.5 then
		anim_speed = 4
	end
	act.frame = flr(act.t / anim_speed) % act.frames
	act.t += 1
	if act.vel:magnitude() < act.velocity_cutoff then
		act.frame = 0
	end
	spr(act.index + act.frame, act.pos.x - act.w, act.pos.y - act.h)
end
