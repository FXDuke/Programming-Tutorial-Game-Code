local parts = {};

local testModule = {
	PartAdded = function(part: Part)
		
		parts[part] = true;
		
		task.spawn(function()
			while (parts[part]) do 
				part.AssemblyLinearVelocity -= part.AssemblyLinearVelocity * task.wait() * 50;
			end
		end)
		
		print(part.Name .. " added to test region");
	end,	
	PartRemoved = function(part: Part)
		print(part.Name .. " was removed from test region");
		
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
