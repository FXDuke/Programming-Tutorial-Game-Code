-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");

-- Constants
local Parent = script.Parent;
local ContainerCanvas = Parent:WaitForChild("Container");
local ScrollingFrame = ContainerCanvas:WaitForChild("ScrollingFrame");
local ScrollingFrameChildren = ScrollingFrame:WaitForChild("Children");

-- Assets
local Remotes = ReplicatedStorage:WaitForChild("Remotes");
local MessageEvent = Remotes:WaitForChild("Message");
local Template = script:WaitForChild("Template");

-- Functions
local MessageID = 0;
local function MessageAdded(messageData: UIPackedMessage)
	-- Create new message ui
	local newTemplate = Template:Clone();
	
	-- Update message content 
	newTemplate.Content.Text = messageData.content;
	newTemplate.Parent = ScrollingFrameChildren;
	newTemplate.Visible = true;
	newTemplate.LayoutOrder = MessageID;
	
	-- Add to message id
	MessageID += 1;
	
	-- Make it so if you click it destroys message
	newTemplate.Content.MouseButton1Up:Once(function()
		newTemplate:Destroy();
	end)
	
	-- Delete message after duration
	if (messageData.duration > 0) then 
		task.delay(messageData.duration, function()
			newTemplate:Destroy();
		end)
	end
end

-- Events
MessageEvent.OnClientEvent:Connect(MessageAdded);
