local transparencyModifier = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("TransparencyModifier");
local tweenService = game:GetService("TweenService");
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Sine);

transparencyModifier.OnClientInvoke = function(object, modifier)
	tweenService:Create(object, tweenInfo, {Transparency = modifier}):Play();
end
