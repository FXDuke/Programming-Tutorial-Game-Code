-- Services
local TweenService = game:GetService("TweenService");

-- Constants 
local Music = script:GetChildren();

-- Tween Variables
local FadeOutInfo = TweenInfo.new(1.5, Enum.EasingStyle.Sine);
local FadeInInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine);
local FirstLoadFadeIn = TweenInfo.new(2.5, Enum.EasingStyle.Sine);

-- Variables
local currentSong: Sound = nil;
local currentVolume = 0.25;
local thread = nil;

-- Functions
function LoopPlay()
	-- Wait until song is almost finished to start next song
	repeat task.wait() until currentSong.TimeLength > 0;
	task.wait(currentSong.TimeLength - FadeOutInfo.Time - currentSong.TimePosition);
	TweenService:Create(currentSong, FadeOutInfo, {Volume = 0}):Play();
	
	-- Stop song after tween is complete
	task.wait(FadeOutInfo.Time);
	currentSong:Stop();
	
	-- Wait before starting next song
	task.wait(math.random(3,8));
	
	-- Generate next song
	local random = math.random(1, #Music - 1);
	local tick = 1;
	
	for i, v in Music do 
		if (v == currentSong) then continue end;
		if (tick == Random) then 
			-- Set next song
			currentSong = v;
			currentSong.Volume = 0;
			currentSong:Play();
			
			-- Animate in song
			TweenService:Create(currentSong, FadeInInfo, {Volume = currentVolume}):Play();
			thread = task.spawn(LoopPlay);
			break;
		end
		tick += 1;
	end
end

-- Module
local BackgroundMusic;
BackgroundMusic = {
	Play = function()
		if (currentSong) then return currentSong:Stop() end;
		
		local random = math.random(1, #Music);
		currentSong = Music[random];
		currentSong:Play();
		currentSong.Volume = 0;
		
		TweenService:Create(currentSong, FirstLoadFadeIn, {Volume = currentVolume}):Play();
		thread = task.spawn(LoopPlay);
	end,	
	Stop = function()
		if (thread) then 
			task.cancel(thread);
		end
		
		if (currentSong) then 
			currentSong:Stop();
		end
		
		currentSong = nil;
		thread = nil;
	end,
	Resume = function()
		if (not currentSong) then return BackgroundMusic.Play(); end;
		currentSong.Volume = 0;
		currentSong:Resume();
		TweenService:Create(currentSong, FirstLoadFadeIn, {Volume = currentVolume}):Play();
		thread = task.spawn(LoopPlay);
	end,
	Pause = function()
		if (not currentSong) then return end;

		TweenService:Create(currentSong, FadeOutInfo, {Volume = 0}):Play();
		task.cancel(thread);
		thread = nil;
		
		task.spawn(function()
			task.wait(FadeOutInfo.Time);
			if (thread) then return end;
			currentSong:Pause();
		end)
	end,
};

return BackgroundMusic;
