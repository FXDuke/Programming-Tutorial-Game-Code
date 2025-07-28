-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local RunService = game:GetService("RunService");

-- Constants
local Player = Players.LocalPlayer;
local Parent = script.Parent;
local Modules = ReplicatedStorage:WaitForChild("Modules");
local RegionsFolder = workspace:WaitForChild("ModuleRegions"):WaitForChild("Regions");

-- Remotes
local Events = ReplicatedStorage:WaitForChild("Events");
local TransparencyChange: BindableFunction = Events:WaitForChild("TransparencyModifier"); -- Modifies transparency of supplied object (typically a region)

-- Remote Variables
local TransparencyEntered = 1;
local TransparencyExit = 0.70;

-- Utility
local Utility = require(Modules:WaitForChild("Utility"));

-- Load in modules
local LoadedModules = {};
for _, module: script in pairs(Modules:WaitForChild("ClientSide"):GetChildren()) do 
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
		if (not Utility.Collision3d(part, region)) then continue end;
		if (Modules:FindFirstChild(name)) then colliding[name] = LoadedModules.Template; continue end;
		assert(LoadedModules[name], name .. " does not have a valid module name associated with it: " .. name);
		colliding[name] = LoadedModules[name];
	end

	return colliding;
end

-- Player handling 
local function CharacterAdded(char: Model)
	active = {
		character = char,
		activeRegions = {},
	};

	char.Destroying:Once(function()
		for name, module in active.activeRegions do  
			module.PlayerRemoving(Player);
			task.spawn(function()
				TransparencyChange:Invoke(Regions[name], TransparencyExit);
			end)
		end
		active = {};
	end)
end

if (Player.Character) then 
	CharacterAdded(Player.Character);
end

Player.CharacterAdded:Connect(CharacterAdded);

-- Main loop 
RunService.PreSimulation:Connect(function(deltaTime: number)
	-- Find players inside of regions
	if (not active.character) then return end;
	
	local hrp = active.character:FindFirstChild("HumanoidRootPart");
	assert(hrp, Player.Name .. " does not have a HumanoidRootPart associated with their character.");

	-- Find regions that collide with hrp
	local collisions = CollidingRegions(hrp);

	-- Remove players from regions the character was previously in
	for name, module in active.activeRegions do 
		if (not collisions[name]) then 
			module.PlayerRemoving(Player);
			active.activeRegions[name] = nil;
			task.spawn(function()
				TransparencyChange:Invoke(Regions[name], TransparencyExit);
			end)
			continue;
		end
	end

	-- Add player to module when entering region
	for name, module in collisions do 
		if (not active.activeRegions[name]) then
			module.PlayerAdded(Player);
			task.spawn(function()
				TransparencyChange:Invoke(Regions[name], TransparencyEntered);
			end)
		end
	end

	-- Update active regions
	active.activeRegions = collisions;
end)

-- Events
RegionsFolder.ChildAdded:Connect(function(region)
	Regions[region.Name] = region;
end)
