-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");

-- Assets
local Remotes = ReplicatedStorage:WaitForChild("Remotes");
local Modules = ReplicatedStorage:WaitForChild("Modules");
local MessagePacker = require(Modules:WaitForChild("MessagePacker"));
local MessageRemote = Remotes:WaitForChild("Message");

-- Variables
local messageID = 0;
local messageDurationDelay = 0.25; -- Time (in seconds) extra after message duration to wait for response.
local messageCallbacks = {};

-- Module
local utility = {
	-- Messages player
	MessagePlayer = function(player: Player, message: UIPackedMessage, callback: (player: Player, response: string?) -> ()?)
		messageID += 1;
		MessageRemote:FireClient(player, message, messageID);
		
		local ID = messageID;
		if (callback) then
			messageCallbacks[ID] = {
				owner = player,
				callback = callback
			};
			
			task.spawn(function()
				-- If callback is not called with duration, clear data
				if (message.duration > 0) then 
					task.wait(message.duration + messageDurationDelay);
					if (messageCallbacks[ID]) then 
						messageCallbacks[ID] = nil;
					end
				end
			end)
		end
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

-- Events
MessageRemote.OnServerEvent:Connect(function(player: Player, id: number, response: string)
	local info = messageCallbacks[id];
	
	if (not info) then 
		return utility.MessagePlayer(player, MessagePacker("Recieved response for invalid message.", 1, {}, "Server"));
	end
	
	if (info.owner ~= player) then 
		return utility.MessagePlayer(player, MessagePacker("You cannot respond to other peoples messages...", -1, {"Ok"}, "Server"));
	end
	
	info.callback(player, response);
end)

return utility;
