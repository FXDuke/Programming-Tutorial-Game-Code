local parts = {};

local testModule = {
	PartAdded = function(part: Part)
		parts[part] = true;
		
		task.spawn(function()
			while (parts[part]) do 
				task.wait();
				part.AssemblyLinearVelocity = part.AssemblyLinearVelocity:Abs() * 0.9;
			end
		end)
	end,	
	PartRemoved = function(part: Part)
		parts[part] = nil;
	end,
	PlayerAdded = function(player: Player)
		print(player.Name .. " walked into region");
	end,
	PlayerRemoving = function(player: Player)
		print(player.Name .. " walked out of region");
	end,
};

return testModule;
