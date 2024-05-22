rawset(_G, "khBlast", true)
rawset(_G, "khBlastVersion", "RC 2")
rawset(_G, "khBlastDiff", 1)
rawset(_G, "khBlastcleargame", false)
rawset(_G, "MATCHXPMOD", 100)
rawset(_G, "RATTACKXPMOD", 10)
rawset(_G, "nextKHBlastDiff", 1)
rawset(_G, "marathonDiff", 1)

rawset(_G, "getEmeraldCount", function(flags)
	local numEmeralds = 0
	if All7Emeralds(flags) then return 7 end
	local i
	local j = flags
	for i = 1, 7 do
		if (j % 2) == 1 then numEmeralds = $ + 1 end
		j = j / 2
		if j == 0 then return numEmeralds end
	end
	return numEmeralds
end)

rawset (_G, "setupKHStuff", function(p)
	if not p.kh then
		p.kh = {
			itemlist = {},
			commandlist = {},
			lastWpn = 0,
			lastMagic = 1,
			cOption = 1,
			comButton = false,
			lastOption = 1,
			menuMode = 0,
			xp = 0,
			level = 1
		}
		p.lives = 1
		return true //Just set them up
	end
	return false //Already set up
end)

COM_AddCommand("changeKHDiffMarathon", function(player, newDiff)
	if newDiff == nil
		CONS_Printf(player, "This command allows you to set the difficulty level as the default for marathons.")
	elseif (tonumber(newDiff) > -1) and (tonumber(newDiff) < 5) then
		marathonDiff = newDiff
		CONS_Printf(player, "The default difficulty has been changed to "..khBlastDiffTable[marathonDiff][1].."!")
	else
		local diffStr = string.upper(newDiff)
		if diffStr == "BEGINNER" or diffStr == "STANDARD" or diffStr == "PROUD" or diffStr == "CRITICAL" or diffStr == "EXP ZERO" then
			if diffStr == "BEGINNER" then
				marathonDiff = 0
			elseif diffStr == "STANDARD" then
				marathonDiff = 1
			elseif diffStr == "PROUD" then
				marathonDiff = 2
			elseif diffStr == "CRITICAL" then
				marathonDiff = 3
			elseif diffStr == "EXP ZERO" then
				marathonDiff = 4
			end
			CONS_Printf(player, "The default difficulty has been changed to "..khBlastDiffTable[marathonDiff][1].."!")
		else
			CONS_Printf(player, "Error - " .. newDiff .. " is not a valid Difficulty value")
		end
	end
end, 1)

addHook("ThinkFrame", function()
	//Temp deets for testing
	for p in players.iterate do
		if p.hp == nil then
			if not (p.mo and p.mo.skin) continue end
			local skin = p.mo.skin
			local data = characterData[skin]
			p.hp = data.StartingHP
			p.maxHP = data.StartingHP
			p.mp = data.StartingMP
			p.maxMP = data.StartingMP
			p.mpRecharge = 0
			print(setupKHStuff(p))
		end
	end
end)