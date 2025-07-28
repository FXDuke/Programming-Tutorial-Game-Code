-- This program is specifically only meant to be run during game development, converting scripts into Rich Text.
-- This is uncommented spaghetti code, probably poorly optimized etc, but it works!


local ReservedWordsRed = {
	["if"] = true,
	["then"] = true,
	["elseif"] = true,
	["else"] = true,
	["while"] = true,
	["do"] = true,
	["for"] = true,
	["return"] = true,
	["end"] = true,
	["break"] = true,
	["until"] = true,
	["repeat"] = true,
	["local"] = true,
	["in"] = true,
	["not"] = true,
	["function"] = true,
	["and"] = true,
	["continue"] = true,
	["or"] = true,
};

local ReservedWordsYellow = {
	["true"] = true,
	["false"] = true,
	["nil"] = true,	
};

local ValidLetters = {
	a = true, b = true, c = true, d = true, e = true,
	f = true, g = true, h = true, i = true, j = true,
	k = true, l = true, m = true, n = true, o = true,
	p = true, q = true, r = true, s = true, t = true,
	u = true, v = true, w = true, x = true, y = true, z = true,
};

local ValidNumbers = {
	["."] = true,	
};
for i = 0, 9 do 
	ValidNumbers[tostring(i)] = true;
end

local red = "#f86d7c";
local yellowReserved = "#ffc608";
local yellowFunction = "#fdfb97"
local blue = "#67d6f7";
local green = "#adf195";
local grey = "#bfbfbf";
local numberYellow = "#ffaf25";
local lightGrey = "#5d6666";

local function ColorString(content, color)
	if (not color) then return content end;
	return [[<font color=']] .. color .. [['>]] .. content .. [[</font>]];
end

local function GetColor(content: string)
	if (ReservedWordsRed[content]) then return red end;
	if (ReservedWordsYellow[content]) then return yellowReserved end;
	if (getfenv()[content]) then return blue end;
end

return function(content: string)
	local output = "";

	local currentWord = "";
	local lastWord = "";
	local numberString = "";
	local spaceOrTab = false;
	local inString = false;
	local note = false;
	local followingColon = false;
	local number = false;
	for i = 1, string.len(content) do 
		local char = string.sub(content, i, i);
		if (not ValidLetters[char:lower()] and not ValidNumbers[char] and char ~= "-") then 

			if (note) then 
				output ..= ColorString(currentWord, lightGrey);
			elseif (number) then 
				output ..= ColorString(numberString, numberYellow);
			elseif (inString) then 
				output ..= ColorString(currentWord, green);
			elseif (followingColon or string.sub(content, i+1, i+1) == "(" and not ReservedWordsRed[currentWord] and not ReservedWordsYellow[currentWord]) then 
				output ..= ColorString(currentWord, yellowFunction);
			elseif (lastWord == "function" and spaceOrTab) then 
				output ..= ColorString(currentWord, yellowFunction);
			else 
				local color = GetColor(currentWord);
				output ..= ColorString(currentWord, color);
			end

			if (char == [["]] or char == "'") then 
				inString = not inString;
			end

			output ..= char;
			lastWord = currentWord;
			numberString = "";
			spaceOrTab = char == " " or char == "\t";
			currentWord = "";
			number = false;
			note = note and char ~= "\n";
			followingColon = false;
		elseif (char == "-" and string.sub(content, i-1, i-1) == "-" or string.sub(content, i+1, i+1) == "-") then 
			note = true;
			currentWord ..= char;
		elseif (ValidNumbers[char] and spaceOrTab and currentWord == "") then 
			
			if (char == "." and not ValidNumbers[string.sub(content, i+1, i+1)]) then 
				number = false;
				currentWord ..= char;
				numberString = "";
			elseif ((string.sub(content, i+1, i+1) == "." or string.sub(content, i-1, i-1) == ".") and char == ".") then 
				number = false;
				currentWord ..= char;
				numberString = "";
			else 
				number = true;
				numberString ..= char;
			end
			
		else 
			currentWord ..= char;
		end

		if (char == ":") then followingColon = true end;


	end

	return output;
end
