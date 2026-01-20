dmg_texts = {}

function spawn_dmg_text(x, y, dmg, col)
	add(dmg_texts, {
		x = x,
		y = y,
		vy = -0.6, -- floats up
		t = 0,
		life = 30, -- ~0.5 sec at 60fps
		dmg = dmg,
		col = col,
	})
end

function update_dmg_texts()
	for i = #dmg_texts, 1, -1 do
		local d = dmg_texts[i]
		d.t += 1
		d.y += d.vy
		-- little easing: slow rise over time
		d.vy *= 0.95
		if d.t >= d.life then
			deli(dmg_texts, i)
		end
	end
end

function draw_dmg_texts()
	for d in all(dmg_texts) do
		local s = "-" .. d.dmg
		-- optional "pop" upward at start
		local yy = d.y - (d.t < 6 and 1 or 0)
		-- fade-ish by switching color near end (cheap fake fade)
		local col = d.col
		if d.t > d.life * 0.7 then
			col = 6
		end -- darker near end

		print(s, d.x, yy, col)
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
