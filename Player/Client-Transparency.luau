local transparencyModifier: BindableFunction = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("TransparencyModifier");
local tweenService = game:GetService("TweenService");
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Sine);

transparencyModifier.OnInvoke = function(object, modifier)
	tweenService:Create(object, tweenInfo, {Transparency = modifier}):Play();
end
