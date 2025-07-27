-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local RunService = game:GetService("RunService");
local TweenService = game:GetService("TweenService");

-- Assets
local Remotes = ReplicatedStorage:WaitForChild("Remotes");
local MessageRemote = Remotes:WaitForChild("Message");

-- Module
local utility = {
	-- Messages player
	MessagePlayer = function(player: Player, message: UIPackedMessage)
		MessageRemote:FireClient(player, message);
	end,
	-- Tweens keypoints in numbersequence (for transparency etc). Does not tween envelope.
	TweenNumberSequence = function(numberSequence: NumberSequence, tweenInfo: TweenInfo, callback: (numberSequence: NumberSequence) -> nil, sequencesValues: {number})
		-- Get origin and goals for keypoints
		local keypointOrigins = numberSequence.Keypoints;
		
		-- Error handling
		assert(#sequencesValues == #keypointOrigins, "Attempted to tween NumberSequence with invalid number of points");
		assert(callback, "No callback set for NumberSequence tween");
		assert(tweenInfo.Time > 0, "TweenInfo time for NumberSequence tween must be above 0");
		
		-- Find deltas for keypoints
		local deltas = {};
		for index, value in sequencesValues do 
			deltas[index] = value - keypointOrigins[index].Value;	
		end
		
		-- Tween in keypoints
		local elapsed = 0;
		local currentSequence;
		while (elapsed < tweenInfo.Time) do 
			elapsed = math.min(elapsed + RunService.PreSimulation:Wait(), tweenInfo.Time);
			
			-- Find alpha
			local alpha = TweenService:GetValue(elapsed / tweenInfo.Time, tweenInfo.EasingStyle, tweenInfo.EasingDirection);
			
			-- Update each keypoint
			local keypoints = {};
			for index, value in deltas do
				local keypoint = NumberSequenceKeypoint.new(keypointOrigins[index].Time, keypointOrigins[index].Value + value * alpha, keypointOrigins[index].Envelope);
				keypoints[index] = keypoint;
			end
			
			-- Create new number sequence and call the callback
			currentSequence = NumberSequence.new(keypoints);
			callback(currentSequence);
		end
		
		return currentSequence;
	end,
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
