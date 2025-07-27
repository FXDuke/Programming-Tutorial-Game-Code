local utility = {
	-- Locks vector 3 y axis to 0
	Vector3YAxis0 = function(vector: Vector3): Vector3
		return Vector3.new(vector.X, 0, vector.Z);
	end,	
	-- Determines if parts (assumed to be unrotated 3d rectangles) are overlaping based on position and size
	Collision3d = function(a: Part, b: Part): boolean
		local ap, as = a.Position, a.Size;
		local bp, bs = b.Position, b.Size;

		return math.abs(ap.X - bp.X) < (as.X + bs.X) * 0.5
			and math.abs(ap.Y - bp.Y) < (as.Y + bs.Y) * 0.5
			and math.abs(ap.Z - bp.Z) < (as.Z + bs.Z) * 0.5;
	end,
};

return utility;
