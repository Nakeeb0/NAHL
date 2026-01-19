local vec2d = {
	__type = "vec2d",
}
vec2d.__index = vec2d

function vec2d.new(a, b)
	return setmetatable({ x = a, y = b }, vec2d)
end

function vec2d:normalize()
	local mag = self:magnitude()
	if abs(mag) <= 0.001 then
		return vec2d.new(0, 0)
	end
	return vec2d.new(self.x / mag, self.y / mag)
end

function vec2d:magnitude()
	return sqrt(self.x ^ 2 + self.y ^ 2)
end

function vec2d:dot(vb)
	return self.x * vb.x + self.y * vb.y
end

function vec2d.__add(va, vb)
	return vec2d.new(va.x + vb.x, va.y + vb.y)
end

function vec2d.__sub(va, vb)
	return vec2d.new(va.x - vb.x, va.y - vb.y)
end

function vec2d.__div(va, b)
	return vec2d.new(va.x / b, va.y / b)
end

function vec2d.__mul(va, b)
	return vec2d.new(va.x * b, va.y * b)
end

function vec2d.__unm(va, b)
	return vec2d.new(-va.x, -va.y)
end

function vec2d:proj(vb) --u is vb, v is self
	if abs(self:magnitude()) <= 0.001 then
		return vec2d.new(0, 0)
	end
	return self * (self:dot(vb) / (self:magnitude() * self:magnitude()))
end
