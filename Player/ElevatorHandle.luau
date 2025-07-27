-- Services
local TweenService = game:GetService("TweenService");
local Players = game:GetService("Players");
local RunService = game:GetService("RunService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

-- Modules
local Utility = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Utility"));

-- Constants
local Player = Players.LocalPlayer;

-- Tween Values
local ElevatorOpenTweenInfo = TweenInfo.new(1.25, Enum.EasingStyle.Back);
local ElevatorCloseTweenInfo = TweenInfo.new(0.95, Enum.EasingStyle.Sine);

-- Assets
local ElevatorFolder = workspace:WaitForChild("Elevators");

-- Variables
local elevators = {};

-- Functions
local function OpenElevator(elevator)
	elevators[elevator].open = true;
	
	local right: Model, left: Model = elevator.ElevatorDoorRight, elevator.ElevatorDoorLeft;
	local finalPositionRight, finalPositionLeft = CFrame.new(right.WorldPivot.Position - right.WorldPivot.RightVector * -3.5) * right.WorldPivot.Rotation, CFrame.new(left.WorldPivot.Position - left.WorldPivot.RightVector * -3.5) * left.WorldPivot.Rotation;
	
	local originRight, originLeft = elevators[elevator].originRight, elevators[elevator].originLeft;
	
	local elapsed = 0;
	while (elapsed < ElevatorOpenTweenInfo.Time and elevators[elevator].open == true) do 
		elapsed = math.min(elapsed + RunService.PreSimulation:Wait(), ElevatorOpenTweenInfo.Time);
		local alpha = TweenService:GetValue(elapsed / ElevatorOpenTweenInfo.Time, ElevatorOpenTweenInfo.EasingStyle, ElevatorOpenTweenInfo.EasingDirection);
		
		right:PivotTo(originRight:Lerp(finalPositionRight, alpha));
		left:PivotTo(originLeft:Lerp(finalPositionLeft, alpha));
	end
end

local function CloseElevator(elevator)
	elevators[elevator].open = false;

	local right: Model, left: Model = elevator.ElevatorDoorRight, elevator.ElevatorDoorLeft;
	local finalPositionRight, finalPositionLeft = elevators[elevator].originRight, elevators[elevator].originLeft;

	local originRight, originLeft = right.WorldPivot, left.WorldPivot;

	local elapsed = 0;
	while (elapsed < ElevatorCloseTweenInfo.Time and elevators[elevator].open == false) do 
		elapsed = math.min(elapsed + RunService.PreSimulation:Wait(), ElevatorCloseTweenInfo.Time);
		local alpha = TweenService:GetValue(elapsed / ElevatorCloseTweenInfo.Time, ElevatorCloseTweenInfo.EasingStyle, ElevatorCloseTweenInfo.EasingDirection);

		right:PivotTo(originRight:Lerp(finalPositionRight, alpha));
		left:PivotTo(originLeft:Lerp(finalPositionLeft, alpha));
	end
end

local function AddElevator(elevator: Model)
	elevators[elevator] = {
		model = elevator,
		originRight = elevator:WaitForChild("ElevatorDoorRight").WorldPivot,
		originLeft = elevator:WaitForChild("ElevatorDoorLeft").WorldPivot,
		open = false,
		inside = false,
	};	
	
	elevator:WaitForChild("RegionHitbox");
end

-- Load in elevators
for _, elevator in pairs(ElevatorFolder:GetChildren()) do 
	AddElevator(elevator);
end

-- Events
ElevatorFolder.ChildAdded:Connect(AddElevator);

-- Main Loop
--TEMP
local out = Vector3.new(49.25, 0.125, -1.25);
--/TEMP

RunService.PreSimulation:Connect(function(deltaTime: number)
	local character = Player.Character;
	if (not character) then return end;
	
	for _, elevator in pairs(elevators) do 
		local pos = elevator.model:GetPivot().Position;
		local delta = character.HumanoidRootPart.Position - pos;
		local dist = delta.Magnitude;
		
		if (dist <= 22 and elevator.open == false) then 
			OpenElevator(elevator.model);
		elseif (dist > 22 and elevator.open == true) then 
			CloseElevator(elevator.model);
		end
		
		elevator.inside = Utility.Collision3d(character.HumanoidRootPart, elevator.model.RegionHitbox);
		-- TEMP
		if (elevator.inside) then 
			character:MoveTo(out);
		end
		-- /TEMP
	end
end)
