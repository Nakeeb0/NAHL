base_ai = {}
base_ai.__index = base_ai

function base_ai.new(x, y)
	local a = actor:new_actor(3, x, y)
	add(enemies, a)
	return a
end

straight_ai = setmetatable({}, base_ai)
straight_ai.__index = straight_ai

function straight_ai.new(x, y)
	local a = base_ai.new(x, y)
	setmetatable(a, straight_ai)
	a.type = "straight-laced"
	a.frames = 4
	a.max_velocity = 0.8 + rnd(0.4) + min(difficulty * 0.1, 0.4) 
	a.accel = 0.01 
	a.friction = 1
	a.bounce = 1
	a.weight = 2
	a.hp_max = 3
	a.hp = 3 + difficulty
	return a
end

straight_boss = setmetatable({}, base_ai)
straight_boss.__index = straight_boss

function straight_boss.new(x, y)
	local a = base_ai.new(x, y)
	setmetatable(a, straight_boss)
	a.type = "straight-laced-boss"
	a.frames = 4
	a.damage = 2
	a.max_velocity = 1
	a.accel = 0.01
	a.friction = 1
	a.bounce = 1
	a.weight = 4
	a.hp_max = 7
	a.force_threshold = 2.3
	a.hp = 7
	a.w = 7
	a.h = 7
	a.velocity_cutoff = 0.1
	a.force = 2.5
	a.index = 33
	return a
end

function straight_boss:create_minions(time)
	local t = 0
	add_update_coroutine(function()
		while self.dead == false do
			if t == time then
				a = straight_ai.new(self.pos.x, self.pos.y)
				a.hp = 2
				t = -1
			end
			t += 1
			yield()
		end
	end)
end

follower_boss = setmetatable({}, base_ai)
follower_boss.__index = follower_boss

function follower_boss.new(x, y)
	local a = base_ai.new(x, y)
	setmetatable(a, follower_boss)
	a.type = "follower-boss"
	a.frames = 1
	a.damage = 2
	a.max_velocity = 1
	a.accel = 0.01
	a.friction = 1
	a.bounce = 1
	a.weight = 4
	a.hp_max = 7
	a.force_threshold = 1.8
	a.hp = 7
	a.w = 7
	a.h = 7
	a.velocity_cutoff = 0.1
	a.force = 2.5
	a.index = 65
	return a
end

dasher_ai = setmetatable({}, base_ai)
dasher_ai.__index = dasher_ai

function dasher_ai.new(x, y)
	local a = base_ai.new(x, y)
	setmetatable(a, dasher_ai)
	a.type = "dasher"
	a.max_velocity = 100
	a.accel = 3.5 
	a.friction = 0.94
	a.force = 1.5
	a.bounce = 1
	a.weight = 2
	a.hp_max = 3
	a.hp = 3 + difficulty
	a.index = 67
	a.state = "neutral"
	a.dash_time = 110 + flr(rnd(100)) - min(difficulty * 10, 30)
	a:dash_in(a.dash_time)
	return a
end

function dasher_ai:dash_in(time)
	local t = 0
	add_update_coroutine(function()
		while self.dead == false do
			if t == time - 60 then
				self.state = "charged"
			end
			if t == time then
				self.state = "dashing"
				local dir = (player.pos - self.pos):normalize()
				self.vel = dir * self.accel
				local tt = 0
				add_update_coroutine(function()
					while tt < 30 do
						self.vel = dir * self.accel
						tt = tt + 1
						yield()
					end
					self.vel = dir * 0
				end)
				return
			end
			t += 1
			yield()
		end
	end)
end

function ai_update()
	for enemy in all(enemies) do
		if enemy.type == "straight-laced" or enemy.type == "straight-laced-boss" then
			local dir = enemy.vel:normalize()
			if enemy.vel:magnitude() == 0 then
				dir = vec2d.new(rnd(2) - 1, rnd(2) - 1)
			end
			enemy.vel += dir * enemy.accel
		elseif enemy.type == "follower-boss" then
			local dir = player.pos - enemy.pos
			enemy.vel += dir * enemy.accel
		elseif enemy.type == "dasher" then
			if enemy.state == "dashing" and enemy.vel:magnitude() == 0 then
				enemy.state = "neutral"
				enemy:dash_in(enemy.dash_time)
			end
		end
	end
end
