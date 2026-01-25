dmg_texts = {}
death_fx = {}

function draw_death_fx()
	for i = #death_fx, 1, -1 do
		local d = death_fx[i]
		d.t += 1
		if d.t > d.life then
			deli(death_fx, i)
		end
	end
	for d in all(death_fx) do
		if d.t % 2 == 0 then
			spr(d.sp, d.x, d.y)
		else
			pal(1, 7)
			pal(2, 7)
			pal(8, 7)
			pal(9, 7)
			spr(d.sp, d.x, d.y)
			pal()
		end
	end
end

function spawn_dmg_text(x, y, dmg, col)
	local isrunning, t, life, vy = true, 0, 30, -0.6
	add_update_coroutine(function()
		while true do
			t += 1
			y += vy
			-- little easing: slow rise over time
			vy *= 0.95

			if t >= life then
				isrunning = false
				break
			else
				yield()
			end
		end
	end)
	add_draw_coroutine(function()
		while true do
			local s = "-" .. dmg
			-- optional "pop" upward at start
			local yy = y - (t < 6 and 1 or 0)
			-- fade-ish by switching color near end (cheap fake fade)
			if t > life * 0.7 then
				col = 6
			end -- darker near end

			print(s, x, yy, col)
			if not isrunning then
				break
			else
				yield()
			end
		end
	end)
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

	local tile_height = flr((act.h * 2 + 7) / 8)
	local tile_width = flr((act.w * 2 + 7) / 8)
	local sx = ((act.index + act.frame * tile_width) % 16) * 8
	local sy = flr((act.index + act.frame * tile_height) / 16) * 8
	sspr(sx, sy, tile_width * 8, tile_width * 8, act.pos.x - act.w, act.pos.y - act.h)
end

function draw_health_bar(x1, y1, x2, y2, color)
	rect(x1, y1 - 1, x2, y2 + 1, 6)
	local chunk = (x2 - x1) / player.hp_max
	rectfill(x1, y1, max(x1, x2 - (chunk * (player.hp_max - player.hp))), y2, color)
	line(x1, y1, x1, y2, 6)
	line(x2, y1, x2, y2, 6)
	for i = x1 + chunk, x2 - chunk, chunk do
		line(i, y1, i, y2, 0)
	end
end

function draw_dash_cooldown(x1, y1, x2, y2, color)
	rect(x1, y1 - 1, x2, y2 + 1, 6)
	local fill_width = min(abs(timer - last_pressed.special1), 100) / 100 * (x2 - x1)
	rectfill(x1, y1, fill_width + x1, y2, color)
	line(x1, y1, x1, y2, 6)
	line(x2, y1, x2, y2, 6)
end
