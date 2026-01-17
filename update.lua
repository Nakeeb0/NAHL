dx = 0
dy = 0
x = 2
y = 2
function _draw()
	cls(1)

	camera(0, 0)
	-- draw the whole map (128⁙32)
	map()
	-- draw the player
	spr(
		2, -- frame index
		x * 8 - 4,
		y * 8 - 4, -- x,y (pixels)
		1,
		1,
		d == -1 -- w,h, flip
	)
end
function _update() 
  	ac=0.1 -- acceleration
	
	if (btn(⬅️)) dx-= ac d=-1
	if (btn(➡️)) dx+= ac d= 1
	if (btn(⬆️)) dy-= ac
	if (btn(⬇️)) dy+= ac
	
	-- move (add velocity)
	x+=dx y+=dy
	
	-- friction (lower for more)
	dx *=.7
	dy *=.7
	
	-- advance animation according
	-- to speed (or reset when
	-- standing almost still)
	spd=sqrt(dx*dx+dy*dy)
	if (spd < 0.05) f=0

end
