-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local RunService = game:GetService("RunService");

-- Constants
local Parent = script.Parent;
local Modules = ReplicatedStorage:WaitForChild("Modules");
local RegionsFolder = Parent:WaitForChild("Regions");
local SimulatedPartsFolder = Parent:WaitForChild("SimulatedParts");

-- Remote Variables
local TransparencyEntered = 1;
local TransparencyExit = 0.70;

-- Load in modules
local LoadedModules = {};
for _, module: script in pairs(Modules:GetChildren()) do 
	if (module:IsA("Folder")) then continue end;
	LoadedModules[module.Name] = require(module);
end

-- Load in regions
local Regions = {};
for _, region: Part in pairs(RegionsFolder:GetChildren()) do 
	Regions[region.Name] = region;
end

-- Variables
local active = {};
local simulatedParts = {};

-- Generic Functions 
local function CollidingRegions(part: Part): {Script}
	local colliding = {};
	
	-- Find all colliding regions
	for name, region in Regions do 
		if (not LoadedModules.Utility.Collision3d(part, region)) then continue end;
		if (Modules.ClientSide:FindFirstChild(name)) then colliding[name] = LoadedModules.Template; continue end;
		assert(LoadedModules[name], name .. " does not have a valid module name associated with it: " .. name);
		colliding[name] = LoadedModules[name];
	end
	
	return colliding;
end

-- Player handling 
Players.PlayerAdded:Connect(function(player: Player)
	local function CharacterAdded(char: Model)
		active[player] = {
			character = char,
			activeRegions = {},
		};
		
		char.Destroying:Once(function()
			for name, module in active[player].activeRegions do 
				module.PlayerRemoving(player);
			end
			active[player] = nil;
		end)
	end
	
	if (player.Character) then 
		CharacterAdded(player.Character);
	end
	
	player.CharacterAdded:Connect(CharacterAdded);
end)

Players.PlayerRemoving:Connect(function(player: Player)
	active[player] = nil;
end)

-- Simulated Parts
function AddSimulatedPart(part: Part)
	-- Add all descendants of part recursively
	for _, partChild in part:GetChildren() do 
		AddSimulatedPart(partChild);
	end	
	
	-- Return if not a part
	if (not part:IsA("Part")) then return end;
	
	-- Handle deletion
	part.Destroying:Once(function()
		for _, active in simulatedParts[part].activeRegions do 
			active.PartRemoved(part);
		end
	end)
	
	-- Add to table
	simulatedParts[part] = {
		part = part, 
		activeRegions = {};
	};
end

-- Add in all simulated parts
for _, part: Part in SimulatedPartsFolder:GetChildren() do
	AddSimulatedPart(part);
end
SimulatedPartsFolder.ChildAdded:Connect(AddSimulatedPart);

-- Main loop 
RunService.PreSimulation:Connect(function(deltaTime: number)
	-- Find players inside of regions
	for player, info in active do 
		local hrp = info.character:FindFirstChild("HumanoidRootPart");
		assert(hrp, player.Name .. " does not have a HumanoidRootPart associated with their character.");
		
		-- Find regions that collide with hrp
		local collisions = CollidingRegions(hrp);
		
		-- Remove players from regions the character was previously in
		for name, module in info.activeRegions do 
			if (not collisions[name]) then 
				module.PlayerRemoving(player);
				info.activeRegions[name] = nil;
				continue;
			end
		end
		
		-- Add player to module when entering region
		for name, module in collisions do 
			if (not info.activeRegions[name]) then
				module.PlayerAdded(player);
			end
		end
		
		-- Update active regions
		info.activeRegions = collisions;
	end
	
	-- Find simulated parts inside of regions
	for _, part in simulatedParts do 
		local collisions = CollidingRegions(part.part);
		
		-- Remove parts from regions the parts was previously in
		for name, module in part.activeRegions do 
			if (not collisions[name]) then 
				module.PartRemoved(part.part);
				part.activeRegions[name] = nil;
				continue;
			end
		end

		-- Add parts to module when entering region
		for name, module in collisions do 
			if (not part.activeRegions[name]) then
				module.PartAdded(part.part);
			end
		end

		-- Update active regions
		part.activeRegions = collisions;
	end
end)
