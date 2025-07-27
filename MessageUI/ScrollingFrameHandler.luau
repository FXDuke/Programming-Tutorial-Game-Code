-- This script operates similar to a UIGridLayout.

-- Services
local TweenService = game:GetService("TweenService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

-- Assets
local Modules = ReplicatedStorage:WaitForChild("Modules");
local Utility = require(Modules:WaitForChild("Utility"));

-- Constants
local Parent = script.Parent;
local CanvasGroup = Parent.Parent;
local CanvasGradiant = CanvasGroup:WaitForChild("TransparencyGradient");

-- UI Variables
local padding = 5; -- in pixels
local updated = false;
local messageSizeY = 75;
local messageSize = UDim2.new(1,0,0,messageSizeY);
local canvasGroupTransparency = false;

-- Tween Variables
local MoveScrollbarTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Sine);
local ScrollbarTweenInInfo = TweenInfo.new(0.15, Enum.EasingStyle.Sine);
local ScrollbarTweenOutInfo = TweenInfo.new(0.15, Enum.EasingStyle.Sine);
local CanvasGroupTransparencyTweenInfoIn = TweenInfo.new(0.075, Enum.EasingStyle.Sine, Enum.EasingDirection.In);
local CanvasGroupTransparencyTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In);

-- NumberSequence Tween variables
local DisableCanvasGroupTransparency = {0,0,0,0};
local EnableCanvasGroupTransparency = {0,0,0.419,1};

-- Precooked Tweens
local ScrollbarTweenIn = TweenService:Create(Parent, ScrollbarTweenInInfo, {ScrollBarImageTransparency = 0});
local ScrollbarTweenOut = TweenService:Create(Parent, ScrollbarTweenOutInfo, {ScrollBarImageTransparency = 1});

-- Functions
local function GetOrderedChildren()
	local children = Parent.Children:GetChildren();
	local order = {};

	while (#order < #children) do 
		
		-- Find lowest frame in list (LayoutOrder will be the MessageID, which can be any integer greater than 0)
		local lowest = math.huge;
		local lowestFound = nil;
		local lowestFoundID = nil;
		for id, child in children do 
			if (lowest < child.LayoutOrder) then continue end;
			lowest = child.LayoutOrder;
			lowestFound = child;
			lowestFoundID = id;
		end

		-- If nothing was found, throw error
		if (lowestFound == nil and #order < #children) then 
			error("Error with finding layout order of Message UI");
		end

		-- Add to table
		table.insert(order, lowestFound);
		
		-- Clear from table to prevent duplicates
		if (lowestFound) then 
			rawset(children, lowestFoundID, nil);
		end
	end
	
	return order;
end

-- Updates UI size and member positions
local function UpdateUI()
	updated = false;
	
	-- Get ordered children
	local orderedChildren = GetOrderedChildren();
	local amount = #orderedChildren;
	if (amount == 0) then return end;
	
	-- Update canvas size
	Parent.CanvasSize = UDim2.new(0,0,0, messageSizeY * amount + padding * (amount - 1));
	
	-- Update object positions in frame
	
	print(amount, orderedChildren);
	
	for position, object: Frame in ipairs(orderedChildren) do 
		local fromBottom = amount - position;
		object.Position = (Parent.CanvasSize - UDim2.new(0,0,0,messageSizeY * (fromBottom + 1) + padding * fromBottom));
	end
	
	-- Tween canvas position to bottom
	Parent.CanvasSize = UDim2.new(0,0,0, messageSizeY * amount + padding * amount);
	TweenService:Create(Parent, MoveScrollbarTweenInfo, {CanvasPosition = Vector2.new(0, Parent.AbsoluteCanvasSize.Y)}):Play();
	
	updated = true;
end

local function UIAdded(ui)
	ui.Size = messageSize; -- change size
	UpdateUI();
end

-- Scrolling Frame Interaction Functions
local function MouseEnter()
	ScrollbarTweenIn:Play();
end

local function MouseLeave()
	ScrollbarTweenOut:Play();
end

-- Callback for TweenNumberSequence
local function UpdateCanvasGroupTransparency(numberSequence: NumberSequence)
	CanvasGradiant.Transparency = numberSequence;
end

-- When the scrolling frame changes, (i.e; when the player scrolls) see if it is near the top to disable the canvas group transparency gradient
local function Changed()
	if (not updated) then return end;
	if (Parent.CanvasPosition.Y < messageSizeY / 2 and canvasGroupTransparency) then 
		canvasGroupTransparency = false;
		Utility.TweenNumberSequence(CanvasGradiant.Transparency, CanvasGroupTransparencyTweenInfoIn, UpdateCanvasGroupTransparency, DisableCanvasGroupTransparency);
	elseif (Parent.CanvasPosition.Y >= messageSizeY / 2 and not canvasGroupTransparency) then 
		canvasGroupTransparency = true;
		Utility.TweenNumberSequence(CanvasGradiant.Transparency, CanvasGroupTransparencyTweenInfo, UpdateCanvasGroupTransparency, EnableCanvasGroupTransparency);
	end
end

-- Events
Parent.Children.ChildAdded:Connect(UIAdded);
Parent.Children.ChildRemoved:Connect(UpdateUI);
Parent.MouseEnter:Connect(MouseEnter);
Parent.MouseLeave:Connect(MouseLeave);
Parent.Changed:Connect(Changed);
