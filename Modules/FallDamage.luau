--[[
Fall Damage script.

Modes of fall damage:
ClientSide -> Client side fall damage script 
Basic -> Damage is based off of velocity magnitude
Advanced -> Damage is based off of time in the air and raycasts 

Modes of exploits:
None -> no exploit
ClientSide -> Bypasses client side fall damage 
Basic -> Bypasses basic fall damage 
Advanced -> Bypasses airtime fall damage


]]
-- Services
local RunService = game:GetService("RunService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

-- Assets
local Modules = ReplicatedStorage:WaitForChild("Modules");
local Remotes = ReplicatedStorage:WaitForChild("Remotes");
local ToggleClientSideFallDamageRemote = Remotes:WaitForChild("ToggleClientSideFallDamage");

-- Modules
local Utility = require(Modules:WaitForChild("Utility"));
local MessagePacker = require(Modules:WaitForChild("MessagePacker"));

-- Varaibles
local activePlayers = {};

-- Whitelist modes so someone cant throw errors by sending invalid mode
local whitelistedModes = {
	Basic = true,
	ClientSide = true,
	Advanced = true,	
};

-- Mode Functions 
local FallDamageModes = {
	Basic = function(player: Player)
		
	end,	
	Advanced = function(player: Player)
		
	end,
};

-- Module
local FallDamage = {
	PartAdded = function(part: Part)
	end,	
	PartRemoved = function(part: Part)
	end,
	PlayerAdded = function(player: Player)
		activePlayers[activePlayers] = {
			client = player,
			airTime = 0,
			lastVelocity = Vector3.zero,
			mode = "Basic",
			exploit = "None",
		};
	end,
	PlayerRemoving = function(player: Player)
		activePlayers[activePlayers] = nil;
	end,	
};

-- Remote Event
ToggleClientSideFallDamageRemote.OnServerEvent:Connect(function(player, type, mode)
	if (not activePlayers[player]) then
		local message = MessagePacker("Cannot update modules outside of region.", 2, {"Ok"}, "Server");
		Utility.MessagePlayer(player, message);
		return;
	end
end)

return FallDamage;
