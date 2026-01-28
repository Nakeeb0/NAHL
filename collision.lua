function solid_tile(tx, ty)
	return fget(mget(tx, ty), 7)
end

function solid_aabb(a, check_x, check_y)
	local l = check_x - a.w 
	local r = check_x + a.w
	local t = check_y - a.h 
	local b = check_y + a.h

	local tx0 = flr(l / 8)
	local tx1 = flr(r / 8)
	local ty0 = flr(t / 8)
	local ty1 = flr(b / 8)

	return solid_tile(tx0, ty0) or solid_tile(tx1, ty0) or solid_tile(tx0, ty1) or solid_tile(tx1, ty1)
end

function actor_collision(a, b)
	return not (
		a.pos.x + a.w < b.pos.x - b.w
		or a.pos.x - a.w > b.pos.x + b.w
		or a.pos.y + a.h < b.pos.y - b.h
		or a.pos.y - a.h > b.pos.y + b.h
	)
end

function check_all_actor_collision()
	for i = 1, #actors - 1 do
		local a = actors[i]
		for j = i + 1, #actors do
			local b = actors[j]
			if a ~= b and not a.ghosted and not b.ghosted then
				if actor_collision(a, b) then
					resolve_collide(a, b)
				end
			end
		end
	end
	check_death()
end
